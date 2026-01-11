public with sharing class OpportunityEIAssociationSelector extends fflib_SObjectSelector {
    /******************************
     *      STATIC METHODS
     ******************************/

    public static OpportunityEIAssociationSelector newInstance() {
        return (OpportunityEIAssociationSelector) Application.Selector.newInstance(pq_Opportunity_Effectiveness_Association__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            pq_Opportunity_Effectiveness_Association__c.Id,
            pq_Opportunity_Effectiveness_Association__c.Opportunity_Effectiveness_Index__c,
            pq_Opportunity_Effectiveness_Association__c.Opportunity__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return pq_Opportunity_Effectiveness_Association__c.sObjectType;
    }

    public override String getOrderBy() {
        return pq_Opportunity_Effectiveness_Association__c.LastModifiedDate.getDescribe().getName() + ' DESC';
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<pq_Opportunity_Effectiveness_Association__c> selectByOpportunities(Set<Id> opportunityIds) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Opportunity__c in :opportunityIds');
        return Database.query(query.toSOQL());
    }

    public List<pq_Opportunity_Effectiveness_Association__c> selectByOEI(Set<Id> opportunityEffectivenessIndexIds) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Opportunity_Effectiveness_Index__c in :opportunityEffectivenessIndexIds');
        return Database.query(query.toSOQL());
    }

    
}