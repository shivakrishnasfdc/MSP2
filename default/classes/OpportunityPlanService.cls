public with sharing class OpportunityPlanService {
    public static Query getQueryForOpportunitiesWithoutPlans() {
        return service().getQueryForOpportunitiesWithoutPlans();
    }

    public static List<PQ_Opportunity_Plan__c> createOpportunityPlans(List<Opportunity> opportunities) {
        return service().createOpportunityPlans(opportunities);
    }

    public static List<Relationship_Map__c> getRelationshipMapsForOppPlanId(Id oppPlanId, Boolean createIfNeeded) {
        return service().getRelationshipMapsForOppPlanId(oppPlanId, createIfNeeded);
    }

    public static Relationship_Map__c createRelationshipMapForOppPlanId(Id oppPlanId) {
        return service().createRelationshipMapForOppPlanId(oppPlanId);
    }

    public static Id getAccountIdForOppPlanId(Id oppPlanId) {
        return service().getAccountIdForOppPlanId(oppPlanId);
    }

    public static Boolean hasOpportunityPlanSetting(Id mapId) {
        return service().hasOpportunityPlanSetting(mapId);
    }

    private static OpportunityPlanServiceImpl service() {
        return (OpportunityPlanServiceImpl) Application.Service.newInstance(OpportunityPlanServiceImpl.class);
    }
}