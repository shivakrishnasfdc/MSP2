@isTest
private class GetChildRecordsWithFieldSetTest {
    @isTest
    static void testChildRecordsWithFieldSet() {
        Test.startTest();
        pqcrush__Account_Plan__c acPlan = TestDataFactory.createAccountPlan('test');
        String result = GetChildRecordsWithFieldSet.childRecordsWithFieldSet(
            'pqcrush__Account_Plan_Opportunity__c',
            acPlan.Id
        );
        // Perform assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        Test.stopTest();
        // Add more assertions as needed
    }

    @isTest
    public static void getObjectName() {
        Test.startTest();
        String result = GetChildRecordsWithFieldSet.getObjectName('Account');
        System.assertNotEquals(null, result, 'Result should not be null');
        Test.stopTest();
    }
}