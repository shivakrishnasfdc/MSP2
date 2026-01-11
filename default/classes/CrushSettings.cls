@SuppressWarnings('PMD.ExcessivePublicCount,PMD.TooManyFields')
public class CrushSettings {
    private static Map<String, String> labelsForNotifications = new Map<String, String>{
        'Goal_Updated__c' => Label.Goal_Updated,
        'Key_Date_Updated__c' => Label.Key_Dates_Updated,
        'Key_Stakeholder_Updated__c' => Label.Key_Stakeholders_Updated,
        'Objectives_Updated__c' => Label.Objectives_Updated,
        'Opportunities_Added__c' => Label.Opportunities_Updated,
        'Plan_Overview_Updated__c' => Label.Plan_Overview_Updated,
        'Status_Updated__c' => Label.Plan_Status_Updated,
        'SWOT_Analysis_Updated__c' => Label.SWOT_Analysis_Updated,
        'Team_Member_Added_Removed__c' => Label.Team_Members_Added_Or_Removed,
        'Team_Member_Permission_Updated__c' => Label.Team_Member_Roles_Updated
    };

    @AuraEnabled
    public Id id;

    @AuraEnabled
    public String type;

    @AuraEnabled
    public String user;

    @AuraEnabled
    public String accountPlanTransferUser;

    @AuraEnabled
    public String accountPlanTransfer;

    @AuraEnabled
    public Integer contactsAncestryLevels;

    @AuraEnabled
    public Boolean enableNotifications;

    @AuraEnabled
    public List<NotificationSetting> notifications;

    @AuraEnabled
    public Boolean useAccountTeamPermissions;

    @AuraEnabled
    public Boolean canCreateObjectsInCrossSell;

    @AuraEnabled
    public Boolean useDefaultAPScoring;

    @AuraEnabled
    public Boolean usePercentageAPScoring;

    @AuraEnabled
    public Boolean allowAddTaskFromObjectiveComponent;

    @AuraEnabled
    public Boolean allowTasksBasedObjStageFromObjectiveComponent;

    @AuraEnabled
    public Boolean useSystemTaskModalFromObjectiveComponent;

    @AuraEnabled
    public String crossSellObjectFilterString;

    @AuraEnabled
    public Boolean disableObjectComponentSortButton;

    private String orgChartDefaultFields;

    private String relationshipMapDefaultFields;

    public CrushSettings(CRUSH_Settings_Obj__c settings) {
        this.id = settings.Id;
        this.type = settings.Type__c;
        this.user = settings.User__c;
        this.accountPlanTransferUser = settings.Account_Plan_Transfer_User__c;
        this.accountPlanTransfer = settings.Account_Plan_Transfer__c;
        this.contactsAncestryLevels = (Integer) settings.Contacts_Ancestry_Levels__c;
        this.enableNotifications = settings.Enable_Notifications__c;
        this.orgChartDefaultFields = settings.Org_Chart_Default_Fields__c;
        this.relationshipMapDefaultFields = settings.Relationship_Map_Default_Fields__c;
        this.canCreateObjectsInCrossSell = settings.Can_Create_Objects_In_Cross_Sell__c;
        this.useDefaultAPScoring = settings.Use_Default_Account_Plan_Score__c;
        this.usePercentageAPScoring = settings.Use_Percentage_Account_Plan_Score__c;
        this.allowAddTaskFromObjectiveComponent = settings.Allow_Add_Tasks_From_Objective_Component__c;
        this.allowTasksBasedObjStageFromObjectiveComponent = settings.Enable_Objective_Stage_Based_On_Tasks__c;
        this.useSystemTaskModalFromObjectiveComponent = settings.Use_System_Create_Task_Modal__c;
        this.crossSellObjectFilterString = settings.WS_Object_Filter__c;
        this.disableObjectComponentSortButton = settings.Disabled_Objective_Sort_Button__c;
        this.notifications = addNotificationSettings(settings);
        if (AccountTeamService.areAccountTeamsEnabled()) {
            this.useAccountTeamPermissions = settings.Use_Account_Team_Permissions__c;
        }
    }

    public CrushSettings(CRUSH_Settings__c settings) {
        this.id = null;
        this.type = 'Org';
        this.user = null;
        this.accountPlanTransferUser = settings.Account_Plan_Transfer_User__c;
        this.accountPlanTransfer = settings.Account_Plan_Transfer__c;
        this.contactsAncestryLevels = (Integer) settings.Contacts_Ancestry_Levels__c;
        this.enableNotifications = settings.Enable_Notifications__c;
        this.orgChartDefaultFields = settings.Org_Chart_Default_Fields__c;
        this.notifications = addNotificationSettings(settings);
    }

    public CRUSH_Settings_Obj__c toSObject() {
        CRUSH_Settings_Obj__c settings = new CRUSH_Settings_Obj__c();

        settings.Id = this.id;
        settings.Type__c = this.type;
        settings.User__c = this.user;
        settings.Account_Plan_Transfer_User__c = this.accountPlanTransferUser;
        settings.Account_Plan_Transfer__c = this.accountPlanTransfer;
        settings.Contacts_Ancestry_Levels__c = this.contactsAncestryLevels;
        settings.Org_Chart_Default_Fields__c = this.orgChartDefaultFields;
        settings.Enable_Notifications__c = this.enableNotifications;
        settings.WS_Object_Filter__c = this.crossSellObjectFilterString;
        for (NotificationSetting setting : this.notifications) {
            settings.put(setting.name, setting.enabled);
        }
        if (this.useAccountTeamPermissions != null) {
            settings.Use_Account_Team_Permissions__c = this.useAccountTeamPermissions;
        }

        return settings;
    }

    private static List<NotificationSetting> addNotificationSettings(SObject settings) {
        List<NotificationSetting> notificationSettings = new List<NotificationSetting>();
        for (String field : labelsForNotifications.keySet()) {
            NotificationSetting nSetting = new NotificationSetting(
                field,
                labelsForNotifications.get(field),
                (Boolean) settings.get(field)
            );
            notificationSettings.add(nSetting);
        }
        return notificationSettings;
    }

    public class NotificationSetting {
        @AuraEnabled
        public String name { get; set; }

        @AuraEnabled
        public String label { get; set; }

        @AuraEnabled
        public Boolean enabled { get; set; }

        public NotificationSetting(String name, String label, Boolean enabled) {
            this.name = name;
            this.label = label;
            this.enabled = enabled;
            if (enabled == null) {
                this.enabled = false;
            }
        }
    }
}