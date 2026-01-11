public with sharing class OpportunityPlanSelector extends fflib_SObjectSelector {
    public static OpportunityPlanSelector newInstance() {
        return (OpportunityPlanSelector) Application.Selector.newInstance(PQ_Opportunity_Plan__c.SObjectType);
    }

    /******************************
     *      QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            PQ_Opportunity_Plan__c.Id,
            PQ_Opportunity_Plan__c.Name,
            PQ_Opportunity_Plan__c.Opportunity__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return PQ_Opportunity_Plan__c.sObjectType;
    }

    /******************************
     *      SELECT METHODS
     ******************************/

    public List<PQ_Opportunity_Plan__c> selectByIds(Set<Id> idSet) {
        if (idSet == null || idSet.isEmpty()) {
            return new List<PQ_Opportunity_Plan__c>();
        }
        fflib_QueryFactory queryFactory = newQueryFactory();
        return (List<PQ_Opportunity_Plan__c>) Database.query(
            queryFactory.selectField('Opportunity__r.AccountId').setCondition('Id in :idSet').toSOQL()
        );
    }

    public List<PQ_Opportunity_Plan__c> selectByOpportunityIds(Set<Id> opportunityIdSet) {
        if (opportunityIdSet == null || opportunityIdSet.isEmpty()) {
            return new List<PQ_Opportunity_Plan__c>();
        }
        fflib_QueryFactory queryFactory = newQueryFactory();
        return (List<PQ_Opportunity_Plan__c>) Database.query(
            queryFactory.setCondition('Opportunity__c in :opportunityIdSet').toSOQL()
        );
    }
}