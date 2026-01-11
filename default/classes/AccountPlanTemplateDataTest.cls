@isTest
public with sharing class AccountPlanTemplateDataTest {
    @isTest
    public static void getData() {
        Test.startTest();
        TestDataFactory.createAccountPlanTemplate();
        List<pqcrush__Account_Plan_Template__c> accountPlanList = AccountPlanTemplateData.getData('Test Account Plan');
        System.assertEquals(1, accountPlanList.size(), 'Size of accountPlanList should be 1');
        Test.stopTest();
    }

    @isTest
    public static void showDefaultPlan() {
        Test.startTest();
        TestDataFactory.checkDefaultTest();
        Id accountPlanList = AccountPlanTemplateData.showDefaultPlan();
        System.assertNotEquals(null, accountPlanList, 'accountPlanList should not be null');
        Test.stopTest();
    }

    @isTest
    public static void getAllAccountPlan() {
        Test.startTest();
        TestDataFactory.createAccountPlanTemplate();
        List<pqcrush__Account_Plan_Template__c> accountPlanList = AccountPlanTemplateData.getAllAccountPlan();
        System.assertNotEquals(null, accountPlanList, 'accountPlanList should not be null');
        Test.stopTest();
    }
}