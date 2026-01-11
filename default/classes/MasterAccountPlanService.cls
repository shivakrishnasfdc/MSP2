public with sharing class MasterAccountPlanService {
    private static MasterAccountPlanServiceImpl instance = null;

    public static List<Account_Plan__c> getAccountPlansByMasterAccountPlan(Id masterAccountPlanId) {
        return service().getAccountPlansByMasterAccountPlan(masterAccountPlanId);
    }

    public static Set<Id> getRelatedAccountIdsByMasterAccountPlans(Set<Id> masterAccountPlanIds) {
        return service().getRelatedAccountIdsByMasterAccountPlans(masterAccountPlanIds);
    }

    @AuraEnabled
    public static boolean updateClosedPlanFilter(Boolean showClosedPlans, Id masterAccountPlanId) {
        return service().updateClosedPlanFilter(showClosedPlans, masterAccountPlanId);
    }

    private static MasterAccountPlanServiceImpl service() {
        if (instance == null) {
            instance = (MasterAccountPlanServiceImpl) Application.Service.newInstance(
                MasterAccountPlanServiceImpl.class
            );
        }
        return instance;
    }
}