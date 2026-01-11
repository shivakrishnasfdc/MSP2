public with sharing class AccountPlanUserSettingController {
    @AuraEnabled
    public static pq_CRUSH_Account_Plan_User_Setting__c getSettings(Id accountPlanId) {
        List<pq_CRUSH_Account_Plan_User_Setting__c> settings = AccountPlanUserSettingSelector.newInstance()
            .selectByAccountPlans(new Set<Id>{ accountPlanId }, UserInfo.getUserId());

        if (settings.size() > 0) {
            return settings[0];
        }

        return AccountPlanUserSettingService.createNewSettings(accountPlanId);
    }

    @AuraEnabled
    public static void updateSettings(Id settingId, String chartType) {
        if (chartType != 'Pie' && chartType != 'Bar') {
            return;
        }

        List<pq_CRUSH_Account_Plan_User_Setting__c> settings = AccountPlanUserSettingSelector.newInstance()
            .selectById(new Set<Id>{ settingId });

        for (pq_CRUSH_Account_Plan_User_Setting__c setting : settings) {
            setting.Objective_Overview_Chart_Type__c = chartType;
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(settings);
        uow.commitWork();
    }
}