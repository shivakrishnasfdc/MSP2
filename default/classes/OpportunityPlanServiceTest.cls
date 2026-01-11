@IsTest
private class OpportunityPlanServiceTest {
    static final String OPPORTUNITY_NAME_1 = 'Test Opportunity opst 1';
    static final String OPPORTUNITY_NAME_2 = 'Test Opportunity opst 2';
    static final String OPPORTUNITY_NAME_3 = 'Test Opportunity opst 3';

    @IsTest
    static void getQueryForOpportunitiesWithoutPlansTest() {
        String expectedSoqlString = 'SELECT id, name, amount, isclosed, lastmodifieddate FROM Opportunity WHERE (Id NOT IN (SELECT opportunity__c FROM pqcrush__PQ_Opportunity_Plan__c))';

        Test.startTest();
        Query result = OpportunityPlanService.getQueryForOpportunitiesWithoutPlans();
        Test.stopTest();

        System.assertEquals(expectedSoqlString, result.toQueryString(), 'Should return the expected query');
    }

    @IsTest
    static void createOpportunityPlansNullTest() {
        Test.startTest();
        List<PQ_Opportunity_Plan__c> result = OpportunityPlanService.createOpportunityPlans(null);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty list when null is passed in');
    }

    @IsTest
    static void createOpportunityPlansEmptyTest() {
        Test.startTest();
        List<PQ_Opportunity_Plan__c> result = OpportunityPlanService.createOpportunityPlans(new List<Opportunity>());
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty list when empty list is passed in');
    }

    @IsTest
    static void createOpportunityPlansHappyPathTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUoW = md.mockOpportunityPlanUow;

        Test.startTest();
        List<PQ_Opportunity_Plan__c> result = OpportunityPlanService.createOpportunityPlans(
            new List<Opportunity>{ md.mockOpportunity }
        );
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should return a list with one Opportunity Plan');
        System.assertEquals(
            md.mockOpportunity.Id,
            result[0].Opportunity__c,
            'Should return an Opportunity Plan with the correct Opportunity Id'
        );
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUoW, 1)).registerNew(result);
    }

    @IsTest
    static void getRelationshipMapsForOppPlanIdNullTest() {
        Test.startTest();
        List<Relationship_Map__c> result = OpportunityPlanService.getRelationshipMapsForOppPlanId(null, true);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty list when oppPlanId is null');
    }

    @IsTest
    static void getRelationshipMapsForOppPlanIdWrongObjectTest() {
        Id mockAccountId = fflib_IDGenerator.generate(Account.sObjectType);

        Test.startTest();
        List<Relationship_Map__c> result = OpportunityPlanService.getRelationshipMapsForOppPlanId(mockAccountId, true);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty list when oppPlanId is not an OpportunityPlan');
    }

    @IsTest
    static void getRelationshipMapsForOppPlanIdNoMapsNoCreateTest() {
        TestMockData md = new TestMockData();
        RelationshipMapSelector mockRMSelector = md.mockRelationshipMapSelector;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUoW;

        md.mocks.startStubbing();
        md.mocks.when(mockRMSelector.selectByOppPlanIds(new Set<Id>{ md.mockOpportunityPlanId }))
            .thenReturn(new List<Relationship_Map__c>());
        md.mocks.stopStubbing();

        Test.startTest();
        List<Relationship_Map__c> result = OpportunityPlanService.getRelationshipMapsForOppPlanId(
            md.mockOpportunityPlanId,
            false
        );
        Test.stopTest();

        // Verify that no new maps were created or returned
        System.assertEquals(0, result.size(), 'Should return empty list when no maps are found and create is false');
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUoW, 0))
            .registerNew((Relationship_Map__c) fflib_Match.anySObject());
    }

    @IsTest
    static void getRelationshipMapsForOppPlanIdNoMapsCreateTest() {
        TestMockData md = new TestMockData();
        RelationshipMapSelector mockRMSelector = md.mockRelationshipMapSelector;
        OpportunityPlanSelector mockOPSelector = md.mockOpportunityPlanSelector;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUoW;
        OpportunityContactRoleSelector mockOCRSelector = md.mockOpportunityContactRoleSelector;
        RMMAutoHistorySelector mockRMMAHSelector = md.mockRMMAutoHistorySelector;
        RelationshipMapMemberSelector mockRMMSelector = md.mockRelationshipMapMemberSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockRMSelector.selectByOppPlanIds(new Set<Id>{ md.mockOpportunityPlanId }))
            .thenReturn(new List<Relationship_Map__c>());
        md.mocks.when(mockOPSelector.selectByIds(new Set<Id>{ md.mockOpportunityPlanId }))
            .thenReturn(new List<PQ_Opportunity_Plan__c>{ md.mockOpportunityPlan });

        md.mocks.when(mockOCRSelector.selectByOpportunityIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<OpportunityContactRole>());
        md.mocks.when(mockRMMAHSelector.selectByMapIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Relationship_Map_Member_Auto_History__c>());
        md.mocks.when(mockRMMSelector.selectByMapIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Relationship_Map_Member__c>());
        md.mocks.stopStubbing();

        Test.startTest();
        List<Relationship_Map__c> result = OpportunityPlanService.getRelationshipMapsForOppPlanId(
            md.mockOpportunityPlanId,
            true
        );
        Test.stopTest();

        //Verify a map was created and returned
        System.assertEquals(
            1,
            result.size(),
            'Should return list with one map when no maps are found and create is true'
        );
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUoW, 1))
            .registerNew((Relationship_Map__c) fflib_Match.anySObject());
        //Verify that it tried to update members for the map
        ((OpportunityContactRoleSelector) md.mocks.verify(mockOCRSelector, 1))
            .selectByOpportunityIds((Set<Id>) fflib_Match.anyObject());
        ((RMMAutoHistorySelector) md.mocks.verify(mockRMMAHSelector, 1))
            .selectByMapIds((Set<Id>) fflib_Match.anyObject());
        ((RelationshipMapMemberSelector) md.mocks.verify(mockRMMSelector, 1))
            .selectByMapIds((Set<Id>) fflib_Match.anyObject());
    }

    @IsTest
    static void getRelationshipMapsForOppPlanIdMapFoundTest() {
        TestMockData md = new TestMockData();
        RelationshipMapSelector mockRMSelector = md.mockRelationshipMapSelector;
        OpportunityPlanSelector mockOPSelector = md.mockOpportunityPlanSelector;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUoW;
        OpportunityContactRoleSelector mockOCRSelector = md.mockOpportunityContactRoleSelector;
        RMMAutoHistorySelector mockRMMAHSelector = md.mockRMMAutoHistorySelector;
        RelationshipMapMemberSelector mockRMMSelector = md.mockRelationshipMapMemberSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockRMSelector.selectByOppPlanIds(new Set<Id>{ md.mockOpportunityPlanId }))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.when(mockOPSelector.selectByIds(new Set<Id>{ md.mockOpportunityPlanId }))
            .thenReturn(new List<PQ_Opportunity_Plan__c>{ md.mockOpportunityPlan });

        md.mocks.when(mockOCRSelector.selectByOpportunityIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<OpportunityContactRole>());
        md.mocks.when(mockRMMAHSelector.selectByMapIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Relationship_Map_Member_Auto_History__c>());
        md.mocks.when(mockRMMSelector.selectByMapIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Relationship_Map_Member__c>());
        md.mocks.stopStubbing();

        Test.startTest();
        List<Relationship_Map__c> result = OpportunityPlanService.getRelationshipMapsForOppPlanId(
            md.mockOpportunityPlanId,
            true
        );
        Test.stopTest();

        //Verify a map was found and returned, not created
        System.assertEquals(1, result.size(), 'Should return list with one map when map is found');
        System.assertEquals(md.mockRelationshipMap.Id, result[0].Id, 'Should return the found map');
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUoW, 0))
            .registerNew((Relationship_Map__c) fflib_Match.anySObject());
        //Verify that it tried to update members for the map
        ((OpportunityContactRoleSelector) md.mocks.verify(mockOCRSelector, 1))
            .selectByOpportunityIds((Set<Id>) fflib_Match.anyObject());
        ((RMMAutoHistorySelector) md.mocks.verify(mockRMMAHSelector, 1))
            .selectByMapIds((Set<Id>) fflib_Match.anyObject());
        ((RelationshipMapMemberSelector) md.mocks.verify(mockRMMSelector, 1))
            .selectByMapIds((Set<Id>) fflib_Match.anyObject());
    }

    @IsTest
    static void createRelationshipMapForOppPlanIdNullIdTest() {
        Test.startTest();
        Relationship_Map__c result = OpportunityPlanService.createRelationshipMapForOppPlanId(null);
        Test.stopTest();

        System.assertEquals(null, result, 'Should return null when null is passed in');
    }

    @IsTest
    static void createRelationshipMapForOppPlanIdWrongObjectTest() {
        Id mockId = fflib_IDGenerator.generate(Account.sObjectType);

        Test.startTest();
        Relationship_Map__c result = OpportunityPlanService.createRelationshipMapForOppPlanId(mockId);
        Test.stopTest();

        System.assertEquals(null, result, 'Should return null when Id of wrong object type is passed in');
    }

    @IsTest
    static void createRelationshipMapForOppPlanIdNoPlanFoundTest() {
        TestMockData md = new TestMockData();
        OpportunityPlanSelector mockOPSelector = md.mockOpportunityPlanSelector;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUoW;

        md.mocks.startStubbing();
        md.mocks.when(mockOPSelector.selectByIds(new Set<Id>{ md.mockOpportunityPlanId }))
            .thenReturn(new List<PQ_Opportunity_Plan__c>());
        md.mocks.stopStubbing();

        Test.startTest();
        Relationship_Map__c result = OpportunityPlanService.createRelationshipMapForOppPlanId(md.mockOpportunityPlanId);
        Test.stopTest();

        System.assertEquals(null, result, 'Should return null when no plan is found');
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUoW, 0))
            .registerNew((Relationship_Map__c) fflib_Match.anySObject());
    }

    @IsTest
    static void createRelationshipMapForOppPlanIdNoUpdatesTest() {
        TestMockData md = new TestMockData();
        OpportunityPlanSelector mockOPSelector = md.mockOpportunityPlanSelector;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUoW;
        OpportunityContactRoleSelector mockOCRSelector = md.mockOpportunityContactRoleSelector;
        RMMAutoHistorySelector mockRMMAHSelector = md.mockRMMAutoHistorySelector;
        RelationshipMapMemberSelector mockRMMSelector = md.mockRelationshipMapMemberSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockOPSelector.selectByIds(new Set<Id>{ md.mockOpportunityPlanId }))
            .thenReturn(new List<PQ_Opportunity_Plan__c>{ md.mockOpportunityPlan });

        md.mocks.when(mockOCRSelector.selectByOpportunityIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<OpportunityContactRole>());
        md.mocks.when(mockRMMAHSelector.selectByMapIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Relationship_Map_Member_Auto_History__c>());
        md.mocks.when(mockRMMSelector.selectByMapIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Relationship_Map_Member__c>());
        md.mocks.stopStubbing();

        Test.startTest();
        Relationship_Map__c result = OpportunityPlanService.createRelationshipMapForOppPlanId(md.mockOpportunityPlanId);
        Test.stopTest();

        //Verify a map was returned
        System.assertNotEquals(null, result, 'Should return a newly created map');
        //Verify a map was created
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUoW, 1))
            .registerNew((Relationship_Map__c) fflib_Match.anySObject());
        //Verify that it tried to update members for the map
        ((OpportunityContactRoleSelector) md.mocks.verify(mockOCRSelector, 1))
            .selectByOpportunityIds((Set<Id>) fflib_Match.anyObject());
        ((RMMAutoHistorySelector) md.mocks.verify(mockRMMAHSelector, 1))
            .selectByMapIds((Set<Id>) fflib_Match.anyObject());
        ((RelationshipMapMemberSelector) md.mocks.verify(mockRMMSelector, 1))
            .selectByMapIds((Set<Id>) fflib_Match.anyObject());
    }

    @IsTest
    static void createRelationshipMapForOppPlanIdAddOCRNotExistingTest() {
        TestMockData md = new TestMockData();
        OpportunityPlanSelector mockOPSelector = md.mockOpportunityPlanSelector;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUoW;
        OpportunityContactRoleSelector mockOCRSelector = md.mockOpportunityContactRoleSelector;
        RMMAutoHistorySelector mockRMMAHSelector = md.mockRMMAutoHistorySelector;
        RelationshipMapMemberSelector mockRMMSelector = md.mockRelationshipMapMemberSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockOPSelector.selectByIds(new Set<Id>{ md.mockOpportunityPlanId }))
            .thenReturn(new List<PQ_Opportunity_Plan__c>{ md.mockOpportunityPlan });

        md.mocks.when(mockOCRSelector.selectByOpportunityIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<OpportunityContactRole>{ md.mockOpportunityContactRole });
        md.mocks.when(mockRMMAHSelector.selectByMapIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Relationship_Map_Member_Auto_History__c>());
        md.mocks.when(mockRMMSelector.selectByMapIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Relationship_Map_Member__c>());
        md.mocks.stopStubbing();

        Test.startTest();
        Relationship_Map__c result = OpportunityPlanService.createRelationshipMapForOppPlanId(md.mockOpportunityPlanId);
        Test.stopTest();

        //Verify a map was returned
        System.assertNotEquals(null, result, 'Should return a newly created map');
        //Verify members were added automatically
        ((OpportunityContactRoleSelector) md.mocks.verify(mockOCRSelector, 1))
            .selectByOpportunityIds((Set<Id>) fflib_Match.anyObject());
        ((RMMAutoHistorySelector) md.mocks.verify(mockRMMAHSelector, 1))
            .selectByMapIds((Set<Id>) fflib_Match.anyObject());
        ((RelationshipMapMemberSelector) md.mocks.verify(mockRMMSelector, 1))
            .selectByMapIds((Set<Id>) fflib_Match.anyObject());
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUoW, 2)).registerNew((List<SObject>) fflib_Match.anyList());
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUoW, 0)).registerDeleted((List<SObject>) fflib_Match.anyList());
    }

    @IsTest
    static void createRelationshipMapForOppPlanIdAddOCRExistingTest() {
        TestMockData md = new TestMockData();
        OpportunityPlanSelector mockOPSelector = md.mockOpportunityPlanSelector;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUoW;
        OpportunityContactRoleSelector mockOCRSelector = md.mockOpportunityContactRoleSelector;
        RMMAutoHistorySelector mockRMMAHSelector = md.mockRMMAutoHistorySelector;
        RelationshipMapMemberSelector mockRMMSelector = md.mockRelationshipMapMemberSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockOPSelector.selectByIds(new Set<Id>{ md.mockOpportunityPlanId }))
            .thenReturn(new List<PQ_Opportunity_Plan__c>{ md.mockOpportunityPlan });

        md.mocks.when(mockOCRSelector.selectByOpportunityIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<OpportunityContactRole>{ md.mockOpportunityContactRole });
        md.mocks.when(mockRMMAHSelector.selectByMapIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Relationship_Map_Member_Auto_History__c>());
        md.mocks.when(mockRMMSelector.selectByMapIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Relationship_Map_Member__c>{ md.mockRelationshipMapMember });
        md.mocks.stopStubbing();

        Test.startTest();
        Relationship_Map__c result = OpportunityPlanService.createRelationshipMapForOppPlanId(md.mockOpportunityPlanId);
        Test.stopTest();

        //Verify a map was returned
        System.assertNotEquals(null, result, 'Should return a newly created map');
        //Verify members were not added or removed since the contact was manually added
        ((OpportunityContactRoleSelector) md.mocks.verify(mockOCRSelector, 1))
            .selectByOpportunityIds((Set<Id>) fflib_Match.anyObject());
        ((RMMAutoHistorySelector) md.mocks.verify(mockRMMAHSelector, 1))
            .selectByMapIds((Set<Id>) fflib_Match.anyObject());
        ((RelationshipMapMemberSelector) md.mocks.verify(mockRMMSelector, 1))
            .selectByMapIds((Set<Id>) fflib_Match.anyObject());
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUoW, 0)).registerNew((List<SObject>) fflib_Match.anyList());
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUoW, 0)).registerDeleted((List<SObject>) fflib_Match.anyList());
    }

    @IsTest
    static void createRelationshipMapForOppPlanIdRemoveOCRExistingTest() {
        TestMockData md = new TestMockData();
        OpportunityPlanSelector mockOPSelector = md.mockOpportunityPlanSelector;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUoW;
        OpportunityContactRoleSelector mockOCRSelector = md.mockOpportunityContactRoleSelector;
        RMMAutoHistorySelector mockRMMAHSelector = md.mockRMMAutoHistorySelector;
        RelationshipMapMemberSelector mockRMMSelector = md.mockRelationshipMapMemberSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockOPSelector.selectByIds(new Set<Id>{ md.mockOpportunityPlanId }))
            .thenReturn(new List<PQ_Opportunity_Plan__c>{ md.mockOpportunityPlan });

        md.mocks.when(mockOCRSelector.selectByOpportunityIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<OpportunityContactRole>());
        md.mocks.when(mockRMMAHSelector.selectByMapIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Relationship_Map_Member_Auto_History__c>());
        md.mocks.when(mockRMMSelector.selectByMapIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Relationship_Map_Member__c>{ md.mockRelationshipMapMember });
        md.mocks.stopStubbing();

        Test.startTest();
        Relationship_Map__c result = OpportunityPlanService.createRelationshipMapForOppPlanId(md.mockOpportunityPlanId);
        Test.stopTest();

        //Verify a map was returned
        System.assertNotEquals(null, result, 'Should return a newly created map');
        //Verify members were not added or removed since the contact was manually added
        ((OpportunityContactRoleSelector) md.mocks.verify(mockOCRSelector, 1))
            .selectByOpportunityIds((Set<Id>) fflib_Match.anyObject());
        ((RMMAutoHistorySelector) md.mocks.verify(mockRMMAHSelector, 1))
            .selectByMapIds((Set<Id>) fflib_Match.anyObject());
        ((RelationshipMapMemberSelector) md.mocks.verify(mockRMMSelector, 1))
            .selectByMapIds((Set<Id>) fflib_Match.anyObject());
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUoW, 0)).registerNew((List<SObject>) fflib_Match.anyList());
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUoW, 0)).registerDeleted((List<SObject>) fflib_Match.anyList());
    }

    @IsTest
    static void createRelationshipMapForOppPlanIdRemoveOCRNotExistingTest() {
        TestMockData md = new TestMockData();
        OpportunityPlanSelector mockOPSelector = md.mockOpportunityPlanSelector;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUoW;
        OpportunityContactRoleSelector mockOCRSelector = md.mockOpportunityContactRoleSelector;
        RMMAutoHistorySelector mockRMMAHSelector = md.mockRMMAutoHistorySelector;
        RelationshipMapMemberSelector mockRMMSelector = md.mockRelationshipMapMemberSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockOPSelector.selectByIds(new Set<Id>{ md.mockOpportunityPlanId }))
            .thenReturn(new List<PQ_Opportunity_Plan__c>{ md.mockOpportunityPlan });

        md.mocks.when(mockOCRSelector.selectByOpportunityIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<OpportunityContactRole>());
        md.mocks.when(mockRMMAHSelector.selectByMapIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Relationship_Map_Member_Auto_History__c>{ md.mockRelationshipMapMemberAutoHistory });
        md.mocks.when(mockRMMSelector.selectByMapIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Relationship_Map_Member__c>{ md.mockRelationshipMapMember });
        md.mocks.stopStubbing();

        Test.startTest();
        Relationship_Map__c result = OpportunityPlanService.createRelationshipMapForOppPlanId(md.mockOpportunityPlanId);
        Test.stopTest();

        //Verify a map was returned
        System.assertNotEquals(null, result, 'Should return a newly created map');
        //Verify members were not added or removed since the contact was manually added
        ((OpportunityContactRoleSelector) md.mocks.verify(mockOCRSelector, 1))
            .selectByOpportunityIds((Set<Id>) fflib_Match.anyObject());
        ((RMMAutoHistorySelector) md.mocks.verify(mockRMMAHSelector, 1))
            .selectByMapIds((Set<Id>) fflib_Match.anyObject());
        ((RelationshipMapMemberSelector) md.mocks.verify(mockRMMSelector, 1))
            .selectByMapIds((Set<Id>) fflib_Match.anyObject());
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUoW, 0)).registerNew((List<SObject>) fflib_Match.anyList());
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUoW, 2)).registerDeleted((List<SObject>) fflib_Match.anyList());
    }

    @IsTest
    static void getAccountIdForOppPlanIdNullTest() {
        Test.startTest();
        Id result = OpportunityPlanService.getAccountIdForOppPlanId(null);
        Test.stopTest();

        System.assertEquals(null, result, 'Should return null when null is passed in');
    }

    @IsTest
    static void getAccountIdForOppPlanIdWrongTypeTest() {
        Id mockId = fflib_IDGenerator.generate(Contact.sObjectType);

        Test.startTest();
        Id result = OpportunityPlanService.getAccountIdForOppPlanId(mockId);
        Test.stopTest();

        System.assertEquals(null, result, 'Should return null when a non Opportunity Plan Id is passed in');
    }

    @IsTest
    static void getAccountIdForOppPlanIdNoneFoundTest() {
        TestMockData md = new TestMockData();
        OpportunityPlanSelector mockOPSelector = md.mockOpportunityPlanSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockOPSelector.selectByIds(new Set<Id>{ md.mockOpportunityPlanId }))
            .thenReturn(new List<PQ_Opportunity_Plan__c>());
        md.mocks.stopStubbing();

        Test.startTest();
        Id result = OpportunityPlanService.getAccountIdForOppPlanId(md.mockOpportunityPlanId);
        Test.stopTest();

        System.assertEquals(null, result, 'Should return null when no Opportunity Plan is found');
    }

    @IsTest
    static void getAccountIdForOppPlanNoRelatedOppTest() {
        TestMockData md = new TestMockData();
        OpportunityPlanSelector mockOPSelector = md.mockOpportunityPlanSelector;
        md.mockOpportunityPlan.Opportunity__r = null;

        md.mocks.startStubbing();
        md.mocks.when(mockOPSelector.selectByIds(new Set<Id>{ md.mockOpportunityPlanId }))
            .thenReturn(new List<PQ_Opportunity_Plan__c>{ md.mockOpportunityPlan });
        md.mocks.stopStubbing();

        Test.startTest();
        Id result = OpportunityPlanService.getAccountIdForOppPlanId(md.mockOpportunityPlanId);
        Test.stopTest();

        System.assertEquals(null, result, 'Should return the null when the Opportunity has no Account Id');
    }

    @IsTest
    static void getAccountIdForOppPlanNoOppAccountTest() {
        TestMockData md = new TestMockData();
        OpportunityPlanSelector mockOPSelector = md.mockOpportunityPlanSelector;
        md.mockOpportunity.AccountId = null;
        md.mockOpportunityPlan.Opportunity__r = md.mockOpportunity;

        md.mocks.startStubbing();
        md.mocks.when(mockOPSelector.selectByIds(new Set<Id>{ md.mockOpportunityPlanId }))
            .thenReturn(new List<PQ_Opportunity_Plan__c>{ md.mockOpportunityPlan });
        md.mocks.stopStubbing();

        Test.startTest();
        Id result = OpportunityPlanService.getAccountIdForOppPlanId(md.mockOpportunityPlanId);
        Test.stopTest();

        System.assertEquals(null, result, 'Should return the null when the Opportunity has no Account Id');
    }

    @IsTest
    static void getAccountIdForOppPlanHappyPathTest() {
        TestMockData md = new TestMockData();
        OpportunityPlanSelector mockOPSelector = md.mockOpportunityPlanSelector;
        md.mockOpportunity.AccountId = md.mockAccountId;
        md.mockOpportunityPlan.Opportunity__r = md.mockOpportunity;

        md.mocks.startStubbing();
        md.mocks.when(mockOPSelector.selectByIds(new Set<Id>{ md.mockOpportunityPlanId }))
            .thenReturn(new List<PQ_Opportunity_Plan__c>{ md.mockOpportunityPlan });
        md.mocks.stopStubbing();

        Test.startTest();
        Id result = OpportunityPlanService.getAccountIdForOppPlanId(md.mockOpportunityPlanId);
        Test.stopTest();

        System.assertEquals(
            md.mockAccountId,
            result,
            'Should return the Account Id of the Opportunity related to the Opportunity Plan'
        );
    }
}