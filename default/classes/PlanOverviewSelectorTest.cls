@isTest
private class PlanOverviewSelectorTest {
    @isTest
    static void newInstanceTest() {
        PlanOverviewSelector selector = PlanOverviewSelector.newInstance();

        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        // Given

        Account_Plan__c ap1 = TestDataFactory.createAccountPlan('planA');
        Account_Plan__c ap2 = TestDataFactory.createAccountPlan('planB');

        pq_CRUSH_Plan_Overview__c ov1 = new pq_CRUSH_Plan_Overview__c(
            Name = 'test1',
            Title__c = 'title1',
            Description__c = 'desc1',
            Background_Color__c = '#ff1100',
            Account_Plan__c = ap1.Id
        );
        insert ov1;

        pq_CRUSH_Plan_Overview__c ov2 = new pq_CRUSH_Plan_Overview__c(
            Name = 'test2',
            Title__c = 'title2',
            Description__c = 'desc2',
            Background_Color__c = '#ff1100',
            Account_Plan__c = ap1.Id
        );
        insert ov2;

        pq_CRUSH_Plan_Overview__c ov3 = new pq_CRUSH_Plan_Overview__c(
            Name = 'test3',
            Title__c = 'title3',
            Description__c = 'desc3',
            Background_Color__c = '#ff1100',
            Account_Plan__c = ap2.Id
        );
        insert ov3;

        // When
        Test.startTest();

        List<pq_CRUSH_Plan_Overview__c> result = new PlanOverviewSelector().selectById(new Set<Id>{ ov1.Id, ov2.Id });

        Test.stopTest();

        // Then

        System.assertEquals(2, result.size(), 'Expected 2 Plan Overview records.');
        System.assert(ov1.Id == result[0].Id || ov2.Id == result[0].Id);
        System.assert(ov1.Id == result[1].Id || ov2.Id == result[1].Id);
    }

    @isTest
    static void selectByAccountPlanTest() {
        // Given

        Account_Plan__c ap1 = TestDataFactory.createAccountPlan('planA');
        Account_Plan__c ap2 = TestDataFactory.createAccountPlan('planB');
        String dataKey = 'one';

        pq_CRUSH_Plan_Overview__c ov1 = new pq_CRUSH_Plan_Overview__c(
            Name = 'test1',
            Title__c = 'title1',
            Description__c = 'desc1',
            Background_Color__c = '#ff1100',
            Account_Plan__c = ap1.Id,
            Data_Key__c = dataKey
        );
        insert ov1;

        pq_CRUSH_Plan_Overview__c ov2 = new pq_CRUSH_Plan_Overview__c(
            Name = 'test2',
            Title__c = 'title2',
            Description__c = 'desc2',
            Background_Color__c = '#ff1100',
            Account_Plan__c = ap1.Id
        );
        insert ov2;

        pq_CRUSH_Plan_Overview__c ov3 = new pq_CRUSH_Plan_Overview__c(
            Name = 'test3',
            Title__c = 'title3',
            Description__c = 'desc3',
            Background_Color__c = '#ff1100',
            Account_Plan__c = ap2.Id,
            Data_Key__c = dataKey
        );
        insert ov3;

        // When
        Test.startTest();

        List<pq_CRUSH_Plan_Overview__c> result = new PlanOverviewSelector()
            .selectByAccountPlan(new Set<Id>{ ap1.Id }, dataKey, false);

        Test.stopTest();

        // Then

        System.assertEquals(1, result.size(), 'Expected 1 Plan Overview record.');
        System.assert(ov1.Id == result[0].Id);
    }

    @isTest
    static void selectByAccountPlanGlobalTest() {
        // Given

        Account_Plan__c ap1 = TestDataFactory.createAccountPlan('planA');
        Account_Plan__c ap2 = TestDataFactory.createAccountPlan('planB');
        String dataKey = 'one';

        pq_CRUSH_Plan_Overview__c ov1 = new pq_CRUSH_Plan_Overview__c(
            Name = 'test1',
            Title__c = 'title1',
            Description__c = 'desc1',
            Background_Color__c = '#ff1100',
            Account_Plan__c = ap1.Id,
            Data_Key__c = dataKey
        );
        insert ov1;

        pq_CRUSH_Plan_Overview__c ov2 = new pq_CRUSH_Plan_Overview__c(
            Name = 'test2',
            Title__c = 'title2',
            Description__c = 'desc2',
            Background_Color__c = '#ff1100',
            Account_Plan__c = ap1.Id
        );
        insert ov2;

        pq_CRUSH_Plan_Overview__c ov3 = new pq_CRUSH_Plan_Overview__c(
            Name = 'test3',
            Title__c = 'title3',
            Description__c = 'desc3',
            Background_Color__c = '#ff1100',
            Account_Plan__c = ap2.Id,
            Data_Key__c = dataKey
        );
        insert ov3;

        // When
        Test.startTest();

        List<pq_CRUSH_Plan_Overview__c> result = new PlanOverviewSelector()
            .selectByAccountPlan(new Set<Id>{ ap1.Id }, dataKey, true);

        Test.stopTest();

        // Then

        System.assertEquals(2, result.size(), 'Expected 2 Plan Overview records.');
        System.assert(ov1.Id == result[0].Id || ov1.Id == result[1].Id);
        System.assert(ov3.Id == result[0].Id || ov3.Id == result[1].Id);
    }
}