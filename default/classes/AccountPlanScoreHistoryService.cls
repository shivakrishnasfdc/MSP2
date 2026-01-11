public with sharing class AccountPlanScoreHistoryService {
    private static AccountPlanScoreHistoryServiceImpl instance = null;

    public static void insertScores(List<pq_Account_Plan_Score_History__c> scores) {
        service().insertScores(scores);
    }

    private static AccountPlanScoreHistoryServiceImpl service() {
        if (instance == null) {
            instance = (AccountPlanScoreHistoryServiceImpl) Application.Service.newInstance(
                AccountPlanScoreHistoryServiceImpl.class
            );
        }
        return instance;
    }
}