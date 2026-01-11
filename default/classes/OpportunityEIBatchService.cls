public with sharing class OpportunityEIBatchService {
    private static OpportunityEIBatchServiceImpl instance = null;

    public static void processOpportunity(List<Opportunity> opps, Date d) {
        service().processOpportunity(opps, d);
    }

    private static OpportunityEIBatchServiceImpl service() {
        if (instance == null) {
            instance = (OpportunityEIBatchServiceImpl) Application.Service.newInstance(OpportunityEIBatchServiceImpl.class);
        }
        return instance;
    }
}