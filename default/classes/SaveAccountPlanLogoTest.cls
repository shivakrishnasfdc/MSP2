@isTest
public with sharing class SaveAccountPlanLogoTest {
    @isTest
    public static void saveAccountPlanUploadLogo() {
        Test.startTest();
        pqcrush__Account_Plan__c accPlan = TestDataFactory.createAccountPlan('Test');
        Map<string, string> saveFileData = SaveAccountPlanLogo.saveAccountPlanUploadLogo(
            'Test',
            'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3Ro',
            accPlan.Id,
            'Header_Logo'
        );
        System.assertEquals('Success', saveFileData.get('status'), 'Status should be Success');
        Test.stopTest();
    }

    @isTest
    public static void saveAccountPlanUploadLogoWithError() {
        Test.startTest();
        Map<string, string> saveFileData = SaveAccountPlanLogo.saveAccountPlanUploadLogo(
            'Test',
            'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3Ro',
            '',
            'Header_Logo'
        );
        System.assertEquals('Error', saveFileData.get('status'), 'Status should be Error');
        Test.stopTest();
    }

    @isTest
    public static void getContentVersion() {
        Test.startTest();
        pqcrush__Account_Plan__c accPlan = TestDataFactory.createAccountPlan('Test');
        TestDataFactory.createContentVersion('TestFileName', accPlan.Id, 'kcbkbcksbckbkckcbskcbdskcbkb');
        List<String> cvData = SaveAccountPlanLogo.getContentVersion(accPlan.Id, 'Header_Logo');
        System.assertNotEquals(null, cvData, 'Size of cvData should not be null');
        Test.stopTest();
    }

    @isTest
    public static void getContentVersionWithNoData() {
        Test.startTest();
        pqcrush__Account_Plan__c accPlan = TestDataFactory.createAccountPlan('Test');
        List<String> cvData = SaveAccountPlanLogo.getContentVersion(accPlan.Id, 'Header_Logo');
        System.assertEquals(null, cvData, 'cvData should be null');
        Test.stopTest();
    }
}