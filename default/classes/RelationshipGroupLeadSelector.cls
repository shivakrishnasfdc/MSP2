// Relationship Group Contact Association Selector

public with sharing class RelationshipGroupLeadSelector extends fflib_SObjectSelector {
    public RelationshipGroupLeadSelector() {
        super(false, true, false);
    }

    public static RelationshipGroupLeadSelector newInstance() {
        return (RelationshipGroupLeadSelector) Application.Selector.newInstance(
            Relationship_Group_Lead_Association__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Relationship_Group_Lead_Association__c.Id,
            Relationship_Group_Lead_Association__c.Lead__c,
            Relationship_Group_Lead_Association__c.Relationship_Group__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Relationship_Group_Lead_Association__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Relationship_Group_Lead_Association__c> selectById(Set<Id> ids) {
        return (List<Relationship_Group_Lead_Association__c>) selectSObjectsById(ids);
    }

    public List<Relationship_Group_Lead_Association__c> selectByLeadIds(Set<String> leadIds) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Lead__c IN :leadIds');
        return Database.query(query.toSOQL());
    }

    public List<Relationship_Group_Lead_Association__c> selectWithGroupsByLeadIds(Set<Id> leadIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Lead__c IN :leadIds')
            .selectFields(composeQueryFields());
        return Database.query(query.toSOQL());
    }

    public List<Relationship_Group_Lead_Association__c> selectByLeadIdsForLocalGroup(
        Set<String> leadIds,
        Id mapOrAccountPlanId
    ) {
        if (mapOrAccountPlanId == null) {
            return new List<Relationship_Group_Lead_Association__c>();
        }

        String condition =
            'Lead__c IN :leadIds AND Relationship_Group__r.' +
            mapOrAccountPlanId.getSobjectType() +
            ' = :mapOrAccountPlanId';

        fflib_QueryFactory query = newQueryFactory().setCondition(condition).selectFields(composeQueryFields());

        return Database.query(query.toSOQL());
    }

    public List<Relationship_Group_Lead_Association__c> selectByLeadIdsForGlobalGroup(Set<String> leadIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'Lead__c IN :leadIds AND (Relationship_Group__r.Relationship_Map__c = null AND Relationship_Group__r.Account_Plan__c = null)'
            )
            .selectFields(composeQueryFields());

        return Database.query(query.toSOQL());
    }

    private Set<String> composeQueryFields() {
        Set<String> queryFields = new Set<String>();
        queryFields.add('Relationship_Group__c.Id');
        queryFields.add('Relationship_Group__c.Label__c');
        queryFields.add('Relationship_Group__c.Parent_Relationship_Group__c');
        queryFields.add('Relationship_Group__c.Account_Plan__c');
        queryFields.add('Relationship_Group__c.Relationship_Map__c');

        return queryFields;
    }
}