@isTest
private class AccountPlanMatrixAssociationSelectorTest {
    @isTest
    static void newInstanceTest() {
        AccountPlanMatrixAssociationSelector selector = AccountPlanMatrixAssociationSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByAccountPlansTest() {
        Account_Plan__c ap = TestDataFactory.createAccountPlan('planA');
        pq_Influence_And_Support_Matrix__c m1 = new pq_Influence_And_Support_Matrix__c(Name = 'one');
        insert m1;
        pq_Account_Plan_Matrix_Association__c input1 = new pq_Account_Plan_Matrix_Association__c(
            Account_Plan__c = ap.Id,
            Influence_And_Support_Matrix__c = m1.Id
        );
        insert input1;

        Set<Id> accountPlanIds = new Set<Id>{ ap.Id };

        Test.startTest();
        List<pq_Account_Plan_Matrix_Association__c> result = new AccountPlanMatrixAssociationSelector()
            .selectByAccountPlans(accountPlanIds);
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals(m1.Id, result[0].Influence_And_Support_Matrix__c);
        System.assertEquals(ap.Id, result[0].Account_Plan__c);
    }
}