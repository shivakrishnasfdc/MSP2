public with sharing class AccountPlanShareService {
    public static void updateAllAccountTeamShares() {
        service().updateAllAccountTeamShares();
    }

    public static void updateAllAccountTeamShares(List<Id> accountPlanIds) {
        service().updateAllAccountTeamShares(accountPlanIds);
    }

    public static void updateAllAccountTeamShares(List<Account_Plan__c> accountPlans) {
        service().updateAllAccountTeamShares(accountPlans);
    }

    private static AccountPlanShareServiceImpl service() {
        return (AccountPlanShareServiceImpl) Application.Service.newInstance(AccountPlanShareServiceImpl.class);
    }
}