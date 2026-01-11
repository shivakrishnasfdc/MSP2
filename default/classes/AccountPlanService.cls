@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class AccountPlanService {
    global static List<Account_Plan__c> openAccountPlans(Set<Id> accountPlanIds) {
        AccountPlanServiceAdmin service = new AccountPlanServiceAdmin();
        return service.openAccountPlansWithoutSharing(accountPlanIds);
    }

    public static void maybeOpenAccountPlans(Map<Id, List<SObject>> recordsByAccountPlanId) {
        if (Application.bypassPlanReopen) {
            return;
        }
        AccountPlanServiceAdmin service = new AccountPlanServiceAdmin();
        service.mayOpenAccountPlans(recordsByAccountPlanId);
    }

    public static void transferAccountPlans(Set<Id> accountPlanIds) {
        AccountPlanServiceAdmin service = new AccountPlanServiceAdmin();
        service.transferAccountPlansWithoutSharing(accountPlanIds);
    }

    public static Map<Id, Set<Id>> getTaskWhatIdsByAccountPlanIdForMap(Map<Id, Account_plan__c> accountPlanIds) {
        return service().getTaskWhatIdsByAccountPlanIdForMap(accountPlanIds);
    }

    public static Set<Id> getIdsForRelatedObjectsToAccountPlan(Id accountPlanId, Id accountId) {
        return service().getIdsForRelatedObjectsToAccountPlan(accountPlanId, accountId);
    }

    private static AccountPlanServiceImpl service() {
        return (AccountPlanServiceImpl) Application.Service.newInstance(AccountPlanServiceImpl.class);
    }

    private without sharing class AccountPlanServiceAdmin {
        private List<Account_Plan__c> openAccountPlansWithoutSharing(Set<Id> accountPlanIds) {
            return service().openAccountPlans(accountPlanIds);
        }

        private void transferAccountPlansWithoutSharing(Set<Id> accountPlanIds) {
            service().transferAccountPlans(accountPlanIds);
        }

        private void mayOpenAccountPlans(Map<Id, List<SObject>> recordsByAccountPlanId) {
            service().maybeOpenAccountPlans(recordsByAccountPlanId);
        }

        private AccountPlanServiceImpl service() {
            return (AccountPlanServiceImpl) Application.Service.newInstance(AccountPlanServiceImpl.class);
        }
    }
}