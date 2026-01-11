@SuppressWarnings('PMD.AvoidGlobalModifier,PMD.NcssMethodCount,PMD.CyclomaticComplexity,PMD.ExcessiveClassLength')
global with sharing class PostInstall implements InstallHandler {
    public Integer batchSize = 0;

    private Version previousVersion;
    private OppPlanPostInstall oppi;

    private List<SObject> objectsToUpdate = new List<SObject>();
    private List<SObject> objectsToInsert = new List<SObject>();

    private Set<Schema.SObjectType> schemasToUpdate = new Set<Schema.SObjectType>();
    private Set<Schema.SObjectType> schemasToInsert = new Set<Schema.SObjectType>();

    global void onInstall(InstallContext context) {
        Application.bypassTrigger = true;
        if (context.previousVersion() != null) {
            previousVersion = context.previousVersion();
            doUpgrade();
        } else {
            doInstall();
        }

        doNonVersionCheckInstall();
        oppi = new OppPlanPostInstall(context.previousVersion());
        processBatches();
        Application.bypassTrigger = false;
    }

    private void doUpgrade() {
        //Fixing data issues that can cause problems if left alone
        //such as duplicate settings objects
        dataIntegrityFixes();

        // Version upgrade steps with more added over time
        if (isInstalledVersionBefore(new Version(1, 8))) {
            installWhiteSpaceAmountType();
        }

        // Migrate org settings
        if (isInstalledVersionBefore(new Version(3, 0))) {
            createOrgSettingsFromCustomSettingsIfNeeded();
        } else {
            createNewOrgSettingsIfNeeded();
        }

        // Add data type to wsAmountTypes
        if (isInstalledVersionBefore(new Version(6, 0))) {
            updateWhiteSpaceAmountTypes();
        }

        // Add map type to Org Chart Fields
        if (isInstalledVersionBefore(new Version(7, 1))) {
            updateOrgChartFieldsMapType();
        }

        // Update SWOT Description to Rich Text
        if (isInstalledVersionBefore(new Version(8, 0))) {
            updateSWOTDescription();
            activateExistingWhiteSpaceAmountTypes();
        }

        // Update Contact Relationships
        if (isInstalledVersionBefore(new Version(9, 0))) {
            updateContactRelationships();
            updateRMChartSettings();
        }

        // Update WS User Settings Filter Fields
        if (isInstalledVersionBefore(new Version(10, 0))) {
            updateWSUserSettings();
            updateSupportColorValues();
        }

        // Update Whitespace Picklist Rows/Columns
        if (isInstalledVersionBefore(new Version(11, 2))) {
            updateWSPicklistHeaders();
        }

        if (isInstalledVersionBefore(new Version(12, 1))) {
            updateContactRelationshipTypes();
            insertDefaultSvg();
        }

        if (isInstalledVersionBefore(new Version(12, 5))) {
            updateRMOrgSettings();
        }

        if (isInstalledVersionBefore(new Version(12, 10))) {
            updateRMOrgSettings2();
            updateCRUSHOrgSettingForCreateInWS();
        }

        // SUMMER 2022 RELEASE
        if (isInstalledVersionBefore(new Version(13, 0))) {
            createDefaultInfluenceSupportMatrix();
            updateRMChartSettings2();
            updatePlanOverviews();
            updateCRUSHOrgSettingForUseDefaultScore();
            updateCRUSHOrgSettingForUsePercentageScore();
            updateWhiteSpaceHighlights();
            updateRMOrgSettingsForButtonVisibility();
            insertDefaultSvg2();
        }

        if (isInstalledVersionBefore(new Version(13, 9))) {
            updateUserSettingsForFilterDataDefaults();
        }

        // SPRING 2023 RELEASE
        if (isInstalledVersionBefore(new Version(14, 0))) {
            convertKSToRM();
        }

        if (isInstalledVersionBefore(new Version(14, 4))) {
            updateRmOrgSettingsForGroupMenuEditable();
        }

        if (isInstalledVersionBefore(new Version(15, 3))) {
            updateStakeholderAutoCreateSetting();
        }
    }

    private void doInstall() {
        // Any first time install logic
        installWhiteSpaceAmountType();
        createNewOrgSettingsIfNeeded();
        createDefaultRelationshipType();
        insertDefaultSvg();
        createDefaultInfluenceSupportMatrix();
        updateRMOrgSettingsForButtonVisibility();
        insertDefaultSvg2();
    }

    private void doNonVersionCheckInstall() {
        // Do installs that check things that are not version related (ex. checking to see if object exists)
        installSupportColors();
        setupKeyStakeholderDisplayFields();
        addTeamMemberOwners();
    }

    private void dataIntegrityFixes() {
        // Fix duplicate chart settings objects
        fixDuplicateChartSettings();
    }

    private Boolean isInstalledVersionBefore(Version version) {
        return previousVersion.compareTo(version) < 0;
    }

    private void processBatches() {
        if (this.objectsToInsert.size() > 0 && this.schemasToInsert.size() > 0) {
            PostInstallHelperService.executeBatchInsertForRecords(
                this.objectsToInsert,
                new List<Schema.SObjectType>(this.schemasToInsert),
                this.batchSize <= 0 ? null : this.batchSize,
                true
            );
        }
        if (this.objectsToUpdate.size() > 0 && this.schemasToUpdate.size() > 0) {
            PostInstallHelperService.executeBatchUpdateForRecords(
                this.objectsToUpdate,
                new List<Schema.SObjectType>(this.schemasToUpdate),
                this.batchSize <= 0 ? null : this.batchSize,
                true
            );
        }
    }

    private void installWhiteSpaceAmountType() {
        if (!Schema.sObjectType.White_Space_Amount_Type__c.isCreateable()) {
            return;
        }

        White_Space_Amount_Type__c us = new White_Space_Amount_Type__c(
            Name = 'Current Spend',
            Abbreviation__c = 'Current',
            Color_RGB__c = '#4da0ee',
            Order__c = 2,
            Display_Type__c = 'Currency'
        );

        insert us;

        White_Space_Amount_Type__c comp = new White_Space_Amount_Type__c(
            Name = 'Competitor',
            Abbreviation__c = 'Compete',
            Color_RGB__c = '#ee7575',
            Order__c = 3,
            Display_Type__c = 'Currency'
        );

        insert comp;

        White_Space_Amount_Type__c upside = new White_Space_Amount_Type__c(
            Name = 'Upside',
            Abbreviation__c = 'Upside',
            Color_RGB__c = '#75b65f',
            Order__c = 1,
            Display_Type__c = 'Currency'
        );

        insert upside;
    }

    private void installSupportColors() {
        Crush_Settings_Obj__c orgSettings = getOrgSettingsAndCreateIfNeeded();

        if (String.isBlank(orgSettings.Support_Colors_Long__c)) {
            Map<String, String> mapToConvert = new Map<String, String>();
            mapToConvert.put('Champion', '#97D700');
            mapToConvert.put('Floater', '#E5E1E6');
            mapToConvert.put('Supporter', '#FFC741');
            mapToConvert.put('Blocker', '#FF0000');

            orgSettings.Support_Colors_Long__c = UtilityForString.parseMapToNameValueString(mapToConvert);

            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new List<Schema.SObjectType>{ Crush_Settings_Obj__c.SObjectType }
            );

            uow.registerDirty(orgSettings);
            uow.commitWork();
        }
    }

    private void updateCRUSHOrgSettingForCreateInWS() {
        if (
            !Schema.sObjectType.Crush_Settings_Obj__c.fields.Can_Create_Objects_In_Cross_Sell__c.isAccessible() ||
            !Schema.sObjectType.Crush_Settings_Obj__c.fields.Can_Create_Objects_In_Cross_Sell__c.isUpdateable()
        ) {
            return;
        }

        Crush_Settings_Obj__c orgSettings = getOrgSettingsAndCreateIfNeeded();

        orgSettings.Can_Create_Objects_In_Cross_Sell__c = true;

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ Crush_Settings_Obj__c.SObjectType }
        );

        uow.registerDirty(orgSettings);
        uow.commitWork();
    }

    private void updateCRUSHOrgSettingForUseDefaultScore() {
        if (
            !Schema.sObjectType.Crush_Settings_Obj__c.fields.Use_Default_Account_Plan_Score__c.isAccessible() ||
            !Schema.sObjectType.Crush_Settings_Obj__c.fields.Use_Default_Account_Plan_Score__c.isUpdateable()
        ) {
            return;
        }

        Crush_Settings_Obj__c orgSettings = getOrgSettingsAndCreateIfNeeded();

        orgSettings.Use_Default_Account_Plan_Score__c = true;

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ Crush_Settings_Obj__c.SObjectType }
        );

        uow.registerDirty(orgSettings);
        uow.commitWork();
    }

    private void updateCRUSHOrgSettingForUsePercentageScore() {
        if (
            !Schema.sObjectType.Crush_Settings_Obj__c.fields.Use_Percentage_Account_Plan_Score__c.isAccessible() ||
            !Schema.sObjectType.Crush_Settings_Obj__c.fields.Use_Percentage_Account_Plan_Score__c.isUpdateable()
        ) {
            return;
        }

        Crush_Settings_Obj__c orgSettings = getOrgSettingsAndCreateIfNeeded();

        orgSettings.Use_Percentage_Account_Plan_Score__c = true;

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ Crush_Settings_Obj__c.SObjectType }
        );

        uow.registerDirty(orgSettings);
        uow.commitWork();
    }

    private void updateSWOTDescription() {
        if (
            !Schema.sObjectType.SWOT_Analysis__c.isQueryable() ||
            !Schema.sObjectType.SWOT_Analysis__c.isUpdateable() ||
            !Schema.sObjectType.SWOT_Analysis__c.fields.Description_Rich_Text__c.isUpdateable()
        ) {
            return;
        }

        List<SWOT_Analysis__c> swots = [
            SELECT Id, Description__c, Description_Rich_Text__c
            FROM SWOT_Analysis__c
            WHERE Description__c != NULL AND Description__c != ''
        ];
        for (SWOT_Analysis__c swot : swots) {
            swot.Description_Rich_Text__c = swot.Description__c;
        }
        update swots;
    }

    private void updateWhiteSpaceAmountTypes() {
        if (
            !Schema.sObjectType.White_Space_Amount_Type__c.isQueryable() ||
            !Schema.sObjectType.White_Space_Amount_Type__c.isUpdateable() ||
            !Schema.sObjectType.White_Space_Amount_Type__c.fields.Display_Type__c.isUpdateable()
        ) {
            return;
        }

        List<White_Space_Amount_Type__c> ats = [
            SELECT Id, Display_Type__c
            FROM White_Space_Amount_Type__c
            WHERE Display_Type__c = NULL
        ];
        for (White_Space_Amount_Type__c at : ats) {
            at.Display_Type__c = 'Currency';
        }
        update ats;
    }

    private void activateExistingWhiteSpaceAmountTypes() {
        if (
            !Schema.sObjectType.White_Space_Amount_Type__c.isQueryable() ||
            !Schema.sObjectType.White_Space_Amount_Type__c.isUpdateable() ||
            !Schema.sObjectType.White_Space_Amount_Type__c.fields.IsActive__c.isUpdateable()
        ) {
            return;
        }

        List<White_Space_Amount_Type__c> atList = new List<White_Space_Amount_Type__c>();

        for (White_Space_Amount_Type__c at : [SELECT Id FROM White_Space_Amount_Type__c WHERE OwnerId != NULL]) {
            at.IsActive__c = true;
            atList.add(at);
        }
        update atList;
    }

    private void updateContactRelationships() {
        Contact_Relationship_Type__c relType = createDefaultRelationshipType();

        List<Contact_Relationship__c> relationships = new List<Contact_Relationship__c>();

        for (Contact_Relationship__c rel : [
            SELECT Id, Contact_Relationship_Type__c
            FROM Contact_Relationship__c
            WHERE OwnerId != NULL
        ]) {
            rel.Contact_Relationship_Type__c = relType.Id;
            relationships.add(rel);
        }

        fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ Contact_Relationship__c.SObjectType }
        );

        uow1.registerDirty(relationships);
        uow1.commitWork();

        List<Map_Member_Placeholder_Relationship__c> otherRelationships = new List<Map_Member_Placeholder_Relationship__c>();

        for (Map_Member_Placeholder_Relationship__c otherRel : [
            SELECT Id, Type__c, Contact_Relationship_Type__c
            FROM Map_Member_Placeholder_Relationship__c
            WHERE OwnerId != NULL
        ]) {
            if (otherRel.Type__c == 'Custom') {
                otherRel.Contact_Relationship_Type__c = relType.Id;
                otherRel.Is_Hierarchy__c = false;
            } else {
                otherRel.Is_Hierarchy__c = true;
            }

            otherRelationships.add(otherRel);
        }

        fflib_SObjectUnitOfWork uow2 = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ Map_Member_Placeholder_Relationship__c.SObjectType }
        );

        uow2.registerDirty(otherRelationships);
        uow2.commitWork();
    }

    private Contact_Relationship_Type__c createDefaultRelationshipType() {
        if (!Schema.sObjectType.Contact_Relationship_Type__c.IsCreateable()) {
            return null;
        }

        Contact_Relationship_Type__c relType = new Contact_Relationship_Type__c(
            Name = 'Relationship',
            Color__c = '#0080ff',
            Label__c = 'relationship',
            Label_Editable__c = true,
            IsActive__c = true,
            Used_in_all_account_plans__c = true,
            Used_in_all_relationship_maps__c = true
        );

        insert relType;
        return relType;
    }

    private void updateOrgChartFieldsMapType() {
        if (
            !Schema.sObjectType.Org_Chart_Field__c.isQueryable() ||
            !Schema.sObjectType.Org_Chart_Field__c.isUpdateable() ||
            !Schema.sObjectType.Org_Chart_Field__c.fields.Map_Type__c.isUpdateable()
        ) {
            return;
        }

        List<Org_Chart_Field__c> fields = [SELECT Id, Map_Type__c FROM Org_Chart_Field__c WHERE Map_Type__c = NULL];
        for (Org_Chart_Field__c ocf : fields) {
            ocf.Map_Type__c = 'Key Stakeholder';
        }
        update fields;
    }

    private void setupKeyStakeholderDisplayFields() {
        Crush_Settings_Obj__c orgSettings = getOrgSettingsAndCreateIfNeeded();
        List<Org_Chart_Field__c> fields = [SELECT Id FROM Org_Chart_Field__c LIMIT 1];
        string strMapType = 'Relationship Map';
        if (fields.size() > 0) {
            fields = [SELECT Id FROM Org_Chart_Field__c WHERE Map_Type__c = 'Relationship Map' LIMIT 1];
            if (fields.size() > 0) {
                return;
            } else {
                fields = OrgChartSettingsController.createRelationshipMapDefaultsWithoutInsertForSettingsObj(
                    orgSettings,
                    strMapType
                );
            }
        } else {
            List<Org_Chart_Field__c> ksFields = OrgChartSettingsController.createOrgChartDefaultsWithoutInsertForSettingsObj(
                orgSettings
            );
            if (ksFields != null) {
                fields.addAll(ksFields);
            }
            List<Org_Chart_Field__c> rmFields = OrgChartSettingsController.createRelationshipMapDefaultsWithoutInsertForSettingsObj(
                orgSettings,
                strMapType
            );
            if (rmFields != null) {
                fields.addAll(rmFields);
            }
        }
        if (fields != null && fields.size() > 0) {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new List<Schema.SObjectType>{ Org_Chart_Field__c.SObjectType }
            );

            uow.registerNew(fields);
            uow.commitWork();
        }
    }

    private void addTeamMemberOwners() {
        if (!Schema.sObjectType.Team_Member__c.isCreateable()) {
            return;
        }

        Integer queryRowLimit = Limits.getLimitQueryRows();
        List<Account_Plan__c> accountPlans = [
            SELECT Id, OwnerId, (SELECT Id, User__c FROM Team_Members__r)
            FROM Account_Plan__c
            LIMIT :queryRowLimit
        ];

        List<Team_Member__c> ownerTeamMembersToAdd = new List<Team_Member__c>();
        for (Account_Plan__c accountPlan : accountPlans) {
            SObject foundOwner = Collection.find(
                accountPlan.pqcrush__Team_Members__r,
                Team_Member__c.User__c,
                Collection.EQUALS,
                accountPlan.OwnerId
            );
            if (foundOwner == null) {
                ownerTeamMembersToAdd.add(
                    new Team_Member__c(
                        Role__c = 'Edit',
                        User__c = accountPlan.OwnerId,
                        Account_Plan__c = accountPlan.Id
                    )
                );
            }
        }

        if (ownerTeamMembersToAdd.size() > 0) {
            insert ownerTeamMembersToAdd;
        }
    }

    private void createOrgSettingsFromCustomSettingsIfNeeded() {
        if (!Schema.sObjectType.CRUSH_Settings__c.isCreateable()) {
            return;
        }

        if (!allSettingsCustomFieldsInsertable()) {
            return;
        }

        Crush_Settings_Obj__c currentSettings = getOrgSettings();
        if (currentSettings == null) {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new List<Schema.SObjectType>{ Crush_Settings_Obj__c.SObjectType }
            );
            CRUSH_Settings__c customSettings = CRUSH_Settings__c.getOrgDefaults();
            CrushSettings wrapped = new CrushSettings(customSettings);
            currentSettings = wrapped.toSObject();
            uow.registerNew(currentSettings);
            uow.commitWork();
        }
    }

    private Boolean allSettingsCustomFieldsInsertable() {
        Map<String, Schema.SObjectField> fieldDescribeTokens = Schema.SObjectType.CRUSH_Settings__c.fields.getMap();
        for (Schema.SObjectField field : fieldDescribeTokens.values()) {
            Schema.DescribeFieldResult describe = field.getDescribe();
            if (describe.isCustom() && !describe.isCreateable()) {
                return false;
            }
        }
        return true;
    }

    private void fixDuplicateChartSettings() {
        if (!Schema.sObjectType.RM_Chart_Setting__c.isQueryable()) {
            return;
        }

        List<RM_Chart_Setting__c> settings = [
            SELECT Id, LastModifiedDate, pqcrush__Account_Plan__c, pqcrush__Relationship_Map__c
            FROM RM_Chart_Setting__c
            WHERE OwnerId != NULL
        ];

        Map<Id, RM_Chart_Setting__c> settingsMap = new Map<Id, RM_Chart_Setting__c>();
        List<RM_Chart_Setting__c> settingsToDelete = new List<RM_Chart_Setting__c>();
        for (RM_Chart_Setting__c setting : settings) {
            Id related = setting.pqcrush__Account_Plan__c != null
                ? setting.pqcrush__Account_Plan__c
                : setting.pqcrush__Relationship_Map__c;
            if (settingsMap.containsKey(related)) {
                RM_Chart_Setting__c existing = settingsMap.get(related);
                if (existing.LastModifiedDate < setting.LastModifiedDate) {
                    settingsToDelete.add(existing);
                    settingsMap.put(related, setting);
                } else {
                    settingsToDelete.add(setting);
                }
            } else {
                settingsMap.put(related, setting);
            }
        }
        fflib_ISObjectUnitOfWork uow = Application.PostInstallUnitOfWork.newInstance();
        uow.registerDeleted(settingsToDelete);
        uow.commitWork();
    }

    private void updateRMChartSettings() {
        if (
            !Schema.sObjectType.RM_Chart_Setting__c.isQueryable() ||
            !Schema.sObjectType.RM_Chart_Setting__c.isUpdateable() ||
            !Schema.sObjectType.RM_Chart_Setting__c.fields.Auto_Layout__c.isUpdateable() ||
            !Schema.sObjectType.RM_Chart_Setting__c.fields.Is_Group_Global_Scope__c.isUpdateable() ||
            !Schema.sObjectType.RM_Chart_Setting__c.fields.Is_Relationship_Line_Global_Scope__c.isUpdateable()
        ) {
            return;
        }

        List<RM_Chart_Setting__c> settings = [
            SELECT Id, Auto_Layout__c, Is_Group_Global_Scope__c, Is_Relationship_Line_Global_Scope__c
            FROM RM_Chart_Setting__c
            WHERE OwnerId != NULL
        ];
        for (RM_Chart_Setting__c setting : settings) {
            setting.Auto_Layout__c = true;
            setting.Is_Group_Global_Scope__c = true;
            setting.Is_Relationship_Line_Global_Scope__c = true;
        }
        update settings;
    }

    private void updateRMChartSettings2() {
        if (
            !Schema.sObjectType.RM_Chart_Setting__c.isQueryable() ||
            !Schema.sObjectType.RM_Chart_Setting__c.isUpdateable() ||
            !Schema.sObjectType.RM_Chart_Setting__c.fields.Is_Influence_Support_Global_Scope__c.isUpdateable() ||
            !Schema.sObjectType.RM_Chart_Setting__c.fields.Is_Reports_To_Global_Scope__c.isUpdateable()
        ) {
            return;
        }

        List<RM_Chart_Setting__c> settings = [
            SELECT Id, Is_Influence_Support_Global_Scope__c, Is_Reports_To_Global_Scope__c
            FROM RM_Chart_Setting__c
            WHERE OwnerId != NULL
        ];
        for (RM_Chart_Setting__c setting : settings) {
            setting.Is_Influence_Support_Global_Scope__c = false;
            setting.Is_Reports_To_Global_Scope__c = true;
        }

        if (settings.size() > 0) {
            this.objectsToUpdate.addAll(settings);
            this.schemasToUpdate.add(RM_Chart_Setting__c.getSObjectType());
        }
    }

    private void updateRMOrgSettings() {
        if (
            !Schema.sObjectType.RM_Org_Setting__c.isQueryable() ||
            !Schema.sObjectType.RM_Org_Setting__c.isUpdateable() ||
            !Schema.sObjectType.RM_Org_Setting__c.fields.Lead_Tab__c.isUpdateable() ||
            !Schema.sObjectType.RM_Org_Setting__c.fields.User_Tab__c.isUpdateable() ||
            !Schema.sObjectType.RM_Org_Setting__c.fields.Create_New_Contact__c.isUpdateable()
        ) {
            return;
        }

        List<RM_Org_Setting__c> settings = [
            SELECT Id, Type__c, Lead_Tab__c, User_Tab__c, Create_New_Contact__c
            FROM RM_Org_Setting__c
            WHERE OwnerId != NULL
        ];
        for (RM_Org_Setting__c setting : settings) {
            setting.Lead_Tab__c = true;
            setting.User_Tab__c = true;
            setting.Create_New_Contact__c = true;
        }
        update settings;
    }

    private void updateRMOrgSettings2() {
        if (
            !Schema.sObjectType.RM_Org_Setting__c.isQueryable() ||
            !Schema.sObjectType.RM_Org_Setting__c.isUpdateable() ||
            !Schema.sObjectType.RM_Org_Setting__c.fields.Show_Auto_Manual_Toggle__c.isUpdateable()
        ) {
            return;
        }

        List<RM_Org_Setting__c> settings = [
            SELECT Id, Show_Auto_Manual_Toggle__c
            FROM RM_Org_Setting__c
            WHERE OwnerId != NULL
        ];
        for (RM_Org_Setting__c setting : settings) {
            setting.Show_Auto_Manual_Toggle__c = true;
        }
        update settings;
    }

    private void updateRMOrgSettingsForButtonVisibility() {
        if (
            !Schema.sObjectType.RM_Org_Setting__c.isQueryable() ||
            !Schema.sObjectType.RM_Org_Setting__c.isUpdateable() ||
            !Schema.sObjectType.RM_Org_Setting__c.fields.Show_Clone_Relationship_Map__c.isUpdateable() ||
            !Schema.sObjectType.RM_Org_Setting__c.fields.Show_Chart_Settings__c.isUpdateable() ||
            !Schema.sObjectType.RM_Org_Setting__c.fields.Enable_Contact_Context_Menu__c.isUpdateable() ||
            !Schema.sObjectType.RM_Org_Setting__c.fields.Enable_Map_Member_Context_Menu__c.isUpdateable() ||
            !Schema.sObjectType.RM_Org_Setting__c.fields.Enable_Omni_Viewer_Context_Menu__c.isUpdateable()
        ) {
            return;
        }

        List<RM_Org_Setting__c> settings = [
            SELECT
                Id,
                Show_Clone_Relationship_Map__c,
                Show_Chart_Settings__c,
                Enable_Contact_Context_Menu__c,
                Enable_Map_Member_Context_Menu__c,
                Enable_Omni_Viewer_Context_Menu__c
            FROM RM_Org_Setting__c
            WHERE OwnerId != NULL
        ];
        for (RM_Org_Setting__c setting : settings) {
            setting.Show_Clone_Relationship_Map__c = true;
            setting.Show_Chart_Settings__c = true;
            setting.Enable_Contact_Context_Menu__c = true;
            setting.Enable_Map_Member_Context_Menu__c = true;
            setting.Enable_Omni_Viewer_Context_Menu__c = false;
        }
        update settings;
    }

    private void updateRmOrgSettingsForGroupMenuEditable() {
        if (
            !Schema.sObjectType.RM_Org_Setting__c.isQueryable() ||
            !Schema.sObjectType.RM_Org_Setting__c.isUpdateable() ||
            !Schema.sObjectType.RM_Org_Setting__c.fields.Enable_Group_Selection_Context_Menu__c.isUpdateable()
        ) {
            return;
        }

        List<RM_Org_Setting__c> settings = [
            SELECT Id, Enable_Group_Selection_Context_Menu__c
            FROM RM_Org_Setting__c
            WHERE OwnerId != NULL
        ];
        for (RM_Org_Setting__c setting : settings) {
            setting.Enable_Group_Selection_Context_Menu__c = true;
        }
        update settings;
    }

    private void updateStakeholderAutoCreateSetting() {
        if (
            !Schema.sObjectType.Crush_Settings_Obj__c.isQueryable() ||
            !Schema.sObjectType.Crush_Settings_Obj__c.isUpdateable() ||
            !Schema.sObjectType.Crush_Settings_Obj__c.fields.Auto_Create_Stakeholder_Maps__c.isUpdateable()
        ) {
            return;
        }
        CRUSH_Settings_Obj__c orgSettings = getOrgSettingsAndCreateIfNeeded();

        orgSettings.Auto_Create_Stakeholder_Maps__c = true;

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ CRUSH_Settings_Obj__c.SObjectType }
        );
        uow.registerDirty(orgSettings);
        uow.commitWork();
    }

    private void updateWSUserSettings() {
        if (
            !Schema.sObjectType.WS_User_Setting__c.isQueryable() ||
            !Schema.sObjectType.WS_User_Setting__c.isUpdateable() ||
            !Schema.sObjectType.WS_User_Setting__c.fields.Row_Filters__c.isUpdateable() ||
            !Schema.sObjectType.WS_User_Setting__c.fields.Column_Filters__c.isUpdateable() ||
            !Schema.sObjectType.WS_User_Setting__c.fields.Amount_Type_Filters__c.isUpdateable()
        ) {
            return;
        }

        List<WS_User_Setting__c> settings = [
            SELECT Id, Row_Filters__c, Column_Filters__c, Amount_Type_Filters__c
            FROM WS_User_Setting__c
            WHERE White_Space__c != NULL
        ];
        for (WS_User_Setting__c setting : settings) {
            setting.Row_Filters__c = getHiddenIdsString(setting.Row_Filters__c);
            setting.Column_Filters__c = getHiddenIdsString(setting.Column_Filters__c);
            setting.Amount_Type_Filters__c = getHiddenIdsString(setting.Amount_Type_Filters__c);
            setting.Show_Unhighlighted__c = true;
        }
        update settings;
    }

    private void updateUserSettingsForFilterDataDefaults() {
        if (
            !Schema.sObjectType.WS_User_Setting__c.isQueryable() ||
            !Schema.sObjectType.WS_User_Setting__c.isUpdateable() ||
            !Schema.sObjectType.WS_User_Setting__c.fields.Show_Empty_Columns__c.isUpdateable() ||
            !Schema.sObjectType.WS_User_Setting__c.fields.Show_Empty_Rows__c.isUpdateable() ||
            !Schema.sObjectType.WS_User_Setting__c.fields.Show_Populated_Columns__c.isUpdateable() ||
            !Schema.sObjectType.WS_User_Setting__c.fields.Show_Populated_Rows__c.isUpdateable()
        ) {
            return;
        }

        List<WS_User_Setting__c> settings = [
            SELECT Id, Show_Empty_Columns__c, Show_Empty_Rows__c, Show_Populated_Columns__c, Show_Populated_Rows__c
            FROM WS_User_Setting__c
            WHERE White_Space__c != NULL
        ];
        for (WS_User_Setting__c setting : settings) {
            setting.Show_Empty_Columns__c = true;
            setting.Show_Empty_Rows__c = true;
            setting.Show_Populated_Columns__c = true;
            setting.Show_Populated_Rows__c = true;
        }
        update settings;
    }

    private void updateSupportColorValues() {
        if (
            !Schema.sObjectType.Crush_Settings_Obj__c.isQueryable() ||
            !Schema.sObjectType.Crush_Settings_Obj__c.isUpdateable() ||
            !Schema.sObjectType.Crush_Settings_Obj__c.fields.Support_Colors_Long__c.isUpdateable() ||
            !Schema.sObjectType.Crush_Settings_Obj__c.fields.Support_Colors__c.isUpdateable()
        ) {
            return;
        }
        Crush_Settings_Obj__c orgSettings = getOrgSettingsAndCreateIfNeeded();
        orgSettings.pqcrush__Support_Colors_Long__c = orgSettings.pqcrush__Support_Colors__c;

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ Crush_Settings_Obj__c.SObjectType }
        );

        uow.registerDirty(orgSettings);
        uow.commitWork();
    }

    private void updateContactRelationshipTypes() {
        if (
            !Schema.sObjectType.Contact_Relationship_Type__c.isQueryable() ||
            !Schema.sObjectType.Contact_Relationship_Type__c.isUpdateable() ||
            !Schema.sObjectType.Contact_Relationship_Type__c.fields.pqcrush__Used_in_all_account_plans__c.IsAccessible() ||
            !Schema.sObjectType.Contact_Relationship_Type__c.fields.pqcrush__Used_in_all_relationship_maps__c.IsAccessible() ||
            !Schema.sObjectType.Contact_Relationship_Type__c.fields.pqcrush__Used_in_all_account_plans__c.isUpdateable() ||
            !Schema.sObjectType.Contact_Relationship_Type__c.fields.pqcrush__Used_in_all_relationship_maps__c.isUpdateable()
        ) {
            return;
        }

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ Contact_Relationship_Type__c.SObjectType }
        );

        for (Contact_Relationship_Type__c rel : [
            SELECT pqcrush__Used_in_all_account_plans__c, pqcrush__Used_in_all_relationship_maps__c
            FROM Contact_Relationship_Type__c
            WHERE IsActive__c = TRUE
        ]) {
            rel.pqcrush__Used_in_all_account_plans__c = true;
            rel.pqcrush__Used_in_all_relationship_maps__c = true;
            uow.registerDirty(rel);
        }

        uow.commitWork();
    }

    private String getHiddenIdsString(String originalJsonString) {
        String convertedFilterString = '';
        if (originalJsonString != null) {
            List<String> stringList = new List<String>();
            Map<String, Object> originalFilterObject = (Map<String, Object>) JSON.deserializeUntyped(
                originalJsonString
            );
            List<Object> all = (List<Object>) originalFilterObject.get('all');
            List<Object> selected = (List<Object>) originalFilterObject.get('selected');
            for (Object item : all) {
                Map<String, Object> itemObj = (Map<String, Object>) item;
                String objId = (String) itemObj.get('value');
                if (selected.contains(itemObj.get('value')) == false) {
                    stringList.add(objId);
                }
            }
            convertedFilterString = String.join(stringList, ',');
        }
        return convertedFilterString;
    }

    private void createNewOrgSettingsIfNeeded() {
        getOrgSettingsAndCreateIfNeeded();
    }

    /**
     * Retrieves the org level settings object for the Strategy app and creates it if it does not exist
     * @return The org level Crush settings object.
     */

    private CRUSH_Settings_Obj__c getOrgSettings() {
        if (
            !Schema.sObjectType.Crush_Settings_Obj__c.isAccessible() ||
            !Schema.sObjectType.Crush_Settings_Obj__c.fields.Support_Colors_Long__c.isAccessible() ||
            !Schema.sObjectType.Crush_Settings_Obj__c.fields.Support_Colors__c.isAccessible() ||
            !Schema.sObjectType.Crush_Settings_Obj__c.fields.Org_Chart_Default_Fields__c.isAccessible() ||
            !Schema.sObjectType.Crush_Settings_Obj__c.fields.Relationship_Map_Default_Fields__c.isAccessible()
        ) {
            return null;
        }
        Crush_Settings_Obj__c orgSettings = buildResult(
            [
                SELECT
                    Id,
                    Support_Colors_Long__c,
                    Support_Colors__c,
                    Org_Chart_Default_Fields__c,
                    Relationship_Map_Default_Fields__c
                FROM Crush_Settings_Obj__c
                WHERE Type__c = 'Org'
            ]
        );
        return orgSettings;
    }

    private CRUSH_Settings_Obj__c getOrgSettingsAndCreateIfNeeded() {
        Crush_Settings_Obj__c orgSettings = getOrgSettings();

        if (orgSettings == null) {
            if (
                !Schema.sObjectType.Crush_Settings_Obj__c.isCreateable() ||
                !Schema.sObjectType.Crush_Settings_Obj__c.isUpdateable() ||
                !Schema.sObjectType.Crush_Settings_Obj__c.fields.Type__c.isCreateable() ||
                !Schema.sObjectType.Crush_Settings_Obj__c.fields.Type__c.isUpdateable()
            ) {
                throw new PostInstallException('Could not create custom settings due to lack of permissions');
            }
            // Instantiates a new crush settings object with default values and type set to org
            SObjectType crushSettingsObjType = Crush_Settings_Obj__c.sObjectType;
            orgSettings = (Crush_Settings_Obj__c) crushSettingsObjType.newSObject(null, true);
            orgSettings.Type__c = 'Org';

            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new List<Schema.SObjectType>{ Crush_Settings_Obj__c.SObjectType }
            );
            uow.registerNew(orgSettings);
            uow.commitWork();
        }

        return orgSettings;
    }

    private void updateWSPicklistHeaders() {
        if (
            !Schema.sObjectType.White_Space__c.isQueryable() ||
            !Schema.sObjectType.White_Space_Template__c.isQueryable() ||
            !Schema.sObjectType.Mapping__c.isQueryable() ||
            !Schema.sObjectType.White_Space_Row__c.isQueryable() ||
            !Schema.sObjectType.White_Space_Column__c.isQueryable() ||
            !Schema.sObjectType.White_Space_Row__c.isUpdateable() ||
            !Schema.sObjectType.White_Space_Column__c.isUpdateable() ||
            !Schema.sObjectType.White_Space_Row__c.fields.Related_Object_Id__c.isUpdateable() ||
            !Schema.sObjectType.White_Space_Column__c.fields.Related_Object_Id__c.isUpdateable()
        ) {
            return;
        }

        List<SObject> objectsToUpdate = new List<SObject>();

        for (White_Space__c ws : [
            SELECT
                Id,
                White_Space_Template__c,
                White_Space_Template__r.isLegacy__c,
                White_Space_Template__r.ColumnMapping__r.ValueField__c,
                White_Space_Template__r.ColumnMapping__r.ObjectType__c,
                White_Space_Template__r.ColumnMapping__r.DisplayLabelField__c,
                White_Space_Template__r.RowMapping__r.ValueField__c,
                White_Space_Template__r.RowMapping__r.ObjectType__c,
                White_Space_Template__r.RowMapping__r.DisplayLabelField__c,
                (SELECT Id, Related_Object_Id__c, Name FROM White_Space_Rows__r),
                (SELECT Id, Related_Object_Id__c, Name FROM White_Space_Columns__r)
            FROM White_Space__c
            WHERE White_Space_Template__c != NULL AND White_Space_Template__r.isLegacy__c = FALSE
        ]) {
            Boolean isColumnPicklist = WhiteSpaceUtils.isPicklistMappingType(
                ws.White_Space_Template__r.ColumnMapping__r
            );
            Boolean isRowPicklist = WhiteSpaceUtils.isPicklistMappingType(ws.White_Space_Template__r.RowMapping__r);

            if (isColumnPicklist) {
                List<SObject> headersToUpdate = getUpdatedPicklistHeaders(
                    ws.White_Space_Template__r.ColumnMapping__r,
                    ws.pqcrush__White_Space_Columns__r
                );
                objectsToUpdate.addAll(headersToUpdate);
            }

            if (isRowPicklist) {
                List<SObject> headersToUpdate = getUpdatedPicklistHeaders(
                    ws.White_Space_Template__r.RowMapping__r,
                    ws.White_Space_Rows__r
                );
                objectsToUpdate.addAll(headersToUpdate);
            }
        }

        update objectsToUpdate;
    }

    private void insertDefaultSvg() {
        if (
            !Schema.sObjectType.RM_Svg__c.isCreateable() ||
            !Schema.sObjectType.RM_Svg__c.fields.Label__c.isUpdateable() ||
            !Schema.sObjectType.RM_Svg__c.fields.Fill__c.isUpdateable() ||
            !Schema.sObjectType.RM_Svg__c.fields.Geometry_String__c.isUpdateable() ||
            !Schema.sObjectType.RM_Svg__c.fields.View_Box__c.isUpdateable()
        ) {
            return;
        }

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ RM_Svg__c.SObjectType }
        );

        uow.registerNew(
            new RM_Svg__c(
                Name = 'Star',
                Label__c = 'Star',
                Fill__c = '#da252b',
                Geometry_String__c = 'M27.4,3.1l4.6,15c0.2,0.6,0.8,0.9,1.4,0.9h15c1.5,0,2.1,2,0.9,2.9l-12.2,9c-0.5,0.4-0.7,1.1-0.5,1.7L42.4,48c0.4,1.4-1.1,2.6-2.3,1.7L27,39.9c-0.5-0.4-1.2-0.4-1.8,0L12,49.7c-1.2,0.9-2.8-0.3-2.3-1.7l5.6-15.4c0.2-0.6,0-1.3-0.5-1.7l-12.2-9C1.4,21,2.1,19,3.5,19h15c0.7,0,1.2-0.2,1.4-0.9L24.6,3C25,1.6,27,1.7,27.4,3.1z',
                View_Box__c = '0 0 52 52'
            )
        );

        uow.registerNew(
            new RM_Svg__c(
                Name = 'Lightning',
                Label__c = 'Lightning',
                Fill__c = '#23dcd9',
                Geometry_String__c = 'M23.8,31.2L20,48.8c-0.2,1,1.1,1.7,1.7,0.9l21-26C43.3,23,42.8,22,42,22H30.8c-0.8,0-1.3-0.9-0.9-1.5l9.9-16.2c0.6-1-0.1-2.3-1.3-2.3H20.8c-1.1,0-2,0.7-2.4,1.7L10.1,28c-0.3,1,0.4,2,1.4,2h11.4C23.5,30,24,30.6,23.8,31.2z',
                View_Box__c = '0 0 52 52'
            )
        );

        uow.registerNew(
            new RM_Svg__c(
                Name = 'Diamond',
                Label__c = 'Diamond',
                Fill__c = '#c13ebb',
                Geometry_String__c = 'M24.4,49.2c0.9,0.9,2.2,0.9,3.1,0l21.9-21.9c0.9-0.9,0.9-2.2,0-3.1L27.6,2.4c-0.9-0.9-2.2-0.9-3.1,0L2.6,24.3c-0.9,0.9-0.9,2.2,0,3.1L24.4,49.2z',
                View_Box__c = '0 0 52 52'
            )
        );

        uow.commitWork();
    }

    private void insertDefaultSvg2() {
        if (
            !Schema.sObjectType.RM_Svg__c.isCreateable() ||
            !Schema.sObjectType.RM_Svg__c.fields.Label__c.isUpdateable() ||
            !Schema.sObjectType.RM_Svg__c.fields.Fill__c.isUpdateable() ||
            !Schema.sObjectType.RM_Svg__c.fields.Geometry_String__c.isUpdateable() ||
            !Schema.sObjectType.RM_Svg__c.fields.View_Box__c.isUpdateable()
        ) {
            return;
        }

        List<List<String>> svgs = new List<List<String>>();
        svgs.add(
            new List<String>{
                'Activity',
                'M37.6183889,11.6708207 C36.0775031,12.1695982 34.8346394,12.6500392 33.8951123,13.1080724 C33.147846,13.4723757 32.2082574,14.0094737 31.0807691,14.7177235 C31.1667725,16.5995452 31.1647549,18.1812026 31.0720049,19.471958 C30.978316,20.7757793 30.729548,22.6451414 30.3255443,25.1018792 L30.3249866,25.105271 C33.1402365,27.1333998 35.173105,28.6648537 36.4346442,29.7093742 C36.597726,29.8444015 37.0675113,30.2927661 37.290798,30.4915397 L41.6350875,28.6718336 L41.6630879,28.5983756 C42.2901352,27.2514509 42.8079954,25.4121018 43.2023354,23.090599 C43.5248028,21.1922141 43.5792329,19.1005349 43.3616438,16.8149992 L37.6183889,11.6708207 Z M36.1073454,9.01038791 L36.0232586,8.70752566 C33.0749193,6.986037 29.6504509,6 26,6 C24.0374305,6 22.1401787,6.28500358 20.3471163,6.81607115 L20.3150626,7.58570491 C20.3125153,8.13379545 20.3206789,8.75803253 20.3397186,9.45727659 C22.030077,9.69444512 23.4511913,10.0055978 24.6125132,10.3984154 C25.7797872,10.7932463 27.2652399,11.4679116 29.0912853,12.4265863 C30.4808345,11.5400042 31.6418165,10.8690679 32.5804736,10.4114588 C33.5274303,9.94980351 34.7018153,9.48372899 36.1073454,9.01038791 Z M22.1658519,42.9499501 C25.7837244,42.5723864 28.2398333,42.214337 29.482962,41.8897282 C30.9042374,41.5186013 32.1824292,41.1660586 33.3120912,40.8358599 C34.1722511,38.7935246 34.7220293,37.2603474 34.9614258,36.2363281 C35.1529949,35.4168907 35.358074,34.3134037 35.5766632,32.925867 C35.1941933,32.5878338 34.8423881,32.2858788 34.5214105,32.020118 C33.2642127,30.9791921 31.1392189,29.383038 28.1591705,27.2428861 C26.7773199,28.0516935 25.578361,28.6100352 24.5396119,28.9176686 C23.4183372,29.2497427 21.6839458,29.5217756 19.2831016,29.7528889 C18.4025226,31.6297547 17.8362807,33.1071422 17.5864096,34.166593 C17.3320659,35.2450077 17.0943845,36.7418674 16.8760063,38.6493017 C17.7547343,39.6657727 18.4980512,40.4228089 19.105957,40.9204102 C19.7335586,41.4341334 20.7535236,42.1106467 22.1658519,42.9499501 Z M9.43256002,37.3549805 C10.4237284,37.3549805 11.2036954,37.3549805 11.7724609,37.3549805 C12.303599,37.3549805 13.0495362,37.3549805 14.0102726,37.3549805 C14.2107696,35.7758361 14.428989,34.4850677 14.6665201,33.4779382 C14.9400638,32.3181157 15.4843529,30.8481997 16.300959,29.0539271 C15.2463486,27.8356974 13.9237556,26.2978223 13.3137207,25.3530273 C12.7899372,24.5418147 12.0001541,23.6495599 11.0966104,21.4542 C10.651234,21.5056018 10.2276481,21.6019315 9.82522217,21.7422911 C8.69828165,22.1353494 7.4686019,22.7868341 6.14148886,23.6996077 C6.04806598,24.4867321 6,25.2877674 6,26.1 C6,30.2689719 7.2662951,34.1429544 9.43256039,37.3549805 Z M45.3282868,31.2792284 C45.7664219,29.6266133 46,27.8905132 46,26.1 C46,25.6350746 45.9842513,25.1738179 45.9532621,24.716739 C45.6200985,26.3917813 45.2132523,27.8388302 44.727981,29.0612839 C44.8786702,29.3140128 45.0019766,29.5965634 45.0979004,29.9089355 C45.1992771,30.239065 45.2760726,30.6958293 45.3282868,31.2792284 Z M10.5692649,18.498153 L10.6995867,18.2850775 C12.1124354,15.9750781 13.2011371,14.3611242 14.0036047,13.4026373 C14.742741,12.519795 15.8565271,11.4530321 17.3603877,10.1773893 C17.332844,9.37002213 17.3176723,8.64228219 17.3150536,7.99292123 C12.5039581,10.3308697 8.76180348,14.5492227 7.0385821,19.6963229 C7.66999104,19.3766191 8.28734315,19.1113543 8.8910957,18.9007754 C9.43289222,18.7118056 9.99245388,18.577843 10.5692649,18.498153 Z M37.1536125,42.780843 C35.4462122,43.3682132 33.1445218,44.0342038 30.2409149,44.7924007 C28.8331282,45.1600054 26.3158719,45.5303223 22.6397944,45.9167706 C23.732491,46.1030135 24.8551317,46.2 26,46.2 C30.1272493,46.2 33.9656284,44.9395616 37.1536125,42.780843 Z M50,26.1 C50,39.4 39.2448133,50.2 26,50.2 C12.7551867,50.2 2,39.4 2,26.1 C2,12.8 12.7551867,2 26,2 C39.2448133,2 50,12.8 50,26.1 Z'
            }
        );
        svgs.add(
            new List<String>{
                'Add',
                'M30,29h16.5c0.8,0,1.5-0.7,1.5-1.5v-3c0-0.8-0.7-1.5-1.5-1.5H30c-0.6,0-1-0.4-1-1V5.5C29,4.7,28.3,4,27.5,4h-3C23.7,4,23,4.7,23,5.5V22c0,0.6-0.4,1-1,1H5.5C4.7,23,4,23.7,4,24.5v3C4,28.3,4.7,29,5.5,29H22c0.6,0,1,0.4,1,1v16.5c0,0.8,0.7,1.5,1.5,1.5h3c0.8,0,1.5-0.7,1.5-1.5V30C29,29.4,29.4,29,30,29z'
            }
        );
        svgs.add(
            new List<String>{
                'Add Set',
                'M22.5,5.1h-17C4.7,5.1,4,5.8,4,6.6v15.9C4,23.3,4.7,24,5.5,24h17c0.8,0,1.5-0.7,1.5-1.5V6.6C24,5.8,23.3,5.1,22.5,5.1z M19.9,13.3H8.1V9.2h11.8V13.3z x M46.5,5.1h-17c-0.8,0-1.5,0.7-1.5,1.5v15.9c0,0.8,0.7,1.5,1.5,1.5h17c0.8,0,1.5-0.7,1.5-1.5V6.6C48,5.8,47.3,5.1,46.5,5.1z M43.9,13.3H32.1V9.2h11.8V13.3z x M22.5,28h-17C4.7,28,4,28.7,4,29.5v15.9c0,0.8,0.7,1.5,1.5,1.5h17c0.8,0,1.5-0.7,1.5-1.5V29.5C24,28.7,23.3,28,22.5,28z M19.9,36.2H8.1v-4.1h11.8V36.2z x M46.5,28h-17c-0.8,0-1.5,0.7-1.5,1.5v15.9c0,0.8,0.7,1.5,1.5,1.5h17c0.8,0,1.5-0.7,1.5-1.5V29.5C48,28.7,47.3,28,46.5,28z M43.9,36.2H32.1v-4.1h11.8V36.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Add User',
                'M21.9,37c0-2.7,0.9-5.8,2.3-8.2c1.7-3,3.6-4.2,5.1-6.4c2.5-3.7,3-9,1.4-13c-1.6-4.1-5.4-6.5-9.8-6.4s-8,2.8-9.4,6.9c-1.6,4.5-0.9,9.9,2.7,13.3c1.5,1.4,2.9,3.6,2.1,5.7c-0.7,2-3.1,2.9-4.8,3.7c-3.9,1.7-8.6,4.1-9.4,8.7C1.3,45.1,3.9,49,8,49h17c0.8,0,1.3-1,0.8-1.6C23.3,44.5,21.9,40.8,21.9,37z x M37.9,25c-6.6,0-12,5.4-12,12s5.4,12,12,12s12-5.4,12-12S44.5,25,37.9,25z M44,38c0,0.6-0.5,1-1.1,1H40v3c0,0.6-0.5,1-1.1,1h-2c-0.6,0-0.9-0.4-0.9-1v-3h-3.1c-0.6,0-0.9-0.4-0.9-1v-2c0-0.6,0.3-1,0.9-1H36v-3c0-0.6,0.3-1,0.9-1h2c0.6,0,1.1,0.4,1.1,1v3h2.9c0.6,0,1.1,0.4,1.1,1V38z'
            }
        );
        svgs.add(
            new List<String>{
                'Adjust Value',
                'm23 14.91a6.55 6.55 0 1 1 -6.52 6.55 6.53 6.53 0 0 1 6.52-6.55zm20.7 15.72a.58.58 0 0 0 0-.84l-4.12-4.12a.59.59 0 0 0 -.42-.18.61.61 0 0 0 -.43.18l-11.34 11.38-1.7 5.69a.8.8 0 0 0 .79 1 .55.55 0 0 0 .18 0l5.69-1.74zm-1.45-7.75 4.15 4.12a.63.63 0 0 0 .43.18.59.59 0 0 0 .42-.18c.73-.73 2.06-1.94 2.06-1.94a2 2 0 0 0 0-2.91l-2.18-2.15a2 2 0 0 0 -1.41-.54 2.34 2.34 0 0 0 -1.5.54s-1.33 1.31-1.93 2a.58.58 0 0 0 0 .88zm-2.15-14.61h-34.1a4 4 0 0 0 -3.93 4v19.07a4 4 0 0 0 3.93 3.94h18.84l3.95-3.94h-18.25a4.53 4.53 0 0 0 -4.54-4.58v-9.88a4.53 4.53 0 0 0 4.56-4.57h25a4.53 4.53 0 0 0 4.56 4.57v3l3.88-3.97v-3.6a4 4 0 0 0 -3.9-4.04z'
            }
        );
        svgs.add(
            new List<String>{
                'Advanced Function',
                'M43,6.9V4c0-0.8-0.7-1.5-1.5-1.5H11.8c-0.8,0-1.5,0.7-1.5,1.5v2.9c0,0.1,0,0.1,0,0.2c0,0.3,0,0.7,0.3,1L25.2,26l0,0L10.6,43.9c-0.2,0.3-0.3,0.6-0.3,1c0,0.1,0,0.1,0,0.2V48c0,0.8,0.7,1.5,1.5,1.5h29.7c0.8,0,1.5-0.7,1.5-1.5v-2.9c0-0.8-0.7-1.5-1.5-1.5H18.4l13.3-16.3l0,0c0.3-0.4,0.4-0.8,0.4-1.4c0-0.5-0.2-1-0.5-1.4l0,0L18.4,8.4h23.1C42.3,8.4,43,7.7,43,6.9z'
            }
        );
        svgs.add(
            new List<String>{
                'Advertising',
                'M23,27.2c0.1,0,0.3,0,0.4,0c0.2-2.7,1.2-5.1,2.7-7c-0.8-0.8-1.8-1.3-3.1-1.3c-2.4,0-4.2,1.8-4.2,4.2C18.8,25.4,20.6,27.2,23,27.2z x M24.2,35.2c0.5,0,1-0.1,1.2-0.1c-0.8-1.3-1.4-2.7-1.7-4c-0.2,0-0.5,0-0.7,0c-4.5,0-8.4-3.6-8.4-8.4c0-4.5,3.6-8.4,8.4-8.4c2.5,0,4.9,1.1,6.4,2.9c1.2-0.7,2.5-1.1,3.9-1.3c-2.3-3.3-6.1-5.4-10.4-5.4c-7.2,0-12.6,5.7-12.6,12.6s5.7,12.6,12.9,12.3C23.6,35.3,23.9,35.3,24.2,35.2z x M49.9,45.5v1.4c0,1.6-1.4,3-3,3H22.8c-1.6,0-3-1.4-3-3v-1.4c0-3.6,4.3-5.9,8.3-7.7l0.4-0.2c0.3-0.1,0.6-0.1,0.9,0.1c1.6,1.1,3.5,1.6,5.4,1.6c1.9,0,3.8-0.6,5.4-1.6c0.3-0.2,0.6-0.2,0.9-0.1l0.4,0.2C45.7,39.6,49.9,41.8,49.9,45.5z M34.8,19.8c4.2,0,7.5,3.7,7.5,8.3s-3.3,8.3-7.5,8.3s-7.5-3.7-7.5-8.3S30.7,19.8,34.8,19.8z x M18.5,39.2c-6.9-2-12.2-8.5-12.2-16.1c0-9.3,7.5-16.8,16.8-16.8c6.9,0,13.1,4.1,15.6,10.2c2,0.8,3.8,2.1,5.1,3.8C42.3,9.8,33.6,2.1,23,2.1C11.3,2.1,2.1,11.3,2.1,23c0,9.2,5.8,17,14.2,19.7C16.7,41.3,17.5,40.2,18.5,39.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Agent Home',
                'M26.71,2.32l23,23A1.15,1.15,0,0,1,50,26.43c-.08.4-.64.64-1,.64H44V49a.92.92,0,0,1-1,1H9a1,1,0,0,1-1-.88V27H3a.77.77,0,0,1-.87-.64.87.87,0,0,1,.23-1.11l23-23A1,1,0,0,1,26.71,2.32ZM18.29,38H14.05a.88.88,0,0,0-.88.88h0v5.43a.88.88,0,0,0,.88.88h4.24a.89.89,0,0,0,.88-.88h0V38.88A.89.89,0,0,0,18.29,38Zm9.59-7.2H23.64a.9.9,0,0,0-.88.88h0V44.31a.89.89,0,0,0,.88.88h4.24a.89.89,0,0,0,.88-.88h0V31.68A.9.9,0,0,0,27.88,30.8Zm9.59-7.19H33.24a.87.87,0,0,0-.88.88h0V44.31a.87.87,0,0,0,.88.88h4.23a.87.87,0,0,0,.88-.88h0V24.49A.87.87,0,0,0,37.47,23.61Z'
            }
        );
        svgs.add(
            new List<String>{
                'Agent Session',
                'M26,4C12.7,4,2.1,13.8,2.1,25.9c0,3.8,1.1,7.4,2.9,10.6c0.3,0.5,0.4,1.1,0.2,1.7l-3.1,8.5c-0.3,0.8,0.5,1.5,1.3,1.3l8.6-3.3c0.5-0.2,1.1-0.1,1.7,0.2c3.6,2,7.9,3.2,12.5,3.2C39.3,48,50,38.3,50,26.1C49.9,13.8,39.2,4,26,4zM19.5,36c0,0.5-0.4,0.9-0.9,0.9h-4.2c-0.5,0-0.9-0.4-0.9-0.9v-5.4c0-0.5,0.4-0.9,0.9-0.9h4.2c0.5,0,0.9,0.4,0.9,0.9V36z M29.1,36c0,0.5-0.4,0.9-0.9,0.9H24c-0.5,0-0.9-0.4-0.9-0.9V23.3c0-0.5,0.4-0.9,0.9-0.9h4.2c0.5,0,0.9,0.4,0.9,0.9V36z M38.7,36c0,0.5-0.4,0.9-0.9,0.9h-4.2c-0.5,0-0.9-0.4-0.9-0.9V16.1c0-0.5,0.4-0.9,0.9-0.9h4.2c0.5,0,0.9,0.4,0.9,0.9V36z'
            }
        );
        svgs.add(
            new List<String>{
                'Aggregation Policy',
                'M49.29,43.08l0,0-7.4-7.35a2,2,0,0,0-.23-.18V32.37h3.48a1,1,0,0,0,.65-.23,1,1,0,0,0,.14-1.4l-5.9-7-.12-.14,0,0a1,1,0,0,0-1.4.17l-5.89,7a1,1,0,0,0-.23.63,1,1,0,0,0,1,1h3.47v2.88a2.3,2.3,0,0,0-.68.45L28.7,43.05h0a2.4,2.4,0,0,0,0,3.39,2.45,2.45,0,0,0,3.39,0l4.7-4.67v5.86a2.42,2.42,0,0,0,4.84,0V42.23l4.24,4.22a2.45,2.45,0,0,0,3.39,0A2.38,2.38,0,0,0,49.29,43.08z x M14.38,2H8.14A6.07,6.07,0,0,0,2,8v4.8H2a6.07,6.07,0,0,0,6.14,6h6.24a6.07,6.07,0,0,0,6.14-6V8h0A6.07,6.07,0,0,0,14.38,2zM12,14H10.52a3.6,3.6,0,0,1,0-7.2H12A3.6,3.6,0,0,1,12,14z x M37.74,18.8h0a6.07,6.07,0,0,0,6.14-6V8h0a6.07,6.07,0,0,0-6.14-6H31.5a6.07,6.07,0,0,0-6.14,6v4.8h0a6.07,6.07,0,0,0,6.14,6zm-7.47-8.4a3.6,3.6,0,0,1,3.6-3.6h1.49a3.6,3.6,0,1,1,0,7.2H33.87A3.6,3.6,0,0,1,30.27,10.4z x M14.38,23.6H8.14A6.07,6.07,0,0,0,2,29.6v4.8H2a6.07,6.07,0,0,0,6.14,6h6.24a6.07,6.07,0,0,0,6.14-6V29.6h0A6.07,6.07,0,0,0,14.38,23.6zM12,35.6H10.52a3.6,3.6,0,1,1,0-7.2H12a3.6,3.6,0,0,1,0,7.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Alert',
                'M34.7,31l-0.4,0.1c-1.5,0.5-3.1-0.2-3.7-1.7l-3.3-8.8c-2.6-7-10.5-10.4-17.4-7.5c-6.5,2.7-9.4,10.3-7,16.9l3.1,8.5c0.5,1.5-0.3,3.1-1.7,3.6l-0.4,0.1c-1.7,0.6-2.5,2.6-1.9,4.3l0.4,1.1c0.2,0.5,0.9,0.9,1.5,0.6l34.4-12.7c0.6-0.2,0.9-1,0.7-1.6l-0.4-1.1C38.3,31.2,36.4,30.3,34.7,31z M26.3,43.6l-7.5,2.8c-0.5,0.2-0.7,0.8-0.4,1.2c1.2,2,3.7,2.8,5.9,2c2.2-0.8,3.5-3.1,3.2-5.3C27.3,43.8,26.7,43.5,26.3,43.6z x M49.2,28.6c1.7-5.7,0.8-11.8-2.3-16.8c-3.1-5.1-8.2-8.6-14-9.7C32.4,2,32,2.3,32,2.7l-0.5,2.8c-0.1,0.4,0.2,0.7,0.6,0.8c4.5,0.9,8.5,3.7,11,7.7s3.1,8.8,1.9,13.3c-0.1,0.4,0.1,0.8,0.5,0.9l2.7,0.9C48.7,29.1,49.1,29,49.2,28.6z x M38.2,17c-1.6-2.6-4.2-4.3-7.2-4.9c-0.4-0.1-0.8,0.2-0.9,0.6l-0.3,2.9c0,0.4,0.2,0.7,0.6,0.8c1.7,0.4,3.2,1.4,4.1,2.9c0.9,1.5,1.2,3.3,0.7,4.9c-0.1,0.3,0.1,0.7,0.4,0.8l2.7,1.1c0.4,0.2,0.8-0.1,1-0.5C40.2,22.7,39.8,19.6,38.2,17z'
            }
        );
        svgs.add(
            new List<String>{
                'Anchor',
                'M48,35.7l-2.4-10.2c-0.3-1.1-1.7-1.5-2.5-0.8l-7.7,7.1c-0.9,0.8-0.5,2.2,0.6,2.5l3.3,1c-0.3,0.7-0.6,1.4-1,2c-1.8,3-4.7,4.9-9.3,5.5v-25c2.6-1.1,4.4-3.7,4.4-6.7c0-4-3.3-7.3-7.3-7.3c-4.1,0-7.3,3.3-7.3,7.3c0,3,1.8,5.5,4.4,6.7v25c-4.6-0.6-7.5-2.5-9.3-5.5c-0.4-0.7-0.7-1.3-1-2l3.3-1c1.1-0.3,1.4-1.8,0.6-2.5l-7.8-7c-0.9-0.8-2.2-0.4-2.5,0.8L4,35.7c-0.3,1.1,0.8,2.1,1.9,1.8l2.6-0.8c0.4,1.1,0.8,2.1,1.4,3.1c2.9,4.9,8.2,7.8,16,7.8s13-2.9,16-7.8c0.6-1,1.1-2.1,1.4-3.1l2.6,0.8C47.2,37.8,48.2,36.8,48,35.7z M26,14.2c-1.6,0-2.9-1.3-2.9-2.9s1.3-2.9,2.9-2.9s2.9,1.3,2.9,2.9S27.6,14.2,26,14.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Animal and Nature',
                'M17.3890829,4.60305058 C20.0880643,3.58920045 22.95837,3.08227539 26,3.08227539 C29.04163,3.08227539 31.9119357,3.58920045 34.6109171,4.60305058 C35.4598238,3.05190158 37.1070695,2 39,2 C41.7614237,2 44,4.23857625 44,7 C44,7.82153519 43.8018664,8.5967938 43.4507773,9.28059773 C44.6893037,10.3202506 45.5390445,13.5600514 46,19 C46.3942871,22.0083008 48.9873047,31.0666504 49,33 C49.0522637,40.9591521 41.385597,46.6258188 26,50 C10.6666667,46.7063802 3,41.0397135 3,33 C3.04736328,30.9470215 5.49975586,22.1008301 6,19 C6.60252733,13.7112015 7.47002244,10.5050274 8.60248532,9.38147786 C8.21823697,8.67344093 8,7.86220645 8,7 C8,4.23857625 10.2385763,2 13,2 C14.8929305,2 16.5401762,3.05190158 17.3890829,4.60305058 Z M20.9679344,22.6949428 C19.2115289,23.2457145 18.0577532,24.92405 18.1725751,26.7612016 L18.563352,33.013632 C18.8087908,36.9406527 22.0653168,40 26,40 C29.9346832,40 33.1912092,36.9406527 33.436648,33.013632 L33.8190397,26.8953652 C33.93443,25.0491197 32.7688091,23.3645882 31.0003642,22.821873 C29.2149747,22.2739577 27.4300226,22 25.6455078,22 C24.0045692,22 22.4453781,22.2316476 20.9679344,22.6949428 Z M36,23 C37.6568542,23 39,21.209139 39,19 C39,16.790861 37.6568542,15 36,15 C34.3431458,15 33,16.790861 33,19 C33,21.209139 34.3431458,23 36,23 Z M16,23 C17.6568542,23 19,21.209139 19,19 C19,16.790861 17.6568542,15 16,15 C14.3431458,15 13,16.790861 13,19 C13,21.209139 14.3431458,23 16,23 Z M29.0736299,27.7089195 C27.3059198,29.7387833 24.4498682,29.7306529 22.7268765,27.6908335 C21.0039682,25.6510141 22.4503068,23.9901712 25.9410086,24.0000438 C29.4317105,24.0099164 30.8413399,25.6788897 29.0736299,27.7089195 Z'
            }
        );
        svgs.add(
            new List<String>{
                'Announcement',
                'M22.7,45.4l-1.3-1c-1.4-1-1.4-3-1.4-4v-2.9c0-0.8-0.7-1.5-1.5-1.5h-6c-0.8,0-1.5,0.7-1.5,1.5v7.7c0,2.7,1.6,4.8,4.1,4.8H20c2.9,0,3.1-2,3.1-2l0,0C23.1,48,23.6,46.2,22.7,45.4z x M45,18V4.4c0,0,0,0,0-0.1c0-2.4-3-3.1-4.6-1.5l-8.9,8.4c-1.4,1.2-3.2,1.7-5,1.7H11.3C6.1,13,2,17.5,2,22.7v0.2c0,5.2,4.1,9.1,9.3,9.1h15.2c1.9,0,3.7,0.8,5.1,2l8.8,8.6c1.6,1.6,4.6,1,4.6-1.4c0,0,0,0,0-0.1V27.6c3,0,4.8-2.1,4.8-4.8C49.8,20.1,48,18,45,18z'
            }
        );
        svgs.add(
            new List<String>{
                'Answer',
                'M26,4C12.7,4,2,13.8,2,26c0,3.9,1.1,7.5,3,10.8c0.2,0.4,0.3,0.9,0.2,1.3L3,45c-0.4,1.3,0.8,2.4,2.1,2l7-2.4c0.5-0.2,1-0.1,1.4,0.2c3.7,2.1,8,3.3,12.6,3.3c13.3,0,24-9.8,24-22C49.9,13.8,39.2,4,26,4L26,4L26,4z M37.5,21.1l-12.2,12c-0.5,0.5-1,0.7-1.7,0.7c-0.6,0-1.2-0.2-1.7-0.7L16,27.3c-0.5-0.5-0.5-1.2,0-1.6l1.7-1.6c0.5-0.5,1.2-0.5,1.7,0l4.2,4.2l10.5-10.4c0.5-0.5,1.2-0.5,1.7,0l1.7,1.6C37.9,19.9,37.9,20.7,37.5,21.1L37.5,21.1L37.5,21.1z'
            }
        );
        svgs.add(
            new List<String>{
                'Answered Twice',
                'M17.6,11.4c-8.9,0-16,6.5-16,14.7c0,2.6,0.7,5,2,7.2c0.1,0.3,0.2,0.6,0.1,0.9l-1.5,4.6c-0.3,0.9,0.5,1.6,1.4,1.3l4.7-1.6c0.3-0.1,0.7-0.1,0.9,0.1c2.5,1.4,5.3,2.2,8.4,2.2c8.9,0,16-6.5,16-14.7C33.6,17.9,26.4,11.4,17.6,11.4z M25.3,22.8l-8.1,8c-0.3,0.3-0.7,0.5-1.1,0.5c-0.4,0-0.8-0.1-1.1-0.5L11,26.9c-0.3-0.3-0.3-0.8,0-1.1l1.1-1.1c0.3-0.3,0.8-0.3,1.1,0l2.8,2.8l7-6.9c0.3-0.3,0.8-0.3,1.1,0l1.1,1.1C25.6,22,25.6,22.5,25.3,22.8z x M34.3,11.4h-4.2c4.7,3.4,8.2,8.8,8.2,14.7c0,5.9-3.7,11.5-8.2,14.7h4.2c8.9,0,16-6.5,16-14.7C50.2,17.9,43.1,11.4,34.3,11.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Anywhere Alert',
                'M50 47.33a45.34 45.34 0 0 0 -45.33-45.33 2.67 2.67 0 1 0 0 5.33 40 40 0 0 1 40 40 2.67 2.67 0 1 0 5.33 0z x M32.67 47.33a28 28 0 0 0 -28-28 2.67 2.67 0 1 0 0 5.34 22.65 22.65 0 0 1 22.66 22.66 2.67 2.67 0 0 0 5.34 0z x M4.67 36.67a10.66 10.66 0 0 1 10.66 10.66 2.67 2.67 0 1 1 -5.33 0v-.39a5.34 5.34 0 0 0 -5.33-4.94 2.67 2.67 0 1 1 0-5.33z'
            }
        );
        svgs.add(
            new List<String>{
                'Anywhere Chat',
                'm26 2.7c-13.21 0-24 9.62-24 21.59v.42a20.64 20.64 0 0 0 7.71 15.43l.32.27v.08a11.05 11.05 0 0 1 -3.1 4.67 1.79 1.79 0 0 0 1.45 3.12l1.17-.17.53-.08c4.76-.73 8.13-1.59 10.23-2.66l.15-.08.5.11a27.38 27.38 0 0 0 5.06.48c13.21 0 24-9.62 24-21.59s-10.81-21.59-24.02-21.59z'
            }
        );
        svgs.add(
            new List<String>{
                'Apex',
                'm48.5 40h-27c-0.8 0-1.5 0.7-1.5 1.5v3c0 0.8 0.7 1.5 1.5 1.5h27c0.8 0 1.5-0.7 1.5-1.5v-3c0-0.8-0.7-1.5-1.5-1.5z m-23.1-18.2l-19.4-15.5c-0.6-0.5-1.5-0.4-2 0.3l-1.7 2.4c-0.5 0.7-0.3 1.6 0.3 2.1l13.8 11c0.5 0.4 0.5 1.2 0 1.6l-13.8 11c-0.6 0.5-0.8 1.5-0.3 2.1l1.7 2.6c0.5 0.7 1.4 0.8 2 0.3l19.4-15.5c0.8-0.6 0.8-1.8 0-2.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Apex Plugin',
                'M26.2,18.1L37.3,7c0.6-0.6,0.6-1.5,0-2.1l-2.4-2.4c-0.6-0.6-1.5-0.6-2.1,0L21.7,13.6L26.2,18.1z x M38.4,30.7l11.1-11.1c0.6-0.6,0.6-1.5,0-2.1l-2.4-2.4c-0.6-0.6-1.5-0.6-2.1,0L33.9,26.2L38.4,30.7z x M36.8,39.9c0.2-0.2,0.3-0.5,0.4-0.8c0.1-0.4,0-0.8-0.2-1.1c-0.1-0.1-0.1-0.2-0.2-0.2l0,0L14.3,15.3l0,0c-0.2-0.3-0.7-0.4-1.1-0.4c-0.4,0-0.8,0.2-1.1,0.5c-0.2,0.2-0.4,0.3-0.6,0.5c-0.1,0.1-0.2,0.3-0.3,0.4c-0.1,0.2-0.3,0.3-0.4,0.5c-0.1,0.2-0.3,0.4-0.4,0.6c-0.2,0.2-0.3,0.5-0.4,0.8c-0.2,0.3-0.3,0.6-0.4,0.9c-0.2,0.3-0.3,0.7-0.4,1.1c-0.2,0.4-0.3,0.8-0.4,1.2c-0.1,0.5-0.3,0.9-0.4,1.4c-0.1,0.5-0.2,1-0.3,1.6c-0.1,0.6-0.2,1.2-0.3,1.7c-0.1,0.6-0.2,1.3-0.2,1.9c-0.1,0.7-0.1,1.4-0.1,2.2c0,0.8,0,1.6,0,2.4c0,0.9,0,1.7,0.1,2.6c0,0.9,0.1,1.9,0.2,2.8c0,0.3,0.1,0.5,0.1,0.8l0.1,0l-5.2,5.2C2,44.4,2,45.4,2.5,46l3.7,3.7c0.6,0.6,1.5,0.6,2.1,0l5.2-5.2c1.9,0.2,3.7,0.3,5.6,0.3c1.6,0,3.1,0,4.7-0.1c1.3-0.1,2.6-0.2,3.8-0.5c1-0.2,2-0.4,3-0.7c0.8-0.2,1.6-0.5,2.3-0.9c0.6-0.3,1.2-0.6,1.7-0.9c0.7-0.4,1.4-1,2-1.6C36.7,40,36.7,40,36.8,39.9z'
            }
        );
        svgs.add(
            new List<String>{
                'Approval',
                'm45.2 29.2h-8.8c-2.6 0-4.8-2.2-4.8-4.8 0.4-7.1 3.7-7.5 4-12.1 0.3-4.8-2.7-9.1-7.4-10.1-6.2-1.3-11.8 3.4-11.8 9.4 0 5.3 3.6 5.3 4 12.8 0 2.6-2.2 4.8-4.8 4.8h-8.8c-2.6 0-4.8 2.1-4.8 4.8v3.2c0 0.9 0.7 1.6 1.6 1.6h44.8c0.9 0 1.6-0.7 1.6-1.6v-3.2c0-2.7-2.2-4.8-4.8-4.8z m0.1 14.4h-38.6c-0.9 0-1.5 0.7-1.5 1.5v0.1c0 2.6 2.2 4.8 4.8 4.8h32.1c2.6 0 4.7-2.2 4.7-4.8v-0.1c0-0.8-0.7-1.5-1.5-1.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Apps',
                'M13,4H7C5.3,4,4,5.3,4,7v6c0,1.7,1.3,3,3,3h6c1.7,0,3-1.3,3-3V7C16,5.3,14.7,4,13,4z x M13,36H7c-1.7,0-3,1.3-3,3v6c0,1.7,1.3,3,3,3h6c1.7,0,3-1.3,3-3v-6C16,37.3,14.7,36,13,36z x M13,20H7c-1.7,0-3,1.3-3,3v6c0,1.7,1.3,3,3,3h6c1.7,0,3-1.3,3-3v-6C16,21.3,14.7,20,13,20z x M29,4h-6c-1.7,0-3,1.3-3,3v6c0,1.7,1.3,3,3,3h6c1.7,0,3-1.3,3-3V7C32,5.3,30.7,4,29,4z x M29,36h-6c-1.7,0-3,1.3-3,3v6c0,1.7,1.3,3,3,3h6c1.7,0,3-1.3,3-3v-6C32,37.3,30.7,36,29,36z x M29,20h-6c-1.7,0-3,1.3-3,3v6c0,1.7,1.3,3,3,3h6c1.7,0,3-1.3,3-3v-6C32,21.3,30.7,20,29,20z x M45,4h-6c-1.7,0-3,1.3-3,3v6c0,1.7,1.3,3,3,3h6c1.7,0,3-1.3,3-3V7C48,5.3,46.7,4,45,4z x M45,36h-6c-1.7,0-3,1.3-3,3v6c0,1.7,1.3,3,3,3h6c1.7,0,3-1.3,3-3v-6C48,37.3,46.7,36,45,36z x M45,20h-6c-1.7,0-3,1.3-3,3v6c0,1.7,1.3,3,3,3h6c1.7,0,3-1.3,3-3v-6C48,21.3,46.7,20,45,20z'
            }
        );
        svgs.add(
            new List<String>{
                'Archive',
                'M45.2,2.3H6.8C4.2,2.3,2,4.5,2,7.1v4.8c0,0.9,0.7,1.6,1.6,1.6h44.8c0.9,0,1.6-0.7,1.6-1.6V7.1C50,4.5,47.8,2.3,45.2,2.3z x M46.6,17.5H5.5c-0.9,0-1.6,0.7-1.6,1.6v26.4c0,2.6,2.2,4.8,4.8,4.8h34.8c2.6,0,4.8-2.2,4.8-4.8V19.1C48.2,18.2,47.5,17.5,46.6,17.5z M32.8,25.5H19.2c-1.1,0-2-0.9-2-2s0.9-2,2-2h13.6c1.1,0,2,0.9,2,2C34.8,24.6,33.9,25.5,32.8,25.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Arrow Bottom',
                'M42.34,41.83a2,2,0,0,1,2,2V48a2,2,0,0,1-2,2H9.66a2,2,0,0,1-2-2V43.87a2,2,0,0,1,2-2ZM28,2a2.12,2.12,0,0,1,2.05,2h0V21.4a1.3,1.3,0,0,0,2.24.92h0l4.8-4.69a2,2,0,0,1,2.86,0h0l2.86,2.75a1.86,1.86,0,0,1,0,2.76h0l-15.42,15a2,2,0,0,1-2.86,0h0l-15.32-15a1.86,1.86,0,0,1,0-2.76h0L12,17.63a2,2,0,0,1,2.86,0h0l4.8,4.69a1.3,1.3,0,0,0,2.24-.92h0V4A2.19,2.19,0,0,1,24,2H28Z'
            }
        );
        svgs.add(
            new List<String>{
                'Arrow Left',
                'M10.17,42.34a2,2,0,0,1-2,2H4a2,2,0,0,1-2-2V9.66a2,2,0,0,1,2-2H8.13a2,2,0,0,1,2,2ZM50,28a2.11,2.11,0,0,1-2,2.05H30.6a1.3,1.3,0,0,0-.92,2.24h0l4.69,4.8a2,2,0,0,1,0,2.86h0l-2.75,2.86a1.87,1.87,0,0,1-2.76,0h0l-15-15.42a2,2,0,0,1,0-2.86h0l15-15.32a1.87,1.87,0,0,1,2.76,0h0L34.37,12a2,2,0,0,1,0,2.86h0l-4.69,4.8a1.3,1.3,0,0,0,.92,2.24H48A2.2,2.2,0,0,1,50,24Z'
            }
        );
        svgs.add(
            new List<String>{
                'Arrow Right',
                'M41.83,9.66a2,2,0,0,1,2-2H48a2,2,0,0,1,2,2V42.34a2,2,0,0,1-2,2H43.87a2,2,0,0,1-2-2ZM2,24A2.11,2.11,0,0,1,4,22H21.4a1.3,1.3,0,0,0,.92-2.24h0l-4.69-4.8a2,2,0,0,1,0-2.86h0l2.75-2.9a1.87,1.87,0,0,1,2.76,0h0l15,15.42a2,2,0,0,1,0,2.86h0l-15,15.32a1.87,1.87,0,0,1-2.76,0h0L17.63,40a2,2,0,0,1,0-2.86h0l4.69-4.8a1.3,1.3,0,0,0-.92-2.24H4A2.2,2.2,0,0,1,2,28Z'
            }
        );
        svgs.add(
            new List<String>{
                'Arrow Top',
                'M9.66,10.17a2,2,0,0,1-2-2V4a2,2,0,0,1,2-2H42.34a2,2,0,0,1,2,2V8.13a2,2,0,0,1-2,2ZM24,50a2.12,2.12,0,0,1-2.05-2h0V30.6a1.3,1.3,0,0,0-2.24-.92h0l-4.8,4.69a2,2,0,0,1-2.86,0h0L9.15,31.62a1.86,1.86,0,0,1,0-2.76h0l15.42-15a2,2,0,0,1,2.86,0h0l15.32,15a1.86,1.86,0,0,1,0,2.76h0L40,34.37a2,2,0,0,1-2.86,0h0l-4.8-4.69a1.3,1.3,0,0,0-2.24.92h0V48A2.19,2.19,0,0,1,28,50H24Z'
            }
        );
        svgs.add(
            new List<String>{
                'Arrow Down',
                'M9.6,31c-0.8,0.8-0.8,1.9,0,2.7l15,14.7c0.8,0.8,2,0.8,2.8,0l15.1-14.7c0.8-0.8,0.8-1.9,0-2.7l-2.8-2.7c-0.8-0.8-2-0.8-2.8,0l-4.7,4.6C31.4,33.7,30,33.2,30,32V5c0-1-0.9-2-2-2h-4c-1.1,0-2,1.1-2,2v27c0,1.2-1.4,1.7-2.2,0.9l-4.7-4.6c-0.8-0.8-2-0.8-2.8,0L9.6,31z'
            }
        );
        svgs.add(
            new List<String>{
                'Arrow Up',
                'M41.4,21c0.8-0.8,0.8-1.9,0-2.7l-15-14.7c-0.8-0.8-2-0.8-2.8,0L8.6,18.3c-0.8,0.8-0.8,1.9,0,2.7l2.8,2.7c0.8,0.8,2,0.8,2.8,0l4.7-4.6c0.8-0.8,2.2-0.2,2.2,0.9v27c0,1,0.9,2,2,2h4c1.1,0,2-1.1,2-2V20c0-1.2,1.4-1.7,2.2-0.9l4.7,4.6c0.8,0.8,2,0.8,2.8,0L41.4,21z'
            }
        );
        svgs.add(
            new List<String>{
                'Asset Warranty',
                'M40.7,2a2.1,2.1,0,0,1,2.06,2.06V25a7,7,0,0,1-1.42-.37,9.93,9.93,0,0,1-2-1.29A5.94,5.94,0,0,0,36,21.71a3.35,3.35,0,0,0-1.48.38V16.28a.7.7,0,0,0-.73-.73H32.22a.69.69,0,0,0-.45.2.71.71,0,0,0-.2.53v7.85a6.35,6.35,0,0,1-.91.51,7.36,7.36,0,0,1-1.23.35V16.28a.74.74,0,0,0-1.47,0v9c-.48.07-.95.15-1.4.26V16.28a.67.67,0,0,0-.2-.53.69.69,0,0,0-.53-.2h-3a.69.69,0,0,0-.45.2.68.68,0,0,0-.21.53V27.41a.75.75,0,0,0,.21.46.69.69,0,0,0,.53.2h1a11.6,11.6,0,0,0-.26,1.4H11.75a.65.65,0,0,0-.45.2.69.69,0,0,0-.2.53V31a.69.69,0,0,0,.2.45.68.68,0,0,0,.54.2H23.25a3.35,3.35,0,0,1-.19.56,9.44,9.44,0,0,1-1.28,2,6,6,0,0,0-1.64,3.37,5.94,5.94,0,0,0,1.64,3.37h0l.56.75H16.11v2.13a2.13,2.13,0,0,1-2.06,2.07H11.69a2.11,2.11,0,0,1-2.06-2.07V41.76H5.06A2.1,2.1,0,0,1,3,39.7V4.06A2.1,2.1,0,0,1,5.06,2ZM25.83,15.55h0Zm8,0h0Zm-18.92,0h-.08a.69.69,0,0,1,.73.73v11a.73.73,0,0,1-.2.54.71.71,0,0,1-.54.2H11.84a.71.71,0,0,1-.54-.2.74.74,0,0,1-.2-.46V16.28a.71.71,0,0,1,.2-.53.69.69,0,0,1,.45-.2h3.12Zm4.41,0h-.07a.7.7,0,0,1,.73.73v11a.7.7,0,0,1-.21.54.69.69,0,0,1-.53.2H17.73a.71.71,0,0,1-.54-.2.74.74,0,0,1-.2-.46V16.28a.71.71,0,0,1,.2-.53.69.69,0,0,1,.45-.2h1.64ZM34,11.87h-.08a.69.69,0,0,1,.53.2.66.66,0,0,1,.2.53v.74a.66.66,0,0,1-.2.53.67.67,0,0,1-.53.21H11.84a.7.7,0,0,1-.74-.66V12.6a.69.69,0,0,1,.65-.73H34Zm4.63,14.55A4.68,4.68,0,0,0,36,25.14a4.68,4.68,0,0,0-2.64,1.28,7.08,7.08,0,0,1-1.55,1,8.43,8.43,0,0,1-1.89.43,4.75,4.75,0,0,0-2.69.95,4.39,4.39,0,0,0-1,2.7,7.64,7.64,0,0,1-.41,1.87,7.08,7.08,0,0,1-1,1.55,4.68,4.68,0,0,0-1.28,2.64,4.68,4.68,0,0,0,1.28,2.64,7.08,7.08,0,0,1,1,1.55,8.43,8.43,0,0,1,.43,1.89,4.82,4.82,0,0,0,.94,2.69,4.42,4.42,0,0,0,2.71,1,7.75,7.75,0,0,1,1.87.41,7.89,7.89,0,0,1,1.55,1A4.68,4.68,0,0,0,36,50a4.68,4.68,0,0,0,2.64-1.28,7.89,7.89,0,0,1,1.55-1,8.43,8.43,0,0,1,1.89-.43,4.75,4.75,0,0,0,2.69-.94,4.4,4.4,0,0,0,1-2.71,7.75,7.75,0,0,1,.41-1.87,7.08,7.08,0,0,1,1-1.55,4.68,4.68,0,0,0,1.28-2.64,4.68,4.68,0,0,0-1.28-2.64,7.08,7.08,0,0,1-1-1.55,8.43,8.43,0,0,1-.43-1.89,4.76,4.76,0,0,0-.94-2.68,4.43,4.43,0,0,0-2.71-1,7.75,7.75,0,0,1-1.87-.41A7.08,7.08,0,0,1,38.64,26.42Zm1.09,7.1a.61.61,0,0,1,.91,0l.9.85a.69.69,0,0,1,0,.86l-5.72,6.35,0,0a1.18,1.18,0,0,1-.9.4,1.29,1.29,0,0,1-.91-.4l-3.1-3.09a.57.57,0,0,1,0-.86l.9-.85a.61.61,0,0,1,.91,0l2.2,2.24Z'
            }
        );
        svgs.add(
            new List<String>{
                'Assignment',
                'M3.6,29.8h44.6c0.9,0,1.6,0.7,1.6,1.6v3.2c0,0.9-0.7,1.6-1.6,1.6H3.6c-0.9,0-1.6-0.7-1.6-1.6v-3.2C2,30.5,2.7,29.8,3.6,29.8z x M3.6,15.6h44.6c0.9,0,1.6,0.7,1.6,1.6v3.2c0,0.9-0.7,1.6-1.6,1.6H3.6C2.7,22,2,21.3,2,20.4v-3.2C2,16.4,2.7,15.6,3.6,15.6z'
            }
        );
        svgs.add(
            new List<String>{
                'Attach',
                'M17.6,36.7c0.6,0.6,1.5,0.5,2.1,0l10-10c0.7-0.7,1.9-0.8,2.8,0c0.9,0.8,0.8,2.2,0,3L20.2,41.8c-2.7,2.7-7.2,2.7-9.9,0l-0.1-0.1c-2.7-2.7-2.7-7.2,0-9.9l21.7-21.7c2.7-2.7,7.2-2.7,9.9,0l0.1,0.1c2.7,2.7,2.7,7.2,0,9.9l-0.1,0.1c-0.5,0.5-0.6,1.2-0.2,1.8c0.6,1.1,1.1,2.3,1.4,3.5c0.2,0.8,1.1,1,1.7,0.5c0.8-0.8,1.5-1.6,1.5-1.6c5.1-5.1,5.1-13.4,0-18.5L46,5.9c-5.1-5.1-13.4-5.1-18.5,0L5.8,27.5c-5.1,5.1-5.1,13.4,0,18.5L6,46.2c5.1,5.1,13.3,5.1,18.4,0l12.4-12.3c3.2-3.2,3.1-8.4-0.2-11.6c-3.2-3.1-8.4-2.9-11.5,0.3l-9.8,9.8c-0.6,0.6-0.6,1.6,0,2.2L17.6,36.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Automate',
                'M26.1,16.4c-5.3,0-9.7,4.3-9.7,9.7s4.3,9.7,9.7,9.7c5.3,0,9.7-4.3,9.7-9.7S31.4,16.4,26.1,16.4z M26.1,33.1c-3.9,0-7.1-3.2-7.1-7.1c0-3.9,3.2-7.1,7.1-7.1c3.9,0,7.1,3.2,7.1,7.1C33.1,29.9,29.9,33.1,26.1,33.1z x M49.3,32.1c0.5-1.9,0.8-4,0.8-6.1c0-2.1-0.3-4.1-0.8-6.1h-2.7c-0.4-1.5-1-2.9-1.7-4.2l1.9-1.9c-2.1-3.5-5-6.5-8.6-8.6l-1.9,1.9c-1.3-0.7-2.7-1.3-4.2-1.7V2.8c-1.9-0.5-4-0.8-6.1-0.8c-2.1,0-4.1,0.3-6.1,0.8v2.7c-1.4,0.4-2.8,1-4.1,1.7l-2-1.9c-3.6,2.1-6.5,5.1-8.6,8.6l1.9,1.9c-0.7,1.3-1.3,2.7-1.7,4.2H2.8C2.3,21.9,2,23.9,2,26c0,2.1,0.3,4.1,0.8,6.1h2.7c0.4,1.5,1,2.9,1.7,4.2l-1.9,1.9c2.1,3.5,5,6.5,8.6,8.6l1.9-1.9c1.3,0.7,2.7,1.3,4.2,1.7v2.7c1.9,0.5,4,0.8,6.1,0.8c2.1,0,4.1-0.3,6.1-0.8v-2.7c1.5-0.4,2.9-1,4.2-1.7l1.9,1.9c3.5-2.1,6.5-5,8.6-8.6l-1.9-1.9c0.7-1.3,1.3-2.7,1.7-4.2H49.3z M43.5,38.6c-0.7,0.9-1.4,1.8-2.3,2.6c-0.8,0.8-1.7,1.6-2.6,2.3l-1.9-1.9c-2.1,1.5-4.6,2.5-7.2,3v2.6c-1.1,0.2-2.3,0.3-3.5,0.3c-1.2,0-2.3-0.1-3.5-0.3v-2.6c-2.6-0.5-5.1-1.5-7.2-3l-1.9,1.9c-0.9-0.7-1.8-1.5-2.6-2.3c-0.8-0.8-1.6-1.7-2.3-2.6l1.9-1.9c-1.5-2.1-2.5-4.6-3-7.2H4.8c-0.2-1.1-0.3-2.3-0.3-3.5c0-1.2,0.1-2.3,0.3-3.5h2.7c0.5-2.6,1.5-5.1,3-7.2l-1.9-1.9c0.7-0.9,1.5-1.8,2.3-2.6c0.8-0.8,1.7-1.6,2.6-2.3l1.9,1.9c2.1-1.5,4.6-2.5,7.2-3V4.8c1.1-0.2,2.3-0.3,3.5-0.3c1.2,0,2.3,0.1,3.5,0.3v2.7c2.6,0.5,5.1,1.5,7.2,3l1.9-1.9c0.9,0.7,1.8,1.4,2.6,2.3c0.8,0.8,1.6,1.7,2.3,2.6l-1.9,1.9c1.5,2.1,2.5,4.6,3,7.2h2.7c0.2,1.1,0.3,2.3,0.3,3.5c0,1.2-0.1,2.3-0.3,3.5h-2.7c-0.5,2.6-1.5,5.1-3,7.2L43.5,38.6z'
            }
        );
        svgs.add(
            new List<String>{
                'Away',
                'M43,9C33.6-0.3,18.4-0.3,9,9s-9.3,24.6,0,34s24.6,9.3,34,0S52.3,18.4,43,9z M13.3,13.3c7-7,18.5-7,25.5,0c2.8,2.8,4.5,6.2,5,9.7H8.2C8.8,19.4,10.5,16,13.3,13.3z'
            }
        );
        svgs.add(
            new List<String>{
                'Back',
                'M48.6,23H15.4c-0.9,0-1.3-1.1-0.7-1.7l9.6-9.6c0.6-0.6,0.6-1.5,0-2.1l-2.2-2.2c-0.6-0.6-1.5-0.6-2.1,0L2.5,25c-0.6,0.6-0.6,1.5,0,2.1L20,44.6c0.6,0.6,1.5,0.6,2.1,0l2.1-2.1c0.6-0.6,0.6-1.5,0-2.1l-9.6-9.6C14,30.1,14.4,29,15.3,29h33.2c0.8,0,1.5-0.6,1.5-1.4v-3C50,23.8,49.4,23,48.6,23z'
            }
        );
        svgs.add(
            new List<String>{
                'Ban',
                'M26,2C12.8,2,2,12.8,2,26s10.8,24,24,24s24-10.8,24-24S39.2,2,26,2z M37.9,27.7c-0.1,0.7-0.7,1.3-1.5,1.3H15.6c-0.8,0-1.4-0.5-1.5-1.3c-0.1-1.2-0.1-2.3,0-3.4c0.1-0.7,0.7-1.3,1.5-1.3h20.8c0.8,0,1.4,0.6,1.5,1.3C38,25.5,38,26.6,37.9,27.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Block Visitor',
                'M22,37a17.19,17.19,0,0,1,2.3-8.2c1.7-3,3.6-4.2,5.1-6.4a14.64,14.64,0,0,0,1.4-13A10,10,0,0,0,21,3a10,10,0,0,0-9.4,6.9c-1.6,4.5-.9,9.9,2.7,13.3,1.5,1.4,2.9,3.6,2.1,5.7s-3.1,2.9-4.8,3.7C7.7,34.3,3,36.7,2.2,41.3A6.22,6.22,0,0,0,8.1,49h17a1,1,0,0,0,.8-1.6A16,16,0,0,1,22,37Z x M46.5,28.5a12,12,0,1,0,0,17A12,12,0,0,0,46.5,28.5ZM32.3,31.3a7.91,7.91,0,0,1,9.8-1.2l-11,11A7.91,7.91,0,0,1,32.3,31.3ZM43.7,42.7A8.36,8.36,0,0,1,33.9,44l11-11A8.05,8.05,0,0,1,43.7,42.7Z'
            }
        );
        svgs.add(
            new List<String>{
                'Bold',
                'M41,19c0-6-4.8-11-10.5-11H14c-1.1,0-2,0.9-2,2v33c0,1.1,0.9,2,2,2h16.5C36.2,45,41,40,41,34c0-2.9-1.1-5.5-2.9-7.5C39.9,24.5,41,21.9,41,19z M30.5,38H19v-8h11.5c1.9,0,3.6,1.9,3.6,4S32.4,38,30.5,38z M30.5,23H19v-8h11.5c1.9,0,3.6,1.9,3.6,4S32.4,23,30.5,23z'
            }
        );
        svgs.add(
            new List<String>{
                'Bookmark',
                'M37.3,49.6l-9.9-9.9c-0.6-0.6-1.5-0.6-2.1,0l-10.6,10C14,50.3,13,49.9,13,49V6c0-2.2,1.8-4,4-4h18c2.2,0,4,1.8,4,4v42.9C39,49.8,37.9,50.3,37.3,49.6z'
            }
        );
        svgs.add(
            new List<String>{
                'Bookmark Alt',
                'M46,2H6A3.2,3.2,0,0,0,2.82,5.18V46.82a3.19,3.19,0,0,0,4.87,2.7L26,38.11,44.31,49.52a3.19,3.19,0,0,0,4.87-2.7V5.18A3.2,3.2,0,0,0,46,2ZM39,17.49,31.53,23l2.85,8.81a.57.57,0,0,1-.35.72.54.54,0,0,1-.52-.07L26,27l-7.51,5.46a.58.58,0,0,1-.8-.13.6.6,0,0,1-.07-.52L20.47,23,13,17.49a.58.58,0,0,1,0-.82.55.55,0,0,1,.38-.18h9.25L25.5,7.67a.56.56,0,0,1,.69-.39.55.55,0,0,1,.39.39l2.89,8.82h9.25a.58.58,0,0,1,.46.68A.57.57,0,0,1,39,17.49Z'
            }
        );
        svgs.add(
            new List<String>{
                'Breadcrumbs',
                'M8.4,42c-0.6,0-1-0.4-1-1V10.9c0-0.6,0.4-1,1-1h8.1c0.4,0,0.9,0.2,1.2,0.5L29.3,25c0.4,0.5,0.4,1.3,0,1.9L17.6,41.5c-0.3,0.4-0.8,0.6-1.3,0.6L8.4,42z x M44.3,25L32.6,10.5c-0.5-0.6-1.4-0.8-2.1-0.2l-2.3,1.9c-0.7,0.5-0.8,1.5-0.2,2.1L37.5,26L28,37.8c-0.5,0.6-0.4,1.6,0.2,2.1l2.3,1.9c0.7,0.5,1.5,0.4,2.1-0.2L44.3,27C44.7,26.2,44.7,25.5,44.3,25z'
            }
        );
        svgs.add(
            new List<String>{
                'Broadcast',
                'M2,18.992c0,5.832,2.28,11.292,6.362,15.374c0.902,0.899,2.28,0.899,3.181,0c0.902-0.9,0.902-2.279,0-3.183c-3.233-3.231-5.036-7.58-5.088-12.19C6.508,14.381,8.31,10.034,11.543,6.8c0.902-0.901,0.902-2.279,0-3.181c-0.901-0.9-2.28-0.901-3.181,0C4.28,7.701,2,13.161,2,18.992z x M14.723,28.004c0.902,0.902,2.28,0.902,3.182,0c0.9-0.9,0.9-2.278,0-3.181c-1.538-1.537-2.438-3.605-2.438-5.831c-0.001-2.227,0.847-4.241,2.438-5.832c0.9-0.901,0.9-2.279,0-3.181c-0.902-0.9-2.28-0.901-3.182,0c-2.385,2.385-3.71,5.62-3.71,9.012C11.013,22.385,12.338,25.619,14.723,28.004z x M43.499,3.618c-0.901-0.901-2.28-0.9-3.181,0c-0.901,0.902-0.901,2.28,0,3.181c3.232,3.234,5.035,7.581,5.089,12.193c-0.054,4.611-1.855,8.959-5.089,12.191c-0.901,0.901-0.901,2.28,0,3.182c0.899,0.9,2.277,0.9,3.181,0c4.081-4.082,6.36-9.542,6.36-15.374C49.859,13.161,47.582,7.701,43.499,3.618z x M40.85,18.992c-0.002-3.392-1.326-6.627-3.713-9.012c-0.9-0.901-2.279-0.9-3.181,0c-0.901,0.902-0.899,2.28,0,3.181c1.591,1.59,2.438,3.604,2.438,5.832c0,2.226-0.9,4.294-2.438,5.831c-0.901,0.902-0.899,2.279,0,3.181c0.901,0.902,2.28,0.902,3.181,0C39.523,25.619,40.848,22.385,40.85,18.992z x M23.662,24.349c-2.12-0.881-3.61-2.972-3.61-5.411c0-3.235,2.623-5.857,5.857-5.857c3.234,0,5.856,2.622,5.856,5.857c0,2.426-1.475,4.507-3.576,5.396l-0.03,2.759v20.844c0,0.601-0.524,1.125-1.125,1.052h-2.249c-0.599,0-1.125-0.525-1.125-1.125V27.02L23.662,24.349z'
            }
        );
        svgs.add(
            new List<String>{
                'Brush',
                'M49.4,2.7L49.4,2.7C46-0.8,27,10,15.4,28.6c-0.5,0.9-0.2,2,0.7,2.4c2.6,1.2,4.7,3.4,5.8,6.1c0.4,1,1.5,1.3,2.4,0.7C42.3,25.9,52.8,6.2,49.4,2.7z x M11.9,35.2C10.4,35.2,9,36,8,37l0,0H7.9c-0.5,0-1,0.8-1.4,1.5c-1.6,2.7-1.9,5.9-4.3,9.4c-0.4,0.6-0.3,1.5,0.4,1.7c3.4,1.1,9.5,0.1,12.5-2.1c0,0,0,0.2,0,0.1c1-0.2,0.7-0.6,1-0.6l0,0c1.1-2,2-3,2-4.9C18,38.4,15.4,35.2,11.9,35.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Bucket',
                'M49,11c0-6.2-9.8-9-19-9s-19,2.8-19,9c0,0.1,0,0.3,0,0.4C2.4,14,1,19.5,1,22.6c0,3,1.5,6.1,4.1,8.3c2.3,1.9,5.1,3,7.9,3.1v0c0.1,0,0.2,0,0.4,0c0,0,0.1,0,0.1,0c0.1,0,0.2,0,0.3,0c6.5-0.2,12.9-2.3,14.7-5.9C27.6,27.4,27,26.2,27,25c0-2.2,1.8-4,4-4s4,1.8,4,4c0,1.7-1,3.1-2.5,3.7c-2,5.6-10,9.3-19.5,9.3v6c0,3.3,7.6,6,17,6s17-2.7,17-6V15.3C48.3,14.1,49,12.7,49,11z M30,8c6.6,0,10.8,1.5,12.4,2.6c0.3,0.2,0.3,0.6,0,0.8C40.8,12.5,36.6,14,30,14s-10.8-1.5-12.4-2.6c-0.3-0.2-0.3-0.6,0-0.8C19.2,9.5,23.4,8,30,8z M7.7,27.8C6,26.4,5,24.5,5,22.6c0-4.5,4.1-6.6,7.7-7.5c0.1,0.1,0.2,0.2,0.3,0.3V30C11.1,29.9,9.2,29.1,7.7,27.8z'
            }
        );
        svgs.add(
            new List<String>{
                'Bug',
                'm19.6 10h12.8a1.51 1.51 0 0 0 1.43-1.75 8 8 0 0 0 -7.83-6.25 8.05 8.05 0 0 0 -7.83 6.24 1.51 1.51 0 0 0 1.43 1.76z x m47.59 30.8a2.4 2.4 0 0 0 2.41-2.56 2.47 2.47 0 0 0 -2.57-2.24h-7v-4c4.64-1.84 7.91-6.8 8-12.71a2.48 2.48 0 0 0 -2-2.48 2.39 2.39 0 0 0 -2.8 2.4 9.14 9.14 0 0 1 -3.92 7.83 4.87 4.87 0 0 0 -4.08-2.24h-19.22a4.87 4.87 0 0 0 -4.08 2.24 9 9 0 0 1 -3.92-7.66 2.53 2.53 0 0 0 -2.24-2.56 2.39 2.39 0 0 0 -2.55 2.4c0 5.91 3.35 11 8 12.79v4h-7a2.53 2.53 0 0 0 -2.62 2.23 2.44 2.44 0 0 0 2.41 2.56h7.2v4c-4.61 1.84-7.91 6.79-7.99 12.71a2.48 2.48 0 0 0 2 2.48 2.39 2.39 0 0 0 2.8-2.4 9 9 0 0 1 3.84-7.76 14.4 14.4 0 0 0 9.27 9.44 1.61 1.61 0 0 0 2.08-1.52v-19.19a2.53 2.53 0 0 1 2.23-2.56 2.44 2.44 0 0 1 2.56 2.4v19.35a1.58 1.58 0 0 0 2.08 1.52 14.4 14.4 0 0 0 9.27-9.44 9.25 9.25 0 0 1 3.84 7.6 2.53 2.53 0 0 0 2.24 2.57 2.4 2.4 0 0 0 2.56-2.4c0-5.92-3.36-11-8-12.79v-4z'
            }
        );
        svgs.add(
            new List<String>{
                'Builder',
                'M11.5,17h-8C2.7,17,2,17.7,2,18.5V44c0,2.2,1.8,4,4,4h5.5c0.8,0,1.5-0.7,1.5-1.5v-28C13,17.7,12.3,17,11.5,17z x M48.5,17h-30c-0.8,0-1.5,0.7-1.5,1.5v28c0,0.8,0.7,1.5,1.5,1.5H46c2.2,0,4-1.8,4-4V18.5C50,17.7,49.3,17,48.5,17z x M46,4H6C3.8,4,2,5.8,2,8v3.5C2,12.3,2.7,13,3.5,13h45c0.8,0,1.5-0.7,1.5-1.5V8C50,5.8,48.2,4,46,4z'
            }
        );
        svgs.add(
            new List<String>{
                'Bundle Config',
                'M14.4,2H8A6,6,0,0,0,2,8v6a6,6,0,0,0,6,6h6.4a6,6,0,0,0,6-6V8A6,6,0,0,0,14.4,2ZM11.53,15.1h-.66a4.1,4.1,0,0,1,0-8.19h.66a4.1,4.1,0,0,1,0,8.19Z x M31.2,20h6.4a6,6,0,0,0,6-6V8a6,6,0,0,0-6-6H31.2a6,6,0,0,0-6,6v6A6,6,0,0,0,31.2,20ZM34.07,6.91h.66a4.1,4.1,0,0,1,0,8.19h-.66a4.1,4.1,0,0,1,0-8.19Z x M14.4,24.93,8,25a6,6,0,0,0-6,6v5.87a6,6,0,0,0,6,6h6.4a6,6,0,0,0,6-6V30.93A6,6,0,0,0,14.4,24.93ZM11.53,38h-.66a4.1,4.1,0,0,1,0-8.19h.66a4.1,4.1,0,0,1,0,8.19Z x M49.27,35.07a14.83,14.83,0,0,1-1.88-.22.22.22,0,0,1-.2-.21,18.39,18.39,0,0,0-.84-2v-.32c.32-.53.84-1.06,1.15-1.6a.82.82,0,0,0-.11-1.06l-2.08-2.14a.78.78,0,0,0-.52-.21,2.36,2.36,0,0,0-.52.21c-.52.32-1,.86-1.56,1.18a.1.1,0,0,0-.11.09h-.1c-.73-.21-1.25-.64-2-.85a.23.23,0,0,1-.21-.21c-.1-.64-.1-1.18-.21-1.82a.89.89,0,0,0-.52-.85.33.33,0,0,0-.21-.11h-3a.86.86,0,0,0-.52.11c-.21.21-.52.53-.52.85a11.15,11.15,0,0,1-.21,1.82.23.23,0,0,1-.21.21c-.73.21-1.25.64-2,.85h-.1c-.11,0-.11,0-.21-.1-.52-.32-.94-.86-1.56-1.18a.62.62,0,0,0-.53-.21c-.31,0-.31.11-.62.21l-2.08,2.14a.82.82,0,0,0-.11,1.06c.31.54.83,1,1.15,1.6a.21.21,0,0,1,0,.3l0,0c-.21.75-.63,1.28-.84,2a.22.22,0,0,1-.2.21c-.63.11-1.15.11-1.78.22a.87.87,0,0,0-.83.64v3.62A1.59,1.59,0,0,0,26,40a9.73,9.73,0,0,1,1.78.22.22.22,0,0,1,.2.21c.21.75.63,1.28.84,2,0,.1.1.21,0,.32-.32.53-.84,1.06-1.15,1.6a.82.82,0,0,0,.11,1.06l2.08,2.14c.21.21.31.21.62.21a1.63,1.63,0,0,0,.53-.21c.5-.42,1-.81,1.56-1.18.1,0,.1-.1.21-.1h.1c.73.21,1.25.64,2,.85a.23.23,0,0,1,.21.21c.1.64.1,1.28.21,1.92s.31.75.83.75h3c.52,0,.73-.21.84-.75s.1-1.28.21-1.92a.22.22,0,0,1,.2-.21,18.46,18.46,0,0,0,2-.85h.11a.09.09,0,0,1,.1.1c.52.32,1,.86,1.56,1.18a.86.86,0,0,0,.53.21c.2,0,.31-.11.62-.21l2.08-2.14a.82.82,0,0,0,.11-1.06c-.31-.54-.83-1-1.15-1.6a.21.21,0,0,1,0-.3l0,0c.21-.75.63-1.28.84-2a.22.22,0,0,1,.2-.21c.63-.11,1.26-.11,1.88-.22s.73-.32.73-.85v-3C50,35.39,49.79,35.17,49.27,35.07Zm-6.9,2.45a4.93,4.93,0,0,1-4.67,4.8,4.65,4.65,0,0,1-4.7-4.6v-.2a4.69,4.69,0,0,1,9.37-.43A3.09,3.09,0,0,1,42.37,37.52Z'
            }
        );
        svgs.add(
            new List<String>{
                'Bundle Policy',
                'M37.55,22.55a2,2,0,0,0-2.83,0L30.43,27a2.11,2.11,0,0,0,0,2.92l9.62,9.94h0a2,2,0,0,0,2.83,0l4.29-4.44a2.11,2.11,0,0,0,0-2.92l-9.62-9.94Z x M31.8,39a2.37,2.37,0,0,0-3.35,0l-6.22,6.27h-.06a2.42,2.42,0,0,0,.06,3.34l0,0a2.37,2.37,0,0,0,3.35,0l6.22-6.22.06,0A2.42,2.42,0,0,0,31.84,39Z x M47.68,45.2H37.92a2.4,2.4,0,1,0,0,4.8h9.76A2.36,2.36,0,0,0,50,47.6h0A2.36,2.36,0,0,0,47.68,45.2Z x M13.6,2H8A6.11,6.11,0,0,0,2,8.2V11a6.11,6.11,0,0,0,6,6.2h5.6a6.11,6.11,0,0,0,6-6.2V8.2A6.11,6.11,0,0,0,13.6,2ZM12.09,12.4H9.5A2.75,2.75,0,0,1,6.8,9.6h0A2.75,2.75,0,0,1,9.51,6.8H12.1a2.75,2.75,0,0,1,2.7,2.8h0A2.75,2.75,0,0,1,12.09,12.4Z x M13.6,22H8a6.11,6.11,0,0,0-6,6.2V31a6.11,6.11,0,0,0,6,6.2h5.6a6.11,6.11,0,0,0,6-6.2V28.2A6.11,6.11,0,0,0,13.6,22ZM12.09,32.4H9.51a2.8,2.8,0,0,1,0-5.6h2.58a2.8,2.8,0,1,1,0,5.6Z x M30.4,17.2H36A6.11,6.11,0,0,0,42,11V8.2A6.11,6.11,0,0,0,36,2H30.4a6.11,6.11,0,0,0-6,6.2V11A6.11,6.11,0,0,0,30.4,17.2ZM31.91,6.8H34.5a2.75,2.75,0,0,1,2.7,2.8h0a2.75,2.75,0,0,1-2.71,2.79H31.9a2.75,2.75,0,0,1-2.7-2.8h0A2.75,2.75,0,0,1,31.91,6.8Z'
            }
        );
        svgs.add(
            new List<String>{
                'Button Choice',
                'M31.9981689,11.9995104 C33.4659424,11.9985117 34.998291,13.1328 34.998291,16.1348 L34.998291,16.1348 L34.998291,26 C34.998291,27.5134277 36.3779053,28.1114014 36.9779053,28.3114014 L36.9779053,28.3114014 L43.8,30.8 C46.7,31.9 48.5,35 47.7,38.2 L47.7,38.2 L44.5,48.5995 C44.3,49.3995 43.6,49.9995 42.7,49.9995 L42.7,49.9995 L26.6,49.9995 C25.8,49.9995 25.1,49.5995 24.8,48.8995 C20.9318685,39.9190553 18.7869873,34.9395752 18.3653564,33.9610596 C17.9437256,32.9825439 18.2219401,32.1955241 19.2,31.6 C21,30.3 23.7,31.6395508 24.8,33.5395508 L24.8,33.5395508 L26.4157715,35.7431828 C27.0515137,36.9508 29,36.9508 29,35.1508 L29,35.1508 L29,16.1348 C29,13.1328 30.5303955,12.0005117 31.9981689,11.9995104 Z M46,2 C48.2,2 50,3.8 50,6 L50,6 L50,21 C50,22.882323 48.1813389,25.0030348 46,25 L46,25 L40.010437,25 C39,25 39,24.1881157 39,24.059082 L39,15.5 C39,11.6547018 37.0187988,8 32,8 C26.9812012,8 25,11.1879783 25,15.5 L25,15.5 L25,24.059082 C25,24.4078007 24.7352295,25 23.987793,25 L23.987793,25 L6,25 C3.8,25 2,23.2 2,21 L2,21 L2,6 C2,3.8 3.8,2 6,2 L6,2 Z'
            }
        );
        svgs.add(
            new List<String>{
                'Calculated Insights',
                'M44,6.81a6,6,0,0,0-4.77,9.56l-5,8.82H33.6a6,6,0,0,0-3,.81l-6.35-4.67A5.9,5.9,0,0,0,24.4,20a6,6,0,1,0-10.73,3.67L8.52,33.2H8a5.94,5.94,0,0,0-3.69,1.25,6,6,0,1,0,8.41,1.08L17.89,26h.51a5.94,5.94,0,0,0,3-.8l6.35,4.67a5.9,5.9,0,0,0-.15,1.33,6,6,0,1,0,10.78-3.58l5-8.82H44a6,6,0,1,0,0-12Z'
            }
        );
        svgs.add(
            new List<String>{
                'Call',
                'M48.5,37.9L42.4,33c-1.4-1.1-3.4-1.2-4.8-0.1l-5.2,3.8c-0.6,0.5-1.5,0.4-2.1-0.2l-7.8-7l-7-7.8c-0.6-0.6-0.6-1.4-0.2-2.1l3.8-5.2c1.1-1.4,1-3.4-0.1-4.8l-4.9-6.1c-1.5-1.8-4.2-2-5.9-0.3L3,8.4c-0.8,0.8-1.2,1.9-1.2,3c0.5,10.2,5.1,19.9,11.9,26.7S30.2,49.5,40.4,50c1.1,0.1,2.2-0.4,3-1.2l5.2-5.2C50.5,42.1,50.4,39.3,48.5,37.9z'
            }
        );
        svgs.add(
            new List<String>{
                'Campaign',
                'M26,0.8C12.1,0.8,0.8,12.1,0.8,26S12.1,51.2,26,51.2S51.2,39.9,51.2,26S39.9,0.8,26,0.8z M26,46.2C14.9,46.2,5.8,37.1,5.8,26S14.9,5.8,26,5.8S46.2,14.9,46.2,26S37.1,46.2,26,46.2z M26,10.9c-8.3,0-15.1,6.8-15.1,15.1S17.7,41.1,26,41.1S41.1,34.3,41.1,26S34.3,10.9,26,10.9z M26,36.1c-5.5,0-10.1-4.5-10.1-10.1S20.5,15.9,26,15.9S36.1,20.5,36.1,26S31.5,36.1,26,36.1z M26,21c-2.8,0-5,2.3-5,5s2.3,5,5,5s5-2.3,5-5S28.8,21,26,21z'
            }
        );
        svgs.add(
            new List<String>{
                'Cancel File Request',
                'M28.6,11.4h5.1c0.6,0,1.1-0.5,1.1-1.1c0-0.3-0.1-0.5-0.3-0.8l-7.2-7.1c-0.2-0.2-0.4-0.3-0.7-0.3c-0.6,0-1.1,0.5-1.1,1.1v5.1C25.5,10,26.9,11.4,28.6,11.4z x M24.6,40.6c0-6.8,4.2-12.6,10.2-14.9v-8.1c0-0.9-0.7-1.6-1.6-1.6h-7.8c-2.6,0-4.7-2.1-4.7-4.6V3.6c0.1-0.8-0.6-1.5-1.5-1.5H6.8c-2.6,0-4.7,2.1-4.7,4.6v29.4c0,2.6,2.1,4.6,4.7,4.6h17.8C24.6,40.7,24.6,40.6,24.6,40.6z x M31.8,34.6l6,6l-6,6c-0.6,0.6-0.6,1.6,0,2.1l0.7,0.7c0.6,0.6,1.6,0.6,2.1,0l6-6l6,6c0.6,0.6,1.6,0.6,2.1,0l0.7-0.7c0.6-0.6,0.6-1.6,0-2.1l-6-6l6-6c0.6-0.6,0.6-1.6,0-2.1l-0.7-0.7c-0.6-0.6-1.6-0.6-2.1,0l-6,6l-6-6c-0.6-0.6-1.6-0.6-2.1,0l-0.7,0.7C31.2,33,31.2,34,31.8,34.6z'
            }
        );
        svgs.add(
            new List<String>{
                'Cancel Transfer',
                'M25.1,12.3v-3c4,0,7.2,3.2,7.2,7.2h-3l4.6,5.7c0.3,0.3,0.7,0.3,0.9,0l4.6-5.7h-3c0-6.3-5.2-11.4-11.4-11.4v-3l-5.7,4.6C19,7,19.1,7.4,19.4,7.6L25.1,12.3z x M26.3,33.6c-1.2-1.6-3.5-2.7-5.8-3.8c-2.4-1-2.7-2-2.7-3c0-1,0.6-2.1,1.4-2.8c1.3-1.3,2.1-3.2,2.1-5.3c0-4-2.4-7.5-6.5-7.5h-0.4c-4.1,0-6.5,3.5-6.5,7.5c0,2.2,0.7,4,2.1,5.3c0.8,0.7,1.4,1.7,1.4,2.8c0,1-0.3,2-2.7,3c-3.4,1.5-6.6,3.1-6.7,6.3C2.3,38.4,3.8,40,5.8,40h17.9c0.3,0,0.7-0.1,1-0.2C24.8,37.6,25.3,35.5,26.3,33.6z x M31.8,34.6l6,6l-6,6c-0.6,0.6-0.6,1.6,0,2.1l0.7,0.7c0.6,0.6,1.6,0.6,2.1,0l6-6l6,6c0.6,0.6,1.6,0.6,2.1,0l0.7-0.7c0.6-0.6,0.6-1.6,0-2.1l-6-6l6-6c0.6-0.6,0.6-1.6,0-2.1l-0.7-0.7c-0.6-0.6-1.6-0.6-2.1,0l-6,6l-6-6c-0.6-0.6-1.6-0.6-2.1,0l-0.7,0.7C31.2,33,31.2,34,31.8,34.6z'
            }
        );
        svgs.add(
            new List<String>{
                'Capacity Plan',
                'M43.3,6H41.57a.74.74,0,0,0-.67.8V10a6.37,6.37,0,0,1-6.3,6.4H17.4A6.37,6.37,0,0,1,11.1,10V6.67A.74.74,0,0,0,10.3,6H8.7A4.77,4.77,0,0,0,4,10.8V45.2A4.77,4.77,0,0,0,8.7,50H43.3A4.77,4.77,0,0,0,48,45.2V10.8A4.77,4.77,0,0,0,43.3,6ZM25.92,45a12,12,0,0,1,.16-24h0a12,12,0,0,1-.16,24Z x M16.91,11.6H34.77a1.59,1.59,0,0,0,1.63-1.55V6.8A4.81,4.81,0,0,0,31.6,2H20.4a4.82,4.82,0,0,0-4.8,4.8V10A1.47,1.47,0,0,0,16.91,11.6Z x M32.23,27.2A9.09,9.09,0,0,0,26,24.4v8.8h8.77A7.32,7.32,0,0,0,32.23,27.2Z'
            }
        );
        svgs.add(
            new List<String>{
                'Caps Lock',
                'M43.6,21.1L27.2,2.5c-0.6-0.7-1.8-0.7-2.4,0L8.4,21.1C7.8,21.8,8.3,23,9.3,23H17v12.5c0,0.8,0.7,1.5,1.5,1.5h15c0.8,0,1.5-0.7,1.5-1.5V23h7.7C43.7,23,44.2,21.8,43.6,21.1z x M33.5,43h-15c-0.8,0-1.5,0.7-1.5,1.5v4c0,0.8,0.7,1.5,1.5,1.5h15c0.8,0,1.5-0.7,1.5-1.5v-4C35,43.7,34.3,43,33.5,43z'
            }
        );
        svgs.add(
            new List<String>{
                'Case',
                'M17.2,11.3h2.9c0.4,0,0.7-0.3,0.7-0.7V8.4h10.3v2.2c0,0.4,0.3,0.7,0.7,0.7h2.9c0.4,0,0.7-0.3,0.7-0.7V8.4c0-2.4-2-4.4-4.4-4.4H20.9c-2.4,0-4.4,2-4.4,4.4v2.2C16.5,11,16.7,11.3,17.2,11.3z M43.6,15.7H8.4c-2.4,0-4.4,2-4.4,4.4v23.5C4,46,6,48,8.4,48h35.2c2.4,0,4.4-2,4.4-4.4V20.1C48,17.7,46,15.7,43.6,15.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Cases',
                'M9,3.5C9,2.7,8.3,2,7.5,2h-4C2.7,2,2,2.7,2,3.5v31C2,35.3,2.7,36,3.5,36h4C8.3,36,9,35.3,9,34.5V3.5z x M50,3.5C50,2.7,49.3,2,48.5,2h-4C43.7,2,43,2.7,43,3.5v31c0,0.8,0.7,1.5,1.5,1.5h4c0.8,0,1.5-0.7,1.5-1.5V3.5z x M37.5,2h-3C33.7,2,33,2.8,33,3.6V16c0,0.4,0.2,0.7,0.6,0.9c1.7,0.9,3.2,2,4.5,3.3c0.3,0.3,0.9,0.1,0.9-0.3V3.6C39,2.8,38.3,2,37.5,2z x M24.1,15.2c0.6-0.1,1.3-0.1,1.9-0.1s1.3,0,1.9,0.1s1.1-0.4,1.1-1V3.6C29,2.8,28.3,2,27.5,2h-3C23.7,2,23,2.8,23,3.6v10.6C23,14.8,23.5,15.3,24.1,15.2z x M13.9,20.2c1.3-1.4,2.9-2.5,4.6-3.3c0.3-0.2,0.5-0.5,0.5-0.9V3.6C19,2.8,18.3,2,17.5,2h-3C13.7,2,13,2.8,13,3.6v16.3C13,20.3,13.5,20.5,13.9,20.2z x M26,19.1c-7.2,0-13,5.8-13,13c0,2.2,0.6,4.4,1.6,6.2l-7.1,7.1c-0.6,0.6-0.6,1.5,0,2.1l2.1,2.1c0.6,0.6,1.5,0.6,2.1,0l6.9-6.9c2.1,1.5,4.7,2.4,7.4,2.4c7.2,0,13-5.8,13-13S33.2,19.1,26,19.1z M26,39.1c-3.9,0-7-3.1-7-7s3.1-7,7-7s7,3.1,7,7S29.9,39.1,26,39.1z'
            }
        );
        svgs.add(
            new List<String>{
                'Center Align Text',
                'M48,6.5C48,5.7,47.3,5,46.5,5h-41C4.7,5,4,5.7,4,6.5v3C4,10.3,4.7,11,5.5,11h41c0.8,0,1.5-0.7,1.5-1.5V6.5z x M42,18.5c0-0.8-0.7-1.5-1.5-1.5h-29c-0.8,0-1.5,0.7-1.5,1.5v3c0,0.8,0.7,1.5,1.5,1.5h29c0.8,0,1.5-0.7,1.5-1.5V18.5z x M40,42.5c0-0.8-0.7-1.5-1.5-1.5h-25c-0.8,0-1.5,0.7-1.5,1.5v3c0,0.8,0.7,1.5,1.5,1.5h25c0.8,0,1.5-0.7,1.5-1.5V42.5z x M48,30.5c0-0.8-0.7-1.5-1.5-1.5h-41C4.7,29,4,29.7,4,30.5v3C4,34.3,4.7,35,5.5,35h41c0.8,0,1.5-0.7,1.5-1.5V30.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Change Owner',
                'm27.3 37.6c-3-1.2-3.5-2.3-3.5-3.5 0-1.2 0.8-2.3 1.8-3.2 1.8-1.5 2.6-3.9 2.6-6.4 0-4.7-2.9-8.5-8.3-8.5s-8.3 3.8-8.3 8.5c0 2.5 0.8 4.9 2.6 6.4 1 0.9 1.8 2 1.8 3.2 0 1.2-0.5 2.3-3.5 3.5-4.4 1.8-8.6 3.8-8.7 7.6 0.2 2.6 2.2 4.8 4.7 4.8h23c2.5 0 4.5-2.2 4.5-4.7-0.1-3.8-4.3-5.9-8.7-7.7z m17.2-18.6c0-7.4-6.1-13.5-13.5-13.5v-3.5l-6.8 5.5c-0.3 0.3-0.2 0.8 0.1 1.1l6.7 5.4v-3.5c4.7 0 8.5 3.8 8.5 8.5h-3.5l5.5 6.8c0.3 0.3 0.8 0.3 1.1 0l5.4-6.8h-3.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Change Record Type',
                'M20,37.5c0-0.8-0.7-1.5-1.5-1.5h-15C2.7,36,2,36.7,2,37.5v11C2,49.3,2.7,50,3.5,50h15c0.8,0,1.5-0.7,1.5-1.5V37.5z x M8.1,22H3.2c-1,0-1.5,0.9-0.9,1.4l8,8.3c0.4,0.3,1,0.3,1.4,0l8-8.3c0.6-0.6,0.1-1.4-0.9-1.4h-4.7c0-5,4.9-10,9.9-10V6C15,6,8.1,13,8.1,22z x M41.8,20.3c-0.4-0.3-1-0.3-1.4,0l-8,8.3c-0.6,0.6-0.1,1.4,0.9,1.4h4.8c0,6-4.1,10-10.1,10v6c9,0,16.1-7,16.1-16H49c1,0,1.5-0.9,0.9-1.4L41.8,20.3z x M50,3.5C50,2.7,49.3,2,48.5,2h-15C32.7,2,32,2.7,32,3.5v11c0,0.8,0.7,1.5,1.5,1.5h15c0.8,0,1.5-0.7,1.5-1.5V3.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Change Request',
                'M16.4,10h3.2a.77.77,0,0,0,.8-.7V6.8H31.6V9.2a.77.77,0,0,0,.7.8h3.3a.77.77,0,0,0,.8-.7V6.8A4.87,4.87,0,0,0,31.6,2H20.4a4.87,4.87,0,0,0-4.8,4.8V9.2a.79.79,0,0,0,.8.8Z x M45.2,14.8H6.8A4.87,4.87,0,0,0,2,19.6V45.2A4.87,4.87,0,0,0,6.8,50H45.2A4.87,4.87,0,0,0,50,45.2V19.6A4.87,4.87,0,0,0,45.2,14.8ZM23.4,32.9l-6.1,6.3a1.08,1.08,0,0,1-1.1,0L10,32.9c-.5-.4-.1-1.1.7-1.1h3.8A12,12,0,0,1,26.3,19.6h.4v4.6A8.19,8.19,0,0,0,19,31.8h3.6C23.4,31.8,23.8,32.5,23.4,32.9Zm19.4,0H39A12.16,12.16,0,0,1,26.9,45.1h-.3V40.5c4.6,0,7.8-3,7.8-7.6H30.7c-.8,0-1.1-.6-.7-1.1l6.2-6.3a1.08,1.08,0,0,1,1.1,0l6.2,6.3c.4.4,0,1.1-.7,1.1Z'
            }
        );
        svgs.add(
            new List<String>{
                'Chart',
                'M45.5,23.4L25,34.7c-1.4,0.7-3-0.3-3-1.8V8.4c0-1-1-1.8-1.9-1.5c-10,2.8-17.2,12.5-16,23.6c1.1,10.1,9.2,18.3,19.4,19.4C36.8,51.3,48,41,48,28c0-1.2-0.1-2.4-0.3-3.6C47.5,23.4,46.4,22.9,45.5,23.4z x M27.7,28l19.7-10.5c1.2-0.6,1.6-2.2,0.8-3.3C43.7,8,36.7,3.5,28.7,2.2C27.3,1.9,26,3,26,4.4V27C26,27.9,26.9,28.4,27.7,28z'
            }
        );
        svgs.add(
            new List<String>{
                'Chat',
                'M26,4C12.7,4,2.1,13.8,2.1,25.9c0,3.8,1.1,7.4,2.9,10.6c0.3,0.5,0.4,1.1,0.2,1.7l-3.1,8.5c-0.3,0.8,0.5,1.5,1.3,1.3l8.6-3.3c0.5-0.2,1.1-0.1,1.7,0.2c3.6,2,7.9,3.2,12.5,3.2C39.3,48,50,38.3,50,26.1C49.9,13.8,39.2,4,26,4z M14,30c-2.2,0-4-1.8-4-4s1.8-4,4-4s4,1.8,4,4S16.2,30,14,30z M26,30c-2.2,0-4-1.8-4-4s1.8-4,4-4s4,1.8,4,4S28.2,30,26,30z M38,30c-2.2,0-4-1.8-4-4s1.8-4,4-4s4,1.8,4,4S40.2,30,38,30z'
            }
        );
        svgs.add(
            new List<String>{
                'Check',
                'M19.1,42.5L2.6,25.9c-0.6-0.6-0.6-1.6,0-2.2l2.2-2.2c0.6-0.6,1.6-0.6,2.2,0L19.4,34c0.4,0.4,1.1,0.4,1.5,0L45.2,9.5c0.6-0.6,1.6-0.6,2.2,0l2.2,2.2c0.6,0.6,0.6,1.6,0,2.2L21.3,42.5C20.7,43.2,19.7,43.2,19.1,42.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Check In',
                'M26,2C15.5,2,7,10.5,7,21.1c0,13.2,13.6,25.3,17.8,28.5c0.7,0.6,1.7,0.6,2.5,0C31.5,46.3,45,34.3,45,21.1C45,10.5,36.5,2,26,2z M26,29c-4.4,0-8-3.6-8-8s3.6-8,8-8s8,3.6,8,8S30.4,29,26,29z'
            }
        );
        svgs.add(
            new List<String>{
                'Check Out',
                'M38.67,27.35A11.33,11.33,0,1,1,27.35,38.67h0A11.34,11.34,0,0,1,38.67,27.35ZM20.36,37.63a4,4,0,1,1-4,4v0A4,4,0,0,1,20.36,37.63ZM42.8,34.07l-6.06,6.79L34,38.09a.79.79,0,0,0-1.11,0l0,0-1.11,1.07a.7.7,0,0,0-.07,1l.07.08L35.6,44a1.62,1.62,0,0,0,1.14.48A1.47,1.47,0,0,0,37.87,44l7.19-7.87a.83.83,0,0,0,0-1l-1.12-1.05a.79.79,0,0,0-1.11,0ZM8.2,2a2.42,2.42,0,0,1,2.25,1.7h0l.62,2.16H46.36A1.5,1.5,0,0,1,47.9,7.31a1.24,1.24,0,0,1-.06.47h0L43.66,22.43a1.42,1.42,0,0,1-.52.82,16.42,16.42,0,0,0-4.47-.64,16,16,0,0,0-5.47,1H19.36a2.2,2.2,0,0,0-2.22,2.18,2.11,2.11,0,0,0,.13.75h0v.08a2.26,2.26,0,0,0,2.17,1.62h7.1a16,16,0,0,0-2.77,4.61H16a2.32,2.32,0,0,1-2.25-1.7h0L6.5,6.62H4.33A2.37,2.37,0,0,1,2,4.22V4.16A2.46,2.46,0,0,1,4.48,2H8.2Z'
            }
        );
        svgs.add(
            new List<String>{
                'Chevron Down',
                'M47.6,17.8L27.1,38.5c-0.6,0.6-1.6,0.6-2.2,0L4.4,17.8c-0.6-0.6-0.6-1.6,0-2.2l2.2-2.2c0.6-0.6,1.6-0.6,2.2,0l16.1,16.3c0.6,0.6,1.6,0.6,2.2,0l16.1-16.2c0.6-0.6,1.6-0.6,2.2,0l2.2,2.2C48.1,16.3,48.1,17.2,47.6,17.8z'
            }
        );
        svgs.add(
            new List<String>{
                'Chevron Left',
                'M34.2,47.7L13.4,27.2c-0.6-0.6-0.6-1.6,0-2.2L34.2,4.5c0.6-0.6,1.6-0.6,2.2,0l2.2,2.2c0.6,0.6,0.6,1.6,0,2.2L22.1,25c-0.6,0.6-0.6,1.6,0,2.2l16.3,16.1c0.6,0.6,0.6,1.6,0,2.2l-2.2,2.2C35.7,48.2,34.8,48.2,34.2,47.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Chevron Right',
                'M17.9,4.4l20.7,20.5c0.6,0.6,0.6,1.6,0,2.2L17.9,47.6c-0.6,0.6-1.6,0.6-2.2,0l-2.2-2.2c-0.6-0.6-0.6-1.6,0-2.2l16.3-16.1c0.6-0.6,0.6-1.6,0-2.2L13.6,8.8c-0.6-0.6-0.6-1.6,0-2.2l2.2-2.2C16.4,3.9,17.3,3.9,17.9,4.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Chevron Up',
                'M4.4,34.2l20.5-20.7c0.6-0.6,1.6-0.6,2.2,0l20.5,20.7c0.6,0.6,0.6,1.6,0,2.2l-2.2,2.2c-0.6,0.6-1.6,0.6-2.2,0L27.1,22.2c-0.6-0.6-1.6-0.6-2.2,0L8.8,38.5c-0.6,0.6-1.6,0.6-2.2,0l-2.2-2.2C3.9,35.7,3.9,34.8,4.4,34.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Clear',
                'M26,2C12.7,2,2,12.7,2,26s10.7,24,24,24s24-10.7,24-24S39.3,2,26,2z M30.9,26.8l7.8,7.8c0.4,0.4,0.4,1,0,1.4l-2.8,2.8c-0.4,0.4-1,0.4-1.4,0L26.7,31c-0.4-0.4-1-0.4-1.4,0l-7.8,7.8c-0.4,0.4-1,0.4-1.4,0L13.3,36c-0.4-0.4-0.4-1,0-1.4l7.8-7.8c0.4-0.4,0.4-1,0-1.4l-7.9-7.9c-0.4-0.4-0.4-1,0-1.4l2.8-2.8c0.4-0.4,1-0.4,1.4,0l7.9,7.9c0.4,0.4,1,0.4,1.4,0l7.8-7.8c0.4-0.4,1-0.4,1.4,0l2.8,2.8c0.4,0.4,0.4,1,0,1.4l-7.8,7.8C30.6,25.8,30.6,26.4,30.9,26.8z'
            }
        );
        svgs.add(
            new List<String>{
                'Clock',
                'M26,2C12.8,2,2,12.8,2,26s10.8,24,24,24s24-10.8,24-24S39.2,2,26,2z M26,44c-9.9,0-18-8.1-18-18S16.1,8,26,8s18,8.1,18,18S35.9,44,26,44z x M29.4,26.2c-0.3-0.3-0.4-0.7-0.4-1.1v-9.6c0-0.8-0.7-1.5-1.5-1.5h-3c-0.8,0-1.5,0.7-1.5,1.5v12.1c0,0.4,0.2,0.8,0.4,1.1l7.4,7.4c0.6,0.6,1.5,0.6,2.1,0l2.1-2.1c0.6-0.6,0.6-1.5,0-2.1L29.4,26.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Close',
                'M31,25.4L44,12.3c0.6-0.6,0.6-1.5,0-2.1L42,8.1c-0.6-0.6-1.5-0.6-2.1,0L26.8,21.2c-0.4,0.4-1,0.4-1.4,0L12.3,8c-0.6-0.6-1.5-0.6-2.1,0l-2.1,2.1c-0.6,0.6-0.6,1.5,0,2.1l13.1,13.1c0.4,0.4,0.4,1,0,1.4L8,39.9c-0.6,0.6-0.6,1.5,0,2.1l2.1,2.1c0.6,0.6,1.5,0.6,2.1,0L25.3,31c0.4-0.4,1-0.4,1.4,0l13.1,13.1c0.6,0.6,1.5,0.6,2.1,0l2.1-2.1c0.6-0.6,0.6-1.5,0-2.1L31,26.8C30.6,26.4,30.6,25.8,31,25.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Collapse All',
                'M48,9.5C48,8.7,47.3,8,46.5,8h-41C4.7,8,4,8.7,4,9.5v3C4,13.3,4.7,14,5.5,14h41c0.8,0,1.5-0.7,1.5-1.5V9.5z x M48,39.5c0-0.8-0.7-1.5-1.5-1.5h-41C4.7,38,4,38.7,4,39.5v3C4,43.3,4.7,44,5.5,44h41c0.8,0,1.5-0.7,1.5-1.5V39.5z x M34.5,29c0.8,0,1.5-0.7,1.5-1.5v-3c0-0.8-0.7-1.5-1.5-1.5h-17c-0.8,0-1.5,0.7-1.5,1.5v3c0,0.8,0.7,1.5,1.5,1.5H34.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Collection Variable',
                'M45,2H7C4.2,2,2,4.2,2,7V45c0,2.7,2.2,5,5,5H45c2.7,0,5-2.2,5-5V7C50,4.2,47.8,2,45,2z M42.6,41.4L42.6,41.4c-0.1,0.6-0.7,1.1-1.4,1.1h-31c-0.6,0-1.1-0.6-1.1-1.3V10.6c0-0.6,0.6-1.1,1.3-1.1h31c0.6,0,1.1,0.6,1.1,1.3V41.4z x M33,22.4c1,0,3.1-0.8,3.1-3.6c0-2.8-2-2.9-2.6-2.9c-1.2,0-2.4,0.9-3.5,2.7c-1.1,1.9-2.3,3.9-2.3,3.9l0,0c-0.3-1.3-0.5-2.4-0.6-2.9c-0.2-1.1-1.5-3.6-4.3-3.6c-2.7,0-5.2,1.6-5.2,1.6l0,0c-0.5,0.3-0.8,0.8-0.8,1.4c0,0.9,0.7,1.7,1.7,1.7c0.3,0,0.5-0.1,0.7-0.2l0,0c0,0,2.1-1.2,2.5,0c0.1,0.3,0.2,0.7,0.4,1.1c0.5,1.8,1,3.9,1.4,5.8l-1.8,2.6c0,0-2-0.7-3.1-0.7s-3.1,0.8-3.1,3.6s2,2.9,2.6,2.9c1.2,0,2.4-0.9,3.5-2.7c1.1-1.9,2.3-3.9,2.3-3.9c0.4,1.7,0.6,3.1,0.8,3.6c0.7,1.9,2.2,3.1,4.3,3.1c0,0,2.1,0,4.7-1.4c0.6-0.2,1-0.8,1-1.5c0-0.9-0.7-1.7-1.7-1.7c-0.3,0-0.5,0.1-0.7,0.2l0,0c0,0-1.8,1-2.4,0.2c-0.4-0.8-0.8-2-1.1-3.3c-0.3-1.2-0.6-2.7-0.8-4.1l1.8-2.6C30,21.7,32,22.4,33,22.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Collection',
                'm12 2.17h14v23.5l.31.46.57-.1 5.66-5.14.39-.12.42.11 5.25 5.12.6.1.28-.46v-23.64h3.28a6 6 0 0 1 3 1.12 5.22 5.22 0 0 1 1.57 2.74s0 37.48 0 39.43a4.2 4.2 0 0 1 -.88 3.15 4.58 4.58 0 0 1 -3.64 1.56h-30.49c-.24 0-1.52.27-3.38-1.54a5.28 5.28 0 0 1 -1.48-3.56v-1.29h-1.59a3.15 3.15 0 0 1 -3.19-3.34c.06-3 3.14-3 3.14-3h1.64v-8h-1.59a3.09 3.09 0 0 1 -3.19-3.19 3.24 3.24 0 0 1 3.19-3.34h1.59v-7.83s-1.2 0-1.59 0a3.11 3.11 0 0 1 -3.19-3.1 3.15 3.15 0 0 1 3.19-3.28h1.59v-1.9a4.78 4.78 0 0 1 1.19-2.92 5.14 5.14 0 0 1 3.35-1.54z'
            }
        );
        svgs.add(
            new List<String>{
                'Color Swatch',
                'M35.4350288,9.49390335 L42.5060967,16.5649712 L42.5077201,16.5633477 C44.0698172,18.1254449 44.0698172,20.6581048 42.5077201,22.220202 L42.5060957,22.2218254 L24,40.7034386 L24,15.2639687 L29.7768418,9.49256991 L29.7781746,9.49390397 C31.340487,7.93306359 33.8721188,7.93366021 35.4336954,9.49523678 L35.4350288,9.49390335 Z M50,36 L50,46 C50,48.209139 48.209139,50 46,50 L21,50 L39,32 L46,32 C48.209139,32 50,33.790861 50,36 Z M2.00011396,41.0457762 L2.00011879,41.0462543 C2.00003963,41.0310054 2,41.0155876 2,41 L2,6 C2,3.790861 3.790861,2 6,2 L16,2 C18.209139,2 20,3.790861 20,6 L20,41 C20,41.0155876 19.9999604,41.0310054 19.999886,41.0457762 C19.9752374,45.9952784 15.9552951,50 11,50 C6.04470488,50 2.0247626,45.9952784 2.00011396,41.0457762 Z M11,45 C13.209139,45 15,43.209139 15,41 C15,38.790861 13.209139,37 11,37 C8.790861,37 7,38.790861 7,41 C7,43.209139 8.790861,45 11,45 Z'
            }
        );
        svgs.add(
            new List<String>{
                'Comments',
                'M47.8,31c-0.1-0.4-0.1-0.8,0.1-1.2c1.3-2.3,2.1-4.9,2.1-7.7c0-8.8-7.6-16-17-16c-4.4,0-8.4,1.6-11.4,4.2C31.9,11.5,40,19.9,40,30.1c0,2.5-0.5,4.9-1.4,7.1c1.1-0.4,2.2-0.9,3.2-1.4c0.4-0.2,0.8-0.3,1.2-0.1l6.1,2.4c0.6,0.2,1.1-0.3,0.9-0.9L47.8,31z x M19,14.1c-9.4,0-17,7.2-17,16c0,2.8,0.8,5.4,2.1,7.7c0.2,0.4,0.3,0.8,0.1,1.2L2,45.1c-0.2,0.6,0.3,1.1,0.9,0.9L9,43.6c0.4-0.1,0.8-0.1,1.2,0.1c2.6,1.5,5.6,2.3,8.8,2.3c9.4,0,17-7.2,17-16C36,21.3,28.4,14.1,19,14.1z'
            }
        );
        svgs.add(
            new List<String>{
                'Company',
                'M21,4H7C5.3,4,4,5.3,4,7v40c0,0.5,0.5,1,1,1h4c0.6,0,1-0.4,1-1v-6c0-0.6,0.4-1,1-1h6c0.6,0,1,0.4,1,1v6c0,0.6,0.4,1,1,1h3c1.1,0,2-0.9,2-2V7C24,5.3,22.7,4,21,4z M12,35.5c0,0.3-0.2,0.5-0.5,0.5h-3C8.2,36,8,35.8,8,35.5v-5C8,30.2,8.2,30,8.5,30h3c0.3,0,0.5,0.2,0.5,0.5V35.5z M12,25.5c0,0.3-0.2,0.5-0.5,0.5h-3C8.2,26,8,25.8,8,25.5v-5C8,20.2,8.2,20,8.5,20h3c0.3,0,0.5,0.2,0.5,0.5V25.5z M12,15.5c0,0.3-0.2,0.5-0.5,0.5h-3C8.2,16,8,15.8,8,15.5v-5C8,10.2,8.2,10,8.5,10h3c0.3,0,0.5,0.2,0.5,0.5V15.5z M20,35.5c0,0.3-0.2,0.5-0.5,0.5h-3c-0.3,0-0.5-0.2-0.5-0.5v-5c0-0.3,0.2-0.5,0.5-0.5h3c0.3,0,0.5,0.2,0.5,0.5V35.5z M20,25.5c0,0.3-0.2,0.5-0.5,0.5h-3c-0.3,0-0.5-0.2-0.5-0.5v-5c0-0.3,0.2-0.5,0.5-0.5h3c0.3,0,0.5,0.2,0.5,0.5V25.5z M20,15.5c0,0.3-0.2,0.5-0.5,0.5h-3c-0.3,0-0.5-0.2-0.5-0.5v-5c0-0.3,0.2-0.5,0.5-0.5h3c0.3,0,0.5,0.2,0.5,0.5V15.5z x M45,14H31c-1.7,0-3,1.3-3,3v30c0,0.5,0.5,1,1,1h4c0.6,0,1-0.4,1-1v-6c0-0.6,0.4-1,1-1h6c0.6,0,1,0.4,1,1v6c0,0.6,0.4,1,1,1h3c1.1,0,2-0.9,2-2V17C48,15.3,46.7,14,45,14z M36,35.5c0,0.3-0.2,0.5-0.5,0.5h-3c-0.3,0-0.5-0.2-0.5-0.5v-5c0-0.3,0.2-0.5,0.5-0.5h3c0.3,0,0.5,0.2,0.5,0.5V35.5z M36,25.5c0,0.3-0.2,0.5-0.5,0.5h-3c-0.3,0-0.5-0.2-0.5-0.5v-5c0-0.3,0.2-0.5,0.5-0.5h3c0.3,0,0.5,0.2,0.5,0.5V25.5z M44,35.5c0,0.3-0.2,0.5-0.5,0.5h-3c-0.3,0-0.5-0.2-0.5-0.5v-5c0-0.3,0.2-0.5,0.5-0.5h3c0.3,0,0.5,0.2,0.5,0.5V35.5z M44,25.5c0,0.3-0.2,0.5-0.5,0.5h-3c-0.3,0-0.5-0.2-0.5-0.5v-5c0-0.3,0.2-0.5,0.5-0.5h3c0.3,0,0.5,0.2,0.5,0.5V25.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Component Customization',
                'M50,5.4C50,2,47.2,2,47.2,2H4.9C4.4,2.1,2,2.3,2,5v14.2C2.1,19.8,2.6,22,5,22h42.2c3.1,0,2.8-2.7,2.8-2.7V5.4z x M49.1,35.3c-0.6-0.1-1.2-0.1-1.8-0.2c-0.1,0-0.2-0.1-0.2-0.2c-0.2-0.7-0.6-1.4-0.8-1.9c0-0.1,0-0.2,0-0.3c0.3-0.5,0.8-1,1.1-1.5c0.2-0.3,0.2-0.7-0.1-1c-0.7-0.7-1.4-1.4-2-2C45.2,28.1,45,28,44.8,28c-0.1,0-0.3,0.1-0.5,0.2c-0.5,0.3-1,0.8-1.5,1.1c-0.1,0-0.1,0.1-0.1,0.1h-0.1c-0.7-0.2-1.2-0.6-1.9-0.8c-0.1,0-0.2-0.1-0.2-0.2c-0.1-0.6-0.1-1.1-0.2-1.7c0-0.3-0.1-0.6-0.5-0.8c-0.1-0.1-0.2-0.1-0.2-0.1c-1,0-1.9,0-2.9,0c-0.2,0-0.3,0-0.5,0.1c-0.2,0.2-0.5,0.5-0.5,0.8c0,0.6-0.1,1.1-0.2,1.7c0,0.1-0.1,0.2-0.2,0.2c-0.7,0.2-1.2,0.6-1.9,0.8h-0.1c-0.1,0-0.1,0-0.2-0.1c-0.5-0.3-0.9-0.8-1.5-1.1c-0.1-0.1-0.2-0.2-0.5-0.2s-0.3,0.1-0.6,0.2c-0.7,0.7-1.4,1.4-2,2c-0.3,0.3-0.3,0.7-0.1,1c0.3,0.5,0.8,0.9,1.1,1.5c0.1,0.1,0.1,0.2,0,0.3c-0.2,0.7-0.6,1.2-0.8,1.9c0,0.1-0.1,0.2-0.2,0.2c-0.6,0.1-1.1,0.1-1.7,0.2c-0.3,0-0.7,0.2-0.8,0.6c0,1.1,0,2.3,0,3.4c0.2,0.3,0.5,0.5,0.8,0.6c0.6,0,1.1,0.1,1.7,0.2c0.1,0,0.2,0.1,0.2,0.2c0.2,0.7,0.6,1.2,0.8,1.9c0,0.1,0.1,0.2,0,0.3c-0.3,0.5-0.8,1-1.1,1.5c-0.2,0.3-0.2,0.7,0.1,1c0.7,0.7,1.4,1.4,2,2c0.2,0.2,0.3,0.2,0.6,0.2c0.1,0,0.3-0.1,0.5-0.2c0.5-0.3,0.9-0.8,1.5-1.1c0.1,0,0.1-0.1,0.2-0.1h0.1c0.7,0.2,1.2,0.6,1.9,0.8c0.1,0,0.2,0.1,0.2,0.2c0.1,0.6,0.1,1.2,0.2,1.8c0,0.5,0.3,0.7,0.8,0.7s1,0,1.5,0s0.9,0,1.4,0s0.7-0.2,0.8-0.7c0.1-0.6,0.1-1.2,0.2-1.8c0-0.1,0.1-0.2,0.2-0.2c0.7-0.2,1.4-0.6,1.9-0.8h0.1c0,0,0.1,0,0.1,0.1c0.5,0.3,1,0.8,1.5,1.1c0.1,0.1,0.3,0.2,0.5,0.2s0.3-0.1,0.6-0.2c0.7-0.7,1.4-1.4,2-2c0.3-0.3,0.3-0.7,0.1-1c-0.3-0.5-0.8-0.9-1.1-1.5c-0.1-0.1-0.1-0.2,0-0.3c0.2-0.7,0.6-1.2,0.8-1.9c0-0.1,0.1-0.2,0.2-0.2c0.6-0.1,1.2-0.1,1.8-0.2c0.5,0,0.7-0.3,0.7-0.8c0-0.9,0-1.9,0-2.8C49.8,35.6,49.6,35.4,49.1,35.3z M38,42.1L38,42.1L38,42.1c-2.6,0-4.5-2-4.5-4.5s2-4.5,4.5-4.5s4.5,2,4.5,4.5C42.4,40,40.4,42.1,38,42.1z x M23.4,27.8c-0.1-1.6-1.5-1.8-1.9-1.8H3.8C3.3,26,2,26.2,2,28v20.6C2.1,49.1,2.4,50,4,50h17.5c2,0,2-2.3,2-2.3c0-0.8,0-1.6,0-2.4c0-1,0.2-2.1-0.4-3.1c-0.1-0.2-0.2-0.3-0.3-0.5s-0.2-0.3-0.3-0.5c-0.6-0.9-0.5-2-0.5-3.1c0-1,0-2.1,0.5-3c0.2-0.4,0.5-0.8,0.7-1.2c0.4-0.6,0.4-1.4,0.4-2.1L23.4,27.8z'
            }
        );
        svgs.add(
            new List<String>{
                'Connected Apps',
                'M23.8,31.2L20,48.8c-0.2,1,1.1,1.7,1.7,0.9l21-26C43.3,23,42.8,22,42,22H30.8c-0.8,0-1.3-0.9-0.9-1.5l9.9-16.2c0.6-1-0.1-2.3-1.3-2.3H20.8c-1.1,0-2,0.7-2.4,1.7L10.1,28c-0.3,1,0.4,2,1.4,2h11.4C23.5,30,24,30.6,23.8,31.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Constant',
                'M49.1,7.7c-0.3-0.3-0.6-0.4-1-0.4l0,0c-3.8-0.2-7.7,0.1-11.5,0.2L23.1,7.5c-4.1,0-7.4,0.9-10.5,3.7c-2,1.8-3.9,4.4-5.4,6.7C7.1,18.2,7,18.4,7,18.8c0,0.8,0.7,1.5,1.5,1.5c0.9,0,1.1-0.6,1.5-1.2c0.4-0.7,0.9-1.3,1.5-1.8c2.1-1.9,4.9-3,7.7-2.7c-2.4,6.6-5.7,14.2-10.5,19.4c-2,2.2-5.4,4.4-6.1,7.4c-0.8,3.1,2.4,3.9,4.7,3c3-1.2,4.9-4.3,6.4-7c1.9-3.3,3.6-6.8,5-10.3c1.5-3.5,2.9-6.9,4.4-10.4c0.9-2.1,1.1-2.1,3.3-2.1h5.9c-2.2,4.8-4.3,9.7-6.2,14.6c-1.5,3.7-4.2,9.2-2.3,13.2c1.9,4,7.2,2.5,10.1,0.5c2.9-2.1,4.9-5.4,6.5-8.6c0.3-0.6,0.6-1.2,0.4-1.9c-0.2-0.6-0.8-0.9-1.4-0.9c-1.4,0-1.6,1.6-2.1,2.6c-0.8,1.7-2.6,3.2-4.5,2.9c-4.4-0.6-0.5-8.6,0.3-10.7c0.8-2.2,1.7-4.4,2.7-6.5c0.5-1.2,1-2.5,1.7-3.7c0.8-1.5,0.8-1.5,2.6-1.6c1.5-0.1,5.9,0.7,7.2-0.1c1.1-0.7,1.7-3.3,2.2-5.2l0,0C49.6,8.6,49.4,8.1,49.1,7.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Contact Request',
                'M25.4,27c-0.6,0.2-0.9,0.9-0.4,1.4l4.4,4.5c0.5,0.5,0.5,1.2,0,1.7l-1.7,1.7c-0.5,0.5-1.2,0.5-1.7,0L15.3,25.5c-0.5-0.5-0.5-1.2,0-1.7L26,13.1c0.5-0.5,1.2-0.5,1.7,0l1.7,1.7c0.5,0.5,0.5,1.2,0,1.7l-4.5,4.5c-0.5,0.5,0.4,1.4,0.4,1.4c10.2,0.3,18.1,7,20.5,16.1C48.4,34.9,50,30.6,50,26C49.9,13.7,39.2,4,26,4C12.8,4,2.2,13.8,2.2,25.8c0,3.8,1.1,7.4,2.9,10.6c0.3,0.5,0.4,1.1,0.2,1.7l-3.1,8.5c-0.3,0.8,0.5,1.5,1.3,1.3l8.7-3.3c0.5-0.2,1.1-0.1,1.7,0.2c3.6,2,7.9,3.2,12.5,3.2c5.9-0.1,11.4-2.1,15.5-5.5C40.8,34,33.9,27.4,25.4,27z'
            }
        );
        svgs.add(
            new List<String>{
                'Contract',
                'M29.6,24H45c1,0,1.3-1.1,0.5-1.9l-4.9-5l9-9.1c0.5-0.5,0.5-1.4,0-1.9l-3.7-3.7C45.4,2,44.6,2,44,2.5l-9,9l-5.1-4.9C29.1,5.8,28,6.1,28,7.1v15.4C28,23.2,28.9,24,29.6,24z x M22.4,28H7c-1,0-1.3,1.1-0.5,1.9l4.9,5l-9,9.1c-0.5,0.5-0.5,1.4,0,1.9l3.7,3.7c0.5,0.5,1.3,0.5,1.9,0l9.1-9.1l5.1,4.9C22.9,46.3,24,46,24,45V29.7C24,29,23.1,28,22.4,28z x M28,29.6V45c0,1,1.1,1.3,1.9,0.5l5-4.9l9.1,9c0.5,0.5,1.4,0.5,1.9,0l3.7-3.7c0.4-0.5,0.4-1.3-0.1-1.9l-9-9l4.9-5.1c0.8-0.8,0.5-1.9-0.5-1.9H29.5C28.8,28,28,28.9,28,29.6z x M24,22.4V7c0-1-1.1-1.3-1.9-0.5l-5,4.9L8,2.4c-0.5-0.5-1.4-0.5-1.9,0L2.4,6.1C1.9,6.6,1.9,7.4,2.4,8l9.1,9.1l-4.9,5.1C5.7,22.9,6,24,7,24h15.3C23,24,24,23.1,24,22.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Contract Alt',
                'M29.6,23.9H45c1,0,1.3-1.1,0.5-1.9l-4.9-5l9-9.1c0.5-0.5,0.5-1.4,0-1.9l-3.7-3.7c-0.5-0.4-1.3-0.4-1.9,0.1l-9,9l-5.1-4.9C29.1,5.7,28,6,28,7v15.4C28,23.1,28.9,23.9,29.6,23.9z x M22.4,28H7c-1,0-1.3,1.1-0.5,1.9l4.9,5l-9,9.1c-0.5,0.5-0.5,1.4,0,1.9l3.7,3.7c0.5,0.5,1.3,0.5,1.9,0l9.1-9.1l5.1,4.9C22.9,46.3,24,46,24,45V29.7C24,29,23.1,28,22.4,28z'
            }
        );
        svgs.add(
            new List<String>{
                'Copy',
                'M44,2H18c-2.2,0-4,1.8-4,4v2h24c2.2,0,4,1.8,4,4v28h2c2.2,0,4-1.8,4-4V6C48,3.8,46.2,2,44,2z x M38,16c0-2.2-1.8-4-4-4H8c-2.2,0-4,1.8-4,4v30c0,2.2,1.8,4,4,4h26c2.2,0,4-1.8,4-4V16z M20,23c0,0.6-0.4,1-1,1h-8c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h8c0.6,0,1,0.4,1,1V23z M28,39c0,0.6-0.4,1-1,1H11c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h16c0.6,0,1,0.4,1,1V39z M32,31c0,0.6-0.4,1-1,1H11c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h20c0.6,0,1,0.4,1,1V31z'
            }
        );
        svgs.add(
            new List<String>{
                'Copy To Clipboard',
                'M17.4,11.6h17.3c0.9,0,1.6-0.7,1.6-1.6V6.8c0-2.6-2.1-4.8-4.7-4.8h-11c-2.6,0-4.7,2.2-4.7,4.8V10C15.8,10.9,16.5,11.6,17.4,11.6z x M43.3,6h-1.6c-0.5,0-0.8,0.3-0.8,0.8V10c0,3.5-2.8,6.4-6.3,6.4H17.4c-3.5,0-6.3-2.9-6.3-6.4V6.8c0-0.5-0.3-0.8-0.8-0.8H8.7C6.1,6,4,8.2,4,10.8v34.4C4,47.8,6.1,50,8.7,50h34.6c2.6,0,4.7-2.2,4.7-4.8V10.8C48,8.2,45.9,6,43.3,6z'
            }
        );
        svgs.add(
            new List<String>{
                'Coupon Codes',
                'M50,19.6V12.4A2.39,2.39,0,0,0,47.6,10H16.4v1.6H14.8V10H4.4A2.39,2.39,0,0,0,2,12.4v7.2A6.4,6.4,0,0,1,2,32.4H2v7.2A2.39,2.39,0,0,0,4.4,42H14.8V40.4h1.6V42H47.6A2.39,2.39,0,0,0,50,39.6V32.4a6.4,6.4,0,0,1,0-12.8ZM16.4,37.2H14.8V34h1.6Zm0-6.4H14.8V27.6h1.6Zm0-6.4H14.8V21.2h1.6Zm0-6.4H14.8V14.8h1.6ZM26.8,28.9,25.31,30l-1.62-2.2L22,30,20.52,28.9l1.63-2.33-2.48-.76.55-1.74,2.44.79V22h2v2.82l2.44-.79.55,1.74-2.49.76Zm12.67,0L38,30l-1.62-2.2L34.68,30,33.19,28.9l1.63-2.33-2.49-.76.55-1.74,2.44.79V22h2v2.82l2.44-.79.55,1.74-2.48.76Z'
            }
        );
        svgs.add(
            new List<String>{
                'Cross Filter',
                'M35,9c-1.7,0-3.3,0.2-4.8,0.7c1.8,1.5,3.4,3.3,4.7,5.3H35c6.1,0,11,4.9,11,11s-4.9,11-11,11c-1.5,0-3-0.3-4.3-0.9c0.8-1.1,1.5-2.3,2-3.5c0.2-0.5,0.4-0.9,0.5-1.4c0.5-1.6,0.8-3.4,0.8-5.2c0-9.4-7.6-17-17-17S0,16.6,0,26s7.6,17,17,17c1.7,0,3.3-0.2,4.8-0.7C20,40.8,18.4,39,17.1,37H17c-6.1,0-11-4.9-11-11s4.9-11,11-11c1.5,0,3,0.3,4.4,0.9C19.3,18.7,18,22.2,18,26c0,9.4,7.6,17,17,17s17-7.6,17-17S44.4,9,35,9z'
            }
        );
        svgs.add(
            new List<String>{
                'Currency Input',
                'M35.9,37.6c2.7-4.5,2.2-10.4-1.7-14.3c-4.5-4.5-11.9-4.5-16.4,0c-3.9,3.9-4.4,9.8-1.7,14.3H35.9z x M49.5,7.2v37.6c0,2.6-2.1,4.7-4.7,4.7H7.2c-2.6,0-4.7-2.1-4.7-4.7V7.2c0-2.6,2.1-4.7,4.7-4.7h37.6C47.4,2.5,49.5,4.6,49.5,7.2z M10.3,43.2h31.3c0.9,0,1.6-0.7,1.6-1.6V10.3c0-0.9-0.7-1.6-1.6-1.6H10.3c-0.9,0-1.6,0.7-1.6,1.6v31.3C8.8,42.5,9.5,43.2,10.3,43.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Custom Apps',
                'M49.4,12.2c-0.2-0.6-0.9-0.7-1.4-0.3L39.9,20c-0.6,0.6-1.6,0.6-2.2,0L32,14.3c-0.6-0.6-0.6-1.6,0-2.2L40.2,4c0.4-0.4,0.2-1.1-0.3-1.4C38.5,2.2,37,2,35.6,2c-8.5,0-15.3,7.3-14.3,16c0.2,1.4,0.5,2.6,1,3.8L3.6,40.4c-2.2,2.2-2.2,5.8,0,7.9c1.1,1.1,2.6,1.7,4,1.7s2.9-0.6,4-1.7l18.6-18.6c1.2,0.5,2.5,0.8,3.8,1c8.7,1,16-5.8,16-14.3C50,14.9,49.8,13.5,49.4,12.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Cuts',
                'M40.7,31.4c-1.7-0.4-3.3-0.2-4.7,0.3L13.9,2.4c-0.3-0.4-1-0.5-1.4-0.2l-0.8,0.6C10,4.1,9.7,6.6,11,8.4l10.6,14c0.4,0.5,0.4,1.3,0,1.8l-5.7,7.5c-1.4-0.5-3.1-0.6-4.7-0.3c-3.7,0.8-6.6,3.8-7.1,7.5c-0.8,5.9,4.4,11,10.5,10c3.6-0.6,6.5-3.4,7.3-6.9c0.5-2.5,0-4.8-1.2-6.5l4.2-5.6c0.6-0.8,1.8-0.8,2.4,0l4.2,5.6c-1.2,1.9-1.7,4.2-1.2,6.5c0.7,3.6,3.7,6.3,7.3,6.9c6.1,1,11.3-4.1,10.5-10C47.2,35.1,44.3,32.1,40.7,31.4z M12.9,43.1c-1.7,0-3-1.3-3-3c0-1.7,1.3-3,3-3s3,1.3,3,3C15.9,41.8,14.6,43.1,12.9,43.1z M38.9,43.1c-1.7,0-3-1.3-3-3c0-1.7,1.3-3,3-3c1.7,0,3,1.3,3,3C41.8,41.8,40.5,43.1,38.9,43.1z x M31.3,18.9c0.4,0.5,1.2,0.5,1.6,0l8-10.5c1.1-1.5,1-3.5-0.1-4.9l0.1-0.1l-0.1,0.1c-0.2-0.3-1.5-1.3-1.5-1.3c-0.4-0.3-1.1-0.2-1.4,0.2l-8.8,11.7c-0.4,0.5-0.4,1.3,0,1.8L31.3,18.9z'
            }
        );
        svgs.add(
            new List<String>{
                'Dash',
                'M50,27.5c0,0.8-0.7,1.5-1.5,1.5h-45C2.7,29,2,28.3,2,27.5v-3C2,23.7,2.7,23,3.5,23h45c0.8,0,1.5,0.7,1.5,1.5V27.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Data Mapping',
                'M44.5,21a5.5,5.5,0,1,1-4.9,8h-.91c-5.39.06-7.29,1.7-10.31,7.34l-.17.33-.2.38c-1.8,3.37-2.82,4.9-4.66,6.52C20.76,45.84,17.42,47,13,47h-.6a5.5,5.5,0,1,1,0-5h.91c5.49-.06,7.36-1.76,10.48-7.67h0L24,34a27.18,27.18,0,0,1,3.11-5H12.4a5.5,5.5,0,1,1,0-5H39.6a5.53,5.53,0,0,1,4.68-3Zm0-19a5.5,5.5,0,1,1-4.9,8H12.4a5.5,5.5,0,1,1,0-5H39.6A5.5,5.5,0,0,1,44.5,2Z'
            }
        );
        svgs.add(
            new List<String>{
                'Database',
                'M45.4,9c0-3.8-8.7-6.9-19.4-6.9S6.6,5.2,6.6,9v2.4c0,3.8,8.7,6.9,19.4,6.9s19.4-3.1,19.4-6.9V9z x M6.6,17c0,3,8.7,5.4,19.4,5.4S45.4,20,45.4,17v4.9c0,3.8-8.7,6.9-19.4,6.9S6.6,25.7,6.6,21.9V17z x M6.6,17c0,3,8.7,5.4,19.4,5.4S45.4,20,45.4,17v4.9c0,3.8-8.7,6.9-19.4,6.9S6.6,25.7,6.6,21.9V17z x M6.6,27.5c0,3,8.7,5.4,19.4,5.4s19.4-2.4,19.4-5.4v4.9c0,3.8-8.7,6.9-19.4,6.9s-19.4-3-19.4-6.8V27.5z x M6.6,38.1c0,3,8.7,5.4,19.4,5.4s19.4-2.4,19.4-5.4V43c0,3.8-8.7,6.9-19.4,6.9S6.6,46.8,6.6,43V38.1z'
            }
        );
        svgs.add(
            new List<String>{
                'Data.com',
                'M42.5,49.1h-5.3c-0.3-1.9-0.5-3.6-0.5-5.1h-0.1c-2.5,4-6.6,6-12.2,6c-4.8,0-8.5-1.6-11.1-4.9c-2.6-3.3-3.8-7.6-3.8-12.8c0-3.4,0.6-6.4,1.9-9.1s3.1-4.9,5.5-6.4c2.4-1.6,5.2-2.4,8.4-2.4c4.6,0,8.3,1.5,11.1,4.4V2.1H42v39.6C42,44.1,42.2,46.6,42.5,49.1z M36.3,34.6V23.9c-1.3-1.7-2.8-2.9-4.5-3.8c-1.7-0.8-3.6-1.2-5.8-1.2c-3.3,0-5.9,1.2-7.8,3.7c-1.9,2.5-2.8,5.7-2.8,9.6c0,4.1,0.9,7.3,2.7,9.7c1.8,2.4,4.4,3.6,7.6,3.6c3.2,0,5.8-1,7.7-3.1C35.4,40.4,36.3,37.8,36.3,34.6z'
            }
        );
        svgs.add(
            new List<String>{
                'Date Input',
                'M46.3,19.7H5.7c-0.9,0-1.6,0.7-1.6,1.6v23.5c0,2.6,2.1,4.7,4.7,4.7h34.4c2.6,0,4.7-2.1,4.7-4.7V21.3C47.9,20.4,47.2,19.7,46.3,19.7z M18.2,41.6c0,0.9-0.7,1.6-1.6,1.6h-3.1c-0.9,0-1.6-0.7-1.6-1.6v-3.1c0-0.9,0.7-1.6,1.6-1.6h3.1c0.9,0,1.6,0.7,1.6,1.6V41.6z M29.1,41.6c0,0.9-0.7,1.6-1.6,1.6h-3.1c-0.9,0-1.6-0.7-1.6-1.6v-3.1c0-0.9,0.7-1.6,1.6-1.6h3.1c0.9,0,1.6,0.7,1.6,1.6V41.6z M29.1,30.7c0,0.9-0.7,1.6-1.6,1.6h-3.1c-0.9,0-1.6-0.7-1.6-1.6v-3.1c0-0.9,0.7-1.6,1.6-1.6h3.1c0.9,0,1.6,0.7,1.6,1.6V30.7z M40.1,30.7c0,0.9-0.7,1.6-1.6,1.6h-3.1c-0.9,0-1.6-0.7-1.6-1.6v-3.1c0-0.9,0.7-1.6,1.6-1.6h3.1c0.9,0,1.6,0.7,1.6,1.6V30.7z M43.2,7.2h-3.9V5.6c0-1.7-1.4-3.1-3.1-3.1c-1.7,0-3.1,1.4-3.1,3.1v1.6H19V5.6c0-1.7-1.4-3.1-3.1-3.1s-3.1,1.4-3.1,3.1v1.6H8.8c-2.6,0-4.7,2.1-4.7,4.7v1.6c0,0.9,0.7,1.6,1.6,1.6h40.7c0.9,0,1.6-0.7,1.6-1.6v-1.6C47.9,9.3,45.8,7.2,43.2,7.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Date Time',
                'M43.6,6.8h-4V5.2c0-1.8-1.4-3.2-3.2-3.2c-1.8,0-3.2,1.4-3.2,3.2v1.6H18.8V5.2c0-1.8-1.4-3.2-3.2-3.2s-3.2,1.4-3.2,3.2v1.6h-4c-2.6,0-4.8,2.2-4.8,4.8v1.6c0,0.9,0.7,1.6,1.6,1.6h41.6c0.9,0,1.6-0.7,1.6-1.6v-1.6C48.4,9,46.2,6.8,43.6,6.8z x M46.8,19.6H5.2c-0.9,0-1.6,0.7-1.6,1.6v24c0,2.6,2.2,4.8,4.8,4.8h35.2c2.6,0,4.8-2.2,4.8-4.8v-24C48.4,20.3,47.7,19.6,46.8,19.6z M26,46.7c-6.6,0-11.9-5.4-11.9-11.9c0-6.6,5.4-11.9,11.9-11.9s11.9,5.4,11.9,11.9C37.9,41.4,32.6,46.7,26,46.7z x M27.2,34.3v-5.1c0-0.4-0.4-0.8-0.8-0.8h-0.8c-0.4,0-0.8,0.4-0.8,0.8v5.6c0,0.3,0.1,0.6,0.4,0.8l3.8,3.8c0.3,0.3,0.8,0.3,1.1,0l0.6-0.6c0.3-0.3,0.3-0.8,0-1.1L27.2,34.3z'
            }
        );
        svgs.add(
            new List<String>{
                'Day View',
                'M44,7h-4h-1V5c0-1.6-1.3-3-3-3l0,0c-1.6,0-3,1.3-3,3v2H19V5c0-1.6-1.3-3-3-3l0,0c-1.6,0-3,1.3-3,3v2h-1H8c-2.2,0-4,1.8-4,4v2.5C4,14.3,4.7,15,5.5,15h41c0.8,0,1.5-0.7,1.5-1.5V11C48,8.8,46.2,7,44,7z x M46.5,20h-41C4.7,20,4,20.7,4,21.5V46c0,2.2,1.8,4,4,4h36c2.2,0,4-1.8,4-4V21.5C48,20.7,47.3,20,46.5,20z M29,42v0.2c0,0.8-1,1.8-2,1.8c-1,0-2-1-2-2V32l-1.5,1.6c-0.3,0.3-0.6,0.4-1,0.4c-0.8,0-1.5-0.7-1.5-1.5c0-0.4,0.2-0.8,0.5-1.1l3.9-3.9c0.4-0.4,0.9-0.6,1.5-0.6c1.1,0,2.1,0.9,2.1,2V42z'
            }
        );
        svgs.add(
            new List<String>{
                'Delete',
                'M45.5,10H33V6c0-2.2-1.8-4-4-4h-6c-2.2,0-4,1.8-4,4v4H6.5C5.7,10,5,10.7,5,11.5v3C5,15.3,5.7,16,6.5,16h39c0.8,0,1.5-0.7,1.5-1.5v-3C47,10.7,46.3,10,45.5,10z M23,7c0-0.6,0.4-1,1-1h4c0.6,0,1,0.4,1,1v3h-6V7z x M41.5,20h-31C9.7,20,9,20.7,9,21.5V45c0,2.8,2.2,5,5,5h24c2.8,0,5-2.2,5-5V21.5C43,20.7,42.3,20,41.5,20z M23,42c0,0.6-0.4,1-1,1h-2c-0.6,0-1-0.4-1-1V28c0-0.6,0.4-1,1-1h2c0.6,0,1,0.4,1,1V42z M33,42c0,0.6-0.4,1-1,1h-2c-0.6,0-1-0.4-1-1V28c0-0.6,0.4-1,1-1h2c0.6,0,1,0.4,1,1V42z'
            }
        );
        svgs.add(
            new List<String>{
                'Deprecate',
                'M48,7H4C2.9,7,2,7.9,2,9v26c0,1.1,0.9,2,2,2h16.2c1,5.7,5.9,10,11.8,10s10.9-4.3,11.8-10H48c1.1,0,2-0.9,2-2V9C50,7.9,49.1,7,48,7z M39.4,39.6l-2.8,2.8L32,37.8l-4.6,4.6l-2.8-2.8l4.6-4.6l-4.6-4.6l2.8-2.8l4.6,4.6l4.6-4.6l2.8,2.8L34.8,35L39.4,39.6z M46,33h-2.2c-1-5.7-5.9-10-11.8-10s-10.9,4.3-11.8,10H6V11h40V33z'
            }
        );
        svgs.add(
            new List<String>{
                'Description',
                'M44,4H8C5.8,4,4,5.8,4,8v36c0,2.2,1.8,4,4,4h36c2.2,0,4-1.8,4-4V8C48,5.8,46.2,4,44,4z M12,14c0-0.6,0.4-1,1-1h10c0.6,0,1,0.4,1,1v10c0,0.6-0.4,1-1,1H13c-0.6,0-1-0.4-1-1V14z M36,40c0,0.6-0.4,1-1,1H13c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h22c0.6,0,1,0.4,1,1V40z M40,32c0,0.6-0.4,1-1,1H13c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h26c0.6,0,1,0.4,1,1V32z M40,24c0,0.6-0.4,1-1,1H29c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h10c0.6,0,1,0.4,1,1V24z M40,16c0,0.6-0.4,1-1,1H29c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h10c0.6,0,1,0.4,1,1V16z'
            }
        );
        svgs.add(
            new List<String>{
                'Desktop Console',
                'M33,44h-3c-0.6,0-1-0.4-1-1v-2c0-0.6-0.4-1-1-1h-4c-0.6,0-1,0.4-1,1v2c0,0.6-0.4,1-1,1h-3c-2.2,0-4,1.8-4,4v0.5c0,0.8,0.7,1.5,1.5,1.5h19c0.8,0,1.5-0.7,1.5-1.5V48C37,45.8,35.2,44,33,44z x M46,2H6C3.8,2,2,3.8,2,6v26c0,2.2,1.8,4,4,4h40c2.2,0,4-1.8,4-4V6C50,3.8,48.2,2,46,2z M8,28.5v-19C8,8.7,8.7,8,9.5,8h6v22h-6C8.7,30,8,29.3,8,28.5z M44,28.5c0,0.8-0.7,1.5-1.5,1.5h-21V8h21C43.3,8,44,8.7,44,9.5V28.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Desktop',
                'M50,6c0-2.2-1.8-4-4-4H6C3.8,2,2,3.8,2,6v26c0,2.2,1.8,4,4,4h40c2.2,0,4-1.8,4-4V6z M44,28.5c0,0.8-0.7,1.5-1.5,1.5h-33C8.7,30,8,29.3,8,28.5v-19C8,8.7,8.7,8,9.5,8h33C43.3,8,44,8.7,44,9.5V28.5z x M33,44h-3c-0.6,0-1-0.4-1-1v-2c0-0.6-0.4-1-1-1h-4c-0.6,0-1,0.4-1,1v2c0,0.6-0.4,1-1,1h-3c-2.2,0-4,1.8-4,4v0.5c0,0.8,0.7,1.5,1.5,1.5h8h3h8c0.8,0,1.5-0.7,1.5-1.5V48C37,45.8,35.2,44,33,44z'
            }
        );
        svgs.add(
            new List<String>{
                'Dialing',
                'M48.5,37.9L42.4,33c-1.4-1.1-3.4-1.2-4.8-0.1l-5.2,3.8c-0.6,0.5-1.5,0.4-2.1-0.2l-7.8-7l-7-7.8c-0.6-0.6-0.6-1.4-0.2-2.1l3.8-5.2c1.1-1.4,1-3.4-0.1-4.8l-4.9-6.1c-1.5-1.8-4.2-2-5.9-0.3L3,8.4c-0.8,0.8-1.2,1.9-1.2,3c0.5,10.2,5.1,19.9,11.9,26.7S30.2,49.5,40.4,50c1.1,0.1,2.2-0.4,3-1.2l5.2-5.2C50.5,42.1,50.4,39.3,48.5,37.9z x M42,24.5c1.2-1.7,1.9-3.8,1.9-6C43.8,12.7,39.1,8,33.3,8c-2.2,0-4.3,0.7-6,1.9L23,5.5C25.8,3.3,29.4,2,33.3,2c9.1,0,16.6,7.4,16.6,16.6c0,3.9-1.3,7.5-3.6,10.3L42,24.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Discounts',
                'M29,34.21a.33.33,0,0,1-.25.16H27.55a.32.32,0,0,1-.28-.16.31.31,0,0,1,0-.32l8.81-16.14a.37.37,0,0,1,.26-.16h1.31a.33.33,0,0,1,.16.43h0Z x M37.88,28.35a1.77,1.77,0,1,1-1.76,1.76,1.76,1.76,0,0,1,1.76-1.76m0-2.35A4.12,4.12,0,1,0,42,30.11,4.11,4.11,0,0,0,37.88,26Z x M49.11,23.69l-1.9-2.27a4.05,4.05,0,0,1-1-2.35l-.21-2.94a3.72,3.72,0,0,0-3.41-3.46l-2.54-.21a5.42,5.42,0,0,1-3.05-1.29L35.13,9.52a3.73,3.73,0,0,0-4.86,0l-2.09,1.76a4.76,4.76,0,0,1-2.76,1.12l-2.71.19A3.72,3.72,0,0,0,19.24,16L19,18.42a5.38,5.38,0,0,1-1.14,2.85v3.66L19.51,23a7.65,7.65,0,0,0,1.87-4.42l.2-2.45a1.38,1.38,0,0,1,1.3-1.26l2.7-.19A7.11,7.11,0,0,0,29.7,13l2.08-1.76a1.37,1.37,0,0,1,.89-.33,1.41,1.41,0,0,1,.93.36L35.52,13a7.63,7.63,0,0,0,4.39,1.85l2.53.21A1.36,1.36,0,0,1,43.7,16.3l.21,2.94a6.43,6.43,0,0,0,1.5,3.69l1.91,2.29a1.38,1.38,0,0,1,0,1.81l-1.56,1.78a8.18,8.18,0,0,0-2,4.69l-.22,2.37a1.37,1.37,0,0,1-1.29,1.26l-2.88.2a6.6,6.6,0,0,0-3.8,1.54l-2.22,1.85a1.39,1.39,0,0,1-.9.33,1.42,1.42,0,0,1-.92-.35L29.61,39a7.64,7.64,0,0,0-4.39-1.86L22.67,37a1.36,1.36,0,0,1-1.24-1.16l-1.78,1.78a3.72,3.72,0,0,0,2.83,1.73l2.54.22a5.36,5.36,0,0,1,3,1.29L30,42.48a3.76,3.76,0,0,0,2.46.92,3.72,3.72,0,0,0,2.41-.88l2.22-1.85a4.26,4.26,0,0,1,2.46-1l2.88-.21a3.73,3.73,0,0,0,3.47-3.41l.21-2.35a5.91,5.91,0,0,1,1.43-3.36l1.55-1.77A3.74,3.74,0,0,0,49.11,23.69Z x M11.43,12.13V31.64a.59.59,0,0,1-1,.41L4.79,26.41a.85.85,0,0,0-1.23,0L2.26,27.7a.86.86,0,0,0,0,1.24L12.61,39.22a.84.84,0,0,0,1.23,0L24.13,28.94a.86.86,0,0,0,0-1.24l-1.24-1.23a.85.85,0,0,0-1.23,0L16,32.11A.63.63,0,0,1,15,31.7V12.19a.85.85,0,0,0-.82-.88H12.37A.91.91,0,0,0,11.43,12.13Z x M27.3,20.12a1.77,1.77,0,1,1-1.76,1.77,1.76,1.76,0,0,1,1.76-1.77m0-2.35a4.12,4.12,0,1,0,4.12,4.12,4.11,4.11,0,0,0-4.12-4.12Z'
            }
        );
        svgs.add(
            new List<String>{
                'Dislike',
                'M12,29.5V9c0-2.2-1.8-4-4-4H5.5C4.7,5,4,5.7,4,6.5v23C4,30.3,4.7,31,5.5,31h5C11.3,31,12,30.3,12,29.5z M48,26V13.5C48,4.8,41.1,4,33.6,4c-7.1,0-9.4,2.7-16.2,3C16.6,7,16,7.7,16,8.5v20c0,0.8,0.7,1.5,1.5,1.5c4.8,0,8.5,5.2,8.5,10.5v6c0,0.8,0.7,1.5,1.5,1.5H30c2.2,0,4-1.8,4-4V34c0-2.2,1.8-4,4-4h6C46.2,30,48,28.2,48,26z'
            }
        );
        svgs.add(
            new List<String>{
                'Display Rich Text',
                'M4.1,43.1h43.9c0.9,0,1.6,0.7,1.6,1.6v3.1c0,0.9-0.7,1.6-1.6,1.6H4.1c-0.9,0-1.6-0.7-1.6-1.6v-3.1C2.5,43.8,3.2,43.1,4.1,43.1z x M4.1,29h43.9c0.9,0,1.6,0.7,1.6,1.6v3.1c0,0.9-0.7,1.6-1.6,1.6H4.1c-0.9,0-1.6-0.7-1.6-1.6v-3.1C2.5,29.7,3.2,29,4.1,29z x M32,14.9h16c0.9,0,1.6,0.7,1.6,1.6v3.1c0,0.9-0.7,1.6-1.6,1.6H32c-0.9,0-1.6-0.7-1.6-1.6v-3.1C30.4,15.6,31.1,14.9,32,14.9z x M24.1,21.6L16.7,3.3c-0.2-0.3-0.5-0.6-0.9-0.6h-5.7c-0.3,0-0.7,0.2-0.8,0.6L2.5,21.6c-0.1,0.3,0.1,0.8,0.5,0.8h3.6c0.3,0,0.7-0.3,0.8-0.6l1.4-3.9l8.7,0l1.5,3.9c0.1,0.3,0.5,0.6,0.8,0.6h3.6C23.9,22.4,24.2,22,24.1,21.6z M10.5,13.1l2.3-5.8h0.5l2.5,5.8H10.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Display Text',
                'M43.5,2.5H8.6c-3.4,0-6.1,2.7-6.1,6.1v34.7c0,3.4,2.7,6.1,6.1,6.1h34.8c3.4,0,6.1-2.7,6.1-6.1V8.6C49.6,5.2,46.8,2.5,43.5,2.5z M10.6,12.7c0-1.1,0.9-2,2-2h22.9c1.1,0,2,0.9,2,2v2.1c0,1.1-0.9,2-2,2h-23c-1.1,0-2-0.9-2-2V12.7z M34.7,39.3c0,1.1-0.9,2-2,2H12.7c-1.1,0-2-0.9-2-2v-2c0-1.1,0.9-2,2-2h20c1.1,0,2,0.9,2,2V39.3z M41.4,27c0,1.1-0.9,2-2,2H12.7c-1.1,0-2-0.9-2-2v-2c0-1.1,0.9-2,2-2h26.6c1.1,0,2,0.9,2,2V27z'
            }
        );
        svgs.add(
            new List<String>{
                'Dock Panel',
                'M1.908,35V9c0-3.9,3.1-7,7-7h26c3.9,0,7,3.1,7,7v3h-6V9c0-0.601-0.4-1-1-1h-26c-0.6,0-1,0.399-1,1v26c0,0.6,0.4,1,1,1h3v6h-3C5.008,42,1.908,38.9,1.908,35z x M45.908,16h-26c-2.2,0-4,1.799-4,4v26c0,2.199,1.8,4,4,4h26c2.199,0,4-1.801,4-4V20C49.908,17.799,48.107,16,45.908,16z M41.893,41.184c0,0.49-0.307,0.795-0.857,0.795H29.41c-0.488,0-1.039-0.428-1.039-0.918v-1.773c0-0.49,0.551-0.979,1.039-0.979h4.834c0.551,0,0.795-0.613,0.428-0.979l-10.4-10.403c-0.367-0.367-0.367-0.918,0-1.285l1.285-1.284c0.367-0.367,0.917-0.367,1.285,0l10.4,10.4c0.367,0.43,0.979,0.123,0.979-0.426v-4.835c0-0.552,0.551-0.979,1.041-0.979h1.836c0.488,0,0.795,0.488,0.795,0.979V41.184z'
            }
        );
        svgs.add(
            new List<String>{
                'Down',
                'M8.3,14h35.4c1,0,1.7,1.3,0.9,2.2L27.3,37.4c-0.6,0.8-1.9,0.8-2.5,0L7.3,16.2C6.6,15.3,7.2,14,8.3,14z'
            }
        );
        svgs.add(
            new List<String>{
                'Downloads',
                'M48.5,31h-3c-0.8,0-1.5,0.7-1.5,1.5v10c0,0.8-0.7,1.5-1.5,1.5h-33C8.7,44,8,43.3,8,42.5v-10C8,31.7,7.3,31,6.5,31h-3C2.7,31,2,31.7,2,32.5V46c0,2.2,1.8,4,4,4h40c2.2,0,4-1.8,4-4V32.5C50,31.7,49.3,31,48.5,31z x M25,37.6c0.6,0.6,1.5,0.6,2.1,0l13.5-13.5c0.6-0.6,0.6-1.5,0-2.1l-2.1-2.1c-0.6-0.6-1.5-0.6-2.1,0l-5.6,5.6c-0.6,0.6-1.7,0.2-1.7-0.7V3.5C29,2.7,28.2,2,27.5,2h-3C23.7,2,23,2.7,23,3.5v21.2c0,0.9-1.1,1.3-1.7,0.7l-5.6-5.6c-0.6-0.6-1.5-0.6-2.1,0L11.5,22c-0.6,0.6-0.6,1.5,0,2.1L25,37.6z'
            }
        );
        svgs.add(
            new List<String>{
                'Drag and Drop',
                'M20,4c2.2,0,4,1.8,4,4s-1.8,4-4,4s-4-1.8-4-4S17.8,4,20,4z M32,4c2.2,0,4,1.8,4,4s-1.8,4-4,4s-4-1.8-4-4S29.8,4,32,4z M20,16c2.2,0,4,1.8,4,4s-1.8,4-4,4s-4-1.8-4-4S17.8,16,20,16z M32,16c2.2,0,4,1.8,4,4s-1.8,4-4,4s-4-1.8-4-4S29.8,16,32,16z M20,28c2.2,0,4,1.8,4,4s-1.8,4-4,4s-4-1.8-4-4S17.8,28,20,28z M32,28c2.2,0,4,1.8,4,4s-1.8,4-4,4s-4-1.8-4-4S29.8,28,32,28z M20,40c2.2,0,4,1.8,4,4s-1.8,4-4,4s-4-1.8-4-4S17.8,40,20,40z M32,40c2.2,0,4,1.8,4,4s-1.8,4-4,4s-4-1.8-4-4S29.8,40,32,40z'
            }
        );
        svgs.add(
            new List<String>{
                'Duration Downscale',
                'M17.08,2H8A6,6,0,0,0,2,8v5.68A6,6,0,0,0,8.08,19.6h9.06a6,6,0,0,0,6-6V7.94A6,6,0,0,0,17.08,2ZM13.82,14.8h-2.5a4,4,0,0,1,0-8h2.5a4,4,0,0,1,0,8Z x M34.5,19.6h9.06a6,6,0,0,0,6-6V7.94A6,6,0,0,0,43.5,2H34.44a6,6,0,0,0-6,6v5.66A6,6,0,0,0,34.5,19.6ZM37.74,6.8h2.5a4,4,0,0,1,0,8h-2.5a4,4,0,0,1,0-8Z x M17.08,24.4H8a6,6,0,0,0-6,6v5.68A6,6,0,0,0,8.08,42h9.06a6,6,0,0,0,6-6V30.34A6,6,0,0,0,17.08,24.4ZM13.82,37.2h-2.5a4,4,0,1,1,0-8h2.5a4,4,0,0,1,0,8Z x M49.83,40.12a.84.84,0,0,0-.23-.23l-1.84-1.52a1.42,1.42,0,0,0-1.84,0L42.82,41c-.53.45-1.45.17-1.45-.5v-15a1.27,1.27,0,0,0-1.32-1.12H37.42a1.33,1.33,0,0,0-1.32,1.12V40.45c0,.67-.92.95-1.45.5l-3.09-2.58a1.44,1.44,0,0,0-1.85,0l-1.77,1.52a.92.92,0,0,0-.23,1.28.84.84,0,0,0,.23.23l9.88,8.26a1.42,1.42,0,0,0,1.84,0L49.6,41.4A.92.92,0,0,0,49.83,40.12Z'
            }
        );
        svgs.add(
            new List<String>{
                'Dynamic Record Choice',
                'M20.8,43c0-0.1,0-0.2,0-0.3C13.7,40.4,8.5,33.9,8.5,26c0-9.6,7.9-17.5,17.5-17.5S43.5,16.4,43.5,26c0,1.6-0.2,3.2-0.6,4.7c0.2,0.2,0.5,0.3,0.7,0.5c0.3,0,0.6-0.1,0.9-0.1l0,0l0,0c1.6,0,3.2,0.5,4.4,1.2c0.6-2,0.9-4.1,0.9-6.3C49.7,12.8,39,2.1,25.9,2.1S2.1,12.8,2.1,25.9c0,12.6,9.8,22.9,22.2,23.7C22.3,48.2,20.8,45.7,20.8,43z x M31.3,28.8c1.5,0,2.9,0.4,4.2,1c0.3-0.1,0.6-0.2,1-0.2c0.4-1.1,0.6-2.3,0.6-3.6c0-6.1-4.9-11-11-11s-11,4.9-11,11c0,4.9,3.2,9,7.6,10.5C23.1,32.1,26.8,28.8,31.3,28.8z x M35.2,34.6c0.8-0.8,1.9-1.3,3.2-1.3c1.7,0,3.1,0.9,3.9,2.2c0.6-0.2,1.4-0.5,2.2-0.5c2.9,0,5.4,2.5,5.4,5.3c0,2.9-2.5,5.3-5.4,5.3c-0.3,0-0.7,0-1-0.1c-0.6,1.2-2,2-3.4,2c-0.6,0-1.2-0.2-1.7-0.4c-0.7,1.6-2.3,2.7-4.1,2.7c-2,0-3.6-1.2-4.2-2.9c-0.2,0-0.6,0.1-0.9,0.1c-2.3,0-4.2-1.8-4.2-4.1c0-1.5,0.8-2.9,2.1-3.6c-0.2-0.6-0.4-1.2-0.4-1.9c0-2.6,2.2-4.8,4.8-4.8C32.9,32.7,34.3,33.5,35.2,34.6z'
            }
        );
        svgs.add(
            new List<String>{
                'Edit Form',
                'M31.4,15.3h8.2c0.6,0,1.1-0.5,1.1-1.1l0,0c0-0.3-0.1-0.5-0.3-0.8L30.2,3.3C29.9,3.1,29.7,3,29.4,3l0,0c-0.6,0-1.1,0.5-1.1,1.1v8.1C28.3,13.9,29.7,15.3,31.4,15.3z x M49.5,25.7l-0.9-0.9c-0.6-0.6-1.5-0.6-2.2,0L34.5,36.7c-0.1,0.1,0,0.2,0,0.3v2.5c0,0.2,0,0.4,0.2,0.4h2.6c0.1,0,0.2-0.1,0.3-0.1L49.5,28C50.2,27.2,50.2,26.3,49.5,25.7z x M39.9,44.4h-1.8h-3.6h-1.7c-1.6,0-2.9-1.3-2.9-2.9v-5.4c0-0.8,0.2-1.6,0.9-2.1l9.5-9.5c0.3-0.3,0.5-0.7,0.5-1.1v-2c0-0.8-0.7-1.5-1.5-1.5H28.3c-2.6,0-4.6-2.1-4.6-4.6V4.5C23.7,3.7,23,3,22.1,3H6.6C4.1,3,2,5.1,2,7.6v36.8C2,46.9,4.1,49,6.6,49h29.4c2.2,0,4.2-1.6,4.6-3.7C40.7,44.9,40.3,44.4,39.9,44.4z M8.2,16.8c0-0.8,0.7-1.5,1.5-1.5h6.2c0.9,0,1.5,0.7,1.5,1.5v1.5c0,0.8-0.7,1.5-1.5,1.5H9.7c-0.9,0-1.5-0.7-1.5-1.5V16.8z M23.7,36.7c0,0.8-0.7,1.5-1.5,1.5H9.7c-0.9,0-1.5-0.7-1.5-1.5v-1.5c0-0.8,0.7-1.5,1.5-1.5h12.4c0.9,0,1.5,0.7,1.5,1.5V36.7z M26.8,27.5c0,0.8-0.7,1.5-1.5,1.5H9.7c-0.9,0-1.5-0.7-1.5-1.5V26c0-0.8,0.7-1.5,1.5-1.5h15.5c0.9,0,1.5,0.7,1.5,1.5V27.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Edit',
                'M9.5,33.4l8.9,8.9c0.4,0.4,1,0.4,1.4,0L42,20c0.4-0.4,0.4-1,0-1.4l-8.8-8.8c-0.4-0.4-1-0.4-1.4,0L9.5,32.1C9.1,32.5,9.1,33.1,9.5,33.4z x M36.1,5.7c-0.4,0.4-0.4,1,0,1.4l8.8,8.8c0.4,0.4,1,0.4,1.4,0l2.5-2.5c1.6-1.5,1.6-3.9,0-5.5l-4.7-4.7c-1.6-1.6-4.1-1.6-5.7,0L36.1,5.7z x M2.1,48.2c-0.2,1,0.7,1.9,1.7,1.7l10.9-2.6c0.4-0.1,0.7-0.3,0.9-0.5l0.2-0.2c0.2-0.2,0.3-0.9-0.1-1.3l-9-9c-0.4-0.4-1.1-0.3-1.3-0.1s-0.2,0.2-0.2,0.2c-0.3,0.3-0.4,0.6-0.5,0.9L2.1,48.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Einstein',
                'M28.7,42.1c7.2.2,7.4,1.6,7.4,7.2V50c-2.8,0-2.8-2.3-4-2.3,0,.8-.7,1.5-2,2.3-.8-1.5-1.4-2.3-2-2.3,0,.7-.6,1.4-1.8,2.2L26,50c-1.3-.8-2-1.5-2-2.3-.6,0-1.3.8-2,2.3-1.3-.8-2-1.5-2-2.3-1.3,0-1.3,2.3-4,2.3v-.9c0-5.3.4-6.7,6.9-7v.4a3,3,0,0,0,6,0A.41.41,0,0,1,28.7,42.1ZM30.2,6.8c3,3.6,2.4,5.3,2.5,6.4a11.91,11.91,0,0,1,7.8.8c1.8.9,2.9,2.3,3,3.3a4.69,4.69,0,0,0-3,1.5,14.94,14.94,0,0,1,6.1,3.9,17.05,17.05,0,0,1,3.3,5.6.77.77,0,0,1,0,.8,22.86,22.86,0,0,1-3.1,2.8,41.42,41.42,0,0,1-4.1,2.7c1.6,1,2.4,1.9,2.5,2.9-1.7.5-2.7.9-3.8,1.3-.5.2-1.5.5-2.6.9,1.6-10.5-5-11.5-8-11.5-2.1,0-3.3,1.7-5.1,1.7s-2.9-1.7-5.1-1.7S12.2,30,13.3,39a12.66,12.66,0,0,1-1.8-.7,21.17,21.17,0,0,0-5-.9A.53.53,0,0,1,5.9,37a.38.38,0,0,1,0-.15v-.3a10,10,0,0,1,2.4-4.3c.7-.7,2-1.6,2.5-1.5a8.68,8.68,0,0,0-3.4-3.1,19.5,19.5,0,0,0-4.8-1.3c-.5-.1-.8-.1-.5-1,1.7-4.3,3.7-7,6.1-8.2a11.26,11.26,0,0,1,6-1.5,9,9,0,0,0-1-2.5A12.94,12.94,0,0,0,12,11.2a.76.76,0,0,1,.1-1c.1,0,.2-.1.3-.1a6.64,6.64,0,0,1,3.1.2A8.08,8.08,0,0,1,19.4,13,36.29,36.29,0,0,0,18,2.8C17.9.6,27.2,3.2,30.2,6.8ZM22.7,34.1c.8,0,1.5,1.1,1.5,2.5s-.7,2.5-1.5,2.5-1.5-1.1-1.5-2.5S21.9,34.1,22.7,34.1Zm6.6,0c.8,0,1.5,1.1,1.5,2.5s-.7,2.5-1.5,2.5-1.5-1.1-1.5-2.5S28.4,34.1,29.3,34.1Z'
            }
        );
        svgs.add(
            new List<String>{
                'Email Open',
                'M45.8,28.1c0-0.8-1-1.3-1.7-0.7L29.5,40.9c-1,0.9-2.2,1.4-3.6,1.4s-2.6-0.5-3.6-1.3L7.8,27.4c-0.7-0.6-1.7-0.2-1.7,0.7c-0.1-0.2-0.1,18-0.1,18c0,1.8,1.5,3.3,3.3,3.3h33.1c1.8,0,3.3-1.5,3.3-3.3V28.1z x M45.6,20.6c0.2-0.2,0.3-0.4,0.3-0.6c0-0.3-0.1-0.5-0.3-0.7l0,0L26.8,2c-0.5-0.5-1.2-0.5-1.7,0L6.5,19.2c0,0,0,0,0,0l0,0c-0.1,0.1-0.1,0.2-0.2,0.2c0,0,0,0,0,0.1c0,0,0,0,0,0c0,0.1-0.1,0.2-0.1,0.3c0,0.3,0.1,0.5,0.3,0.7c0,0,0,0,0,0l18.5,17.2c0.5,0.5,1.2,0.5,1.7,0L45.6,20.6C45.6,20.7,45.6,20.6,45.6,20.6L45.6,20.6C45.6,20.6,45.6,20.6,45.6,20.6z'
            }
        );
        svgs.add(
            new List<String>{
                'Email',
                'M24.9,30.1c0.6,0.6,1.5,0.6,2.1,0l22.6-21C50,8.3,49.9,7,48.3,7L3.6,7.1c-1.2,0-2.2,1.1-1.3,2.1L24.9,30.1z x M50,17.3c0-1-1.2-1.6-2-0.9L30.3,32.7c-1.2,1.1-2.7,1.7-4.3,1.7s-3.1-0.6-4.3-1.6L4.1,16.4c-0.8-0.7-2-0.2-2,0.9C2,17,2,40,2,40c0,2.2,1.8,4,4,4h40c2.2,0,4-1.8,4-4C50,34,50,21.8,50,17.3z'
            }
        );
        svgs.add(
            new List<String>{
                'Emoji',
                'M50.1,26c0,13.3-10.8,24.1-24.1,24.1C12.7,50.1,1.9,39.3,1.9,26C1.9,12.7,12.7,1.9,26,1.9C39.3,1.9,50.1,12.7,50.1,26z M18.3,15.8c-2.4,0-4.3,1.9-4.3,4.3s1.9,4.3,4.3,4.3c2.4,0,4.3-1.9,4.3-4.3S20.7,15.8,18.3,15.8z M33.8,15.8c-2.4,0-4.3,1.9-4.3,4.3s1.9,4.3,4.3,4.3c2.4,0,4.3-1.9,4.3-4.3S36.2,15.8,33.8,15.8z M33.6,32.5c-2,1.8-4.7,2.8-7.6,2.8c-2.8,0-5.4-1-7.5-2.7l-0.9-0.8c-0.3-0.2-0.5-0.3-1.1-0.3c-1.1,0-1.9,0.9-1.9,1.9c0,0.5,0.2,1,0.6,1.4l0.7,0.6c2.7,2.4,6.3,3.8,10.1,3.8c3.9,0,7.5-1.5,10.2-3.9l0.5-0.5c0.4-0.4,0.6-0.9,0.6-1.4c0-1.1-0.9-1.9-1.9-1.9c-0.5,0-0.9,0.2-1.2,0.4L33.6,32.5z'
            }
        );
        svgs.add(
            new List<String>{
                'End Call',
                'M48.5,5.6l-2.1-2.1C45.8,2.9,44.7,3,44,3.8L20.5,27.3l-5-5.6c-0.6-0.6-0.6-1.4-0.2-2.1l3.8-5.2c1.1-1.4,1-3.4-0.1-4.8l-4.9-6.1c-1.5-1.8-4.2-2-5.9-0.3L3,8.4c-0.8,0.8-1.2,1.9-1.2,3c0.5,9.2,4.2,18,10,24.6l-8,8c-0.7,0.7-0.8,1.8-0.3,2.4l2.1,2.1C6.2,49.1,7.3,49,8,48.2L48.2,8C49,7.3,49.1,6.2,48.5,5.6z x M48.5,37.9L42.4,33c-1.4-1.1-3.4-1.2-4.8-0.1l-5.2,3.8c-0.6,0.5-1.5,0.4-2.1-0.2l-2.4-2.2l-8.5,8.5c6.1,4.1,13.4,6.8,21,7.2c1.1,0.1,2.2-0.4,3-1.2l5.2-5.2C50.5,42.1,50.4,39.3,48.5,37.9z'
            }
        );
        svgs.add(
            new List<String>{
                'End Chat',
                'M24.6,40.6c0-8.8,7.2-16,16-16c1.5,0,2.9,0.2,4.2,0.6c0.2-1.1,0.3-2.1,0.3-3.2c-0.1-11-9.7-19.8-21.5-19.8c-11.9,0-21.4,8.8-21.4,19.6c0,3.4,1,6.6,2.6,9.5c0.3,0.4,0.4,1,0.2,1.5l-2.8,7.6c-0.3,0.7,0.4,1.3,1.2,1.2l7.7-3c0.4-0.2,1-0.1,1.5,0.2c3.2,1.8,7.1,2.9,11.2,2.9c0.3,0,0.5,0,0.8,0C24.6,41.3,24.6,40.9,24.6,40.6z M34.4,18.3c2,0,3.6,1.6,3.6,3.6s-1.6,3.6-3.6,3.6s-3.6-1.6-3.6-3.6S32.4,18.3,34.4,18.3z M12.9,25.4c-2,0-3.6-1.6-3.6-3.6s1.6-3.6,3.6-3.6c2,0,3.6,1.6,3.6,3.6S14.8,25.4,12.9,25.4z M23.6,25.4c-2,0-3.6-1.6-3.6-3.6s1.6-3.6,3.6-3.6c2,0,3.6,1.6,3.6,3.6S25.6,25.4,23.6,25.4z x M31.7,34.6l6,6l-6,6c-0.6,0.6-0.6,1.6,0,2.1l0.7,0.7c0.6,0.6,1.6,0.6,2.1,0l6-6l6,6c0.6,0.6,1.6,0.6,2.1,0l0.7-0.7c0.6-0.6,0.6-1.6,0-2.1l-6-6l6-6c0.6-0.6,0.6-1.6,0-2.1l-0.7-0.7c-0.6-0.6-1.6-0.6-2.1,0l-6,6l-6-6c-0.6-0.6-1.6-0.6-2.1,0l-0.7,0.7C31.2,33,31.2,34,31.7,34.6z'
            }
        );
        svgs.add(
            new List<String>{
                'End Messaging Session',
                'M24.6,40.6c0-2.8,0.7-5.4,2-7.7h-2.3c-0.5,0-0.8-0.3-0.8-0.8v-9.2c0-0.5,0.3-0.8,0.8-0.8h9.2c0.5,0,0.8,0.3,0.8,0.8v3c1.9-0.8,4.1-1.3,6.3-1.3c1.5,0,2.9,0.2,4.2,0.6c0.2-1.1,0.3-2.2,0.3-3.3C45,10.9,35.5,2.1,23.6,2.1c-11.9,0-21.4,8.8-21.4,19.6c0,3.4,1,6.6,2.6,9.5c0.3,0.4,0.4,1,0.2,1.5l-2.8,7.6c-0.3,0.7,0.4,1.3,1.2,1.2l7.7-3c0.4-0.2,1-0.1,1.5,0.2c3.2,1.8,7.1,2.9,11.2,2.9c0.3,0,0.6,0,0.8,0C24.6,41.3,24.6,41,24.6,40.6z M12.8,12.2c0-0.5,0.3-0.8,0.8-0.8h19.9c0.5,0,0.8,0.3,0.8,0.8v4.6c0,0.5-0.4,0.8-0.9,0.8H13.6c-0.5,0-0.8-0.3-0.8-0.8V12.2z M19,32.1c0,0.5-0.4,0.8-0.9,0.8h-4.6c-0.5,0-0.8-0.3-0.8-0.8v-9.2c0-0.5,0.3-0.8,0.8-0.8h4.7c0.5,0,0.8,0.3,0.8,0.8V32.1z x M31.8,34.6l6,6l-6,6c-0.6,0.6-0.6,1.6,0,2.1l0.7,0.7c0.6,0.6,1.6,0.6,2.1,0l6-6l6,6c0.6,0.6,1.6,0.6,2.1,0l0.7-0.7c0.6-0.6,0.6-1.6,0-2.1l-6-6l6-6c0.6-0.6,0.6-1.6,0-2.1l-0.7-0.7c-0.6-0.6-1.6-0.6-2.1,0l-6,6l-6-6c-0.6-0.6-1.6-0.6-2.1,0l-0.7,0.7C31.2,33.1,31.2,34.1,31.8,34.6z'
            }
        );
        svgs.add(
            new List<String>{
                'Engage',
                'M26.5,4.25 C39.301356,4.25 49.75,13.6384178 49.75,25.3183903 C49.75,36.9983628 39.301356,46.3867807 26.5,46.3867807 C24.8377011,46.3867807 23.1974628,46.2285805 21.6001365,45.9180487 L21.6001365,45.9180487 L21.113,45.817 L20.9701481,45.8930527 C18.9378605,46.9334978 15.6648477,47.7753318 11.0573216,48.4901817 L11.0573216,48.4901817 L10.5398777,48.5690905 L9.41174,48.732028 C7.68683822,48.9811565 6.69759037,46.8308991 8.00905671,45.6831155 C9.32400065,44.5322883 10.3234322,43.0226888 11.0065383,41.1279241 L11.0065383,41.1279241 L11.032,41.051 L10.7151344,40.7905779 C6.12018367,36.9425763 3.37660694,31.5495523 3.25427233,25.7254112 L3.25427233,25.7254112 L3.25,25.3183903 C3.25,13.6384178 13.698644,4.25 26.5,4.25 Z M33.5,31 L19.5,31 C18.3954305,31 17.5,31.8954305 17.5,33 C17.5,34.1045695 18.3954305,35 19.5,35 L19.5,35 L33.5,35 C34.6045695,35 35.5,34.1045695 35.5,33 C35.5,31.8954305 34.6045695,31 33.5,31 L33.5,31 Z M37.5,23.5 L15.5,23.5 C14.3954305,23.5 13.5,24.3954305 13.5,25.5 C13.5,26.6045695 14.3954305,27.5 15.5,27.5 L15.5,27.5 L37.5,27.5 C38.6045695,27.5 39.5,26.6045695 39.5,25.5 C39.5,24.3954305 38.6045695,23.5 37.5,23.5 L37.5,23.5 Z M33.5,16 L19.5,16 C18.3954305,16 17.5,16.8954305 17.5,18 C17.5,19.1045695 18.3954305,20 19.5,20 L19.5,20 L33.5,20 C34.6045695,20 35.5,19.1045695 35.5,18 C35.5,16.8954305 34.6045695,16 33.5,16 L33.5,16 Z'
            }
        );
        svgs.add(
            new List<String>{
                'Enter',
                'M44,30.5c0,0,0.1,1.6-1.5,1.6H15.2c-0.9,0-1.3-1.2-0.7-1.8l5.6-5.6c0.6-0.6,0.6-1.5,0-2.1L18,20.5c-0.6-0.6-1.5-0.6-2.1,0L2.4,34c-0.6,0.6-0.6,1.5,0,2.1L16,49.6c0.6,0.6,1.5,0.6,2.1,0l2.1-2.1c0.6-0.6,0.6-1.5,0-2.1l-5.6-5.6c-0.6-0.7-0.2-1.7,0.7-1.7h33.2c0.7,0,1.5-0.8,1.5-1.6v-33C50,2.8,49.3,2,48.5,2h-3C44.7,2,44,2.8,44,3.5C44,3.5,44,30.5,44,30.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Error',
                'M26,2C12.8,2,2,12.8,2,26s10.8,24,24,24s24-10.8,24-24S39.2,2,26,2z M8,26c0-9.9,8.1-18,18-18c3.9,0,7.5,1.2,10.4,3.3L11.3,36.4C9.2,33.5,8,29.9,8,26z M26,44c-3.9,0-7.5-1.2-10.4-3.3c5.1-5.1,19.3-19.3,25.1-25.1C42.8,18.5,44,22.1,44,26C44,35.9,35.9,44,26,44z'
            }
        );
        svgs.add(
            new List<String>{
                'Event Ext',
                'm49.83 32.45a1.43 1.43 0 0 0 -1.39-1.45h-12a1.43 1.43 0 0 0 -1.44 1.44v1.44a1.43 1.43 0 0 0 1.4 1.44h6.14l-11 11a1.42 1.42 0 0 0 0 2l1 1a1.54 1.54 0 0 0 1.09.45 1.32 1.32 0 0 0 .94-.38l11-11v6a1.43 1.43 0 0 0 1.43 1.44h1.53a1.43 1.43 0 0 0 1.47-1.4z x m3.45 12.48h31.91a1.24 1.24 0 0 0 1.25-1.23v-1.25a3.8 3.8 0 0 0 -3.76-3.69h-3.06v-1.31a2.43 2.43 0 0 0 -4.86 0v1.28h-11.06v-1.28a2.44 2.44 0 0 0 -4.87 0v1.28h-3.12a3.69 3.69 0 0 0 -3.69 3.72v1.28a1.24 1.24 0 0 0 1.25 1.23z x m36.53 25.13v-7.79a1.25 1.25 0 0 0 -1.22-1.26h-31.86a1.24 1.24 0 0 0 -1.26 1.22v18.46a3.69 3.69 0 0 0 3.69 3.69h18.5a16.82 16.82 0 0 1 12.15-14.32zm-11-2.85a1.24 1.24 0 0 1 1.2-1.28h2.43a1.24 1.24 0 0 1 1.26 1.22v2.47a1.24 1.24 0 0 1 -1.17 1.31h-2.52a1.25 1.25 0 0 1 -1.25-1.23zm-12.23 11a1.23 1.23 0 0 1 -1.25 1.23h-2.49a1.24 1.24 0 0 1 -1.25-1.23v-2.46a1.25 1.25 0 0 1 1.23-1.25h2.46a1.25 1.25 0 0 1 1.26 1.22zm0-8.54a1.24 1.24 0 0 1 -1.22 1.26h-2.52a1.25 1.25 0 0 1 -1.25-1.23v-2.49a1.24 1.24 0 0 1 1.2-1.28h2.49a1.24 1.24 0 0 1 1.26 1.22zm8.54 8.54a1.25 1.25 0 0 1 -1.22 1.26h-2.51a1.24 1.24 0 0 1 -1.26-1.22v-2.5a1.24 1.24 0 0 1 1.23-1.25h2.46a1.25 1.25 0 0 1 1.25 1.23zm-1.3-7.28h-2.43a1.25 1.25 0 0 1 -1.26-1.22v-2.5a1.24 1.24 0 0 1 1.2-1.28h2.49a1.24 1.24 0 0 1 1.25 1.23v2.46a1.24 1.24 0 0 1 -1.17 1.31z'
            }
        );
        svgs.add(
            new List<String>{
                'Event',
                'M46.5,20h-41C4.7,20,4,20.7,4,21.5V46c0,2.2,1.8,4,4,4h36c2.2,0,4-1.8,4-4V21.5C48,20.7,47.3,20,46.5,20z M19,42c0,0.6-0.4,1-1,1h-4c-0.6,0-1-0.4-1-1v-4c0-0.6,0.4-1,1-1h4c0.6,0,1,0.4,1,1V42z M19,32c0,0.6-0.4,1-1,1h-4c-0.6,0-1-0.4-1-1v-4c0-0.6,0.4-1,1-1h4c0.6,0,1,0.4,1,1V32z M29,42c0,0.6-0.4,1-1,1h-4c-0.6,0-1-0.4-1-1v-4c0-0.6,0.4-1,1-1h4c0.6,0,1,0.4,1,1V42z M29,32c0,0.6-0.4,1-1,1h-4c-0.6,0-1-0.4-1-1v-4c0-0.6,0.4-1,1-1h4c0.6,0,1,0.4,1,1V32z M39,42c0,0.6-0.4,1-1,1h-4c-0.6,0-1-0.4-1-1v-4c0-0.6,0.4-1,1-1h4c0.6,0,1,0.4,1,1V42z M39,32c0,0.6-0.4,1-1,1h-4c-0.6,0-1-0.4-1-1v-4c0-0.6,0.4-1,1-1h4c0.6,0,1,0.4,1,1V32z x M44,7h-4h-1V5c0-1.6-1.3-3-3-3l0,0c-1.6,0-3,1.3-3,3v2H19V5c0-1.6-1.3-3-3-3l0,0c-1.6,0-3,1.3-3,3v2h-1H8c-2.2,0-4,1.8-4,4v2.5C4,14.3,4.7,15,5.5,15h41c0.8,0,1.5-0.7,1.5-1.5V11C48,8.8,46.2,7,44,7z'
            }
        );
        svgs.add(
            new List<String>{
                'Events',
                'M8.8,9C4.4,13.5,2,19.4,2,25.6C2,27,3.1,28,4.4,28s2.4-1.1,2.4-2.4c-0.1-4.9,1.9-9.6,5.4-13.1s8.3-5.4,13.1-5.4c1.4,0,2.4-1.1,2.4-2.4c0-1.4-1.1-2.4-2.4-2.4C19.2,2.2,13.2,4.6,8.8,9z M11.7,25.6c0,1.4,1,2.4,2.4,2.4s2.4-1.1,2.4-2.4c0-2.3,0.9-4.6,2.6-6.2c1.7-1.7,3.9-2.5,6.2-2.6c1.4,0,2.4-1.1,2.4-2.4c0-1.4-1-2.4-2.4-2.4c-3.6,0-7.1,1.4-9.7,3.9C15.2,16.4,11.5,20.1,11.7,25.6z x M45.5,15.2c-0.9-1.2-2.1-2.6-2.3-2.8c-0.3-0.2-0.7-0.4-1.1-0.4c-0.4,0-0.8,0.1-1,0.4L31,22.4c-2.4-2-6-1.9-8.3,0.4c-2.3,2.3-2.4,5.9-0.4,8.3l-9.7,9.7c-0.3,0.3-0.5,0.7-0.5,1.1c0,0.5,0.2,1,0.6,1.3l2.7,2c3.7,2.9,8.3,4.5,13.2,4.5c11.8,0,21.4-9.6,21.4-21.4C50,23.5,48.3,18.9,45.5,15.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Expand All',
                'M48,9.5C48,8.7,47.3,8,46.5,8h-41C4.7,8,4,8.7,4,9.5v3C4,13.3,4.7,14,5.5,14h41c0.8,0,1.5-0.7,1.5-1.5V9.5z x M48,39.5c0-0.8-0.7-1.5-1.5-1.5h-41C4.7,38,4,38.7,4,39.5v3C4,43.3,4.7,44,5.5,44h41c0.8,0,1.5-0.7,1.5-1.5V39.5z x M30,29h4.5c0.8,0,1.5-0.7,1.5-1.5v-3c0-0.8-0.7-1.5-1.5-1.5H30c-0.6,0-1-0.4-1-1v-4.5c0-0.8-0.7-1.5-1.5-1.5h-3c-0.8,0-1.5,0.7-1.5,1.5V22c0,0.6-0.4,1-1,1h-4.5c-0.8,0-1.5,0.7-1.5,1.5v3c0,0.8,0.7,1.5,1.5,1.5H22c0.6,0,1,0.4,1,1v4.5c0,0.8,0.7,1.5,1.5,1.5h3c0.8,0,1.5-0.7,1.5-1.5V30C29,29.4,29.4,29,30,29z'
            }
        );
        svgs.add(
            new List<String>{
                'Expand Alt',
                'M48.8,2H33.3c-1,0-1.3,0.9-0.5,1.7l4.9,4.9l-9,9c-0.5,0.5-0.5,1.3,0,1.9l3.7,3.7c0.5,0.5,1.3,0.5,1.9,0l9.1-9.1l4.9,4.9c0.8,0.8,1.7,0.5,1.7-0.5V3.1C50,2.5,49.4,2,48.8,2z x M3.5,50h15.4c1,0,1.3-1.1,0.5-1.9l-4.9-5l9-9.1c0.5-0.5,0.5-1.4,0-1.9l-3.7-3.7c-0.5-0.5-1.3-0.5-1.9,0l-9,9l-5-4.9C3,31.7,2,32,2,33v15.4C2,49.1,2.8,50,3.5,50z'
            }
        );
        svgs.add(
            new List<String>{
                'Expand',
                'M48.8,2H33.3c-1,0-1.3,0.9-0.5,1.7l4.9,4.9l-9,9c-0.5,0.5-0.5,1.3,0,1.9l3.7,3.7c0.5,0.5,1.3,0.5,1.9,0l9.1-9.1l4.9,4.9c0.8,0.8,1.7,0.5,1.7-0.5V3.1C50,2.5,49.4,2,48.8,2z x M3.5,50h15.4c1,0,1.3-1.1,0.5-1.9l-4.9-5l9-9.1c0.5-0.5,0.5-1.4,0-1.9l-3.7-3.7c-0.5-0.5-1.3-0.5-1.9,0l-9,9l-5-4.9C3,31.7,2,32,2,33v15.4C2,49.1,2.8,50,3.5,50z x M50,48.8V33.3c0-1-0.9-1.3-1.7-0.5l-4.9,4.9l-9-9c-0.5-0.5-1.3-0.5-1.9,0l-3.7,3.7c-0.5,0.5-0.5,1.3,0,1.9l9.1,9.1L33,48.3c-0.8,0.8-0.5,1.7,0.5,1.7h15.4C49.5,50,50,49.4,50,48.8z x M2,3.5v15.4c0,1,1.1,1.3,1.9,0.5l5-4.9l9.1,9c0.5,0.5,1.4,0.5,1.9,0l3.7-3.7c0.5-0.5,0.5-1.3,0-1.9l-9-9l4.9-5C20.3,3,20,2,19,2H3.6C2.9,2,2,2.8,2,3.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Feed',
                'M25.2,43c-0.3,0-0.7-0.1-1.1-0.3c-0.6-0.3-1.1-1-1.2-1.6L17.2,18l-4.9,11c-0.3,0.9-1.1,1.4-2,1.4H3.5C2.7,30.4,2,29.8,2,29v-1.5C2,26.7,2.7,26,3.5,26h5.2l6.9-15.7C16,9.5,16.9,8.9,17.9,9c1,0.1,1.8,0.7,2,1.7l5.9,23.4L33.7,17c0.4-0.9,1.3-1.4,2.2-1.3c0.8,0.1,1.6,0.7,2,1.5l3.9,8.9h6.8c0.8,0,1.5,0.7,1.5,1.5V29c0,0.8-0.7,1.5-1.5,1.5h-8.2c-0.9,0-1.7-0.5-2.1-1.3l-2.5-5.7l-8.4,18.3C26.9,42.5,26.2,43,25.2,43z'
            }
        );
        svgs.add(
            new List<String>{
                'File',
                'M9.7,36.1V11.3c-2.6,0-4.7,2.1-4.7,4.6v29.4C5,47.9,7.1,50,9.7,50H33c2.6,0,4.7-2.1,4.7-4.6H19C13.9,45.4,9.7,45.4,9.7,36.1z x M45.4,15.9h-7.8c-2.6,0-4.7-2.1-4.7-4.6V3.5C33,2.7,32.3,2,31.4,2H19c-2.6,0-4.7,2.1-4.7,4.6v29.4c0,2.6,2.1,4.6,4.7,4.6h23.3c2.6,0,4.7-2.1,4.7-4.6V17.5C47,16.6,46.3,15.9,45.4,15.9z x M46.7,9.4l-7.2-7.1C39.3,2.1,39.1,2,38.8,2l0,0c-0.6,0-1.1,0.5-1.1,1.1v5.1c0,1.7,1.4,3.1,3.1,3.1h5.1c0.6,0,1.1-0.5,1.1-1.1l0,0C47,9.9,46.9,9.7,46.7,9.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Filter',
                'M24.4,31.8c-0.6-0.6-1.5-0.6-2.1,0l-3.6,3.6C18.1,36,17,35.6,17,34.7V21.5c0-0.8-0.7-1.5-1.5-1.5h-3c-0.8,0-1.5,0.7-1.5,1.5v13.2c0,0.9-1.1,1.3-1.7,0.7l-3.6-3.6c-0.6-0.6-1.5-0.6-2.1,0L1.4,34c-0.6,0.6-0.6,1.5,0,2.1l11.5,11.5c0.6,0.6,1.5,0.6,2.1,0L26.6,36c0.6-0.6,0.6-1.5,0-2.1L24.4,31.8z x M51,9.5C51,8.7,50.3,8,49.5,8h-37C11.7,8,11,8.7,11,9.5v3c0,0.8,0.7,1.5,1.5,1.5h37c0.8,0,1.5-0.7,1.5-1.5V9.5z x M51,21.5c0-0.8-0.7-1.5-1.5-1.5h-27c-0.8,0-1.5,0.7-1.5,1.5v3c0,0.8,0.7,1.5,1.5,1.5h27c0.8,0,1.5-0.7,1.5-1.5V21.5z x M51,33.5c0-0.8-0.7-1.5-1.5-1.5h-17c-0.8,0-1.5,0.7-1.5,1.5v3c0,0.8,0.7,1.5,1.5,1.5h17c0.8,0,1.5-0.7,1.5-1.5V33.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Flow',
                'm49.9 10.6c-2.1-4.1-7.4-11.7-17.2-7.2-6.1 2.8-9.5 4.4-9.5 4.4l-8.8 3.8c-2.5 1.2-7.9-0.5-11-1.6-0.9-0.3-1.7 0.6-1.3 1.5 2.1 4.1 7.4 11.7 17.2 7.2 6.1-2.8 18.3-8.1 18.3-8.1 2.5-1.2 7.9 0.5 11 1.6 0.9 0.2 1.7-0.7 1.3-1.6z m-21.1 12.8c-1.1 0.6-5.5 2.6-5.5 2.6l-4.4 1.9c-2.2 1.2-6.9-0.4-9.7-1.5-0.8-0.4-1.5 0.6-1.1 1.4 1.8 4 6.5 11.2 15.1 6.8 5.4-2.7 9.9-4.5 9.9-4.5 2.2-1.2 6.9 0.4 9.7 1.5 0.8 0.3 1.5-0.6 1.1-1.5-1.8-3.9-6.5-11.1-15.1-6.7z m-3.2 17.7c-0.9 0.5-2.4 1.4-2.4 1.4-1.7 1.1-5.2-0.3-7.3-1.3-0.6-0.3-1.1 0.6-0.8 1.4 1.3 3.6 4.8 10.1 11.3 6.1 2.4-1.5 2.4-1.4 2.4-1.4 1.8-0.9 5.2 0.3 7.3 1.3 0.6 0.3 1.1-0.6 0.8-1.4-1.3-3.6-4.6-9.8-11.3-6.1z x m25.9 25.1z'
            }
        );
        svgs.add(
            new List<String>{
                'Flow Alt',
                'M42.3,4.9H30.4C29.6,3.2,27.9,2,26,2c-2.6,0-4.8,2.2-4.8,4.8s2.2,4.8,4.8,4.8c2,0,3.7-1.2,4.4-2.9h11.9c2.1,0,3.8,1.7,3.8,3.8v7.7c0,2.1-1.7,3.8-3.8,3.8h-5.8v-5.8c0-1.6-1.3-2.9-2.9-2.9H18.3c-1.6,0-2.9,1.3-2.9,2.9v5.8H9.7c-4.2,0-7.7,3.4-7.7,7.7v7.7c0,4.2,3.4,7.7,7.7,7.7h11.9C22.3,48.8,24,50,26,50c2.6,0,4.8-2.2,4.8-4.8c0-2.6-2.2-4.8-4.8-4.8c-2,0-3.7,1.2-4.4,2.9H9.7c-2.1,0-3.8-1.7-3.8-3.8v-7.7c0-2.1,1.7-3.8,3.8-3.8h5.8v5.8c0,1.6,1.3,2.9,2.9,2.9h15.4c1.6,0,2.9-1.3,2.9-2.9v-5.8h5.8c4.2,0,7.7-3.4,7.7-7.7v-7.7C50,8.3,46.5,4.9,42.3,4.9z'
            }
        );
        svgs.add(
            new List<String>{
                'Food and Drink',
                'M40.8813782,24 C39.9367714,31.8648614 33.526454,37 28,37 L16.0015898,37 C10.0054932,37 3.00158983,31.010376 3.00158983,22 C3.00158983,17.3333333 3.00158983,12.6666667 3.00158983,8 L3.00158983,8 C3.00158983,6.8954305 3.89702033,6 5.00158983,6 L5.00158983,6 L39,6 L44,6 C47.3137085,6 50,8.6862915 50,12 L50,18 C50,21.3137085 47.3137085,24 44,24 L40.8813782,24 Z M39,6 L39,6 Z M40.5925926,40 C41.3333333,40 42,40.675 42,41.425 L42,41.5 C42,43.975 40,46 37.5555556,46 L6.44444444,46 C4,46 2,43.975 2,41.5 L2,41.425 C2,40.675 2.66666667,40 3.40740741,40 L40.5925926,40 Z M41,11 L41,19 L43,19 C44.1045695,19 45,18.1045695 45,17 L45,13 C45,11.8954305 44.1045695,11 43,11 L41,11 Z'
            }
        );
        svgs.add(
            new List<String>{
                'Formula',
                'M30.2,3.2c-0.8-0.6-1.9-0.9-3.2-0.9c-0.3,0-0.6,0-0.9,0.1c-3.5,0.5-5.8,3.8-7.2,6.8c-0.6,1.4-1.2,2.9-1.7,4.4c-0.3,0.7-0.5,1.4-0.8,2.1c0,0.1-0.4,1.5-0.5,1.5c0,0-3.2,0-3.2,0l0,0h-0.4c-0.5,0-0.9,0.4-0.9,0.9c0,0.5,0.4,0.9,0.9,0.9h3.1l-1.8,7.5C12,34.7,9.7,44.2,9.1,45.9c-0.6,1.7-1.4,2.6-2.5,2.6c-0.2,0-0.4,0-0.5-0.1c-0.1-0.1-0.2-0.2-0.2-0.4c0-0.1,0.1-0.4,0.3-0.7c0.2-0.3,0.3-0.7,0.3-1c0-0.7-0.2-1.2-0.7-1.6c-0.4-0.4-0.9-0.6-1.5-0.6c-0.6,0-1.1,0.2-1.6,0.6c-0.5,0.4-0.7,1-0.7,1.7c0,1,0.4,1.8,1.2,2.5c0.8,0.7,1.8,1,3.1,1c2.1,0,4.1-1,5.5-2.6c0.9-1,1.5-2.2,2.1-3.5c1.8-3.9,2.7-8.2,3.7-12.3c1-4.2,2-8.4,2.9-12.7H24c0.5,0,0.9-0.4,0.9-0.9c0-0.5-0.4-0.9-0.9-0.9H24v0h-3.1c1.7-6.6,3.7-11.1,4.1-11.8c0.7-1.1,1.4-1.7,2.1-1.7c0.3,0,0.5,0.1,0.6,0.2c0.1,0.2,0.1,0.3,0.1,0.4c0,0.1-0.1,0.3-0.3,0.7c-0.2,0.4-0.3,0.8-0.3,1.2c0,0.6,0.2,1,0.6,1.4c0.4,0.4,0.9,0.6,1.5,0.6c0.6,0,1.1-0.2,1.5-0.6c0.4-0.4,0.6-1,0.6-1.7C31.5,4.6,31.1,3.8,30.2,3.2z x M46.1,23.2c1.3,0,3.8-1,3.8-4.4c0-3.3-2.4-3.5-3.1-3.5c-1.5,0-2.9,1.1-4.2,3.3c-1.3,2.3-2.7,4.7-2.7,4.7l0,0c-0.3-1.6-0.6-2.9-0.7-3.5c-0.3-1.4-1.9-4.4-5.2-4.4c-3.3,0-6.3,1.9-6.3,1.9l0,0c-0.6,0.4-0.9,1-0.9,1.7c0,1.1,0.9,2,2,2c0.3,0,0.6-0.1,0.9-0.2l0,0c0,0,2.5-1.4,3,0c0.2,0.4,0.3,0.9,0.4,1.4c0.6,2.2,1.2,4.7,1.7,7l-2.2,3.1c0,0-2.4-0.9-3.7-0.9s-3.8,1-3.8,4.4s2.4,3.5,3.1,3.5c1.5,0,2.9-1.1,4.2-3.3c1.3-2.3,2.7-4.7,2.7-4.7c0.4,2,0.8,3.7,1,4.4c0.8,2.3,2.7,3.7,5.3,3.7c0,0,2.6,0,5.7-1.7c0.7-0.3,1.3-1,1.3-1.9c0-1.1-0.9-2-2-2c-0.3,0-0.6,0.1-0.9,0.2l0,0c0,0-2.2,1.2-2.9,0.3c-0.5-1-1-2.4-1.3-4c-0.3-1.5-0.7-3.2-1-4.9l2.2-3.2C42.4,22.3,44.9,23.2,46.1,23.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Forward',
                'M3.4,29h33.2c0.9,0,1.3,1.1,0.7,1.7l-9.6,9.6c-0.6,0.6-0.6,1.5,0,2.1l2.2,2.2c0.6,0.6,1.5,0.6,2.1,0L49.5,27c0.6-0.6,0.6-1.5,0-2.1L32,7.4c-0.6-0.6-1.5-0.6-2.1,0l-2.1,2.1c-0.6,0.6-0.6,1.5,0,2.1l9.6,9.6c0.6,0.7,0.2,1.8-0.7,1.8H3.5C2.7,23,2,23.6,2,24.4v3C2,28.2,2.6,29,3.4,29z'
            }
        );
        svgs.add(
            new List<String>{
                'Forward Up',
                'M8.2,49.6l31.5-31.5c0.9-0.9,2.3-0.2,2.3,0.9v18.2c0,1.1,0.9,2,2,2h4.2c1.1,0,2-0.9,2-2L50,4.1c0-1.1-0.9-2-2-2l-33.2,0c-1.1,0-2,0.9-2,2l0,4c0,1.1,0.9,2,2,2H33c1.2,0.1,1.9,1.5,1,2.4L2.6,43.9c-0.8,0.8-0.9,2-0.1,2.7l2.8,2.8C6.1,50.2,7.4,50.4,8.2,49.6z'
            }
        );
        svgs.add(
            new List<String>{
                'Freeze Column',
                'M14.5,44A1.54,1.54,0,0,1,16,45.5v3A1.54,1.54,0,0,1,14.5,50h-9A1.54,1.54,0,0,1,4,48.5v-3A1.54,1.54,0,0,1,5.5,44Zm19.6,0c.59,0,1.1.7,1.1,1.5v3c0,.8-.51,1.5-1.1,1.5H27.5c-.59,0-1.1-.7-1.1-1.5v-3c0-.8.51-1.5,1.1-1.5Zm12.8,0c.59,0,1.1.7,1.1,1.5v3c0,.8-.51,1.5-1.1,1.5H40.3c-.59,0-1.1-.7-1.1-1.5v-3c0-.8.51-1.5,1.1-1.5ZM21.6,14a.8.8,0,0,1,.8.8V49.2a.8.8,0,0,1-.8.8h-.8a.8.8,0,0,1-.8-.8V14.8a.8.8,0,0,1,.8-.8ZM14.5,34A1.54,1.54,0,0,1,16,35.5v3A1.54,1.54,0,0,1,14.5,40h-9A1.54,1.54,0,0,1,4,38.5v-3A1.54,1.54,0,0,1,5.5,34Zm19.6,0c.59,0,1.1.7,1.1,1.5v3c0,.8-.51,1.5-1.1,1.5H27.5c-.59,0-1.1-.7-1.1-1.5v-3c0-.8.51-1.5,1.1-1.5Zm12.8,0c.59,0,1.1.7,1.1,1.5v3c0,.8-.51,1.5-1.1,1.5H40.3c-.59,0-1.1-.7-1.1-1.5v-3c0-.8.51-1.5,1.1-1.5ZM14.5,24A1.54,1.54,0,0,1,16,25.5v3A1.54,1.54,0,0,1,14.5,30h-9A1.54,1.54,0,0,1,4,28.5v-3A1.54,1.54,0,0,1,5.5,24Zm19.6,0c.59,0,1.1.7,1.1,1.5v3c0,.8-.51,1.5-1.1,1.5H27.5c-.59,0-1.1-.7-1.1-1.5v-3c0-.8.51-1.5,1.1-1.5Zm12.8,0c.59,0,1.1.7,1.1,1.5v3c0,.8-.51,1.5-1.1,1.5H40.3c-.59,0-1.1-.7-1.1-1.5v-3c0-.8.51-1.5,1.1-1.5ZM14.5,14A1.54,1.54,0,0,1,16,15.5v3A1.54,1.54,0,0,1,14.5,20h-9A1.54,1.54,0,0,1,4,18.5v-3A1.54,1.54,0,0,1,5.5,14Zm19.6,0c.59,0,1.1.7,1.1,1.5v3c0,.8-.51,1.5-1.1,1.5H27.5c-.59,0-1.1-.7-1.1-1.5v-3c0-.8.51-1.5,1.1-1.5Zm12.8,0c.59,0,1.1.7,1.1,1.5v3c0,.8-.51,1.5-1.1,1.5H40.3c-.59,0-1.1-.7-1.1-1.5v-3c0-.8.51-1.5,1.1-1.5ZM46.5,2A1.54,1.54,0,0,1,48,3.5v5A1.54,1.54,0,0,1,46.5,10H5.5A1.54,1.54,0,0,1,4,8.5v-5A1.54,1.54,0,0,1,5.5,2Z'
            }
        );
        svgs.add(
            new List<String>{
                'Frozen',
                'M27,3c0.6,0,1,0.4,1,1v45.9c0,0.6-0.4,1-1,1h-2c-0.6,0-1-0.4-1-1V4c0-0.6,0.4-1,1-1H27z x M26,17.2l-8.1-8.1c-0.4-0.4-0.4-1,0-1.4l1.4-1.4c0.4-0.4,1-0.4,1.4,0l5.3,5.3l5.3-5.3c0.4-0.4,1-0.4,1.4,0l1.4,1.4c0.4,0.4,0.4,1,0,1.4L26,17.2 x M26,36.7l8.1,8.1c0.4,0.4,0.4,1,0,1.4l-1.4,1.4c-0.4,0.4-1,0.4-1.4,0L26,42.3l-5.3,5.3c-0.4,0.4-1,0.4-1.4,0l-1.4-1.4c-0.4-0.4-0.4-1,0-1.4L26,36.7 x M47.1,15.6c0.3,0.5,0.2,1.1-0.4,1.4L7.2,40.3c-0.5,0.3-1.1,0.2-1.4-0.4l-1-1.7c-0.3-0.5-0.2-1.1,0.4-1.4l39.5-23.4c0.5-0.3,1.1-0.2,1.4,0.4L47.1,15.6z x M34.4,22l2.8-11.1c0.1-0.6,0.6-0.9,1.2-0.7l1.9,0.5c0.6,0.1,0.9,0.6,0.7,1.2l-1.9,7.3l7.3,1.9c0.6,0.1,0.9,0.6,0.7,1.2l-0.5,1.9c-0.1,0.6-0.6,0.9-1.2,0.7L34.4,22 x M17.6,31.9L14.8,43c-0.1,0.6-0.6,0.9-1.2,0.7l-1.9-0.5c-0.6-0.1-0.9-0.6-0.7-1.2l1.9-7.3l-7.3-1.9c-0.6-0.1-0.9-0.6-0.7-1.2l0.5-1.9C5.5,29.1,6,28.8,6.6,29L17.6,31.9 x M5.9,13.9c0.3-0.5,0.9-0.7,1.4-0.4l39.5,23.4c0.5,0.3,0.7,0.9,0.4,1.4l-1,1.7c-0.3,0.5-0.9,0.7-1.4,0.4L5.2,17c-0.5-0.3-0.7-0.9-0.4-1.4L5.9,13.9z x M17.6,22L6.5,24.9c-0.6,0.1-1.1-0.1-1.2-0.7l-0.5-1.9c-0.1-0.6,0.1-1.1,0.7-1.2l7.3-1.9l-1.9-7.3c-0.1-0.6,0.1-1.1,0.7-1.2l1.9-0.5c0.6-0.1,1.1,0.1,1.2,0.7L17.6,22 x M34.3,31.9L45.4,29c0.6-0.1,1.1,0.1,1.2,0.7l0.5,1.9c0.1,0.6-0.1,1.1-0.7,1.2l-7.3,1.9L41,42c0.1,0.6-0.1,1.1-0.7,1.2l-1.9,0.5c-0.6,0.1-1.1-0.1-1.2-0.7L34.3,31.9z'
            }
        );
        svgs.add(
            new List<String>{
                'Fulfillment Order',
                'M24.3,36.5c0.7,0,1.4,0.1,2,0.3L15.5,6.2c0,0,0,0,0,0l-1-3c-0.3-0.9-1.2-1.3-2-1L3.1,5.3c-0.9,0.3-1.3,1.2-1,2l1,3c0.3,0.9,1.2,1.3,2,1L10,9.7l9.9,28.1C21.2,37,22.7,36.5,24.3,36.5z x M41.2,29.2l-9.9,3.5c-1,0.4-2.2-0.2-2.5-1.2l-3.5-9.9c-0.4-1,0.2-2.2,1.2-2.5l9.9-3.5c1-0.4,2.2,0.2,2.5,1.2l3.5,9.9C42.8,27.7,42.2,28.8,41.2,29.2z x M31.8,12.9l-6.7,2.3c-1,0.4-2.2-0.2-2.5-1.2l-2.3-6.7c-0.4-1,0.2-2.2,1.2-2.5l6.7-2.3c1-0.4,2.2,0.2,2.5,1.2l2.3,6.7C33.4,11.3,32.9,12.5,31.8,12.9z x M49.9,35.5l-1-3c-0.3-0.9-1.2-1.3-2-1l-18.2,6.3c1.9,1.2,3.2,3.2,3.6,5.5l16.7-5.7C49.8,37.3,50.2,36.4,49.9,35.5z x M24.3,39.1c-3,0-5.5,2.5-5.5,5.5c0,3,2.5,5.5,5.5,5.5s5.5-2.5,5.5-5.5C29.8,41.5,27.3,39.1,24.3,39.1z'
            }
        );
        svgs.add(
            new List<String>{
                'Full Width View',
                'M48.5,4h-45C2.7,4,2,4.7,2,5.5v5C2,11.3,2.7,12,3.5,12h45c0.8,0,1.5-0.7,1.5-1.5v-5C49.9,4.7,49.3,4,48.5,4z x M10.7,16h-7c-0.8,0-1.5,0.7-1.5,1.5v29.8c0,0.8,0.7,1.5,1.5,1.5h7c0.8,0,1.5-0.7,1.5-1.5V17.5C12.2,16.7,11.5,16,10.7,16z x M48.5,16h-7c-0.8,0-1.5,0.7-1.5,1.5v29.8c0,0.8,0.7,1.5,1.5,1.5h7c0.8,0,1.5-0.7,1.5-1.5V17.5C50,16.7,49.3,16,48.5,16z x M34.5,16H17.7c-0.8,0-1.5,0.7-1.5,1.5v29.8c0,0.8,0.7,1.5,1.5,1.5h16.8c0.8,0,1.5-0.7,1.5-1.5V17.5C36,16.7,35.3,16,34.5,16z'
            }
        );
        svgs.add(
            new List<String>{
                'Global Constant',
                'M28.6,28.2c2.6-2,5.4-2.3,7.3-2.3l7.1-0.1c0.7,0,1.4,0,2.1-0.1c0.9,0,1.8-0.1,2.6-0.1c0.6,0,1,0,1.5,0h0.6l0,0C49.9,12.5,39.1,1.8,26,1.8S2.1,12.5,2.1,25.6c0,11.5,8.2,21.1,19,23.4c-0.2-0.8-0.1-1.6,0.1-2.4c0.3-1.4,1.1-2.5,1.9-3.3c-2.5-2.5-4.6-8.2-5-15.2h5.5v6.4c0.2-0.5,0.3-1,0.6-1.4c1-1.4,2.1-2.9,3.4-4.2c0.2-0.2,0.5-0.4,0.6-0.6L28.6,28.2z M44.9,23.4h-6.3c-0.2-5.7-1.5-10.6-3.4-14.3C40.5,12,44.1,17.3,44.9,23.4z M28.4,7.7c2.7,2.3,5.1,8.2,5.5,15.7h-5.5V7.7z M23.6,7.7v15.7h-5.5C18.5,15.9,20.9,10,23.6,7.7z M7.1,28.2h6.3c0.2,5.7,1.5,10.6,3.4,14.3C11.5,39.6,7.9,34.3,7.1,28.2z M13.3,23.4H7.1c0.8-6.1,4.5-11.4,9.7-14.3C14.9,12.8,13.7,17.8,13.3,23.4z x M24.6,41.9c0.3-0.2,0.6-0.6,0.8-0.7c0.2-0.3,0.6-0.6,0.8-1c-1.3-0.6-2.2-1.7-2.6-3v5.7C24,42.4,24.3,42.1,24.6,41.9z x M49.6,29.9c-0.2-0.2-0.3-0.2-0.5-0.2l0,0c-2-0.1-4.1,0.1-6,0.1L36,29.9c-2.1,0-3.9,0.5-5.6,2c-1,1-2.1,2.3-2.9,3.5c-0.1,0.2-0.2,0.3-0.2,0.5c0,0.5,0.4,0.8,0.8,0.8c0.5,0,0.6-0.3,0.8-0.6s0.5-0.6,0.8-1c1.1-1,2.6-1.6,4.1-1.4c-1.3,3.5-3,7.5-5.6,10.3c-1,1.1-2.9,2.3-3.3,3.9c-0.4,1.7,1.3,2.1,2.5,1.6c1.6-0.6,2.5-2.3,3.4-3.7c1-1.8,1.9-3.6,2.6-5.4c0.8-1.8,1.6-3.7,2.3-5.5c0.5-1.1,0.6-1.1,1.8-1.1h3.1c-1.1,2.5-2.2,5.1-3.3,7.7c-0.8,2-2.2,4.9-1.2,7c1,2.1,3.8,1.4,5.3,0.2c1.6-1.1,2.5-2.9,3.4-4.5c0.2-0.3,0.3-0.6,0.2-1c-0.2-0.3-0.4-0.5-0.7-0.5c-0.7,0-0.9,0.9-1.1,1.4c-0.4,0.9-1.4,1.7-2.4,1.5c-2.3-0.3-0.2-4.5,0.2-5.7c0.4-1.2,0.9-2.3,1.4-3.4c0.3-0.6,0.6-1.4,0.9-2c0.4-0.8,0.4-0.8,1.4-0.9c0.8,0,3.1,0.4,3.8-0.1c0.6-0.4,0.9-1.8,1.2-2.8l0,0C49.9,30.4,49.9,30.2,49.6,29.9z'
            }
        );
        svgs.add(
            new List<String>{
                'Graph',
                'M2,45.5c0,2.2,1.8,4,4,4h42.4c0.9,0,1.6-0.7,1.6-1.6v-2.8c0-0.9-0.7-1.6-1.6-1.6l-38.9,0C8.7,43.5,8,42.8,8,42L8,4.1c0-0.9-0.7-1.6-1.6-1.6H3.6C2.7,2.5,2,3.2,2,4.1V45.5z x M49.7,14.1c0-1.7-1.3-3-3-3c-0.9,0-1.6,0.4-2.2,0.9l-8.6,8.6L30,15c0,0,0,0,0,0l-0.1-0.1c-0.1-0.1-0.1-0.1-0.2-0.2c-0.1,0-0.1-0.1-0.2-0.1c-0.1-0.1-0.2-0.1-0.3-0.2c-0.1,0-0.1-0.1-0.2-0.1c-0.1,0-0.2-0.1-0.4-0.1c-0.1,0-0.1,0-0.2-0.1c-0.2,0-0.4-0.1-0.6-0.1c-0.2,0-0.4,0-0.6,0.1c-0.1,0-0.1,0-0.2,0.1c-0.1,0-0.3,0.1-0.4,0.1c-0.1,0-0.1,0.1-0.2,0.1c-0.1,0.1-0.2,0.1-0.3,0.2c-0.1,0-0.1,0.1-0.2,0.2c-0.1,0.1-0.2,0.1-0.3,0.2c0,0,0,0,0,0L14.2,26.5c-0.6,0.6-1,1.3-1,2.2c0,1.7,1.3,3,3,3c0.7,0,1.4-0.3,1.9-0.7l9.8-9.7l5.7,5.6c0,0,0,0,0,0c0.1,0.1,0.2,0.1,0.3,0.2c0.1,0.1,0.1,0.1,0.2,0.2c0.1,0.1,0.2,0.1,0.3,0.2c0.1,0,0.1,0.1,0.2,0.1c0.1,0.1,0.3,0.1,0.4,0.1c0.1,0,0.1,0,0.2,0.1c0.2,0,0.4,0.1,0.6,0.1c0.2,0,0.4,0,0.6-0.1c0.1,0,0.1,0,0.2,0c0.1,0,0.2-0.1,0.4-0.1c0.1,0,0.1-0.1,0.2-0.1c0.1,0,0.2-0.1,0.3-0.2c0.1,0,0.1-0.1,0.2-0.1c0,0,0.1-0.1,0.1-0.1l0.1-0.1C37.9,27.1,38,27,38,27l10.8-10.7C49.3,15.7,49.7,15,49.7,14.1z'
            }
        );
        svgs.add(
            new List<String>{
                'Groups',
                'M15.9,28c-1.4-2.1-2.1-4.5-2.1-7.2c0-4.6,1.9-8.4,4.9-10.7c-1-1.8-3-3.1-5.6-3.1c-4.4,0-6.9,3.6-6.9,7.7c0,2.2,0.7,4.1,2.2,5.4c0.8,0.8,1.5,1.8,1.5,2.8S9.5,24.9,7,26c-3.6,1.6-6.9,3.8-7,7.1C0.1,35.3,1.5,37,3.6,37h3.3c0.5,0,1-0.3,1.3-0.8c1.6-2.9,4.6-4.7,7.1-6C16.2,29.8,16.4,28.7,15.9,28z x M45.1,26c-2.5-1.1-2.9-2-2.9-3.1s0.7-2.1,1.5-2.8c1.5-1.4,2.2-3.2,2.2-5.4c0-4.1-2.4-7.7-6.9-7.7c-2.6,0-4.6,1.3-5.7,3.1c3,2.3,4.9,6.1,4.9,10.7c0,2.7-0.7,5.1-2.1,7.2c-0.5,0.8-0.2,1.8,0.6,2.2c2.5,1.2,5.5,3.1,7.1,6c0.3,0.5,0.8,0.8,1.3,0.8h3.3c2.1,0,3.5-1.7,3.5-3.9C52,29.8,48.7,27.6,45.1,26z x M32.7,33.3c-2.7-1.2-3.2-2.3-3.2-3.4c0-1.2,0.8-2.3,1.7-3.1c1.6-1.5,2.5-3.6,2.5-6c0-4.5-2.7-8.4-7.6-8.4s-7.6,3.9-7.6,8.4c0,2.4,0.9,4.5,2.5,6c0.9,0.9,1.7,2,1.7,3.1c0,1.2-0.4,2.2-3.2,3.4c-4,1.7-7.8,3.6-7.9,7.2c0,2.4,1.8,4.4,4.1,4.4h10.4h10.4c2.3,0,4.1-2,4.1-4.4C40.5,37,36.7,35.1,32.7,33.3z'
            }
        );
        svgs.add(
            new List<String>{
                'Help Center',
                'M25.7,2C12.4,2.2,1.9,13.1,2,26.3C2.2,39.6,13.1,50.1,26.3,50C39.6,49.8,50.1,38.9,50,25.7C49.8,12.4,38.9,1.9,25.7,2z M25.7,5.2c3.6-0.1,7,0.8,9.9,2.3l-3.2,5.4c-1.9-1-4.1-1.5-6.4-1.5s-4.5,0.5-6.4,1.5l-3.2-5.4C19.2,6.1,22.3,5.2,25.7,5.2z M12.9,32.4l-5.4,3.2c-1.4-2.8-2.3-6-2.3-9.4c-0.1-3.6,0.8-7,2.3-9.9l5.4,3.2c-1,1.9-1.5,4.1-1.5,6.4S11.9,30.5,12.9,32.4z M26.3,46.8c-3.6,0.1-7-0.8-9.9-2.3l3.2-5.4c1.9,1,4.1,1.5,6.4,1.5s4.5-0.5,6.4-1.5l3.2,5.4C32.8,45.9,29.7,46.8,26.3,46.8z M26,37.5c-6.4,0-11.5-5.2-11.5-11.5c0-6.4,5.2-11.5,11.5-11.5c6.4,0,11.5,5.2,11.5,11.5C37.5,32.4,32.4,37.5,26,37.5z M39.1,32.4c1-1.9,1.5-4.1,1.5-6.4s-0.5-4.5-1.5-6.4l5.4-3.2c1.4,2.8,2.3,6,2.3,9.4c0.1,3.6-0.8,7-2.3,9.9L39.1,32.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Help',
                'M28.4,38h-5c-0.8,0-1.4-0.6-1.4-1.4v-1.5c0-4.2,2.7-8,6.7-9.4c1.2-0.4,2.3-1.1,3.2-2.1c5-6,0.4-13.2-5.6-13.4c-2.2-0.1-4.3,0.7-5.9,2.2c-1.3,1.2-2.1,2.7-2.3,4.4c-0.1,0.6-0.7,1.1-1.5,1.1h-5c-0.9,0-1.6-0.7-1.5-1.6c0.4-3.8,2.1-7.2,4.8-9.9c3.2-3,7.3-4.6,11.7-4.5c8.3,0.3,15.1,7.1,15.4,15.4c0.3,7-4,13.3-10.5,15.7c-0.9,0.4-1.5,1.1-1.5,2v1.5C30,37.4,29.2,38,28.4,38z x M30,48.5c0,0.8-0.7,1.5-1.5,1.5h-5c-0.8,0-1.5-0.7-1.5-1.5v-5c0-0.8,0.7-1.5,1.5-1.5h5c0.8,0,1.5,0.7,1.5,1.5V48.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Hide',
                'M51.8,25.1c-1.6-3.2-3.7-6.1-6.3-8.4L37,25.1c0,0.3,0,0.6,0,0.9c0,6.1-4.9,11-11,11c-0.3,0-0.6,0-0.9,0l-5.4,5.4c2,0.4,4.1,0.7,6.2,0.7c11.3,0,21.1-6.6,25.8-16.1C52.1,26.3,52.1,25.7,51.8,25.1z x M48.5,5.6l-2.1-2.1C45.8,2.9,44.7,3,44,3.8l-7.3,7.3C33.4,9.7,29.8,9,26,9C14.7,9,4.9,15.6,0.2,25.1c-0.3,0.6-0.3,1.3,0,1.8c2.2,4.5,5.5,8.2,9.6,11L3.8,44c-0.7,0.7-0.8,1.8-0.3,2.4l2.1,2.1C6.2,49.1,7.3,49,8,48.2L48.2,8C49,7.3,49.1,6.2,48.5,5.6z M15,26c0-6.1,4.9-11,11-11c2,0,3.8,0.5,5.4,1.4l-3,3C27.6,19.2,26.8,19,26,19c-3.9,0-7,3.1-7,7c0,0.8,0.2,1.6,0.4,2.4l-3,3C15.5,29.8,15,28,15,26z'
            }
        );
        svgs.add(
            new List<String>{
                'Hide Mobile',
                'M36.1,25.3v14.1c0,0.7-0.6,1.4-1.4,1.4H20.6L12,49.4c0.6,0.4,1.3,0.6,2,0.6h24c2,0,3.7-1.7,3.7-3.7V19.7L36.1,25.3z M26,48.1c-1.6,0-2.8-1.2-2.8-2.8s1.2-2.8,2.8-2.8s2.8,1.2,2.8,2.8S27.6,48.1,26,48.1z x M10.3,45.6l5.7-5.7c0,0,0,0,0-0.1l20.2-20.2v0.1l5.5-5.5v-0.1l7-7c0.7-0.6,0.8-1.7,0.3-2.2L47,3c-0.6-0.6-1.6-0.5-2.2,0.3l-3.1,3.1V5.7C41.7,3.7,40,2,38,2H14c-2,0-3.7,1.7-3.7,3.7v32.1l-7.1,7.1C2.6,45.5,2.5,46.5,3,47L4.9,49c0.6,0.6,1.6,0.5,2.2-0.3L10.3,45.6L10.3,45.6z M15.8,10.8c0-0.7,0.6-1.4,1.4-1.4h17.5c0.7,0,1.4,0.6,1.4,1.4v1.2L15.8,32.2V10.8z'
            }
        );
        svgs.add(
            new List<String>{
                'Hierarchy',
                'M23.1,23H10.8c-0.7,0-1.4,0.6-1.4,1.3v10.5H5.3c-0.7,0-1.4,0.7-1.4,1.4v10c0,0.7,0.7,1.4,1.4,1.4H19c0.7,0,1.4-0.7,1.4-1.4v-10c0-0.7-0.7-1.4-1.4-1.4h-4.1v-6.4h21.9v6.4h-4.1c-0.7,0-1.4,0.7-1.4,1.4v10c0,0.7,0.7,1.4,1.4,1.4h13.7c0.7,0,1.3-0.7,1.3-1.4v-10c0-0.7-0.6-1.4-1.3-1.4h-4.2V24.3c0-0.7-0.7-1.3-1.4-1.3H28.6v-6.4h4.1c0.7,0,1.3-0.7,1.3-1.4v-10c0-0.7-0.6-1.4-1.3-1.4H19c-0.7,0-1.4,0.7-1.4,1.4v10c0,0.7,0.7,1.4,1.4,1.4h4.2V23z'
            }
        );
        svgs.add(
            new List<String>{
                'Holiday Operating Hours',
                'm38.71 25.59a11.3 11.3 0 0 1 11.29 11v.29a11.29 11.29 0 0 1 -11 11.29h-.29a11.3 11.3 0 0 1 -.3-22.59zm-.45 3.08v.1l-1.66 5.32a.4.4 0 0 1 -.4.32h-5.43a.58.58 0 0 0 -.39 1l.07.06 4.31 3.18a.55.55 0 0 1 .2.51v.09l-2 5.43a.53.53 0 0 0 .74.65h.07l4.67-3.45a.53.53 0 0 1 .55-.06l.08.06 4.63 3.45a.52.52 0 0 0 .83-.51v-.09l-2-5.43a.56.56 0 0 1 .11-.53l.07-.07 4.29-3.27a.57.57 0 0 0 -.23-1h-5.44a.52.52 0 0 1 -.45-.23v-.09l-1.67-5.31a.52.52 0 0 0 -.95-.13zm-16.42-25.67a19.89 19.89 0 0 1 19.84 19.84v.24a14.26 14.26 0 0 0 -2.47-.31h-.9v-.25a16.47 16.47 0 1 0 -16.47 16.79 16.32 16.32 0 0 0 2.91-.26 14.19 14.19 0 0 0 .92 3.26 19.36 19.36 0 0 1 -3.83.37 19.84 19.84 0 0 1 0-39.68zm.16 11.3a1.06 1.06 0 0 1 1 1v6.7a1.06 1.06 0 0 0 .27.76l3.81 3.93a1 1 0 0 1 0 1.45l-1.43 1.44a1 1 0 0 1 -1.43 0l-5-5.1a1.4 1.4 0 0 1 -.28-.76v-8.38a1.06 1.06 0 0 1 1-1h2.06z'
            }
        );
        svgs.add(
            new List<String>{
                'Home',
                'M49,27h-5v22c0,0.6-0.4,1-1,1H33c-0.6,0-1-0.4-1-1V32H20v17c0,0.6-0.4,1-1,1H9c-0.6,0-1-0.4-1-1V27H3c-0.4,0-0.8-0.2-0.9-0.6C1.9,26,2,25.6,2.3,25.3l23-23c0.4-0.4,1.1-0.4,1.4,0l23,23c0.3,0.3,0.3,0.7,0.2,1.1S49.4,27,49,27z'
            }
        );
        svgs.add(
            new List<String>{
                'Identity',
                'M46,8H34.9c0,0,0.1,0.7,0.1,1c0,3.9-3.1,7-7,7h-6c-3.9,0-7-3.1-7-7c0-0.3,0-1,0.1-1H6c-2.2,0-4,1.8-4,4v30c0,2.2,1.8,4,4,4h40c2.2,0,4-1.8,4-4V12C50,9.8,48.2,8,46,8z M21.7,38H16h-5.7C9,38,8,36.8,8,35.5c0-2,2.1-3.1,4.3-4c1.5-0.6,1.7-1.2,1.7-1.9c0-0.6-0.4-1.2-0.9-1.7c-0.9-0.8-1.4-2-1.4-3.3c0-2.5,1.5-4.6,4.2-4.6s4.2,2.1,4.2,4.6c0,1.3-0.5,2.5-1.4,3.3c-0.5,0.5-0.9,1.1-0.9,1.7c0,0.6,0.2,1.2,1.7,1.9c2.2,0.9,4.3,2,4.3,4C24,36.8,23,38,21.7,38z M44,34c0,0.6-0.4,1-1,1H29c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h14c0.6,0,1,0.4,1,1V34z M46,26c0,0.6-0.4,1-1,1H29c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h16c0.6,0,1,0.4,1,1V26z x M22,12h6c1.7,0,3-1.3,3-3s-1.3-3-3-3h-6c-1.7,0-3,1.3-3,3S20.3,12,22,12z'
            }
        );
        svgs.add(
            new List<String>{
                'Image',
                'M50,10c0-2.2-1.8-4-4-4H6c-2.2,0-4,1.8-4,4v32c0,2.2,1.8,4,4,4h40c2.2,0,4-1.8,4-4V10z M39.6,38h-29c-1.2,0-1.9-1.3-1.3-2.3l8.8-15.3c0.4-0.7,1.3-0.7,1.7,0l5.3,9.1c0.4,0.6,1.3,0.7,1.7,0.1l4.3-6.2c0.4-0.6,1.3-0.6,1.7,0L40.7,36C41.3,36.9,40.7,38,39.6,38z M37,20c-2.2,0-4-1.8-4-4s1.8-4,4-4s4,1.8,4,4S39.2,20,37,20z'
            }
        );
        svgs.add(
            new List<String>{
                'In App Assistant',
                'M49.9,33.6l-2-4.2l2-4.2c0.2-0.3,0-0.8-0.3-0.9c-0.1,0-0.2-0.1-0.3-0.1h-6.5c-0.5-1.3-1.8-4.5-3-6.3c-1.5-2.4-3.2-4.4-5.2-6c-2.3-1.9-4.9-3.5-7.9-4.7L26,7.1l-0.7,0.2c-0.1,0-1.2,0.4-2.9,1.2c-1.4,0.7-3,1.7-4.6,3c-3.1,2.5-5.5,5.5-7.2,9c-0.5,1.1-1.1,2.4-1.6,3.8H2.7c-0.1,0-0.2,0-0.3,0.1c-0.3,0.1-0.5,0.6-0.4,0.9l1.8,4.2l-1.8,4.2C2,33.8,2,33.8,2,33.9c0,0.4,0.3,0.7,0.7,0.7h4.5c0,0.7,0,0.9,0,1.2c0,0.1,0,0.3,0,0.6c0,0.7,0,1.5,0.1,2v1.3l1.2,0.7c0.1,0,2,1.1,5.1,2.2c2.8,1,7.3,2.2,12.7,2.2c4.7,0,9.3-0.9,13.7-2.7c1.3-0.5,2.5-1.1,3.6-1.7l1-0.5l0.2-0.8l0.1-0.7c0-0.3,0-0.7,0-1l0-0.1l0-1c0-0.4,0-0.6-0.1-0.8c0-0.2-0.1-0.4-0.1-1h4.6c0.4,0,0.7-0.3,0.7-0.7C50,33.8,50,33.7,49.9,33.6z M41.4,37.2c0,0.2,0,0.4-0.1,0.6c-0.9,0.5-1.8,0.9-2.7,1.3c-4,1.6-8.1,2.4-12.4,2.4c-4.9,0-9-1.1-11.6-2c-1.9-0.7-3.3-1.3-4-1.7c0-0.4,0-0.9,0-1.3c0-0.4,0-0.6,0-0.8c0-0.3,0-0.5,0.1-2.6c0.2-2.9,0.9-5.6,1.4-7.1c0.5-1.5,1.1-2.9,1.6-4c1.5-3.1,3.6-5.6,6.3-7.8c1.7-1.4,3.1-2.2,3.9-2.6c0.9-0.4,1.6-0.7,2-0.9c2.4,1,4.5,2.3,6.4,3.9c1.7,1.4,3.2,3.1,4.5,5.3c1,1.6,2.4,5,2.8,6c0,0,1.3,4.2,1.4,7c0.1,2.2,0.1,2.6,0.2,3.1c0,0.2,0,0.3,0.1,0.5V37.2z x M25.8,38c-0.6,0-1-0.2-1.4-0.5c-0.4-0.4-0.6-0.9-0.6-1.5c0-0.6,0.2-1.1,0.6-1.4c0.4-0.4,0.9-0.6,1.5-0.6c0.6,0,1.1,0.2,1.4,0.6c0.4,0.4,0.6,0.9,0.6,1.4c0,0.6-0.2,1.1-0.6,1.5C26.8,37.9,26.3,38,25.8,38z x M19.1,23.2c0-0.9,0.3-1.7,0.8-2.6c0.6-0.9,1.4-1.6,2.4-2.2c1.1-0.6,2.3-0.9,3.7-0.9c1.3,0,2.5,0.2,3.5,0.7c1,0.5,1.8,1.1,2.3,2c0.5,0.8,0.8,1.7,0.8,2.7c0,0.8-0.2,1.4-0.5,2c-0.3,0.6-0.7,1.1-1.1,1.5c-0.4,0.4-1.2,1.1-2.3,2.1c-0.3,0.3-0.6,0.5-0.7,0.7c-0.2,0.2-0.3,0.4-0.4,0.6c-0.1,0.2-0.2,0.4-0.2,0.5c0,0.2-0.1,0.5-0.2,0.9c-0.2,0.9-0.7,1.4-1.6,1.4c-0.5,0-0.9-0.2-1.2-0.5C24.1,32,24,31.5,24,30.9c0-0.8,0.1-1.4,0.4-2c0.2-0.6,0.5-1,0.9-1.5c0.4-0.4,0.9-0.9,1.6-1.5c0.6-0.5,1-0.9,1.3-1.1c0.3-0.3,0.5-0.5,0.7-0.9c0.2-0.3,0.3-0.7,0.3-1c0-0.7-0.3-1.3-0.8-1.8s-1.2-0.7-2.1-0.7c-1,0-1.7,0.3-2.2,0.8c-0.5,0.5-0.9,1.2-1.2,2.2c-0.3,1-0.9,1.5-1.8,1.5c-0.5,0-0.9-0.2-1.3-0.5C19.3,24,19.1,23.6,19.1,23.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Inbox',
                'M50,8c0-2.2-1.8-4-4-4H6C3.8,4,2,5.8,2,8v36c0,2.2,1.8,4,4,4h40c2.2,0,4-1.8,4-4V8z M19,35c0,0.6-0.4,1-1,1H9c-0.6,0-1-0.4-1-1v-4c0-0.6,0.4-1,1-1h9c0.6,0,1,0.4,1,1V35z M19,25c0,0.6-0.4,1-1,1H9c-0.6,0-1-0.4-1-1v-4c0-0.6,0.4-1,1-1h9c0.6,0,1,0.4,1,1V25z M19,15c0,0.6-0.4,1-1,1H9c-0.6,0-1-0.4-1-1v-4c0-0.6,0.4-1,1-1h9c0.6,0,1,0.4,1,1V15z M44,41c0,0.6-0.4,1-1,1H24c-0.6,0-1-0.4-1-1V11c0-0.6,0.4-1,1-1h19c0.6,0,1,0.4,1,1V41z'
            }
        );
        svgs.add(
            new List<String>{
                'Incoming Call',
                'M48.5,37.9L42.4,33c-1.4-1.1-3.4-1.2-4.8-0.1l-5.2,3.8c-0.6,0.5-1.5,0.4-2.1-0.2l-7.8-7l-7-7.8c-0.6-0.6-0.6-1.4-0.2-2.1l3.8-5.2c1.1-1.4,1-3.4-0.1-4.8l-4.9-6.1c-1.5-1.8-4.2-2-5.9-0.3L3,8.4c-0.8,0.8-1.2,1.9-1.2,3c0.5,10.2,5.1,19.9,11.9,26.7S30.2,49.5,40.4,50c1.1,0.1,2.2-0.4,3-1.2l5.2-5.2C50.5,42.1,50.4,39.3,48.5,37.9z x M29.6,24H45c1,0,1.3-1.1,0.5-1.9l-4.9-5l9-9.1c0.5-0.5,0.5-1.4,0-1.9l-3.7-3.7c-0.5-0.5-1.3-0.5-1.9,0l-9.1,9.1l-5.1-4.9C29.1,5.7,28,6,28,7v15.3C28,23,28.9,24,29.6,24z'
            }
        );
        svgs.add(
            new List<String>{
                'Info',
                'M26,2C12.7,2,2,12.7,2,26s10.7,24,24,24s24-10.7,24-24S39.3,2,26,2z M26,14.1c1.7,0,3,1.3,3,3s-1.3,3-3,3s-3-1.3-3-3S24.3,14.1,26,14.1z M31,35.1c0,0.5-0.4,0.9-1,0.9h-3c-0.4,0-3,0-3,0h-2c-0.5,0-1-0.3-1-0.9v-2c0-0.5,0.4-1.1,1-1.1l0,0c0.5,0,1-0.3,1-0.9v-4c0-0.5-0.4-1.1-1-1.1l0,0c-0.5,0-1-0.3-1-0.9v-2c0-0.5,0.4-1.1,1-1.1h6c0.5,0,1,0.5,1,1.1v8c0,0.5,0.4,0.9,1,0.9l0,0c0.5,0,1,0.5,1,1.1V35.1z'
            }
        );
        svgs.add(
            new List<String>{
                'Info Alt',
                'M26,2C12.7,2,2,12.7,2,26s10.7,24,24,24s24-10.7,24-24S39.3,2,26,2z M26,44C16,44,8,36,8,26S16,8,26,8s18,8,18,18S36,44,26,44z x M26,14.1c1.7,0,3,1.3,3,3s-1.3,3-3,3s-3-1.3-3-3S24.3,14.1,26,14.1z x M31,35.1c0,0.5-0.4,0.9-1,0.9h-8c-0.5,0-1-0.3-1-0.9v-2c0-0.5,0.4-1.1,1-1.1c0.5,0,1-0.3,1-0.9v-4c0-0.5-0.4-1.1-1-1.1c-0.5,0-1-0.3-1-0.9v-2c0-0.5,0.4-1.1,1-1.1h6c0.5,0,1,0.5,1,1.1v8c0,0.5,0.4,0.9,1,0.9c0.5,0,1,0.5,1,1.1V35.1z'
            }
        );
        svgs.add(
            new List<String>{
                'Insert Tag Field',
                'M16.3,12.2L14,10.3c-0.7-0.5-1.5-0.4-2.1,0.2L0.3,25.1c-0.4,0.5-0.4,1.3,0,1.9L12,41.5c0.5,0.6,1.4,0.8,2.1,0.2l2.3-1.9c0.7-0.5,0.8-1.5,0.2-2.1L7.2,26l9.5-11.7C17.1,13.7,17,12.8,16.3,12.2z x M51.7,25.1L40,10.6c-0.5-0.6-1.4-0.8-2.1-0.2l-2.3,1.9c-0.7,0.5-0.8,1.5-0.2,2.1l9.5,11.7l-9.5,11.7c-0.5,0.6-0.4,1.6,0.2,2.1l2.3,1.9c0.7,0.5,1.5,0.4,2.1-0.2L51.7,27C52.1,26.3,52.1,25.6,51.7,25.1z x M31.6,10.8l-3-0.7c-0.8-0.2-1.7,0.3-1.9,1.1l-7.4,28.4c-0.2,0.8,0.3,1.6,1.1,1.8l3,0.7c0.8,0.2,1.7-0.3,1.9-1.1l7.4-28.4C32.9,11.7,32.4,11,31.6,10.8z'
            }
        );
        svgs.add(
            new List<String>{
                'Insert Template',
                'M48.5,38H44v-4.5c0-0.8-0.7-1.5-1.5-1.5h-3c-0.8,0-1.5,0.7-1.5,1.5V38h-4.5c-0.8,0-1.5,0.7-1.5,1.5v3c0,0.8,0.7,1.5,1.5,1.5H38v4.5c0,0.8,0.7,1.5,1.5,1.5h3c0.8,0,1.5-0.7,1.5-1.5V44h4.5c0.8,0,1.5-0.7,1.5-1.5v-3C50,38.7,49.3,38,48.5,38z x M34,29.5c0-0.8,0.7-1.5,1.5-1.5H38V6c0-2.2-1.8-4-4-4H6C3.8,2,2,3.8,2,6v28c0,2.2,1.8,4,4,4h22v-2.5c0-0.8,0.7-1.5,1.5-1.5H34V29.5z M16,11c0,0.6-0.4,1-1,1H9c-0.6,0-1-0.4-1-1V9c0-0.6,0.4-1,1-1h6c0.6,0,1,0.4,1,1V11z M28,27c0,0.6-0.4,1-1,1H9c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h18c0.6,0,1,0.4,1,1V27z M32,19c0,0.6-0.4,1-1,1H9c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h22c0.6,0,1,0.4,1,1V19z'
            }
        );
        svgs.add(
            new List<String>{
                'Internal Share',
                'M2.3,37.9c0,0.1,0,0.1,0,0.2c0,0.8,0.6,1.4,1.4,1.4c0.4,0,0.7-0.1,1-0.4c0,0,10.1-10.9,22.5-7.6v11c0,0.8,0.6,1.4,1.4,1.4c0.3,0,0.5-0.1,0.7-0.2l20.1-17.1c0.3-0.3,0.5-0.7,0.5-1.1c0-0.4-0.2-0.8-0.4-1L29.4,8.2C29.2,8.1,28.9,8,28.6,8c-0.8,0-1.4,0.6-1.4,1.4v10.3C27.1,19.7,7.3,16.7,2.3,37.9z'
            }
        );
        svgs.add(
            new List<String>{
                'Italic',
                'M38,12.3V11c0-1.1-0.9-2-2-2H22c-1.1,0-2,0.9-2,2v2c0,1.1,0.9,2,2,2h0c1.7,0,3,1.6,2.6,3.2L21,35.8c-0.3,1.3-1.4,2.2-2.6,2.2H16c-1.1,0-2,0.9-2,2v2c0,1.1,0.9,2,2,2h14c1.1,0,2-0.9,2-2v-2c0-1.1-0.9-2-2-2h0c-1.7,0-3-1.6-2.6-3.2L31,17.2c0.3-1.3,1.4-2.2,2.6-2.2h1.7C36.8,15,38,13.8,38,12.3z'
            }
        );
        svgs.add(
            new List<String>{
                'Jump To Bottom',
                'M40.6,30.4L27.1,44c-0.6,0.6-1.6,0.6-2.2,0L11.4,30.4c-0.6-0.6-0.6-1.6,0-2.2l2.2-2.2c0.6-0.6,1.6-0.6,2.2,0l9.1,9.4c0.6,0.6,1.6,0.6,2.2,0l9.1-9.3c0.6-0.6,1.6-0.6,2.2,0l2.2,2.2C41.1,28.9,41.1,29.8,40.6,30.4z x M40.6,12.3L27.1,26.1c-0.6,0.6-1.6,0.6-2.2,0L11.4,12.3c-0.6-0.6-0.6-1.6,0-2.2l2.2-2.2c0.6-0.6,1.6-0.6,2.2,0l9.1,9.4c0.6,0.6,1.6,0.6,2.2,0L36.2,8c0.6-0.6,1.6-0.6,2.2,0l2.2,2.2C41.1,10.8,41.1,11.8,40.6,12.3z'
            }
        );
        svgs.add(
            new List<String>{
                'Jump To Left',
                'M21.5,40.6,7.9,27.1a1.57,1.57,0,0,1,0-2.2L21.5,11.4a1.57,1.57,0,0,1,2.2,0l2.2,2.2a1.57,1.57,0,0,1,0,2.2l-9.4,9.1a1.57,1.57,0,0,0,0,2.2l9.3,9.1a1.57,1.57,0,0,1,0,2.2l-2.2,2.2A1.66,1.66,0,0,1,21.5,40.6Z x M39.6,40.6,25.8,27.1a1.57,1.57,0,0,1,0-2.2L39.6,11.4a1.57,1.57,0,0,1,2.2,0L44,13.6a1.57,1.57,0,0,1,0,2.2l-9.4,9.1a1.57,1.57,0,0,0,0,2.2l9.3,9.1a1.57,1.57,0,0,1,0,2.2l-2.2,2.2A1.66,1.66,0,0,1,39.6,40.6Z'
            }
        );
        svgs.add(
            new List<String>{
                'Jump To Right',
                'M30.4,11.3,44,24.8A1.57,1.57,0,0,1,44,27L30.4,40.5a1.57,1.57,0,0,1-2.2,0L26,38.3a1.57,1.57,0,0,1,0-2.2L35.4,27a1.57,1.57,0,0,0,0-2.2l-9.3-9.1a1.57,1.57,0,0,1,0-2.2l2.2-2.2A1.66,1.66,0,0,1,30.4,11.3Z x M12.3,11.3,26.1,24.8a1.57,1.57,0,0,1,0,2.2L12.3,40.5a1.57,1.57,0,0,1-2.2,0L7.9,38.3a1.57,1.57,0,0,1,0-2.2L17.3,27a1.57,1.57,0,0,0,0-2.2L8,15.7a1.57,1.57,0,0,1,0-2.2l2.2-2.2A1.66,1.66,0,0,1,12.3,11.3Z'
            }
        );
        svgs.add(
            new List<String>{
                'Jump To Top',
                'M11.4,21.6L24.9,7.9c0.6-0.6,1.6-0.6,2.2,0l13.5,13.7c0.6,0.6,0.6,1.6,0,2.2L38.4,26c-0.6,0.6-1.6,0.6-2.2,0l-9.1-9.4c-0.6-0.6-1.6-0.6-2.2,0l-9.1,9.3c-0.6,0.6-1.6,0.6-2.2,0l-2.2-2.2C10.9,23.1,10.9,22.2,11.4,21.6z x M11.4,39.7L24.9,26c0.6-0.6,1.6-0.6,2.2,0l13.5,13.7c0.6,0.6,0.6,1.6,0,2.2l-2.2,2.2c-0.6,0.6-1.6,0.6-2.2,0l-9.1-9.4c-0.6-0.6-1.6-0.6-2.2,0L15.8,44c-0.6,0.6-1.6,0.6-2.2,0l-2.2-2.2C10.9,41.2,10.9,40.2,11.4,39.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Kanban',
                'M32,17.5c0-0.8-0.7-1.5-1.5-1.5h-9c-0.8,0-1.5,0.7-1.5,1.5v27c0,0.8,0.7,1.5,1.5,1.5h9c0.8,0,1.5-0.7,1.5-1.5V17.5z x M14,17.5c0-0.8-0.7-1.5-1.5-1.5h-9C2.7,16,2,16.7,2,17.5v31C2,49.3,2.7,50,3.5,50h9c0.8,0,1.5-0.7,1.5-1.5V17.5z x M50,17.5c0-0.8-0.7-1.5-1.5-1.5h-9c-0.8,0-1.5,0.7-1.5,1.5v23c0,0.8,0.7,1.5,1.5,1.5h9c0.8,0,1.5-0.7,1.5-1.5V17.5z x M50,3.5C50,2.7,49.3,2,48.5,2h-45C2.7,2,2,2.7,2,3.5v5C2,9.3,2.7,10,3.5,10h45c0.8,0,1.5-0.7,1.5-1.5V3.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Key Dates',
                'm46.8 19.6a1.6 1.6 0 0 1 1.59 1.45v24.15a4.82 4.82 0 0 1 -4.58 4.8h-35.41a4.82 4.82 0 0 1 -4.8-4.59v-24.21a1.6 1.6 0 0 1 1.45-1.59h41.75zm-21.38 4.63v.11l-2.18 6.86a.53.53 0 0 1 -.54.41h-6.93a.75.75 0 0 0 -.49 1.25l.08.07 5.56 4.07a.72.72 0 0 1 .25.67v.11l-2.55 7a.68.68 0 0 0 1 .83l.08-.06 6-4.45a.7.7 0 0 1 .73-.06l.09.06 6 4.45a.68.68 0 0 0 1.07-.67v-.1l-2.64-7a.72.72 0 0 1 .15-.7l.08-.08 5.56-4.09a.74.74 0 0 0 -.31-1.31h-7.04a.67.67 0 0 1 -.6-.31v-.1l-2.1-6.82a.67.67 0 0 0 -1.27-.14zm10.98-22.23a3.21 3.21 0 0 1 3.2 3.2v1.6h4a4.81 4.81 0 0 1 4.8 4.8v1.6a1.6 1.6 0 0 1 -1.6 1.6h-41.6a1.6 1.6 0 0 1 -1.6-1.6v-1.6a4.81 4.81 0 0 1 4.8-4.8h4v-1.6a3.2 3.2 0 0 1 6.4 0v1.6h14.4v-1.6a3.21 3.21 0 0 1 3.2-3.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Key',
                'M6.51,12a.77.77,0,0,1,1.41.48h0v.41c0,9,7.09,16.27,15.74,16.27h.71a1.53,1.53,0,0,1,1.57,1.06h0l4.41,12.69a2.13,2.13,0,0,1-.08,1.22h0l-2.36,5.45a.77.77,0,0,1-1,.41h0l-5.35-2.52a.84.84,0,0,1-.48-1h0l.63-2.52a.82.82,0,0,0-.39-1.06h0l-1.81-.81a.9.9,0,0,1-.39-1h0l.7-2.52a.82.82,0,0,0-.39-1.06h0l-1.26-.57a.79.79,0,0,1-.39-1h0l.79-2.36a.82.82,0,0,0-.4-1.06h0l-2.36-1.06A.8.8,0,0,1,15.4,31h0l-.55-1.54a11.11,11.11,0,0,1-5.43-2.12A11.74,11.74,0,0,1,5.25,14.79,10.21,10.21,0,0,1,6.51,12Zm5.55,2.54A11.28,11.28,0,0,1,23.8,2a11.38,11.38,0,0,1,10,7.6A10.64,10.64,0,0,1,34,16.09h0l12.7,13.27a1.4,1.4,0,0,1,.48,1.2h0V36.4a.76.76,0,0,1-.8.8h-6a.78.78,0,0,1-.8-.64h0L39.21,34a.75.75,0,0,0-.79-.8h-2a.78.78,0,0,1-.8-.64h0L35.22,30a.76.76,0,0,0-.8-.8H33.07a.79.79,0,0,1-.8-.72h0L32,26a.76.76,0,0,0-.8-.8H28.51A.73.73,0,0,1,28,25h0l-1.11-1.19a11.17,11.17,0,0,1-14.78-9.28ZM21.6,7.6a4,4,0,0,0,0,8,4,4,0,0,0,4-4A4,4,0,0,0,21.6,7.6Z'
            }
        );
        svgs.add(
            new List<String>{
                'Keypad',
                'M8.55,36.91A6.55,6.55,0,1,1,2,43.45,6.54,6.54,0,0,1,8.55,36.91Zm17.45,0a6.55,6.55,0,1,1-6.55,6.54A6.55,6.55,0,0,1,26,36.91Zm17.45,0a6.55,6.55,0,1,1-6.54,6.54A6.54,6.54,0,0,1,43.45,36.91ZM8.55,19.45A6.55,6.55,0,1,1,2,26,6.55,6.55,0,0,1,8.55,19.45Zm17.45,0A6.55,6.55,0,1,1,19.45,26,6.56,6.56,0,0,1,26,19.45Zm17.45,0A6.55,6.55,0,1,1,36.91,26,6.55,6.55,0,0,1,43.45,19.45ZM8.55,2A6.55,6.55,0,1,1,2,8.55,6.54,6.54,0,0,1,8.55,2ZM26,2a6.55,6.55,0,1,1-6.55,6.55A6.55,6.55,0,0,1,26,2ZM43.45,2a6.55,6.55,0,1,1-6.54,6.55A6.55,6.55,0,0,1,43.45,2Z'
            }
        );
        svgs.add(
            new List<String>{
                'Knowledge Base',
                'M9.5,35h13c0.8,0,1.5-0.7,1.5-1.5V10c0-1.7-1.8-3-3.2-3H9.5C8.7,7,8,7.7,8,8.5V32v1.5C8,34.3,8.7,35,9.5,35z x M49.2,11.6c-0.6-0.2-1.2,0.3-1.2,1v24.9c0,0.8-0.7,1.5-1.5,1.5h-41C4.7,39,4,38.3,4,37.5V12.7c0-0.7-0.8-1.2-1.4-0.9C1.1,12.5,0,14.1,0,16v23c0,2.2,1.8,4,4,4h16.5c0.8,0,1.5,0.7,1.5,1.5l0,0c0,0.8,0.7,1.5,1.5,1.5h5c0.8,0,1.5-0.7,1.5-1.5l0,0c0-0.8,0.7-1.5,1.5-1.5H48c2.2,0,4-1.8,4-4V16C52,13.9,51.3,12.1,49.2,11.6z x M29.5,35h13c0.8,0,1.5-0.7,1.5-1.5V32V8.5C44,7.7,43.3,7,42.5,7H31.2C29.7,7,28,8.3,28,10v23.5C28,34.3,28.7,35,29.5,35z'
            }
        );
        svgs.add(
            new List<String>{
                'Layers',
                'M36,20c0-2.2-1.8-4-4-4H6c-2.2,0-4,1.8-4,4v26c0,2.2,1.8,4,4,4h26c2.2,0,4-1.8,4-4V20z x M43,2H17c-3.9,0-7,3.1-7,7v3h6h20c2.2,0,4,1.8,4,4v20v6h3c3.9,0,7-3.1,7-7V9C50,5.1,46.9,2,43,2z'
            }
        );
        svgs.add(
            new List<String>{
                'Layout',
                'M48,50H4c-1.1,0-2-0.9-2-2V4c0-1.1,0.9-2,2-2h44c1.1,0,2,0.9,2,2v44C50,49.1,49.1,50,48,50z M6,46h40V6H6V46z x M39,20H13c-0.6,0-1-0.4-1-1v-6c0-0.6,0.4-1,1-1h26c0.6,0,1,0.4,1,1v6C40,19.6,39.6,20,39,20z x M19,40h-6c-0.6,0-1-0.4-1-1V27c0-0.6,0.4-1,1-1h6c0.6,0,1,0.4,1,1v12C20,39.6,19.6,40,19,40z x M39,40H27c-0.6,0-1-0.4-1-1V27c0-0.6,0.4-1,1-1h12c0.6,0,1,0.4,1,1v12C40,39.6,39.6,40,39,40z'
            }
        );
        svgs.add(
            new List<String>{
                'Layout Card',
                'M5.1,3.29A3.1,3.1,0,0,0,2,6.39V45.61a3.1,3.1,0,0,0,3.1,3.1H23.68a3.09,3.09,0,0,0,3.09-3.1V6.39a3.09,3.09,0,0,0-3.09-3.1ZM31.94,14.13a2.58,2.58,0,1,0,0,5.16H47.42a2.58,2.58,0,0,0,0-5.16ZM29.35,26a2.58,2.58,0,0,1,2.59-2.58H47.42a2.58,2.58,0,0,1,0,5.16H31.94A2.58,2.58,0,0,1,29.35,26Zm2.59,6.71a2.58,2.58,0,1,0,0,5.16H47.42a2.58,2.58,0,0,0,0-5.16Z'
            }
        );
        svgs.add(
            new List<String>{
                'Layout Tile',
                'M2,7.52A2.88,2.88,0,0,1,4.88,4.64H47.12A2.88,2.88,0,0,1,50,7.52v19.2a2.88,2.88,0,0,1-2.88,2.88H4.88A2.88,2.88,0,0,1,2,26.72Zm7.2,28.8a2.39,2.39,0,0,1,2.4-2.4H39.44a2.4,2.4,0,1,1,0,4.8H11.6A2.39,2.39,0,0,1,9.2,36.32Zm8.16,6.24a2.4,2.4,0,1,0,0,4.8H33.68a2.4,2.4,0,0,0,0-4.8Z'
            }
        );
        svgs.add(
            new List<String>{
                'Layout Banner',
                'M2,4.88A2.88,2.88,0,0,1,4.88,2H47.12A2.88,2.88,0,0,1,50,4.88V47.12A2.88,2.88,0,0,1,47.12,50H4.88A2.88,2.88,0,0,1,2,47.12ZM9.2,22.16a2.39,2.39,0,0,1,2.4-2.4H39.44a2.4,2.4,0,1,1,0,4.8H11.6A2.39,2.39,0,0,1,9.2,22.16Zm8.16,5.28a2.4,2.4,0,1,0,0,4.8H33.68a2.4,2.4,0,0,0,0-4.8Z'
            }
        );
        svgs.add(
            new List<String>{
                'Layout Overlap',
                'M5.29,4.82A2.83,2.83,0,0,1,8.12,2H29.76a2.83,2.83,0,0,1,2.83,2.82V10H20.35a4.23,4.23,0,0,0-4.23,4.24V36.82a4.23,4.23,0,0,0,4.23,4.24H32.59v6.12A2.83,2.83,0,0,1,29.76,50H8.12a2.83,2.83,0,0,1-2.83-2.82Zm15.06,7.53a1.89,1.89,0,0,0-1.88,1.89V36.82a1.89,1.89,0,0,0,1.88,1.89H44.82a1.89,1.89,0,0,0,1.89-1.89V14.24a1.89,1.89,0,0,0-1.89-1.89Z'
            }
        );
        svgs.add(
            new List<String>{
                'Leave Conference',
                'M25.7,22.4c-0.5,0.7-0.2,1.7,0.6,2.2c1.6,0.9,3.4,1.9,4.9,3.3c2.5-1.9,5.5-3,8.8-3.2c-1.1-1.9-3.4-3.2-5.8-4.3c-2.3-1-2.8-1.9-2.8-3c0-1,0.7-1.9,1.4-2.8c1.4-1.3,2.1-3.1,2.1-5.3c0.1-4-2.2-7.5-6.4-7.5c-2.5,0-4.2,1.3-5.4,3.1c2.9,2.2,4.6,6,4.6,10.3C27.6,18,26.9,20.4,25.7,22.4z x M31.8,34.7l6,6l-6,6c-0.6,0.6-0.6,1.6,0,2.1l0.7,0.7c0.6,0.6,1.6,0.6,2.1,0l6-6l6,6c0.6,0.6,1.6,0.6,2.1,0l0.7-0.7c0.6-0.6,0.6-1.6,0-2.1l-6-6l6-6c0.6-0.6,0.6-1.6,0-2.1l-0.7-0.7c-0.6-0.6-1.6-0.6-2.1,0l-6,6l-6-6c-0.6-0.6-1.6-0.6-2.1,0l-0.7,0.7C31.3,33.1,31.3,34.1,31.8,34.7z x M28.2,30.7c-1.4-1.4-3.5-2.3-5.6-3.3c-2.6-1.1-3-2.2-3-3.3c0-1.1,0.7-2.3,1.6-3.1c1.5-1.5,2.3-3.6,2.3-6c0-4.5-2.6-8.4-7.2-8.4h-0.5c-4.6,0-7.2,3.9-7.2,8.4c0,2.4,0.8,4.5,2.3,6c0.9,0.8,1.6,1.9,1.6,3.1c0,1.1-0.3,2.2-3,3.3c-3.8,1.7-7.3,3.4-7.5,7c0.2,2.5,1.9,4.4,4.1,4.4h18.6C25.2,35.7,26.4,32.9,28.2,30.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Light Bulb',
                'M24.12,2.69A16.11,16.11,0,0,0,9.69,17a15.9,15.9,0,0,0,5.85,13.65,4.92,4.92,0,0,1,1.87,3.82v.08a4,4,0,0,0,4.05,4h9a4,4,0,0,0,4.05-4v-.08a4.92,4.92,0,0,1,1.87-3.82,15.88,15.88,0,0,0,5.93-12.24C42.36,9.09,34,1.68,24.12,2.69ZM33,43.16H19a1.56,1.56,0,0,0-1.56,1.56,4.69,4.69,0,0,0,4.68,4.68h7.8a4.69,4.69,0,0,0,4.68-4.68A1.56,1.56,0,0,0,33,43.16Z'
            }
        );
        svgs.add(
            new List<String>{
                'Lightning Extension',
                'M47.6,37.6c-0.5-0.1-1.1-0.1-1.6-0.2c-0.1,0-0.2-0.1-0.2-0.2c-0.2-0.6-0.5-1.2-0.7-1.7c0-0.1,0-0.2,0-0.3c0.3-0.4,0.7-0.9,1-1.3c0.2-0.3,0.2-0.6-0.1-0.9c-0.6-0.6-1.2-1.2-1.8-1.8c-0.1-0.1-0.3-0.2-0.4-0.2s-0.3,0.1-0.4,0.2c-0.4,0.3-0.9,0.7-1.3,1c-0.1,0-0.1,0.1-0.1,0.1h-0.1c-0.6-0.2-1.1-0.5-1.7-0.7c-0.1,0-0.2-0.1-0.2-0.2c-0.1-0.5-0.1-1-0.2-1.5c0-0.3-0.1-0.5-0.4-0.7c-0.1-0.1-0.2-0.1-0.2-0.1c-0.9,0-1.7,0-2.6,0c-0.2,0-0.3,0-0.4,0.1c-0.2,0.2-0.4,0.4-0.4,0.7c0,0.5-0.1,1-0.2,1.5c0,0.1-0.1,0.2-0.2,0.2c-0.6,0.2-1.1,0.5-1.7,0.7h-0.1c-0.1,0-0.1,0-0.2-0.1c-0.4-0.3-0.8-0.7-1.3-1C32,31.1,31.9,31,31.7,31s-0.3,0.1-0.5,0.2c-0.6,0.6-1.2,1.2-1.8,1.8c-0.3,0.3-0.3,0.6-0.1,0.9c0.3,0.4,0.7,0.8,1,1.3c0.1,0.1,0.1,0.2,0,0.3c-0.2,0.6-0.5,1.1-0.7,1.7c0,0.1-0.1,0.2-0.2,0.2c-0.5,0.1-1,0.1-1.5,0.2c-0.3,0-0.6,0.2-0.7,0.5c0,1,0,2,0,3c0.2,0.3,0.4,0.4,0.7,0.5c0.5,0,1,0.1,1.5,0.2c0.1,0,0.2,0.1,0.2,0.2c0.2,0.6,0.5,1.1,0.7,1.7c0,0.1,0.1,0.2,0,0.3c-0.3,0.4-0.7,0.9-1,1.3c-0.2,0.3-0.2,0.6,0.1,0.9c0.6,0.6,1.2,1.2,1.8,1.8c0.2,0.2,0.3,0.2,0.5,0.2c0.1,0,0.3-0.1,0.4-0.2c0.4-0.3,0.8-0.7,1.3-1c0.1,0,0.1-0.1,0.2-0.1h0.1c0.6,0.2,1.1,0.5,1.7,0.7c0.1,0,0.2,0.1,0.2,0.2c0.1,0.5,0.1,1.1,0.2,1.6c0,0.4,0.3,0.6,0.7,0.6s0.9,0,1.3,0c0.4,0,0.8,0,1.2,0s0.6-0.2,0.7-0.6c0.1-0.5,0.1-1.1,0.2-1.6c0-0.1,0.1-0.2,0.2-0.2c0.6-0.2,1.2-0.5,1.7-0.7h0.1c0,0,0.1,0,0.1,0.1c0.4,0.3,0.9,0.7,1.3,1c0.1,0.1,0.3,0.2,0.4,0.2c0.2,0,0.3-0.1,0.5-0.2c0.6-0.6,1.2-1.2,1.8-1.8c0.3-0.3,0.3-0.6,0.1-0.9c-0.3-0.4-0.7-0.8-1-1.3c-0.1-0.1-0.1-0.2,0-0.3c0.2-0.6,0.5-1.1,0.7-1.7c0-0.1,0.1-0.2,0.2-0.2c0.5-0.1,1.1-0.1,1.6-0.2c0.4,0,0.6-0.3,0.6-0.7c0-0.8,0-1.7,0-2.5C48.2,37.9,48,37.7,47.6,37.6z M37.8,43.6C37.8,43.6,37.7,43.6,37.8,43.6c-2.3,0-4-1.8-4-4s1.8-4,4-4l0,0c2.2,0,4,1.8,4,4C41.7,41.8,39.9,43.6,37.8,43.6z x M38.7,20.7c-0.2-0.8-0.8-1.3-1.6-1.3c-3.2,0-6.4,0-9.6,0l0,0c-1.2,0-0.6-1-0.6-1c0.2-0.4,0.4-0.7,0.5-1.1c2.2-4.3,4.3-8.6,6.5-12.9c0.8-1.2,0-2.4-1.4-2.4c-6,0-11.9,0-17.9,0c-0.9,0-1.3,0.3-1.7,1.1c-3,7.6-6,15.1-8.9,22.7c0,0.2-0.1,0.4-0.1,0.5c-0.1,1,0.6,1.7,1.7,1.7c3.2,0,6.5,0,9.7,0c0.7,0.1,2.1,0.4,1.4,2.2c-1.2,3.1-2.4,6.1-3.6,9.2c-1.2,2.8-2.3,5.6-3.4,8.4c-0.4,1,0,1.9,1,2.2c0.7,0.2,1.2-0.1,1.7-0.6c4-4.2,8-8.4,12-12.7c0.5-0.5,0.9-1,1.4-1.5c0.6-0.6,0.5-1.6,0.5-1.6l0,0c0-1,0.3-1.9,1.1-2.7c0.6-0.6,1.2-1.2,1.8-1.8c0.7-0.7,1.6-1.1,2.6-1.1c0.7,0,1.1-0.3,1.3-0.4l0.1-0.1l0,0l0,0c1.7-1.8,3.5-3.7,5.2-5.5C38.7,21.7,38.9,21.2,38.7,20.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Like',
                'M10.5,21h-5C4.7,21,4,21.7,4,22.5v23C4,46.3,4.7,47,5.5,47H8c2.2,0,4-1.8,4-4V22.5C12,21.7,11.3,21,10.5,21z x M44,22h-6c-2.2,0-4-1.8-4-4V8c0-2.2-1.8-4-4-4h-2.5C26.7,4,26,4.7,26,5.5v6c0,5.3-3.7,10.5-8.5,10.5c-0.8,0-1.5,0.7-1.5,1.5v20c0,0.8,0.6,1.5,1.4,1.5c6.8,0.3,9.1,3,16.2,3c7.5,0,14.4-0.8,14.4-9.5v-5V26C48,23.8,46.2,22,44,22z'
            }
        );
        svgs.add(
            new List<String>{
                'Link',
                'M27.2,41.7c-0.7-0.1-1.4-0.2-2.1-0.3s-1.4-0.3-2.1-0.6c-0.4-0.1-0.9,0-1.2,0.3l-0.5,0.5c-2.9,2.9-7.6,3.2-10.6,0.6c-3.4-2.9-3.5-8.1-0.4-11.2l7.6-7.6c1-1,2.2-1.6,3.4-2c1.6-0.4,3.3-0.3,4.8,0.3c0.9,0.4,1.8,0.9,2.6,1.7c0.4,0.4,0.7,0.8,1,1.3c0.4,0.7,1.3,0.8,1.8,0.2c0.9-0.9,2.1-2.1,2.8-2.8c0.4-0.4,0.4-1,0.1-1.5C34,20,33.5,19.5,33,19c-0.7-0.7-1.5-1.4-2.4-1.9c-1.4-0.9-3-1.5-4.7-1.8c-3.1-0.6-6.5-0.1-9.3,1.4c-1.1,0.6-2.2,1.4-3.1,2.3l-7.3,7.3c-5.3,5.3-5.7,13.9-0.6,19.3c5.3,5.8,14.3,5.9,19.8,0.4l2.5-2.5C28.6,43,28.1,41.8,27.2,41.7z x M45.6,5.8c-5.5-5.1-14.1-4.7-19.3,0.6L24,8.6c-0.7,0.7-0.2,1.9,0.7,2c1.4,0.1,2.8,0.4,4.2,0.8c0.4,0.1,0.9,0,1.2-0.3l0.5-0.5c2.9-2.9,7.6-3.2,10.6-0.6c3.4,2.9,3.5,8.1,0.4,11.2L34,28.8c-1,1-2.2,1.6-3.4,2c-1.6,0.4-3.3,0.3-4.8-0.3c-0.9-0.4-1.8-0.9-2.6-1.7c-0.4-0.4-0.7-0.8-1-1.3c-0.4-0.7-1.3-0.8-1.8-0.2l-2.8,2.8c-0.4,0.4-0.4,1-0.1,1.5c0.4,0.6,0.9,1.1,1.4,1.6c0.7,0.7,1.6,1.4,2.4,1.9c1.4,0.9,3,1.5,4.6,1.8c3.1,0.6,6.5,0.1,9.3-1.4c1.1-0.6,2.2-1.4,3.1-2.3l7.6-7.6C51.5,20.1,51.3,11.1,45.6,5.8z'
            }
        );
        svgs.add(
            new List<String>{
                'List',
                'M8,10.5C8,9.7,7.3,9,6.5,9h-3C2.7,9,2,9.7,2,10.5v3C2,14.3,2.7,15,3.5,15h3C7.3,15,8,14.3,8,13.5V10.5z x M50,10.5C50,9.7,49.3,9,48.5,9h-35C12.7,9,12,9.7,12,10.5v3c0,0.8,0.7,1.5,1.5,1.5h35c0.8,0,1.5-0.7,1.5-1.5V10.5z x M8,24.5C8,23.7,7.3,23,6.5,23h-3C2.7,23,2,23.7,2,24.5v3C2,28.3,2.7,29,3.5,29h3C7.3,29,8,28.3,8,27.5V24.5z x M46,24.5c0-0.8-0.7-1.5-1.5-1.5h-31c-0.8,0-1.5,0.7-1.5,1.5v3c0,0.8,0.7,1.5,1.5,1.5h31c0.8,0,1.5-0.7,1.5-1.5V24.5z x M8,38.5C8,37.7,7.3,37,6.5,37h-3C2.7,37,2,37.7,2,38.5v3C2,42.3,2.7,43,3.5,43h3C7.3,43,8,42.3,8,41.5V38.5z x M50,38.5c0-0.8-0.7-1.5-1.5-1.5h-35c-0.8,0-1.5,0.7-1.5,1.5v3c0,0.8,0.7,1.5,1.5,1.5h35c0.8,0,1.5-0.7,1.5-1.5V38.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Listen',
                'M50.6,30.2C50.6,15.8,39.7,4,26.2,4S1.7,15.8,1.7,30.2c0,3.4,0.6,6.8,1.8,10c1.4,3.9,4.9,6.7,9.1,6.8c1.2,0,2.2-1,2.2-2.2V32.3c0-1.2-1-2.2-2.2-2.2c-2.2,0-4.3,0.8-5.9,2c-0.1-0.7-0.1-1.3-0.1-2c0-11.8,8.8-21.3,19.6-21.3s19.6,9.6,19.6,21.3c0,0.7,0,1.4-0.1,2c-1.6-1.3-3.6-2.1-5.9-2.1c-1.2,0-2.2,1-2.2,2.2v12.4c0,1.2,1,2.2,2.2,2.2c2.4,0,4.9-0.9,6.5-2.7c1.7-1.8,2.5-3.8,3.2-6.2C50.2,35.5,50.6,32.9,50.6,30.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Live Message',
                'M46,2H22c-2.2,0-4,1.8-4,4v0.1c3.6,0.4,6.9,1.7,9.6,3.8h14.8c0.8,0,1.6,0.8,1.6,1.6v27c0,0.8-0.8,1.4-1.6,1.4h-17c-0.8,0-1.4-0.6-1.4-1.4v-0.1c0-0.1-0.1-0.3-0.2-0.3c-1.7,0.8-3.6,1.3-5.5,1.5C18.1,39.8,18,40,18,40.5v5.4c0,2.2,1.7,4,3.9,4h24c2.2,0,4.1-1.8,4.1-4V6C50,3.8,48.2,2,46,2z M34,48c-1.7,0-3-1.3-3-3s1.3-3,3-3s3,1.3,3,3S35.7,48,34,48z x M2,22.9C2,30,8.3,35.7,15.9,35.8c2.7,0,5.2-0.7,7.3-1.9c0.4-0.2,0.7-0.2,1-0.1l5,1.9c0.5,0.1,0.9-0.3,0.8-0.8l-1.8-5c-0.1-0.4-0.1-0.7,0.1-1c1.1-1.9,1.7-4,1.7-6.2C30,15.7,23.8,10,16,10C8.3,10,2.1,15.7,2,22.9z'
            }
        );
        svgs.add(
            new List<String>{
                'Location',
                'M48.8,9.5L34.4,2.3c-0.7-0.3-1.5-0.3-2.1,0L19,9L5.6,2.3C4.8,1.9,3.8,1.9,3.1,2.4C2.4,2.8,2,3.6,2,4.4v36c0,0.9,0.5,1.7,1.3,2.1l14.4,7.2c0.7,0.3,1.5,0.3,2.1,0L33.2,43l13.3,6.7c0.3,0.2,0.7,0.3,1.1,0.3c0.4,0,0.9-0.1,1.3-0.4c0.7-0.4,1.1-1.2,1.1-2v-36C50,10.7,49.6,9.9,48.8,9.5z M45,14.1v19c0,1.1-1,1.9-2,1.5c-3.7-1.4-0.7-7.6-3.4-11c-2.5-3.1-5.7,0.1-8.8-4.8c-2.9-4.7,1-8.1,4.6-9.9c0.5-0.2,1-0.2,1.4,0l7.4,3.7C44.8,12.9,45,13.5,45,14.1z M24.9,41.9c-0.6,0.3-1.3,0.2-1.8-0.2c-1-0.9-1.8-2.3-1.8-3.7c0-2.4-4-1.6-4-6.4c0-3.9-4.6-4.9-8.5-4.5c-1,0.1-1.7-0.6-1.7-1.6V10.9c0-1.2,1.2-2,2.2-1.4l8.6,4.3c0.1,0,0.2,0.1,0.2,0.1l0.3,0.2c3.6,2.1,2.9,3.8,1.4,6.4c-1.7,2.9-2.4,0-4.8-0.8s-4.8,0.8-4,2.4s3.2,0,4.8,1.6s1.6,4,6.4,2.4s5.6-0.8,7.2,0.8c1.6,1.6,2.4,4.8,0,7.2c-1.4,1.4-2,4.4-2.6,6.4c-0.1,0.4-0.4,0.8-0.8,1L24.9,41.9z'
            }
        );
        svgs.add(
            new List<String>{
                'Location Permit',
                'M39.18,11.4,30.06,2.28A1.1,1.1,0,0,0,29.35,2a1,1,0,0,0-1,1v7.26A2.71,2.71,0,0,0,31.06,13h7.26a1,1,0,0,0,1-1C39.46,11.83,39.46,11.69,39.18,11.4Zm.28,7.26A1.42,1.42,0,0,0,38,17.24H28.35a4.13,4.13,0,0,1-4.13-4.13V3.42A1.42,1.42,0,0,0,22.8,2H9A4.13,4.13,0,0,0,4.85,6.13V39.32A4.13,4.13,0,0,0,9,43.45h14.1c1.14,0,1.42-.71,1.28-2a13.94,13.94,0,0,1,3-10.25c3.42-4,9.12-4.27,10-4.27s2.28,0,2.14-1.29Zm-29.77-8,3.42-.43a.14.14,0,0,0,.14-.14L14.82,7a.42.42,0,0,1,.57,0L17,10.12l.14.14,3.42.43a.28.28,0,0,1,.14.43l-2.57,2.56V14l.57,3.42c0,.15-.14.43-.42.29l-3-1.57H15l-3,1.57c-.14.14-.43,0-.43-.29L12,14v-.28L9.41,11.26A1.09,1.09,0,0,1,9.69,10.69ZM22.23,33.91a1.43,1.43,0,0,1-1.43,1.42h-9a1.43,1.43,0,0,1-1.43-1.42V32.48a1.43,1.43,0,0,1,1.43-1.42h9a1.43,1.43,0,0,1,1.43,1.42Zm7.54-8.41a1.43,1.43,0,0,1-1.42,1.43H11.83A1.43,1.43,0,0,1,10.4,25.5V24.08a1.43,1.43,0,0,1,1.43-1.43H28.49a1.43,1.43,0,0,1,1.43,1.43V25.5Z x M37.32,37a2,2,0,1,0,2,2A2.14,2.14,0,0,0,37.32,37Z x M37.32,30.34a9.83,9.83,0,1,0,9.83,9.83A10,10,0,0,0,37.32,30.34ZM37.61,46A.44.44,0,0,1,37,46c-1-.85-4.42-3.7-4.42-7A4.7,4.7,0,0,1,42,39C41.88,42.31,38.61,45.16,37.61,46Z'
            }
        );
        svgs.add(
            new List<String>{
                'Lock',
                'M11,19h4c0.6,0,1-0.3,1-0.9V18c0-5.7,4.9-10.4,10.7-10C32,8.4,36,13,36,18.4v-0.3c0,0.6,0.4,0.9,1,0.9h4c0.6,0,1-0.3,1-0.9V18c0-9.1-7.6-16.4-16.8-16c-8.5,0.4-15,7.6-15.2,16.1C10.1,18.6,10.5,19,11,19z x M10,18.1v0.4C10,18.4,10,18.3,10,18.1L10,18.1z x M46,27c0-2.2-1.8-4-4-4H10c-2.2,0-4,1.8-4,4v19c0,2.2,1.8,4,4,4h32c2.2,0,4-1.8,4-4V27z M30.6,42.7c0.2,0.6-0.3,1.3-1,1.3h-7.3c-0.7,0-1.1-0.6-1-1.3l1.8-6c-1.5-1-2.4-2.8-2.1-4.8c0.4-1.9,1.9-3.4,3.9-3.8c3.2-0.6,6,1.7,6,4.7c0,1.6-0.8,3.1-2.1,3.9L30.6,42.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Locker Service Console',
                'M47.7,9.1L47.7,9.1c-0.9-2.2-2-4.2-3.3-6.1c-0.6-0.8-1.7-0.9-2.3-0.2c-1.9,1.8-4.6,2.8-7.4,2.8c-3,0-5.7-1.2-7.7-3.2c-0.6-0.6-1.6-0.6-2.2,0c-2,2-4.7,3.2-7.7,3.2c-2.8,0-5.4-1-7.4-2.8C9,2.2,7.9,2.3,7.4,3C6.1,4.8,5,6.9,4.1,9.1h0c0,0-2.4,4.9-2,13c0,0,0,0.1,0,0.1c0,0.2,0,0.4,0,0.7c0,0.4,0.1,0.8,0.1,1.2c0,0,0,0.1,0,0.1h0C3.6,37.6,13.5,48.3,26,50c12.6-1.8,22.4-12.5,23.8-25.9h0c0-0.1,0-0.2,0-0.3c0-0.2,0-0.5,0.1-0.8C50.6,14.4,47.7,9.1,47.7,9.1z M40.9,19.4L24.3,36.3c-0.4,0.4-0.9,0.4-1.3,0l-9.7-9.8c-0.4-0.4-0.4-0.9,0-1.3l1.3-1.3c0.4-0.4,0.9-0.4,1.3,0l7.3,7.4c0.2,0.2,0.6,0.2,0.9,0l14.3-14.4c0.4-0.4,0.9-0.4,1.3,0l1.3,1.3C41.3,18.5,41.3,19.1,40.9,19.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Log a Call',
                'M43,2H13.5c-2.6,0-4.8,2.4-4.8,4.8v1.6H7.1C5.4,8.4,4,9.8,4,11.6s1.4,3.2,3.1,3.2h1.6v8H7.1C5.4,22.8,4,24.2,4,26s1.4,3.2,3.1,3.2h1.6v8H7.1c-1.7,0-3.1,1.4-3.1,3.2c0,1.8,1.4,3.2,3.1,3.2h1.6v1.6c0,2.4,2.2,4.8,4.8,4.8H43c2.6,0,5-2.4,5-5V6.6C48,3.9,45.6,2,43,2z M40.2,34.2L38,36.5c-0.5,0.5-1.2,0.8-1.8,0.7C31,36.9,26.2,34.5,22.7,31c-3.5-3.5-5.8-8.5-6.1-13.8c0-0.7,0.2-1.4,0.7-1.8l2.2-2.2c1-1,2.7-1,3.6,0.2l2,2.6c0.7,0.9,0.7,2.1,0.1,3l-1.7,2.5c-0.2,0.3-0.2,0.8,0.1,1l3.6,4.1l4,3.7c0.3,0.3,0.7,0.3,1,0.1l2.4-1.8c0.9-0.6,2.1-0.6,3,0.1l2.5,2.1C41.2,31.4,41.2,33.2,40.2,34.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Logout',
                'M21,48.5v-3c0-0.8-0.7-1.5-1.5-1.5h-10C8.7,44,8,43.3,8,42.5v-33C8,8.7,8.7,8,9.5,8h10C20.3,8,21,7.3,21,6.5v-3C21,2.7,20.3,2,19.5,2H6C3.8,2,2,3.8,2,6v40c0,2.2,1.8,4,4,4h13.5C20.3,50,21,49.3,21,48.5z x M49.6,27c0.6-0.6,0.6-1.5,0-2.1L36.1,11.4c-0.6-0.6-1.5-0.6-2.1,0l-2.1,2.1c-0.6,0.6-0.6,1.5,0,2.1l5.6,5.6c0.6,0.6,0.2,1.7-0.7,1.7H15.5c-0.8,0-1.5,0.6-1.5,1.4v3c0,0.8,0.7,1.6,1.5,1.6h21.2c0.9,0,1.3,1.1,0.7,1.7l-5.6,5.6c-0.6,0.6-0.6,1.5,0,2.1l2.1,2.1c0.6,0.6,1.5,0.6,2.1,0L49.6,27z'
            }
        );
        svgs.add(
            new List<String>{
                'Loop',
                'M47.2,32.6c0,0.1,0,0.1-0.1,0.2c-0.3,0.9-0.5,1.8-0.9,2.6c-0.4,0.9-0.8,1.9-1.3,2.7c-1,1.8-2.2,3.4-3.6,4.8c-1.4,1.4-3,2.7-4.7,3.7c-1.7,1-3.6,1.9-5.6,2.4c-2,0.6-4.1,0.8-6.2,0.8C12.3,50,2,39.7,2,27.1S12.3,4.2,24.9,4.2c4.3,0,8.3,1.2,11.7,3.2c0,0,0,0,0,0c1.7,1,3.2,2.2,4.5,3.5c0.4,0.3,0.7,0.6,1,1c0.8,0.6,1.3,0.2,1.3-0.8V3.6C43.4,2.8,44.2,2,45,2h3.2c0.9,0,1.6,0.8,1.7,1.6v19.6c0,0.8-0.6,1.4-1.4,1.4H28.9c-0.9,0-1.5-0.6-1.5-1.5v-3.3c0-0.9,0.8-1.6,1.6-1.6h7.5c0.6,0,1.2-0.2,1.4-0.5c-2.9-4-7.6-6.6-13-6.6c-8.9,0-16,7.2-16,16s7.2,16,16,16c7,0,12.9-4.4,15.1-10.6c0,0,0.3-1.4,1.4-1.4c1.1,0,3.8,0,4.6,0c0.7,0,1.3,0.5,1.3,1.2C47.2,32.4,47.2,32.5,47.2,32.6z'
            }
        );
        svgs.add(
            new List<String>{
                'Lower Flag',
                'M6.6,2h-3C2.8,2,2.1,2.7,2.1,3.5v45c0,0.8,0.7,1.5,1.5,1.5h3c0.8,0,1.5-0.7,1.5-1.5v-45C8.1,2.7,7.4,2,6.6,2z x M40.6,24.6c2.7,0,5.2,0.7,7.5,1.9V6.6c0-0.7-0.8-1.2-1.5-0.8c-16,8.4-14.2-8.8-33.5-2.1c-0.6,0.2-1,0.8-1,1.4v23.3c0,0.7,0.7,1.2,1.3,0.9c7.7-2.6,11.9-1.3,15.4,0.6C31.7,26.6,35.9,24.6,40.6,24.6z x M31.8,34.6l6,6l-6,6c-0.6,0.6-0.6,1.6,0,2.1l0.7,0.7c0.6,0.6,1.6,0.6,2.1,0l6-6l6,6c0.6,0.6,1.6,0.6,2.1,0l0.7-0.7c0.6-0.6,0.6-1.6,0-2.1l-6-6l6-6c0.6-0.6,0.6-1.6,0-2.1l-0.7-0.7c-0.6-0.6-1.6-0.6-2.1,0l-6,6l-6-6c-0.6-0.6-1.6-0.6-2.1,0l-0.7,0.7C31.2,33,31.2,34,31.8,34.6z'
            }
        );
        svgs.add(
            new List<String>{
                'Macros',
                'M2.1,12.9 x M37.2,40.2c-0.2,0.4-0.6,0.5-1,0.5h-4.7c-0.4,0-0.7-0.3-0.7-0.7c0-0.1,0.1-0.3,0.1-0.4c0,0,0,0,0.1-0.1s0.1-0.1,0.2-0.2l10.3-12.5c0.3-0.4,0.4-1,0.2-1.4c0-0.1-0.1-0.2-0.1-0.2L30.9,12.5c-0.1-0.1-0.1-0.3-0.1-0.4c0-0.4,0.4-0.7,0.7-0.7h4.7c0.4,0,0.8,0.1,1,0.5l11.1,13.4c0.2,0.2,0.2,0.5,0.2,0.7c0,0.3-0.1,0.6-0.2,0.8L37.2,40.2z x M25.6,40.2c-0.2,0.4-0.6,0.5-1,0.5h-4.7c-0.4,0-0.7-0.3-0.7-0.7c0-0.1,0.1-0.3,0.1-0.4c0,0,0,0,0.1-0.1s0.1-0.1,0.2-0.2l10.3-12.5c0.3-0.4,0.4-1,0.2-1.4c0-0.1-0.1-0.2-0.1-0.2L19.3,12.5c-0.1-0.1-0.1-0.3-0.1-0.4c0-0.4,0.4-0.7,0.7-0.7h4.7c0.4,0,0.8,0.1,1,0.5l11.1,13.4c0.2,0.2,0.2,0.5,0.2,0.7c0,0.3-0.1,0.6-0.2,0.8L25.6,40.2z x M14,40.2c-0.2,0.4-0.6,0.5-1,0.5H4.2c-0.4,0-0.7-0.3-0.7-0.7c0-0.1,0.1-0.3,0.1-0.4c0,0,0,0,0.1-0.1s0.1-0.1,0.2-0.2l10.3-12.5c0.3-0.4,0.4-1,0.2-1.4c0-0.1-0.1-0.2-0.1-0.2L3.6,12.5c-0.1-0.1-0.1-0.3-0.1-0.4c0-0.4,0.4-0.7,0.7-0.7h8.7c0.4,0,0.8,0.1,1,0.5L25,25.3c0.2,0.2,0.2,0.5,0.2,0.7c0,0.3-0.1,0.6-0.2,0.8L14,40.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Magic Wand',
                'M28.2,21c-0.4-0.4-1-0.4-1.4,0L2.9,44.9c-1.2,1.2-1.2,3,0,4.2l0,0c1.2,1.2,3,1.2,4.2,0L31,25.2c0.4-0.4,0.4-1,0-1.4L28.2,21z x M35.2,21l3.2-3.2c0.6-0.6,0.6-1.5,0-2.1l-2.1-2.1c-0.6-0.6-1.5-0.6-2.1,0L31,16.8c-0.4,0.4-0.4,1,0,1.4l2.8,2.8C34.2,21.4,34.8,21.4,35.2,21z x M10.4,11.6c3.8,1.2,6.8,4.1,8,8c0.2,0.6,1,0.6,1.2,0c1.2-3.8,4.1-6.8,8-8c0.6-0.2,0.6-1,0-1.2c-3.8-1.2-6.8-4.1-8-8c-0.2-0.6-1-0.6-1.2,0c-1.2,3.8-4.1,6.8-8,8C9.9,10.6,9.9,11.4,10.4,11.6z x M49.6,30.5c-3.4-1.1-6-3.7-7.1-7.1c-0.2-0.5-0.9-0.5-1.1,0c-1.1,3.4-3.7,6-7.1,7.1c-0.5,0.2-0.5,0.9,0,1.1c3.4,1.1,6,3.7,7.1,7.1c0.2,0.5,0.9,0.5,1.1,0c1.1-3.4,3.7-6,7.1-7.1C50.1,31.4,50.1,30.6,49.6,30.5z x M38.3,8.4c2.6,0.8,4.5,2.7,5.3,5.3c0.1,0.4,0.7,0.4,0.8,0c0.8-2.6,2.7-4.5,5.3-5.3c0.4-0.1,0.4-0.7,0-0.8c-2.6-0.8-4.5-2.7-5.3-5.3c-0.1-0.4-0.7-0.4-0.8,0c-0.8,2.6-2.7,4.5-5.3,5.3C37.9,7.7,37.9,8.3,38.3,8.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Merge',
                'M42.3,44c-5.6-2.7-9.6-7.5-11.6-13c-0.8-2-1.3-4.3-1.5-6.3v-3.5H40c0.8,0,1.4-0.9,0.8-1.8l-14.2-17c-0.5-0.6-1.6-0.6-2,0l-13.8,17c-0.5,0.6,0,1.8,0.8,1.8h10.9c0,1.5,0,3.4,0,3.4v0.1l0,0c-0.3,2.1-0.8,4.4-1.5,6.3c-2,5.5-6,10.3-11.6,13c-0.8,0.3-1.1,1.3-0.8,2l1.3,3.1c0.4,0.8,1.3,1.1,2.1,0.6c6-2.9,10.8-7.5,13.7-13c3,5.5,7.7,10.1,13.8,13c0.8,0.4,1.8,0.3,2.1-0.6l1.3-3.1C43.5,45.3,43.1,44.4,42.3,44z'
            }
        );
        svgs.add(
            new List<String>{
                'Merge Field',
                'M16.5,39.9L16.5,39.9l-0.7,0c-2.3,0-3.2-1.3-3.2-3.5c0-1,0.1-1.9,0.3-2.9c0.2-1,0.3-2,0.3-3.1c0-2.6-1.1-4-2.9-4.4V26c1.8-0.5,2.9-1.8,2.9-4.4c0-1.1-0.1-2.1-0.3-3.1c-0.2-1-0.3-1.9-0.3-2.9c0-2.2,0.8-3.5,3.2-3.5h0.7v0c0.6,0,1.1-0.5,1.1-1.1c0-0.6-0.5-1.1-1.1-1.1v0h0c0,0,0,0,0,0s0,0,0,0h-3.8c-3.4,0-5.9,1.6-5.9,5.3c0,1.1,0.2,2.2,0.3,3.4c0.2,1.1,0.3,2.3,0.3,3.4c0,1.3-0.3,2.7-2.5,2.9c0,0,0,0-0.1,0c-0.6,0-1.1,0.5-1.1,1.1s0.5,1,1.1,1.1c0,0,0.2,0,0.2,0c2.2,0.3,2.5,1.8,2.5,2.9c0,1.1-0.2,2.2-0.3,3.3s-0.3,2.2-0.3,3.3c0,4.1,2.5,5.5,5.9,5.5h3.8v0c0.6,0,1.1-0.5,1.1-1.1C17.6,40.4,17.1,39.9,16.5,39.9z x M35.5,39.9L35.5,39.9l0.7,0c2.3,0,3.2-1.3,3.2-3.5c0-1-0.1-1.9-0.3-2.9c-0.2-1-0.3-2-0.3-3.1c0-2.6,1.1-4,2.9-4.4V26c-1.8-0.5-2.9-1.8-2.9-4.4c0-1.1,0.1-2.1,0.3-3.1c0.2-1,0.3-1.9,0.3-2.9c0-2.2-0.8-3.5-3.2-3.5h-0.7v0c-0.6,0-1.1-0.5-1.1-1.1c0-0.6,0.5-1.1,1.1-1.1v0h0c0,0,0,0,0,0s0,0,0,0h3.8c3.4,0,5.9,1.6,5.9,5.3c0,1.1-0.2,2.2-0.3,3.4c-0.2,1.1-0.3,2.3-0.3,3.4c0,1.3,0.3,2.7,2.5,2.9c0,0,0,0,0.1,0c0.6,0,1.1,0.5,1.1,1.1s-0.5,1-1.1,1.1c0,0-0.2,0-0.2,0c-2.2,0.3-2.5,1.8-2.5,2.9c0,1.1,0.2,2.2,0.3,3.3s0.3,2.2,0.3,3.3c0,4.1-2.5,5.5-5.9,5.5h-3.8v0c-0.6,0-1.1-0.5-1.1-1.1C34.4,40.4,34.9,39.9,35.5,39.9z'
            }
        );
        svgs.add(
            new List<String>{
                'Metrics',
                'M44.9,2H7.1C4.3,2,2,4.3,2,7.1v37.7C2,47.7,4.3,50,7.1,50h37.7c2.8,0,5.1-2.3,5.1-5.1V7.1C50,4.3,47.7,2,44.9,2z M15.7,39.7c0,0.9-0.8,1.7-1.7,1.7h-1.7c-0.9,0-1.7-0.8-1.7-1.7v-9.4c0-0.9,0.8-1.7,1.7-1.7H14c0.9,0,1.7,0.8,1.7,1.7V39.7z M24.3,39.7c0,0.9-0.8,1.7-1.7,1.7h-1.7c-0.9,0-1.7-0.8-1.7-1.7V17.4c0-0.9,0.8-1.7,1.7-1.7h1.7c0.9,0,1.7,0.8,1.7,1.7V39.7z M32.9,39.7c0,0.9-0.8,1.7-1.7,1.7h-1.7c-0.9,0-1.7-0.8-1.7-1.7V12.3c0-0.9,0.8-1.7,1.7-1.7h1.7c0.9,0,1.7,0.8,1.7,1.7V39.7z M41.4,39.7c0,0.9-0.8,1.7-1.7,1.7H38c-0.9,0-1.7-0.8-1.7-1.7V23.4c0-0.9,0.8-1.7,1.7-1.7h1.7c0.9,0,1.7,0.8,1.7,1.7V39.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Missed Call',
                'M34.7,40.3c0.7,0,1.2,0.5,1.4,1.1l0.8,5.4c0.2,1.5,1.4,2.6,2.9,2.8l6.5,0.7c2,0.2,3.7-1.3,3.7-3.3v-6.2c0-1-0.4-1.8-1.1-2.5c-6.4-5.8-14.9-8.8-23-8.8s-16.6,3-23,8.8C2.3,38.9,2,39.9,2,40.8V47c-0.2,2,1.5,3.6,3.5,3.3l6.5-0.7c1.5-0.2,2.7-1.3,2.9-2.8l0.8-5.4c0.1-0.7,0.7-1.1,1.4-1.1C17.1,40.3,25.5,39.6,34.7,40.3z x M39.7,12.6c0.5-0.5,1.4-0.1,1.4,0.6v6.7c0,0.7,0.5,1.2,1.2,1.2l2.5,0c0.7,0,1.2-0.5,1.2-1.2c0,0,0.1-16.1,0.1-16.1c0-0.7-0.5-1.2-1.2-1.2H28.9c-0.7,0-1.2,0.5-1.2,1.2v2.5c0,0.7,0.5,1.2,1.2,1.2h6.7c0.7,0,1.1,0.9,0.6,1.4l-9.4,9.4c-0.3,0.3-0.9,0.3-1.3,0L10.1,3C9.6,2.5,8.8,2.5,8.3,3L6.4,4.8c-0.5,0.5-0.5,1.3,0,1.9l18.8,18.9c0.5,0.6,1.3,0.6,1.9,0L39.7,12.6z'
            }
        );
        svgs.add(
            new List<String>{
                'Money',
                'M30.1,26.1c0-2.3,1.4-4.3,3.3-5.3c-0.3-3.9-3.5-6.9-7.5-6.9c-4.1,0-7.5,3.4-7.5,7.5c0,4.1,3.4,7.5,7.5,7.5c1.5,0,3-0.5,4.1-1.3V26.1z x M30.1,36.4v-1.9c0-0.7,0.1-1.3,0.3-1.9H12.8c0-2.9-2.3-5.3-5.3-5.3V16.1c2.9,0,5.3-2.3,5.3-5.3h26.3c0,2.9,2.3,5.3,5.3,5.3v4h3.8c0.7,0,1.3,0.1,1.9,0.3V9.7c0-2.5-2-4.5-4.5-4.5H6.5C4,5.2,2,7.2,2,9.7v24.2c0,2.5,2,4.5,4.5,4.5h24C30.3,37.8,30.1,37.1,30.1,36.4z x M50,44.9c0,1-1,1.9-2,1.9H36c-1,0-1.9-0.9-1.9-1.9V43c0-1,0.9-1.9,1.9-1.9h12.1c1,0,1.9,0.9,1.9,1.9V44.9L50,44.9z x M50,36.5c0,1-1,1.9-2,1.9H36c-1,0-1.9-0.9-1.9-1.9v-1.9c0-1,0.9-1.9,1.9-1.9h12.1c1,0,1.9,0.9,1.9,1.9V36.5L50,36.5z x M50,28c0,1-1,1.9-2,1.9H36c-1,0-1.9-0.9-1.9-1.9v-1.9c0-1,0.9-1.9,1.9-1.9h12.1c1,0,1.9,0.9,1.9,1.9V28L50,28z'
            }
        );
        svgs.add(
            new List<String>{
                'Money Bag',
                'M20.5,9.1c0.2,0.6,0.8,0.9,1.4,0.9H30c0.6,0,1.2-0.3,1.4-0.9l3.2-5.9C34.8,2.6,34.4,2,33.8,2H26h-7.8c-0.6,0-1,0.6-0.7,1.1L20.5,9.1z x M30.7,14.7h-9.4C13.4,14.7,7,21.2,7,29.2v16c0,2.6,2.1,4.8,4.8,4.8h28.4c2.6,0,4.8-2.2,4.8-4.8v-16C45,21.2,38.5,14.7,30.7,14.7z M28.4,41.7v2.7c0,0.5-0.5,0.8-1,0.8h-3.2c-0.5,0-0.6-0.3-0.6-0.8v-2.6c-2.4-0.5-4.4-1.5-4.9-2c-0.6-0.6-0.8-1.1-0.3-1.8l1-1.6c0.2-0.4,0.7-0.6,1.2-0.6c0.3,0,0.6,0.1,0.8,0.2h0.1c1.6,1,3,1.4,4,1.4c1.1,0,2-0.6,2-1.2c0-0.5-0.3-1.3-3.3-2.3c-2.7-1-6-2.6-6-6.3c0-2.2,1.4-4.7,5.4-5.5v-2.4c0-0.5,0.2-0.8,0.6-0.8h3.2c0.5,0,1,0.3,1,0.8V22c1.6,0.4,3.3,1.2,3.9,1.6c0.3,0.2,0.5,0.6,0.6,1c0.1,0.4-0.1,0.8-0.3,1L31.2,27c-0.3,0.4-0.9,0.7-1.3,0.7c-0.2,0-0.5-0.1-0.7-0.2c-1.6-0.9-2.9-1.4-3.8-1.4c-1.3,0-1.9,0.6-1.9,1c0,0.6,0.3,1.2,3,2.2c3.3,1.1,7,2.9,7,6.7C33.6,38.6,31.5,40.9,28.4,41.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Multi-select Checkbox',
                'M44,2.5H19c-2.6,0-4.7,2.1-4.7,4.7V8c0,0.5,0.3,0.8,0.8,0.8h22.7c2.6,0,4.7,2.1,4.7,4.7v24.3c0,0.5,0.3,0.8,0.8,0.8H44c2.6,0,4.7-2.1,4.7-4.7V7.2C48.7,4.6,46.6,2.5,44,2.5z x M33,13.5H8c-2.6,0-4.7,2.1-4.7,4.7v26.6c0,2.6,2.1,4.7,4.7,4.7H33c2.6,0,4.7-2.1,4.7-4.7V18.2C37.8,15.6,35.6,13.5,33,13.5z M31,26.8l-12,12c-0.5,0.5-1,0.7-1.6,0.7c-0.5,0-1.2-0.2-1.6-0.7l-5.8-5.8c-0.5-0.5-0.5-1.2,0-1.6l1.6-1.6c0.5-0.5,1.2-0.5,1.6,0l4.2,4.2l10.3-10.3c0.5-0.5,1.2-0.5,1.6,0l1.6,1.6C31.4,25.6,31.4,26.4,31,26.8z'
            }
        );
        svgs.add(
            new List<String>{
                'Muted',
                'M48.5,5.6l-2.1-2.1C45.8,2.9,44.7,3,44,3.8l-10,10V9.9C34,5.5,30.5,2,26.1,2h-0.2C21.5,2,18,5.5,18,9.9v14.5c0,1.5,0.4,3,1.2,4.2l-3.5,3.5C14,30,13,27.3,13,24.4v-4c0-1.4-1.1-2.4-2.5-2.4C9.1,18,8,19,8,20.4v4c0,4.3,1.6,8.2,4.2,11.2L3.8,44c-0.7,0.7-0.8,1.8-0.3,2.4l2.1,2.1C6.2,49.1,7.3,49,8,48.2L48.2,8C49,7.3,49.1,6.2,48.5,5.6z x M39,23.2v1.2c0,7-5.8,12.8-13,12.8c-0.3,0-0.6,0-0.9,0l-3.9,4.1c0.8,0.2,1.8,0.4,2.8,0.6V45h-4.5c-1.4,0-2.5,1.1-2.5,2.5s1.1,2.5,2.5,2.5h13.1c1.4,0,2.5-1.1,2.5-2.5S33.9,45,32.5,45H28v-3.2c9-1.2,16-8.6,16-17.4v-4c0-0.6-0.3-1.2-0.6-1.6L39,23.2z'
            }
        );
        svgs.add(
            new List<String>{
                'News',
                'M50.5,6h-41C8.7,6,8,6.7,8,7.5V38c0,1.2-1.1,2.2-2.3,2c-1-0.2-1.7-1.1-1.7-2.1V16c0-0.6-0.4-1-1-1H1.5C0.7,15,0,15.7,0,16.5V42c0,2.2,1.8,4,4,4h4h40c2.2,0,4-1.8,4-4V7.5C52,6.7,51.3,6,50.5,6z M28,35c0,0.6-0.4,1-1,1H15c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h12c0.6,0,1,0.4,1,1V35z M28,27c0,0.6-0.4,1-1,1H15c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h12c0.6,0,1,0.4,1,1V27z M46,35c0,0.6-0.4,1-1,1H33c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h12c0.6,0,1,0.4,1,1V35z M46,27c0,0.6-0.4,1-1,1H33c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h12c0.6,0,1,0.4,1,1V27z M46,19c0,0.6-0.4,1-1,1H15c-0.6,0-1-0.4-1-1v-6c0-0.6,0.4-1,1-1h30c0.6,0,1,0.4,1,1V19z'
            }
        );
        svgs.add(
            new List<String>{
                'Note',
                'M41.4,39.7l-0.9,0.9c-1,1-2.3,1.5-3.7,1.5h-2.6c-2.4,0-5-1.9-5-5.2v-2.5c0-2,0.9-3.2,1.4-3.9l10.8-11c0.3-0.3,0.6-1,0.6-1.4V9.8C42,7.2,39.8,5,37.2,5H11.6C9,5,6.8,7.4,6.8,9.8H5.2C3.4,9.8,2,11.3,2,13.1s1.4,3.2,3.2,3.2h1.6v6.5H5.2C3.4,22.8,2,24.2,2,26s1.4,3.2,3.2,3.2h1.6v6.5H5.2c-1.8,0-3.2,1.5-3.2,3.2c0,1.8,1.4,3.2,3.2,3.2h1.6c0,3.2,2.2,4.8,4.8,4.8H30h7.2c2.6,0,4.8-2.2,4.8-4.8V40C42,39.5,41.8,39.4,41.4,39.7z M33.2,17.1c0,0.9-0.7,1.6-1.6,1.6h-16c-0.9,0-1.6-0.7-1.6-1.6v-1.6c0-0.9,0.7-1.6,1.6-1.6h16c0.9,0,1.6,0.7,1.6,1.6V17.1z M26,36.5c0,0.9-0.7,1.6-1.6,1.6h-8.8c-0.9,0-1.6-0.7-1.6-1.6v-1.6c0-0.9,0.7-1.6,1.6-1.6h8.8c0.9,0,1.6,0.7,1.6,1.6V36.5z M28.4,26.8c0,0.9-0.7,1.6-1.6,1.6H15.6c-0.9,0-1.6-0.7-1.6-1.6v-1.6c0-0.9,0.7-1.6,1.6-1.6h11.2c0.9,0,1.6,0.7,1.6,1.6V26.8z x M49.5,22.4l-1-1c-0.6-0.6-1.6-0.6-2.2,0L34.1,34C34,34,34,34.2,34,34.2v2.7c0,0.2,0,0.4,0.2,0.4h2.6c0.1,0,0.2-0.1,0.3-0.1l12.3-12.4C50.2,24.1,50.2,23.1,49.5,22.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Notebook',
                'M44,2H14c-2.2,0-4,1.8-4,4v3H7c-1.7,0-3,1.3-3,3s1.3,3,3,3h3v8H7c-1.7,0-3,1.3-3,3s1.3,3,3,3h3v8H7c-1.7,0-3,1.3-3,3s1.3,3,3,3h3v3c0,2.2,1.8,4,4,4h30c2.2,0,4-1.8,4-4V6C48,3.8,46.2,2,44,2z M37,36c0,0.6-0.4,1-1,1H22c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h14c0.6,0,1,0.4,1,1V36z M39,28c0,0.6-0.4,1-1,1H20c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h18c0.6,0,1,0.4,1,1V28z M41,18c0,0.6-0.4,1-1,1H18c-0.6,0-1-0.4-1-1v-6c0-0.6,0.4-1,1-1h22c0.6,0,1,0.4,1,1V18z'
            }
        );
        svgs.add(
            new List<String>{
                'Notificaton',
                'M46,33h-0.5c-1.9,0-3.5-1.6-3.5-3.5V18c0-9.1-7.6-16.4-16.8-16C16.6,2.4,10,9.8,10,18.5v11.1c0,1.9-1.6,3.4-3.5,3.4H6c-2.2,0-4,1.9-4,4.1v1.5C2,39.3,2.7,40,3.5,40h45c0.8,0,1.5-0.7,1.5-1.5V37C50,34.8,48.2,33,46,33z x M30.9,44h-9.8c-0.6,0-1.1,0.6-1,1.2c0.5,2.8,3,4.8,5.9,4.8s5.4-2.1,5.9-4.8C32,44.6,31.5,44,30.9,44z'
            }
        );
        svgs.add(
            new List<String>{
                'Number Input',
                'M44.8,49.5H7.2c-2.6,0-4.7-2.1-4.7-4.7V7.2c0-2.6,2.1-4.7,4.7-4.7h37.6c2.6,0,4.7,2.1,4.7,4.7v37.6C49.5,47.4,47.4,49.5,44.8,49.5z M8.8,10.3v31.3c0,0.9,0.7,1.6,1.6,1.6h31.3c0.9,0,1.6-0.7,1.6-1.6V10.3c0-0.9-0.7-1.6-1.6-1.6H10.4C9.5,8.8,8.8,9.5,8.8,10.3z x M36.2,20.3h-2.9l1.2-4.8v-0.1c0-0.2-0.1-0.4-0.4-0.4h-2.3c-0.2,0-0.3,0.1-0.4,0.3l-1.2,4.9h-5.8l1.2-4.8v-0.1c0-0.2-0.1-0.4-0.4-0.4h-2.3c-0.2,0-0.3,0.1-0.4,0.3l-1.3,4.9h-3.2c-0.2,0-0.3,0.1-0.4,0.3l-0.6,2.2v0.1c0,0.2,0.1,0.4,0.4,0.4h3l-1.4,5.6h-3.1c-0.2,0-0.3,0.1-0.4,0.3l-0.6,2.2v0.1c0,0.2,0.1,0.4,0.4,0.4h2.9l-1.2,4.8v0.1c0,0.2,0.1,0.4,0.4,0.4h2.3c0.2,0,0.3-0.1,0.4-0.3l1.3-5h5.7L26,36.4v0.1c0,0.2,0.1,0.4,0.4,0.4h2.3c0.2,0,0.3-0.1,0.4-0.3l1.3-5h3.2c0.2,0,0.3-0.1,0.4-0.3l0.6-2.2V29c0-0.2-0.1-0.4-0.4-0.4h-3l1.4-5.6h3.1c0.2,0,0.3-0.1,0.4-0.3l0.6-2.2v-0.1C36.6,20.5,36.4,20.3,36.2,20.3L36.2,20.3z M28.1,28.8h-5.8l1.4-5.6h5.7L28.1,28.8z'
            }
        );
        svgs.add(
            new List<String>{
                'Offline',
                'M34.7,36.1c0.5-0.5,0.5-1.3,0-1.8l-1.8-1.8c-0.5-0.5-1.3-0.5-1.8,0l-4.4,4.4c-0.3,0.3-0.9,0.3-1.2,0l-4.4-4.4c-0.5-0.5-1.3-0.5-1.8,0l-1.8,1.8c-0.5,0.5-0.5,1.3,0,1.8l4.4,4.4c0.3,0.3,0.3,0.9,0,1.2l-4.4,4.4c-0.5,0.5-0.5,1.3,0,1.8l1.8,1.8c0.5,0.5,1.3,0.5,1.8,0l4.4-4.4c0.3-0.3,0.9-0.3,1.2,0l4.4,4.4c0.5,0.5,1.3,0.5,1.8,0l1.8-1.8c0.5-0.5,0.5-1.3,0-1.8l-4.4-4.4c-0.3-0.3-0.3-0.9,0-1.2L34.7,36.1z x M47.7,11.6c-5.5-6.1-13.3-9.5-21.6-9.5S10,5.5,4.5,11.6C4.1,12,4.2,12.7,4.6,13l3,2.6C8,16,8.6,15.9,9,15.5c4.4-4.7,10.6-7.4,17.1-7.4s12.7,2.7,17.1,7.4c0.4,0.4,1,0.4,1.4,0.1l3-2.6C48,12.6,48.1,12,47.7,11.6z x M26.1,16.1c-4.2,0-8.2,1.8-11,5c-0.4,0.4-0.3,1.1,0.1,1.5l3.2,2.4c0.4,0.3,1,0.3,1.3-0.1c1.7-1.8,4-2.8,6.4-2.8s4.7,1,6.3,2.7c0.3,0.4,0.9,0.4,1.3,0.1l3.2-2.4c0.5-0.4,0.5-1,0.1-1.5C34.3,17.9,30.3,16.1,26.1,16.1z'
            }
        );
        svgs.add(
            new List<String>{
                'Orchestrator',
                'M36.4,3.14a1.62,1.62,0,0,0-2.24-1,1.65,1.65,0,0,0-.59,2.38l7.28,18.18c.45.95,1.28,1.51,2.21,1.06a1.76,1.76,0,0,0,.63-2.47Z x M26.2,15.75c4.11,0,7.41,3.74,7.41,8.37s-3.3,8.37-7.41,8.37-7.41-3.74-7.41-8.37S22.09,15.75,26.2,15.75ZM26.2,15.75c4.11,0,7.41,3.74,7.41,8.37s-3.3,8.37-7.41,8.37-7.41-3.74-7.41-8.37S22.09,15.75,26.2,15.75Z x M9.11,34.34l10.67,1.2L22.24,50h-3a1.87,1.87,0,0,1-1.79-1.39l-2.18-7.84-9.09-1a4.77,4.77,0,0,1-3.88-6.3L7,19.79A2.79,2.79,0,0,1,10.52,18a2.86,2.86,0,0,1,1.73,3.63L8.33,33.09A.94.94,0,0,0,9.11,34.34Z x M33.36,50h-3.2l2.43-14.29,10.09,1.91a.94.94,0,0,0,1.08-1.14l-1.42-6.4a2.85,2.85,0,0,1,2.07-3.44,2.8,2.8,0,0,1,3.38,2.1L49.87,38a4.73,4.73,0,0,1-5.38,5.8l-7.7-1.46-1.62,6.27A1.87,1.87,0,0,1,33.36,50Z x M23.31,37.29a1.1,1.1,0,0,1-1.68-.95V34.57a1.1,1.1,0,0,1,1.68-1l2.89,1.83Z x M26.2,35.45l2.88-1.83a1.1,1.1,0,0,1,1.69,1v1.77a1.11,1.11,0,0,1-1.69.95Z'
            }
        );
        svgs.add(
            new List<String>{
                'Outbound Call',
                'M48.5,37.9L42.4,33c-1.4-1.1-3.4-1.2-4.8-0.1l-5.2,3.8c-0.6,0.5-1.5,0.4-2.1-0.2l-7.8-7l-7-7.8c-0.6-0.6-0.6-1.4-0.2-2.1l3.8-5.2c1.1-1.4,1-3.4-0.1-4.8l-4.9-6.1c-1.5-1.8-4.2-2-5.9-0.3L3,8.4c-0.8,0.8-1.2,1.9-1.2,3c0.5,10.2,5.1,19.9,11.9,26.7S30.2,49.5,40.4,50c1.1,0.1,2.2-0.4,3-1.2l5.2-5.2C50.5,42.1,50.4,39.3,48.5,37.9z x M48.4,2H33c-1,0-1.3,1.1-0.5,1.9l4.9,5l-9,9.1c-0.5,0.5-0.5,1.4,0,1.9l3.7,3.7c0.5,0.5,1.3,0.5,1.9,0l9.1-9.1l5.1,4.9C48.9,20.3,50,20,50,19V3.7C50,3,49.1,2,48.4,2z'
            }
        );
        svgs.add(
            new List<String>{
                'Outcome',
                'M36.2,11.6c0,0-0.1-0.1-0.1-0.1c-0.6-0.5-1.5-0.5-2,0.1l-2.2,2.1c0,0,0,0,0,0c-0.6,0.6-0.5,1.5,0,2l5.6,5.6c0.2,0.2,0.3,0.4,0.3,0.7c0,0.6-0.4,1.1-1,1.1H15.6c-0.8,0-1.5,0.6-1.5,1.4v3c0.1,0.8,0.7,1.5,1.5,1.6h21.3c0.2,0,0.4,0.1,0.5,0.2c0.5,0.4,0.5,1,0.2,1.5L32,36.5c0,0,0,0,0,0c-0.6,0.6-0.5,1.5,0,2l2.1,2.2c0,0,0,0,0,0c0.6,0.6,1.5,0.5,2,0l13.5-13.5c0,0,0,0,0,0c0.6-0.6,0.5-1.5,0-2L36.2,11.6z x M21.1,17.2L21.1,17.2h3c0.8,0,1.5-0.7,1.5-1.5V6.1c0-2.2-1.8-4-4-4h-1.9H9.1H6.1c-2.2,0-4,1.8-4,4v40c0,2.2,1.8,4,4,4h2.9h10.6h1.9c2.2,0,4-1.8,4-4v-9.5c0-0.8-0.7-1.5-1.5-1.5h-3l0,0c-0.8,0-1.5,0.7-1.5,1.5v5.9c0,0.8-0.7,1.5-1.5,1.5H9.6c-0.8,0-1.5-0.7-1.5-1.5v-33c0-0.8,0.7-1.5,1.5-1.5H18c0.8,0,1.5,0.7,1.5,1.5v6.1C19.6,16.5,20.2,17.2,21.1,17.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Page',
                'M44.4,19H33.2c-2.6,0-4.2-1.6-4.2-4.2V3.6C29,2.7,28.3,2,27.4,2H10.8C8.2,2,6,4.2,6,6.8v38.4c0,2.6,2.2,4.8,4.8,4.8h30.4c2.6,0,4.8-2.2,4.8-4.8V20.6C46,19.7,45.3,19,44.4,19z x M45.7,12.9L35.1,2.3C34.9,2.1,34.5,2,34.2,2l0,0C33.6,2,33,2.5,33,3.1v8.5c0,1.8,1.6,3.4,3.4,3.4h8.5c0.6,0,1.1-0.6,1.1-1.2l0,0C46,13.5,45.9,13.1,45.7,12.9z'
            }
        );
        svgs.add(
            new List<String>{
                'Palette',
                'M49.5,17.3C47.2,7.8,37.2,2,26.2,2C12.8,2,2,12.7,2,26s10.8,24,24.2,24c18.6,0,17.1-9.4,11.2-13.1c-3.5-2.2-5.4-7.3-1.9-10.9C42,19.3,52.5,30,49.5,17.3z M13,34c-2.8,0-5-2.2-5-5s2.2-5,5-5s5,2.2,5,5S15.8,34,13,34z M14,15c0-2.8,2.2-5,5-5s5,2.2,5,5s-2.2,5-5,5S14,17.8,14,15z M25,44c-2.8,0-5-2.2-5-5s2.2-5,5-5s5,2.2,5,5S27.8,44,25,44z M34,18c-2.8,0-5-2.2-5-5s2.2-5,5-5s5,2.2,5,5S36.8,18,34,18z'
            }
        );
        svgs.add(
            new List<String>{
                'Password',
                'M44.8,49.5H7.2c-2.6,0-4.7-2.1-4.7-4.7V7.2c0-2.6,2.1-4.7,4.7-4.7h37.6c2.6,0,4.7,2.1,4.7,4.7v37.6C49.5,47.3,47.4,49.5,44.8,49.5z M8.9,10.3v31.3c0,0.9,0.7,1.6,1.6,1.6h31.2c0.9,0,1.6-0.7,1.6-1.6V10.3c0-0.9-0.7-1.6-1.6-1.6H10.4C9.6,8.8,8.9,9.5,8.9,10.3z x M38.8,23.8l-0.9-3c-0.3-0.8-1.1-1.3-2-1L29.1,22v-6.7c0-0.9-0.7-1.6-1.6-1.6h-3.1c-0.9,0-1.6,0.7-1.6,1.6V22l-6.6-2.2c-0.8-0.3-1.7,0.2-2,1l-0.9,3c-0.3,0.8,0.2,1.7,1,2l6.2,2L16,33.9c-0.5,0.7-0.3,1.7,0.4,2.2l2.6,1.8c0.7,0.5,1.7,0.3,2.2-0.4l4.9-6.8l4.9,6.8c0.5,0.7,1.5,0.9,2.2,0.4l2.6-1.8c0.7-0.5,0.9-1.5,0.4-2.2l-4.5-6.2l6.1-2C38.6,25.5,39,24.7,38.8,23.8z'
            }
        );
        svgs.add(
            new List<String>{
                'Paste',
                'M17.5,12h17c0.8,0,1.5-0.7,1.5-1.5V6c0-2.2-1.8-4-4-4H20c-2.2,0-4,1.8-4,4v4.5C16,11.3,16.7,12,17.5,12z x M44,6h-2.5C40.7,6,40,6.7,40,7.5V12c0,2.2-1.8,4-4,4H16c-2.2,0-4-1.8-4-4V7.5C12,6.7,11.3,6,10.5,6H8c-2.2,0-4,1.8-4,4v36c0,2.2,1.8,4,4,4h36c2.2,0,4-1.8,4-4V10C48,7.8,46.2,6,44,6z M38,41c0,0.6-0.4,1-1,1H15c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h22c0.6,0,1,0.4,1,1V41z M38,33c0,0.6-0.4,1-1,1H15c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h22c0.6,0,1,0.4,1,1V33z M38,25c0,0.6-0.4,1-1,1H15c-0.6,0-1-0.4-1-1v-2c0-0.6,0.4-1,1-1h22c0.6,0,1,0.4,1,1V25z'
            }
        );
        svgs.add(
            new List<String>{
                'Pause',
                'M30,43c0,1,0.9,2,2,2h4c1.1,0,2-1.1,2-2V9c0-1-0.9-2-2-2h-4c-1.1,0-2,1.1-2,2V43z x M14,43c0,1,0.9,2,2,2h4c1.1,0,2-1.1,2-2V9c0-1-0.9-2-2-2h-4c-1.1,0-2,1.1-2,2V43z'
            }
        );
        svgs.add(
            new List<String>{
                'Payment Gateway',
                'm19.56 6.29a17.94 17.94 0 0 0 0 35.87h.8v-14.22c0-1.06.81-2.42 1.88-2.42h15.2c0-.59.06-1 .06-1.32a18 18 0 0 0 -17.94-17.91zm14.32 16.4h-4.62a26.74 26.74 0 0 0 -2.54-10.76 14.52 14.52 0 0 1 7.16 10.76zm-16.37-11.79v11.79h-4.1c.31-5.62 2.08-10.06 4.1-11.79zm0 14.86v11.78c-2-1.73-3.79-6.15-4.1-11.78zm4.1-3.07v-11.79c2 1.73 3.8 6.17 4.1 11.79zm-9.22-10.76a27.62 27.62 0 0 0 -2.53 10.76h-4.65a14.48 14.48 0 0 1 7.18-10.76zm-7.17 14.34h4.65a26.74 26.74 0 0 0 2.52 10.73 14.5 14.5 0 0 1 -7.17-10.73z x m47.5 28.56h-21.77a2.5 2.5 0 0 0 -2.5 2.5v12.15a2.5 2.5 0 0 0 2.5 2.5h21.77a2.5 2.5 0 0 0 2.5-2.5v-12.15a2.5 2.5 0 0 0 -2.5-2.5zm-18.84 14.65a2.92 2.92 0 0 0 -2.84-3h-.08v-6.21a2.93 2.93 0 0 0 3-2.84v-.07h15.81a2.91 2.91 0 0 0 2.87 2.91h.08v6.25a2.93 2.93 0 0 0 -3 2.86v.09z'
            }
        );
        svgs.add(
            new List<String>{
                'Pdx Ext',
                'm28.6 11.4h5.1a1.11 1.11 0 0 0 1.1-1.1 1.32 1.32 0 0 0 -.3-.8l-7.2-7.1a.89.89 0 0 0 -.7-.3 1.11 1.11 0 0 0 -1.1 1.1v5.1a3.12 3.12 0 0 0 3.1 3.1z x m49.83 32.45a1.43 1.43 0 0 0 -1.39-1.45h-12a1.43 1.43 0 0 0 -1.44 1.44v1.44a1.43 1.43 0 0 0 1.4 1.44h6.14l-11 11a1.42 1.42 0 0 0 0 2l1 1a1.54 1.54 0 0 0 1.09.45 1.32 1.32 0 0 0 .94-.38l11-11v6a1.43 1.43 0 0 0 1.43 1.44h1.53a1.43 1.43 0 0 0 1.47-1.4z x m18.35 20.68h-1.46v4.93h1.46a1.56 1.56 0 0 0 1.56-1.1 3.93 3.93 0 0 0 .24-1.44 3.61 3.61 0 0 0 -.36-1.77 1.53 1.53 0 0 0 -1.44-.62z x m11.29 20.93a1.27 1.27 0 0 0 -.84-.25h-1.45v2.23h1.46a1.18 1.18 0 0 0 .84-.28 1.09 1.09 0 0 0 .3-.86 1 1 0 0 0 -.33-.84z x m33.24 16h-7.84a4.67 4.67 0 0 1 -4.7-4.6v-7.8a1.42 1.42 0 0 0 -1.34-1.5h-12.56a4.67 4.67 0 0 0 -4.7 4.6v29.4a4.6 4.6 0 0 0 4.62 4.6h17.88v-.1a15.92 15.92 0 0 1 10.2-14.9v-8.1a1.58 1.58 0 0 0 -1.56-1.6zm-20.75 7.65a2.93 2.93 0 0 1 -1.89.56h-1.6v2.71h-1.51v-7.55h3.24a2.64 2.64 0 0 1 1.76.63 2.3 2.3 0 0 1 .66 1.8 2.35 2.35 0 0 1 -.66 1.85zm8.66 1.9a2.73 2.73 0 0 1 -2.53 1.45h-3.26v-7.63h3.26a3.85 3.85 0 0 1 1.17.17 2.49 2.49 0 0 1 1.28.95 3.43 3.43 0 0 1 .54 1.22 5.6 5.6 0 0 1 .14 1.29 5 5 0 0 1 -.6 2.55zm7.92-4.84h-3.81v1.74h3.34v1.31h-3.34v3.16h-1.57v-7.54h5.38z'
            }
        );
        svgs.add(
            new List<String>{
                'People',
                'M42,22.3c-2.8-1.1-3.2-2.2-3.2-3.3s0.8-2.2,1.8-3c1.7-1.4,2.6-3.5,2.6-5.8c0-4.4-2.9-8.2-8-8.2c-4.7,0-7.5,3.2-7.9,7.1c0,0.4,0.2,0.7,0.5,0.9c3.8,2.4,6.1,6.6,6.1,11.7c0,3.8-1.5,7.2-4.2,9.6c-0.2,0.2-0.2,0.6,0,0.8c0.7,0.5,2.3,1.2,3.3,1.7c0.3,0.1,0.5,0.2,0.8,0.2h12.1c2.3,0,4.1-1.9,4.1-4v-0.6C50,25.9,46.2,24,42,22.3z x M28.6,36.2c-3.4-1.4-3.9-2.6-3.9-3.9c0-1.3,1-2.6,2.1-3.6c2-1.7,3.1-4.1,3.1-6.9c0-5.2-3.4-9.7-9.6-9.7c-6.1,0-9.6,4.5-9.6,9.7c0,2.8,1.1,5.2,3.1,6.9c1.1,1,2.1,2.3,2.1,3.6c0,1.3-0.5,2.6-4,3.9c-5,2-9.9,4.3-9.9,8.5V45v1c0,2.2,1.8,4,4.1,4h27.7c2.3,0,4.2-1.8,4.2-4v-1v-0.4C38,40.5,33.6,38.2,28.6,36.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Percent',
                'M39.55,26A10.5,10.5,0,1,0,50,36.5,10.5,10.5,0,0,0,39.55,26Zm0,16.14a5.65,5.65,0,1,1,5.6-5.64,5.64,5.64,0,0,1-5.6,5.64ZM23,15.5a10.48,10.48,0,1,0-3.07,7.43A10.5,10.5,0,0,0,23,15.5Zm-10.5,5.64a5.65,5.65,0,1,1,4-1.65A5.63,5.63,0,0,1,12.49,21.14Zm26.71-15A.8.8,0,0,0,38.49,5h-3a.83.83,0,0,0-.64.4h0l-22,40.41h0a.78.78,0,0,0,0,.78.79.79,0,0,0,.68.39h3a.8.8,0,0,0,.64-.4h0l22-40.41Z'
            }
        );
        svgs.add(
            new List<String>{
                'Photo',
                'M26,20c-4.4,0-8,3.6-8,8s3.6,8,8,8s8-3.6,8-8S30.4,20,26,20z x M46,14h-5.2c-1.4,0-2.6-0.7-3.4-1.8l-2.3-3.5C34.4,7,32.7,6,30.9,6h-9.8c-1.8,0-3.5,1-4.3,2.7l-2.3,3.5c-0.7,1.1-2,1.8-3.4,1.8H6c-2.2,0-4,1.8-4,4v24c0,2.2,1.8,4,4,4h40c2.2,0,4-1.8,4-4V18C50,15.8,48.2,14,46,14z M26,40c-6.6,0-12-5.4-12-12s5.4-12,12-12s12,5.4,12,12S32.6,40,26,40z'
            }
        );
        svgs.add(
            new List<String>{
                'Pin',
                'M49.5,15.4L36,1.9c-1.4-1.4-3.6-1.4-5,0s-1.4,3.6,0,5l0.7,0.7L15.5,18.3L15,17.8c-1.4-1.4-3.6-1.4-5,0s-1.4,3.6,0,5l7.2,7.2L2.4,44.8c-1.4,1.4-1.4,3.7,0,5.1c1.4,1.4,3.7,1.4,5.1,0L22.3,35l6.3,6.3c1.4,1.4,3.6,1.4,5,0c1.4-1.4,1.4-3.6,0-5l-0.5-0.5l10.6-16.3l0.7,0.7c1.4,1.4,3.6,1.4,5,0h0C50.8,19,50.8,16.8,49.5,15.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Pinned',
                'M36.9,23.7h-0.5L33,7.9h0.9c1.6,0,2.9-1.3,2.9-2.9s-1.3-2.9-2.9-2.9H18.1c-1.6,0-2.9,1.3-2.9,2.9s1.3,2.9,2.9,2.9H19l-3.3,15.8h-0.5c-1.6,0-2.9,1.3-2.9,2.9s1.3,2.9,2.9,2.9h8.4v17.4c0,1.6,1.3,3,3,3s3-1.3,3-3V29.6h7.4c1.6,0,2.9-1.3,2.9-2.9S38.5,23.7,36.9,23.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Play',
                'M8,43.7V8.3c0-1,1.3-1.7,2.2-0.9l33.2,17.3c0.8,0.6,0.8,1.9,0,2.5L10.2,44.7C9.3,45.4,8,44.8,8,43.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Podcast Webinar',
                'M48,22.8C48,22.8,48,22.8,48,22.8c0-4.9-1.8-9.6-5-13.2c0,0,0,0,0,0c-0.1-0.1-0.3-0.3-0.4-0.4C38.6,4.8,32.6,2,26,2C19.7,2,13.9,4.6,9.9,8.6c0,0,0,0-0.1,0C6.1,12.4,4,17.5,4,22.8C4,28.1,6.1,33.2,9.9,37c0.8,0.8,2,0.8,2.8,0s0.8-2.1,0-2.9c-2.9-2.9-4.6-7-4.6-11.2c0-3.7,1.3-7.1,3.4-9.9c0.4-0.5,0.7-0.9,1.2-1.3c0.1-0.1,0.2-0.2,0.2-0.3C16.2,8,20.9,6,26,6c9.8,0,17.8,7.6,17.9,16.9c0,4.2-1.7,8.3-4.7,11.2c-0.8,0.8-0.8,2.1,0,2.9s2.1,0.8,2.9,0C45.9,33.2,48,28.2,48,22.8L48,22.8C48,22.8,48,22.8,48,22.8z x M39.6,22.9C39.6,22.8,39.6,22.8,39.6,22.9C39.6,22.8,39.6,22.8,39.6,22.9C39.6,22.8,39.6,22.8,39.6,22.9c0-7.2-6.1-13-13.6-13c-6.2,0-11.4,3.9-13.1,9.2c-0.4,1.2-0.6,2.4-0.6,3.7c0,3.1,1.2,6.1,3.4,8.3c0.8,0.8,2.1,0.8,2.9,0c0.8-0.8,0.8-2.1,0-2.9c-1.4-1.4-2.2-3.3-2.2-5.3c0-4.9,4.5-8.8,9.6-8.8s9.6,4,9.6,8.8c0,2-0.8,3.9-2.2,5.3c-0.8,0.8-0.8,2.1,0,2.9c0.8,0.8,2,0.8,2.8,0C38.4,28.9,39.6,26,39.6,22.9L39.6,22.9z x M28.2,32.4h-4.4c-1.7,0-3.2,1.4-3.2,3.2v11.3c0,1.7,1.4,3.2,3.2,3.2h4.4c1.7,0,3.2-1.4,3.2-3.2V35.5C31.4,33.8,29.9,32.4,28.2,32.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Power',
                'M34.4,7.7C33.7,7.4,33,7.9,33,8.6v3.8c0,0.7,0.4,1.4,1,1.7c5.3,3,8.7,9,7.9,15.7c-0.8,7.3-6.7,13.3-14.1,14.1C18.2,45,10,37.4,10,28c0-5.9,3.2-11.1,8-13.9c0.6-0.3,1-1,1-1.7V8.6c0-0.7-0.7-1.2-1.4-0.9C9.1,11.2,3.2,20,4.1,30C5,40.3,13.2,48.7,23.5,49.9C36.7,51.3,48,41,48,28C48,18.8,42.4,11,34.4,7.7z x M29,3.5C29,2.7,28.3,2,27.5,2h-3C23.7,2,23,2.7,23,3.5v17c0,0.8,0.7,1.5,1.5,1.5h3c0.8,0,1.5-0.7,1.5-1.5V3.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Preview',
                'M51.8,25.1C47.1,15.6,37.3,9,26,9S4.9,15.6,0.2,25.1c-0.3,0.6-0.3,1.3,0,1.8C4.9,36.4,14.7,43,26,43s21.1-6.6,25.8-16.1C52.1,26.3,52.1,25.7,51.8,25.1z M26,37c-6.1,0-11-4.9-11-11s4.9-11,11-11s11,4.9,11,11S32.1,37,26,37z x M26,19c-3.9,0-7,3.1-7,7s3.1,7,7,7s7-3.1,7-7S29.9,19,26,19z'
            }
        );
        svgs.add(
            new List<String>{
                'Pricebook Entries',
                'M25,2.3l11.7.2a5.51,5.51,0,0,1,2.5,1h0l4.6,4.6,4.6,4.6a3.55,3.55,0,0,1,1,2.5h0L49.7,27a3.55,3.55,0,0,1-1,2.5h0L29.5,48.7a3.69,3.69,0,0,1-5,0h0L13.9,38.1,3.3,27.5a3.69,3.69,0,0,1,0-5h0L22.5,3.3a3.55,3.55,0,0,1,2.5-1ZM18.6,21l-1.9,1.8a.85.85,0,0,0,0,1.3L27.9,35.3a.85.85,0,0,0,1.3,0l1.9-1.9a.85.85,0,0,0,0-1.3L19.7,21A.65.65,0,0,0,18.6,21Zm5.3-5.4L22,17.5a.85.85,0,0,0,0,1.3L33.2,30a.85.85,0,0,0,1.3,0l1.9-1.9a.85.85,0,0,0,0-1.3L25.1,15.6A.91.91,0,0,0,23.9,15.6ZM42,10a3.69,3.69,0,0,0-5,0,3.69,3.69,0,0,0,0,5,3.69,3.69,0,0,0,5,0A3.69,3.69,0,0,0,42,10Z'
            }
        );
        svgs.add(
            new List<String>{
                'Print',
                'M46.5,17.4h-41c-2.2,0-4,1.8-4,4v14c0,2.2,1.8,4,4,4h5.9l0,5.8c0,2.2,1.8,4,4,4h21.3c2.2,0,4-1.8,4-4l0-5.8h5.9c2.2,0,4-1.8,4-4v-14C50.5,19.2,48.7,17.4,46.5,17.4z M8.3,27.7c-1.7,0-3-1.3-3-3c0-1.7,1.3-3,3-3s3,1.3,3,3C11.3,26.4,10,27.7,8.3,27.7z M35.9,43.1c0,0.8-0.7,1.5-1.5,1.5h-17c-0.8,0-1.5-0.7-1.5-1.5v-9.8c0-0.8,0.7-1.5,1.5-1.5h17c0.8,0,1.5,0.7,1.5,1.5V43.1z x M40.5,11.1c0,0.8-0.7,1.5-1.5,1.5H12.8c-0.8,0-1.5-0.7-1.5-1.5V4.3c0-0.8,0.7-1.5,1.5-1.5H39c0.8,0,1.5,0.7,1.5,1.5V11.1z'
            }
        );
        svgs.add(
            new List<String>{
                'Priority',
                'M9,3.5C9,2.7,8.3,2,7.5,2h-3C3.7,2,3,2.7,3,3.5v45C3,49.3,3.7,50,4.5,50h3C8.3,50,9,49.3,9,48.5V3.5z x M47.5,7.7c-16,8.4-14.2-8.8-33.5-2.1c-0.6,0.2-1,0.8-1,1.4v23.3c0,0.7,0.7,1.2,1.3,0.9c19.2-6.4,17.2,11.2,33.9,1.8c0.5-0.3,0.8-0.8,0.8-1.3V8.5C49,7.8,48.2,7.3,47.5,7.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Privately Shared',
                'M35.6,39.5c-0.7-4.1-4.9-6.2-8.3-7.7c-1.5-0.7-3.6-1.5-4.2-3.3c-0.4-1-0.2-2,0.3-2.9c0.9-0.9,1.7-1.7,2.4-2.8c0.2-0.3,0.3-0.5,0.5-0.8c2-2.9,2.3-6.9,1.1-10.2c-1.2-3.6-4.4-6-8.3-6.1c-0.1,0-0.2,0-0.3,0c-0.1,0-0.2,0-0.3,0c-3.9,0.1-7.1,2.5-8.3,6.1c-1.2,3.4-0.9,7.3,1.1,10.2c0.1,0.3,0.3,0.5,0.5,0.8c0.7,1.1,1.6,1.9,2.4,2.8c0.4,0.9,0.6,1.9,0.3,2.9c-0.6,1.8-2.7,2.6-4.2,3.3c-3.4,1.5-7.6,3.6-8.3,7.7c-0.7,3.4,1.6,6.8,5.2,6.8h8.5h6.6h8.5C34,46.3,36.3,42.9,35.6,39.5z x M41.3,9.9c4.1-0.2,7.4,3,7.4,7.1v0c0,0.3-0.2,0.4-0.4,0.4h-1.8c-0.3,0-0.4-0.1-0.4-0.4v0.1c0-2.4-1.8-4.4-4.1-4.6c-2.6-0.2-4.7,1.9-4.7,4.4v0c0,0.3-0.2,0.4-0.4,0.4h-1.8c-0.2,0-0.4-0.2-0.4-0.4C34.7,13.3,37.6,10.1,41.3,9.9z x M48.7,19.2H34.6c-1,0-1.8,0.8-1.8,1.8v8.4c0,1,0.8,1.8,1.8,1.8h14.1c1,0,1.8-0.8,1.8-1.8v-8.4C50.5,20,49.7,19.2,48.7,19.2z M43.7,27.9c0.1,0.3-0.1,0.6-0.4,0.6H40c-0.3,0-0.5-0.3-0.4-0.6l0.8-2.6c-0.7-0.4-1.1-1.2-0.9-2.1c0.2-0.8,0.8-1.5,1.7-1.7c1.4-0.3,2.6,0.7,2.6,2.1c0,0.7-0.4,1.4-0.9,1.7L43.7,27.9z'
            }
        );
        svgs.add(
            new List<String>{
                'Process',
                'M16.2,23.2l8.5-10.6c0.6-0.8,1.8-0.8,2.4,0l8.5,10.7c0.3,0.4,0.7,0.7,1.2,0.7h9.6c0.8,0,1.6-0.7,1.6-1.5V8c0-2.2-1.9-4-4.1-4H8C5.8,4,4,5.8,4,8v14.5C4,23.3,4.7,24,5.5,24H15C15.5,24,15.9,23.6,16.2,23.2z x M35.7,28.8l-8.5,10.6c-0.6,0.8-1.8,0.8-2.4,0l-8.5-10.7C15.9,28.4,15.5,28,15,28H5.5C4.7,28,4,28.7,4,29.5V44c0,2.2,1.8,4,4,4h36c2.2,0,4-1.8,4-4V29.5c0-0.8-0.7-1.5-1.5-1.5h-9.6C36.4,28,36,28.4,35.7,28.8z'
            }
        );
        svgs.add(
            new List<String>{
                'Product Warranty Term',
                'M38.77,25.61c1.42,0,2.54,1.54,3.79,2.07s3.19.24,4.13,1.24.71,2.84,1.24,4.14S50,35.42,50,36.84s-1.54,2.54-2.07,3.78-.23,3.19-1.24,4.14-2.83.7-4.13,1.24-2.37,2.06-3.79,2.06S36.23,46.53,35,46s-3.19-.24-4.13-1.24-.71-2.84-1.24-4.14-2.07-2.36-2.07-3.78,1.53-2.54,2.07-3.78.23-3.19,1.24-4.14,2.83-.71,4.13-1.24S37.36,25.61,38.77,25.61ZM26.71,41a4.82,4.82,0,0,1,.38.7c.5,1.22.47,2.83.89,4.08H3.39A1.5,1.5,0,0,1,2,44.15H2V42.56A1.51,1.51,0,0,1,3.39,41H26.71ZM43,33.18a.55.55,0,0,0-.81,0h0l-4.38,5-2-2a.55.55,0,0,0-.81,0h0l-.82.77a.52.52,0,0,0,0,.77h0l2.8,2.8a1.13,1.13,0,0,0,.82.35,1.05,1.05,0,0,0,.82-.35l5.19-5.77a.62.62,0,0,0,0-.77h0ZM6.65,12.3A1.38,1.38,0,0,1,8,13.73H8V36a1.38,1.38,0,0,1-1.32,1.43H3.33A1.39,1.39,0,0,1,2,36H2V13.73A1.39,1.39,0,0,1,3.33,12.3H6.65Zm19,0a1.43,1.43,0,0,1,1.43,1.43h0V32c-.68,1.57-2.63,3-2.63,4.81a2.48,2.48,0,0,0,.06.54H21.35A1.43,1.43,0,0,1,19.92,36h0V13.73a1.43,1.43,0,0,1,1.43-1.43h4.3Zm-9.71,0a1.52,1.52,0,0,1,1.59,1.43h0V36a1.52,1.52,0,0,1-1.59,1.43h-1.6A1.52,1.52,0,0,1,12.75,36h0V13.73a1.52,1.52,0,0,1,1.59-1.43h1.6Zm17.91,0a1.52,1.52,0,0,1,1.6,1.43h0V24.21a7,7,0,0,1-1.5.94,19.63,19.63,0,0,1-3.28.69V13.73a1.52,1.52,0,0,1,1.59-1.43h1.59Zm8.63,0a1.39,1.39,0,0,1,1.33,1.43h0v11.5l-.21-.08c-1.58-.67-3-2.63-4.83-2.63a2.79,2.79,0,0,0-.94.17v-9a1.39,1.39,0,0,1,1.33-1.43h3.32Zm-.07-8.36a1.51,1.51,0,0,1,1.4,1.59h0V7.12a1.51,1.51,0,0,1-1.4,1.59h-39A1.5,1.5,0,0,1,2,7.12H2V5.53A1.5,1.5,0,0,1,3.39,3.94h39Z'
            }
        );
        svgs.add(
            new List<String>{
                'Products',
                'M31.9,39.5h6A1.42,1.42,0,0,0,39.4,38V14a1.42,1.42,0,0,0-1.5-1.5h-6A1.42,1.42,0,0,0,30.4,14V38A1.42,1.42,0,0,0,31.9,39.5Z x M45.4,39.5h3A1.42,1.42,0,0,0,49.9,38V14a1.42,1.42,0,0,0-1.5-1.5h-3A1.42,1.42,0,0,0,43.9,14V38A1.42,1.42,0,0,0,45.4,39.5Z x M25,39.5h0A1.37,1.37,0,0,0,26.5,38V14A1.42,1.42,0,0,0,25,12.5h0A1.42,1.42,0,0,0,23.5,14V38A1.37,1.37,0,0,0,25,39.5Z x M16.6,39.5H18A1.42,1.42,0,0,0,19.5,38V14A1.42,1.42,0,0,0,18,12.5H16.5A1.42,1.42,0,0,0,15,14V38A1.45,1.45,0,0,0,16.6,39.5Z x M3.6,39.5h6A1.42,1.42,0,0,0,11.1,38V14a1.42,1.42,0,0,0-1.5-1.5h-6A1.42,1.42,0,0,0,2.1,14V38A1.47,1.47,0,0,0,3.6,39.5Z'
            }
        );
        svgs.add(
            new List<String>{
                'Promotions',
                'M33.39,28.66a3.12,3.12,0,1,0,3.15,3.13h0a3.13,3.13,0,0,0-3.11-3.13Z x M18.52,17.08a3.12,3.12,0,1,0,3.12,3.13,3.12,3.12,0,0,0-3.12-3.13Z x M48.77,22.84l-2.61-3.13a5.61,5.61,0,0,1-1.31-3.24l-.3-4a5.13,5.13,0,0,0-4.69-4.78l-3.49-.28a7.36,7.36,0,0,1-4.2-1.79L29.52,3.29a5.15,5.15,0,0,0-6.7-.06L19.94,5.66A6.64,6.64,0,0,1,16.15,7.2l-3.74.26a5.14,5.14,0,0,0-4.78,4.7l-.27,3.41a7.49,7.49,0,0,1-1.8,4.24L3.27,22.45a5.14,5.14,0,0,0-.06,6.69l2.49,3A6.21,6.21,0,0,1,7.12,35.7l.28,3.85a5.14,5.14,0,0,0,4.69,4.78l3.5.31a7.23,7.23,0,0,1,4.18,1.78l2.66,2.3a5.17,5.17,0,0,0,6.7.05l3.05-2.55a5.9,5.9,0,0,1,3.4-1.36l4-.29a5.13,5.13,0,0,0,4.78-4.69l.29-3.24a8.14,8.14,0,0,1,2-4.64l2.13-2.43A5.12,5.12,0,0,0,48.77,22.84Zm-36-2.63A5.8,5.8,0,1,1,18.55,26h0A5.79,5.79,0,0,1,12.73,20.21Zm8.39,17.11a.46.46,0,0,1-.35.23H19.08a.44.44,0,0,1-.37-.22.42.42,0,0,1,0-.43L30.83,14.65a.51.51,0,0,1,.36-.22H33a.44.44,0,0,1,.21.59h0Zm18.13-5.54A5.81,5.81,0,1,1,33.44,26h0a5.79,5.79,0,0,1,5.77,5.82h0Z'
            }
        );
        svgs.add(
            new List<String>{
                'Prompt',
                'M47,4.5H5c-1.7,0-3,1.3-3,3v30.6c0,1.7,1.3,3,3,3h14.5l3.6,5.2c1,1.4,2.8,1.7,4.2,0.7c0.2-0.2,0.4-0.4,0.6-0.6l4.2-5.3H47c1.7,0,3-1.3,3-3V7.5C50,5.8,48.7,4.5,47,4.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Prompt Edit',
                'M47,4.5H5c-1.7,0-3,1.3-3,3v30.6c0,1.7,1.3,3,3,3h14.5l3.6,5.2c1,1.4,2.8,1.7,4.2,0.7c0.2-0.2,0.4-0.4,0.6-0.6l4.2-5.3H47c1.7,0,3-1.3,3-3V7.5C50,5.8,48.7,4.5,47,4.5z M21.3,32L21.3,32c-0.2,0.2-0.3,0.3-0.5,0.3l-5,1.2c-0.5,0.1-0.9-0.3-0.8-0.8l1.2-5c0-0.1,0.1-0.3,0.2-0.4l0.1-0.1c0.1-0.1,0.4-0.1,0.6,0l4.2,4.2C21.4,31.6,21.4,31.9,21.3,32z M33.4,19.7L23.1,30c-0.2,0.2-0.5,0.2-0.6,0l-4.1-4.1c-0.2-0.1-0.2-0.4,0-0.6L28.6,15c0.2-0.2,0.5-0.2,0.6,0l4.1,4.1C33.5,19.3,33.5,19.5,33.4,19.7z M36.5,16.7l-1.2,1.2c-0.2,0.2-0.5,0.2-0.6,0l-4.1-4.1c-0.2-0.2-0.2-0.5,0-0.6l1.1-1.2c0.7-0.7,1.9-0.7,2.6,0l2.2,2.2C37.2,14.9,37.2,16,36.5,16.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Propagation Policy',
                'M13.6,2H8A6,6,0,0,0,2,8v4a6,6,0,0,0,6,6h5.6a6,6,0,0,0,6-6V8A6,6,0,0,0,13.6,2Zm-2,11.2H10a3.2,3.2,0,0,1,0-6.4h1.6a3.2,3.2,0,0,1,0,6.4Z x M30.4,18H36a6,6,0,0,0,6-6V8a6,6,0,0,0-6-6H30.4a6,6,0,0,0-6,6v4A6,6,0,0,0,30.4,18Zm2-11.2H34a3.2,3.2,0,1,1,0,6.4H32.4a3.2,3.2,0,1,1,0-6.4Z x M13.6,22.8H8a6,6,0,0,0-6,6v4a6,6,0,0,0,6,6h5.6a6,6,0,0,0,6-6v-4A6,6,0,0,0,13.6,22.8ZM11.6,34H10a3.2,3.2,0,1,1,0-6.4h1.6a3.2,3.2,0,1,1,0,6.4Z x M47.6,39.6h-8V36.78a7.2,7.2,0,1,0-4.8,0V39.6h-8A2.39,2.39,0,0,0,24.4,42v5.62A2.39,2.39,0,0,0,26.8,50h0a2.39,2.39,0,0,0,2.38-2.4V44.4h5.6v3.22A2.39,2.39,0,0,0,37.2,50h0a2.39,2.39,0,0,0,2.38-2.4V44.4h5.6v3.22A2.39,2.39,0,0,0,47.6,50h0A2.39,2.39,0,0,0,50,47.6V42A2.39,2.39,0,0,0,47.6,39.6Zm-10.4-12h0A2.4,2.4,0,1,1,34.8,30,2.39,2.39,0,0,1,37.22,27.6Z'
            }
        );
        svgs.add(
            new List<String>{
                'Puzzle',
                'M45,38.4c-0.2,2.7-0.5,5.6-1,8.4c-0.1,0.8-1,1.7-1.8,1.8c-5.4,0.6-10.7,1-16.1,1c-5.3,0-10.7-0.3-16-1c-0.8-0.1-1.7-0.9-1.8-1.8c-0.7-4.4-1.1-8.9-1.1-13.4s0.4-9,1.1-13.4c0.1-0.8,1-1.6,1.8-1.8c3.3-0.4,6.5-0.6,9.7-0.8c0,0,2.6-0.1,2.4-2.6c-0.2-2.2-4-3.7-4-7.4c0-3,3-5.4,7.9-5.4c4.8,0,7.8,2.4,7.8,5.4c0,3.8-3.7,5.2-3.9,7.4c-0.2,2.4,2.4,2.6,2.4,2.6c3.3,0.1,6.6,0.4,9.8,0.8c0.8,0.1,1.7,0.9,1.8,1.8c0.5,3.1,0.8,6,1,9.1c0,0.9-0.7,1.8-1.6,1.8c-0.3,0-0.6,0-0.9,0c-0.9,0-2.3-0.7-2.9-1.4c0,0-2.1-2.2-4.4-2.3c-3.7-0.1-6.5,3.1-6.5,6.6s2.8,6.8,6.4,6.7c2.2-0.1,4.4-2.3,4.4-2.3c0.7-0.6,2-1.2,2.9-1.2c0.3,0,0.6,0,0.9,0C44.4,37,45.1,37.6,45,38.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Qualifications',
                'M18.37,35.92a.4.4,0,0,1-.31.19H16.61a.39.39,0,0,1-.33-.19.35.35,0,0,1,0-.37L26.7,16.43a.42.42,0,0,1,.31-.18h1.55a.38.38,0,0,1,.18.51h0Z x M16.32,19.24a2.1,2.1,0,1,1-2.09,2.09h0a2.09,2.09,0,0,1,2.09-2.09m0-2.79a4.88,4.88,0,1,0,4.87,4.89h0A4.89,4.89,0,0,0,16.32,16.45Z x M47.15,26a1.34,1.34,0,0,0-1,.43L32.62,41.36a.44.44,0,0,1-.33.15.43.43,0,0,1-.31-.13l-4.67-4.6a1.33,1.33,0,0,0-1.86,0l-1.84,1.87a1.3,1.3,0,0,0,0,1.85l7.27,7.16a2.2,2.2,0,0,0,3.15-.09L50.06,30A1.3,1.3,0,0,0,50,28.11L48,26.34A1.3,1.3,0,0,0,47.15,26Z x M43.27,24.43l-1.65,1.81-1-1.2-.34-.41-2-2.35A7.35,7.35,0,0,1,36.58,18l-.25-3.42a1.83,1.83,0,0,0-1.64-1.69l-3-.24a8.88,8.88,0,0,1-5.13-2.17l-2.28-2A1.78,1.78,0,0,0,23.13,8,1.83,1.83,0,0,0,22,8.45L19.5,10.54a8.31,8.31,0,0,1-4.76,1.94l-3.22.22a1.77,1.77,0,0,0-1.67,1.63l-.24,2.92a8.93,8.93,0,0,1-2.17,5.16l-2,2.26a1.79,1.79,0,0,0,0,2.34l2.15,2.58a7.94,7.94,0,0,1,1.82,4.57l.24,3.29a1.79,1.79,0,0,0,1.64,1.68l3,.26a8.93,8.93,0,0,1,5.09,2.18l2.27,2,.12.09,2.7,2.65a4.38,4.38,0,0,1-1.63.32,4.43,4.43,0,0,1-2.91-1.08l-2.28-2A6.15,6.15,0,0,0,14.07,42l-3-.27a4.42,4.42,0,0,1-4-4.1l-.23-3.3a5.41,5.41,0,0,0-1.23-3.07L3.44,28.69A4.39,4.39,0,0,1,3.49,23l2-2.28A6.36,6.36,0,0,0,7,17l.24-2.93a4.4,4.4,0,0,1,4.1-4l3.21-.23A5.65,5.65,0,0,0,17.8,8.53l2.48-2.08A4.41,4.41,0,0,1,26,6.5l2.28,2A6.35,6.35,0,0,0,31.92,10l3,.23a4.42,4.42,0,0,1,4,4.11l.25,3.43a4.81,4.81,0,0,0,1.13,2.79l2.24,2.69A4,4,0,0,1,43.27,24.43Z x M26.39,32.91a4.78,4.78,0,0,1,3.37,1.38L31,35.47a4.88,4.88,0,0,0,2.76-4.39h0a4.87,4.87,0,0,0-4.87-4.87h0A4.89,4.89,0,0,0,24,31.08a4.81,4.81,0,0,0,.54,2.21A4.83,4.83,0,0,1,26.39,32.91Zm.37-1.84a2.1,2.1,0,1,1,2.1,2.1,2.08,2.08,0,0,1-2.1-2.1Z'
            }
        );
        svgs.add(
            new List<String>{
                'Question',
                'M28.4,38h-5c-0.8,0-1.4-0.6-1.4-1.4v-1.5c0-4.2,2.7-8,6.7-9.4c1.2-0.4,2.3-1.1,3.2-2.1c5-6,0.4-13.2-5.6-13.4c-2.2-0.1-4.3,0.7-5.9,2.2c-1.3,1.2-2.1,2.7-2.3,4.4c-0.1,0.6-0.7,1.1-1.5,1.1h-5c-0.9,0-1.6-0.7-1.5-1.6c0.4-3.8,2.1-7.2,4.8-9.9c3.2-3,7.3-4.6,11.7-4.5c8.3,0.3,15.1,7.1,15.4,15.4c0.3,7-4,13.3-10.5,15.7c-0.9,0.4-1.5,1.1-1.5,2v1.5C30,37.4,29.2,38,28.4,38z x M30,48.5c0,0.8-0.7,1.5-1.5,1.5h-5c-0.8,0-1.5-0.7-1.5-1.5v-5c0-0.8,0.7-1.5,1.5-1.5h5c0.8,0,1.5,0.7,1.5,1.5V48.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Questions and Answers',
                'M50,28c0-3.9-2.5-7.3-6-8.5C43.7,9.8,35.8,2,26,2S8.3,9.8,8,19.5c-3.5,1.2-6,4.6-6,8.5c0,4.2,2.9,7.7,6.7,8.7C10.9,44.4,17.8,50,26,50s15.1-5.6,17.3-13.3C47.1,35.7,50,32.2,50,28z M40,19l-0.1-0.1l0.4,0.1H40z M26,46c-7.7,0-14-6.5-14-14.4c0-2,0.4-5,1.2-6.8c0.1-0.3,0.3-0.6,0.4-0.9c3-1.2,5.6-3.3,7.3-6c3.5,4.4,9,7.4,15.1,7.4c2.1,0,2.7,0.1,2.9,0c0.4,1.3,0.8,2.9,0.9,4.5c-0.6,2.5-4.5,4.9-10,5.2C29.6,34.5,29,34,28.4,34h-5c-0.8,0-1.4,0.8-1.4,1.6v3c0,0.8,0.6,1.4,1.4,1.4h5c0.7,0,1.2-0.3,1.4-0.9c3.6-0.1,6.8-1.1,9.3-2.6C37.2,42,32.1,46,26,46z'
            }
        );
        svgs.add(
            new List<String>{
                'Quick Text',
                'M26.1,3.3C12.5,3.3,1.5,13.4,1.5,25.8c0,3.9,1.1,7.6,3,10.9c0.3,0.5,0.4,1.1,0.2,1.7l-3.2,8.7c-0.3,0.8,0.5,1.5,1.3,1.3l8.8-3.4c0.5-0.2,1.1-0.1,1.7,0.2c3.7,2.1,8.1,3.3,12.9,3.3c13.5-0.1,24.5-10.1,24.5-22.6C50.7,13.4,39.7,3.3,26.1,3.3z M14.7,25c0-0.5,0.4-1,1-1h15.9c0.5,0,1,0.4,1,1V27c0,0.5-0.4,1-1,1H15.6c-0.5,0-1-0.4-1-1V25z M37.6,34.6c0,0.5-0.4,1-1,1h-21c-0.5,0-1-0.4-1-1v-1.9c0-0.5,0.4-1,1-1h21c0.5,0,1,0.4,1,1V34.6z M37.6,19.3c0,0.5-0.4,1-1,1h-21c-0.5,0-1-0.4-1-1v-1.9c0-0.5,0.4-1,1-1h21c0.5,0,1,0.4,1,1V19.3z'
            }
        );
        svgs.add(
            new List<String>{
                'Quotation Marks',
                'M44.3,6.5c-9,0-15.9,7-15.9,16V44c0,0.8,0.7,1.5,1.5,1.5h17c0.8,0,1.5-0.7,1.5-1.5V27c0-0.8-0.7-1.5-1.5-1.5H34.4v-3c0-5,4.9-10,9.9-10h2.6c0.8,0,1.5-0.7,1.5-1.5V8c0-0.8-0.7-1.5-1.5-1.5H44.3z x M19.5,6.5c-9,0-15.9,7-15.9,16V44c0,0.8,0.7,1.5,1.5,1.5h17c0.8,0,1.5-0.7,1.5-1.5V27c0-0.8-0.7-1.5-1.5-1.5H9.6v-3c0-5,4.9-10,9.9-10h2.6c0.8,0,1.5-0.7,1.5-1.5V8c0-0.8-0.7-1.5-1.5-1.5H19.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Quote',
                'M45.2,2.1H27.7c-1.1-0.1-2.1,0.5-2.9,1.3L3.4,24.9c-1.8,1.8-1.8,4.9,0,6.8l17,17c1.8,1.8,4.9,1.8,6.8,0l21.7-21.8c0.8-0.8,1.3-2.1,1.2-3.2V6.9C50,4.3,47.8,2.1,45.2,2.1z M27.9,37.3l-1.1,1.1c-0.6,0.6-1.6,0.6-2.2,0L13.7,27.6c-0.6-0.6-0.6-1.6,0-2.2l1.1-1.1c0.6-0.6,1.6-0.6,2.2,0l10.9,10.9C28.6,35.7,28.6,36.7,27.9,37.3z M34.3,30.9L33.2,32c-0.6,0.6-1.6,0.6-2.2,0L20.1,21.2c-0.6-0.6-0.6-1.6,0-2.2l1.1-1.1c0.6-0.6,1.6-0.6,2.2,0l10.9,10.9C35,29.3,35,30.3,34.3,30.9z M38.8,17.3c-2.2,0-4-1.8-4-4s1.8-4,4-4s4,1.8,4,4S41,17.3,38.8,17.3z'
            }
        );
        svgs.add(
            new List<String>{
                'Radio Button',
                'M13.1,28.5C7.2,28.5,2.5,33.2,2.5,39c0,5.8,4.7,10.6,10.6,10.6c5.8,0,10.6-4.7,10.6-10.6C23.6,33.2,18.9,28.5,13.1,28.5z M13.1,44.9c-3.2,0-5.9-2.6-5.9-5.9s2.6-5.9,5.9-5.9s5.9,2.6,5.9,5.9S16.3,44.9,13.1,44.9z x M38.9,28.5c-5.8,0-10.6,4.7-10.6,10.6c0,5.8,4.7,10.6,10.6,10.6c5.8,0,10.6-4.7,10.6-10.6C49.5,33.2,44.8,28.5,38.9,28.5z x M13.1,2.5C7.2,2.5,2.5,7.2,2.5,13.1c0,5.8,4.7,10.6,10.6,10.6c5.8,0,10.6-4.7,10.6-10.6C23.6,7.2,18.9,2.5,13.1,2.5z M13.1,18.9c-3.2,0-5.9-2.6-5.9-5.9s2.6-5.9,5.9-5.9s5.9,2.6,5.9,5.9S16.3,18.9,13.1,18.9z x M38.9,2.5c-5.8,0-10.6,4.7-10.6,10.6c0,5.8,4.7,10.6,10.6,10.6c5.8,0,10.6-4.7,10.6-10.6C49.5,7.2,44.8,2.5,38.9,2.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Rating',
                'M27.4133467,3.10133815 L32.0133467,18.1013381 C32.2133467,18.7013381 32.8133467,19.0013381 33.4133467,19.0013381 L48.4133467,19.0013381 C49.9133467,19.0013381 50.5133467,21.0013381 49.3133467,21.9013381 L37.1133467,30.9013381 C36.6133467,31.3013381 36.4133467,32.0013381 36.6133467,32.6013381 L42.4133467,48.0013381 C42.8133467,49.4013381 41.3133467,50.6013381 40.1133467,49.7013381 L27.0133467,39.9013381 C26.5133467,39.5013381 25.8133467,39.5013381 25.2133467,39.9013381 L12.0133467,49.7013381 C10.8133467,50.6013381 9.21334668,49.4013381 9.71334668,48.0013381 L15.3133467,32.6013381 C15.5133467,32.0013381 15.3133467,31.3013381 14.8133467,30.9013381 L2.61334668,21.9013381 C1.41334668,21.0013381 2.11334668,19.0013381 3.51334668,19.0013381 L18.5133467,19.0013381 C19.2133467,19.0013381 19.7133467,18.8013381 19.9133467,18.1013381 L24.6133467,3.00133815 C25.0133467,1.60133815 27.0133467,1.70133815 27.4133467,3.10133815 Z M26.0133467,12.8023264 C26,14.1700393 26,33.5426636 26,34.4953918 C26.1865845,34.6476135 28.9331193,36.6890643 34.2396046,40.6197441 C34.9394191,41.144605 35.8141872,40.4447905 35.5809157,39.6283403 L35.5809157,39.6283403 L32.3085327,31.0201416 C31.9597778,30.2501831 32.3085327,29.7487793 32.7398682,29.4849854 L32.7398682,29.4849854 L39.6048489,24.6961622 C40.3046634,24.1713013 39.9547562,23.0049438 39.0799881,23.0049438 L39.0799881,23.0049438 L31.0206299,23.0049438 C30.6707226,23.0049438 29.7518921,22.8880615 29.5025635,21.9888306 L29.5025635,21.9888306 L26.8332347,13.4436151 C26.7175852,13.0388421 26.3602784,12.8204102 26.0133467,12.8023264 Z'
            }
        );
        svgs.add(
            new List<String>{
                'Recipe',
                'm31.2 4.24a2.24 2.24 0 1 1 -2.2-2.24 2.24 2.24 0 0 1 2.2 2.24zm-8.2 8.32a3 3 0 1 0 -3-3 3 3 0 0 0 3 3zm19.44 31-10-15.36v-8.2a2.14 2.14 0 0 0 2.4-2.24 2 2 0 0 0 -1.84-2.16h-13.8a2 2 0 0 0 -2 2 2.09 2.09 0 0 0 0 .25 2.16 2.16 0 0 0 2.4 2.24v8.31l-10 15.2a4.26 4.26 0 0 0 -.24 4.24 3.91 3.91 0 0 0 3.52 2.16h26.12a3.9 3.9 0 0 0 3.52-2.16 4 4 0 0 0 -.16-4.24zm-18.8-14v-9.16h4.8v9.28l4.72 7.52h-14.28z'
            }
        );
        svgs.add(
            new List<String>{
                'Reminder',
                'M50.3,7.5a7.45,7.45,0,0,0-6.2-5.9,7.81,7.81,0,0,0-5.8,1.6.81.81,0,0,0,.2,1.4,28.48,28.48,0,0,1,9.4,8.2.84.84,0,0,0,1.4,0A6.87,6.87,0,0,0,50.3,7.5ZM13.5,4.7a.9.9,0,0,0,.2-1.4A7,7,0,0,0,7.9,1.7,7.23,7.23,0,0,0,1.7,7.5a7.36,7.36,0,0,0,1.1,5.3.84.84,0,0,0,1.4,0A26,26,0,0,1,13.5,4.7ZM26,6.5a22.06,22.06,0,0,0-22,22,21.58,21.58,0,0,0,4.3,13L5,44.8a3.2,3.2,0,0,0,0,4.6,3.15,3.15,0,0,0,4.6,0l3.3-3.3A22.1,22.1,0,0,0,26,50.4a21.58,21.58,0,0,0,13-4.3l3.3,3.3a3.25,3.25,0,0,0,2.4,1A3.3,3.3,0,0,0,47,44.8l-3.3-3.3a21.58,21.58,0,0,0,4.3-13A21.94,21.94,0,0,0,26,6.5ZM10.5,28.4A15.5,15.5,0,1,1,26,43.9,15.49,15.49,0,0,1,10.5,28.4Zm18-.9V21.1a2.37,2.37,0,0,0-2.4-2.4,2.43,2.43,0,0,0-2.4,2.4v7.3a2.06,2.06,0,0,0,.7,1.7l5.7,5.7a2.41,2.41,0,0,0,3.4,0,2.3,2.3,0,0,0,0-3.4Z'
            }
        );
        svgs.add(
            new List<String>{
                'Replace',
                'M20,37.5c0-0.8-0.7-1.5-1.5-1.5h-15C2.7,36,2,36.7,2,37.5v11C2,49.3,2.7,50,3.5,50h15c0.8,0,1.5-0.7,1.5-1.5V37.5z x M8.1,22H3.2c-1,0-1.5,0.9-0.9,1.4l8,8.3c0.4,0.3,1,0.3,1.4,0l8-8.3c0.6-0.6,0.1-1.4-0.9-1.4h-4.7c0-5,4.9-10,9.9-10V6C15,6,8.1,13,8.1,22z x M41.8,20.3c-0.4-0.3-1-0.3-1.4,0l-8,8.3c-0.6,0.6-0.1,1.4,0.9,1.4h4.8c0,6-4.1,10-10.1,10v6c9,0,16.1-7,16.1-16H49c1,0,1.5-0.9,0.9-1.4L41.8,20.3z x M50,3.5C50,2.7,49.3,2,48.5,2h-15C32.7,2,32,2.7,32,3.5v11c0,0.8,0.7,1.5,1.5,1.5h15c0.8,0,1.5-0.7,1.5-1.5V3.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Reply',
                'M19.2,18.1L19.2,18.1c0,0-1.1-1.1-0.5-1.7l5.6-5.6c0.6-0.6,0.6-1.5,0-2.1l-2.1-2.2c-0.6-0.6-1.5-0.6-2.1,0L6.6,20c-0.6,0.6-0.6,1.5,0,2.1l13.5,13.5c0.6,0.6,1.5,0.6,2.1,0l2.1-2.1c0.6-0.6,0.6-1.5,0-2.1l-5.5-5.6c-0.6-0.6-0.2-1.5,0.5-1.7c11.1,0.4,20.1,9.3,20.8,20.6c0,0.8,0.7,1.4,1.5,1.4h3c0.9,0,1.4-0.7,1.3-1.6C45.2,30,34.2,18.6,19.2,18.1z'
            }
        );
        svgs.add(
            new List<String>{
                'Reply All',
                'M24.4,18.1c0,0-1.1-1.1-0.5-1.7l5.6-5.6c0.6-0.6,0.6-1.5,0-2.1l-2.1-2.2c-0.6-0.6-1.5-0.6-2.1,0L11.8,20c-0.6,0.6-0.6,1.5,0,2.1l13.5,13.5c0.6,0.6,1.5,0.6,2.1,0l2.1-2.1c0.6-0.6,0.6-1.5,0-2.1L24,25.8c-0.6-0.6-0.2-1.5,0.5-1.7c11.1,0.4,20.1,9.3,20.8,20.6c0,0.8,0.7,1.4,1.5,1.4h3c0.9,0,1.4-0.7,1.3-1.6C50.4,30,39.4,18.6,24.4,18.1z x M5.4,20.4L17,8.8c0.6-0.6,0.6-1.5,0-2.1l-0.1-0.2c-0.6-0.6-1.5-0.6-2.1,0L1.3,20c-0.6,0.6-0.6,1.5,0,2.1l13.5,13.5c0.6,0.6,1.5,0.6,2.1,0l0.1-0.1c0.6-0.6,0.6-1.5,0-2.1L5.5,21.8C5.5,21.8,4.8,21.2,5.4,20.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Report Issue',
                'M42,23H10c-2.2,0-4,1.8-4,4v19c0,2.2,1.8,4,4,4h32c2.2,0,4-1.8,4-4V27C46,24.8,44.2,23,42,23z M31,44.5c-1.5,1-3.2,1.5-5,1.5c-0.6,0-1.2-0.1-1.8-0.2c-2.4-0.5-4.4-1.8-5.7-3.8l3.3-2.2c0.7,1.1,1.9,1.9,3.2,2.1c1.3,0.3,2.6,0,3.8-0.8c2.3-1.5,2.9-4.7,1.4-6.9c-0.7-1.1-1.9-1.9-3.2-2.1c-1.3-0.3-2.6,0-3.8,0.8c-0.3,0.2-0.5,0.4-0.7,0.6L26,37h-9v-9l2.6,2.6c0.4-0.4,0.9-0.8,1.3-1.1c2-1.3,4.4-1.8,6.8-1.4c2.4,0.5,4.4,1.8,5.7,3.8C36.2,36.1,35.1,41.7,31,44.5z x M10,18.1v0.4C10,18.4,10,18.3,10,18.1C10,18.1,10,18.1,10,18.1z x M11,19h4c0.6,0,1-0.3,1-0.9V18c0-5.7,4.9-10.4,10.7-10C32,8.4,36,13,36,18.4v-0.3c0,0.6,0.4,0.9,1,0.9h4c0.6,0,1-0.3,1-0.9V18c0-9.1-7.6-16.4-16.8-16c-8.5,0.4-15,7.6-15.2,16.1C10.1,18.6,10.5,19,11,19z'
            }
        );
        svgs.add(
            new List<String>{
                'Ribbon',
                'M24.1,36.7L14.7,50l-2.4-6.4H5.9l8.2-11.1c1.6,1,3.3,1.1,4.5,1.4c0.4,0.1,0.9,0.2,1.1,0.2c0.2,0.1,0.6,0.4,0.8,0.6C21.4,35.3,22.6,36.2,24.1,36.7z M39.3,32.5c-1.6,1-3.3,1.1-4.5,1.4c-0.4,0.1-1,0.2-1.2,0.2c-0.2,0.1-0.6,0.4-0.8,0.6c-0.9,0.6-2,1.6-3.5,2.1L38.7,50l2.4-6.4h6.4C47.5,43.6,39.3,32.5,39.3,32.5z M26.7,11.6c-3.1,0-5.6,2.5-5.6,5.6s2.5,5.6,5.6,5.6s5.6-2.5,5.6-5.6S29.8,11.6,26.7,11.6z M41.9,17.2c0,1.9-2.1,3.4-2.8,5.1c-0.7,1.8-0.3,4.3-1.7,5.6c-1.3,1.3-3.8,1-5.6,1.7c-1.7,0.7-3.2,2.8-5.1,2.8s-3.4-2.1-5.1-2.8c-1.8-0.7-4.3-0.3-5.6-1.7c-1.3-1.3-1-3.8-1.7-5.6c-0.7-1.7-2.8-3.2-2.8-5.1s2.1-3.4,2.8-5.1c0.7-1.8,0.3-4.3,1.7-5.6c1.3-1.3,3.8-1,5.6-1.7C23.3,4.1,24.8,2,26.7,2s3.4,2.1,5.1,2.8c1.8,0.7,4.3,0.3,5.6,1.7c1.3,1.3,1,3.8,1.7,5.6C39.8,13.8,41.9,15.3,41.9,17.2z M37.1,17.2c0-5.8-4.6-10.4-10.4-10.4s-10.4,4.6-10.4,10.4s4.6,10.4,10.4,10.4S37.1,23,37.1,17.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Rotate',
                'M48.5,2h-3C44.7,2,44,2.7,44,3.5v7c0,0.9-1,1.5-1.6,0.8l0,0C37.7,6.1,31,3.4,23.7,4.1c-2.6,0.2-5.1,1-7.4,2.2c-1.2,0.6-2.4,1.3-3.4,2.1c-0.7,0.5-0.8,1.6-0.2,2.3l2.1,2.1c0.5,0.5,1.3,0.6,1.9,0.2c1.2-0.8,2.5-1.5,3.9-2.1c0.6-0.2,1.3-0.4,2-0.6c6.3-1.2,12.3,1.3,15.7,5.4c1.2,1.4,0.3,2.3-0.7,2.3h-7c-0.8,0-1.6,0.7-1.6,1.5v3c0,0.8,0.8,1.5,1.6,1.5h18.2c0.7,0,1.2-0.6,1.2-1.3V3.5C50,2.7,49.3,2,48.5,2z x M39.4,37.4c-0.6-0.6-1.5-0.6-2.1,0c-1.6,1.6-3.6,2.9-5.8,3.7c-0.6,0.2-1.3,0.4-2,0.6c-6.3,1.2-12.3-1.3-15.7-5.4c-1.2-1.4-0.3-2.3,0.7-2.3h7c0.8,0,1.5-0.7,1.5-1.5v-3c0-0.8-0.7-1.5-1.5-1.5H3.3C2.6,28,2,28.6,2,29.3v19.2C2,49.3,2.7,50,3.5,50h3C7.3,50,8,49.3,8,48.5v-7c0-0.9,1-1.5,1.6-0.8l0,0c4.6,5.2,11.4,7.9,18.7,7.2c2.6-0.2,5.1-1,7.4-2.2c2.2-1.1,4.1-2.5,5.7-4.1c0.6-0.6,0.6-1.6,0-2.1L39.4,37.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Routing Offline',
                'M43,9C33.6-0.3,18.4-0.3,9,9s-9.3,24.6,0,34s24.6,9.3,34,0S52.3,18.4,43,9z M26,44c-9.9,0-18-8.1-18-18S16.1,8,26,8S44,16,44,26S36,44,26,44z'
            }
        );
        svgs.add(
            new List<String>{
                'Rules',
                'M50.1,25.4L42,17.3c-0.4-0.4-1.1-0.4-1.5,0L39,18.8c-0.4,0.4-0.4,1.1,0,1.5l2.5,2.5c0.4,0.4,0.1,1.2-0.5,1.2H18.9l13.2-13.1c0.4-0.4,1.2-0.1,1.2,0.5v3.6c0,0.6,0.4,1,1,1l2.1,0c0.6,0,1-0.4,1-1V3.4c0-0.6-0.4-1-1-1H25c-0.5,0-1,0.5-1,1.1l0,2c0,0.6,0.4,1,1,1h3.6c0.6,0,0.9,0.7,0.5,1.2L12.9,23.9H3C2.4,23.9,2,24.4,2,25v2.1c0,0.6,0.6,1.1,1.1,1.1h10l16.1,16.1c0.4,0.4,0.1,1.2-0.5,1.2h-3.6c-0.6,0-1,0.4-1,1l0,2c0,0.5,0.4,1,1,1.1h11.4c0.6,0,1-0.4,1-1V37.1c0-0.6-0.4-1-1-1l-2.1,0c-0.6,0-1,0.4-1,1v3.6c0,0.6-0.7,0.9-1.2,0.5L19,28.2h22.1c0.6,0,0.9,0.8,0.5,1.2L39,31.9c-0.4,0.4-0.4,1.1,0,1.5l1.5,1.5c0.4,0.4,1.1,0.4,1.5,0l8.1-8C50.5,26.4,50.5,25.8,50.1,25.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Salesforce Page',
                'm44.44 19h-11.24a3.89 3.89 0 0 1 -4.2-3.55 3.53 3.53 0 0 1 0-.65v-11.2a1.58 1.58 0 0 0 -1.56-1.6h-16.64a4.87 4.87 0 0 0 -4.8 4.8v38.4a4.87 4.87 0 0 0 4.8 4.8h30.4a4.87 4.87 0 0 0 4.8-4.8v-24.6a1.58 1.58 0 0 0 -1.56-1.6zm-10.85 20.35a3.92 3.92 0 0 1 -1.08-.1 4.19 4.19 0 0 1 -3.68 2.16 5.24 5.24 0 0 1 -1.83-.41 4.88 4.88 0 0 1 -4.43 2.91 4.72 4.72 0 0 1 -4.57-3.13c-.22 0-.65.11-1 .11a4.49 4.49 0 0 1 -4.54-4.42 4.39 4.39 0 0 1 2.27-3.89 6.33 6.33 0 0 1 -.44-2.06 5.26 5.26 0 0 1 5.19-5.18 5.92 5.92 0 0 1 4.06 2.14 4.79 4.79 0 0 1 3.46-1.42 4.91 4.91 0 0 1 4.21 2.38 7.49 7.49 0 0 1 2.38-.54 5.93 5.93 0 0 1 5.83 5.73 5.85 5.85 0 0 1 -5.83 5.72z x m36.4 15h8.5a1.2 1.2 0 0 0 1.1-1.2 1.4 1.4 0 0 0 -.3-.9l-10.6-10.6a1.4 1.4 0 0 0 -.9-.3 1.2 1.2 0 0 0 -1.2 1.1v8.5a3.49 3.49 0 0 0 3.4 3.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Salesforce1',
                'M21.7,11.9c1.7-1.7,4-2.8,6.6-2.8c3.4,0,6.4,1.9,8,4.7c1.4-0.6,2.9-1,4.5-1C47,12.8,52,17.8,52,24s-5,11.2-11.2,11.2c-0.8,0-1.5-0.1-2.2-0.2c-1.4,2.5-4.1,4.2-7.2,4.2c-1.3,0-2.5-0.3-3.6-0.8c-1.4,3.3-4.7,5.6-8.6,5.6c-4,0-7.5-2.5-8.8-6.1c-0.6,0.1-1.2,0.2-1.8,0.2c-4.8,0-8.7-3.9-8.7-8.7c0-3.2,1.7-6,4.3-7.5c-0.5-1.2-0.8-2.6-0.8-4c0-5.5,4.5-10,10.1-10C17,8,19.9,9.5,21.7,11.9z'
            }
        );
        svgs.add(
            new List<String>{
                'Save',
                'M37.1,4v13.6c0,1-0.8,1.9-1.9,1.9H13.9c-1,0-1.9-0.8-1.9-1.9V4H8C5.8,4,4,5.8,4,8v36c0,2.2,1.8,4,4,4h36c2.2,0,4-1.8,4-4V11.2L40.8,4H37.1z M44.1,42.1c0,1-0.8,1.9-1.9,1.9H9.9c-1,0-1.9-0.8-1.9-1.9V25.4c0-1,0.8-1.9,1.9-1.9h32.3c1,0,1.9,0.8,1.9,1.9V42.1z x M24.8,13.6c0,1,0.8,1.9,1.9,1.9h4.6c1,0,1.9-0.8,1.9-1.9V4h-8.3L24.8,13.6L24.8,13.6z'
            }
        );
        svgs.add(
            new List<String>{
                'Scan',
                'M48.5,32A1.61,1.61,0,0,1,50,33.5v8.85Q50,47,45.5,47h-9a1.55,1.55,0,0,1,0-3.1h8.25c1.66,0,2.25-.61,2.25-2.32V33.5A1.61,1.61,0,0,1,48.5,32Zm-45,0A1.61,1.61,0,0,1,5,33.5H5v8.08c0,1.71.59,2.32,2.25,2.32H15.5a1.55,1.55,0,0,1,0,3.1h-9Q2,47,2,42.35H2V33.5A1.61,1.61,0,0,1,3.5,32ZM20.17,14c.73,0,1.33.45,1.33,1h0V37c0,.55-.6,1-1.33,1H16.83c-.73,0-1.33-.45-1.33-1h0V15c0-.55.6-1,1.33-1h3.34ZM11.5,14a1,1,0,0,1,1,1h0V37a1,1,0,0,1-1,1h-1a1,1,0,0,1-1-1h0V15a1,1,0,0,1,1-1h1Zm15,0a1,1,0,0,1,1,1h0V37a1,1,0,0,1-1,1h-1a1,1,0,0,1-1-1h0V15a1,1,0,0,1,1-1h1Zm15,0a1,1,0,0,1,1,1h0V37a1,1,0,0,1-1,1h-1a1,1,0,0,1-1-1h0V15a1,1,0,0,1,1-1h1Zm-6.33,0c.73,0,1.33.45,1.33,1h0V37c0,.55-.6,1-1.33,1H31.83c-.73,0-1.33-.45-1.33-1h0V15c0-.55.6-1,1.33-1h3.34ZM45.5,5Q50,5,50,9.65h0V18.5a1.5,1.5,0,0,1-3,0h0V10.42c0-1.71-.59-2.32-2.25-2.32H36.5a1.55,1.55,0,0,1,0-3.1h9Zm-30,0a1.55,1.55,0,0,1,0,3.1H7.25C5.59,8.1,5,8.71,5,10.42V18.5A1.61,1.61,0,0,1,3.5,20,1.61,1.61,0,0,1,2,18.5V9.65Q2,5,6.5,5Z'
            }
        );
        svgs.add(
            new List<String>{
                'Screen',
                'M50,6c0-2.2-1.8-4-4-4H6C3.8,2,2,3.8,2,6v27.7c0,2.2,1.8,4,4,4h40c2.2,0,4-1.8,4-4V6z M44,30.2c0,0.8-0.7,1.5-1.5,1.5h-33C8.7,31.7,8,31,8,30.2V9.5C8,8.7,8.7,8,9.5,8h33C43.3,8,44,8.7,44,9.5V30.2z M19,44c-2.2,0-4,1.8-4,4v0.5c0,0.8,0.7,1.5,1.5,1.5h19c0.8,0,1.5-0.7,1.5-1.5V48c0-2.2-1.8-4-4-4H19z x M18,26.7h-4.1c-0.6,0-1-0.5-1-1V14c0-0.6,0.4-1,1-1H18c0.5,0,1,0.4,1,1v11.7C19,26.3,18.5,26.7,18,26.7z x M38.1,26.7H24.8c-0.6,0-1-0.4-1-1V14c0-0.6,0.4-1,1-1h13.3c0.5,0,1,0.4,1,1v11.7C39.1,26.3,38.6,26.7,38.1,26.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Search',
                'M49.62,45.27,36.22,32a18.9,18.9,0,1,0-34.1-9.2A18.91,18.91,0,0,0,32,36.27l13.3,13.3a1.45,1.45,0,0,0,2.1,0l2.1-2.1A1.68,1.68,0,0,0,49.62,45.27Zm-28.7-11.5a12.9,12.9,0,1,1,12.9-12.9A12.87,12.87,0,0,1,20.92,33.77Z'
            }
        );
        svgs.add(
            new List<String>{
                'Section',
                'M47.6,29.2h-8c-1.3,0-2.4-1.1-2.4-2.4v-1.6c0-1.3,1.1-2.4,2.4-2.4h8c1.3,0,2.4,1.1,2.4,2.4v1.6C50,28.1,48.9,29.2,47.6,29.2 x M30,29.2h-8c-1.3,0-2.4-1.1-2.4-2.4v-1.6c0-1.3,1.1-2.4,2.4-2.4h8c1.3,0,2.4,1.1,2.4,2.4v1.6C32.4,28.1,31.3,29.2,30,29.2 x M12.4,29.2h-8C3,29.2,2,28.1,2,26.8v-1.6c0-1.3,1.1-2.4,2.4-2.4h8c1.3,0,2.4,1.1,2.4,2.4v1.6C14.8,28.1,13.7,29.2,12.4,29.2 x M43.6,34H8.4c-1.8,0-3.2,1.4-3.2,3.2v8c0,1.8,1.4,3.2,3.2,3.2h35.2c1.8,0,3.2-1.4,3.2-3.2v-8C46.8,35.4,45.3,34,43.6,34z M42,42.8c0,0.4-0.4,0.8-0.8,0.8H10.8c-0.4,0-0.8-0.4-0.8-0.8v-3.2c0-0.4,0.4-0.8,0.8-0.8h30.4c0.4,0,0.8,0.4,0.8,0.8V42.8z x M43.6,3.6H8.4C6.6,3.6,5.2,5,5.2,6.8v8c0,1.8,1.4,3.2,3.2,3.2h35.2c1.8,0,3.2-1.4,3.2-3.2v-8C46.8,5,45.3,3.6,43.6,3.6z M42,12.4c0,0.4-0.4,0.8-0.8,0.8H10.8c-0.4,0-0.8-0.4-0.8-0.8V9.2c0-0.4,0.4-0.8,0.8-0.8h30.4c0.4,0,0.8,0.4,0.8,0.8V12.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Send',
                'M2.1,44.5l4.4-16.3h18.6c0.5,0,1-0.5,1-1v-2c0-0.5-0.5-1-1-1H6.5l-4.3-16l0,0C2.1,8,2,7.7,2,7.4C2,6.7,2.7,6,3.5,6.1c0.2,0,0.3,0.1,0.5,0.1l0,0l0,0l0,0l45,18.5c0.6,0.2,1,0.8,1,1.4s-0.4,1.1-0.9,1.3l0,0L4,46.4l0,0c-0.2,0.1-0.4,0.1-0.6,0.1C2.6,46.4,2,45.8,2,45C2,44.8,2,44.7,2.1,44.5L2.1,44.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Sentiment Negative',
                'M26,2C12.8,2,2,12.8,2,26.1c0,13.3,10.8,24.1,24,24.1s24-10.8,24-24.1C50,12.8,39.2,2,26,2z M17,15c1.7,0,3,1.8,3,4c0,2.2-1.3,4-3,4c-1.7,0-3-1.8-3-4C14,16.8,15.3,15,17,15z M14,38.7c0.5-6.1,5-11.2,12.1-11.2c7,0,11.4,5.1,11.9,11.2H14z M35,23c-1.7,0-3-1.8-3-4c0-2.2,1.3-4,3-4c1.7,0,3,1.8,3,4C38,21.2,36.7,23,35,23z'
            }
        );
        svgs.add(
            new List<String>{
                'Sentiment Neutral',
                'M26,2C12.8,2,2,12.8,2,26.1s10.8,24.1,24,24.1s24-10.8,24-24.1S39.2,2,26,2z M17,15c1.7,0,3,1.8,3,4s-1.3,4-3,4s-3-1.8-3-4S15.3,15,17,15z M38,34.1c0,1.1-0.9,1.9-1.9,1.9H15.9c-1.1,0-1.9-0.9-1.9-1.9V34c0-1.1,0.9-1.9,1.9-1.9h20.1C37.1,32.1,38,33,38,34.1L38,34.1z M35,23c-1.7,0-3-1.8-3-4s1.3-4,3-4s3,1.8,3,4S36.7,23,35,23z'
            }
        );
        svgs.add(
            new List<String>{
                'Service Territory',
                'M17.05,2H8A6.08,6.08,0,0,0,2,8.09v5.68a6,6,0,0,0,6,6.09h9.05a6,6,0,0,0,6-6.09V8.09A6,6,0,0,0,17.05,2ZM13.79,15H11.3a4.06,4.06,0,0,1,0-8.12h2.49a4.06,4.06,0,1,1,0,8.12Z x M34.42,19.86h9a6,6,0,0,0,6-6.09V8.09a6,6,0,0,0-6-6.09h-9a6,6,0,0,0-6,6.09v5.68A6,6,0,0,0,34.42,19.86Zm3.25-13h2.49a4.06,4.06,0,1,1,0,8.12H37.67a4.06,4.06,0,0,1,0-8.12Z x M17.05,24.73H8a6.08,6.08,0,0,0-6,6.09v5.69a6.06,6.06,0,0,0,6,6.08h9.05a6.06,6.06,0,0,0,6-6.08V30.82A6,6,0,0,0,17.05,24.73Zm-3.26,13H11.3a4.06,4.06,0,0,1,0-8.12h2.49a4.06,4.06,0,1,1,0,8.12Z x M39.18,24.73c-6,0-10.81,4.47-10.81,10.05,0,6.94,7.74,13.3,10.13,15a1.17,1.17,0,0,0,1.42,0C42.31,48,50,41.72,50,34.78,50,29.2,45.16,24.73,39.18,24.73Zm0,14.2a4.4,4.4,0,0,1-4.55-4.21,4.57,4.57,0,0,1,9.11,0A4.4,4.4,0,0,1,39.18,38.93Z'
            }
        );
        svgs.add(
            new List<String>{
                'Settings',
                'M26.1,19.1c-3.9,0-7,3.1-7,7s3.1,7,7,7s7-3.1,7-7S30,19.1,26.1,19.1z x M47.1,32.4l-3.7-3.1c0.2-1.1,0.3-2.3,0.3-3.4c0-1.1-0.1-2.3-0.3-3.4l3.7-3.1c1.2-1,1.6-2.8,0.8-4.2l-1.6-2.8c-0.6-1-1.7-1.6-2.9-1.6c-0.4,0-0.8,0.1-1.1,0.2l-4.6,1.7c-1.8-1.6-3.8-2.7-5.9-3.4L31,4.6c-0.3-1.6-1.7-2.5-3.3-2.5h-3.2c-1.6,0-3,0.9-3.3,2.5l-0.8,4.6c-2.2,0.7-4.2,1.9-6,3.4l-4.6-1.7c-0.4-0.1-0.7-0.2-1.1-0.2c-1.2,0-2.3,0.6-2.9,1.6l-1.6,2.8c-0.8,1.4-0.5,3.2,0.8,4.2l3.7,3.1c-0.2,1.1-0.3,2.3-0.3,3.4c0,1.2,0.1,2.3,0.3,3.4L5,32.3c-1.2,1-1.6,2.8-0.8,4.2l1.6,2.8c0.6,1,1.7,1.6,2.9,1.6c0.4,0,0.8-0.1,1.1-0.2l4.6-1.7c1.8,1.6,3.8,2.7,5.9,3.4l0.8,4.8c0.3,1.6,1.6,2.7,3.3,2.7h3.2c1.6,0,3-1.2,3.3-2.8l0.8-4.8c2.3-0.8,4.4-2,6.2-3.7l4.3,1.7c0.4,0.1,0.8,0.2,1.2,0.2c1.2,0,2.3-0.6,2.9-1.6l1.5-2.6C48.7,35.2,48.3,33.4,47.1,32.4z M26.1,37.1c-6.1,0-11-4.9-11-11s4.9-11,11-11s11,4.9,11,11S32.2,37.1,26.1,37.1z'
            }
        );
        svgs.add(
            new List<String>{
                'Setup',
                'M46.8,32.4l-3.7-3.1c0.2-1.1,0.3-2.3,0.3-3.4s-0.1-2.3-0.3-3.4l3.7-3.1c1.2-1,1.6-2.8,0.8-4.2L46,12.3c-0.6-1-1.7-1.6-2.9-1.6c-0.4,0-0.8,0.1-1.1,0.2l-4.5,1.7c-1.8-1.6-3.8-2.7-5.8-3.4l-0.8-4.7C30.6,2.9,29.2,2,27.6,2h-3.2c-1.6,0-3,0.9-3.3,2.5l-0.8,4.6c-2.2,0.7-4.1,1.9-5.9,3.4L10,10.8c-0.4-0.1-0.7-0.2-1.1-0.2c-1.2,0-2.3,0.6-2.9,1.6l-1.6,2.8c-0.8,1.4-0.5,3.2,0.8,4.2l3.7,3.1c-0.2,1.1-0.3,2.3-0.3,3.4c0,1.2,0.1,2.3,0.3,3.4l-3.7,3.1c-1.2,1-1.6,2.8-0.8,4.2L6,39.4c0.6,1,1.7,1.6,2.9,1.6c0.4,0,0.8-0.1,1.1-0.2l4.5-1.7c1.8,1.6,3.8,2.7,5.8,3.4l0.8,4.8c0.3,1.6,1.6,2.7,3.3,2.7h3.2c1.6,0,3-1.2,3.3-2.8l0.8-4.8c2.3-0.8,4.3-2,6.1-3.7l4.2,1.7c0.4,0.1,0.8,0.2,1.2,0.2c1.2,0,2.3-0.6,2.9-1.6l1.5-2.6C48.4,35.2,48,33.4,46.8,32.4z M26.1,37.1c-6,0-10.9-4.9-10.9-11s4.8-11,10.9-11s10.9,4.9,10.9,11S32.1,37.1,26.1,37.1z x M29,18h-4.6c-0.7,0-1.3,0.4-1.5,1l-2.8,7.2c-0.2,0.5,0.2,1.1,0.8,1.1h4.7l-1.7,6c-0.2,0.6,0.5,0.9,0.9,0.5l7.1-8.3c0.5-0.5,0.1-1.3-0.6-1.3h-3.5l3.1-4.9c0.3-0.5-0.1-1.2-0.7-1.2H29z'
            }
        );
        svgs.add(
            new List<String>{
                'Setup Assistant Guide',
                'M11.5,24.9c0-0.4-0.5-0.6-0.8-0.4l-4.5,3.7C6,28.4,6,28.7,6,29v15.9c0,1,1.4,1.5,2.3,0.8l7.3-5.7c0.2-0.2,0.3-0.4,0.1-0.7C13.9,36.6,12.1,32.1,11.5,24.9z x M21.2,39.8c0.2,0.1,0.4,0.2,0.6,0.2h8.3c0.2,0,0.4-0.1,0.6-0.2c1.2-0.8,6-4.8,6-18.4c0-6.3-1.8-10.7-3.9-13.7C29.7,3.3,26,2,26,2s-3.8,1.3-6.9,5.8c-2.1,3-3.8,7.3-3.8,13.6C15.3,35,20,39,21.2,39.8z M25.9,13c3.3,0,6,2.7,6,6s-2.7,6-6,6s-6-2.7-6-6S22.6,13,25.9,13z x M45.7,28.2l-4.4-3.7c-0.3-0.3-0.8-0.1-0.8,0.4c-0.6,7.2-2.4,11.7-4.1,14.5c-0.1,0.2-0.1,0.5,0.1,0.7l7.3,5.7C44.7,46.5,46,46,46,45V29C46,28.7,46,28.4,45.7,28.2z x M32.2,44.5C32,44.2,31.7,44,31.4,44h-5.5h-5.5c-0.3,0-0.7,0.2-0.8,0.5c-0.4,0.6-1,1.7-1.4,3.1c-0.3,1.2,0.7,2.4,2,2.4h5.7h5.7c1.3,0,2.3-1.2,2-2.4C33.2,46.1,32.6,45,32.2,44.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Shield',
                'M4.8,14h42.4c1,0,1.8-1,1.5-2c-1-3.3-2.4-6.3-4.3-9c-0.6-0.8-1.7-0.9-2.3-0.2c-1.9,1.8-4.6,2.8-7.4,2.8c-3,0-5.7-1.2-7.7-3.2c-0.6-0.6-1.6-0.6-2.2,0c-2,2-4.7,3.2-7.7,3.2c-2.8,0-5.4-1-7.4-2.8C9,2.2,7.9,2.3,7.4,3C5.5,5.6,4,8.7,3.1,12C3,13,3.8,14,4.8,14z x M50,20.4c0-0.9-0.7-1.4-1.6-1.4H3.6C2.7,19,2,19.5,2,20.4c0,0.1,0,0.2,0,0.3c0,15,10.4,27.4,24,29.3c13.6-1.9,24-14.3,24-29.2C50,20.6,50,20.5,50,20.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Shopping Bag',
                'M44,19.6a4,4,0,0,0-4-4h-.7a13.24,13.24,0,0,0-26.4,0H12a4,4,0,0,0-4,4l-2,25a4,4,0,0,0,4,4H42a4,4,0,0,0,4-4ZM26.1,9.4a7.24,7.24,0,0,1,7.2,6.2H18.9A7.39,7.39,0,0,1,26.1,9.4Zm5.7,18.2H20.2a3,3,0,0,1-3-3,3.08,3.08,0,0,1,3-3H31.9a3,3,0,0,1,3,3A3.1,3.1,0,0,1,31.8,27.6Z'
            }
        );
        svgs.add(
            new List<String>{
                'Slider',
                'M43,23.1h5c1.1,0,2,0.9,2,2v2c0,1.1-0.9,2-2,2h-5c-0.6,0-0.9-0.5-0.8-1c0,0,0.3-1,0.3-2S42.2,24,42.2,24C42.1,23.4,42.5,23,43,23.1z x M10.8,41H4c-1.1,0-2,0.9-2,2v2c0,1.1,0.9,2,2,2h6.8c1,1.8,3,3,5.2,3c3.3,0,6-2.7,6-6s-2.7-6-6-6C13.8,38,11.8,39.2,10.8,41z x M26.2,42c0,0,0.3,1.1,0.3,2.1s-0.3,2-0.3,2c-0.1,0.5,0.2,1,0.8,1h21c1.1,0,2-0.9,2-2v-2c0-1.1-0.9-2-2-2H27C26.4,41,26.1,41.4,26.2,42z x M30.2,6c0,0,0.3,1.1,0.3,2.1s-0.3,2-0.3,2c-0.1,0.5,0.2,1,0.8,1h17c1.1,0,2-0.9,2-2v-2c0-1.1-0.9-2-2-2H31C30.5,5,30.1,5.4,30.2,6z x M14.8,5H4C2.9,5,2,5.9,2,7v2c0,1.1,0.9,2,2,2h10.8c1,1.8,3,3,5.2,3c3.3,0,6-2.7,6-6s-2.7-6-6-6C17.8,2,15.8,3.2,14.8,5z x M26.8,23H4c-1.1,0-2,0.9-2,2v2c0,1.1,0.9,2,2,2h22.8c1,1.8,3,3,5.2,3c3.3,0,6-2.7,6-6s-2.7-6-6-6C29.8,20,27.8,21.2,26.8,23z'
            }
        );
        svgs.add(
            new List<String>{
                'Smiley and People',
                'M50,26.1 C50,39.4 39.2448133,50.2 26,50.2 C12.7551867,50.2 2,39.4 2,26.1 C2,12.8 12.7551867,2 26,2 C39.2448133,2 50,12.8 50,26.1 Z M17,15 C15.3255814,15 14,16.7674419 14,19 C14,21.2325581 15.3255814,23 17,23 C18.6744186,23 20,21.2325581 20,19 C20,16.7674419 18.6744186,15 17,15 Z M35,15 C33.3255814,15 32,16.7674419 32,19 C32,21.2325581 33.3255814,23 35,23 C36.6744186,23 38,21.2325581 38,19 C38,16.7674419 36.6744186,15 35,15 Z M11,29 C11.6320591,36.6439458 17.1578483,43 25.9212267,43 C34.684605,43 40.3679409,36.6439458 41,29 C38.1939694,29 33.1939694,29 26,29 C18.8060306,29 13.8060306,29 11,29 Z'
            }
        );
        svgs.add(
            new List<String>{
                'Sms',
                'M26,4C12.7,4,2.1,13.8,2.1,25.9c0,3.8,1.1,7.4,2.9,10.6c0.3,0.5,0.4,1.1,0.2,1.7l-3.1,8.5c-0.3,0.8,0.5,1.5,1.3,1.3l8.6-3.3c0.5-0.2,1.1-0.1,1.7,0.2c3.6,2,7.9,3.2,12.5,3.2C39.3,48,50,38.2,50,26.1C49.9,13.8,39.2,4,26,4z M16.4,29.6c-0.3,0.5-0.6,1-1,1.3s-0.9,0.6-1.5,0.8c-0.5,0.2-1.1,0.2-1.7,0.2c-0.8,0-1.5-0.1-2.2-0.4c-0.7-0.3-1.4-0.7-1.9-1.3L7.9,30c-0.1-0.1,0-0.3,0.2-0.5L9.7,28c0.2-0.2,0.4-0.2,0.5-0.1s0.2,0.3,0.2,0.3c0.2,0.3,0.5,0.5,0.8,0.7c0.5,0.3,1,0.3,1.6,0.2c0.2,0,0.3-0.1,0.5-0.2c0.1-0.1,0.2-0.2,0.3-0.3c0.1-0.1,0.1-0.3,0.1-0.4c0-0.4-0.1-0.5-0.2-0.6c-0.2-0.2-0.5-0.4-0.9-0.5s-0.8-0.3-1.3-0.4c-0.5-0.2-1-0.4-1.4-0.6c-0.5-0.3-0.8-0.7-1.1-1.1c-0.3-0.5-0.5-1.1-0.5-1.9c0-0.7,0.1-1.3,0.4-1.8c0.3-0.5,0.6-0.9,1.1-1.2c0.4-0.3,0.9-0.6,1.5-0.7c1.2-0.3,2.4-0.3,3.6,0.1c0.6,0.2,1.2,0.6,1.5,0.8l0.3,0.2c0.2,0.1,0.1,0.4-0.1,0.6l-1.5,1.5c-0.2,0.2-0.5,0.2-0.7,0c-0.2-0.1-0.3-0.3-0.4-0.3c-0.5-0.3-1.2-0.4-1.8-0.3c-0.2,0-0.3,0.1-0.4,0.2c-0.1,0.1-0.2,0.2-0.3,0.3c-0.1,0.1-0.1,0.2-0.1,0.4c0,0.3,0.1,0.4,0.2,0.5c0.2,0.2,0.5,0.3,0.9,0.5c0.4,0.1,0.8,0.3,1.3,0.4c0.5,0.2,1,0.4,1.4,0.6c0.5,0.3,0.8,0.7,1.1,1.1c0.3,0.5,0.5,1.1,0.5,1.9C16.8,28.5,16.7,29.1,16.4,29.6z M33,31c0,0.6-0.5,1-1.1,1h-1c-0.6,0-0.9-0.4-0.9-1v-5.9c0-0.6-0.8-0.7-1-0.2l-1.7,4.5c-0.1,0.4-0.5,0.6-0.9,0.6h-0.7c-0.4,0-0.8-0.3-0.9-0.6L23,24.9c-0.2-0.5-1-0.4-1,0.2V31c0,0.6-0.5,1-1.1,1h-1c-0.6,0-0.9-0.4-0.9-1V20c0-0.6,0.4-1,0.9-1h2.6c0.4,0,0.8,0.3,0.9,0.6l2,5.2c0.2,0.4,0.8,0.4,0.9,0l2-5.2c0.1-0.4,0.5-0.6,0.9-0.6h2.7c0.6,0,1.1,0.4,1.1,1V31z M43.5,29.7c-0.3,0.5-0.6,1-1.1,1.3c-0.4,0.3-0.9,0.6-1.5,0.8S39.8,32,39.2,32c-0.8,0-1.5-0.1-2.2-0.4c-0.7-0.3-1.4-0.7-1.9-1.3l-0.2-0.2c-0.1-0.1,0-0.3,0.2-0.5l1.6-1.5c0.2-0.2,0.4-0.2,0.5-0.1s0.2,0.3,0.2,0.3c0.2,0.3,0.5,0.5,0.8,0.7c0.5,0.3,1.1,0.3,1.6,0.2c0.2-0.1,0.4-0.1,0.5-0.2c0.1-0.1,0.2-0.2,0.3-0.3s0.1-0.3,0.1-0.4c0-0.4-0.1-0.5-0.2-0.6c-0.2-0.2-0.5-0.4-0.9-0.5s-0.8-0.3-1.3-0.4c-0.5-0.2-1-0.4-1.4-0.6c-0.5-0.3-0.9-0.7-1.2-1.1c-0.3-0.5-0.5-1.1-0.5-1.9c0-0.7,0.1-1.3,0.4-1.8c0.3-0.5,0.6-0.9,1.1-1.2c0.4-0.3,1-0.6,1.5-0.7c1.2-0.3,2.4-0.3,3.6,0.1c0.6,0.2,1.2,0.6,1.5,0.9l0.3,0.3c0.2,0.1,0.1,0.4-0.1,0.6L42,22.9c-0.2,0.2-0.5,0.2-0.7,0c-0.2-0.1-0.3-0.3-0.4-0.3c-0.5-0.3-1.2-0.4-1.8-0.3c-0.2,0-0.3,0.1-0.4,0.2c-0.1,0.1-0.2,0.2-0.3,0.3c-0.1,0.1-0.1,0.3-0.1,0.4c0,0.3,0.1,0.4,0.2,0.5c0.2,0.2,0.5,0.3,0.9,0.5c0.4,0.1,0.8,0.3,1.3,0.4c0.5,0.2,1,0.4,1.4,0.6c0.5,0.3,0.8,0.7,1.2,1.1c0.3,0.5,0.5,1.1,0.5,1.9C43.9,28.5,43.8,29.2,43.5,29.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Social Share',
                'M40.9,32c-2.6,0-4.9,1.1-6.5,2.8l-14.6-7.3c0.1-0.5,0.1-1,0.1-1.6c0-0.5-0.1-1.1-0.1-1.6l14.6-7.3c1.6,1.8,4,2.9,6.6,2.9c5,0,9-4,9-9s-4-9-9-9s-9,4-9,9c0,0.2,0,0.4,0,0.6l-15.1,7.6c-1.7-1.3-3.7-2.1-6-2.1c-5,0-9,4-9,9s4,9,9,9c2.3,0,4.3-0.8,5.9-2.2l15.1,7.5c0,0.2,0,0.4,0,0.7c0,5,4,9,9,9s9-4,9-9S45.9,32,40.9,32z'
            }
        );
        svgs.add(
            new List<String>{
                'Spinner',
                'M16,27.5v-3c0-0.8-0.7-1.5-1.5-1.5h-11C2.7,23,2,23.7,2,24.5v3C2,28.3,2.7,29,3.5,29h11C15.3,29,16,28.3,16,27.5z x M17.9,32c-0.6-0.6-1.5-0.6-2.1,0L8,39.8c-0.6,0.6-0.6,1.5,0,2.1l2.1,2.1c0.6,0.6,1.5,0.6,2.1,0l7.8-7.8c0.6-0.6,0.6-1.5,0-2.1L17.9,32z x M34.1,20c0.6,0.6,1.5,0.6,2.1,0l7.8-7.8c0.6-0.6,0.6-1.5,0-2.1L41.9,8c-0.6-0.6-1.5-0.6-2.1,0L32,15.7c-0.6,0.6-0.6,1.5,0,2.1L34.1,20z x M12.2,8c-0.6-0.6-1.5-0.6-2.1,0L8,10.1c-0.6,0.6-0.6,1.5,0,2.1l7.8,7.8c0.6,0.6,1.5,0.6,2.1,0l2.1-2.1c0.6-0.6,0.6-1.5,0-2.1L12.2,8z x M36.3,32c-0.6-0.6-1.5-0.6-2.1,0L32,34.1c-0.6,0.6-0.6,1.5,0,2.1l7.8,7.8c0.6,0.6,1.5,0.6,2.1,0l2.1-2.1c0.6-0.6,0.6-1.5,0-2.1L36.3,32z x M27.5,36h-3c-0.8,0-1.5,0.7-1.5,1.5v11c0,0.8,0.7,1.5,1.5,1.5h3c0.8,0,1.5-0.7,1.5-1.5v-11C29,36.7,28.3,36,27.5,36z x M48.5,23h-11c-0.8,0-1.5,0.7-1.5,1.5v3c0,0.8,0.7,1.5,1.5,1.5h11c0.8,0,1.5-0.7,1.5-1.5v-3C50,23.7,49.3,23,48.5,23z x M27.5,2h-3C23.7,2,23,2.7,23,3.5v11c0,0.8,0.7,1.5,1.5,1.5h3c0.8,0,1.5-0.7,1.5-1.5v-11C29,2.7,28.3,2,27.5,2z'
            }
        );
        svgs.add(
            new List<String>{
                'Standard Objects',
                'M46.2,38.9L27.4,49.6c-1,0.6-2.3,0.6-3.3,0L5.4,38.9c-0.8-0.4-0.8-1.4,0-1.8l4.4-2.5c0.3-0.2,0.7-0.2,1,0l11.4,6.5c1.1,0.6,2.3,0.9,3.6,0.9s2.5-0.3,3.6-0.9l11.4-6.5c0.3-0.2,0.7-0.2,1,0l4.4,2.5C47,37.5,47,38.5,46.2,38.9z x M46.2,26.9L27.4,37.6c-1,0.6-2.3,0.6-3.3,0L5.4,26.9c-0.8-0.4-0.8-1.4,0-1.8l4.4-2.5c0.3-0.2,0.7-0.2,1,0l11.4,6.5c1.1,0.6,2.3,0.9,3.6,0.9s2.5-0.3,3.6-0.9l11.4-6.5c0.3-0.2,0.7-0.2,1,0l4.4,2.5C47,25.5,47,26.5,46.2,26.9z x M24.3,25.6L5.5,14.9c-0.8-0.4-0.8-1.4,0-1.8L24.3,2.4c1-0.6,2.3-0.6,3.3,0l18.8,10.7c0.8,0.4,0.8,1.4,0,1.8L27.6,25.6C26.6,26.1,25.3,26.1,24.3,25.6z'
            }
        );
        svgs.add(
            new List<String>{
                'Steps',
                'M44.4,50.2h-7v-4.8h7v2.5V50.2L44.4,50.2z M44.4,47.9L44.4,47.9L44.4,47.9L44.4,47.9z M30.3,50.2h-7v-4.8h7V50.2z M16.3,50.2h-7v-4.8h7V50.2z M6.9,44.3H2.1v-7h4.8V44.3z M49.9,42.6h-4.8v-7h4.8V42.6z M6.9,30.3H2.1v-7h4.8V30.3z M49.9,28.6h-4.8v-7h4.8V28.6z M6.9,16.3H2.1v-7h4.8V16.3z M49.9,14.7h-4.8v-7h4.8V14.7z M42.6,6.6h-7V1.8h7V6.6z M28.6,6.6h-7V1.8h7V6.6z M14.7,6.6H7.7V1.8h7L14.7,6.6L14.7,6.6z'
            }
        );
        svgs.add(new List<String>{ 'Stop', 'M8,8h36v36H8V8z' });
        svgs.add(
            new List<String>{
                'Store',
                'M43.1,29.5c-0.1,0-0.2,0-0.2,0c-1.6-0.2-2.9-0.6-4.1-1.5c-0.1-0.1-0.1-0.1-0.2-0.1c-0.6-0.5-1.1-0.2-1.4-0.1l-0.1,0.1c-1.5,1.1-3.2,1.7-5.2,1.7c-2.1,0-3.8-0.6-5.4-1.8c-0.6-0.4-1,0-1,0c-1.6,1.3-3.4,1.9-5.5,1.9c-2,0-3.8-0.6-5.3-1.8c-0.1-0.1-0.2-0.1-0.2-0.2c-0.5-0.4-1,0-1,0c-1.5,1.2-3.2,1.8-5.1,1.9c0,0-0.6,0-0.6,0.7v12c0,1,0,2.1,0,2.9c0,0.3,0.2,1,1.1,1.2h18.5c1-0.2,1.1-0.9,1.1-1.2c0-0.8,0-1.8,0-2.9c0-2.6,0-5.1,0-7.7c0.1-0.3,0.2-0.6,1-0.6c2.8,0,5.6,0,8.4,0c0.2,0,0.3,0,0.5,0c0.3,0.1,0.6,0.3,0.6,1c0,2.5,0,4.9,0,7.3c0,1,0,1.9,0,2.7c0,1.1,0.8,1.3,1,1.3h2.8c0.2,0,1-0.2,1-1.3c0-0.8,0-1.7,0-2.7V30.6C43.9,29.8,43.5,29.6,43.1,29.5z M23.2,41c0,0.1,0,0.2,0,0.3c0,0.4-0.2,1-1.2,1c-2.7,0-5.4,0-8.1,0c-0.9,0-1.1-0.4-1.2-0.8c0-0.1,0-0.2,0-0.4c0-1.8,0-3.8,0-5.7c0-1.4,0.8-1.5,1.1-1.5c2.8,0,5.7,0,8.5,0c0.3,0,1,0.2,1,1.3C23.2,37.2,23.2,39.1,23.2,41z x M42.3,25.5c2.2,0.6,4.1,0.2,5.7-1.4c1-1,1.7-2.2,1.9-3.5c0-0.1,0-0.2,0-0.2c-0.2-0.5-0.4-1-0.6-1.4c-2.4-4.3-4.7-8.6-7-12.9c-0.3-0.6-1-0.6-1.2-0.6H10.6c0,0-0.9,0-1.2,0.6c-2.4,4.3-4.7,8.7-7,12.9C2.2,19.4,2,20,2,20.6c0,0.1,0,0.1,0,0.2c0.2,1.4,0.8,2.6,1.8,3.5c1.8,1.6,3.8,2,6.2,1.2c1.3-0.5,2.2-1.3,3-2.5c0.1-0.1,0.2-0.2,0.3-0.3c0.5-0.3,1.1-0.2,1.5,0.3c0.4,0.6,0.9,1.2,1.5,1.6c1.7,1.3,3.6,1.5,5.6,0.9c1.3-0.4,2.3-1.3,3-2.5c0.4-0.6,1.4-0.7,1.8,0c0.2,0.2,0.3,0.5,0.5,0.7c1,1.2,2.3,1.9,3.8,2.1c1.4,0.2,2.8-0.2,4.1-1c0.7-0.5,1.3-1.1,1.7-1.8c0.5-0.6,1.4-0.6,1.8,0c0.8,1.3,1.8,2.1,3.3,2.5L42.3,25.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Strategy',
                'M46.9,18.7h-8.1c-1.8,0-3.2,1.4-3.2,3.2V22v1.9h-7.5V8.1c0-0.5-0.5-1-1-1H16.6V5.2c0-1.8-1.4-3.2-3.2-3.2H5.3C3.6,2,2.1,3.4,2.1,5.2v8.1c0,1.8,1.4,3.2,3.2,3.2h8.1c1.8,0,3.2-1.4,3.2-3.2v-1.9H24v12.5h-7.4V22v0c0-1.8-1.4-3.2-3.2-3.2H5.3c-1.8,0-3.2,1.4-3.2,3.2v0v8v0c0,1.8,1.4,3.2,3.2,3.2h8.1c1.8,0,3.2-1.4,3.2-3.2v0v-1.9H24v12.5h-7.4v-1.8c0-1.8-1.4-3.2-3.2-3.2H5.3c-1.8,0-3.2,1.4-3.2,3.2v8.1c0,1.8,1.4,3.2,3.2,3.2h8.1c1.8,0,3.2-1.4,3.2-3.2v-1.9h10.6c0.6,0,1-0.6,1-1V28.2h7.5v1.8V30c0,1.8,1.4,3.2,3.2,3.2h8.1c1.8,0,3.2-1.4,3.2-3.2v-0.1V22v-0.1C50.1,20.1,48.7,18.7,46.9,18.7z M12.5,12.4H6.2V6h6.3V12.4z M12.5,22.8v6.3H6.2v-6.3H12.5z M12.5,46H6.2v-6.3h6.3V46z M46.1,22.8v6.3h-6.3v-6.3H46.1z'
            }
        );
        svgs.add(
            new List<String>{
                'Strikethrough',
                'M12.1,18.1c-0.2-1-0.3-2.2-0.3-3.4c0-1.3,0.3-2.8,0.9-4.2c0.6-1.5,1.5-2.9,2.8-4.1c1.2-1.2,2.9-2.3,4.8-3.1c2-0.8,4.3-1.3,7.1-1.3c2.5,0,4.9,0.3,7.2,1c1.8,0.6,3.5,1.6,5,3c0.6,0.6,0.6,1.6-0.1,2.2l-2.7,2.5c-0.6,0.5-1.5,0.6-2.1,0C34,10,33.2,9.4,32.3,8.9c-1.4-0.7-3-1.1-4.9-1.1c-1.7,0-3.2,0.2-4.3,0.7s-2.1,1-2.8,1.8s-1.2,1.5-1.5,2.3s-0.4,1.6-0.4,2.2c0,1.1,0.2,2,0.5,2.8c0.3,0.7-0.2,1.4-0.9,1.4h-4.9C12.6,19,12.2,18.5,12.1,18.1z x M39.9,33h-5c-0.7,0-1.2,0.7-0.9,1.3c0.3,0.6,0.4,1.4,0.4,2.2c0,1.2-0.3,2.3-0.8,3.3c-0.6,1-1.3,1.7-2.2,2.4c-0.9,0.6-1.9,1.1-3,1.4c-1.1,0.3-2.1,0.5-3.2,0.5c-1.9,0-3.7-0.4-5.4-1.2c-1.3-0.6-2.4-1.4-3.4-2.5c-0.5-0.6-1.5-0.7-2.1-0.2l-2.8,2.4c-0.6,0.5-0.7,1.5-0.1,2.1c1.4,1.6,3.2,2.8,5.3,3.6c2.6,1,5.4,1.5,8.4,1.5c2.2,0,4.3-0.3,6.2-1c1.9-0.6,3.6-1.6,5.1-2.8c1.4-1.2,2.6-2.7,3.4-4.5c0.8-1.8,1.3-3.7,1.3-5.9c0-0.8,0-1.3-0.1-2C40.8,33.4,40.4,33,39.9,33z x M49.9,23.9c-0.2-0.6-0.8-0.9-1.4-0.9h-45c-0.7,0-1.2,0.3-1.4,0.9C2,24.1,2,24.2,2,24.4v3C2,28.2,2.7,29,3.5,29h45c0.8,0,1.5-0.8,1.5-1.6v-3C50,24.2,50,24.1,49.9,23.9z'
            }
        );
        svgs.add(
            new List<String>{
                'Success',
                'M26,2C12.7,2,2,12.7,2,26s10.7,24,24,24s24-10.7,24-24S39.3,2,26,2z M39.4,20L24.1,35.5c-0.6,0.6-1.6,0.6-2.2,0L13.5,27c-0.6-0.6-0.6-1.6,0-2.2l2.2-2.2c0.6-0.6,1.6-0.6,2.2,0l4.4,4.5c0.4,0.4,1.1,0.4,1.5,0L35,15.5c0.6-0.6,1.6-0.6,2.2,0l2.2,2.2C40.1,18.3,40.1,19.3,39.4,20z'
            }
        );
        svgs.add(
            new List<String>{
                'Survey',
                'M5.23,3H40.77A3.29,3.29,0,0,1,44,6.33V9.67A3.29,3.29,0,0,1,40.77,13H5.23A3.29,3.29,0,0,1,2,9.67V6.33A3.29,3.29,0,0,1,5.23,3ZM5.15,18h19.7A3.26,3.26,0,0,1,28,21.33v3.34A3.26,3.26,0,0,1,24.85,28H5.15A3.26,3.26,0,0,1,2,24.67V21.33A3.26,3.26,0,0,1,5.15,18ZM39,28A11,11,0,1,1,28,39,11,11,0,0,1,39,28Zm7,7.92a.84.84,0,0,0,0-1l-1.12-1a.77.77,0,0,0-1.12,0l-6,6.72-2.72-2.72a.77.77,0,0,0-1.12,0l-1.12,1a.68.68,0,0,0,0,1l3.84,3.76a1.58,1.58,0,0,0,1.12.48,1.45,1.45,0,0,0,1.12-.48ZM5.2,33H23.76a16.14,16.14,0,0,0-1,5,17.11,17.11,0,0,0,.48,5H5.2A3.28,3.28,0,0,1,2,39.67V36.33H2A3.28,3.28,0,0,1,5.2,33Z'
            }
        );
        svgs.add(
            new List<String>{
                'Swarm Request',
                'M19,11.48c0,.08.08.16.08.24A.29.29,0,0,0,19,11.48Z x M19.05,11.48c0,.08.08.16.08.24a4.29,4.29,0,0,0,.4.88,6.88,6.88,0,0,0,12.06.47A16.4,16.4,0,0,1,42.28,25.45c.32,0,.64-.08.88-.08A12.35,12.35,0,0,1,47,26,20.84,20.84,0,0,0,32.55,8.6a6.5,6.5,0,0,0-.72-2.31,7,7,0,0,0-9.34-3,6.86,6.86,0,0,0-3.76,7.42A5.52,5.52,0,0,1,19.05,11.48Z x M15.14,33.75A6.86,6.86,0,0,0,9.71,30a8.23,8.23,0,0,1-.08-1.44,16.84,16.84,0,0,1,6.23-12.93,10,10,0,0,0-.64-1,13.25,13.25,0,0,1-1.12-3.43A21.13,21.13,0,0,0,4.92,28.56c0,.88.08,1.68.16,2.56a7,7,0,1,0,10.06,2.63Z x M49.23,33.75a6.94,6.94,0,0,0-12.37,6.31c.08.16.24.4.32.56A16.36,16.36,0,0,1,26,45a16.65,16.65,0,0,1-7.42-1.84,10.24,10.24,0,0,1-3.36,3.35,20.67,20.67,0,0,0,10.86,3,21.14,21.14,0,0,0,14.85-6.15,6.31,6.31,0,0,0,5.35-.4A6.75,6.75,0,0,0,49.23,33.75Z x M19.13,34.15a.32.32,0,0,0,.4.4l2.64-1a.49.49,0,0,1,.56.08,6.34,6.34,0,0,0,3.67,1,7.13,7.13,0,0,0,7.34-6.87A7.13,7.13,0,0,0,26.4,20.9a7.12,7.12,0,0,0-7.27,6.86A7.41,7.41,0,0,0,20,31a.7.7,0,0,1,.08.56Z'
            }
        );
        svgs.add(
            new List<String>{
                'Symbols',
                'M33.5,28 L34.5,24 L37.5,24 L36.5,28 L33.5,28 Z M32.75,31 L35.75,31 L35,34 L38,34 L38.75,31 L42,31 L42,28 L39.5,28 L40.5,24 L43.5,24 L43.5,21 L41.25,21 L42,18 L39,18 L38.25,21 L35.25,21 L36,18 L33,18 L32.25,21 L29,21 L29,24 L31.5,24 L30.5,28 L27,28 L27,31 L29.75,31 L29,34 L32,34 L32.75,31 Z M4,6 L48,6 C49.1045695,6 50,6.8954305 50,8 L50,44 C50,45.1045695 49.1045695,46 48,46 L4,46 C2.8954305,46 2,45.1045695 2,44 L2,8 L2,8 C2,6.8954305 2.8954305,6 4,6 L4,6 Z M23.8366275,26.8097576 C24.4455559,26.3642002 24.9334641,25.9694043 25.301109,25.6242683 C25.6812797,25.2673733 26.0094591,24.8272268 26.285947,24.3049719 C26.569864,23.7686843 26.711,23.1492539 26.711,22.45 C26.711,21.5526019 26.4852508,20.7469107 26.0338199,20.0386313 C25.5832061,19.3316336 24.946713,18.7766428 24.1291062,18.3755526 C23.3160118,17.9766761 22.3837622,17.778 21.335,17.778 C20.0947537,17.778 19.0147775,18.0099667 18.0977133,18.476141 C17.1848146,18.9401979 16.372479,19.6196748 15.6614599,20.5122307 L15.5124489,20.6992871 L17.596493,22.5161461 L17.7608601,22.3289503 C18.2704121,21.7486271 18.7832051,21.3201289 19.2978793,21.0419266 C19.8020352,20.7694099 20.4066387,20.632 21.115,20.632 C21.7892255,20.632 22.3117616,20.8094651 22.6952104,21.1604182 C23.0743022,21.5073835 23.263,21.9679342 23.263,22.56 C23.263,23.0431104 23.1192655,23.442373 22.8305405,23.7695946 C22.514866,24.1273591 22.0259423,24.544907 21.365273,25.0188654 C20.6187463,25.5414137 20.0501357,26.0271803 19.6608663,26.4775116 C19.2459548,26.9575074 19.039,27.5621399 19.039,28.28 L19.039,29 L22.179,29 L22.179,28.72 C22.179,28.4038392 22.2930149,28.1278031 22.5282499,27.8801874 C22.7938963,27.6005595 23.230137,27.2429852 23.8366275,26.8097576 Z M10,18 L10,29 L13,29 L13,18 L10,18 Z M11.5,34.5 C12.6045695,34.5 13.5,33.6045695 13.5,32.5 C13.5,31.3954305 12.6045695,30.5 11.5,30.5 C10.3954305,30.5 9.5,31.3954305 9.5,32.5 C9.5,33.6045695 10.3954305,34.5 11.5,34.5 Z M20.5,34.5 C21.6045695,34.5 22.5,33.6045695 22.5,32.5 C22.5,31.3954305 21.6045695,30.5 20.5,30.5 C19.3954305,30.5 18.5,31.3954305 18.5,32.5 C18.5,33.6045695 19.3954305,34.5 20.5,34.5 Z'
            }
        );
        svgs.add(
            new List<String>{
                'Sync',
                'M47.9,29.3c0-0.8-0.7-1.5-1.5-1.5h-3.5c-0.8,0-1.4,0.6-1.4,1.4c0,0.2,0,0.5-0.1,0.7c-0.3,1.3-0.8,2.5-1.5,3.7c-2.8,4.9-7.7,7.6-12.9,7.6c-4,0-7.8-1.6-10.6-4.4c-0.5-0.4-0.9-0.9-1.2-1.4c-0.3-0.8,0.4-1.2,1.3-1.2h7c0.8,0,1.5-0.7,1.5-1.5v-3.1c0-0.8-0.6-1.4-1.4-1.4H5.3c-0.7,0-1.3,0.6-1.3,1.3v18.2c0.1,0.8,0.8,1.5,1.6,1.5h3c0.8,0,1.5-0.7,1.5-1.5v-7c0-0.9,0.5-1.3,1.2-0.7c0.3,0.4,0.6,0.7,1,1c5,5,12,7.1,19.2,5.7c2.5-0.5,4.9-1.5,7-2.9c5.2-3.4,8.5-8.6,9.4-14.3V29.3z x M4.1,22.7c0,0.8,0.7,1.5,1.5,1.5h3.5c0.8,0,1.4-0.6,1.4-1.4c0-0.2,0-0.5,0.1-0.7c0.3-1.3,0.8-2.5,1.5-3.7c2.8-4.9,7.7-7.6,12.9-7.6c4,0,7.8,1.6,10.6,4.4c0.5,0.4,0.9,0.9,1.2,1.4c0.3,0.8-0.4,1.2-1.3,1.2h-7c-0.8,0-1.5,0.7-1.5,1.5v3.1c0,0.8,0.6,1.4,1.4,1.4h18.3c0.7,0,1.3-0.6,1.3-1.3V4.3c-0.1-0.8-0.8-1.5-1.6-1.5h-3c-0.8,0-1.5,0.7-1.5,1.5v7c0,0.9-0.5,1.3-1.2,0.7c-0.3-0.4-0.6-0.7-1-1c-5-5-12-7.1-19.2-5.7c-2.5,0.5-4.9,1.5-7,2.9C8.3,11.6,5,16.8,4.1,22.5L4.1,22.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Tabset',
                'M31.6,2H20.4c-0.7,0-1.2,0.6-1.2,1.3v2.5c0,0.7,0.6,1.3,1.2,1.3h11.2c0.7,0,1.2-0.6,1.2-1.3V3.3C32.9,2.6,32.3,2,31.6,2z x M48.7,2H37.5c-0.7,0-1.3,0.6-1.3,1.3v2.5c0,0.7,0.6,1.3,1.3,1.3h11.2C49.4,7,50,6.5,50,5.8V3.3C50,2.6,49.4,2,48.7,2z x M48.7,10.4H17c-0.7,0-1.3-0.6-1.3-1.3V3.3c0-0.7-0.6-1.3-1.3-1.3H3.3C2.6,2,2,2.6,2,3.3v45.5C2,49.4,2.6,50,3.3,50h1.7H7h41.7c0.7,0,1.3-0.6,1.3-1.3V11.7C50,11,49.4,10.4,48.7,10.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Target Mode',
                'M24.56,45.75A1.45,1.45,0,0,0,26,44.3l.08-16.77A1.5,1.5,0,0,0,24.81,26H7.72a1.49,1.49,0,0,0-1.53,1.29v3.3a1.49,1.49,0,0,0,1.29,1.53H13a1.08,1.08,0,0,1,1.05,1.05,1.1,1.1,0,0,1-.25.73L2.56,45.18a1.65,1.65,0,0,0-.08,2.26l2.18,2.17a1.7,1.7,0,0,0,2.25-.08L18.28,38.17a1,1,0,0,1,1.45,0,.75.75,0,0,1,.24.73v5.31a1.51,1.51,0,0,0,1.29,1.54h3.3Z x M30.53,48.33A24,24,0,0,0,43.1,41.88a23.37,23.37,0,1,0-33-33.05A23.09,23.09,0,0,0,3.61,21.32H8.36A18.65,18.65,0,0,1,39.8,12.14a18.66,18.66,0,0,1-9.11,31.43Zm.24-9.6a13.14,13.14,0,0,0,5.72-3.46A14,14,0,0,0,16.67,15.44a13.86,13.86,0,0,0-3.47,5.8h5A9.21,9.21,0,0,1,20,18.66,9.35,9.35,0,0,1,33.19,31.88a10.49,10.49,0,0,1-2.42,1.78Z'
            }
        );
        svgs.add(
            new List<String>{
                'Task',
                'M24,7l-1.7-1.7c-0.5-0.5-1.2-0.5-1.7,0L10,15.8l-4.3-4.2c-0.5-0.5-1.2-0.5-1.7,0l-1.7,1.7c-0.5,0.5-0.5,1.2,0,1.7l5.9,5.9c0.5,0.5,1.1,0.7,1.7,0.7c0.6,0,1.2-0.2,1.7-0.7L24,8.7C24.4,8.3,24.4,7.5,24,7z x M48.4,18.4H27.5c-0.9,0-1.6-0.7-1.6-1.6v-3.2c0-0.9,0.7-1.6,1.6-1.6h20.9c0.9,0,1.6,0.7,1.6,1.6v3.2C50,17.7,49.3,18.4,48.4,18.4z x M48.4,32.7H22.7c-0.9,0-1.6-0.7-1.6-1.6v-3.2c0-0.9,0.7-1.6,1.6-1.6h25.7c0.9,0,1.6,0.7,1.6,1.6v3.2C50,32,49.3,32.7,48.4,32.7z x M13,32.7H9.8c-0.9,0-1.6-0.7-1.6-1.6v-3.2c0-0.9,0.7-1.6,1.6-1.6H13c0.9,0,1.6,0.7,1.6,1.6v3.2C14.7,32,13.9,32.7,13,32.7z x M13,47H9.8c-0.9,0-1.6-0.7-1.6-1.6v-3.2c0-0.9,0.7-1.6,1.6-1.6H13c0.9,0,1.6,0.7,1.6,1.6v3.2C14.7,46.3,13.9,47,13,47z x M48.4,47H22.7c-0.9,0-1.6-0.7-1.6-1.6v-3.2c0-0.9,0.7-1.6,1.6-1.6h25.7c0.9,0,1.6,0.7,1.6,1.6v3.2C50,46.3,49.3,47,48.4,47z'
            }
        );
        svgs.add(
            new List<String>{
                'Text Background Color',
                'M25.9,16l4.3,10h-9l3.9-10H25.9z M48,8v36c0,2.2-1.8,4-4,4H8c-2.2,0-4-1.8-4-4V8c0-2.2,1.8-4,4-4h36C46.2,4,48,5.8,48,8z M42.5,40.7L30.5,11c-0.3-0.6-0.8-1-1.5-1h-7.1c-0.6,0-1.2,0.4-1.4,1l-11,29.7C9.3,41.3,9.7,42,10.4,42h4.1c0.6,0,1.2-0.5,1.4-1.1l3.2-8.9h13.4l3.5,8.9c0.2,0.6,0.8,1.1,1.4,1.1h4.1C42.2,42,42.7,41.3,42.5,40.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Thunder',
                'M30.349,3.077c-1.437-1.436-3.786-1.435-5.222,0l-22.05,22.05c-1.436,1.436-1.436,3.785,0,5.221L14.82,42.092c1.436,1.436,3.786,1.436,5.222,0l22.05-22.05c1.434-1.435,1.435-3.785,0-5.222L30.349,3.077z x M12.177,5.009c-0.522-0.522-1.436-0.522-1.958,0l-5.204,5.204c-0.522,0.522-0.522,1.437,0,1.958l1.958,1.958c0.522,0.521,1.436,0.521,1.958,0l5.205-5.205c0.522-0.522,0.522-1.436,0-1.958L12.177,5.009z x M31.062,36.261c-0.522,0.522-0.521,1.437,0,1.958l11.363,11.389c0.522,0.522,1.436,0.522,1.959,0l5.225-5.225c0.521-0.521,0.522-1.436,0-1.959L38.245,31.036c-0.522-0.522-1.438-0.521-1.96,0L31.062,36.261z'
            }
        );
        svgs.add(
            new List<String>{
                'Topic',
                'M17.4,35.3c-0.1-0.3-0.4-0.6-0.7-0.7L14.5,34c-0.4-0.1-0.9,0.1-1.1,0.5L9.6,41c-1,1.8-0.4,2.4,1.4,1.4l6.6-3.8c0.4-0.2,0.6-0.7,0.5-1.1L17.4,35.3z x M34.6,16.7c0.1,0.3,0.4,0.6,0.7,0.7l2.2,0.6c0.4,0.1,0.9-0.1,1.1-0.5l3.8-6.6c1-1.8,0.4-2.4-1.4-1.4l-6.6,3.8c-0.4,0.2-0.6,0.7-0.5,1.1L34.6,16.7z x M13.4,17.6c0.2,0.4,0.7,0.6,1.1,0.5l2.2-0.6c0.3-0.1,0.6-0.4,0.7-0.7l0.6-2.2c0.1-0.4-0.1-0.9-0.5-1.1L11,9.6c-1.8-1-2.4-0.4-1.4,1.4L13.4,17.6z x M38.6,34.4c-0.2-0.4-0.7-0.6-1.1-0.5l-2.2,0.6c-0.3,0.1-0.6,0.4-0.7,0.7L34,37.5c-0.1,0.4,0.1,0.9,0.5,1.1l6.6,3.8c1.8,1,2.4,0.4,1.4-1.4L38.6,34.4z x M48.7,25.2l-16.4-4.4c-0.6-0.1-1-0.6-1.1-1.1L26.8,3.3c-0.5-1.7-1.2-1.7-1.7,0l-4.4,16.4c-0.1,0.6-0.6,1-1.1,1.1L3.3,25.2c-1.7,0.5-1.7,1.2,0,1.7l16.4,4.4c0.6,0.1,1,0.6,1.1,1.1l4.4,16.4c0.5,1.7,1.2,1.7,1.7,0l4.4-16.4c0.1-0.6,0.6-1,1.1-1.1l16.4-4.4C50.4,26.4,50.4,25.6,48.7,25.2z M26,30c-2.2,0-4-1.8-4-4s1.8-4,4-4s4,1.8,4,4S28.2,30,26,30z'
            }
        );
        svgs.add(
            new List<String>{
                'Topic2',
                'M49.2,13.3h-6.5l2.8-10.7V2.4c0-0.4-0.3-0.8-0.8-0.8h-5.2c-0.4,0-0.7,0.3-0.8,0.7l-2.8,11.1h-13l2.8-10.7V2.4c0-0.4-0.3-0.8-0.8-0.8h-5.2c-0.4,0-0.7,0.3-0.8,0.7l-2.9,11H8.8c-0.4,0-0.7,0.2-0.8,0.6l-1.3,4.9v0.2c0,0.4,0.3,0.8,0.8,0.8h6.8l-3.2,12.5h-7c-0.4,0-0.7,0.2-0.8,0.6L2,37.6v0.2c0,0.4,0.3,0.8,0.8,0.8h6.6L6.6,49.5v0.2c0,0.4,0.3,0.8,0.8,0.8h5.2c0.4,0,0.7-0.2,0.8-0.7l2.9-11.2h12.9l-2.8,10.8v0.2c0,0.4,0.3,0.8,0.8,0.8h5.2c0.4,0,0.7-0.2,0.8-0.7L36,38.5h7.1c0.4,0,0.7-0.2,0.8-0.7l1.3-4.9v-0.2c0-0.4-0.3-0.8-0.8-0.8h-6.7L41,19.4h6.9c0.4,0,0.7-0.2,0.8-0.7l1.3-4.9v-0.2C50,13.6,49.6,13.3,49.2,13.3L49.2,13.3z M30.9,32.3H18l3.2-12.5h12.9C34.1,19.8,30.9,32.3,30.9,32.3z'
            }
        );
        svgs.add(
            new List<String>{
                'Touch Action',
                'M37.8,29.8L29.6,27c-0.6-0.2-1.1-0.8-1.1-1.5V14.6c0-1.7-1.4-3-3.1-3h-0.3c-1.7,0-3.1,1.4-3.1,3v21.5c0,1.8-2.3,2.6-3.3,1l-2.1-4.4c-1.1-1.9-3.6-2.4-5.4-1.1l-1.3,1l6.9,16.3c0.3,0.7,1,1.1,1.8,1.1h18.1c0.9,0,1.6-0.6,1.8-1.4l3.2-11.4C42.5,34,40.7,30.9,37.8,29.8z x M17.2,23v-8.2c0-0.2,0-0.2,0-0.4c0.2-4.1,3.5-7.4,7.6-7.6c0.2,0,0.2,0,0.4,0c0.2,0,0.2,0,0.4,0c4.1,0.2,7.4,3.5,7.6,7.6c0,0.2,0,0.2,0,0.4V23c0,0.7,0.9,1,1.4,0.6c2.2-2.3,3.5-5.4,3.5-8.7c0-7.4-6.4-13.4-14-12.7c-5.8,0.6-10.6,5-11.5,10.7c-0.6,4,0.6,7.9,3.3,10.7C16.3,24,17.2,23.7,17.2,23z'
            }
        );
        svgs.add(
            new List<String>{
                'Tracker',
                'M15.2,28.4v-4.4c5.1-0.9,9-5.4,9-10.8c0-6.1-4.9-11-11-11c-6.1,0-11,4.9-11,11c0,5.4,3.9,9.9,9,10.8v4.4c-5.1,0.9-9,5.4-9,10.8c0,6.1,4.9,11,11,11c6.1,0,11-4.9,11-11C24.2,33.8,20.3,29.4,15.2,28.4z M6.2,13.2c0-3.9,3.1-7,7-7c3.9,0,7,3.1,7,7s-3.1,7-7,7C9.3,20.2,6.2,17.2,6.2,13.2z x M30.3,9.2h17.9c1.1,0,2,0.9,2,2v4c0,1.1-0.9,2-2,2H30.3c-1.1,0-2-0.9-2-2v-4C28.3,10.1,29.2,9.2,30.3,9.2z x M30.3,35.2h17.9c1.1,0,2,0.9,2,2v4c0,1.1-0.9,2-2,2H30.3c-1.1,0-2-0.9-2-2v-4C28.3,36.2,29.2,35.2,30.3,35.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Trail',
                'M27.8,2c3.3,0,5.9,2.6,5.9,5.9s-2.7,5.9-5.9,5.9s-5.9-2.6-5.9-5.9S24.5,2,27.8,2z x M43,18.1c-1.2-0.1-2.3,0.7-2.4,1.8L40,25.7c-0.2,0-0.3,0.3-0.5,0.3h-5.5l-3.8-6.7c-0.3-0.6-0.9-1.1-1.6-1.2l-5.8-0.8c-1-0.1-2,0.4-2.4,1.4l-4.4,11.3c-0.3,0.9,0.1,1.8,0.9,2.3l10.8,7.4l0.9,8.4c0.1,1.1,1.1,1.9,2.2,1.9l0,0c1.3,0,2.3-1,2.2-2.2L32,37.5c0-0.5-0.3-1-0.8-1.4l-5.9-6.6l2.2-5.4l2.6,4.5c0.4,0.6,1.1,1.3,1.9,1.3h7.6l-2.2,18c-0.1,1.1,0.7,2,1.9,2.1c0.1,0,0.2-0.1,0.2-0.1c1.1,0,2-0.8,2.2-1.9L45,20.2C45.1,19.2,44.2,18.2,43,18.1z x M12.2,27.7l3.7-9.5c0.2-0.6,0.5-1.2,0.9-1.8l-0.5-0.1c-3.2-0.4-6.2,1.5-7.2,4.4l-2,5.2c-0.4,1.1,0.2,2.4,1.4,2.7l0.9,0.2C10.6,29.3,11.8,28.7,12.2,27.7z x M13.6,35.2L9.1,48.6c-0.2,0.7,0.3,1.3,1,1.3h2.5c0.9,0,1.8-0.6,2.1-1.4l4.4-9.7l-5-3.1C14,35.5,13.8,35.3,13.6,35.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Trailhead',
                'M26.8,2.2c-0.4-0.2-0.9-0.2-1.4,0C11.1,8.2,1.9,22.4,2.2,38v3.4c0,0.5,0.2,1,0.7,1.4c6.9,4.6,15,7.1,23.3,7.2H27h0.1c7.9-0.3,15.7-2.7,22.3-7.2c0.4-0.3,0.7-0.8,0.7-1.4V38C50.4,22.4,41.2,8.2,26.8,2.2z M13.9,14.8c5.8-6.9,12.3-9.2,12.3-9.2c1.4,0.6,16.9,6.7,20.2,26.4h-4.1l-7.8-11.3c-0.5-0.7-1.6-0.9-2.4-0.4c-0.2,0.1-0.3,0.3-0.4,0.4l-2,2.8l-5.5-7.9c-0.5-0.7-1.6-0.9-2.4-0.4c-0.2,0.1-0.3,0.3-0.4,0.4L10.2,31.9L6.1,32C7.3,24.5,10.4,19,13.9,14.8z M38.1,32h-4.7H28l2.6-3.8l2.4-3.6L38.1,32z M23.7,20.9L23.7,20.9L23.7,20.9l4,5.7l-3.8,5.3h-1h-8.6l4.1-6.1l4.3-6.4l0,0L23.7,20.9z M27.5,44L27.5,44l-1.5,2.6c-2.9,0-5.6-0.4-8.8-1.1l0,0c-4.1-1-8-2.7-11.6-4.9v-2.5c0-0.8,0-1.7,0.1-2.6h7.5h10.1c-1.4,2.1-0.7,4.9,1.5,6.2c0.2,0.1,0.4,0.2,0.5,0.3l1.6,0.7C27.5,42.9,27.7,43.5,27.5,44z M46.8,40.5c-2.6,1.6-5.3,2.9-8.1,3.9c0,0-0.5,0.2-0.7,0.2c-1.6,0.5-3.2,0.9-4.9,1.3c-0.9,0.2-1.9,0.3-2.8,0.4l0.3-0.5c1.3-2.2,0.5-4.9-1.7-6.2c-0.1-0.1-0.3-0.1-0.4-0.2l-1.6-0.7c-0.5-0.2-0.8-0.8-0.5-1.4c0-0.1,0.1-0.2,0.1-0.2l1.5-1.7H31h15.7c0,0.8,0.1,1.7,0.1,2.6L46.8,40.5z'
            }
        );
        svgs.add(
            new List<String>{
                'Trailhead Alt',
                'M22.21,36.21a2.72,2.72,0,0,1-.11.25,6.89,6.89,0,0,0,2.42,7.85c1.58,1.24,1.89,1.76,1.73,2.92A7.59,7.59,0,0,1,25.15,50,44.87,44.87,0,0,1,2,42.64H2v-3.7c0-.93,0-1.83.1-2.73H22.21Zm27.69,0c.05.9.1,1.8.1,2.73h0v3.69a45,45,0,0,1-20.31,7.2,10,10,0,0,0,.54-2c.53-3.73-1.83-5.57-3.24-6.67a2.83,2.83,0,0,1-1.12-3.25,8.24,8.24,0,0,1,.89-1.67H49.9ZM22.5,19.59l4.4,6.47-4.16,6.13h-8.8ZM26,2A39.25,39.25,0,0,1,49.48,32.19H43.6l-8.77-12.9a2.08,2.08,0,0,0-3.33,0h0l-2.17,3.19-5.17-7.6a2.09,2.09,0,0,0-3.33,0h0L9.08,32.19H2.52A39.25,39.25,0,0,1,26,2Zm7.17,22,5.56,8.19H27.61Z'
            }
        );
        svgs.add(
            new List<String>{
                'Transparent',
                'M48.5,5.6,46.4,3.5a1.67,1.67,0,0,0-2.4.3L32.59,15.21c-.77-1.3-1.51-2.61-2.21-4a36.5,36.5,0,0,1-3.15-8.36c-.13-.53-.39-.91-1-.89s-.86.4-1,.93c-.06.26-.11.51-.17.76A48.3,48.3,0,0,1,21,13.7,97.47,97.47,0,0,1,14.13,25a16,16,0,0,0-3,11.12c0,.14,0,.29.06.43L3.8,44a1.87,1.87,0,0,0-.3,2.4l2.1,2.1A1.67,1.67,0,0,0,8,48.2L48.2,8A1.67,1.67,0,0,0,48.5,5.6Z x M38.42,23.79l-22,22.31A14.47,14.47,0,0,0,26.22,50a15.48,15.48,0,0,0,7-1.44c4.94-2.51,8.11-6.4,8.94-12A15.22,15.22,0,0,0,39,24.66C38.87,24.44,38.58,24,38.42,23.79Z'
            }
        );
        svgs.add(
            new List<String>{
                'Travel and Places',
                'M47,21 L42.48,8.84 C41.76,6.52 39.6,5 37.2,5 L14.8,5 C12.4,5 10.24,6.52 9.44,8.84 L5,21 C2.92,21.56 2,23.56 2,25.8 L2,37.4 C2,39.48 4.16,41.28 6,42 L6,46.0334473 C6,47.3444824 6.67423503,48 8.02270508,48 L13.050293,48 C14.3500977,48 15,47.3444824 15,46.0334473 L15,42 L37,42 L37,46.0334473 C37,47.3444824 37.6625977,48 38.987793,48 L44.0212402,48 C45.3404134,48 46,47.3444824 46,46.0334473 L46,41.96 C47.84,41.32 50,39.56 50,37.4 L50,25.8 C50,23.56 49.08,21.56 47,21 Z M11,34 C8.76,34 7,32.24 7,30 C7,27.76 8.76,26 11,26 C13.24,26 15,27.76 15,30 C15,32.24 13.24,34 11,34 Z M27.6,21 L11.76,21 C11.2,21 10.84,20.48 11,20 L14,11 C14.08,10.68 14.289856,10 15,10 L37,10 C37.7802124,10 37.92,10.76 38,11 L41,20 C41.2,20.6424561 40.880127,21 40.08,21 L27.6,21 Z M41,34 C38.76,34 37,32.24 37,30 C37,27.76 38.76,26 41,26 C43.24,26 45,27.76 45,30 C45,32.24 43.24,34 41,34 Z'
            }
        );
        svgs.add(
            new List<String>{
                'Trending',
                'M50.1,30.56a1.16,1.16,0,0,1-2,.82L42.73,26,30.32,36.65a3.39,3.39,0,0,1-4.92,0l-7.49-8.54L4.57,39.81a1.13,1.13,0,0,1-1.64,0l-.59-.59a1.13,1.13,0,0,1,0-1.64L15.46,19.68a3.39,3.39,0,0,1,4.92,0l7.49,7.49,7.61-8.78-4.92-4.45a1.26,1.26,0,0,1,.82-2.11H47.76A2.35,2.35,0,0,1,50,14.3Z'
            }
        );
        svgs.add(
            new List<String>{
                'Turn Off Notifications',
                'M23.4,26.6c0.6,0.6,1.4,0.6,2,0L46.8,6.9C47.2,6.2,47.1,5,45.6,5H3.4c-1.1,0-2,1.1-1.2,2L23.4,26.6z x M30.1,37.6c0.5-5.6,5-10.2,10.7-10.8c0.5,0,1-0.1,1.4-0.1c1.8,0,3.4,0.4,4.9,1c0-4.2,0-9.3,0-12.4c0-1-1.2-1.5-1.9-0.8L28.6,29.9c-1.1,1-2.6,1.6-4.1,1.6s-3-0.6-4.1-1.6L3.8,14.5c-0.8-0.7-1.9-0.2-1.9,0.8v19.6c0,2.5,2.1,4.6,4.6,4.6h23.7C30.1,38.9,30.1,38.2,30.1,37.6z x M42.1,31c-4.4,0-8,3.6-8,8s3.6,8,8,8s8-3.6,8-8S46.5,31,42.1,31z M48.1,40.6c0,0.2-0.2,0.4-0.5,0.4h-11c-0.3,0-0.5-0.2-0.5-0.4c0-0.4,0-2.9,0-3.2c0-0.2,0.2-0.4,0.5-0.4h11c0.3,0,0.5,0.2,0.5,0.4C48.1,37.8,48.1,40.2,48.1,40.6z'
            }
        );
        svgs.add(
            new List<String>{
                'Type Tool',
                'M50.37,47.59,32.74,4a2.41,2.41,0,0,0-2.2-1.47H20.11A2.21,2.21,0,0,0,18.06,4L1.9,47.59A1.43,1.43,0,0,0,3.22,49.5h6a2.36,2.36,0,0,0,2.06-1.62L16,34.81H35.68l5.14,13.07a2.36,2.36,0,0,0,2.06,1.62h6A1.52,1.52,0,0,0,50.37,47.59ZM19.08,26l5.73-14.69H26L32.3,26Z'
            }
        );
        svgs.add(
            new List<String>{
                'Unlock',
                'M10,18.1v0.4C10,18.4,10,18.3,10,18.1C10,18.1,10,18.1,10,18.1z x M42,23H16v-4.7c0-5.3,4-10,9.3-10.3c4.9-0.3,9,2.8,10.3,7.2c0.1,0.4,0.5,0.8,1,0.8h4.1c0.6,0,1.1-0.6,1-1.2C40.1,7.2,33.3,1.6,25.2,2c-8.5,0.4-15,7.7-15.2,16.1c0,0.1,0,0.2,0,0.3V23c-2.2,0-4,1.8-4,4v19c0,2.2,1.8,4,4,4h32c2.2,0,4-1.8,4-4V27C46,24.8,44.2,23,42,23z M30.6,42.7c0.2,0.6-0.3,1.3-1,1.3h-7.3c-0.7,0-1.2-0.6-1-1.3l1.8-6c-1.5-1-2.4-2.8-2-4.8c0.4-1.9,1.9-3.4,3.9-3.8c3.2-0.6,6,1.7,6,4.7c0,1.6-0.8,3.1-2.1,3.9L30.6,42.7z'
            }
        );
        svgs.add(
            new List<String>{
                'Unmuted',
                'M41.5,18c-1.4,0-2.5,1-2.5,2.4v4c0,7-5.9,12.8-13.1,12.8s-13.1-5.8-13.1-12.8v-4c0-1.4-1.1-2.4-2.5-2.4S8,19,8,20.4v4c0,8.9,6.8,16.2,15.5,17.4v3.4h-4.1c-1.4,0-2.5,1-2.5,2.4c0,1.4,1.1,2.4,2.5,2.4h13.1c1.4,0,2.5-1,2.5-2.4c0-1.4-1.1-2.4-2.5-2.4h-4.1v-3.4C37.2,40.6,44,33.3,44,24.4v-4C44,19,42.9,18,41.5,18z x M26,32.4c4.4,0,8-3.6,8-8V9.9C34,5.5,30.5,2,26.1,2h-0.2C21.5,2,18,5.5,18,9.9v14.5C18,28.8,21.6,32.4,26,32.4z'
            }
        );
        svgs.add(
            new List<String>{
                'Variable',
                'M42.6,17.8c2.4,0,7.2-2,7.2-8.4c0-6.4-4.6-6.8-6.1-6.8c-2.8,0-5.6,2-8.1,6.3c-2.5,4.4-5.3,9.1-5.3,9.1l-0.1,0c-0.6-3.1-1.1-5.6-1.3-6.7c-0.5-2.7-3.6-8.4-9.9-8.4c-6.4,0-12.2,3.7-12.2,3.7l0,0C5.8,7.3,5.1,8.5,5.1,9.9c0,2.1,1.7,3.9,3.9,3.9c0.6,0,1.2-0.2,1.7-0.4l0,0c0,0,4.8-2.7,5.9,0c0.3,0.8,0.6,1.7,0.9,2.7c1.2,4.2,2.4,9.1,3.3,13.5l-4.2,6c0,0-4.7-1.7-7.1-1.7s-7.2,2-7.2,8.4s4.6,6.8,6.1,6.8c2.8,0,5.6-2,8.1-6.3c2.5-4.4,5.3-9.1,5.3-9.1c0.8,4,1.5,7.1,1.9,8.5c1.6,4.5,5.3,7.2,10.1,7.2c0,0,5,0,10.9-3.3c1.4-0.6,2.4-2,2.4-3.6c0-2.1-1.7-3.9-3.9-3.9c-0.6,0-1.2,0.2-1.7,0.4l0,0c0,0-4.2,2.4-5.6,0.5c-1-2-1.9-4.6-2.6-7.8c-0.6-2.8-1.3-6.2-2-9.5l4.3-6.2C35.5,16.1,40.2,17.8,42.6,17.8z'
            }
        );
        svgs.add(
            new List<String>{
                'Video',
                'M46.9,13.1L35.9,21v-5.6c0-1.5-1.2-2.7-2.7-2.7H4.7c-1.5,0-2.7,1.2-2.7,2.7v21.3c0,1.5,1.2,2.7,2.7,2.7h28.6c1.5,0,2.7-1.2,2.7-2.7v-5.5L46.9,39c0.7,0.7,1.9,0.2,1.9-0.8V13.9C48.8,12.9,47.6,12.4,46.9,13.1z'
            }
        );
        svgs.add(
            new List<String>{
                'Voicemail Drop',
                'M39,14.8c-6.1,0-11.2,5-11.2,11.2c0,2.2,0.7,4.3,1.8,6.1h-7.2c1.2-1.8,1.8-3.8,1.8-6.1c0-6.1-5-11.2-11.2-11.2c-6.1,0-11.2,5-11.2,11.2c0,6.1,5,11.2,11.2,11.2l0,0h25.9l0,0l0,0c6.1,0,11.2-5,11.2-11.2C50.2,19.8,45.2,14.8,39,14.8z M7.2,25.9c0-3.3,2.7-6,5.9-6c3.3,0,5.9,2.7,5.9,6s-2.7,6-5.9,6S7.2,29.3,7.2,25.9z M39,32c-3.3,0-5.9-2.7-5.9-6s2.7-6,5.9-6c3.3,0,5.9,2.7,5.9,6C45,29.3,42.3,32,39,32z'
            }
        );
        svgs.add(
            new List<String>{
                'Volume High',
                'M24.6,2.6L12,18H6c-2.2,0-4,1.8-4,4v8c0,2.2,1.8,4,4,4h6l12.6,15.4c1.3,1.3,3.4,0.4,3.4-1.4V4C28,2.2,25.8,1.3,24.6,2.6z x M42.6,8.7c-0.4-0.4-1-0.4-1.4,0l-1.4,1.4c-0.4,0.4-0.4,1.1,0,1.4C43.6,15.2,46,20.3,46,26c0,5.7-2.4,10.8-6.2,14.5c-0.4,0.4-0.4,1,0,1.4l1.4,1.4c0.4,0.4,1,0.4,1.4,0C47.1,39,50,32.8,50,26C50,19.2,47.2,13,42.6,8.7z x M36.3,15.1c-0.4-0.4-1-0.4-1.4,0l-1.4,1.4c-0.4,0.4-0.4,1,0,1.4c2.2,2,3.5,4.9,3.5,8.1c0,3.2-1.4,6.1-3.6,8.1c-0.4,0.4-0.4,1,0,1.4l1.4,1.4c0.4,0.4,1,0.4,1.4,0c2.9-2.7,4.8-6.6,4.8-11C41,21.7,39.2,17.8,36.3,15.1z'
            }
        );
        svgs.add(
            new List<String>{
                'Volume Low',
                'M24.6,2.6L12,18H6c-2.2,0-4,1.8-4,4v8c0,2.2,1.8,4,4,4h6l12.6,15.4c1.3,1.3,3.4,0.4,3.4-1.4V4C28,2.2,25.8,1.3,24.6,2.6z x M36.3,15.1c-0.4-0.4-1-0.4-1.4,0l-1.4,1.4c-0.4,0.4-0.4,1,0,1.4c2.2,2,3.5,4.9,3.5,8.1s-1.4,6.1-3.6,8.1c-0.4,0.4-0.4,1,0,1.4l1.4,1.4c0.4,0.4,1,0.4,1.4,0c2.9-2.7,4.8-6.6,4.8-11C41,21.7,39.2,17.8,36.3,15.1z'
            }
        );
        svgs.add(
            new List<String>{
                'Volume Off',
                'M24.6,2.6L12,18H6c-2.2,0-4,1.8-4,4v8c0,2.2,1.8,4,4,4h6l12.6,15.4c1.3,1.3,3.4,0.4,3.4-1.4V4C28,2.2,25.8,1.3,24.6,2.6z x M44.8,26l4.9-4.9c0.4-0.4,0.4-1,0-1.4l-1.4-1.4c-0.4-0.4-1-0.4-1.4,0L42,23.2l-4.9-4.9c-0.4-0.4-1-0.4-1.4,0l-1.4,1.4c-0.4,0.4-0.4,1,0,1.4l4.9,4.9l-4.9,4.9c-0.4,0.4-0.4,1,0,1.4l1.4,1.4c0.4,0.4,1,0.4,1.4,0l4.9-4.9l4.9,4.9c0.4,0.4,1,0.4,1.4,0l1.4-1.4c0.4-0.4,0.4-1,0-1.4L44.8,26z'
            }
        );
        svgs.add(
            new List<String>{
                'Waits',
                'M50,18.4c0-0.8-0.7-1.5-1.5-1.5h-21c-0.8,0-1.5,0.7-1.5,1.5v3c0,0.8,0.7,1.5,1.5,1.5h14.3L26.3,41.8c0,0,0,0.1,0,0.1c-0.2,0.2-0.3,0.5-0.3,0.8v3c0,0.8,0.7,1.5,1.5,1.5h21c0.8,0,1.5-0.7,1.5-1.5v-3c0-0.8-0.7-1.5-1.5-1.5h-14l15.2-18.6c0.2-0.3,0.3-0.7,0.3-1c0-0.1,0-0.1,0-0.2V18.4z x M26,6.3c0-0.8-0.7-1.5-1.5-1.5h-21C2.7,4.8,2,5.5,2,6.3v3c0,0.8,0.7,1.5,1.5,1.5h14.3L2.3,29.7c0,0,0,0.1,0,0.1C2.1,30,2,30.3,2,30.6v3c0,0.8,0.7,1.5,1.5,1.5h21c0.8,0,1.5-0.7,1.5-1.5v-3c0-0.8-0.7-1.5-1.5-1.5h-14l15.2-18.6c0.2-0.3,0.3-0.7,0.3-1c0-0.1,0-0.1,0-0.2V6.3z'
            }
        );
        svgs.add(
            new List<String>{
                'Warning',
                'm51.4 42.5l-22.9-37c-1.2-2-3.8-2-5 0l-22.9 37c-1.4 2.3 0 5.5 2.5 5.5h45.8c2.5 0 4-3.2 2.5-5.5z m-25.4-2.5c-1.7 0-3-1.3-3-3s1.3-3 3-3 3 1.3 3 3-1.3 3-3 3z m3-9c0 0.6-0.4 1-1 1h-4c-0.6 0-1-0.4-1-1v-13c0-0.6 0.4-1 1-1h4c0.6 0 1 0.4 1 1v13z'
            }
        );
        svgs.add(
            new List<String>{
                'Warranty Term',
                'M26,2c3,0,5.43,3.29,8.09,4.42s6.82.51,8.84,2.65,1.51,6.07,2.65,8.84S50,23,50,26s-3.29,5.43-4.42,8.09-.51,6.82-2.65,8.84-6.07,1.53-8.84,2.65S29,50,26,50s-5.43-3.29-8.09-4.42-6.82-.51-8.84-2.65-1.53-6.07-2.65-8.84S2,29,2,26s3.29-5.43,4.42-8.09.51-6.82,2.65-8.84,6.07-1.53,8.84-2.65S23,2,26,2Zm0,7.58A16.42,16.42,0,1,0,42.42,26h0A16.47,16.47,0,0,0,26,9.58Zm7.62,9.15,1.61,1.52a1.25,1.25,0,0,1,0,1.51L25.08,33.07a2.07,2.07,0,0,1-1.61.7,2.23,2.23,0,0,1-1.61-.7L16.37,27.6a1,1,0,0,1-.1-1.42l.1-.11L18,24.56a1.1,1.1,0,0,1,1.54-.07l.07.07,3.89,4,8.59-9.8A1.1,1.1,0,0,1,33.62,18.73Z'
            }
        );
        svgs.add(
            new List<String>{
                'Watch List',
                'M42.9,7h.2l.3.1a2.45,2.45,0,0,1,1.4,1l.2.3,4.2,7.4c1.5,2.7.2,3.4-1.1,4.2s-2.5,1.1-3.9-.8l-.1-.2-.7-1.3L37,42.7a3,3,0,0,1-5.3,1.1l-.1-.1L20.9,27.2l-5.5,12A3,3,0,0,1,12.7,41H3.6c-.4,0-1.5-.4-1.5-1.4A4.06,4.06,0,0,0,2,38.3V36.5a1.52,1.52,0,0,1,1.44-1.6H10.8l7-15.2a2.94,2.94,0,0,1,3.86-1.55A3,3,0,0,1,23,19.3h0l9.9,15.3,4.6-18.1-.9.5c-1.9,1.3-2.7.7-3.9-.8l-.2-.3c-.8-1.3-1.1-2.6.1-3.5l1-.7L41,7.4A3.14,3.14,0,0,1,42.9,7Z'
            }
        );
        svgs.add(
            new List<String>{
                'Wellness',
                'M27.42,10.57A1.66,1.66,0,0,0,26.17,10h0a1.66,1.66,0,0,0-1.25.56c-11.76,13.39-5,24,0,29.07a1.66,1.66,0,0,0,1.19.49h0a1.77,1.77,0,0,0,1.24-.54C32.3,34.48,38.83,23.93,27.42,10.57Z x M15.66,28.3C13,26.79,9.37,25.92,4.56,26.24a1.27,1.27,0,0,0-1,.53h0a1.34,1.34,0,0,0-.24,1.08c3,14,13,14.75,18.77,13.94a1.35,1.35,0,0,0,.64-.3A23.14,23.14,0,0,1,15.66,28.3Z x M36.34,28.3c2.69-1.51,6.29-2.38,11.1-2.06a1.27,1.27,0,0,1,1,.53h0a1.34,1.34,0,0,1,.24,1.08c-3,14-13,14.75-18.77,13.94a1.35,1.35,0,0,1-.64-.3A23.14,23.14,0,0,0,36.34,28.3Z x M15.38,25c.32-4.56,1.2-6.62,1.61-7.35a22.71,22.71,0,0,0-6.43-3.46,1.28,1.28,0,0,0-1.08.09h0a1.34,1.34,0,0,0-.64.88,21.65,21.65,0,0,0-.25,8.41A22.93,22.93,0,0,1,15.38,25Z x M43.31,15.13a1.29,1.29,0,0,0-.64-.88h0a1.28,1.28,0,0,0-1.08-.09,22.79,22.79,0,0,0-6.42,3.46c.4.73,1.29,2.79,1.6,7.35a22.93,22.93,0,0,1,6.8-1.43A21.27,21.27,0,0,0,43.31,15.13Z'
            }
        );
        svgs.add(
            new List<String>{
                'Wifi',
                'M47.7,15.8c-5.5-6.1-13.3-9.5-21.6-9.5S10,9.7,4.5,15.8c-0.4,0.4-0.3,1.1,0.1,1.4l3,2.6c0.4,0.4,1,0.3,1.4-0.1c4.4-4.7,10.6-7.4,17.1-7.4s12.7,2.7,17.1,7.4c0.4,0.4,1,0.4,1.4,0.1l3-2.6C48,16.8,48.1,16.2,47.7,15.8z x M26.1,20.3c-4.2,0-8.2,1.8-11,5c-0.4,0.4-0.3,1.1,0.1,1.5l3.2,2.4c0.4,0.3,1,0.3,1.3-0.1c1.7-1.8,4-2.8,6.4-2.8s4.7,1,6.3,2.7c0.3,0.4,0.9,0.4,1.3,0.1l3.2-2.4c0.5-0.4,0.5-1,0.1-1.5C34.3,22.1,30.3,20.3,26.1,20.3z x M26.2,34.2c2.7,0,5,2.2,5,5s-2.2,5-5,5s-5-2.2-5-5S23.5,34.2,26.2,34.2z'
            }
        );
        svgs.add(
            new List<String>{
                'Work Forecast',
                'M44.88,11.82s-2.38-4.91-7.7-4.91S29.34,12,29.34,12a7.94,7.94,0,0,0-6.75,0s-2.45-5.05-7.77-5.05-7.7,4.91-7.7,4.91S2.14,22.93,2,32.89s6.48,12.2,9.61,12.2c3.41,0,11.46-1.43,11.05-12.61a3.26,3.26,0,0,1,3.07-1.84,4.06,4.06,0,0,1,3.68,1.84C29,43.66,37,45.09,40.39,45.09c3.06,0,9.74-2.39,9.61-12.2S44.88,11.82,44.88,11.82ZM12.23,40.73a5.94,5.94,0,1,1,5.93-5.94A5.94,5.94,0,0,1,12.23,40.73Zm27.54,0a5.94,5.94,0,1,1,5.93-5.94A5.94,5.94,0,0,1,39.77,40.73Z'
            }
        );
        svgs.add(
            new List<String>{
                'World',
                'M26,2C12.7,2,2,12.7,2,26s10.7,24,24,24s24-10.7,24-24S39.3,2,26,2z M26,7C26,7,26,7,26,7C26,7,26,7,26,7C26,7,26,7,26,7z M28,7.1c-0.1,0-0.1,0-0.2,0C27.9,7.1,28,7.1,28,7.1z M26,45C15.5,45,7,36.5,7,26c0-1,0.1-2.1,0.3-3c1.3,0.2,2.9,0.7,3.7,1.5c1.7,1.8,3.6,3.9,5.4,4.3c0,0-0.2,0.1-0.4,0.4c-0.2,0.3-0.4,0.9-0.4,1.9c0,4.7,4.4,1.9,4.4,6.6c0,4.7,5.3,6.6,5.3,2.8s3.5-5.6,3.5-8.5s-2.7-2.8-4.4-3.8c-1.8-0.9-2.7-2.4-6.1-1.9c-1.8-1.7-2.8-3.1-2-4.7c0.9-1.7,4.6-2,4.6-4.6s-2.5-3.1-4.3-3.1c-0.8,0-2.5-0.6-3.9-1.3c1.7-1.7,3.8-3.1,6-4.1c1.6,0.7,4.3,1.8,6.6,1.8c2.7,0,4.1-1.9,3.7-3.1c4.5,0.7,8.5,3,11.4,6.2c-1.5,0.9-3.5,1.9-7,1.9c-4.6,0-4.6,4.7-1.9,5.6c2.8,0.9,5.6-1.8,6.5,0c0.9,1.8-6.5,1.8-4.6,6.4c1.9,4.6,3.7-0.1,5.6,4.5c1.9,4.6,5.6-0.7,2.8-4.3c-1.2-1.6-0.9-6.5,1.9-6.5h0.9c0.4,1.6,0.7,3.3,0.7,5C45,36.5,36.5,45,26,45z'
            }
        );
        svgs.add(
            new List<String>{
                'Yubi Key',
                'M38.5,14.1h-37c-0.8,0-1.5,0.7-1.5,1.5v21c0,0.8,0.7,1.5,1.5,1.5h37c0.8,0,1.5-0.7,1.5-1.5v-21C40,14.8,39.3,14.1,38.5,14.1z M21,32.2c-3.4,0-6.1-2.7-6.1-6.1S17.6,20,21,20s6.1,2.7,6.1,6.1S24.4,32.2,21,32.2z x M50.5,18H36c-0.8,0-1.5,0.7-1.5,1.5v13c0,0.8,0.7,1.5,1.5,1.5h14.5c0.8,0,1.5-0.7,1.5-1.5v-13C52,18.7,51.3,18,50.5,18z M47.1,22c0.6,0,1,0.4,1,1v1.9H40V22H47.1z M47.1,30H40v-2.7h8.1V29C48.1,29.6,47.7,30,47.1,30z'
            }
        );
        svgs.add(
            new List<String>{
                'Zoom In',
                'M31,19h-6v-6c0-0.6-0.4-1-1-1h-4c-0.6,0-1,0.4-1,1v6h-6c-0.6,0-1,0.4-1,1v4c0,0.6,0.4,1,1,1h6v6c0,0.6,0.4,1,1,1h4c0.6,0,1-0.4,1-1v-6h6c0.6,0,1-0.4,1-1v-4C32,19.4,31.6,19,31,19z x M49.6,45.2L38.1,33.8C40.5,30.5,42,26.4,42,22c0-11-9-20-20-20S2,11,2,22s9,20,20,20c4.4,0,8.5-1.5,11.8-3.9l11.5,11.5c0.6,0.6,1.5,0.6,2.1,0l2.1-2.1C50.1,46.9,50.1,45.9,49.6,45.2z M22,36c-7.7,0-14-6.3-14-14S14.3,8,22,8s14,6.3,14,14S29.7,36,22,36z'
            }
        );
        svgs.add(
            new List<String>{
                'Zoom Out',
                'M19,25h12c0.6,0,1-0.4,1-1v-4c0-0.6-0.4-1-1-1H19 x M19,19h-6c-0.6,0-1,0.4-1,1v4c0,0.6,0.4,1,1,1h6 x M49.6,45.3L38.1,33.8C40.5,30.5,42,26.4,42,22c0-11-9-20-20-20S2,11,2,22s9,20,20,20c4.4,0,8.5-1.5,11.8-3.9l11.5,11.5c0.6,0.6,1.5,0.6,2.1,0l2.1-2.1C50.1,46.9,50.1,45.9,49.6,45.3z M22,36c-7.7,0-14-6.3-14-14S14.3,8,22,8s14,6.3,14,14S29.7,36,22,36z'
            }
        );

        // Custom Icons with different viewboxes
        svgs.add(
            new List<String>{
                '[c] File Pen',
                'M0 64C0 28.65 28.65 0 64 0H224V128C224 145.7 238.3 160 256 160H384V299.6L289.3 394.3C281.1 402.5 275.3 412.8 272.5 424.1L257.4 484.2C255.1 493.6 255.7 503.2 258.8 512H64C28.65 512 0 483.3 0 448V64z x M256 128V0L384 128H256z x M564.1 250.1C579.8 265.7 579.8 291 564.1 306.7L534.7 336.1L463.8 265.1L493.2 235.7C508.8 220.1 534.1 220.1 549.8 235.7L564.1 250.1z x M311.9 416.1L441.1 287.8L512.1 358.7L382.9 487.9C378.8 492 373.6 494.9 368 496.3L307.9 511.4C302.4 512.7 296.7 511.1 292.7 507.2C288.7 503.2 287.1 497.4 288.5 491.1L303.5 431.8C304.9 426.2 307.8 421.1 311.9 416.1V416.1z',
                '0 0 576 512'
            }
        );

        svgs.add(
            new List<String>{
                '[c] Budget Holder',
                'M 118.1 235.517 c 7.898 0 14.31 -6.032 14.31 -13.483 c 0 -7.441 0 -13.473 0 -13.473 c 39.069 -3.579 64.932 -24.215 64.932 -57.785 v -0.549 c 0 -34.119 -22.012 -49.8 -65.758 -59.977 V 58.334 c 6.298 1.539 12.82 3.72 19.194 6.549 c 10.258 4.547 22.724 1.697 28.952 -8.485 c 6.233 -10.176 2.866 -24.47 -8.681 -29.654 c -11.498 -5.156 -24.117 -8.708 -38.095 -10.236 V 8.251 c 0 -4.552 -6.402 -8.251 -14.305 -8.251 c -7.903 0 -14.31 3.514 -14.31 7.832 c 0 4.335 0 7.843 0 7.843 c -42.104 3.03 -65.764 25.591 -65.764 58.057 v 0.555 c 0 34.114 22.561 49.256 66.862 59.427 v 33.021 c -10.628 -1.713 -21.033 -5.243 -31.623 -10.65 c -11.281 -5.755 -25.101 -3.72 -31.938 6.385 c -6.842 10.1 -4.079 24.449 7.294 30.029 c 16.709 8.208 35.593 13.57 54.614 15.518 v 13.755 C 103.79 229.36 110.197 235.517 118.1 235.517 Z x M 131.301 138.12 c 14.316 4.123 18.438 8.257 18.438 15.681 v 0.555 c 0 7.979 -5.776 12.651 -18.438 14.033 V 138.12 Z M 86.999 70.153 v -0.549 c 0 -7.152 5.232 -12.657 18.71 -13.755 v 29.719 C 90.856 81.439 86.999 77.305 86.999 70.153 Z',
                '0 0 235.517 235.517'
            }
        );

        svgs.add(
            new List<String>{
                '[c] Person Walking Arrow',
                'M160 48C160 21.49 181.5 0 208 0C234.5 0 256 21.49 256 48C256 74.51 234.5 96 208 96C181.5 96 160 74.51 160 48V48zM112.7 205.4C97.41 212.2 85.42 224.6 79.22 240.1L77.71 243.9C71.15 260.3 52.53 268.3 36.12 261.7C19.71 255.1 11.73 236.5 18.29 220.1L19.8 216.3C32.19 185.4 56.18 160.5 86.66 146.9L97.66 142C118.5 132.8 140.1 128 163.7 128C208.3 128 248.5 154.8 265.6 195.9L280.1 232.7L302.3 243.4C318.1 251.3 324.5 270.5 316.6 286.3C308.7 302.1 289.5 308.5 273.7 300.6L247 287.3C236.7 282.1 228.6 273.4 224.2 262.8L214.6 239.8L195.3 305.3L244.8 359.4C250.2 365.3 254.1 372.4 256 380.2L279 472.2C283.3 489.4 272.9 506.8 255.8 511C238.6 515.3 221.2 504.9 216.1 487.8L194.9 399.6L124.3 322.5C109.5 306.4 103.1 283.9 109.6 262.8L126.5 199.3C125.6 199.7 124.6 200.1 123.7 200.5L112.7 205.4z x M100.7 344.2L141.4 388.6L126.9 424.8C124.5 430.9 120.9 436.4 116.3 440.9L54.63 502.6C42.13 515.1 21.87 515.1 9.372 502.6C-3.124 490.1-3.124 469.9 9.372 457.4L68.73 398L93.69 335.6C95.84 338.6 98.17 341.4 100.7 344.2H100.7z x M630.6 233.4C643.1 245.9 643.1 266.1 630.6 278.6L550.6 358.6C538.1 371.1 517.9 371.1 505.4 358.6C492.9 346.1 492.9 325.9 505.4 313.4L530.7 288H384C366.3 288 352 273.7 352 256C352 238.3 366.3 224 384 224H530.7L505.4 198.6C492.9 186.1 492.9 165.9 505.4 153.4C517.9 140.9 538.1 140.9 550.6 153.4L630.6 233.4z',
                '0 0 640 512'
            }
        );

        svgs.add(
            new List<String>{
                '[c] Person Group',
                'M184 88C184 118.9 158.9 144 128 144C97.07 144 72 118.9 72 88C72 57.07 97.07 32 128 32C158.9 32 184 57.07 184 88z x M208.4 196.3C178.7 222.7 160 261.2 160 304C160 338.3 171.1 369.8 192 394.5V416C192 433.7 177.7 448 160 448H96C78.33 448 64 433.7 64 416V389.2C26.16 371.2 0 332.7 0 288C0 226.1 50.14 176 112 176H144C167.1 176 190.2 183.5 208.4 196.3V196.3z x M64 245.7C54.04 256.9 48 271.8 48 288C48 304.2 54.04 319.1 64 330.3V245.7z x M448 416V394.5C468 369.8 480 338.3 480 304C480 261.2 461.3 222.7 431.6 196.3C449.8 183.5 472 176 496 176H528C589.9 176 640 226.1 640 288C640 332.7 613.8 371.2 576 389.2V416C576 433.7 561.7 448 544 448H480C462.3 448 448 433.7 448 416z x M576 330.3C585.1 319.1 592 304.2 592 288C592 271.8 585.1 256.9 576 245.7V330.3z x M568 88C568 118.9 542.9 144 512 144C481.1 144 456 118.9 456 88C456 57.07 481.1 32 512 32C542.9 32 568 57.07 568 88z x M256 96C256 60.65 284.7 32 320 32C355.3 32 384 60.65 384 96C384 131.3 355.3 160 320 160C284.7 160 256 131.3 256 96z x M448 304C448 348.7 421.8 387.2 384 405.2V448C384 465.7 369.7 480 352 480H288C270.3 480 256 465.7 256 448V405.2C218.2 387.2 192 348.7 192 304C192 242.1 242.1 192 304 192H336C397.9 192 448 242.1 448 304z x M256 346.3V261.7C246 272.9 240 287.8 240 304C240 320.2 246 335.1 256 346.3z x M384 261.7V346.3C393.1 335 400 320.2 400 304C400 287.8 393.1 272.9 384 261.7z',
                '0 0 640 512'
            }
        );

        svgs.add(
            new List<String>{
                '[c] Legal',
                'M 217.75 124.981 h -4.752 l -24.451 -48.9 h 2.939 c 4.143 0 7.5 -3.358 7.5 -7.5 c 0 -4.142 -3.357 -7.5 -7.5 -7.5 h -71.588 v -6.635 c 7.803 -3.021 13.359 -10.584 13.359 -19.44 c 0 -11.501 -9.357 -20.857 -20.859 -20.857 c -11.501 0 -20.857 9.356 -20.857 20.857 c 0 8.855 5.556 16.419 13.357 19.44 v 6.635 H 33.313 c -4.143 0 -7.5 3.358 -7.5 7.5 c 0 4.142 3.357 7.5 7.5 7.5 h 3.391 l -24.451 48.9 H 7.5 c -4.143 0 -7.5 3.358 -7.5 7.5 c 0 26.929 21.908 48.837 48.838 48.837 c 26.929 0 48.836 -21.908 48.836 -48.837 c 0 -4.142 -3.357 -7.5 -7.5 -7.5 h -4.752 l -24.449 -48.9 h 43.926 v 101.403 H 81.08 c -4.143 0 -7.5 3.358 -7.5 7.5 c 0 4.142 3.357 7.5 7.5 7.5 h 63.555 c 4.143 0 7.5 -3.358 7.5 -7.5 c 0 -4.142 -3.357 -7.5 -7.5 -7.5 h -24.736 V 76.081 h 44.379 l -24.449 48.9 h -4.752 c -4.143 0 -7.5 3.358 -7.5 7.5 c 0 26.929 21.907 48.837 48.836 48.837 c 26.93 0 48.838 -21.908 48.838 -48.837 C 225.25 128.339 221.893 124.981 217.75 124.981 z x M 112.398 29.148 c 3.23 0 5.859 2.628 5.859 5.858 c 0 3.23 -2.629 5.857 -5.859 5.857 c -3.229 0 -5.857 -2.627 -5.857 -5.857 C 106.541 31.776 109.169 29.148 112.398 29.148 z x M 48.838 166.318 c -16.081 0 -29.578 -11.277 -33 -26.337 h 1.018 c 0.008 0 0.017 0.001 0.025 0.001 c 0.007 0 0.014 -0.001 0.021 -0.001 h 63.869 c 0.008 0 0.015 0.001 0.021 0.001 c 0.009 0 0.018 -0.001 0.025 -0.001 h 1.018 C 78.415 155.042 64.918 166.318 48.838 166.318 z x M 29.021 124.981 l 19.816 -39.63 l 19.814 39.63 H 29.021 z x M 176.412 85.351 l 19.816 39.63 h -39.631 L 176.412 85.351 z x M 176.412 166.318 c -16.08 0 -29.577 -11.277 -32.998 -26.337 h 1.018 c 0.008 0 0.017 0.001 0.025 0.001 c 0.007 0 0.014 -0.001 0.021 -0.001 h 63.869 c 0.008 0 0.015 0.001 0.021 0.001 c 0.009 0 0.018 -0.001 0.025 -0.001 h 1.018 C 205.99 155.042 192.493 166.318 176.412 166.318 Z',
                '0 0 225.25 225.25'
            }
        );

        svgs.add(
            new List<String>{
                '[c] Medal',
                'M223.7 130.8L149.1 7.77C147.1 2.949 141.9 0 136.3 0H16.03c-12.95 0-20.53 14.58-13.1 25.18l111.3 158.9C143.9 156.4 181.7 137.3 223.7 130.8z x M256 160c-97.25 0-176 78.75-176 176S158.8 512 256 512s176-78.75 176-176S353.3 160 256 160z x M348.5 317.3l-37.88 37l8.875 52.25c1.625 9.25-8.25 16.5-16.63 12l-46.88-24.62L209.1 418.5c-8.375 4.5-18.25-2.75-16.63-12l8.875-52.25l-37.88-37C156.6 310.6 160.5 299 169.9 297.6l52.38-7.625L245.7 242.5c2-4.25 6.125-6.375 10.25-6.375S264.2 238.3 266.2 242.5l23.5 47.5l52.38 7.625C351.6 299 355.4 310.6 348.5 317.3z x M495.1 0H375.7c-5.621 0-10.83 2.949-13.72 7.77l-73.76 122.1c42 6.5 79.88 25.62 109.5 53.38l111.3-158.9C516.5 14.58 508.9 0 495.1 0z',
                '0 0 512 512'
            }
        );

        svgs.add(
            new List<String>{
                '[c] Crosshairs',
                'M224 256C224 238.3 238.3 224 256 224C273.7 224 288 238.3 288 256C288 273.7 273.7 288 256 288C238.3 288 224 273.7 224 256z x M256 0C273.7 0 288 14.33 288 32V42.35C381.7 56.27 455.7 130.3 469.6 224H480C497.7 224 512 238.3 512 256C512 273.7 497.7 288 480 288H469.6C455.7 381.7 381.7 455.7 288 469.6V480C288 497.7 273.7 512 256 512C238.3 512 224 497.7 224 480V469.6C130.3 455.7 56.27 381.7 42.35 288H32C14.33 288 0 273.7 0 256C0 238.3 14.33 224 32 224H42.35C56.27 130.3 130.3 56.27 224 42.35V32C224 14.33 238.3 0 256 0V0z x M224 404.6V384C224 366.3 238.3 352 256 352C273.7 352 288 366.3 288 384V404.6C346.3 392.1 392.1 346.3 404.6 288H384C366.3 288 352 273.7 352 256C352 238.3 366.3 224 384 224H404.6C392.1 165.7 346.3 119.9 288 107.4V128C288 145.7 273.7 160 256 160C238.3 160 224 145.7 224 128V107.4C165.7 119.9 119.9 165.7 107.4 224H128C145.7 224 160 238.3 160 256C160 273.7 145.7 288 128 288H107.4C119.9 346.3 165.7 392.1 224 404.6z',
                '0 0 512 512'
            }
        );

        svgs.add(
            new List<String>{
                '[c] Observation Component',
                'M23.08 32.69h.35l20.55-3v29.12a.82.82 0 00.87.87h3.48a.82.82 0 00.87-.87V28.86l21.25-3.14a2.71 2.71 0 002.26-3 2.63 2.63 0 00-3-2.18l-17.11 2.4a8.48 8.48 0 00-6.1-2.53A8.8 8.8 0 0038.84 25l-16.2 2.43a2.63 2.63 0 00.44 5.23z M72.1 52.63a2.52 2.52 0 00.35-2.7l-6.88-16.54a2.67 2.67 0 00-4.87 0l-7 16.54a2.71 2.71 0 00.17 2.44c.16.23 2.84 4.34 7.25 5.28a14.42 14.42 0 018.5-2.73h.25a20.29 20.29 0 002.23-2.29z x M59.39 50.1l3.74-9 3.75 9z x M39 57.85a2.52 2.52 0 00.35-2.7l-7-16.54a2.47 2.47 0 00-2.3-1.61 2.67 2.67 0 00-2.44 1.57l-7 16.54a2.68 2.68 0 00.18 2.44c.17.26 3.57 5.49 9.05 5.49 3.25.04 6.39-1.7 9.16-5.19z x M-12.7-2.52l3.75-9 3.74 9z x M55.13 69.44a14.43 14.43 0 01.25-2.65 21.85 21.85 0 00-8.79-1.88 21 21 0 00-13.32 4.7 1.84 1.84 0 00-.61 1.31V71a1.74 1.74 0 001.74 1.74h21.12a14.33 14.33 0 01-.39-3.3z x M69.62 79.56a10.2 10.2 0 1110.21-10.19 10.16 10.16 0 01-10.21 10.19z x M.91-12.69a1 1 0 00-.7.21c-.56.38-1.12.75-1.67 1.16a3.54 3.54 0 00-.53.56.27.27 0 000 .35.3.3 0 00.34.09c.14 0 .27-.1.4-.15a2.43 2.43 0 01.37-.16c.19-.06.28 0 .28.21a2.17 2.17 0 010 .25c-.39 1.61-.78 3.21-1.18 4.82a.89.89 0 00.45 1.06 1.15 1.15 0 001.16-.1c.54-.35 1.07-.71 1.58-1.11a5.52 5.52 0 00.72-.73.22.22 0 000-.28.27.27 0 00-.3-.11l-.38.14-.44.2c-.17.06-.26 0-.25-.19a2.63 2.63 0 01.06-.39c.37-1.5.73-3 1.1-4.51a1 1 0 00-1.01-1.32z x M1.08-2.09a1.55 1.55 0 00-1.78-1.47 1.36 1.36 0 00-1.08 2 1.53 1.53 0 001.7.89 1.48 1.48 0 001.16-1.42z',
                '0 0 100 100'
            }
        );

        svgs.add(
            new List<String>{
                '[c] File Signature',
                'M292.7 342.3C289.7 345.3 288 349.4 288 353.7V416h62.34c4.264 0 8.35-1.703 11.35-4.727l156.9-158l-67.88-67.88L292.7 342.3z x M568.5 167.4L536.6 135.5c-9.875-10-26-10-36 0l-27.25 27.25l67.88 67.88l27.25-27.25C578.5 193.4 578.5 177.3 568.5 167.4z x M256 0v128h128L256 0z x M256 448c-16.07-.2852-30.62-9.359-37.88-23.88c-2.875-5.875-8-6.5-10.12-6.5s-7.25 .625-10 6.125l-7.749 15.38C187.6 444.6 181.1 448 176 448H174.9c-6.5-.5-12-4.75-14-11L144 386.6L133.4 418.5C127.5 436.1 111 448 92.45 448H80C71.13 448 64 440.9 64 432S71.13 416 80 416h12.4c4.875 0 9.102-3.125 10.6-7.625l18.25-54.63C124.5 343.9 133.6 337.3 144 337.3s19.5 6.625 22.75 16.5l13.88 41.63c19.75-16.25 54.13-9.75 66 14.12C248.5 413.2 252.2 415.6 256 415.9V347c0-8.523 3.402-16.7 9.451-22.71L384 206.5V160H256c-17.67 0-32-14.33-32-32L224 0H48C21.49 0 0 21.49 0 48v416C0 490.5 21.49 512 48 512h288c26.51 0 48-21.49 48-48V448H256z',
                '0 0 576 512'
            }
        );

        svgs.add(
            new List<String>{
                '[c] Hand Shake',
                'M334.6 217.4l-30 27.49C264 282.1 217.8 256.8 202.9 240.6C176 211.2 178.1 165.7 207.3 138.9L289.1 64H282.5C224.7 64 169.1 86.95 128.2 127.8L32 128.1c-17.6 0-32 14.39-32 31.98v159.8c0 17.59 14.4 32.04 31.1 32.04l114.3-.0604l90.5 81.82c27.5 22.37 67.75 18.11 90-9.255l18.12 15.25c15.88 12.1 39.38 10.5 52.38-5.369l31.38-38.6l5.374 4.498c13.75 11 33.88 9.002 45-4.748l9.576-11.83c11.08-13.7 8.979-33.75-4.701-44.86L334.6 217.4z x M608 128.1l-96-.1257c-40.98-40.96-96.56-63.88-154.5-63.88L348.9 64c-8 0-15.62 3.197-21.62 8.568L229 162.3C228.9 162.5 228.8 162.7 228.8 162.7C212 178.5 212.4 203.3 226.6 218.7c9.625 10.5 35 21.62 56.13 2.75c0-.125 .25-.125 .375-.25l80-73.1c6.5-5.871 16.62-5.496 22.62 1s5.5 16.62-1 22.62l-26.12 23.87l145.6 118.1c12.12 9.992 19.5 23.49 22.12 37.98L608 351.7c17.6 0 32-14.38 32-31.98V160.1C640 142.4 625.7 128.1 608 128.1z',
                '0 0 640 512'
            }
        );

        svgs.add(
            new List<String>{
                '[c] Hand Shake Slash',
                'M358.6 195.6l145.6 118.1c12.12 9.992 19.5 23.49 22.12 37.98h81.62c17.6 0 31.1-14.39 31.1-31.99V159.1c0-17.67-14.33-31.99-31.1-31.99h-95.1c-40.98-40.96-96.56-63.98-154.5-63.98h-8.613c-7.1 0-15.63 3.002-21.63 8.373l-93.44 85.57L208.3 137.9L289.1 64.01L282.5 64c-43.48 0-85.19 13.66-120.8 37.44l-122.9-96.33C34.41 1.672 29.19 0 24.03 0c-7.125 0-14.19 3.156-18.91 9.187c-8.187 10.44-6.375 25.53 4.062 33.7L601.2 506.9c10.5 8.203 25.56 6.328 33.69-4.078c8.187-10.44 6.375-25.53-4.062-33.7l-135.5-106.2c-.1719-9.086-3.789-18.03-11.39-24.2l-149.2-121.2l-11.47 10.51L297.6 207.1l65.51-59.85c6.5-5.871 16.62-5.496 22.62 .1c5.1 6.496 5.5 16.62-.1 22.62L358.6 195.6z x M32 127.1c-17.6 0-31.1 14.4-31.1 31.99v159.8c0 17.59 14.4 32.06 31.1 32.06l114.2-.0712l90.5 81.85c27.5 22.37 67.75 18.12 89.1-9.25l18.12 15.25c15.87 12.1 39.37 10.5 52.37-5.371l13.02-16.03L39.93 127.1L32 127.1z',
                '0 0 640 512'
            }
        );

        svgs.add(
            new List<String>{
                '[c] Buyer Group',
                'M37.3,43.1c-1.5-2.4-2.4-5.2-2.4-8.3c0-5.2,2.2-9.6,5.7-12.2c-1.3-2.2-3.5-3.6-6.6-3.6 c-5.1,0-7.9,4.1-7.9,8.8c0,2.6,0.9,4.7,2.6,6.3c1,0.9,1.8,2,1.8,3.3c0,1.2-0.4,2.3-3.3,3.5c-4.1,1.9-7.9,4.2-8,8.1 c0,2.6,1.7,4.4,4.1,4.4h3.8c0.6,0,1.2-0.4,1.5-0.9c1.9-3.3,5.3-5.5,8.2-6.9C37.5,45.1,37.9,43.9,37.3,43.1z x M58.4,66.4h13.3c0.4,0,0.8-0.3,0.8-0.7l2.4-8.6c0.2-0.6-0.3-1.1-0.8-1.1H60h-6.4l-0.3-1.3 c-0.2-0.6-0.7-1-1.3-1h-2.2c-0.7,0-1.4,0.6-1.4,1.3c-0.1,0.8,0.6,1.4,1.3,1.4H51l1.2,4l0,0l3,10.3c0.2,0.6,0.7,1,1.3,1h15.6 c0.7,0,1.4-0.6,1.4-1.3c0.1-0.8-0.6-1.4-1.3-1.4H58.4c-0.6,0-1.1-0.4-1.3-0.9V68C56.9,67.2,57.5,66.4,58.4,66.4z x M48.4,61.6l-0.4-1.5c-0.9-0.3-1.6-0.8-2.2-1.5c-0.9-1.1-1.4-2.4-1.3-3.8c0.1-2.8,2.6-5,5.4-5H52 c1.8,0,3.4,0.9,4.4,2.3H60h2.1c-1.6-1.1-3.5-2-5.4-2.8c-3.2-1.3-3.6-2.6-3.6-3.9c0-1.3,0.9-2.6,1.9-3.6c1.9-1.7,2.9-4.1,2.9-7 c0-5.2-3.2-9.7-8.8-9.7s-8.8,4.5-8.8,9.7c0,2.8,1.1,5.2,2.9,7c1.1,1,1.9,2.3,1.9,3.6c0,1.3-0.5,2.6-3.6,3.9 c-4.8,1.9-9.2,4.2-9.3,8.5c0,2.8,2,5.3,4.7,5.3h11.8L48.4,61.6z x M63.1,34.8c0,3.1-0.8,5.9-2.4,8.3c-0.6,0.9-0.3,2,0.7,2.6c2.8,1.3,6,3.3,7.9,6.4h4.8c1,0,1.9,0.3,2.7,0.9 c1.3-0.7,2.1-2.1,2.1-3.9c-0.1-3.9-3.9-6.3-8-8.2c-2.9-1.2-3.3-2.4-3.3-3.5c0-1.2,0.8-2.4,1.8-3.3c1.7-1.6,2.6-3.7,2.6-6.3 c0-4.8-2.8-8.8-7.9-8.8c-3.1,0-5.3,1.4-6.6,3.6C60.9,25.2,63.1,29.5,63.1,34.8z',
                '0 0 100 100'
            }
        );

        List<RM_Svg__c> svgList = new List<RM_Svg__c>();

        for (List<String> svg : svgs) {
            String viewBox = (svg.size() == 3) ? svg[2] : '0 0 52 52';
            svgList.add(
                new RM_Svg__c(
                    Name = svg[0],
                    Label__c = svg[0],
                    Fill__c = '#666666',
                    Geometry_String__c = svg[1],
                    View_Box__c = viewBox
                )
            );
        }

        this.objectsToInsert.addAll(svgList);
        this.schemasToInsert.add(RM_Svg__c.getSObjectType());
    }

    private void createDefaultInfluenceSupportMatrix() {
        if (
            !Schema.sObjectType.pq_Influence_And_Support_Matrix__c.isCreateable() ||
            !Schema.sObjectType.pq_Influence_And_Support_Matrix__c.fields.Name.isUpdateable() ||
            !Schema.sObjectType.pq_Influence_And_Support_Matrix__c.fields.Is_Default__c.isUpdateable()
        ) {
            return;
        }

        List<pq_Influence__c> infList = createDefaultInfluences();
        List<pq_Support__c> suppList = createDefaultSupports();
        createMatrixWithAssociations(infList, suppList);
        updateMapMembersInfleunceSupport(infList, suppList);
    }

    private List<pq_Influence__c> createDefaultInfluences() {
        // CREATE INFLUENCE VALUES
        List<pq_Influence__c> infList = new List<pq_Influence__c>();
        Schema.DescribeFieldResult influenceFieldResult = SObjectType.Key_Stakeholder__c.fields.Influence__c;
        for (Schema.PicklistEntry pickListEntry : influenceFieldResult.getPicklistValues()) {
            infList.add(new pq_Influence__c(Name = pickListEntry.getValue(), Label__c = pickListEntry.getLabel()));
        }

        if (infList.size() > 0) {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new List<Schema.SObjectType>{ pq_Influence__c.SObjectType }
            );

            uow.registerNew(infList);
            uow.commitWork();
        }

        return infList;
    }

    private List<pq_Support__c> createDefaultSupports() {
        // GET SUPPORT COLORS FOR SUPPORT
        Crush_Settings_Obj__c orgSettings = getOrgSettingsAndCreateIfNeeded();
        Map<String, String> colorMap = new Map<String, String>();
        if (String.isBlank(orgSettings.Support_Colors_Long__c)) {
            colorMap.put('Champion', '#97D700');
            colorMap.put('Floater', '#E5E1E6');
            colorMap.put('Supporter', '#FFC741');
            colorMap.put('Blocker', '#FF0000');
        } else {
            colorMap = UtilityForString.parseNameValueStringToMap(orgSettings.Support_Colors_Long__c);
        }

        // CREATE SUPPORT VALUES
        List<pq_Support__c> suppList = new List<pq_Support__c>();
        Schema.DescribeFieldResult supportFieldResult = SObjectType.Key_Stakeholder__c.fields.Support__c;
        for (Schema.PicklistEntry pickListEntry : supportFieldResult.getPicklistValues()) {
            String col = colorMap.containsKey(pickListEntry.getValue())
                ? colorMap.get(pickListEntry.getValue())
                : '#CCCCCC';
            suppList.add(
                new pq_Support__c(Name = pickListEntry.getValue(), Label__c = pickListEntry.getLabel(), Color__c = col)
            );
        }

        if (suppList.size() > 0) {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new List<Schema.SObjectType>{ pq_Support__c.SObjectType }
            );

            uow.registerNew(suppList);
            uow.commitWork();
        }

        return suppList;
    }

    private void updateWhiteSpaceHighlights() {
        if (
            !Schema.sObjectType.WS_Highlight__c.isQueryable() ||
            !Schema.sObjectType.WS_Highlight__c.fields.Apply_To_All_Cross_Sell_Maps__c.isUpdateable()
        ) {
            return;
        }
        List<WS_Highlight__c> highlights = [
            SELECT Id, Color__c, Label__c, Apply_To_All_Cross_Sell_Maps__c
            FROM WS_Highlight__c
            WHERE Apply_To_All_Cross_Sell_Maps__c != TRUE
        ];

        for (WS_Highlight__c highlight : highlights) {
            highlight.Apply_To_All_Cross_Sell_Maps__c = true;
        }

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ WS_Highlight__c.SObjectType }
        );

        uow.registerDirty(highlights);
        uow.commitWork();
    }

    private void updatePlanOverviews() {
        if (
            !Schema.sObjectType.Account_Plan__c.isQueryable() ||
            !Schema.sObjectType.Account_Plan__c.fields.Plan_Overview_Title__c.IsAccessible() ||
            !Schema.sObjectType.Account_Plan__c.fields.Plan_Overview__c.IsAccessible() ||
            !Schema.sObjectType.pq_CRUSH_Plan_Overview__c.isCreateable()
        ) {
            return;
        }

        List<Account_Plan__c> accountPlans = [
            SELECT Id, Plan_Overview_Title__c, Plan_Overview__c
            FROM Account_Plan__c
            WHERE ownerId != NULL
        ];
        List<pq_CRUSH_Plan_Overview__c> overviews = new List<pq_CRUSH_Plan_Overview__c>();
        for (Account_Plan__c accountPlan : accountPlans) {
            overviews.add(
                //Don't need to worry about title length for name field since the original field can only be 80 characters
                new pq_CRUSH_Plan_Overview__c(
                    name = accountPlan.Plan_Overview_Title__c,
                    Account_Plan__c = accountPlan.Id,
                    Title__c = accountPlan.Plan_Overview_Title__c,
                    Description__c = accountPlan.Plan_Overview__c,
                    Background_Color__c = '#cccccc'
                )
            );
        }

        if (overviews.size() > 0) {
            this.objectsToInsert.addAll(overviews);
            this.schemasToInsert.add(pq_CRUSH_Plan_Overview__c.getSObjectType());
        }
    }

    private void createMatrixWithAssociations(List<pq_Influence__c> infList, List<pq_Support__c> suppList) {
        pq_Influence_And_Support_Matrix__c defaultMatrix = new pq_Influence_And_Support_Matrix__c(
            Name = 'default',
            Is_Default__c = true
        );
        if(Schema.sObjectType.pq_Influence_And_Support_Matrix__c.isCreateable() && Schema.sObjectType.pq_Influence_And_Support_Matrix__c.fields.Name.isCreateable() 
        && Schema.sObjectType.pq_Influence_And_Support_Matrix__c.fields.Is_Default__c.isCreateable()) {
            Database.insert(defaultMatrix,true,Accesslevel.USER_MODE);
        }
        
        List<pq_Influence_Matrix_Association__c> infMatrixAssocs = new List<pq_Influence_Matrix_Association__c>();
        Integer order = 0;
        for (pq_Influence__c inf : infList) {
            infMatrixAssocs.add(
                new pq_Influence_Matrix_Association__c(
                    Influence_And_Support_Matrix__c = defaultMatrix.Id,
                    Influence__c = inf.Id,
                    Order__c = order++
                )
            );
        }

        if (infMatrixAssocs.size() > 0) {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new List<Schema.SObjectType>{ pq_Influence_Matrix_Association__c.SObjectType }
            );

            uow.registerNew(infMatrixAssocs);
            uow.commitWork();
        }

        List<pq_Support_Matrix_Association__c> suppMatrixAssocs = new List<pq_Support_Matrix_Association__c>();
        order = 0;
        for (pq_Support__c sup : suppList) {
            suppMatrixAssocs.add(
                new pq_Support_Matrix_Association__c(
                    Influence_And_Support_Matrix__c = defaultMatrix.Id,
                    Support__c = sup.Id,
                    Order__c = order++
                )
            );
        }

        if (suppMatrixAssocs.size() > 0) {
            fflib_SObjectUnitOfWork uow2 = new fflib_SObjectUnitOfWork(
                new List<Schema.SObjectType>{ pq_Support_Matrix_Association__c.SObjectType }
            );

            uow2.registerNew(suppMatrixAssocs);
            uow2.commitWork();
        }
    }

    private void updateMapMembersInfleunceSupport(List<pq_Influence__c> infList, List<pq_Support__c> suppList) {
        Map<String, Id> influenceMap = new Map<String, Id>();
        for (pq_Influence__c inf : infList) {
            influenceMap.put(inf.Name, inf.Id);
        }

        Map<String, Id> supportMap = new Map<String, Id>();
        for (pq_Support__c supp : suppList) {
            supportMap.put(supp.Name, supp.Id);
        }

        Set<SObject> toUpdate = new Set<SObject>();
        List<Relationship_Map_Member__c> members = [
            SELECT Id, Influence__c, Support__c
            FROM Relationship_Map_Member__c
            WHERE Contact__c != NULL
        ];
        for (Relationship_Map_Member__c member : members) {
            if (influenceMap.containsKey(member.Influence__c)) {
                member.InfluenceId__c = influenceMap.get(member.Influence__c);
                toUpdate.add(member);
            }

            if (supportMap.containsKey(member.Support__c)) {
                member.SupportId__c = supportMap.get(member.Support__c);
                toUpdate.add(member);
            }
        }

        List<Key_Stakeholder__c> keystakeholders = [
            SELECT Id, Influence__c, Support__c
            FROM Key_Stakeholder__c
            WHERE Contact__c != NULL
        ];
        for (Key_Stakeholder__c keystakeholder : keystakeholders) {
            if (influenceMap.containsKey(keystakeholder.Influence__c)) {
                keystakeholder.InfluenceId__c = influenceMap.get(keystakeholder.Influence__c);
                toUpdate.add(keystakeholder);
            }

            if (supportMap.containsKey(keystakeholder.Support__c)) {
                keystakeholder.SupportId__c = supportMap.get(keystakeholder.Support__c);
                toUpdate.add(keystakeholder);
            }
        }

        if (toUpdate.size() > 0) {
            this.objectsToUpdate.addAll(toUpdate);
            this.schemasToUpdate.add(Key_Stakeholder__c.getSObjectType());
            this.schemasToUpdate.add(Relationship_Map_Member__c.getSObjectType());
        }
    }

    // Convert Key Stakeholders for Account Plans to use RM objects
    private void convertKSToRM() {
        if (!canExecuteUpdateOrgChartFields()) {
            return;
        }
        updateOrgChartFields();
        KSConversionBatch batch = new KSConversionBatch();
        Database.executeBatch(batch, 5);
    }

    // Update OrgChartFields
    private Boolean canExecuteUpdateOrgChartFields() {
        if (
            !Schema.sObjectType.Org_Chart_Field__c.isQueryable() ||
            !Schema.sObjectType.Org_Chart_Field__c.fields.ObjectName__c.IsAccessible() ||
            !Schema.sObjectType.Org_Chart_Field__c.fields.ObjectName__c.IsUpdateable()
        ) {
            return false;
        }

        return true;
    }
    private void updateOrgChartFields() {
        List<Org_Chart_Field__c> updateItems = new List<Org_Chart_Field__c>();
        for (Org_Chart_Field__c item : [
            SELECT Id, ObjectName__c
            FROM Org_Chart_Field__c
            WHERE ObjectName__c = 'pqcrush__Key_Stakeholder__c'
        ]) {
            item.ObjectName__c = 'pqcrush__Relationship_Map_Member__c';
            updateItems.add(item);
        }

        if (updateItems.size() > 0) {
            this.objectsToUpdate.addAll(updateItems);
            this.schemasToUpdate.add(Org_Chart_Field__c.getSObjectType());
        }
    }

    // HELPER METHODS
    private List<SObject> getUpdatedPicklistHeaders(Mapping__c mapping, List<SObject> headers) {
        Schema.DescribeFieldResult describeField = UTIL_Describe.getFieldDescribe(
            mapping.ObjectType__c,
            mapping.ValueField__c
        );
        List<Schema.PicklistEntry> picklistEntries = describeField.getPicklistValues();
        Map<String, String> picklistLabelValueMap = new Map<String, String>();
        for (Schema.PicklistEntry entry : picklistEntries) {
            picklistLabelValueMap.put(entry.getLabel(), entry.getValue());
        }

        List<SObject> headersToUpdate = new List<SObject>();
        for (SObject header : headers) {
            String relatedObjectId = (String) header.get('Related_Object_Id__c');
            String name = (String) header.get('Name');
            if (String.isBlank(relatedObjectId) && picklistLabelValueMap.containsKey(name)) {
                header.put('Related_Object_Id__c', picklistLabelValueMap.get(name));
                headersToUpdate.add(header);
            }
        }
        return headersToUpdate;
    }

    private CRUSH_Settings_Obj__c buildResult(List<Crush_Settings_Obj__c> settings) {
        if (settings.size() == 0) {
            return null;
        } else {
            return settings[0];
        }
    }

    public class PostInstallException extends Exception {
    }
}