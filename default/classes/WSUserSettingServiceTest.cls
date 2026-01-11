@isTest
private class WSUserSettingServiceTest {
    @isTest
    static void getUserSettingTest() {
        // mocks
        TestMockData md = new TestMockData();
        WSUserSettingSelector mockWSUserSettingSelector = md.mockWSUserSettingSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockWSUserSettingSelector.selectByWhitespaceId(md.mockWhiteSpaceId))
            .thenReturn(new List<WS_User_Setting__c>{ md.mockWSUserSetting });
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        WS_User_Setting__c setting = WSUserSettingService.getUserSetting(md.mockWhiteSpaceId);
        Test.stopTest();

        System.assert(setting != null);
    }

    @isTest
    static void getUserSettingTest2() {
        // mocks
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUoW = md.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test
        WSUserSettingSelector mockWSUserSettingSelector = md.mockWSUserSettingSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockWSUserSettingSelector.selectByWhitespaceId(md.mockWhiteSpaceId)).thenReturn(null);
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        WS_User_Setting__c setting = WSUserSettingService.getUserSetting(md.mockWhiteSpaceId);
        Test.stopTest();

        System.assertNotEquals(setting, null);
        System.assertEquals(md.mockWhiteSpaceId, setting.White_Space__c);
        System.assertEquals(UserInfo.getUserId(), setting.User__c);
        System.assertEquals(null, setting.Id);
    }

    @isTest
    static void updateUserSettingTest() {
        // mocks
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUoW = md.mockUow;

        // When
        Test.startTest();
        WSUserSettingService.updateUserSetting(new List<WS_User_Setting__c>{ md.mockWSUserSetting });
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(md.mockWSUserSetting);
        System.assert(true, 'Assert by verifing mock data');
    }

    @isTest
    static void updateUserSettingTest2() {
        // mocks
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUoW = md.mockUow;
        WS_User_Setting__c mockWSUserSetting = md.mockWSUserSetting;
        mockWSUserSetting.Id = null;

        // When
        Test.startTest();
        WSUserSettingService.updateUserSetting(new List<WS_User_Setting__c>{ md.mockWSUserSetting });
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew(md.mockWSUserSetting);
        System.assert(true, 'Assert by verifing mock data');
    }

    @isTest
    static void updateZoomIndexTest() {
        // mocks
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUoW = md.mockUow;
        WSUserSettingSelector mockWSUserSettingSelector = md.mockWSUserSettingSelector;

        Integer zoomIndex = 5;

        md.mocks.startStubbing();
        md.mocks.when(mockWSUserSettingSelector.selectById(new Set<Id>{ md.mockWSUserSettingId }))
            .thenReturn(new List<WS_User_Setting__c>{ md.mockWSUserSetting });
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        WSUserSettingService.updateZoomIndex(md.mockWSUserSettingId, zoomIndex);
        Test.stopTest();

        md.mockWSUserSetting.Zoom_Index__c = zoomIndex;

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(md.mockWSUserSetting);
        System.assert(true, 'Assert by verifing mock data');
    }
}