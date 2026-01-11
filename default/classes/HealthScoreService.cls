public with sharing class HealthScoreService {
    public static Double getTotalScoreForAccountPlan(Account_Plan__c accountPlan) {
        List<PQ_AP_Score__mdt> allMetadata = service().getValidScoreMetadata();
        return service().getTotalScoreForAccountPlan(accountPlan, allMetadata);
    }

    public static Double getTotalScoreForAccountPlanPercent(Account_Plan__c accountPlan) {
        List<PQ_AP_Score__mdt> allMetadata = service().getValidScoreMetadata();
        return service().getTotalScoreForAccountPlanPercent(accountPlan, allMetadata);
    }

    public static Double getTotalScoreForAccountPlan(Account_Plan__c accountPlan, List<PQ_AP_Score__mdt> allMetadata) {
        return service().getTotalScoreForAccountPlan(accountPlan, allMetadata);
    }
    public static Double getTotalScoreForAccountPlanPercent(
        Account_Plan__c accountPlan,
        List<PQ_AP_Score__mdt> allMetadata
    ) {
        return service().getTotalScoreForAccountPlanPercent(accountPlan, allMetadata);
    }

    public static Double getMaxTotalScore() {
        return service().getMaxTotalScore();
    }

    public static Double getMaxTotalScorePercent() {
        return service().getMaxTotalScorePercent();
    }

    public static Set<String> getAccountPlanFieldNamesForScoreMetadata(List<PQ_AP_Score__mdt> scoreMetadata) {
        return service().getAccountPlanFieldNamesForScoreMetadata(scoreMetadata);
    }

    public static List<PQ_AP_Score__mdt> getValidScoreMetadata() {
        return service().getValidScoreMetadata();
    }

    public static ColorBoundary getColorBoundaryFromSettings(CRUSH_Settings_Obj__c settings) {
        return service().getColorBoundaryFromSettings(settings);
    }

    public static Double getScoreFromPlanForMetadata(Account_Plan__c accountPlan, PQ_AP_Score__mdt metadata) {
        return service().getScoreFromPlanForMetadata(accountPlan, metadata);
    }

    public static Double getScoreFromPlanForMetadataPercent(Account_Plan__c accountPlan, PQ_AP_Score__mdt metadata) {
        return service().getScoreFromPlanForMetadataPercent(accountPlan, metadata);
    }

    private static HealthScoreServiceImpl service() {
        return (HealthScoreServiceImpl) Application.Service.newInstance(HealthScoreServiceImpl.class);
    }
}