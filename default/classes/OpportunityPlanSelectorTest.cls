@isTest
public with sharing class OpportunityPlanSelectorTest {
    @isTest
    static void newInstanceTest() {
        Test.startTest();
        OpportunityPlanSelector result = OpportunityPlanSelector.newInstance();
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(
            PQ_Opportunity_Plan__c.SObjectType,
            result.getSObjectType(),
            'Result should be of type PQ_Opportunity_Plan__c'
        );
    }

    @isTest
    static void selectByIdsNullTest() {
        Opportunity opp = TestDataFactory.createOpportunity('sbint Opportunity');
        insert opp;
        TestDataFactory.createOpportunityPlan(opp);

        Test.startTest();
        List<PQ_Opportunity_Plan__c> result = OpportunityPlanSelector.newInstance().selectByIds(null);
        Test.stopTest();
        System.assertEquals(0, result.size(), 'Result should be empty');
    }

    @isTest
    static void selectByIdsEmptyTest() {
        Opportunity opp = TestDataFactory.createOpportunity('sbint Opportunity');
        insert opp;
        TestDataFactory.createOpportunityPlan(opp);

        Test.startTest();
        List<PQ_Opportunity_Plan__c> result = OpportunityPlanSelector.newInstance().selectByIds(new Set<Id>());
        Test.stopTest();
        System.assertEquals(0, result.size(), 'Result should be empty');
    }

    @isTest
    static void selectByIdsHappyPathTest() {
        Opportunity opp1 = TestDataFactory.createOpportunity('sbint Opportunity1');
        Opportunity opp2 = TestDataFactory.createOpportunity('sbint Opportunity2');
        insert new List<Opportunity>{ opp1, opp2 };
        PQ_Opportunity_Plan__c plan1 = TestDataFactory.createOpportunityPlan(opp1);
        TestDataFactory.createOpportunityPlan(opp2);

        Test.startTest();
        List<PQ_Opportunity_Plan__c> result = OpportunityPlanSelector.newInstance()
            .selectByIds(new Set<Id>{ plan1.Id });
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Result should have 1 record');
        System.assertEquals(plan1.Id, result[0].Id, 'record in result should be plan1');
    }

    @isTest
    static void selectByOpportunityIdsNullTest() {
        Opportunity opp = TestDataFactory.createOpportunity('sbint Opportunity');
        insert opp;
        TestDataFactory.createOpportunityPlan(opp);

        Test.startTest();
        List<PQ_Opportunity_Plan__c> result = OpportunityPlanSelector.newInstance().selectByOpportunityIds(null);
        Test.stopTest();
        System.assertEquals(0, result.size(), 'Result should be empty');
    }

    @isTest
    static void selectByOpportunityIdsEmptyTest() {
        Opportunity opp = TestDataFactory.createOpportunity('sbint Opportunity');
        insert opp;
        TestDataFactory.createOpportunityPlan(opp);

        Test.startTest();
        List<PQ_Opportunity_Plan__c> result = OpportunityPlanSelector.newInstance()
            .selectByOpportunityIds(new Set<Id>());
        Test.stopTest();
        System.assertEquals(0, result.size(), 'Result should be empty');
    }

    @isTest
    static void selectByOpportunityIdsHappyPathTest() {
        Opportunity opp1 = TestDataFactory.createOpportunity('sbint Opportunity1');
        Opportunity opp2 = TestDataFactory.createOpportunity('sbint Opportunity2');
        insert new List<Opportunity>{ opp1, opp2 };
        PQ_Opportunity_Plan__c plan1 = TestDataFactory.createOpportunityPlan(opp1);
        TestDataFactory.createOpportunityPlan(opp2);

        Test.startTest();
        List<PQ_Opportunity_Plan__c> result = OpportunityPlanSelector.newInstance()
            .selectByOpportunityIds(new Set<Id>{ opp1.Id });
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Result should have 1 record');
        System.assertEquals(plan1.Id, result[0].Id, 'record in result should be plan1');
    }
}