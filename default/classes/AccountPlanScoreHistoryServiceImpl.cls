public with sharing class AccountPlanScoreHistoryServiceImpl {
    public void insertScores(List<pq_Account_Plan_Score_History__c> scores) {
        if (scores == null || scores.size() <= 0) {
            return;
        }

        if (scores[0].Year_Week__c <= 0) {
            return;
        }

        List<pq_Account_Plan_Score_History__c> foundScores = AccountPlanScoreHistorySelector.newInstance()
            .selectByYearWeek(scores[0].Year_Week__c);

        List<pq_Account_Plan_Score_History__c> newScores = new List<pq_Account_Plan_Score_History__c>();
        Set<Id> planIdsWithScores = new Set<Id>();
        for (pq_Account_Plan_Score_History__c foundScore : foundScores) {
            planIdsWithScores.add(foundScore.Account_Plan__c);
        }

        for (pq_Account_Plan_Score_History__c score : scores) {
            if (!planIdsWithScores.contains(score.Account_Plan__c)) {
                newScores.add(score);
            }
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerNew(newScores);
        new SystemContext().commitWork(uow);
    }

    private without sharing class SystemContext {
        private void commitWork(fflib_ISObjectUnitOfWork uow) {
            uow.commitWork();
        }
    }
}