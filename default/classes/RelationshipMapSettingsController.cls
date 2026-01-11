public with sharing class RelationshipMapSettingsController {
    @AuraEnabled
    public static Boolean getAutoCreateMapFlag(String mapType) {
        Crush_Settings_Obj__c orgSettings = SettingService.getOrgSettingsAndCreateIfNeeded();
        if (mapType.toLowerCase() == 'keystakeholder') {
            return orgSettings.Auto_Create_Stakeholder_Maps__c;
        }
        return orgSettings.Auto_Create_Relationship_Maps__c;
    }

    @AuraEnabled
    public static void setAutoCreateMapFlag(Boolean value, String mapType) {
        CRUSH_Settings_Obj__c orgSettings = SettingService.getOrgSettingsAndCreateIfNeeded();
        if (mapType.toLowerCase() == 'keystakeholder') {
            orgSettings.Auto_Create_Stakeholder_Maps__c = value;
        } else {
            orgSettings.Auto_Create_Relationship_Maps__c = value;
        }
        SettingService.upsertSettings(orgSettings);
    }

    @AuraEnabled
    public static Map<String, Boolean> getTabVisibility(Id recordId) {
        if (recordId == null) {
            return new Map<String, Boolean>{ 'lead' => false, 'user' => false };
        }
        RM_Org_Setting__c settings = RMOrgSettingService.getRMOrgSetting(recordId);
        Boolean leadTab =
            Map_Member_Lead__c.sObjectType.getDescribe().isCreateable() &&
            (settings?.Lead_Tab__c == null || settings.Lead_Tab__c);
        Boolean userTab =
            Map_Member_User__c.sObjectType.getDescribe().isCreateable() &&
            (settings?.User_Tab__c == null || settings.User_Tab__c);
        Map<String, Boolean> result = new Map<String, Boolean>();
        result.put('lead', leadTab);
        result.put('user', userTab);
        return result;
    }

    @AuraEnabled
    public static RM_Org_Setting__c getRMOrgSettingForType(String type) {
        return RMOrgSettingService.getRMOrgSettingForType(type);
    }

    @AuraEnabled
    public static void updateEnableSuggestedContactsForRM(Id settingId, Boolean showSuggestedContacts) {
        RMOrgSettingService.updateEnableSuggestedContactsForRM(settingId, showSuggestedContacts);
    }

    @AuraEnabled
    public static void updateEnableSuggestedContactsForRMSettings(Id settingId, Boolean showSuggestedContacts) {
        RMOrgSettingService.updateEnableSuggestedContactsForRMSettings(settingId, showSuggestedContacts);
    }

    @AuraEnabled
    public static void updateRMOrgSettingOperator(Id rmOrgSettingId, String rmOrgSettingOperator) {
        RMOrgSettingService.updateRMOrgSettingOperator(rmOrgSettingId, rmOrgSettingOperator);
    }

    @AuraEnabled
    public static List<pq_Condition__c> getContactsConditions(Id settingId) {
        return PqConditionService.getPqConditions(settingId);
    }

    @AuraEnabled
    public static List<pq_Condition__c> insertContactsCondition(List<pq_Condition__c> conditions) {
        return PqConditionService.insertPqCondition(conditions);
    }

    @AuraEnabled
    public static void deleteContactsCondition(List<pq_Condition__c> conditions) {
        PqConditionService.deletePqCondition(conditions);
    }

    @AuraEnabled
    public static List<pq_Condition__c> updateContactsCondition(List<pq_Condition__c> conditions) {
        return PqConditionService.updatePqCondition(conditions);
    }
    @AuraEnabled
    public static void updateContactLimit(Id settingId, String contactLimitValue) {
        RMOrgSettingService.updateContactLimit(settingId, contactLimitValue);
    }
    @AuraEnabled
    public static void updateRMContactLimit(Id settingId, String contactLimitValue) {
        RMOrgSettingService.updateRMContactLimit(settingId, contactLimitValue);
    }

    public class SupportColorSettingObject {
        @AuraEnabled
        public String name;

        @AuraEnabled
        public String value;

        @AuraEnabled
        public String color;

        public supportColorSettingObject(String name, String label, String color) {
            this.name = name;
            this.value = label;
            this.color = color;
        }
    }
}