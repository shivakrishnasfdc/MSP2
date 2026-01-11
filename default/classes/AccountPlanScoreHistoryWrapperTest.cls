@isTest
private class AccountPlanScoreHistoryWrapperTest {
    @isTest
    static void instanceTest() {
        List<String> labels = new List<String>();
        List<PlanScore> planScores = new List<PlanScore>();
        planScores.add(new PlanScore('test'));

        AccountPlanScoreHistoryWrapper wrapper = new AccountPlanScoreHistoryWrapper(labels, planScores);

        System.assertEquals('test', wrapper.planScores[0].name);
        System.assertEquals(0, wrapper.labels.size());
    }

    @isTest
    static void convertEmptyTest() {
        AccountPlanScoreHistoryWrapper result = AccountPlanScoreHistoryWrapper.convert(
            new List<pq_Account_Plan_Score_History__c>()
        );
        System.assertEquals(0, result.labels.size());
        System.assertEquals(0, result.planScores.size());
    }

    @isTest
    static void convertNullTest() {
        AccountPlanScoreHistoryWrapper result = AccountPlanScoreHistoryWrapper.convert(null);
        System.assertEquals(0, result.labels.size());
        System.assertEquals(0, result.planScores.size());
    }

    @isTest
    static void convertTest() {
        Account_Plan__c plan1 = TestDataFactory.createAccountPlan('plan1');
        Account_Plan__c plan2 = TestDataFactory.createAccountPlan('plan2');

        List<pq_Account_Plan_Score_History__c> list1 = new List<pq_Account_Plan_Score_History__c>();
        list1.add(
            new pq_Account_Plan_Score_History__c(Account_Plan__c = plan1.Id, Year_Week__c = 202305, Score__c = 10)
        );
        list1.add(
            new pq_Account_Plan_Score_History__c(Account_Plan__c = plan1.Id, Year_Week__c = 202306, Score__c = 8)
        );
        list1.add(
            new pq_Account_Plan_Score_History__c(Account_Plan__c = plan2.Id, Year_Week__c = 202305, Score__c = 7)
        );
        list1.add(
            new pq_Account_Plan_Score_History__c(Account_Plan__c = plan2.Id, Year_Week__c = 202307, Score__c = 6)
        );
        list1.add(
            new pq_Account_Plan_Score_History__c(Account_Plan__c = plan2.Id, Year_Week__c = 202308, Score__c = 4)
        );
        insert list1;

        List<pq_Account_Plan_Score_History__c> l = [
            SELECT Id, Account_Plan__r.Name, Score__c, Year_Week__c
            FROM pq_Account_Plan_Score_History__c
        ];

        AccountPlanScoreHistoryWrapper result = AccountPlanScoreHistoryWrapper.convert(l);
        System.assertEquals(4, result.labels.size());
        System.assertEquals(2, result.planScores.size());
        System.assertEquals(4, result.planScores[0].scores.size());
        System.assertEquals(4, result.planScores[1].scores.size());
        System.assertEquals('plan1', result.planScores[0].name);
        System.assertEquals('plan2', result.planScores[1].name);
    }
}