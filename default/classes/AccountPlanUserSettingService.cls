public with sharing class AccountPlanUserSettingService {
    public static pq_CRUSH_Account_Plan_User_Setting__c createNewSettings(Id accountPlanId) {
        return service().createNewSettings(accountPlanId);
    }

    private static AccountPlanUserSettingServiceImpl service() {
        return (AccountPlanUserSettingServiceImpl) Application.Service.newInstance(
            AccountPlanUserSettingServiceImpl.class
        );
    }
}