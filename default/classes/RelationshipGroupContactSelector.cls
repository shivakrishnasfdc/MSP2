// Relationship Group Contact Association Selector

public with sharing class RelationshipGroupContactSelector extends fflib_SObjectSelector {
    public RelationshipGroupContactSelector() {
        super(false, true, false);
    }

    public static RelationshipGroupContactSelector newInstance() {
        return (RelationshipGroupContactSelector) Application.Selector.newInstance(
            Relationship_Group_Contact_Association__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Relationship_Group_Contact_Association__c.Id,
            Relationship_Group_Contact_Association__c.Contact__c,
            Relationship_Group_Contact_Association__c.Relationship_Group__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Relationship_Group_Contact_Association__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Relationship_Group_Contact_Association__c> selectById(Set<Id> ids) {
        return (List<Relationship_Group_Contact_Association__c>) selectSObjectsById(ids);
    }

    public List<Relationship_Group_Contact_Association__c> selectByContactIds(Set<String> contactIds) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Contact__c IN :contactIds');
        return Database.query(query.toSOQL());
    }

    public List<Relationship_Group_Contact_Association__c> selectWithGroupsByContactIds(Set<Id> contactIds) {
        Set<String> queryFields = new Set<String>();
        queryFields.add('Relationship_Group__c.Id');
        queryFields.add('Relationship_Group__c.Label__c');
        queryFields.add('Relationship_Group__c.Parent_Relationship_Group__c');
        queryFields.add('Relationship_Group__c.Account_Plan__c');
        queryFields.add('Relationship_Group__c.Relationship_Map__c');
        queryFields.add('Relationship_Group__c.Relationship_Map__c.Name');
        queryFields.add('Relationship_Group__c.Account_Plan__c.Name');

        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Contact__c IN :contactIds')
            .selectFields(queryFields);

        return Database.query(query.toSOQL());
    }

   

    public List<Relationship_Group_Contact_Association__c> selectByContactIdsForLocalGroup(
        Set<String> contactIds,
        Id mapOrAccountPlanId
    ) {
        if (mapOrAccountPlanId == null) {
            return new List<Relationship_Group_Contact_Association__c>();
        }

        String condition =
            'Contact__c IN :contactIds AND Relationship_Group__r.' +
            mapOrAccountPlanId.getSobjectType() +
            ' = :mapOrAccountPlanId';

        fflib_QueryFactory query = newQueryFactory().setCondition(condition);

        return Database.query(query.toSOQL());
    }

    public List<Relationship_Group_Contact_Association__c> selectByContactIdsForGlobalGroup(Set<String> contactIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'Contact__c IN :contactIds AND (Relationship_Group__r.Relationship_Map__c = null AND Relationship_Group__r.Account_Plan__c = null)'
            );

        return Database.query(query.toSOQL());
    }
}