@IsTest
private class OpportunityPlanCreationBatchTest {
    static final String OPPORTUNITY_NAME_1 = 'Test Opportunity opcbt 1';
    static final String OPPORTUNITY_NAME_2 = 'Test Opportunity opcbt 2';
    static final String OPPORTUNITY_NAME_3 = 'Test Opportunity opcbt 3';
    static final String OPPORTUNITY_NAME_4 = 'Test Opportunity opcbt 4';

    @IsTest
    static void batchSizeAndRecordLimitTest() {
        OpportunityPlanCreationBatch batch = new OpportunityPlanCreationBatch();
        System.assertEquals(200, batch.batchSize);
        System.assertEquals(10000, batch.maxRecords);
    }

    @IsTest
    static void executeBatchWithoutFeatureTest() {
        setOppPlanFeatureFlag(false);

        Opportunity opp1 = new Opportunity(
            Name = OPPORTUNITY_NAME_1,
            CloseDate = Date.today(),
            StageName = 'Prospecting'
        );
        Opportunity opp2 = new Opportunity(
            Name = OPPORTUNITY_NAME_2,
            CloseDate = Date.today(),
            StageName = 'Prospecting'
        );
        Opportunity opp3 = new Opportunity(
            Name = OPPORTUNITY_NAME_3,
            CloseDate = Date.today(),
            StageName = 'Prospecting'
        );
        List<Opportunity> opps = new List<Opportunity>{ opp1, opp2, opp3 };
        insert opps;

        Set<Id> oppIds = new Set<Id>{ opp1.Id, opp2.Id, opp3.Id };

        OpportunityPlanCreationBatch batch = new OpportunityPlanCreationBatch();
        Test.startTest();
        batch.execute(null);
        Test.stopTest();

        List<PQ_Opportunity_Plan__c> plans = [
            SELECT Id, Opportunity__c
            FROM PQ_Opportunity_Plan__c
            WHERE Opportunity__c IN :oppIds
        ];

        System.assertEquals(0, plans.size());
    }

    @IsTest
    static void executeBatchWithFeatureTest() {
        setOppPlanFeatureFlag(true);

        Opportunity opp1 = new Opportunity(
            Name = OPPORTUNITY_NAME_1,
            CloseDate = Date.today(),
            StageName = 'Prospecting'
        );
        Opportunity opp2 = new Opportunity(
            Name = OPPORTUNITY_NAME_2,
            CloseDate = Date.today(),
            StageName = 'Prospecting'
        );
        Opportunity opp3 = new Opportunity(
            Name = OPPORTUNITY_NAME_3,
            CloseDate = Date.today(),
            StageName = 'Prospecting'
        );
        Opportunity oppWithPlan = new Opportunity(
            Name = OPPORTUNITY_NAME_4,
            CloseDate = Date.today(),
            StageName = 'Prospecting'
        );
        List<Opportunity> opps = new List<Opportunity>{ opp1, opp2, opp3, oppWithPlan };
        insert opps;

        insert new PQ_Opportunity_Plan__c(Opportunity__c = oppWithPlan.Id, Name = 'Test Plan');

        Datetime oneSecInFuture = Datetime.now().addSeconds(1);
        while (Datetime.now() < oneSecInFuture) {
            Integer temp = 1 + 1; //NOPMD - loop until time has passed to garauntee our new objects created dates are after the batch start date
        }

        Set<Id> expectedOppIds = new Set<Id>{ opp1.Id, opp2.Id, opp3.Id };

        OpportunityPlanCreationBatch batch = new OpportunityPlanCreationBatch();
        Test.startTest();
        batch.execute(null);
        Test.stopTest();

        List<PQ_Opportunity_Plan__c> plans = [
            SELECT Id, Opportunity__c
            FROM PQ_Opportunity_Plan__c
            WHERE LastModifiedDate >= :oneSecInFuture
        ];

        System.assertEquals(3, plans.size());
        Set<Id> planOppIds = new Set<Id>();
        for (PQ_Opportunity_Plan__c plan : plans) {
            planOppIds.add(plan.Opportunity__c);
        }
        System.assertEquals(expectedOppIds, planOppIds, 'Plans should be created for all opportunities without plans');
        System.assert(!planOppIds.contains(oppWithPlan.Id), 'Plans should not be created for opportunities with plans');
    }

    @Future
    static void setOppPlanFeatureFlag(Boolean value) {
        FeatureManagement.setPackageBooleanValue('OppPlan_Access', value);
    }
}