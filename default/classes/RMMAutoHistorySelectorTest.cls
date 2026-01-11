@isTest
private with sharing class RMMAutoHistorySelectorTest {
    @isTest
    static void newInstanceTest() {
        Test.startTest();
        RMMAutoHistorySelector result = RMMAutoHistorySelector.newInstance();
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(
            Relationship_Map_Member_Auto_History__c.SObjectType,
            result.getSObjectType(),
            'Result should be of type Relationship_Map_Member_Auto_History__c'
        );
    }

    @isTest
    static void selectByMapIdsNullTest() {
        Contact c = TestDataFactory.createContact('sbopint_First', 'sbopint_Last');
        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('sbmint Test Relationship Map');
        TestDataFactory.createRelationshipMapMemberAutoHistory(rm, c);

        Test.startTest();
        List<Relationship_Map_Member_Auto_History__c> result = RMMAutoHistorySelector.newInstance()
            .selectByMapIds(null);
        Test.stopTest();
        System.assertEquals(0, result.size(), 'Result should be empty');
    }

    @isTest
    static void selectByMapIdsEmptyTest() {
        Contact c = TestDataFactory.createContact('sbopint_First', 'sbopint_Last');
        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('sbmiet Test Relationship Map');
        TestDataFactory.createRelationshipMapMemberAutoHistory(rm, c);

        Test.startTest();
        List<Relationship_Map_Member_Auto_History__c> result = RMMAutoHistorySelector.newInstance()
            .selectByMapIds(new Set<Id>());
        Test.stopTest();
        System.assertEquals(0, result.size(), 'Result should be empty');
    }

    @isTest
    static void selectByMapIdsHappPathTest() {
        Contact c1 = TestDataFactory.createContact('sbopint_First1', 'sbopint_Last1');
        Contact c2 = TestDataFactory.createContact('sbopint_First2', 'sbopint_Last2');
        Relationship_Map__c rm1 = TestDataFactory.createRelationshipMap('sbmiet Test Relationship Map');
        Relationship_Map__c rm2 = TestDataFactory.createRelationshipMap('sbmiet Test Relationship Map2');
        Relationship_Map_Member_Auto_History__c h11 = TestDataFactory.createRelationshipMapMemberAutoHistory(rm1, c1);
        Relationship_Map_Member_Auto_History__c h12 = TestDataFactory.createRelationshipMapMemberAutoHistory(rm1, c2);
        Relationship_Map_Member_Auto_History__c h21 = TestDataFactory.createRelationshipMapMemberAutoHistory(rm2, c1);
        Relationship_Map_Member_Auto_History__c h22 = TestDataFactory.createRelationshipMapMemberAutoHistory(rm2, c2);

        Test.startTest();
        List<Relationship_Map_Member_Auto_History__c> result = RMMAutoHistorySelector.newInstance()
            .selectByMapIds(new Set<Id>{ rm1.Id });
        Test.stopTest();
        System.assertEquals(2, result.size(), 'Result should contain 2 records');
        Set<Id> resultIds = (new Map<Id, Relationship_Map_Member_Auto_History__c>(result)).keySet();
        System.assert(resultIds.contains(h11.Id), 'Result should contain h11');
        System.assert(resultIds.contains(h12.Id), 'Result should contain h12');
        System.assert(!resultIds.contains(h21.Id), 'Result should not contain h21');
        System.assert(!resultIds.contains(h22.Id), 'Result should not contain h22');
    }
}