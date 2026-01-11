@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing class OpportunityScoreService {
    private static OpportunityScoreServiceImpl instance = null;

    public static String WON_KEY = 'Won';
    public static String LOST_KEY = 'Lost';
    public static String HAS_CONTACT_KEY = 'HasContact';
    public static String TOTAL_KEY = 'Total';

    public static OpportunityEffectivenessData calculateOpportunityEfficiencyIndex(List<Opportunity> opps) {
        return service().calculateOpportunityEfficiencyIndex(opps);
    }

    public static OpportunityEffectivenessData mergeData(OpportunityEffectivenessData newData, OpportunityEffectivenessData oldData) {
        return service().mergeData(newData, oldData);
    }

    public static Map<Id, OpportunityScoreData> calculateOpportunityScore(Set<Id> opportunityIds) {
        return service().calculateOpportunityScore(opportunityIds);
    }

    private static OpportunityScoreServiceImpl service() {
        if (instance == null) {
            instance = (OpportunityScoreServiceImpl) Application.Service.newInstance(OpportunityScoreServiceImpl.class);
        }
        return instance;
    }
}