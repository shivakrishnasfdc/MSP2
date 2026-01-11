@isTest
private class GetFieldLableAndFieldAPIForColumnsTest {
    @isTest
    static void testGetFieldLableAndFieldAPI() {
        // Test data
        String objectName = 'pqcrush__Account_Plan_Opportunity__c'; // Replace with your actual object name

        // Call the method
        Test.startTest();
        List<GetAccountPlanChildWrapper> result = GetFieldLableAndFieldAPIForColumns.getFieldLableAndFieldAPI(
            objectName
        );
        Test.stopTest();

        // Add your assertions based on the expected results
        System.assertNotEquals(null, result, 'Result should not be null');
        // Add more assertions based on your specific requirements
    }

    // Add more test methods as needed
}