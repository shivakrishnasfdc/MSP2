@IsTest
public with sharing class OpportunityPlanControllerTest {
    @IsTest
    static void getRelationshipMapIdForPlanIdNullTest() {
        Test.startTest();
        Id result = OpportunityPlanController.getRelationshipMapIdForPlanId(null);
        Test.stopTest();

        System.assertEquals(null, result, 'Should return null when planId is null');
    }

    @IsTest
    static void getRelationshipMapIdForPlanIdWrongTypeTest() {
        TestMockData md = new TestMockData();

        Test.startTest();
        Id result = OpportunityPlanController.getRelationshipMapIdForPlanId(md.mockAccountId);
        Test.stopTest();

        System.assertEquals(null, result, 'Should return null when planId is not an OpportunityPlan or Opportunity Id');
    }

    @IsTest
    static void getRelationshipMapIdForPlanIdNoMapsTest() {
        TestMockData md = new TestMockData();
        OpportunityPlanServiceImpl mockOpportunityPlanService = md.mockOpportunityPlanService;

        md.mocks.startStubbing();
        md.mocks.when(mockOpportunityPlanService.getRelationshipMapsForOppPlanId(md.mockOpportunityPlanId, true))
            .thenReturn(new List<Relationship_Map__c>());
        md.mocks.stopStubbing();

        Test.startTest();
        Id result = OpportunityPlanController.getRelationshipMapIdForPlanId(md.mockOpportunityPlanId);
        Test.stopTest();

        System.assertEquals(
            null,
            result,
            'Should return null when no RelationshipMaps are found (should actually create a plan, but we\'re stubbing this case)'
        );
    }

    @IsTest
    static void getRelationshipMapIdForPlanIdHappyPathTest() {
        TestMockData md = new TestMockData();
        OpportunityPlanServiceImpl mockOpportunityPlanService = md.mockOpportunityPlanService;

        md.mocks.startStubbing();
        md.mocks.when(mockOpportunityPlanService.getRelationshipMapsForOppPlanId(md.mockOpportunityPlanId, true))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.stopStubbing();

        Test.startTest();
        Id result = OpportunityPlanController.getRelationshipMapIdForPlanId(md.mockOpportunityPlanId);
        Test.stopTest();

        System.assertEquals(md.mockRelationshipMap.Id, result, 'Should return the RelationshipMap Id when found');
    }

    @IsTest
    static void getRelationshipMapIdForPlanIdMultipleMapsTest() {
        TestMockData md = new TestMockData();
        OpportunityPlanServiceImpl mockOpportunityPlanService = md.mockOpportunityPlanService;

        Relationship_Map__c mockMap1 = md.mockRelationshipMap.clone(false, true);

        md.mocks.startStubbing();
        md.mocks.when(mockOpportunityPlanService.getRelationshipMapsForOppPlanId(md.mockOpportunityPlanId, true))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap, mockMap1 });
        md.mocks.stopStubbing();

        Test.startTest();
        Id result = OpportunityPlanController.getRelationshipMapIdForPlanId(md.mockOpportunityPlanId);
        Test.stopTest();

        System.assertEquals(
            md.mockRelationshipMap.Id,
            result,
            'Should return the first RelationshipMap Id when multiple are found'
        );
    }

    @IsTest
    static void getRelationshipMapIdForPlanIdOpportunityIdPassedTest() {
        TestMockData md = new TestMockData();
        OpportunityPlanServiceImpl mockOpportunityPlanService = md.mockOpportunityPlanService;
        OpportunityPlanSelector mockSelector = md.mockOpportunityPlanSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockOpportunityPlanService.getRelationshipMapsForOppPlanId(md.mockOpportunityPlanId, true))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.when(mockSelector.selectByOpportunityIds(new Set<Id>{ md.mockOpportunityId }))
            .thenReturn(new List<PQ_Opportunity_Plan__c>{ md.mockOpportunityPlan });
        md.mocks.stopStubbing();

        Test.startTest();
        Id result = OpportunityPlanController.getRelationshipMapIdForPlanId(md.mockOpportunityId);
        Test.stopTest();

        System.assertEquals(
            md.mockRelationshipMap.Id,
            result,
            'Should return the RelationshipMap Id for the OpportunityPlan found by Opportunity Id'
        );
        ((OpportunityPlanSelector) md.mocks.verify(mockSelector, 1))
            .selectByOpportunityIds(new Set<Id>{ md.mockOpportunityId });
    }

    @IsTest
    static void getPlanIdForOpportunityIdNullTest() {
        Test.startTest();
        Id result = OpportunityPlanController.getPlanIdForOpportunityId(null);
        Test.stopTest();

        System.assertEquals(null, result, 'Should return null when opportunityId is null');
    }

    @IsTest
    static void getPlanIdForOpportunityIdWrongTypeTest() {
        TestMockData md = new TestMockData();

        Test.startTest();
        Id result = OpportunityPlanController.getPlanIdForOpportunityId(md.mockAccountId);
        Test.stopTest();

        System.assertEquals(
            null,
            result,
            'Should return null when opportunityId is not an OpportunityPlan or Opportunity Id'
        );
    }

    @IsTest
    static void getPlanIdForOpportunityIdPlanIdTest() {
        TestMockData md = new TestMockData();
        OpportunityPlanSelector mockSelector = md.mockOpportunityPlanSelector;

        Test.startTest();
        Id result = OpportunityPlanController.getPlanIdForOpportunityId(md.mockOpportunityPlanId);
        Test.stopTest();

        System.assertEquals(
            md.mockOpportunityPlanId,
            result,
            'Should return the OpportunityPlan Id when passed an OpportunityPlan Id'
        );
        ((OpportunityPlanSelector) md.mocks.verify(mockSelector, 0))
            .selectByOpportunityIds((Set<Id>) fflib_match.anyObject());
    }

    @IsTest
    static void getPlanIdForOpportunityIdHappyPathTest() {
        TestMockData md = new TestMockData();
        OpportunityPlanSelector mockSelector = md.mockOpportunityPlanSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockSelector.selectByOpportunityIds(new Set<Id>{ md.mockOpportunityId }))
            .thenReturn(new List<PQ_Opportunity_Plan__c>{ md.mockOpportunityPlan });
        md.mocks.stopStubbing();

        Test.startTest();
        Id result = OpportunityPlanController.getPlanIdForOpportunityId(md.mockOpportunityId);
        Test.stopTest();

        System.assertEquals(
            md.mockOpportunityPlanId,
            result,
            'Should return the OpportunityPlan Id for the OpportunityPlan found by Opportunity Id'
        );
    }

    @IsTest
    static void getPlanIdForOpportunityIdMultiplePlansTest() {
        TestMockData md = new TestMockData();
        OpportunityPlanSelector mockSelector = md.mockOpportunityPlanSelector;

        PQ_Opportunity_Plan__c mockPlan1 = md.mockOpportunityPlan.clone(false, true);

        md.mocks.startStubbing();
        md.mocks.when(mockSelector.selectByOpportunityIds(new Set<Id>{ md.mockOpportunityId }))
            .thenReturn(new List<PQ_Opportunity_Plan__c>{ md.mockOpportunityPlan, mockPlan1 });
        md.mocks.stopStubbing();

        Test.startTest();
        Id result = OpportunityPlanController.getPlanIdForOpportunityId(md.mockOpportunityId);
        Test.stopTest();

        System.assertEquals(
            md.mockOpportunityPlanId,
            result,
            'Should return the first OpportunityPlan Id when multiple are found'
        );
    }

    @isTest
    static void getOpportunityScoreForOpportunityPlanTest() {

        // Given
        TestMockData md = new TestMockData();
        OpportunityScoreServiceImpl mockOpportunityScoreService = md.mockOpportunityScoreService;
        OpportunityPlanSelector mockOpportunityPlanSelector = md.mockOpportunityPlanSelector;
        
        Map<Id, OpportunityScoreData> oppIdXOppData = new Map<Id, OpportunityScoreData>();
        oppIdXOppData.put(md.mockOpportunityId, new OpportunityScoreData());

        md.mocks.startStubbing();
        md.mocks.when(mockOpportunityPlanSelector.selectByIds(new Set<Id> { md.mockOpportunityPlanId }))
            .thenReturn(new List<pq_Opportunity_Plan__c>{ md.mockOpportunityPlan });
        md.mocks.when(mockOpportunityScoreService.calculateOpportunityScore(new Set<Id>{ md.mockOpportunityId }))
            .thenReturn(oppIdXOppData);
        md.mocks.stopStubbing();

        OpportunityPlanController.getOpportunityScoreForOpportunityPlan(md.mockOpportunityPlanId);

        ((OpportunityScoreServiceImpl) md.mocks.verify(mockOpportunityScoreService, 1)).calculateOpportunityScore(new Set<Id>{ md.mockOpportunityId });
        System.assert(true, 'Test verified by mock assertion');
    }

    @isTest
    static void getOpportunityScoreForOpportunityTest() {

        // Given
        TestMockData md = new TestMockData();
        OpportunityScoreServiceImpl mockOpportunityScoreService = md.mockOpportunityScoreService;

        Map<Id, OpportunityScoreData> oppIdXOppData = new Map<Id, OpportunityScoreData>();
        oppIdXOppData.put(md.mockOpportunityId, new OpportunityScoreData());

        md.mocks.startStubbing();
        md.mocks.when(mockOpportunityScoreService.calculateOpportunityScore(new Set<Id>{ md.mockOpportunityId }))
            .thenReturn(oppIdXOppData);
        md.mocks.stopStubbing();

        OpportunityPlanController.getOpportunityScoreForOpportunity(md.mockOpportunityId);

        ((OpportunityScoreServiceImpl) md.mocks.verify(mockOpportunityScoreService, 1)).calculateOpportunityScore(new Set<Id>{ md.mockOpportunityId });
        System.assert(true, 'Test verified by mock assertion');
    }
}