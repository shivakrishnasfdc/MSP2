public with sharing class SettingServiceImpl {
    /**
     * caching of settings objects
     */
    private static final String ORG_SETTINGS_KEY = 'pqcrush.ORG_SETTINGS_KEY';
    private static final String USER_SETTINGS_KEY = 'pqcrush.USER_SETTINGS_KEY.';
    private static final Map<String, CRUSH_Settings_Obj__c> SETTINGS_CACHE = new Map<String, CRUSH_Settings_Obj__c>();

    /**
     * Retrieves the org level settings object for the Strategy app
     * @return The org level Crush settings object or null if it doesn't exist.
     *
     * IMPORTANT:
     * This should only be used by the post install script.
     * Everything else should use getOrgSettingsAndCreateIfNeeded()
     */
    public CRUSH_Settings_Obj__c getOrgSettings() {
        if (SETTINGS_CACHE.containsKey(ORG_SETTINGS_KEY)) {
            CRUSH_Settings_Obj__c cachedOrgSettings = SETTINGS_CACHE.get(ORG_SETTINGS_KEY);
            return cachedOrgSettings;
        }
        CRUSH_Settings_Obj__c orgSettings = buildResult(CrushSettingsObjSelector.newInstance().selectOrgSettingsObj());
        if (orgSettings != null) {
            SETTINGS_CACHE.put(ORG_SETTINGS_KEY, orgSettings);
        }
        return orgSettings;
    }

    /**
     * Retrieves the org level settings object for the Strategy app and creates it if it does not exist
     * @return The org level Crush settings object.
     */
    public CRUSH_Settings_Obj__c getOrgSettingsAndCreateIfNeeded() {
        Crush_Settings_Obj__c orgSettings = getOrgSettings();

        if (orgSettings == null) {
            // Instantiates a new crush settings object with default values and type set to org
            // Must instantiate this way to populate defaults before insert and avoid an extra fetch
            SObjectType crushSettingsObjType = Crush_Settings_Obj__c.sObjectType;
            orgSettings = (Crush_Settings_Obj__c) crushSettingsObjType.newSObject(null, true);
            orgSettings.Type__c = 'Org';
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
            uow.registerNew(orgSettings);
            SystemContext systemContext = new SystemContext();
            systemContext.commitWork(uow);
            SETTINGS_CACHE.put(ORG_SETTINGS_KEY, orgSettings);
        }

        return orgSettings;
    }

    /**
     * Retrieves the calling user level settings object for the Crush app and creates it if it does not exist
     * @return The user level Crush settings object.
     */
    public CRUSH_Settings_Obj__c getCurrentUserSettings() {
        Id currentUserId = UserInfo.getUserId();
        return getUserSettings(currentUserId);
    }

    /**
     * Retrieves a user level settings object for the Crush app and creates it if it does not exist
     * @return The user level Crush settings object.
     */
    public CRUSH_Settings_Obj__c getUserSettings(Id userId) {
        String cacheKey = USER_SETTINGS_KEY + userId;
        if (SETTINGS_CACHE.containsKey(cacheKey)) {
            CRUSH_Settings_Obj__c cachedOrgSettings = SETTINGS_CACHE.get(cacheKey);
            return cachedOrgSettings;
        }
        Crush_Settings_Obj__c userSettings = buildResult(
            CrushSettingsObjSelector.newInstance().selectUserSettingsObj(userId)
        );

        if (userSettings == null) {
            userSettings = getTempUserSettingsObject(userId);
        }

        SETTINGS_CACHE.put(cacheKey, userSettings);
        return userSettings;
    }

    public void updateCrossSellCreateObjectSettings(Boolean canCreateObjectsInCrossSell) {
        if (canCreateObjectsInCrossSell == null) {
            return;
        }

        Crush_Settings_Obj__c orgSettings = getOrgSettingsAndCreateIfNeeded();
        orgSettings.Can_Create_Objects_In_Cross_Sell__c = canCreateObjectsInCrossSell;
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerDirty(orgSettings);
        SystemContext systemContext = new SystemContext();
        systemContext.commitWork(uow);
    }

    public void updateUseDefaultAPScoringSettings(Boolean useDefaultAPScoring) {
        if (useDefaultAPScoring == null) {
            return;
        }

        Crush_Settings_Obj__c orgSettings = getOrgSettingsAndCreateIfNeeded();
        orgSettings.Use_Default_Account_Plan_Score__c = useDefaultAPScoring;
        if (useDefaultAPScoring) {
            orgSettings.Use_Percentage_Account_Plan_Score__c = false;
        } else {
            orgSettings.Use_Percentage_Account_Plan_Score__c = true;
        }
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerDirty(orgSettings);
        SystemContext systemContext = new SystemContext();
        systemContext.commitWork(uow);
    }

    public void updateUsePercentageAPScoringSettings(Boolean usePercentageAPScoring) {
        if (usePercentageAPScoring == null) {
            return;
        }

        Crush_Settings_Obj__c orgSettings = getOrgSettingsAndCreateIfNeeded();
        orgSettings.Use_Percentage_Account_Plan_Score__c = usePercentageAPScoring;
        if (usePercentageAPScoring) {
            orgSettings.Use_Default_Account_Plan_Score__c = false;
        } else {
            orgSettings.Use_Default_Account_Plan_Score__c = true;
        }
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerDirty(orgSettings);
        SystemContext systemContext = new SystemContext();
        systemContext.commitWork(uow);
    }

    public void updateAllowAddTaskFromObjectiveComponent(Boolean allowAddTask) {
        if (allowAddTask == null) {
            return;
        }

        Crush_Settings_Obj__c orgSettings = getOrgSettingsAndCreateIfNeeded();
        orgSettings.Allow_Add_Tasks_From_Objective_Component__c = allowAddTask;
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerDirty(orgSettings);
        SystemContext systemContext = new SystemContext();
        systemContext.commitWork(uow);
    }

    public void updateDisableObjectiveComponentSortButton(Boolean disableSortButton) {
        if (disableSortButton == null) {
            return;
        }

        Crush_Settings_Obj__c orgSettings = getOrgSettingsAndCreateIfNeeded();
        orgSettings.Disabled_Objective_Sort_Button__c = disableSortButton;
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerDirty(orgSettings);
        SystemContext systemContext = new SystemContext();
        systemContext.commitWork(uow);
    }

    public void updateAllowTasksBasedObjStageFromObjectiveComponent(Boolean allowTasksBasedObjStage) {
        if (allowTasksBasedObjStage == null) {
            return;
        }

        Crush_Settings_Obj__c orgSettings = getOrgSettingsAndCreateIfNeeded();
        orgSettings.Enable_Objective_Stage_Based_On_Tasks__c = allowTasksBasedObjStage;
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerDirty(orgSettings);
        SystemContext systemContext = new SystemContext();
        systemContext.commitWork(uow);
    }

    public void updateUseSystemTaskModalFromObjectiveComponent(Boolean useSystemModal) {
        if (useSystemModal == null) {
            return;
        }

        Crush_Settings_Obj__c orgSettings = getOrgSettingsAndCreateIfNeeded();
        orgSettings.Use_System_Create_Task_Modal__c = useSystemModal;
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerDirty(orgSettings);
        SystemContext systemContext = new SystemContext();
        systemContext.commitWork(uow);
    }

    public void updateWSFilterStringSetting(String filterString) {
        Crush_Settings_Obj__c orgSettings = getOrgSettingsAndCreateIfNeeded();
        orgSettings.WS_Object_Filter__c = filterString;
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerDirty(orgSettings);
        SystemContext systemContext = new SystemContext();
        systemContext.commitWork(uow);
    }

    public List<String> getObjectNameListFromFilterString(String filterString) {
        if (!String.isNotBlank(filterString)) {
            return new List<String>();
        }
        List<String> fullList = filterString.split('\n');
        List<String> trimmedList = new List<String>();
        for (String s : fullList) {
            if (String.isNotBlank(s)) {
                trimmedList.add(s.trim());
            }
        }
        trimmedList.sort();
        return trimmedList;
    }

    public String getFilterStringFromObjectNameList(List<String> objectNameList) {
        if (!(objectNameList?.size() > 0)) {
            return null;
        }
        List<String> trimmedList = new List<String>();
        for (String s : objectNameList) {
            if (String.isNotBlank(s)) {
                trimmedList.add(s.trim());
            }
        }
        if (trimmedList.size() == 0) {
            return null;
        }
        trimmedList.sort();
        return String.join(trimmedList, '\n');
    }

    public CRUSH_Settings_Obj__c upsertSettings(CRUSH_Settings_Obj__c settings) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        if (settings.id != null) {
            uow.registerDirty(settings);
        } else {
            uow.registerNew(settings);
        }
        SystemContext systemContext = new SystemContext();
        systemContext.commitWork(uow);

        if (settings.Type__c == 'Org') {
            SETTINGS_CACHE.remove(ORG_SETTINGS_KEY);
        } else {
            Id userId = settings.User__c;
            String cacheKey = USER_SETTINGS_KEY + userId;
            SETTINGS_CACHE.remove(cacheKey);
        }

        return settings;
    }

    public List<NameValuePair> getPickListValues(String fieldName) {
        List<NameValuePair> nvp = new List<NameValuePair>();
        Schema.SObjectType s = CRUSH_Settings_Obj__c.SObjectType;
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String, Schema.SObjectField> fields = r.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            nvp.add(new NameValuePair(pickListVal.getLabel(), pickListVal.getValue()));
        }
        return nvp;
    }

    /******************************
     *      PRIVATE METHODS
     ******************************/

    private CRUSH_Settings_Obj__c buildResult(List<Crush_Settings_Obj__c> settings) {
        if (settings.size() == 0) {
            return null;
        } else {
            return settings[0];
        }
    }

    private CRUSH_Settings_Obj__c getTempUserSettingsObject(Id userId) {
        Crush_Settings_Obj__c orgSettings = getOrgSettingsAndCreateIfNeeded();
        CRUSH_Settings_Obj__c userSettings = new Crush_Settings_Obj__c(Type__c = 'User', User__c = userId);

        for (Schema.SObjectField fldToken : userSettingsFields) {
            userSettings.put(fldToken, orgSettings.get(fldToken));
        }

        return userSettings;
    }

    private Set<Schema.SObjectField> userSettingsFields = new Set<Schema.SObjectField>{ //NOPMD
        Crush_Settings_Obj__c.Enable_Notifications__c,
        Crush_Settings_Obj__c.Goal_Updated__c,
        Crush_Settings_Obj__c.Key_Date_Updated__c,
        Crush_Settings_Obj__c.Key_Stakeholder_Updated__c,
        Crush_Settings_Obj__c.Objectives_Updated__c,
        Crush_Settings_Obj__c.Opportunities_Added__c,
        Crush_Settings_Obj__c.Plan_Overview_Updated__c,
        Crush_Settings_Obj__c.Status_Updated__c,
        Crush_Settings_Obj__c.SWOT_Analysis_Updated__c,
        Crush_Settings_Obj__c.Team_Member_Added_Removed__c,
        Crush_Settings_Obj__c.Team_Member_Permission_Updated__c
    };

    private without sharing class SystemContext {
        private void commitWork(fflib_ISObjectUnitOfWork uow) {
            uow.commitWork();
        }
    }
}