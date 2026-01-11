public with sharing class OpportunityPlanController {
    @AuraEnabled
    public static Id getRelationshipMapIdForPlanId(Id oppPlanId) {
        if (oppPlanId == null) {
            return null;
        }
        if (oppPlanId.getSobjectType() == Opportunity.getSObjectType()) {
            oppPlanId = getPlanIdForOpportunityId(oppPlanId);
        }
        if (oppPlanId == null || oppPlanId.getSobjectType() != PQ_Opportunity_Plan__c.SObjectType) {
            return null;
        }
        List<pqcrush__Relationship_Map__c> maps = OpportunityPlanService.getRelationshipMapsForOppPlanId(
            oppPlanId,
            true
        );
        if (maps.size() == 0) {
            return null;
        }
        return maps[0].Id;
    }

    @AuraEnabled
    public static Id getPlanIdForOpportunityId(Id opportunityId) {
        if (opportunityId == null) {
            return null;
        }
        if (OpportunityId.getSobjectType() == PQ_Opportunity_Plan__c.SObjectType) {
            return opportunityId;
        }
        if (opportunityId.getSobjectType() != Opportunity.SObjectType) {
            return null;
        }
        List<PQ_Opportunity_Plan__c> plans = OpportunityPlanSelector.newInstance()
            .selectByOpportunityIds(new Set<Id>{ opportunityId });
        if (plans.isEmpty()) {
            return null;
        }
        PQ_Opportunity_Plan__c plan = null;
        if (plans.size() > 0) {
            plan = plans[0];  
        }
        return plan != null ? plan.Id : null;
    }

    @AuraEnabled
    public static OpportunityScoreData getOpportunityScoreForOpportunityPlan(Id opportunityPlanId) {

        List<pq_Opportunity_Plan__c> plans = OpportunityPlanSelector.newInstance().selectByIds(new Set<Id>{ opportunityPlanId });

        if (plans == null || plans.isEmpty()) {
            return new OpportunityScoreData();
        }
        PQ_Opportunity_Plan__c plan = plans[0];
        Id opportunityId = plan.Opportunity__c;

        Map<Id, OpportunityScoreData> oppIdXOppData = OpportunityScoreService.calculateOpportunityScore(new Set<Id>{ opportunityId });

        OpportunityScoreData result = oppIdXOppData.get(opportunityId);

        return result != null ? result : new OpportunityScoreData();

    }

    @AuraEnabled
    public static OpportunityScoreData getOpportunityScoreForOpportunity(Id opportunityId) {
        if (opportunityId == null) {
        return new OpportunityScoreData();
        }
        Map<Id, OpportunityScoreData> oppIdXOppData = OpportunityScoreService.calculateOpportunityScore(new Set<Id>{ opportunityId });
        if (oppIdXOppData != null && oppIdXOppData.containsKey(opportunityId)) {
            return oppIdXOppData.get(opportunityId);
        }
        return new OpportunityScoreData();

    }
}