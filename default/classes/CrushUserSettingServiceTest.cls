@isTest
private class CrushUserSettingServiceTest {
    @isTest
    static void getSettingTest1() {
        TestMockData md = new TestMockData();
        CrushUserSettingSelector mockCrushUserSettingSelector = md.mockCrushUserSettingSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockCrushUserSettingSelector.selectForCurrentUser())
            .thenReturn(new List<pq_Crush_User_Setting__c>());
        md.mocks.stopStubbing();

        pq_Crush_User_Setting__c result = CrushUserSettingService.getSetting();
        System.assertNotEquals(null, result);
    }

    @isTest
    static void getSettingTest2() {
        TestMockData md = new TestMockData();
        CrushUserSettingSelector mockCrushUserSettingSelector = md.mockCrushUserSettingSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockCrushUserSettingSelector.selectForCurrentUser())
            .thenReturn(
                new List<pq_Crush_User_Setting__c>{ new pq_Crush_User_Setting__c(User__c = UserInfo.getUserId()) }
            );
        md.mocks.stopStubbing();

        pq_Crush_User_Setting__c result = CrushUserSettingService.getSetting();
        System.assertNotEquals(null, result);
    }

    // Testing updating where setting doesn't exists
    @isTest
    static void updateTaskFilterTest1() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        CrushUserSettingSelector mockCrushUserSettingSelector = md.mockCrushUserSettingSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockCrushUserSettingSelector.selectForCurrentUser())
            .thenReturn(new List<pq_Crush_User_Setting__c>());
        md.mocks.stopStubbing();

        String input = 'abc';

        CrushUserSettingService.updateTaskFilter(input);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew(
                new pq_Crush_User_Setting__c(Account_Plan_Task_Filter__c = input, User__c = UserInfo.getUserId())
            );
        System.assert(true, 'Assert from mock verify');
    }

    // Testing updating where setting already exists
    @isTest
    static void updateTaskFilterTest2() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        CrushUserSettingSelector mockCrushUserSettingSelector = md.mockCrushUserSettingSelector;

        pq_Crush_User_Setting__c setting1 = new pq_Crush_User_Setting__c(
            Account_Plan_Task_Filter__c = 'abc1',
            User__c = UserInfo.getUserId()
        );
        pq_Crush_User_Setting__c setting2 = new pq_Crush_User_Setting__c(
            Account_Plan_Task_Filter__c = 'abc2',
            User__c = UserInfo.getUserId()
        );
        pq_Crush_User_Setting__c setting3 = new pq_Crush_User_Setting__c(
            Account_Plan_Task_Filter__c = 'abc3',
            User__c = UserInfo.getUserId()
        );

        List<pq_Crush_User_Setting__c> settingsList = new List<pq_Crush_User_Setting__c>{
            setting1,
            setting2,
            setting3
        };

        md.mocks.startStubbing();
        md.mocks.when(mockCrushUserSettingSelector.selectForCurrentUser()).thenReturn(settingsList);
        md.mocks.stopStubbing();

        String input = 'abc';

        CrushUserSettingService.updateTaskFilter(input);

        setting1.Account_Plan_Task_Filter__c = input;
        List<pq_Crush_User_Setting__c> settingsToDelete = new List<pq_Crush_User_Setting__c>{ setting2, setting3 };

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(setting1);
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDeleted(settingsToDelete);
        System.assert(true, 'Assert from mock verify');
    }

    @isTest
    static void updateAccountPlanSortTest1() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        CrushUserSettingSelector mockCrushUserSettingSelector = md.mockCrushUserSettingSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockCrushUserSettingSelector.selectForCurrentUser())
            .thenReturn(new List<pq_Crush_User_Setting__c>());
        md.mocks.stopStubbing();

        String input = 'CreatedDate DESC';

        CrushUserSettingService.updateAccountPlanSort(input);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew(
                new pq_Crush_User_Setting__c(Account_Plan_Sort__c = input, User__c = UserInfo.getUserId())
            );
        System.assert(true, 'Assert from mock verify');
    }

    @isTest
    static void updateAccountPlanSortTest2() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        CrushUserSettingSelector mockCrushUserSettingSelector = md.mockCrushUserSettingSelector;

        pq_Crush_User_Setting__c setting1 = new pq_Crush_User_Setting__c(
            Account_Plan_Sort__c = 'CreatedDate DESC',
            User__c = UserInfo.getUserId()
        );
        pq_Crush_User_Setting__c setting2 = new pq_Crush_User_Setting__c(
            Account_Plan_Sort__c = 'CreatedDate ASC',
            User__c = UserInfo.getUserId()
        );
        pq_Crush_User_Setting__c setting3 = new pq_Crush_User_Setting__c(
            Account_Plan_Sort__c = 'Name ASC',
            User__c = UserInfo.getUserId()
        );

        List<pq_Crush_User_Setting__c> settingsList = new List<pq_Crush_User_Setting__c>{
            setting1,
            setting2,
            setting3
        };

        md.mocks.startStubbing();
        md.mocks.when(mockCrushUserSettingSelector.selectForCurrentUser()).thenReturn(settingsList);
        md.mocks.stopStubbing();

        String input = 'CreatedDate DESC';

        CrushUserSettingService.updateAccountPlanSort(input);

        setting1.Account_Plan_Task_Filter__c = input;
        List<pq_Crush_User_Setting__c> settingsToDelete = new List<pq_Crush_User_Setting__c>{ setting2, setting3 };

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(setting1);
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDeleted(settingsToDelete);
        System.assert(true, 'Assert from mock verify');
    }
}