public with sharing class TasksController {
    private static final Integer BATCH_SIZE = 200;

    @AuraEnabled
    public static List<RecordTypeInfoWrapper> getRecordTypeInfo() {
        return SObjectController.getRecordTypeInfos('Task');
    }

    @AuraEnabled
    public static List<AccountPlanTaskWrapper> getTasksForAccountPlan(
        List<Id> accountPlanIds,
        Integer pageNumber,
        Integer recordsPerPage,
        String filtersJson
    ) {
        if (accountPlanIds == null || accountPlanIds.size() == 0) {
            return new List<AccountPlanTaskWrapper>();
        }
        if (filtersJson == null) {
            filtersJson = '[]';
        }
        List<FilterObject> selectedFilters = (List<FilterObject>) System.JSON.deserializeStrict(
            filtersJson,
            List<FilterObject>.class
        );

        if (selectedFilters != null && selectedFilters.size() > 0) {
            CrushUserSettingService.updateTaskFilter(filtersJson);
        }

        // Recasting as Integer to fix weird behavior when the integer is passed from lightning component
        Integer pageNumberInt = Integer.valueOf(pageNumber);
        Integer recordsPerPageInt = Integer.valueOf(recordsPerPage);

        List<Account_Plan__c> plans = AccountPlanSelector.newInstance().selectById(new Set<Id>(accountPlanIds));
        if (plans.size() == 0) {
            return new List<AccountPlanTaskWrapper>();
        }
        Map<Id, Set<Account_Plan__c>> accountPlanSetByWhatId = getMapOfPlansByAssociatedIds(plans);
        List<Task> allTasks = TasksSelector.newInstance()
            .selectByRelatedIdsWithFiltersPaged(
                AccountPlanSetByWhatId.keySet(),
                pageNumberInt,
                recordsPerPageInt,
                selectedFilters
            );
        List<AccountPlanTaskWrapper> wrappers = new List<AccountPlanTaskWrapper>();

        for (Task task : allTasks) {
            if (AccountPlanSetByWhatId.containsKey(task.WhatId)) {
                wrappers.add(new AccountPlanTaskWrapper(task, AccountPlanSetByWhatId.get(task.WhatId)));
            } else if (accountPlanSetByWhatId.containsKey(task.WhoId)) {
                wrappers.add(new AccountPlanTaskWrapper(task, accountPlanSetByWhatId.get(task.WhoId)));
            } else {
                wrappers.add(new AccountPlanTaskWrapper(task, new Set<Account_Plan__c>()));
            }
        }
        return wrappers;
    }

    @AuraEnabled
    public static Integer getTaskCountForAccountPlan(List<Id> accountPlanIds, String filtersJson) {
        if (accountPlanIds == null || accountPlanIds.size() == 0) {
            return 0;
        }
        if (filtersJson == null) {
            filtersJson = '[]';
        }
        List<FilterObject> selectedFilters = (List<FilterObject>) System.JSON.deserializeStrict(
            filtersJson,
            List<FilterObject>.class
        );

        if (selectedFilters == null) {
            selectedFilters = new List<FilterObject>();
        }

        List<Account_Plan__c> plans = AccountPlanSelector.newInstance().selectById(new Set<Id>(accountPlanIds));
        if (plans.size() == 0) {
            return 0;
        }

        Map<Id, Set<Account_Plan__c>> accountPlanSetByWhatId = getMapOfPlansByAssociatedIds(plans);
        Set<Id> whatIdSet = AccountPlanSetByWhatId.keySet();
        Integer taskCount = TasksSelector.newInstance().selectCountByRelatedIdsWithFilters(whatIdSet, selectedFilters);
        return taskCount;
    }

    @AuraEnabled
    public static List<AccountPlanTaskWrapper> getTasksForAllAccountPlans(
        Integer pageNumber,
        Integer recordsPerPage,
        String filtersJson
    ) {
        if (filtersJson == null) {
            filtersJson = '[]';
        }
        List<FilterObject> selectedFilters = (List<FilterObject>) System.JSON.deserializeStrict(
            filtersJson,
            List<FilterObject>.class
        );

        if (selectedFilters != null && selectedFilters.size() > 0) {
            CrushUserSettingService.updateTaskFilter(filtersJson);
        }

        // Recasting as Integer to fix weird behavior when the integer is passed from lightning component
        Integer pageNumberInt = Integer.valueOf(pageNumber);
        Integer recordsPerPageInt = Integer.valueOf(recordsPerPage);

        List<Account_Plan__c> allAccountPlans = AccountPlanSelector.newInstance().selectAll();
        if (allAccountPlans.size() == 0) {
            return new List<AccountPlanTaskWrapper>();
        }
        Map<Id, Account_Plan__c> planMap = new Map<Id, Account_Plan__c>(allAccountPlans);
        List<Task> allTasks = TasksSelector.newInstance()
            .selectByRelatedIdsWithFiltersPaged(planMap.keySet(), pageNumberInt, recordsPerPageInt, selectedFilters);
        List<AccountPlanTaskWrapper> wrappers = new List<AccountPlanTaskWrapper>();

        for (Task task : allTasks) {
            Set<Account_Plan__c> accountPlans = new Set<Account_Plan__c>();
            if (planMap.containsKey(task.WhatId)) {
                accountPlans.add(planMap.get(task.WhatId));
            }
            wrappers.add(new AccountPlanTaskWrapper(task, accountPlans));
        }
        return wrappers;
    }

    @AuraEnabled
    public static Integer getTaskCountForAllAccountPlans(String filtersJson) {
        if (filtersJson == null) {
            filtersJson = '[]';
        }
        List<FilterObject> selectedFilters = (List<FilterObject>) System.JSON.deserializeStrict(
            filtersJson,
            List<FilterObject>.class
        );
        if (selectedFilters == null) {
            selectedFilters = new List<FilterObject>();
        }

        List<Account_Plan__c> allAccountPlans = AccountPlanSelector.newInstance().selectAll();
        if (allAccountPlans.size() == 0) {
            return 0;
        }

        Set<Id> whatIdSet = new Map<Id, Account_Plan__c>(allAccountPlans).keySet();
        Integer taskCount = TasksSelector.newInstance().selectCountByRelatedIdsWithFilters(whatIdSet, selectedFilters);
        return taskCount;
    }

    @AuraEnabled
    public static Map<Id, UserRecordAccess> getUserRecordAccessForTasks(List<Id> taskIds) {
        Integer numberOfList = (taskIds.size() / BATCH_SIZE) + 1;
        Map<Id, UserRecordAccess> recordAccessByTaskId = new Map<Id, UserRecordAccess>();

        for (Integer i = 0; i < numberOfList; i++) {
            List<Id> smallList = new List<Id>();
            Integer start = i * BATCH_SIZE;
            Integer finish = start + BATCH_SIZE;
            for (Integer j = start; (j < finish) && (j < taskIds.size()); j++) {
                smallList.add(taskIds.get(j));
            }

            List<UserRecordAccess> recordAccess = UserRecordAccessSelector.newInstance()
                .selectByRecordId(new Set<Id>(smallList));

            for (UserRecordAccess ura : recordAccess) {
                recordAccessByTaskId.put(ura.RecordId, ura);
            }
        }

        return recordAccessByTaskId;
    }

    @AuraEnabled
    public static Task getTaskById(Id taskId) {
        List<Task> tasks = TasksSelector.newInstance().selectById(new Set<Id>{ taskId });

        if (tasks.isEmpty()) {
            return null;
        }

        return tasks.get(0);
    }

    @AuraEnabled
    public static void deleteTask(Id taskId) {
        fflib_SObjectUnitOfWork unitOfWork = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ Task.SObjectType }
        );

        Task taskItem = getTaskById(taskId);
        Tasks taskRecords = Tasks.newInstance(new List<Task>{ taskItem });
        taskRecords.deleteObjects(unitOfWork);

        unitOfWork.commitWork();
    }

    @AuraEnabled
    public static Task upsertStatus(Id taskId, String status) {
        fflib_SObjectUnitOfWork unitOfWork = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ Task.SObjectType }
        );

        Task taskItem = getTaskById(taskId);
        Tasks taskRecords = Tasks.newInstance(new List<Task>{ taskItem });

        taskRecords.updateField(Schema.Task.Status, status, unitOfWork);

        unitOfWork.commitWork();
        return getTaskById(taskItem.Id);
    }

    @AuraEnabled
    public static List<FilterSectionObject> getFilterValues() {
        // Get current values
        pq_Crush_User_Setting__c userSettings = CrushUserSettingService.getSetting();
        String taskFiltersJson = userSettings.Account_Plan_Task_Filter__c;

        List<FilterObject> selectedFilters = null;
        if (!String.isBlank(taskFiltersJson)) {
            try {
                selectedFilters = (List<FilterObject>) System.JSON.deserializeStrict(
                    taskFiltersJson,
                    List<FilterObject>.class
                );
            } catch (Exception e) {
                selectedFilters = null;
            }
        }

        String ownerIdVal = 'OwnerMine';
        String activityType = 'AllTime';
        Set<String> statusSelected = new Set<String>();

        if (selectedFilters != null) {
            for (FilterObject fo : selectedFilters) {
                switch on fo.field {
                    when 'OwnerId' {
                        ownerIdVal = fo.value;
                    }
                    when 'ActivityDate' {
                        activityType = fo.value;
                    }
                    when 'Status' {
                        statusSelected.add(fo.value);
                    }
                }
            }
        }

        List<FilterObject> basicFilters = new List<FilterObject>();
        basicFilters.add(
            new FilterObject(
                System.Label.Task_Filter_Assignee_All,
                'OwnerAll',
                'OwnerId',
                ownerIdVal == 'OwnerAll',
                ownerIdVal == 'OwnerAll'
            )
        );
        basicFilters.add(
            new FilterObject(
                System.Label.Task_Filter_Assignee_My,
                'OwnerMine',
                'OwnerId',
                ownerIdVal == 'OwnerMine',
                ownerIdVal == 'OwnerMine'
            )
        );
        FilterSectionObject basicSection = new FilterSectionObject(System.Label.Assignee, basicFilters, true);

        List<FilterObject> statusFilters = getStatusPicklistValues();
        for (FilterObject fo : statusFilters) {
            if (statusSelected.contains(fo.value)) {
                fo.isSelected = true;
                fo.isDefault = true;
            }
        }
        FilterSectionObject statusSection = new FilterSectionObject(System.Label.Status, statusFilters, false);

        List<FilterObject> dateRangeFilters = new List<FilterObject>();
        dateRangeFilters.add(
            new FilterObject(
                System.Label.Task_Filter_Date_All_Time,
                'AllTime',
                'ActivityDate',
                activityType == 'AllTime',
                activityType == 'AllTime'
            )
        );
        dateRangeFilters.add(
            new FilterObject(
                System.Label.Task_Filter_Date_Last_7_Days,
                'LAST_N_DAYS:7',
                'ActivityDate',
                activityType == 'LAST_N_DAYS:7',
                activityType == 'LAST_N_DAYS:7'
            )
        );
        dateRangeFilters.add(
            new FilterObject(
                System.Label.Task_Filter_Date_Next_7_Days,
                'NEXT_N_DAYS:7',
                'ActivityDate',
                activityType == 'NEXT_N_DAYS:7',
                activityType == 'NEXT_N_DAYS:7'
            )
        );
        dateRangeFilters.add(
            new FilterObject(
                System.Label.Task_Filter_Date_Last_30_Days,
                'LAST_N_DAYS:30',
                'ActivityDate',
                activityType == 'LAST_N_DAYS:30',
                activityType == 'LAST_N_DAYS:30'
            )
        );
        dateRangeFilters.add(
            new FilterObject(
                System.Label.Task_Filter_Date_Next_30_Days,
                'NEXT_N_DAYS:30',
                'ActivityDate',
                activityType == 'NEXT_N_DAYS:30',
                activityType == 'NEXT_N_DAYS:30'
            )
        );
        dateRangeFilters.add(
            new FilterObject(
                System.Label.Task_Filter_Date_Next_60_Days,
                'NEXT_N_DAYS:60',
                'ActivityDate',
                activityType == 'NEXT_N_DAYS:60',
                activityType == 'NEXT_N_DAYS:60'
            )
        );
        dateRangeFilters.add(
            new FilterObject(
                System.Label.Task_Filter_Date_Next_90_Days,
                'NEXT_N_DAYS:90',
                'ActivityDate',
                activityType == 'NEXT_N_DAYS:90',
                activityType == 'NEXT_N_DAYS:90'
            )
        );
        FilterSectionObject dateRangeSection = new FilterSectionObject(System.Label.Date_Range, dateRangeFilters, true);

        return new List<FilterSectionObject>{ basicSection, statusSection, dateRangeSection };
    }

    private static List<FilterObject> getStatusPicklistValues() {
        List<FilterObject> filters = new List<FilterObject>();
        Schema.SObjectType objType = Task.getSObjectType();
        Schema.DescribeSObjectResult objDesc = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDesc.fields.getMap();

        List<Schema.PickListEntry> plValues = fieldMap.get('Status').getDescribe().getPickListValues();
        for (Schema.PicklistEntry plValue : plValues) {
            filters.add(new FilterObject(plValue.getLabel(), plValue.getValue(), 'Status', false, false));
        }
        return filters;
    }

    @AuraEnabled
    public static Map<String, List<FilterObject>> getUpdateStatusPicklistValues() {
        List<FilterObject> closedFilters = new List<FilterObject>();
        List<FilterObject> openFilters = new List<FilterObject>();

        List<TaskStatus> closedStatus = TaskStatusSelector.newInstance().selectTasksStatusForClosed();
        List<TaskStatus> openStatus = TaskStatusSelector.newInstance().selectTasksStatusForOpen();

        for (TaskStatus status : closedStatus) {
            closedFilters.add(new FilterObject(status.MasterLabel, status.ApiName, 'Status', true, false));
        }
        for (TaskStatus status : openStatus) {
            openFilters.add(new FilterObject(status.MasterLabel, status.ApiName, 'Status', true, false));
        }
        Map<String, List<FilterObject>> filterMap = new Map<String, List<FilterObject>>();
        filterMap.put('closed', closedFilters);
        filterMap.put('open', openFilters);
        return filterMap;
    }

    @AuraEnabled
    public static List<FilterSectionObject> getAccountPlanFilters() {
        List<Account_Plan__c> accountPlans = AccountPlanSelector.newInstance().selectAll();

        List<FilterObject> accountPlanFilters = new List<FilterObject>();
        for (Account_Plan__c accountPlan : accountPlans) {
            accountPlanFilters.add(new FilterObject(accountPlan.Name, accountPlan.Id, 'AccountPlans', false, false));
        }
        FilterSectionObject accountPlanFilterSection = new FilterSectionObject('', accountPlanFilters, false);

        return new List<FilterSectionObject>{ accountPlanFilterSection };
    }

    @AuraEnabled
    public static List<TaskWrapper> getTasksForContact(Id contactId) {
        List<Task> openTaskList = TasksSelector.newInstance().selectByWhoId(new Set<Id>{ contactId }, true, 20, false);
        List<Task> closedTaskList = TasksSelector.newInstance()
            .selectByWhoId(new Set<Id>{ contactId }, false, 20, true);

        openTaskList.addAll(closedTaskList);

        return TaskWrapper.convert(openTaskList);
    }

    private static Map<Id, Set<Account_Plan__c>> getMapOfPlansByAssociatedIds(List<Account_Plan__c> accountPlans) {
        if (accountPlans == null || accountPlans.size() == 0) {
            return new Map<Id, Set<Account_Plan__c>>();
        }

        Set<Id> accountIds = new Set<Id>();
        Map<Id, Account_plan__c> accountPlanMap = new Map<Id, Account_plan__c>();
        for (Account_plan__c plan : accountPlans) {
            accountIds.add(plan.Account__c);
            accountPlanMap.put(plan.Id, plan);
        }

        Map<Id, Set<Id>> whatIdsByAccountId = AccountService.getTaskWhatIdsByAccountId(accountIds);
        Map<Id, Set<Id>> whatIdsByAccountPlanId = AccountPlanService.getTaskWhatIdsByAccountPlanIdForMap(
            accountPlanMap
        );

        Map<Id, Set<Account_Plan__c>> accountPlanSetByWhatId = new Map<Id, Set<Account_Plan__c>>();

        for (Account_plan__c plan : accountPlans) {
            Set<Id> whatIds = new Set<Id>();
            if (whatIdsByAccountId.containsKey(plan.Account__c)) {
                whatIds.addAll(whatIdsByAccountId.get(plan.Account__c));
            }
            if (whatIdsByAccountPlanId.containsKey(plan.Id)) {
                whatIds.addAll(whatIdsByAccountPlanId.get(plan.Id));
            }
            whatIds.add(plan.Id);

            for (Id whatId : whatIds) {
                if (!AccountPlanSetByWhatId.containsKey(whatId)) {
                    AccountPlanSetByWhatId.put(whatId, new Set<Account_Plan__c>());
                }
                AccountPlanSetByWhatId.get(whatId).add(plan);
            }
        }

        return AccountPlanSetByWhatId;
    }
}