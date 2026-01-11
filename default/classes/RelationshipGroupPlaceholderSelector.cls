public with sharing class RelationshipGroupPlaceholderSelector extends fflib_SObjectSelector {
    public static RelationshipGroupPlaceholderSelector newInstance() {
        return (RelationshipGroupPlaceholderSelector) Application.Selector.newInstance(
            Relationship_Group_Placeholder_Assoc__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Relationship_Group_Placeholder_Assoc__c.Id,
            Relationship_Group_Placeholder_Assoc__c.Map_Member_Placeholder__c,
            Relationship_Group_Placeholder_Assoc__c.Relationship_Group__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Relationship_Group_Placeholder_Assoc__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Relationship_Group_Placeholder_Assoc__c> selectById(Set<Id> ids) {
        return (List<Relationship_Group_Placeholder_Assoc__c>) selectSObjectsById(ids);
    }

    public List<Relationship_Group_Placeholder_Assoc__c> selectByPlaceholderIds(Set<String> placeholderIds) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Map_Member_Placeholder__c IN :placeholderIds');
        return Database.query(query.toSOQL());
    }

    public List<Relationship_Group_Placeholder_Assoc__c> selectWithGroupsByPlaceholderIds(Set<String> placeholderIds) {
        Set<String> queryFields = new Set<String>();
        queryFields.add('Relationship_Group__c.Id');
        queryFields.add('Relationship_Group__c.Label__c');
        queryFields.add('Relationship_Group__c.Parent_Relationship_Group__c');

        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Map_Member_Placeholder__c IN :placeholderIds')
            .selectFields(queryFields);

        return Database.query(query.toSOQL());
    }

    public List<Relationship_Group_Placeholder_Assoc__c> selectByPlaceholderIdsForLocalGroup(
        Set<String> placeholderIds,
        Id mapOrAccountPlanId
    ) {
        if (mapOrAccountPlanId == null) {
            return new List<Relationship_Group_Placeholder_Assoc__c>();
        }

        String condition =
            'Map_Member_Placeholder__c IN :placeholderIds AND Relationship_Group__r.' +
            mapOrAccountPlanId.getSobjectType() +
            ' = :mapOrAccountPlanId';

        fflib_QueryFactory query = newQueryFactory().setCondition(condition);

        return Database.query(query.toSOQL());
    }

    public List<Relationship_Group_Placeholder_Assoc__c> selectByPlaceholderIdsForGlobalGroup(
        Set<String> placeholderIds
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'Map_Member_Placeholder__c IN :placeholderIds AND (Relationship_Group__r.Relationship_Map__c = null AND Relationship_Group__r.Account_Plan__c = null)'
            );

        return Database.query(query.toSOQL());
    }
}