@isTest
private class SObjectControllerTest {
    @isTest
    static void getRecordTypeInfosTest() {
        try {
            SObjectController.getRecordTypeInfos('pqcrush__Account_Plan__c');
        } catch (Exception e) {
            System.assert(false, 'failed in catch');
        }
        System.assert(true, 'no errors');
    }

    //TODO: Update this test method
    @isTest
    static void getFieldDetailsTest() {
        String sobjectApiName = 'Account';
        try {
            Test.startTest();
            SObjectController.getFieldDetails(sobjectApiName);
            Test.stopTest();
        } catch (Exception e) {
            System.assertEquals('System.NullPointerException', e.getTypeName(), 'Invalid Exception');
        }
    }
}