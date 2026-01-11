public with sharing class ObjectiveService {
    private static ObjectiveServiceImpl instance = null;

    public static List<ObjectiveWrapper> getObjectivesForAccountPlans(Set<Id> accountPlanIds) {
        return service().getObjectivesForAccountPlans(accountPlanIds);
    }

    public static void removeTaskFromObjective(Id objectiveId, Id taskId, Boolean alsoDelete) {
        service().removeTaskFromObjective(objectiveId, taskId, alsoDelete);
    }

    public static void deleteObjective(Id objectiveId, List<Id> taskIds, Boolean alsoDelete) {
        service().deleteObjective(objectiveId, taskIds, alsoDelete);
    }

    public static List<Task> getTasksForAccountPlan(Set<Id> accountPlanIds, List<FilterObject> selectedFilters) {
        return service().getTasksForAccountPlan(accountPlanIds, selectedFilters);
    }

    public static void updateObjectiveRecords(List<Objective__c> objectives) {
        service().updateObjectiveRecords(objectives);
    }

    private static ObjectiveServiceImpl service() {
        if (instance == null) {
            instance = (ObjectiveServiceImpl) Application.Service.newInstance(ObjectiveServiceImpl.class);
        }
        return instance;
    }
}