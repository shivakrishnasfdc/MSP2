@isTest
private class AccountPlanUserSettingSelectorTest {
    @isTest
    static void newInstanceTest() {
        AccountPlanUserSettingSelector selector = AccountPlanUserSettingSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        Account_Plan__c ap = TestDataFactory.createAccountPlan('planA');

        pq_CRUSH_Account_Plan_User_Setting__c newSetting = new pq_CRUSH_Account_Plan_User_Setting__c(
            Account_Plan__c = ap.Id,
            Objective_Overview_Chart_Type__c = 'Bar',
            User__c = UserInfo.getUserId()
        );
        insert newSetting;

        Test.startTest();
        List<pq_CRUSH_Account_Plan_User_Setting__c> result = new AccountPlanUserSettingSelector()
            .selectById(new Set<Id>{ newSetting.Id });
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals(newSetting.Id, result[0].Id);
    }

    @isTest
    static void selectByAccountPlansTest() {
        Account_Plan__c ap = TestDataFactory.createAccountPlan('planA');
        Set<Id> accountPlanIds = new Set<Id>{ ap.Id };

        pq_CRUSH_Account_Plan_User_Setting__c newSetting = new pq_CRUSH_Account_Plan_User_Setting__c(
            Account_Plan__c = ap.Id,
            Objective_Overview_Chart_Type__c = 'Bar',
            User__c = UserInfo.getUserId()
        );
        insert newSetting;

        Test.startTest();
        List<pq_CRUSH_Account_Plan_User_Setting__c> result = new AccountPlanUserSettingSelector()
            .selectByAccountPlans(accountPlanIds, UserInfo.getUserId());
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals('Bar', result[0].Objective_Overview_Chart_Type__c);
        System.assertEquals(ap.Id, result[0].Account_Plan__c);
    }
}