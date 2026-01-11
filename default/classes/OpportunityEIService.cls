public with sharing class OpportunityEIService {
    private static OpportunityEIServiceImpl instance = null;

    public static void processOpportunityForDate(List<Opportunity> opps, Date d) {
        service().processOpportunityForDate(opps, d);
    }

    // public static void processRedosForList(List<Opportunity> opps, List<OpportunityContactRole> ocrs) {
    //     service().processRedosForList(opps, ocrs);
    // }
    
    public static void processRollingData(Integer numberOfDaysToRollData) {
        service().processRollingData(numberOfDaysToRollData);
    }
    

    private static OpportunityEIServiceImpl service() {
        if (instance == null) {
            instance = (OpportunityEIServiceImpl) Application.Service.newInstance(OpportunityEIServiceImpl.class);
        }
        return instance;
    }
}