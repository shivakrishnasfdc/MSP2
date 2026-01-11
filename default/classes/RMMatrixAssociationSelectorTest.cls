@isTest
private class RMMatrixAssociationSelectorTest {
    @isTest
    static void newInstanceTest() {
        RMMatrixAssociationSelector selector = RMMatrixAssociationSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByRelationshipMapsTest() {
        Relationship_Map__c map1 = TestDataFactory.createRelationshipMap('map1');
        pq_Influence_And_Support_Matrix__c m1 = new pq_Influence_And_Support_Matrix__c(Name = 'one');
        insert m1;
        pq_Relationship_Map_Matrix_Association__c input1 = new pq_Relationship_Map_Matrix_Association__c(
            Relationship_Map__c = map1.Id,
            Influence_And_Support_Matrix__c = m1.Id
        );
        insert input1;

        Set<Id> mapIds = new Set<Id>{ map1.Id };

        Test.startTest();
        List<pq_Relationship_Map_Matrix_Association__c> result = new RMMatrixAssociationSelector()
            .selectByRelationshipMaps(mapIds);
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals(m1.Id, result[0].Influence_And_Support_Matrix__c);
        System.assertEquals(map1.Id, result[0].Relationship_Map__c);
    }
}