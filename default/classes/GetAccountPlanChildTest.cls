@isTest
private class GetAccountPlanChildTest {
    @isTest
    public static void testGetRelatedChild() {
        Test.startTest();
        List<GetAccountPlanChildWrapper> result = GetAccountPlanChild.getRelatedChild();
        Test.stopTest();

        // Assert the result based on your expectations
        System.assertNotEquals(null, result, 'Result should not be null');
        // Add more assertions based on the expected behavior of your method
    }

    // Add more test methods as needed
}