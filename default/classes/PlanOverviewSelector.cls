public with sharing class PlanOverviewSelector extends AccountPlanChildSelector {
    public static PlanOverviewSelector newInstance() {
        return (PlanOverviewSelector) Application.Selector.newInstance(pq_CRUSH_Plan_Overview__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            pq_CRUSH_Plan_Overview__c.Id,
            pq_CRUSH_Plan_Overview__c.Name,
            pq_CRUSH_Plan_Overview__c.Title__c,
            pq_CRUSH_Plan_Overview__c.Description__c,
            pq_CRUSH_Plan_Overview__c.Background_Color__c,
            pq_CRUSH_Plan_Overview__c.Account_Plan__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return pq_CRUSH_Plan_Overview__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<pq_CRUSH_Plan_Overview__c> selectById(Set<Id> idSet) {
        return (List<pq_CRUSH_Plan_Overview__c>) selectSObjectsById(idSet);
    }

    public List<pq_CRUSH_Plan_Overview__c> selectByAccountPlan(Set<Id> idSet, String dataKey, Boolean isGlobal) {
        fflib_QueryFactory queryFactory = newQueryFactory();

        if (isGlobal) {
            return Database.query(queryFactory.setCondition('Data_Key__c = :dataKey').toSOQL());
        }

        return Database.query(
            queryFactory.setCondition('Account_Plan__c IN :idSet AND Data_Key__c = :dataKey').toSOQL()
        );
    }
}