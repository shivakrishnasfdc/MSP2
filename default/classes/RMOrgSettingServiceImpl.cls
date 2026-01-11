public with sharing class RMOrgSettingServiceImpl {
    private static Map<String, RM_Org_Setting__c> settingsCache = new Map<String, RM_Org_Setting__c>();
    /******************************
     *      PUBLIC METHODS
     ******************************/

    public RM_Org_Setting__c getRMOrgSetting(Id recordId) {
        String type;
        if (recordId != null && RelationshipMapService.hasAccountPlanSetting(recordId)) {
            type = 'keystakeholder';
        } else if (recordId != null && OpportunityPlanService.hasOpportunityPlanSetting(recordId)) {
            type = 'om';
        } else if (recordID != null) {
            RM_Org_Setting__c rmOrgSettings = getRMOrgSettingForID(recordId);
            if (rmOrgSettings != null) {
                return rmOrgSettings;
            } else {
                type = 'rm';
            }
        } else {
            type = 'rm';
        }

        return getRMOrgSettingForType(type);
    }

    public RM_Org_Setting__c getRMOrgSettingForID(id recordId) {
        if (recordId == null) {
            return null;
        }

        List<RM_Org_Setting__c> settings = RMOrgSettingSelector.newInstance().selectById(new Set<Id>{ recordId });

        if (settings == null || settings.isempty()) {
            return null;
        } else {
            return settings[0];
        }
    }

    public RM_Org_Setting__c getRMOrgSettingForType(String type) {
        if (settingsCache.containsKey(type)) {
            return settingsCache.get(type);
        }

        List<RM_Org_Setting__c> settings = RMOrgSettingSelector.newInstance().selectByType(type);

        if (settings.size() < 1) {
            return createNewSetting(type);
        }

        if (settings[0].Lead_Tab__c == null) {
            settings[0].Lead_Tab__c = true;
        }

        if (settings[0].User_Tab__c == null) {
            settings[0].User_Tab__c = true;
        }

        if (settings[0].Show_Auto_Manual_Toggle__c == null) {
            settings[0].Show_Auto_Manual_Toggle__c = true;
        }

        settingsCache.put(type, settings[0]);

        return settings[0];
    }

    public void setRMOrgSetting(RM_Org_Setting__c settings) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        if (settings.id != null) {
            uow.registerDirty(settings);
        } else {
            uow.registerNew(settings);
        }

        uow.commitWork();
    }

    public void setAdvancedOrgSetting(RM_Org_Setting__c settings) {
        RM_Org_Setting__c rmSetting = getRMOrgSettingForType(settings.Type__c);

        rmSetting.Prolifiq_Extended_Tools_URL__c = settings.Prolifiq_Extended_Tools_URL__c;

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(rmSetting);
        uow.commitWork();
    }

    public void setDefaultChartSetting(RM_Org_Setting__c settings) {
        RM_Org_Setting__c rmSetting = getRMOrgSettingForType(settings.Type__c);
        rmSetting.Auto_Layout__c = settings.Auto_Layout__c;
        rmSetting.Enable_Drag_Select__c = settings.Enable_Drag_Select__c;
        rmSetting.Is_Group_Global_Scope__c = settings.Is_Group_Global_Scope__c;
        rmSetting.Is_Relationship_Line_Global_Scope__c = settings.Is_Relationship_Line_Global_Scope__c;
        rmSetting.Is_Badge_Global_Scope__c = settings.Is_Badge_Global_Scope__c;
        rmSetting.Is_Influence_Support_Global_Scope__c = settings.Is_Influence_Support_Global_Scope__c;
        rmSetting.Is_Reports_To_Global_Scope__c = settings.Is_Reports_To_Global_Scope__c;
        rmSetting.Show_Empty_Fields__c = settings.Show_Empty_Fields__c;
        rmSetting.Show_Overview__c = settings.Show_Overview__c;
        rmSetting.Show_Parents__c = settings.Show_Parents__c;
        rmSetting.Relationship_Line_Opacity__c = settings.Relationship_Line_Opacity__c;
        rmSetting.Reports_To_Line_Opacity__c = settings.Reports_To_Line_Opacity__c;
        rmSetting.Prolifiq_Extended_Tools_URL__c = settings.Prolifiq_Extended_Tools_URL__c;
        rmSetting.Card_Style__c = settings.Card_Style__c;
        rmSetting.Display_Style__c = settings.Display_Style__c;

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(rmSetting);
        uow.commitWork();
    }

    public void setTabsSetting(
        String type,
        Boolean leadTab,
        Boolean userTab,
        Boolean createNewContact,
        Boolean showAutoManualToggle,
        Boolean enableContactContextMenu,
        Boolean enableMapMemberContextMenu,
        Boolean enableOmniViewerContextMenu,
        Boolean enableGroupSelectionContextMenu,
        Boolean showCloneButton,
        Boolean showSettingsButton
    ) {
        RM_Org_Setting__c rmSetting = getRMOrgSettingForType(type);

        if (leadTab != null) {
            rmSetting.Lead_Tab__c = leadTab;
        }

        if (userTab != null) {
            rmSetting.User_Tab__c = userTab;
        }

        if (createNewContact != null) {
            rmSetting.Create_New_Contact__c = createNewContact;
        }
        if (createNewContact != null) {
            rmSetting.pqcrush__Create_New_Account__c = createNewContact;
        }

        if (showAutoManualToggle != null) {
            rmSetting.Show_Auto_Manual_Toggle__c = showAutoManualToggle;
        }

        if (enableContactContextMenu != null) {
            rmSetting.Enable_Contact_Context_Menu__c = enableContactContextMenu;
        }

        if (enableMapMemberContextMenu != null) {
            rmSetting.Enable_Map_Member_Context_Menu__c = enableMapMemberContextMenu;
        }

        if (enableOmniViewerContextMenu != null) {
            rmSetting.Enable_Omni_Viewer_Context_Menu__c = enableOmniViewerContextMenu;
        }

        if (enableGroupSelectionContextMenu != null) {
            rmSetting.Enable_Group_Selection_Context_Menu__c = enableGroupSelectionContextMenu;
        }

        if (showCloneButton != null) {
            rmSetting.Show_Clone_Relationship_Map__c = showCloneButton;
        }

        if (showSettingsButton != null) {
            rmSetting.Show_Chart_Settings__c = showSettingsButton;
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(rmSetting);
        uow.commitWork();
    }

    public List<NameValuePair> getPickListValues(String fieldName) {
        List<NameValuePair> nvp = new List<NameValuePair>();
        Schema.SObjectType s = RM_Org_Setting__c.SObjectType;
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String, Schema.SObjectField> fields = r.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            nvp.add(new NameValuePair(pickListVal.getLabel(), pickListVal.getValue()));
        }
        return nvp;
    }

    public void updateEnableSuggestedContactsForRM(Id settingId, Boolean showSuggestedContacts) {
        if (showSuggestedContacts == null) {
            return;
        }
        string type = 'keystakeholder';

        RM_Org_Setting__c orgSettings = getRMOrgSettingForType(type);
        orgSettings.Enable_Suggested_Contacts_For_RM__c = showSuggestedContacts;
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerDirty(orgSettings);
        SystemContext systemContext = new SystemContext();
        systemContext.commitWork(uow);
    }

    public void updateEnableSuggestedContactsForRMSettings(Id settingId, Boolean showSuggestedContacts) {
        if (showSuggestedContacts == null) {
            return;
        }

        RM_Org_Setting__c orgSettings = RMOrgSettingService.getRMOrgSetting(settingId);
        orgSettings.Enable_Sugg_Con_For_RMSettings__c = showSuggestedContacts;
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerDirty(orgSettings);
        SystemContext systemContext = new SystemContext();
        systemContext.commitWork(uow);
    }

    public void updateRMOrgSettingOperator(Id rmOrgSettingId, String rmOrgSettingOperator) {
        if (rmOrgSettingOperator == null) {
            return;
        }

        RM_Org_Setting__c orgSettings = RMOrgSettingService.getRMOrgSetting(rmOrgSettingId);
        orgSettings.Operator__c = rmOrgSettingOperator;
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerDirty(orgSettings);
        //suggest contact restricted
        uow.commitWork();
        //SystemContext systemContext = new SystemContext();
        //systemContext.commitWork(uow);
    }

    private RM_Org_Setting__c createNewSetting(String type) {
        RM_Org_Setting__c newSetting = new RM_Org_Setting__c(
            Type__c = type,
            Auto_Layout__c = true,
            Card_Style__c = 'Detail',
            Display_Style__c = 'Horizontal',
            Enable_Drag_Select__c = false,
            Lead_Tab__c = true,
            Is_Group_Global_Scope__c = false,
            Is_Relationship_Line_Global_Scope__c = false,
            Relationship_Line_Opacity__c = 100.0,
            Reports_To_Line_Opacity__c = 100.0,
            Prolifiq_Extended_Tools_URL__c = '',
            Show_Empty_Fields__c = false,
            Show_Overview__c = false,
            Show_Parents__c = true,
            User_Tab__c = true,
            Is_Influence_Support_Global_Scope__c = false,
            Is_Reports_To_Global_Scope__c = true,
            Show_Auto_Manual_Toggle__c = true,
            Enable_Contact_Context_Menu__c = true,
            Enable_Map_Member_Context_Menu__c = true,
            Enable_Omni_Viewer_Context_Menu__c = true,
            Enable_Group_Selection_Context_Menu__c = true
        );

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerNew(newSetting);
        new SystemContext().commitWork(uow);

        return newSetting;
    }

    public void updateContactLimit(Id settingId, String contactLimitValue) {
        if (contactLimitValue == null) {
            return;
        }
        string type = 'keystakeholder';

        RM_Org_Setting__c orgSettings = getRMOrgSettingForType(type);
        orgSettings.pqcrush__contact_limit__c = contactLimitValue;
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerDirty(orgSettings);
        SystemContext systemContext = new SystemContext();
        systemContext.commitWork(uow);
    }

    public void updateRMContactLimit(Id settingId, String contactLimitValue) {
        if (contactLimitValue == null) {
            return;
        }

        RM_Org_Setting__c orgSettings = RMOrgSettingService.getRMOrgSetting(settingId);
        orgSettings.pqcrush__rm_contact_limit__c = contactLimitValue;
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerDirty(orgSettings);
        SystemContext systemContext = new SystemContext();
        systemContext.commitWork(uow);
    }

    private without sharing class SystemContext {
        private void commitWork(fflib_ISObjectUnitOfWork uow) {
            uow.commitWork();
        }
    }
}