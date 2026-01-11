@isTest
private class AccountContactRelationServiceTest {
    @isTest
    static void areAccountContactRelationEnabledTest() {
        AccountContactRelationService.areAccountContactRelationEnabled();

        System.assert(true, 'This should not throw any errors.');
    }
}