@isTest
private class InfluenceSupportMatrixSelectorTest {
    @isTest
    static void newInstanceTest() {
        InfluenceSupportMatrixSelector selector = InfluenceSupportMatrixSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        pq_Influence_And_Support_Matrix__c input1 = new pq_Influence_And_Support_Matrix__c(Name = 'one');
        pq_Influence_And_Support_Matrix__c input2 = new pq_Influence_And_Support_Matrix__c(Name = 'two');

        insert input1;
        insert input2;

        Set<Id> inputSet = new Set<Id>{ input1.Id, input2.Id };

        Test.startTest();
        List<pq_Influence_And_Support_Matrix__c> result = new InfluenceSupportMatrixSelector().selectById(inputSet);
        Test.stopTest();

        // Then the admin user should get back all three account plans
        System.assertEquals(2, result.size());
        for (pq_Influence_And_Support_Matrix__c matrix : result) {
            System.assert(inputSet.contains(matrix.Id));
        }
    }
}