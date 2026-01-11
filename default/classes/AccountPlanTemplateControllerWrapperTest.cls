@isTest
public with sharing class AccountPlanTemplateControllerWrapperTest {
    @isTest
    public static void getAllAccountPlans() {
        Test.startTest();
        TestDataFactory.createAccountPlan('Test');
        List<pqcrush__Account_Plan__c> accountPlanList = AccountPlanTemplateControllerWrapper.getAllAccountPlans();
        System.assertNotEquals(0, accountPlanList.size(), 'Size of accountPlanList should not be 0');
        Test.stopTest();
    }

    @isTest
    public static void getAllAccountPlansWithNoData() {
        Test.startTest();
        List<pqcrush__Account_Plan__c> accountPlanList = AccountPlanTemplateControllerWrapper.getAllAccountPlans();
        System.assertEquals(null, accountPlanList, 'accountPlanList should be null');
        Test.stopTest();
    }
}