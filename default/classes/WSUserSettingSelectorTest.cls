@isTest
private class WSUserSettingSelectorTest {
    @isTest
    static void selectByIdTest() {
        // Given
        Id userId = UserInfo.getUserId();
        Account acct = new Account(Name = 'Account 1');
        insert acct;
        Account_Plan__c ap = TestDataFactory.createAccountPlan('planA', acct);
        White_Space__c ws = TestDataFactory.createWhiteSpace(ap, 'WS Name');

        WS_User_Setting__c setting = new WS_User_Setting__c(User__c = userId, White_Space__c = ws.Id);
        insert setting;

        // When
        List<WS_User_Setting__c> wsUserSettings = new WSUserSettingSelector().selectById(new Set<Id>{ setting.Id });

        System.assertEquals(setting.Id, wsUserSettings[0].Id);
    }

    @isTest
    static void selectByWhitespaceIdTest() {
        // Given
        Id userId = UserInfo.getUserId();
        Account acct = new Account(Name = 'Account 1');
        insert acct;
        Account_Plan__c ap = TestDataFactory.createAccountPlan('planA', acct);
        White_Space__c ws = TestDataFactory.createWhiteSpace(ap, 'WS Name');

        WS_User_Setting__c setting = new WS_User_Setting__c(User__c = userId, White_Space__c = ws.Id);
        insert setting;

        // When
        List<WS_User_Setting__c> wsUserSettings = new WSUserSettingSelector().selectByWhitespaceId(ws.Id);

        System.assertEquals(setting.Id, wsUserSettings[0].Id);
    }
}