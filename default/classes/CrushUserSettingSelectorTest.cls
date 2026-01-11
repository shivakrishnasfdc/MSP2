@isTest
private class CrushUserSettingSelectorTest {
    @isTest
    static void newInstanceTest() {
        CrushUserSettingSelector selector = CrushUserSettingSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByUserIdTest() {
        pq_Crush_User_Setting__c setting = new pq_Crush_User_Setting__c(User__c = UserInfo.getUserId());
        insert setting;

        List<pq_Crush_User_Setting__c> result = CrushUserSettingSelector.newInstance().selectForCurrentUser();
        System.assertEquals(1, result.size());
        System.assertEquals(setting.Id, result[0].Id);
    }

    @isTest
    static void selectByUserIdEmptyTest() {
        pq_Crush_User_Setting__c setting = new pq_Crush_User_Setting__c();
        insert setting;

        List<pq_Crush_User_Setting__c> result = CrushUserSettingSelector.newInstance().selectForCurrentUser();
        System.assertEquals(0, result.size());
    }
}