public with sharing class EventSelector extends fflib_SObjectSelector {
    /******************************
     *      STATIC METHODS
     ******************************/

    public static EventSelector newInstance() {
        return (EventSelector) Application.Selector.newInstance(Event.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Event.Id,
            Event.Subject,
            Event.Description,
            Event.OwnerId,
            Event.Type,
            Event.EventSubType,
            Event.ActivityDateTime,
            Event.StartDateTime,
            Event.EndDateTime,
            Event.WhatId,
            Event.WhoId
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Event.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Event> selectById(Set<ID> idSet) {
        Query eventQuery = generateStandardQueryForIdsAndFilters(null, null, new List<FilterObject>());

        return Database.query(eventQuery.addCondition(Query.conditionIn('Id', idSet)).toQueryString());
    }

    public List<Event> selectByWhatId(Set<Id> idSet, Boolean isSortAscending, Integer maxResult) {
        fflib_QueryFactory.SortOrder sortOrder = isSortAscending
            ? fflib_QueryFactory.SortOrder.ASCENDING
            : fflib_QueryFactory.SortOrder.DESCENDING;
        fflib_QueryFactory queryFactory = newQueryFactory();
        return Database.query(
            queryFactory
                .selectFields(
                    new Set<String>{
                        'Owner.Name',
                        'EventSubType',
                        'Type',
                        'ActivityDateTime',
                        'StartDateTime',
                        'EndDateTime',
                        'WhatId',
                        'Who',
                        'Who.Name',
                        'Who.FirstName',
                        'Who.LastName'
                    }
                )
                .setOrdering(Event.StartDateTime, sortOrder, true)
                .addOrdering(Event.Subject, fflib_QueryFactory.SortOrder.ASCENDING, true)
                .setLimit(maxResult)
                .setCondition('What.Id in :idSet')
                .toSOQL()
        );
    }

    private Query generateStandardQueryForIdsAndFilters(
        Set<Id> relatedIds,
        String sObjectType,
        List<FilterObject> selectedFilters
    ) {
        Query eventQuery = generateQueryForIdsAndFilters(relatedIds, sObjectType, selectedFilters);
        eventQuery.selectFields(getSObjectFieldList());
        eventQuery.selectField('Owner.Name');
        eventQuery.selectField('What.Name');
        eventQuery.selectField('What.Type');
        eventQuery.selectField('Who.Id');
        eventQuery.selectField('Who.Name');
        eventQuery.selectField('Who.FirstName');
        eventQuery.selectField('Who.LastName');
        eventQuery.orderBy('ActivityDate', 'asc', false);
        eventQuery.orderBy('Subject', 'asc', false);
        return eventQuery;
    }

    private Query generateQueryForIdsAndFilters(
        Set<Id> relatedIds,
        String sObjectType,
        List<FilterObject> selectedFilters
    ) {
        Query eventQuery = new Query(Event.sObjectType, null);

        Boolean isMine = false;
        Boolean dateRange = false;
        Query.DateLiteral dateRangeLiteral = null;

        List<String> statusFilters = new List<String>();
        for (FilterObject eventFilter : selectedFilters) {
            if (eventFilter.field == 'OwnerId') {
                isMine = eventFilter.value == 'OwnerMine';
            } else if (eventFilter.field == 'Status') {
                statusFilters.add(eventFilter.value);
            } else if (eventFilter.field == 'ActivityDate' && eventFilter.value != 'AllTime') {
                dateRange = true;
                dateRangeLiteral = getDateLiteralForValue(eventFilter.value);
            }
        }

        if (relatedIds != null) {
            eventQuery.addCondition(
                Query.doOr(Query.conditionIn('WhatId', relatedIds), Query.conditionIn('WhoId', relatedIds))
            );
        }
        if (sObjectType != null) {
            eventQuery.addCondition(Query.conditionEq('What.Type', sObjectType));
        }
        if (isMine) {
            String userId = UserInfo.getUserId(); //NOPMD - False positive, used in query condition
            eventQuery.addCondition(Query.conditionEq('OwnerId', userId));
        }
        if (statusFilters.size() > 0) {
            eventQuery.addCondition(Query.conditionIn('Status', statusFilters));
        }
        if (dateRange) {
            eventQuery.addCondition(
                Query.doOr(
                    Query.conditionEq('ActivityDate', Query.TODAY),
                    Query.conditionEq('ActivityDate', dateRangeLiteral)
                )
            );
        }
        return eventQuery;
    }

    private Query.DateLiteral getDateLiteralForValue(String value) {
        if (value == 'NEXT_N_DAYS:7') {
            return Query.NEXT_N_DAYS(7);
        } else if (value == 'LAST_N_DAYS:7') {
            return Query.LAST_N_DAYS(7);
        } else if (value == 'LAST_N_DAYS:30') {
            return Query.LAST_N_DAYS(30);
        } else {
            return Query.TODAY;
        }
    }
}