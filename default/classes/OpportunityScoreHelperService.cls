public with sharing class OpportunityScoreHelperService {
    private static OpportunityScoreHelperServiceImpl instance = null;

    public static Map<Id, List<OpportunityContactRole>> getMapOppsContactRole(Set<Id> oppIds) {
        return service().getMapOppsContactRole(oppIds);
    }

    public static OpportunityScoreData calculateOpportunityScoreData(List<OpportunityContactRole> ocrs, OpportunityEffectivenessData oeData) {
        return service().calculateOpportunityScoreData(ocrs, oeData);
    }

    private static OpportunityScoreHelperServiceImpl service() {
        if (instance == null) {
            instance = (OpportunityScoreHelperServiceImpl) Application.Service.newInstance(OpportunityScoreHelperServiceImpl.class);
        }
        return instance;
    }
}