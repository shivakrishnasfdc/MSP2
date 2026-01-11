public with sharing class TasksSelector extends fflib_SObjectSelector {
    public static TasksSelector newInstance() {
        return (TasksSelector) Application.Selector.newInstance(Task.SObjectType);
    }

    public override String getOrderBy() {
        return Task.WhatId.getDescribe().getName();
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Task.Id,
            Task.TaskSubType,
            Task.OwnerId,
            Task.Subject,
            Task.ActivityDate,
            Task.Status,
            Task.WhatId,
            Task.WhoId,
            Task.CreatedById,
            Task.IsClosed
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Task.sObjectType;
    }

    public List<Task> selectById(Set<ID> idSet) {
        Query taskQuery = generateStandardQueryForIdsAndFilters(null, null, new List<FilterObject>());

        return Database.query(taskQuery.addCondition(Query.conditionIn('Id', idSet)).toQueryString());
    }

    public List<Task> selectByIdOrWhatIds(Set<Id> idSet, Set<Id> whatIds, String sortField1, Boolean isSortAscending) {

        List<Task> taskList = new List<Task>();

        Schema.DescribeSObjectResult taskDescribe = Task.SObjectType.getDescribe();

        // Get the describe result for a specific field
        Schema.DescribeFieldResult fieldDescribe = taskDescribe.fields.getMap().get(sortField1).getDescribe();
        
        // Check if the field is sortable
        Boolean isFieldSortable = fieldDescribe.isSortable();

        if(isFieldSortable){
            fflib_QueryFactory.SortOrder sortOrder1 = isSortAscending
                ? fflib_QueryFactory.SortOrder.ASCENDING
                : fflib_QueryFactory.SortOrder.DESCENDING;
            //String sortField2 = 'Subject';
            //fflib_QueryFactory.SortOrder sortOrder2 = fflib_QueryFactory.SortOrder.ASCENDING;
            fflib_QueryFactory queryFactory = newQueryFactory();
            taskList = Database.query(
                queryFactory
                .selectFields(
                    new Set<String>{'Owner.Name', 'Who.Name' }
                )
                .setCondition('Id in :idSet OR WhatId in :whatIds')
                .addOrdering(sortField1, sortOrder1, true)
                // .addOrdering(sortField2, sortOrder2, true)
                .toSOQL()
            );
        }

        return taskList;
    }

    public pqcrush__pq_Crush_User_Setting__c getObjectiveTaskOrderBy() {
        pqcrush__pq_Crush_User_Setting__c userSetting = new pqcrush__pq_Crush_User_Setting__c();
        userSetting.pqcrush__Objective_Task_Sort_Field__c = 'ActivityDate';
        userSetting.pqcrush__Objective_Task_Sort_Ascending__c = FALSE;
        List<pqcrush__pq_Crush_User_Setting__c> userSettings = CrushUserSettingSelector.newInstance().selectForCurrentUser();
        if (userSettings != NULL && userSettings.size() > 0) {
            if (userSettings[0].pqcrush__Objective_Task_Sort_Field__c != NULL) {
                userSetting = userSettings[0];
            }
        }
        return userSetting;
    }

    public List<Task> selectByIdAndFilters(Set<ID> idSet, List<FilterObject> selectedFilters) {
        Query taskQuery = generateStandardQueryForIdsAndFilters(null, null, selectedFilters);
        List<Task> result = Database.query(taskQuery.addCondition(Query.conditionIn('Id', idSet)).toQueryString());

        return result;
    }

    public List<Task> selectByWhoId(Set<Id> idSet, Boolean isSortAscending, Integer maxResult, Boolean isClosed) {
        fflib_QueryFactory.SortOrder sortOrder = isSortAscending
            ? fflib_QueryFactory.SortOrder.ASCENDING
            : fflib_QueryFactory.SortOrder.DESCENDING;
        fflib_QueryFactory queryFactory = newQueryFactory();
        return Database.query(
            queryFactory
                .selectFields(new Set<String>{'Owner.Name', 'TaskSubType', 'Who', 'Who.Name', 'Who.FirstName', 'Who.LastName' })
                .setOrdering(Task.ActivityDate, sortOrder, true)
                .addOrdering(Task.Subject, fflib_QueryFactory.SortOrder.ASCENDING, true)
                .setLimit(maxResult)
                .setCondition('Who.Id in :idSet AND IsClosed = :isClosed')
                .toSOQL()
        );
    }

    public List<Task> selectByWhatId(Set<Id> idSet, Boolean isSortAscending, Integer maxResult, Boolean isClosed) {
        fflib_QueryFactory.SortOrder sortOrder = isSortAscending
            ? fflib_QueryFactory.SortOrder.ASCENDING
            : fflib_QueryFactory.SortOrder.DESCENDING;
        fflib_QueryFactory queryFactory = newQueryFactory();
        return Database.query(
            queryFactory
                .selectFields(
                    new Set<String>{ 'Owner.Name', 'TaskSubType', 'Who', 'Who.Name', 'Who.FirstName', 'Who.LastName' }
                )
                .setOrdering(Task.ActivityDate, sortOrder, true)
                .addOrdering(Task.Subject, fflib_QueryFactory.SortOrder.ASCENDING, true)
                .setLimit(maxResult)
                .setCondition('What.Id in :idSet AND IsClosed = :isClosed')
                .toSOQL()
        );
    }

    public List<Task> getTasksWithRelatedIds(Set<Id> relatedIds, List<FilterObject> selectedFilters) {
        Boolean isMine = false;
        Boolean dateRange = false;
        String dateRangeString = '';

        List<String> statusFilters = new List<String>();
        for (FilterObject taskFilter : selectedFilters) {
            if (taskFilter.field == 'OwnerId') {
                isMine = taskfilter.value == 'OwnerMine';
            } else if (taskFilter.field == 'Status') {
                statusFilters.add(taskFilter.value);
            } else if (taskFilter.field == 'ActivityDate' && taskFilter.value != 'AllTime') {
                dateRange = true;
                dateRangeString = taskFilter.value;
            }
        }
        String whereClause = '(WhatId IN :relatedIds OR WhoId IN :relatedIds)';
        if (isMine) {
            String userId = UserInfo.getUserId(); //NOPMD - False positive, used in query condition
            whereClause += ' AND OwnerId = :userId';
        }
        if (statusFilters.size() > 0) {
            whereClause += ' AND Status IN :statusFilters';
        }
        if (dateRange) {
            whereClause += ' AND (ActivityDate = TODAY OR ActivityDate = ' + dateRangeString + ')';
        }

        List<Task> result = Database.Query('SELECT Id FROM Task WHERE ' + whereClause);

        return result;
    }

    public Integer getTaskCountForObjectType(String sObjectType, List<FilterObject> selectedFilters) {
        Query taskQuery = generateCountQueryForIdsAndFilters(null, sObjectType, selectedFilters);
        AggregateResult result = taskQuery.aggregate()[0];
        return (Integer) result.get('taskCount');
    }

    public List<Task> selectByRelatedIdsWithFiltersPaged(
        Set<Id> idSet,
        Integer pageNumber,
        Integer recordsPerPage,
        List<FilterObject> selectedFilters
    ) {
        Integer calcOffset = 0;
        if (pageNumber > 1) {
            calcOffset = (pageNumber - 1) * recordsPerPage;
        }

        Query taskQuery = generateStandardQueryForIdsAndFilters(idSet, null, selectedFilters);

        List<Task> result = new List<Task>();
        result = Database.query(taskQuery.setLimit(recordsPerPage).setOffset(calcOffset).toQueryString());
        return result;
    }

    public List<Task> selectByRelatedIdsWithFilters(Set<Id> idSet, List<FilterObject> selectedFilters) {
        Query taskQuery = generateStandardQueryForIdsAndFilters(idSet, null, selectedFilters);
        List<Task> result = Database.query(taskQuery.toQueryString());
        return result;
    }

    public Integer selectCountByRelatedIdsWithFilters(Set<Id> relatedIds, List<FilterObject> selectedFilters) {
        Query taskQuery = generateCountQueryForIdsAndFilters(relatedIds, null, selectedFilters);
        AggregateResult result = taskQuery.aggregate()[0];
        return (Integer) result.get('taskCount');
    }

    public List<Task> selectByObjectType(
        String sObjectType,
        Integer pageNumber,
        Integer recordsPerPage,
        List<FilterObject> selectedFilters
    ) {
        Integer calcOffset = 0;
        if (pageNumber > 1) {
            calcOffset = (pageNumber - 1) * recordsPerPage;
        }
        Query taskQuery = generateStandardQueryForIdsAndFilters(null, sObjectType, selectedFilters);

        String soqlString = taskQuery.setLimit(recordsPerPage).setOffset(calcOffset).toQueryString();
        
        List<Task> result = Database.query(soqlString);

        return result;
    }

    private Query generateCountQueryForIdsAndFilters(
        Set<Id> relatedIds,
        String sObjectType,
        List<FilterObject> selectedFilters
    ) {
        Query taskQuery = generateQueryForIdsAndFilters(relatedIds, sObjectType, selectedFilters);

        taskQuery.count('Id', 'taskCount');
        return taskQuery;
    }

    private Query generateStandardQueryForIdsAndFilters(
        Set<Id> relatedIds,
        String sObjectType,
        List<FilterObject> selectedFilters
    ) {
        Query taskQuery = generateQueryForIdsAndFilters(relatedIds, sObjectType, selectedFilters);
        taskQuery.selectFields(getSObjectFieldList());
        taskQuery.selectField('Owner.Name');
        taskQuery.selectField('What.Name');
        taskQuery.selectField('What.Type');
        taskQuery.selectField('Who.Id');
        taskQuery.selectField('Who.Name');
        taskQuery.selectField('Who.FirstName');
        taskQuery.selectField('Who.LastName');
        taskQuery.orderBy('ActivityDate', 'asc', false);
        taskQuery.orderBy('Subject', 'asc', false);
        return taskQuery;
    }

    private Query generateQueryForIdsAndFilters(
        Set<Id> relatedIds,
        String sObjectType,
        List<FilterObject> selectedFilters
    ) {
        Query taskQuery = new Query(Task.sObjectType, null);

        Boolean isMine = false;
        Boolean dateRange = false;
        Query.DateLiteral dateRangeLiteral = null;

        List<String> statusFilters = new List<String>();
        for (FilterObject taskFilter : selectedFilters) {
            if (taskFilter.field == 'OwnerId') {
                isMine = taskfilter.value == 'OwnerMine';
            } else if (taskFilter.field == 'Status') {
                statusFilters.add(taskFilter.value);
            } else if (taskFilter.field == 'ActivityDate' && taskFilter.value != 'AllTime') {
                dateRange = true;
                dateRangeLiteral = getDateLiteralForValue(taskFilter.value);
            }
        }

        if (relatedIds != null) {
            taskQuery.addCondition(
                Query.doOr(Query.conditionIn('WhatId', relatedIds), Query.conditionIn('WhoId', relatedIds))
            );
        }
        if (sObjectType != null) {
            taskQuery.addCondition(Query.conditionEq('What.Type', sObjectType));
        }
        if (isMine) {
            String userId = UserInfo.getUserId(); //NOPMD - False positive, used in query condition
            taskQuery.addCondition(Query.conditionEq('OwnerId', userId));
        }
        if (statusFilters.size() > 0) {
            taskQuery.addCondition(Query.conditionIn('Status', statusFilters));
        }
        if (dateRange) {
            taskQuery.addCondition(
                Query.doOr(
                    Query.conditionEq('ActivityDate', Query.TODAY),
                    Query.conditionEq('ActivityDate', dateRangeLiteral)
                )
            );
        }
        return taskQuery;
    }

    private Query.DateLiteral getDateLiteralForValue(String value) {
        if (value == 'NEXT_N_DAYS:7') {
            return Query.NEXT_N_DAYS(7);
        } else if (value == 'LAST_N_DAYS:7') {
            return Query.LAST_N_DAYS(7);
        } else if (value == 'LAST_N_DAYS:30') {
            return Query.LAST_N_DAYS(30);
        } else if (value == 'NEXT_N_DAYS:30') {
            return Query.NEXT_N_DAYS(30); 
        } else if (value == 'NEXT_N_DAYS:60') {
            return Query.NEXT_N_DAYS(60); 
        } else if (value == 'NEXT_N_DAYS:90') {
            return Query.NEXT_N_DAYS(90); 
        } else {
            return Query.TODAY;
        }
    }
}