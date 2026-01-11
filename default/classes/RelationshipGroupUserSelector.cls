public with sharing class RelationshipGroupUserSelector extends fflib_SObjectSelector {
    public static RelationshipGroupUserSelector newInstance() {
        return (RelationshipGroupUserSelector) Application.Selector.newInstance(
            Relationship_Group_User_Association__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Relationship_Group_User_Association__c.Id,
            Relationship_Group_User_Association__c.User__c,
            Relationship_Group_User_Association__c.Relationship_Group__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Relationship_Group_User_Association__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Relationship_Group_User_Association__c> selectById(Set<Id> ids) {
        return (List<Relationship_Group_User_Association__c>) selectSObjectsById(ids);
    }

    public List<Relationship_Group_User_Association__c> selectByUserIds(Set<String> userIds) {
        fflib_QueryFactory query = newQueryFactory().setCondition('User__c IN :userIds');
        return Database.query(query.toSOQL());
    }

    public List<Relationship_Group_User_Association__c> selectWithGroupsByUserIds(Set<Id> userIds) {
        Set<String> queryFields = new Set<String>();
        queryFields.add('Relationship_Group__c.Id');
        queryFields.add('Relationship_Group__c.Label__c');
        queryFields.add('Relationship_Group__c.Parent_Relationship_Group__c');
        queryFields.add('Relationship_Group__c.Account_Plan__c');
        queryFields.add('Relationship_Group__c.Relationship_Map__c');

        fflib_QueryFactory query = newQueryFactory().setCondition('User__c IN :userIds').selectFields(queryFields);

        return Database.query(query.toSOQL());
    }

    public List<Relationship_Group_User_Association__c> selectByUserIdsForLocalGroup(
        Set<String> userIds,
        Id mapOrAccountPlanId
    ) {
        if (mapOrAccountPlanId == null) {
            return new List<Relationship_Group_User_Association__c>();
        }

        String condition =
            'User__c IN :userIds AND Relationship_Group__r.' +
            mapOrAccountPlanId.getSobjectType() +
            ' = :mapOrAccountPlanId';

        fflib_QueryFactory query = newQueryFactory().setCondition(condition);

        return Database.query(query.toSOQL());
    }

    public List<Relationship_Group_User_Association__c> selectByUserIdsForGlobalGroup(Set<String> userIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'User__c IN :userIds AND (Relationship_Group__r.Relationship_Map__c = null AND Relationship_Group__r.Account_Plan__c = null)'
            );

        return Database.query(query.toSOQL());
    }
}