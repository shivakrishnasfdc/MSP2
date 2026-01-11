@isTest
private class RelationshipGroupLeadSelectorTest {
    @isTest
    static void selectByIdTest() {
        // Given

        Lead l1 = TestDataFactory.createLead('fname', 'lname', 'acme');
        Lead l2 = TestDataFactory.createLead('fname2', 'lname2', 'acme2');
        Lead l3 = TestDataFactory.createLead('fname3', 'lname3', 'acme3');

        Relationship_Group__c g1 = TestDataFactory.createRelationshipGroup('groupa');

        Relationship_Group_Lead_Association__c rga1 = TestDataFactory.createRelationshipGroupLeadAssociation(g1, l1);
        Relationship_Group_Lead_Association__c rga2 = TestDataFactory.createRelationshipGroupLeadAssociation(g1, l2);
        TestDataFactory.createRelationshipGroupLeadAssociation(g1, l3);

        // When
        Test.startTest();

        List<Relationship_Group_Lead_Association__c> result = new RelationshipGroupLeadSelector()
            .selectById(new Set<Id>{ rga1.Id, rga2.Id });

        Test.stopTest();

        // Then

        System.assertEquals(2, result.size(), 'Expected 2 records.');
        System.assert(rga1.Id == result[0].Id || rga2.Id == result[0].Id);
        System.assert(rga1.Id == result[1].Id || rga2.Id == result[1].Id);
    }

    @isTest
    static void selectByLeadIdsTest() {
        // Given

        Lead l1 = TestDataFactory.createLead('fname', 'lname', 'acme');
        Lead l2 = TestDataFactory.createLead('fname2', 'lname2', 'acme2');
        Lead l3 = TestDataFactory.createLead('fname3', 'lname3', 'acme3');

        Relationship_Group__c g1 = TestDataFactory.createRelationshipGroup('groupa');

        Relationship_Group_Lead_Association__c rga1 = TestDataFactory.createRelationshipGroupLeadAssociation(g1, l1);
        Relationship_Group_Lead_Association__c rga2 = TestDataFactory.createRelationshipGroupLeadAssociation(g1, l2);
        TestDataFactory.createRelationshipGroupLeadAssociation(g1, l3);

        // When
        Test.startTest();

        List<Relationship_Group_Lead_Association__c> result = new RelationshipGroupLeadSelector()
            .selectByLeadIds(new Set<String>{ l1.Id, l2.Id });

        Test.stopTest();

        // Then

        System.assertEquals(2, result.size(), 'Expected 2 records.');
        System.assert(rga1.Id == result[0].Id || rga2.Id == result[0].Id);
        System.assert(rga1.Id == result[1].Id || rga2.Id == result[1].Id);
    }

    @isTest
    static void selectWithGroupsByLeadIdsTest() {
        // Given

        Lead l1 = TestDataFactory.createLead('fname', 'lname', 'acme');
        Lead l2 = TestDataFactory.createLead('fname2', 'lname2', 'acme2');
        Lead l3 = TestDataFactory.createLead('fname3', 'lname3', 'acme3');

        Relationship_Group__c g1 = TestDataFactory.createRelationshipGroup('groupa');

        Relationship_Group_Lead_Association__c rga1 = TestDataFactory.createRelationshipGroupLeadAssociation(g1, l1);
        Relationship_Group_Lead_Association__c rga2 = TestDataFactory.createRelationshipGroupLeadAssociation(g1, l2);
        TestDataFactory.createRelationshipGroupLeadAssociation(g1, l3);

        // When
        Test.startTest();

        List<Relationship_Group_Lead_Association__c> result = new RelationshipGroupLeadSelector()
            .selectWithGroupsByLeadIds(new Set<Id>{ l1.Id, l2.Id });

        Test.stopTest();

        // Then

        System.assertEquals(2, result.size(), 'Expected 2 records.');
        System.assert(rga1.Id == result[0].Id || rga2.Id == result[0].Id);
        System.assert(rga1.Id == result[1].Id || rga2.Id == result[1].Id);
        System.assert(result[0].Relationship_Group__r.pqcrush__Label__c == 'groupa');
    }

    @isTest
    static void selectByLeadIdsForLocalGroupTest() {
        // Given
        Lead l1 = TestDataFactory.createLead('fname', 'lname', 'acme');
        Lead l2 = TestDataFactory.createLead('fname2', 'lname2', 'acme2');
        Lead l3 = TestDataFactory.createLead('fname3', 'lname3', 'acme3');

        Relationship_Map__c map1 = TestDataFactory.createRelationshipMap('TestMap');

        Relationship_Group__c g1 = TestDataFactory.createRelationshipGroupForMap('groupa', map1.Id);

        Relationship_Group_Lead_Association__c rga1 = TestDataFactory.createRelationshipGroupLeadAssociation(g1, l1);
        Relationship_Group_Lead_Association__c rga2 = TestDataFactory.createRelationshipGroupLeadAssociation(g1, l2);
        TestDataFactory.createRelationshipGroupLeadAssociation(g1, l3);

        // When
        Test.startTest();

        List<Relationship_Group_Lead_Association__c> result = new RelationshipGroupLeadSelector()
            .selectByLeadIdsForLocalGroup(new Set<String>{ l1.Id, l2.Id }, map1.Id);

        Test.stopTest();

        // Then

        System.assertEquals(2, result.size(), 'Expected 2 records.');
        System.assert(rga1.Id == result[0].Id || rga2.Id == result[0].Id);
        System.assert(rga1.Id == result[1].Id || rga2.Id == result[1].Id);
        System.assert(result[0].Relationship_Group__r.Relationship_Map__c == map1.Id);
    }

    @isTest
    static void selectByLeadIdsForGlobalGroupTest() {
        // Given
        Lead l1 = TestDataFactory.createLead('fname', 'lname', 'acme');
        Lead l2 = TestDataFactory.createLead('fname2', 'lname2', 'acme2');
        Lead l3 = TestDataFactory.createLead('fname3', 'lname3', 'acme3');

        Relationship_Map__c map1 = TestDataFactory.createRelationshipMap('TestMap');

        Relationship_Group__c g1 = TestDataFactory.createRelationshipGroupForMap('groupa', map1.Id);

        Relationship_Group__c g2 = TestDataFactory.createRelationshipGroup('groupb');

        TestDataFactory.createRelationshipGroupLeadAssociation(g1, l1);
        TestDataFactory.createRelationshipGroupLeadAssociation(g1, l2);
        TestDataFactory.createRelationshipGroupLeadAssociation(g1, l3);

        Relationship_Group_Lead_Association__c rga4 = TestDataFactory.createRelationshipGroupLeadAssociation(g2, l3);

        // When
        Test.startTest();

        List<Relationship_Group_Lead_Association__c> result = new RelationshipGroupLeadSelector()
            .selectByLeadIdsForGlobalGroup(new Set<String>{ l3.Id });

        Test.stopTest();

        // Then

        System.assertEquals(1, result.size(), 'Expected 1 record.');
        System.assert(rga4.Id == result[0].Id);
    }
}