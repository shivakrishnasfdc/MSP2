@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class ObjectiveController {
    @AuraEnabled
    public static ObjectiveWrapperList getObjectivesForAccountPlan(Id accountPlanId) {
        if (accountPlanId.getSObjectType() == pq_Master_Account_Plan__c.getSObjectType()) {
            List<Account_Plan__c> plans = MasterAccountPlanService.getAccountPlansByMasterAccountPlan(accountPlanId);
            Set<Id> accountPlanIds = new Set<Id>();
            for (Account_Plan__c plan : plans) {
                accountPlanIds.add(plan.Id);
            }
            return new ObjectiveWrapperList(ObjectiveService.getObjectivesForAccountPlans(accountPlanIds));
        }

        return new ObjectiveWrapperList(ObjectiveService.getObjectivesForAccountPlans(new Set<Id>{ accountPlanId }));
    }

    @AuraEnabled
    public static Id createNewTaskForObjective(Id objectiveId, String taskSubject) {
        fflib_ISObjectUnitOfWork uowTask = Application.UnitOfWork.newInstance();
        Task t = new Task(Subject = taskSubject);
        uowTask.registerNew(t);
        uowTask.commitWork();

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Objective_Task_Association__c ota = new Objective_Task_Association__c(
            Objective__c = objectiveId,
            TaskId__c = t.Id
        );
        uow.registerNew(ota);
        uow.commitWork();

        return t.Id;
    }

    @AuraEnabled
    public static void removeTaskFromObjective(Id objectiveId, Id taskId, Boolean alsoDelete) {
        ObjectiveService.removeTaskFromObjective(objectiveId, taskId, alsoDelete);
    }

    @AuraEnabled
    public static ObjectiveSettingWrapper getSettings() {
        CRUSH_Settings_Obj__c setting = SettingService.getOrgSettingsAndCreateIfNeeded();
        ObjectiveSettingWrapper wrapper = new ObjectiveSettingWrapper(setting);
        return wrapper;
    }

    @AuraEnabled
    public static void updateSettings(String settingString) {
        ObjectiveSettingWrapper setting = (ObjectiveSettingWrapper) JSON.deserialize(
            settingString,
            ObjectiveSettingWrapper.class
        );
        CRUSH_Settings_Obj__c currentSetting = SettingService.getOrgSettingsAndCreateIfNeeded();
        CRUSH_Settings_Obj__c updatedSettings = ObjectiveSettingWrapper.updateSettings(currentSetting, setting);
        SettingService.upsertSettings(updatedSettings);
    }

    @AuraEnabled
    public static void updateObjectiveRecords(List<Objective__c> objectives) {
        ObjectiveService.updateObjectiveRecords(objectives);
    }

    @AuraEnabled
    public static void deleteObjective(Id objectiveId, List<Id> taskIds, Boolean alsoDelete) {
        ObjectiveService.deleteObjective(objectiveId, taskIds, alsoDelete);
    }

    @AuraEnabled
    public static List<String> getObjectiveTaskSortFieldValues() {
        List<String> values = new List<String>();

        Schema.DescribeFieldResult fieldResult = pqcrush__pq_CRUSH_User_Setting__c.pqcrush__Objective_Task_Sort_Field__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();

        // Iterate over loop and the values 
        for (Schema.PicklistEntry p : pList) {
            values.add(p.getLabel() + ',' + p.getValue());
        }
        return values;
    }

    @AuraEnabled
    public static String getObjectiveTaskUserSortValues(List<String> listOfValues) {
        if (listOfValues == null || listOfValues.isEmpty()) {
            return 'Due Date,true';
        }
        //Split the Label and API name, then store them in a map
        Map<String, String> sortValueMap = new Map<String, String>();
        for (String valueString : listOfValues) {
          if (String.isNotEmpty(valueString) && valueString.contains(',')) {
            List<String> lstAlpha = valueString.split(',');
                sortValueMap.put(lstAlpha[1], lstAlpha[0]);
            }
        }

        String userSetting;
        Boolean userSortAscending;
        List<pqcrush__pq_Crush_User_Setting__c> userSettings = CrushUserSettingSelector.newInstance()
            .selectForCurrentUser();
        if (userSettings != null && userSettings.size() > 0) {
            pqcrush__pq_Crush_User_Setting__c userSettingRecord = userSettings[0];
            String sortField;
            if (userSettingRecord != null) {
                sortField = userSettingRecord.pqcrush__Objective_Task_Sort_Field__c;
                userSortAscending = userSettingRecord.pqcrush__Objective_Task_Sort_Ascending__c != null 
                    ? userSettingRecord.pqcrush__Objective_Task_Sort_Ascending__c 
                    : true; 
            }
            if (userSettingRecord != null && sortField != null && sortValueMap.containsKey(sortField)) {
                userSetting = sortValueMap.get(sortField);
            }
        } else {
            userSetting = 'Due Date';
            userSortAscending = true;
        }
        String values = userSetting + ',' + string.valueOf(userSortAscending);
        return values;
    }

    @AuraEnabled
    public static void updateObjectiveTaskSortAscending(Boolean taskSortOrder) {
        CrushUserSettingService.updateObjectiveTaskSortAscending(taskSortOrder);
    }

    @AuraEnabled
    public static Boolean updateObjectiveTaskSortField(String sortField) {

        Boolean flag = false;
        Schema.DescribeSObjectResult taskDescribe = Task.SObjectType.getDescribe();
        // Get the describe result for a specific field
        Schema.DescribeFieldResult fieldDescribe = taskDescribe.fields.getMap().get(sortField).getDescribe();
        
        // Check if the field is sortable
        Boolean isFieldSortable = fieldDescribe.isSortable();

        if(isFieldSortable){
            flag = true;
            CrushUserSettingService.updateObjectiveTaskSortField(sortField);
        }

        return flag;
    }
}