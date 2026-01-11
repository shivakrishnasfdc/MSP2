public with sharing class SuggestedContactsController {
    @AuraEnabled
    public static RM_Org_Setting__c getRMOrgSettingForType(String type) {
        return RMOrgSettingService.getRMOrgSettingForType(type);
    }

    @AuraEnabled
    public static List<pq_Condition__c> getContactsConditions(Id settingId) {
        return PqConditionService.getPqConditions(settingId);
    }

    @AuraEnabled
    public static List<Relationship_Map_Member__c> insertRelationshipMapMember(
        List<Relationship_Map_Member__c> mapMember
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerNew(mapMember);
        uow.commitWork();
        return mapMember;
    }

    @AuraEnabled
    public static List<RelationshipMapMemberWrapper> getSuggestedContactsByAccountPlan(
        Id accountPlanId,
        List<pq_Condition__c> conditions,
        String operator
    ) {
        List<Relationship_Map__c> maps = RelationshipMapSelector.newInstance()
            .selectByAccountPlanIds(new Set<Id>{ accountPlanId });
        if (maps == null || maps.isEmpty()) {
            return new List<RelationshipMapMemberWrapper>();
        }
        Relationship_Map__c relationshipMap = maps.get(0);
        Id mapId = relationshipMap.Id;
        String query = '';
        if (conditions != null && conditions.size() > 0) {
            query = generateQuery(conditions, operator);
        }

        return getSuggestedContactsByRelationshipMap(mapId, accountPlanId, query);
    }

    @AuraEnabled
    public static List<RelationshipMapMemberWrapper> getSuggestedContactsByRelationshipMap(
        Id mapId,
        List<pq_Condition__c> conditions,
        String operator
    ) {
        List<Relationship_Map__c> maps = RelationshipMapSelector.newInstance().selectByIds(new Set<Id>{ mapId });
        if (maps == null || maps.isEmpty()) {
            return new List<RelationshipMapMemberWrapper>();
        }
        Relationship_Map__c relationshipMap = maps.get(0);
        Id accountPlanId = relationshipMap.pq_AccountPlanId__c;
        if (accountPlanId == null) {
            return new List<RelationshipMapMemberWrapper>();
        }
        String query = '';
        if (conditions.size() > 0) {
            query = generateQuery(conditions, operator);
        }
        return getSuggestedContactsByRelationshipMap(mapId, accountPlanId, query);
    }

    public static List<RelationshipMapMemberWrapper> getSuggestedContactsByRelationshipMap(
        Id mapId,
        Id accountPlanId,
        String query
    ) {
        pqcrush__Account_Plan__c accountPlan = AccountPlanSelector.newInstance()
            .selectById(new Set<Id>{ accountPlanId })[0];

        List<RelationshipMapMemberWrapper> wrapperList = new List<RelationshipMapMemberWrapper>();

        List<Relationship_Map_Member__c> members = RelationshipMapMemberSelector.newInstance()
            .selectByMapIds(new Set<Id>{ mapId });

        Set<Id> memberContactIds = new Set<Id>();
        for (Relationship_Map_Member__c member : members) {
            memberContactIds.add(member.Contact__c);
        }

        Set<String> additionalFields = new Set<String>{ 'Name', 'FirstName', 'LastName', 'Title', 'LastModifiedDate' };

        List<Contact> contacts = ContactSelector.newInstance()
            .selectByAccountIdWithCustomCondition(
                additionalFields,
                new Set<Id>{ accountPlan.Account__c },
                memberContactIds,
                1000,
                query
            );

        if (!contacts.isEmpty()) {
            for (Contact record : contacts) {
                Relationship_Map_Member__c mapMember = new Relationship_Map_Member__c(
                    Relationship_Map__c = mapId,
                    Contact__c = record.Id
                );

                wrapperList.add(new RelationshipMapMemberWrapper(mapMember, record));
            }
        }
        return wrapperList;
    }

    public static String generateQuery(List<pq_Condition__c> conditions, String operator) {
        String query = '';
        if (conditions != null) {
            query += '(';
            for (integer i = 0; i < conditions.size(); i++) {
                query += conditions[i].pqcrush__Field__c;

                query += conditions(conditions[i].pqcrush__Operator__c);

                String fieldType = UTIL_Describe.getFieldType('Contact', conditions[i].pqcrush__Field__c);

                if (checkType(fieldType) || checkType(conditions[i].pqcrush__Value__c)) {
                    query += conditions[i].pqcrush__Value__c;
                } else {
                    query += '\'' + conditions[i].pqcrush__Value__c + '\'';
                }

                if (i < conditions.size() - 1) {
                    query += ' ' + operator + ' ';
                }
            }
            query += ')';
        }
        return query;
    }

    public static Boolean checkType(String fieldType) {
        Boolean checkType = false;
        switch on fieldType {
            when 'DATETIME', 'DATE', 'TRUE', 'true', 'True', 'FALSE', 'false', 'False' {
                checkType = true;
            }
        }
        return checkType;
    }

    public static String conditions(String condition) {
        switch on condition {
            when 'EQUALS' {
                condition = ' = ';
            }
            when 'NOT_EQUAL_TO' {
                condition = ' != ';
            }
            when 'GREATER_THAN' {
                condition = ' > ';
            }
            when 'GREATER_THAN_OR_EQUAL_TO' {
                condition = ' >= ';
            }
            when 'LESS_THAN' {
                condition = ' < ';
            }
            when 'LESS_THAN_OR_EQUAL_TO' {
                condition = ' <= ';
            }
            when 'IS_IN' {
                condition = ' IN ';
            }
            when 'IS_NOT_IN' {
                condition = ' NOT IN ';
            }
            when 'IS_LIKE' {
                condition = ' LIKE ';
            }
            when 'IS_NOT_LIKE' {
                condition = ' NOT LIKE ';
            }
            when else {
                condition = null;
            }
        }
        return condition;
    }
}