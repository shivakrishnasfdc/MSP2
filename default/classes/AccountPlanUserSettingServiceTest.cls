@isTest
private class AccountPlanUserSettingServiceTest {
    @isTest
    static void createNewSettingsTest() {
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        pq_CRUSH_Account_Plan_User_Setting__c newSetting = new pq_CRUSH_Account_Plan_User_Setting__c(
            Account_Plan__c = md.mockAccountPlanId,
            Objective_Overview_Chart_Type__c = 'Bar',
            User__c = UserInfo.getUserId()
        );

        AccountPlanUserSettingService.createNewSettings(md.mockAccountPlanId);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew(newSetting);
        System.assert(true, 'Assert by mock verify');
    }
}