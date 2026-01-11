@isTest
private class SupportMatrixAssociationSelectorTest {
    @isTest
    static void newInstanceTest() {
        SupportMatrixAssociationSelector selector = SupportMatrixAssociationSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByMatrixIdTest() {
        pq_Support__c s1 = new pq_Support__c(Name = 'blocker', Label__c = 'blockerlabel', Color__c = '#ff0011');
        insert s1;
        pq_Influence_And_Support_Matrix__c m1 = new pq_Influence_And_Support_Matrix__c(Name = 'one');
        insert m1;
        pq_Support_Matrix_Association__c input1 = new pq_Support_Matrix_Association__c(
            Order__c = 1,
            Support__c = s1.Id,
            Influence_And_Support_Matrix__c = m1.Id
        );
        insert input1;

        Set<Id> inputSet = new Set<Id>{ m1.Id };

        Test.startTest();
        List<pq_Support_Matrix_Association__c> result = new SupportMatrixAssociationSelector()
            .selectByMatrixId(inputSet);
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals(m1.Id, result[0].Influence_And_Support_Matrix__c);
        System.assertEquals(s1.Id, result[0].Support__c);
        System.assertEquals('blocker', result[0].Support__r.Name);
        System.assertEquals('blockerlabel', result[0].Support__r.Label__c);
        System.assertEquals('#ff0011', result[0].Support__r.Color__c);
    }
}