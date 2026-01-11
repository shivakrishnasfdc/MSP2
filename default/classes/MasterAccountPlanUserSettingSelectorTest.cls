@isTest
private class MasterAccountPlanUserSettingSelectorTest {
    @isTest
    static void newInstanceTest() {
        MasterAccountPlanUserSettingSelector selector = MasterAccountPlanUserSettingSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectForCurrentUserAndMasterAccountPlanTest() {
        pq_Master_Account_Plan__c m = new pq_Master_Account_Plan__c(Name = 'test');
        insert m;

        Master_Account_Plan_User_Setting__c setting = new Master_Account_Plan_User_Setting__c(User__c = UserInfo.getUserId(), Master_Account_Plan__c = m.Id);
        insert setting;

        List<Master_Account_Plan_User_Setting__c> result = MasterAccountPlanUserSettingSelector.newInstance().selectForCurrentUserAndMasterAccountPlan(m.Id);

        System.assertEquals(1, result.size());
        System.assertEquals(setting.Id, result[0].Id);
    }

    @isTest
    static void selectByUserIdEmptyTest() {
        TestMockData md = new TestMockData();

        pq_Master_Account_Plan__c m = new pq_Master_Account_Plan__c(Name = 'test');
        insert m;

        Master_Account_Plan_User_Setting__c setting = new Master_Account_Plan_User_Setting__c(Master_Account_Plan__c = m.Id);
        insert setting;

        List<Master_Account_Plan_User_Setting__c> result = MasterAccountPlanUserSettingSelector.newInstance().selectForCurrentUserAndMasterAccountPlan(md.mockMasterAccountPlanId);
        System.assertEquals(0, result.size());
    }
}