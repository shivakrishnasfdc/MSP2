@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class RMChartSettingController {
    @AuraEnabled
    public static UserRecordAccess getRelationshipMapAccessRecordForObject(Id objectId) {
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObjectCreateIfNeeded(objectId);

        List<UserRecordAccess> accessList = UserRecordAccessSelector.newInstance()
            .selectByRecordId(new Set<Id>{ setting.Id });

        if (accessList == null || accessList.size() <= 0) {
            return null;
        }

        return accessList[0];
    }

    @AuraEnabled
    public static RMChartSettingsWrapper getRelationshipMapSettingForObject(Id objectId) {
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(objectId);

        RM_Org_Setting__c orgSetting = RMOrgSettingService.getRMOrgSetting(objectId);

        RMChartSettingsWrapper wrapper = new RMChartSettingsWrapper(setting, orgSetting);

        return wrapper;
    }

    @AuraEnabled
    public static void updateAutoLayout(Id recordId, Boolean autoLayout) {
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObjectCreateIfNeeded(recordId);
        setting.Auto_Layout__c = autoLayout;
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(setting);
        uow.commitWork();
    }

    @AuraEnabled
    public static void updateReadOnly(Id recordId, Boolean readOnly) {
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObjectCreateIfNeeded(recordId);
        setting.Read_Only__c = readOnly;
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(setting);
        uow.commitWork();
    }

    @AuraEnabled
    public static void updateCardStyle(Id recordId, String cardStyle) {
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObjectCreateIfNeeded(recordId);
        setting.Card_Style__c = cardStyle;
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(setting);
        uow.commitWork();
    }
}