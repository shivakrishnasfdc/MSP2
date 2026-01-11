@SuppressWarnings('PMD.AvoidGlobalModifier,PMD.EmptyStatementBlock')
global with sharing class ScheduleForAccountPlanScoreBatch implements Database.Batchable<Account_Plan__c>, Schedulable {
    /******************************
     *     Schedulable Methods
     ******************************/

    global void execute(SchedulableContext context) {
        Database.executeBatch(this);
    }

    /******************************
     *     Batchable Methods
     ******************************/

    global Iterable<Account_Plan__c> start(Database.BatchableContext context) {
        return AccountPlanSelector.newInstance().selectByStatus('Open');
    }

    global void execute(Database.BatchableContext context, List<Account_Plan__c> records) {
        List<pq_Account_Plan_Score_History__c> scoreHistories = new List<pq_Account_Plan_Score_History__c>();

        Date today = Date.Today();
        Date jan1 = Date.newInstance(today.Year(), 1, 1);
        Integer weeks = jan1.DaysBetween(today) / 7 + 1;

        Decimal yearweek = today.Year() * 100 + weeks;

        for (Account_Plan__c ap : records) {
            pq_Account_Plan_Score_History__c scoreHistory = new pq_Account_Plan_Score_History__c(
                Account_Plan__c = ap.Id,
                Year_Week__c = yearweek,
                Score__c = ap.Account_Plan_Score__c
            );
            scoreHistories.add(scoreHistory);
        }

        if (scoreHistories.size() > 0) {
            AccountPlanScoreHistoryService.insertScores(scoreHistories);
        }
    }

    global void finish(Database.BatchableContext context) {
    }
}