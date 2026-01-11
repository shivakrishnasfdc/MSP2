@isTest
private class AccountPlanScoreHistorySelectorTest {
    @isTest
    static void newInstanceTest() {
        AccountPlanScoreHistorySelector selector = AccountPlanScoreHistorySelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;

        Account_Plan__c ap = TestDataFactory.createAccountPlan('Plan A', testAccount);

        pq_Account_Plan_Score_History__c h = new pq_Account_Plan_Score_History__c(
            Account_Plan__c = ap.Id,
            Year_Week__c = 202305,
            Score__c = 27
        );

        pq_Account_Plan_Score_History__c h2 = new pq_Account_Plan_Score_History__c(
            Account_Plan__c = ap.Id,
            Year_Week__c = 202306,
            Score__c = 29
        );
        insert new List<pq_Account_Plan_Score_History__c>{ h, h2 };

        List<pq_Account_Plan_Score_History__c> result = AccountPlanScoreHistorySelector.newInstance()
            .selectById(new Set<Id>{ h.Id });
        System.assertEquals(1, result.size());
        System.assertEquals(202305, result[0].Year_Week__c);
        System.assertEquals(ap.Id, result[0].Account_Plan__c);
        System.assertEquals(27, result[0].Score__c);
    }

    @isTest
    static void selectByAccountPlansAfterDateTest() {
        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;

        Account_Plan__c ap = TestDataFactory.createAccountPlan('Plan 1', testAccount);
        Account_Plan__c ap2 = TestDataFactory.createAccountPlan('Plan 2', testAccount);

        pq_Account_Plan_Score_History__c h = new pq_Account_Plan_Score_History__c(
            Account_Plan__c = ap.Id,
            Year_Week__c = 202305,
            Score__c = 27
        );
        pq_Account_Plan_Score_History__c h2 = new pq_Account_Plan_Score_History__c(
            Account_Plan__c = ap2.Id,
            Year_Week__c = 202304,
            Score__c = 21
        );
        insert new List<pq_Account_Plan_Score_History__c>{ h, h2 };

        DateTime dt = DateTime.Now();

        List<pq_Account_Plan_Score_History__c> result = AccountPlanScoreHistorySelector.newInstance()
            .selectByAccountPlansAfterDate(new Set<Id>{ ap.Id }, dt);
        System.assertEquals(0, result.size());

        DateTime dtearlier = DateTime.Now().addDays(-1);
        List<pq_Account_Plan_Score_History__c> result2 = AccountPlanScoreHistorySelector.newInstance()
            .selectByAccountPlansAfterDate(new Set<Id>{ ap.Id }, dtearlier);
        System.assertEquals(1, result2.size());
    }

    @IsTest
    static void selectByYearWeekTest() {
        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;

        Account_Plan__c ap = TestDataFactory.createAccountPlan('Plan 1', testAccount);
        Account_Plan__c ap2 = TestDataFactory.createAccountPlan('Plan 2', testAccount);

        pq_Account_Plan_Score_History__c h = new pq_Account_Plan_Score_History__c(
            Account_Plan__c = ap.Id,
            Year_Week__c = 202305,
            Score__c = 27
        );
        pq_Account_Plan_Score_History__c h2 = new pq_Account_Plan_Score_History__c(
            Account_Plan__c = ap.Id,
            Year_Week__c = 202304,
            Score__c = 21
        );
        pq_Account_Plan_Score_History__c h3 = new pq_Account_Plan_Score_History__c(
            Account_Plan__c = ap2.Id,
            Year_Week__c = 202304,
            Score__c = 36
        );
        insert new List<pq_Account_Plan_Score_History__c>{ h, h2, h3 };

        List<pq_Account_Plan_Score_History__c> result = AccountPlanScoreHistorySelector.newInstance()
            .selectByYearWeek(202304);
        System.assertEquals(
            2,
            result.size(),
            'Should return 2 results since there are 2 records with the correct year week'
        );
        Map<Id, pq_Account_Plan_Score_History__c> resultmap = new Map<Id, pq_Account_Plan_Score_History__c>(result);

        System.assert(resultmap.containsKey(h2.Id), 'Should contain h2 since it has the correct year week');
        System.assert(resultmap.containsKey(h3.Id), 'Should contain h3 since it has the correct year week');
    }
}