public with sharing class CrushUserSettingService {
    private static CrushUserSettingServiceImpl instance = null;

    public static pq_Crush_User_Setting__c getSetting() {
        return service().getSetting();
    }

    public static void updateTaskFilter(String taskFiltrJSON) {
        service().updateTaskFilter(taskFiltrJSON);
    }

    public static void updateAccountPlanSort(String sortOrder) {
        service().updateAccountPlanSort(sortOrder);
    }

    public static void updateObjectiveTaskSortAscending(Boolean taskSortOrder) {
        service().updateObjectiveTaskSortAscending(taskSortOrder);
    }

    public static void updateObjectiveTaskSortField(String sortField) {
        service().updateObjectiveTaskSortField(sortField);
    }

    private static CrushUserSettingServiceImpl service() {
        if (instance == null) {
            instance = (CrushUserSettingServiceImpl) Application.Service.newInstance(CrushUserSettingServiceImpl.class);
        }
        return instance;
    }
}