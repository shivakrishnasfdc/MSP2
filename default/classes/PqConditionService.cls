public with sharing class PqConditionService {
    public static List<pq_Condition__c> getPqConditions(Id settingId) {
        return service().getPqConditions(settingId);
    }

    public static List<pq_Condition__c> insertPqCondition(List<pq_Condition__c> conditions) {
        return service().insertPqCondition(conditions);
    }

    public static void deletePqCondition(List<pq_Condition__c> conditions) {
        service().deletePqCondition(conditions);
    }

    public static List<pq_Condition__c> updatePqCondition(List<pq_Condition__c> conditions) {
        return service().updatePqCondition(conditions);
    }

    private static PqConditionServiceImpl service() {
        return (PqConditionServiceImpl) Application.Service.newInstance(PqConditionServiceImpl.class);
    }
}