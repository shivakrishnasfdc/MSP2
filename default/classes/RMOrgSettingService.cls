public with sharing class RMOrgSettingService {
    @AuraEnabled
    public static RM_Org_Setting__c getRMOrgSetting(Id recordId) {
        return service().getRMOrgSetting(recordId);
    }

    @AuraEnabled
    public static RM_Org_Setting__c getRMOrgSettingForType(String type) {
        return service().getRMOrgSettingForType(type);
    }

    @AuraEnabled
    public static void setRMOrgSetting(RM_Org_Setting__c settings) {
        service().setRMOrgSetting(settings);
    }

    @AuraEnabled
    public static void setDefaultChartSetting(RM_Org_Setting__c settings) {
        service().setDefaultChartSetting(settings);
    }

    @AuraEnabled
    public static void setAdvancedOrgSetting(RM_Org_Setting__c settings) {
        service().setAdvancedOrgSetting(settings);
    }

    @AuraEnabled
    public static void setTabsSetting(
        String type,
        Boolean leadTab,
        Boolean userTab,
        Boolean createNewContact,
        Boolean showAutoManualToggle,
        Boolean enableContactMenu,
        Boolean enableMapMemberMenu,
        Boolean enableOmniViewerMenu,
        Boolean enableGroupSelectionMenu,
        Boolean showCloneButton,
        Boolean showSettingsButton
    ) {
        service()
            .setTabsSetting(
                type,
                leadTab,
                userTab,
                createNewContact,
                showAutoManualToggle,
                enableContactMenu,
                enableMapMemberMenu,
                enableOmniViewerMenu,
                enableGroupSelectionMenu,
                showCloneButton,
                showSettingsButton
            );
    }

    @AuraEnabled
    public static List<NameValuePair> getPickListValues(String fieldName) {
        return service().getPickListValues(fieldName);
    }

    public static void updateEnableSuggestedContactsForRM(Id settingId, Boolean showSuggestedContacts) {
        service().updateEnableSuggestedContactsForRM(settingId, showSuggestedContacts);
    }

    public static void updateEnableSuggestedContactsForRMSettings(Id settingId, Boolean showSuggestedContacts) {
        service().updateEnableSuggestedContactsForRMSettings(settingId, showSuggestedContacts);
    }

    public static void updateRMOrgSettingOperator(Id rmOrgSettingId, String rmOrgSettingOperator) {
        service().updateRMOrgSettingOperator(rmOrgSettingId, rmOrgSettingOperator);
    }
    public static void updateContactLimit(Id settingId, String contactLimitValue) {
        service().updateContactLimit(settingId, contactLimitValue);
    }

    public static void updateRMContactLimit(Id settingId, String contactLimitValue) {
        service().updateRMContactLimit(settingId, contactLimitValue);
    }

    private static RMOrgSettingServiceImpl service() {
        return (RMOrgSettingServiceImpl) Application.Service.newInstance(RMOrgSettingServiceImpl.class);
    }
}