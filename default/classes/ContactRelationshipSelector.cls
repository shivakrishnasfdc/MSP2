public with sharing class ContactRelationshipSelector extends fflib_SObjectSelector {
    public ContactRelationshipSelector() {
        super(false, true, false);
    }

    public static ContactRelationshipSelector newInstance() {
        return (ContactRelationshipSelector) Application.Selector.newInstance(Contact_Relationship__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Contact_Relationship__c.Id,
            Contact_Relationship__c.Account_Plan__c,
            Contact_Relationship__c.Contact_Relationship_Type__c,
            Contact_Relationship__c.From_Contact__c,
            Contact_Relationship__c.To_Contact__c,
            Contact_Relationship__c.Label__c,
            Contact_Relationship__c.TempId__c,
            Contact_Relationship__c.Account_Plan__c,
            Contact_Relationship__c.Relationship_Map__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Contact_Relationship__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Contact_Relationship__c> selectById(Set<Id> ids) {
        return (List<Contact_Relationship__c>) selectSObjectsById(ids);
    }

    public List<Contact_Relationship__c> selectByIdOrTempKey(Set<String> keys) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Id IN :keys OR TempId__c IN :keys');
        return Database.query(query.toSOQL());
    }

    public List<Contact_Relationship__c> selectActiveCustomRelsByToOrFrom(Set<String> toOrFrom) {
        Set<String> queryFields = additionalQueryFields();
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'Contact_Relationship_Type__c != null AND Contact_Relationship_Type__r.pqcrush__IsActive__c = true AND (To_Contact__c IN :toOrFrom OR From_Contact__c IN :toOrFrom)'
            )
            .selectFields(queryFields);
        return Database.query(query.toSOQL());
    }

    public List<Contact_Relationship__c> selectLocalRelationshipsById(
        Set<Id> ids,
        Id mapOrAccountPlanId,
        Boolean hasAccountPlanSetting
    ) {
        if (mapOrAccountPlanId == null) {
            return new List<Contact_Relationship__c>();
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
            ' AND (From_Contact__c IN :ids OR To_Contact__c IN :ids) AND ' +
            mapOrAccountPlanId.getSobjectType() +
            ' = :mapOrAccountPlanId';

        fflib_QueryFactory query = newQueryFactory().setCondition(condition).selectFields(queryFields);

        return Database.query(query.toSOQL());
    }

    public List<Contact_Relationship__c> selectGlobalRelationshipsById(
        Set<Id> ids,
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
            ' AND (From_Contact__c IN :ids OR To_Contact__c IN :ids) AND pqcrush__Account_Plan__c = null AND pqcrush__Relationship_Map__c = null';

        Set<String> queryFields = additionalQueryFields();
        fflib_QueryFactory query = newQueryFactory().setCondition(condition).selectFields(queryFields);

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
}