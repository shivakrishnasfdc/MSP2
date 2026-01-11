public with sharing class AccountPlanScoreHistoryWrapper {
    @AuraEnabled
    public List<string> labels { get; set; }
    @AuraEnabled
    public List<PlanScore> planScores { get; set; }

    public AccountPlanScoreHistoryWrapper(List<String> labels, List<PlanScore> planScores) {
        this.labels = labels;
        this.planScores = planScores;
    }

    public static AccountPlanScoreHistoryWrapper convert(List<pq_Account_Plan_Score_History__c> scores) {
        if (scores == null || scores.size() <= 0) {
            return new AccountPlanScoreHistoryWrapper(new List<String>(), new List<PlanScore>());
        }

        Set<String> yAxis = new Set<String>(); // also called labels in chartjs

        Set<Decimal> yearWeekSet = new Set<Decimal>();
        for (pq_Account_Plan_Score_History__c phscore : scores) {
            yearWeekSet.add(phscore.Year_Week__c);
        }

        Map<Id, Map<Decimal, pq_Account_Plan_Score_History__c>> mapmap = new Map<Id, Map<Decimal, pq_Account_Plan_Score_History__c>>();
        Map<Id, PlanScore> mapPlans = new Map<Id, PlanScore>();
        for (pq_Account_Plan_Score_History__c phscore : scores) {
            Map<Decimal, pq_Account_Plan_Score_History__c> mapDecimal;
            if (!mapmap.containsKey(phscore.Account_Plan__c)) {
                mapDecimal = new Map<Decimal, pq_Account_Plan_Score_History__c>();
                mapPlans.put(phscore.Account_Plan__c, new PlanScore(phscore.Account_Plan__r.Name));
            } else {
                mapDecimal = mapmap.get(phscore.Account_Plan__c);
            }

            mapDecimal.put(phscore.Year_Week__c, phscore);
            mapmap.put(phscore.Account_Plan__c, mapDecimal);
        }

        for (Decimal yearWeek : yearWeekSet) {
            yAxis.add(String.valueOf(yearWeek));
            for (Id planId : mapPlans.KeySet()) {
                PlanScore planScore = mapPlans.get(planId);
                // Get score for week
                Map<Decimal, pq_Account_Plan_Score_History__c> mapscore = mapmap.get(planId);
                if (mapscore == null) {
                    planScore.scores.add(-1);
                    continue;
                }

                pq_Account_Plan_Score_History__c apsh = mapscore.get(yearWeek);
                if (apsh == null) {
                    planScore.scores.add(-1);
                } else {
                    planScore.scores.add(apsh.Score__c);
                }
                mapPlans.put(planId, planScore);
            }
        }

        List<String> labels = new List<String>(yAxis);
        List<PlanScore> planScores = mapPlans.values();
        return new AccountPlanScoreHistoryWrapper(labels, planScores);
    }
}