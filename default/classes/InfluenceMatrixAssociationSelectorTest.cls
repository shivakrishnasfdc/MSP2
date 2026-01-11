@isTest
private class InfluenceMatrixAssociationSelectorTest {
    @isTest
    static void newInstanceTest() {
        InfluenceMatrixAssociationSelector selector = InfluenceMatrixAssociationSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByMatrixIdTest() {
        pq_Influence__c s1 = new pq_Influence__c(Name = 'high', Label__c = 'highlabel');
        insert s1;
        pq_Influence_And_Support_Matrix__c m1 = new pq_Influence_And_Support_Matrix__c(Name = 'one');
        insert m1;
        pq_Influence_Matrix_Association__c input1 = new pq_Influence_Matrix_Association__c(
            Order__c = 1,
            Influence__c = s1.Id,
            Influence_And_Support_Matrix__c = m1.Id
        );
        insert input1;

        Set<Id> inputSet = new Set<Id>{ m1.Id };

        Test.startTest();
        List<pq_Influence_Matrix_Association__c> result = new InfluenceMatrixAssociationSelector()
            .selectByMatrixId(inputSet);
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals(m1.Id, result[0].Influence_And_Support_Matrix__c);
        System.assertEquals(s1.Id, result[0].Influence__c);
        System.assertEquals('high', result[0].Influence__r.Name);
        System.assertEquals('highlabel', result[0].Influence__r.Label__c);
    }
}