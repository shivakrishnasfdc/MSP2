@isTest
private class AccountPlanUserSettingControllerTest {
    // TEST WHEN SELECTOR RETURNS SOMETHING
    @isTest
    static void getSettingsTest() {
        testMockData md = new testMockData();
        AccountPlanUserSettingSelector mockAccountPlanUserSettingSelector = md.mockAccountPlanUserSettingSelector;

        pq_CRUSH_Account_Plan_User_Setting__c setting = new pq_CRUSH_Account_Plan_User_Setting__c(
            Account_Plan__c = md.mockAccountPlanId,
            Objective_Overview_Chart_Type__c = 'Bar',
            User__c = UserInfo.getUserId()
        );

        md.mocks.startStubbing();
        md.mocks.when(
                mockAccountPlanUserSettingSelector.selectByAccountPlans(
                    new Set<Id>{ md.mockAccountPlanId },
                    UserInfo.getUserId()
                )
            )
            .thenReturn(new List<pq_CRUSH_Account_Plan_User_Setting__c>{ setting });
        md.mocks.stopStubbing();

        pq_CRUSH_Account_Plan_User_Setting__c result = AccountPlanUserSettingController.getSettings(
            md.mockAccountPlanId
        );

        System.assertEquals(setting.Account_Plan__c, result.Account_Plan__c);
        System.assertEquals(UserInfo.getUserId(), result.User__c);
    }

    // TEST WHEN SELECTOR RETURNS NOTHING
    @isTest
    static void getSettingsTest2() {
        testMockData md = new testMockData();
        AccountPlanUserSettingSelector mockAccountPlanUserSettingSelector = md.mockAccountPlanUserSettingSelector;
        AccountPlanUserSettingServiceImpl mockAccountPlanUserSettingService = md.mockAccountPlanUserSettingService;

        md.mocks.startStubbing();
        md.mocks.when(
                mockAccountPlanUserSettingSelector.selectByAccountPlans(
                    new Set<Id>{ md.mockAccountPlanId },
                    UserInfo.getUserId()
                )
            )
            .thenReturn(new List<pq_CRUSH_Account_Plan_User_Setting__c>());
        md.mocks.stopStubbing();

        AccountPlanUserSettingController.getSettings(md.mockAccountPlanId);

        ((AccountPlanUserSettingServiceImpl) md.mocks.verify(mockAccountPlanUserSettingService, 1))
            .createNewSettings(md.mockAccountPlanId);

        System.assert(true, 'verify by mocks');
    }

    // TEST WHEN INPUT IS VALID
    @isTest
    static void updateSettings() {
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        AccountPlanUserSettingSelector mockAccountPlanUserSettingSelector = md.mockAccountPlanUserSettingSelector;

        Id settingId = fflib_IDGenerator.generate(pq_CRUSH_Account_Plan_User_Setting__c.SObjectType);

        pq_CRUSH_Account_Plan_User_Setting__c oldSetting = new pq_CRUSH_Account_Plan_User_Setting__c(
            Id = settingId,
            Account_Plan__c = md.mockAccountPlanId,
            Objective_Overview_Chart_Type__c = 'Bar',
            User__c = UserInfo.getUserId()
        );

        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanUserSettingSelector.selectById(new Set<Id>{ settingId }))
            .thenReturn(new List<pq_CRUSH_Account_Plan_User_Setting__c>{ oldSetting });
        md.mocks.stopStubbing();

        AccountPlanUserSettingController.updateSettings(settingId, 'Pie');

        oldSetting.Objective_Overview_Chart_Type__c = 'Pie';

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerDirty(new List<pq_CRUSH_Account_Plan_User_Setting__c>{ oldSetting });
        System.assert(true, 'verify by mocks');
    }

    // TEST WHEN INPUT IS INVALID
    @isTest
    static void updateSettings2() {
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        AccountPlanUserSettingSelector mockAccountPlanUserSettingSelector = md.mockAccountPlanUserSettingSelector;

        Id settingId = fflib_IDGenerator.generate(pq_CRUSH_Account_Plan_User_Setting__c.SObjectType);

        pq_CRUSH_Account_Plan_User_Setting__c oldSetting = new pq_CRUSH_Account_Plan_User_Setting__c(
            Id = settingId,
            Account_Plan__c = md.mockAccountPlanId,
            Objective_Overview_Chart_Type__c = 'Bar',
            User__c = UserInfo.getUserId()
        );

        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanUserSettingSelector.selectById(new Set<Id>{ md.mockAccountPlanId }))
            .thenReturn(new List<pq_CRUSH_Account_Plan_User_Setting__c>{ oldSetting });
        md.mocks.stopStubbing();

        AccountPlanUserSettingController.updateSettings(settingId, 'YYZZZ');

        oldSetting.Objective_Overview_Chart_Type__c = 'Pie';

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0)).registerDirty(oldSetting);
        System.assert(true, 'verify by mocks');
    }
}