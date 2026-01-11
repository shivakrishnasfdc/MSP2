@isTest
private class AccountPlanScoreHistoryServiceTest {
    @isTest
    static void insertScoresEmptyTest() {
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        List<pq_Account_Plan_Score_History__c> scores = new List<pq_Account_Plan_Score_History__c>();
        AccountPlanScoreHistoryService.insertScores(scores);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0))
            .registerNew(fflib_Match.sObjectOfType(pq_Account_Plan_Score_History__c.SObjectType));

        System.assert(true, 'verified by mocks');
    }

    @isTest
    static void insertScoresNullTest() {
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        AccountPlanScoreHistoryService.insertScores(null);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0))
            .registerNew(fflib_Match.sObjectOfType(pq_Account_Plan_Score_History__c.SObjectType));

        System.assert(true, 'verified by mocks');
    }

    @isTest
    static void insertScoresAlreadyExistsTest() {
        testMockData md = new testMockData();
        AccountPlanScoreHistorySelector mockAccountPlanScoreHistorySelector = md.mockAccountPlanScoreHistorySelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        pq_Account_Plan_Score_History__c h = new pq_Account_Plan_Score_History__c(
            Account_Plan__c = md.mockAccountPlanId,
            Year_Week__c = 202305,
            Score__c = 27
        );

        pq_Account_Plan_Score_History__c h2 = new pq_Account_Plan_Score_History__c(
            Account_Plan__c = fflib_IDGenerator.generate(Account_Plan__c.SObjectType),
            Year_Week__c = 202305,
            Score__c = 35
        );

        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanScoreHistorySelector.selectByYearWeek(h.Year_Week__c))
            .thenReturn(new List<pq_Account_Plan_Score_History__c>{ h });
        md.mocks.stopStubbing();

        List<pq_Account_Plan_Score_History__c> scores = new List<pq_Account_Plan_Score_History__c>();
        scores.add(h);
        scores.add(h2);
        AccountPlanScoreHistoryService.insertScores(scores);

        List<pq_Account_Plan_Score_History__c> insertedScores = new List<pq_Account_Plan_Score_History__c>();
        insertedScores.add(h2);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew(insertedScores);

        System.assert(true, 'verified by mocks');
    }

    @isTest
    static void insertScoresHappyPathTest() {
        testMockData md = new testMockData();
        AccountPlanScoreHistorySelector mockAccountPlanScoreHistorySelector = md.mockAccountPlanScoreHistorySelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;

        Account_Plan__c ap1 = TestDataFactory.createAccountPlan('Plan A', testAccount);
        Account_Plan__c ap2 = TestDataFactory.createAccountPlan('Plan B', testAccount);
        Account_Plan__c ap3 = TestDataFactory.createAccountPlan('Plan C', testAccount);

        pq_Account_Plan_Score_History__c h1 = new pq_Account_Plan_Score_History__c(
            Account_Plan__c = ap1.Id,
            Year_Week__c = 202312,
            Score__c = 56
        );

        pq_Account_Plan_Score_History__c h2 = new pq_Account_Plan_Score_History__c(
            Account_Plan__c = ap2.Id,
            Year_Week__c = 202312,
            Score__c = 27
        );

        pq_Account_Plan_Score_History__c h3 = new pq_Account_Plan_Score_History__c(
            Account_Plan__c = ap3.Id,
            Year_Week__c = 202312,
            Score__c = 78
        );

        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanScoreHistorySelector.selectByYearWeek(h1.Year_Week__c))
            .thenReturn(new List<pq_Account_Plan_Score_History__c>());
        md.mocks.stopStubbing();

        List<pq_Account_Plan_Score_History__c> scores = new List<pq_Account_Plan_Score_History__c>();
        scores.add(h1);
        scores.add(h2);
        scores.add(h3);
        AccountPlanScoreHistoryService.insertScores(scores);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew(scores);

        System.assert(true, 'verified by mocks');
    }
}