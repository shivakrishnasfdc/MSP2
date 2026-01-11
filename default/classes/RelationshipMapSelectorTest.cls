@isTest
private class RelationshipMapSelectorTest {
    @isTest
    static void newInstanceTest() {
        RelationshipMapSelector selector = RelationshipMapSelector.newInstance();

        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        Relationship_Map__c relMap = TestDataFactory.createRelationshipMap('mapname');

        Test.startTest();
        List<Relationship_Map__c> maps = new RelationshipMapSelector().selectByIds(new Set<Id>{ relMap.Id });
        Test.stopTest();

        System.assertEquals(relMap.Id, maps[0].Id);
    }

    @isTest
    static void selectAllTest() {
        TestDataFactory.createRelationshipMap('mapname');
        TestDataFactory.createRelationshipMap('mapname');
        TestDataFactory.createRelationshipMap('mapname');

        Test.startTest();
        List<Relationship_Map__c> maps = new RelationshipMapSelector().selectAll();
        Test.stopTest();

        System.assertEquals(3, maps.size());
    }

    @isTest
    static void selectByAccountPlanIdsNullTest() {
        Account_Plan__c plan1 = TestDataFactory.createAccountPlan('rmst_sbapnt_test_1');
        Account_Plan__c plan2 = TestDataFactory.createAccountPlan('rmst_sbapnt_test_2');
        TestDataFactory.createRelationshipMap('mapname', plan1.Id);
        TestDataFactory.createRelationshipMap('mapname', plan2.Id);
        TestDataFactory.createRelationshipMap('mapname');

        Test.startTest();
        List<Relationship_Map__c> result = RelationshipMapSelector.newInstance().selectByAccountPlanIds(null);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Result should be empty when null is passed in');
    }

    @isTest
    static void selectByAccountPlanIdsEmptyTest() {
        Account_Plan__c plan1 = TestDataFactory.createAccountPlan('rmst_sbapnt_test_1');
        Account_Plan__c plan2 = TestDataFactory.createAccountPlan('rmst_sbapnt_test_2');
        TestDataFactory.createRelationshipMap('mapname', plan1.Id);
        TestDataFactory.createRelationshipMap('mapname', plan2.Id);
        TestDataFactory.createRelationshipMap('mapname');

        Test.startTest();
        List<Relationship_Map__c> result = RelationshipMapSelector.newInstance().selectByAccountPlanIds(new Set<Id>{});
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Result should be empty when empty set is passed in');
    }

    @isTest
    static void selectByAccountPlanIdsNoMatchesTest() {
        Account_Plan__c plan1 = TestDataFactory.createAccountPlan('rmst_sbapnt_test_1');
        Account_Plan__c plan2 = TestDataFactory.createAccountPlan('rmst_sbapnt_test_2');
        TestDataFactory.createRelationshipMap('mapname', plan1.Id);
        TestDataFactory.createRelationshipMap('mapname', plan1.Id);
        TestDataFactory.createRelationshipMap('mapname');

        Test.startTest();
        List<Relationship_Map__c> result = RelationshipMapSelector.newInstance()
            .selectByAccountPlanIds(new Set<Id>{ plan2.Id });
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Result should be empty when no matches are found');
    }

    @isTest
    static void selectByAccountPlanIdsSinglePlanTest() {
        Account_Plan__c plan1 = TestDataFactory.createAccountPlan('rmst_sbapnt_test_1');
        Account_Plan__c plan2 = TestDataFactory.createAccountPlan('rmst_sbapnt_test_2');
        Relationship_Map__c expected = TestDataFactory.createRelationshipMap('mapname', plan1.Id);
        TestDataFactory.createRelationshipMap('mapname', plan2.Id);
        TestDataFactory.createRelationshipMap('mapname');

        Test.startTest();
        List<Relationship_Map__c> result = RelationshipMapSelector.newInstance()
            .selectByAccountPlanIds(new Set<Id>{ plan1.Id });
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Result should contain one matching record');
        System.assertEquals(expected.Id, result[0].Id, 'Result should contain the expected record');
    }

    @isTest
    static void selectByAccountPlanIdsMultiplePlansTest() {
        Account_Plan__c plan1 = TestDataFactory.createAccountPlan('rmst_sbapnt_test_1');
        Account_Plan__c plan2 = TestDataFactory.createAccountPlan('rmst_sbapnt_test_2');
        Account_Plan__c plan3 = TestDataFactory.createAccountPlan('rmst_sbapnt_test_3');
        Relationship_Map__c relMap1 = TestDataFactory.createRelationshipMap('mapname', plan1.Id);
        Relationship_Map__c relMap2 = TestDataFactory.createRelationshipMap('mapname', plan2.Id);
        TestDataFactory.createRelationshipMap('mapname', plan3.Id);
        TestDataFactory.createRelationshipMap('mapname');

        Test.startTest();
        List<Relationship_Map__c> result = RelationshipMapSelector.newInstance()
            .selectByAccountPlanIds(new Set<Id>{ plan1.Id, plan2.Id });
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Result should contain two matching records');
        Set<Id> expectedIds = new Set<Id>{ relMap1.Id, relMap2.Id };
        Set<Id> resultIds = new Set<Id>{ result[0].Id, result[1].Id };
        System.assertEquals(expectedIds, resultIds, 'Result should contain the expected records');
    }

    @isTest
    static void selectByOppPlanIdsNullTest() {
        Test.startTest();
        List<Relationship_Map__c> result = RelationshipMapSelector.newInstance().selectByOppPlanIds(null);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty list when null is passed in');
    }

    @isTest
    static void selectByOppPlanIdsEmptyTest() {
        Test.startTest();
        List<Relationship_Map__c> result = RelationshipMapSelector.newInstance().selectByOppPlanIds(new Set<Id>{});
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty list when empty set is passed in');
    }

    @isTest
    static void selectByOppPlanIdsNoMatchesTest() {
        Opportunity opp = TestDataFactory.createOpportunity('rmst_sbopinmt_test_opp');
        PQ_Opportunity_Plan__c plan1 = TestDataFactory.createOpportunityPlan(opp);
        PQ_Opportunity_Plan__c plan2 = TestDataFactory.createOpportunityPlan(opp);
        TestDataFactory.createRelationshipMap('mapname', null, plan1.Id);
        TestDataFactory.createRelationshipMap('mapname', null, plan1.Id);
        TestDataFactory.createRelationshipMap('mapname');

        Test.startTest();
        List<Relationship_Map__c> result = RelationshipMapSelector.newInstance()
            .selectByOppPlanIds(new Set<Id>{ plan2.Id });
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty list when no matches are found');
    }

    @isTest
    static void selectByOppPlanIdsSinglePlanTest() {
        Opportunity opp = TestDataFactory.createOpportunity('rmst_sbopinmt_test_opp');
        PQ_Opportunity_Plan__c plan1 = TestDataFactory.createOpportunityPlan(opp);
        PQ_Opportunity_Plan__c plan2 = TestDataFactory.createOpportunityPlan(opp);
        Relationship_Map__c expected = TestDataFactory.createRelationshipMap('mapname', null, plan1.Id);
        TestDataFactory.createRelationshipMap('mapname', null, plan2.Id);
        TestDataFactory.createRelationshipMap('mapname');

        Test.startTest();
        List<Relationship_Map__c> result = RelationshipMapSelector.newInstance()
            .selectByOppPlanIds(new Set<Id>{ plan1.Id });
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should return one matching record');
        System.assertEquals(expected.Id, result[0].Id, 'Should return the expected record');
    }

    @isTest
    static void selectByOppPlanIdsMultiplePlansTest() {
        Opportunity opp = TestDataFactory.createOpportunity('rmst_sbopinmt_test_opp');
        PQ_Opportunity_Plan__c plan1 = TestDataFactory.createOpportunityPlan(opp);
        PQ_Opportunity_Plan__c plan2 = TestDataFactory.createOpportunityPlan(opp);
        PQ_Opportunity_Plan__c plan3 = TestDataFactory.createOpportunityPlan(opp);
        Relationship_Map__c relMap1 = TestDataFactory.createRelationshipMap('mapname', null, plan1.Id);
        Relationship_Map__c relMap2 = TestDataFactory.createRelationshipMap('mapname', null, plan2.Id);
        TestDataFactory.createRelationshipMap('mapname', null, plan3.Id);
        TestDataFactory.createRelationshipMap('mapname');

        Test.startTest();
        List<Relationship_Map__c> result = RelationshipMapSelector.newInstance()
            .selectByOppPlanIds(new Set<Id>{ plan1.Id, plan2.Id });
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Should return two matching records');
        Set<Id> expectedIds = new Set<Id>{ relMap1.Id, relMap2.Id };
        Set<Id> resultIds = new Set<Id>{ result[0].Id, result[1].Id };
        System.assertEquals(expectedIds, resultIds, 'Should return the expected records');
    }
}