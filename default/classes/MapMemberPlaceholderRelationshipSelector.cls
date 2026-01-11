public with sharing class MapMemberPlaceholderRelationshipSelector extends fflib_SObjectSelector {
    public static MapMemberPlaceholderRelationshipSelector newInstance() {
        return (MapMemberPlaceholderRelationshipSelector) Application.Selector.newInstance(
            Map_Member_Placeholder_Relationship__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Map_Member_Placeholder_Relationship__c.Id,
            Map_Member_Placeholder_Relationship__c.To__c,
            Map_Member_Placeholder_Relationship__c.From__c,
            Map_Member_Placeholder_Relationship__c.Label__c,
            Map_Member_Placeholder_Relationship__c.Type__c,
            Map_Member_Placeholder_Relationship__c.TempId__c,
            Map_Member_Placeholder_Relationship__c.Account_Plan__c,
            Map_Member_Placeholder_Relationship__c.Relationship_Map__c,
            Map_Member_Placeholder_Relationship__c.Is_Hierarchy__c,
            Map_Member_Placeholder_Relationship__c.Contact_Relationship_Type__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Map_Member_Placeholder_Relationship__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Map_Member_Placeholder_Relationship__c> selectById(Set<Id> ids) {
        return (List<Map_Member_Placeholder_Relationship__c>) selectSObjectsById(ids);
    }

    public List<Map_Member_Placeholder_Relationship__c> selectByTo(Set<String> to, Set<Id> mapOrAccountPlanId) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'To__c IN :to AND (Account_Plan__c in :mapOrAccountPlanId OR Relationship_Map__c in :mapOrAccountPlanId)'
            );
        return Database.query(query.toSOQL());
    }

    public List<Map_Member_Placeholder_Relationship__c> selectByToOrFrom(Set<String> toOrFrom) {
        fflib_QueryFactory query = newQueryFactory().setCondition('To__c IN :toOrFrom OR From__c IN :toOrFrom');
        return Database.query(query.toSOQL());
    }

    public List<Map_Member_Placeholder_Relationship__c> selectActiveCustomRelsByToOrFrom(Set<String> toOrFrom) {
        Set<String> queryFields = additionalQueryFields();
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'Contact_Relationship_Type__c != null AND Contact_Relationship_Type__r.pqcrush__IsActive__c = true AND (To__c IN :toOrFrom OR From__c IN :toOrFrom)'
            )
            .selectFields(queryFields);
        return Database.query(query.toSOQL());
    }

    public List<Map_Member_Placeholder_Relationship__c> selectByIdOrTempKey(Set<String> keys) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Id IN :keys OR TempId__c IN :keys');
        return Database.query(query.toSOQL());
    }

    public List<Map_Member_Placeholder_Relationship__c> selectLocalRelationshipsById(
        Set<String> ids,
        Id mapOrAccountPlanId,
        Boolean hasAccountPlanSetting
    ) {
        if (mapOrAccountPlanId == null) {
            return new List<Map_Member_Placeholder_Relationship__c>();
        }

        String fieldCondition = '';
        String usedInString = 'pqcrush__Used_in_all_relationship_maps__c';
        if (hasAccountPlanSetting) {
            usedInString = 'pqcrush__Used_in_all_account_plans__c';
        }

        Set<Id> relTypeIds = ContactRelationshipTypeSelector.newInstance()
            .getRelationshipTypesFromJunction(mapOrAccountPlanId);
        if (relTypeIds.size() > 0) {
            fieldCondition =
                '(Contact_Relationship_Type__r.' +
                usedInString +
                ' = true OR Contact_Relationship_Type__c IN :relTypeIds)';
        } else {
            fieldCondition = 'Contact_Relationship_Type__r.' + usedInString + ' = true';
        }

        Set<String> queryFields = additionalQueryFields();

        String condition =
            'Contact_Relationship_Type__c != null AND Contact_Relationship_Type__r.pqcrush__IsActive__c = true AND ' +
            fieldCondition +
            ' AND (To__c IN :ids OR From__c IN :ids) AND ' +
            mapOrAccountPlanId.getSobjectType() +
            ' = :mapOrAccountPlanId';

        fflib_QueryFactory query = newQueryFactory().setCondition(condition).selectFields(queryFields);

        return Database.query(query.toSOQL());
    }

    public List<Map_Member_Placeholder_Relationship__c> selectGlobalRelationshipsById(
        Set<String> ids,
        Id mapOrAccountPlanId,
        Boolean hasAccountPlanSetting
    ) {
        String fieldCondition = '';
        String usedInString = 'pqcrush__Used_in_all_relationship_maps__c';
        if (hasAccountPlanSetting) {
            usedInString = 'pqcrush__Used_in_all_account_plans__c';
        }

        Set<Id> relTypeIds = ContactRelationshipTypeSelector.newInstance()
            .getRelationshipTypesFromJunction(mapOrAccountPlanId);
        if (relTypeIds.size() > 0) {
            fieldCondition =
                '(Contact_Relationship_Type__r.' +
                usedInString +
                ' = true OR Contact_Relationship_Type__c IN :relTypeIds)';
        } else {
            fieldCondition = 'Contact_Relationship_Type__r.' + usedInString + ' = true';
        }

        String condition =
            'Contact_Relationship_Type__c != null AND Contact_Relationship_Type__r.pqcrush__IsActive__c = true AND ' +
            fieldCondition +
            ' AND (From__c IN :ids OR To__c IN :ids) AND pqcrush__Account_Plan__c = null AND pqcrush__Relationship_Map__c = null';

        Set<String> queryFields = additionalQueryFields();
        fflib_QueryFactory query = newQueryFactory().setCondition(condition).selectFields(queryFields);

        return Database.query(query.toSOQL());
    }

    public List<Map_Member_Placeholder_Relationship__c> selectHierarchyLinksByPlaceholderId(
        Set<Id> mapOrAccountPlanId,
        Set<String> ids
    ) {
        Set<String> queryFields = additionalQueryFields();
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'Is_Hierarchy__c = true AND Contact_Relationship_Type__c = null AND (To__c IN :ids OR From__c IN :ids) AND (Account_Plan__c in :mapOrAccountPlanId OR Relationship_Map__c in :mapOrAccountPlanId)'
            )
            .selectFields(queryFields);
        return Database.query(query.toSOQL());
    }

    public List<Map_Member_Placeholder_Relationship__c> selectHierarchyLinksByContactId(Set<String> ids) {
        Set<String> queryFields = additionalQueryFields();
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'Is_Hierarchy__c = true AND Contact_Relationship_Type__c = null AND (To__c IN :ids OR From__c IN :ids)'
            )
            .selectFields(queryFields);
        return Database.query(query.toSOQL());
    }

    private Set<String> additionalQueryFields() {
        Set<String> queryFields = new Set<String>();
        queryFields.add('Contact_Relationship_Type__c.Label_Editable__c');
        queryFields.add('Contact_Relationship_Type__c.Label__c');
        queryFields.add('Contact_Relationship_Type__c.Color__c');
        queryFields.add('Relationship_Map__c');
        queryFields.add('Account_Plan__c');
        queryFields.add('Relationship_Map__r.Name');
        queryFields.add('Account_Plan__r.Name');
        return queryFields;
    }

    
    public List<Map_Member_Placeholder_Relationship__c> selectByAccountPlanIdAndSelectFields(Set<Id> ids, Set<String> queryFields) {
        System.debug('===notSelectByIdAndSelectFields called====');
        System.debug('===queryFields===='+queryFields);
        System.debug('===set ids===='+ids);
        if (queryFields == null) {
            queryFields = new Set<String>();
        }
        return Database.query(newQueryFactory().selectFields(queryFields).setCondition('pqcrush__Account_Plan__c IN :ids').toSOQL());
    }
}