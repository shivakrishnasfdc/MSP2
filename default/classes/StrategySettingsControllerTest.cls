@isTest
private class StrategySettingsControllerTest {
    @isTest
    static void getOrgSettingsTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SettingServiceImpl mockService = (SettingServiceImpl) mocks.mock(SettingServiceImpl.class);

        Application.Service.setMock(SettingServiceImpl.class, mockService);

        // Given
        CRUSH_Settings_Obj__c mockOrgSettings = new CRUSH_Settings_Obj__c(Type__c = 'Org');
        mocks.startStubbing();
        mocks.when(mockService.getOrgSettingsAndCreateIfNeeded()).thenReturn(mockOrgSettings);
        mocks.stopStubbing();

        // When
        CrushSettings orgSettings = StrategySettingsController.getOrgSettings();

        // Then
        ((SettingServiceImpl) mocks.verify(mockService, 1)).getOrgSettingsAndCreateIfNeeded();
        System.assertEquals(mockOrgSettings.Type__c, orgSettings.type);
    }

    @isTest
    static void updateAccountPlansSharingShouldCallService() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AccountPlanShareServiceImpl mockService = (AccountPlanShareServiceImpl) mocks.mock(
            AccountPlanShareServiceImpl.class
        );
        Application.Service.setMock(AccountPlanShareServiceImpl.class, mockService);

        StrategySettingsController.updateAccountPlansSharing();

        ((AccountPlanShareServiceImpl) mocks.verify(mockService, 1)).updateAllAccountTeamShares();
        system.assert(true);
    }

    @isTest
    static void getCurrentUserSettingsTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SettingServiceImpl mockService = (SettingServiceImpl) mocks.mock(SettingServiceImpl.class);

        Application.Service.setMock(SettingServiceImpl.class, mockService);

        // Given
        CRUSH_Settings_Obj__c mockUserSettings = new CRUSH_Settings_Obj__c(
            Type__c = 'User',
            User__c = UserInfo.getUserId()
        );
        mocks.startStubbing();
        mocks.when(mockService.getCurrentUserSettings()).thenReturn(mockUserSettings);
        mocks.stopStubbing();

        // When
        CrushSettings userSettings = StrategySettingsController.getCurrentUserSettings();

        // Then
        ((SettingServiceImpl) mocks.verify(mockService, 1)).getCurrentUserSettings();
        System.assertEquals(mockUserSettings.User__c, userSettings.user);
        System.assertEquals(mockUserSettings.Type__c, userSettings.type);
    }

    @isTest
    static void upsertSettingsUpdateTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);

        Application.UnitOfWork.setMock(mockUow);

        // Given
        CRUSH_Settings_Obj__c testOrgSettings = new CRUSH_Settings_Obj__c(Type__c = 'Org');
        insert testOrgSettings;
        testOrgSettings.Type__c = 'User';

        CrushSettings crushSettingsObj = new CrushSettings(testOrgSettings);
        CRUSH_Settings_Obj__c mockOrgSettingsObject = crushSettingsObj.toSObject();

        // When
        Test.startTest();
        CrushSettings results = StrategySettingsController.upsertSettings(JSON.serialize(crushSettingsObj));
        Test.stopTest();

        // Then
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerDirty(mockOrgSettingsObject);
        System.assertEquals('User', results.type);
        System.assertEquals(testOrgSettings.id, results.id);
    }

    @isTest
    static void upsertSettingsInsertTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);

        Application.UnitOfWork.setMock(mockUow);

        // Given
        CRUSH_Settings_Obj__c testOrgSettings = new CRUSH_Settings_Obj__c(Type__c = 'Org');
        insert testOrgSettings;
        testOrgSettings.Type__c = 'User';
        testOrgSettings.Id = null;

        CrushSettings crushSettingsObj = new CrushSettings(testOrgSettings);
        CRUSH_Settings_Obj__c mockOrgSettingsObject = crushSettingsObj.toSObject();

        // When
        Test.startTest();
        CrushSettings results = StrategySettingsController.upsertSettings(JSON.serialize(crushSettingsObj));
        Test.stopTest();

        // Then
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerNew(mockOrgSettingsObject);
        System.assertEquals('User', results.type);
        System.assertEquals(testOrgSettings.id, results.id);
    }

    @isTest
    static void saveObjectsRelatedToAccountTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockService = md.mockSettingService;

        // Given
        CRUSH_Settings_Obj__c mockOrgSettings = new CRUSH_Settings_Obj__c(Type__c = 'Org');
        md.mocks.startStubbing();
        md.mocks.when(mockService.getOrgSettingsAndCreateIfNeeded()).thenReturn(mockOrgSettings);
        md.mocks.stopStubbing();

        Map<String, Boolean> input = new Map<String, Boolean>();
        input.put('abc', false);
        input.put('def', true);
        input.put('ghi', false);
        input.put('jkl', true);

        String inputString = 'def,jkl';

        StrategySettingsController.saveObjectsRelatedToAccount(input);
        mockOrgSettings.Task_Objects_Related_To_Account__c = inputString;

        ((SettingServiceImpl) md.mocks.verify(mockService, 1)).upsertSettings(mockOrgSettings);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    static void saveObjectsRelatedToAccountPlanTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockService = md.mockSettingService;

        // Given
        CRUSH_Settings_Obj__c mockOrgSettings = new CRUSH_Settings_Obj__c(Type__c = 'Org');
        md.mocks.startStubbing();
        md.mocks.when(mockService.getOrgSettingsAndCreateIfNeeded()).thenReturn(mockOrgSettings);
        md.mocks.stopStubbing();

        Map<String, Boolean> input = new Map<String, Boolean>();
        input.put('abc', false);
        input.put('def', true);
        input.put('ghi', false);
        input.put('jkl', true);

        String inputString = 'def,jkl';

        StrategySettingsController.saveObjectsRelatedToAccount(input);
        mockOrgSettings.Task_Objects_Related_To_Account_Plan__c = inputString;

        ((SettingServiceImpl) md.mocks.verify(mockService, 1)).upsertSettings(mockOrgSettings);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    static void getObjectsRelatedToAccountTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockService = md.mockSettingService;
        SObjectServiceImpl mockSObjectService = md.mockSObjectService;

        // Given
        CRUSH_Settings_Obj__c mockOrgSettings = new CRUSH_Settings_Obj__c(
            Type__c = 'Org',
            Task_Objects_Related_Exclusions__c = 'Opportunity',
            Task_Objects_Related_To_Account__c = 'Opportunity,Contact'
        );
        md.mocks.startStubbing();
        md.mocks.when(mockService.getOrgSettingsAndCreateIfNeeded()).thenReturn(mockOrgSettings);
        md.mocks.when(mockSObjectService.getObjectsRelatedTo(Schema.Account.SObjectType))
            .thenReturn(
                new Set<Schema.SObjectType>{
                    Contact.getSObjectType(),
                    Opportunity.getSObjectType(),
                    User.getSObjectType()
                }
            );
        md.mocks.stopStubbing();

        Map<String, Boolean> result = StrategySettingsController.getObjectsRelatedToAccount();

        System.assertEquals(true, result.get('Contact'));
        System.assertEquals(false, result.get('User'));
        System.assertEquals(null, result.get('Opportunity'));
    }

    @isTest
    static void getObjectsRelatedToAccountNullTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockService = md.mockSettingService;
        SObjectServiceImpl mockSObjectService = md.mockSObjectService;

        // Given
        CRUSH_Settings_Obj__c mockOrgSettings = new CRUSH_Settings_Obj__c(
            Type__c = 'Org',
            Task_Objects_Related_Exclusions__c = null,
            Task_Objects_Related_To_Account__c = null
        );
        md.mocks.startStubbing();
        md.mocks.when(mockService.getOrgSettingsAndCreateIfNeeded()).thenReturn(mockOrgSettings);
        md.mocks.when(mockSObjectService.getObjectsRelatedTo(Schema.Account.SObjectType))
            .thenReturn(
                new Set<Schema.SObjectType>{
                    Contact.getSObjectType(),
                    Opportunity.getSObjectType(),
                    User.getSObjectType()
                }
            );
        md.mocks.stopStubbing();

        Map<String, Boolean> result = StrategySettingsController.getObjectsRelatedToAccount();

        System.assertEquals(false, result.get('Contact'));
        System.assertEquals(false, result.get('User'));
        System.assertEquals(false, result.get('Opportunity'));
    }

    @isTest
    static void getObjectsRelatedToAccountPlanTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockService = md.mockSettingService;
        SObjectServiceImpl mockSObjectService = md.mockSObjectService;

        // Given
        CRUSH_Settings_Obj__c mockOrgSettings = new CRUSH_Settings_Obj__c(
            Type__c = 'Org',
            Task_Objects_Related_Exclusions__c = 'Opportunity',
            Task_Objects_Related_To_Account_Plan__c = 'Opportunity,Contact,Account'
        );
        md.mocks.startStubbing();
        md.mocks.when(mockService.getOrgSettingsAndCreateIfNeeded()).thenReturn(mockOrgSettings);
        md.mocks.when(mockSObjectService.getObjectsRelatedTo(Account_Plan__c.getSObjectType()))
            .thenReturn(
                new Set<Schema.SObjectType>{
                    Contact.getSObjectType(),
                    Opportunity.getSObjectType(),
                    User.getSObjectType()
                }
            );
        md.mocks.stopStubbing();

        Map<String, Boolean> result = StrategySettingsController.getObjectsRelatedToAccountPlan();

        System.assertEquals(true, result.get('Contact'));
        System.assertEquals(false, result.get('User'));
        System.assertEquals(null, result.get('Opportunity'));
        System.assertEquals(true, result.get('Account'));
    }

    @isTest
    static void getObjectsRelatedToAccountPlanNullTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockService = md.mockSettingService;
        SObjectServiceImpl mockSObjectService = md.mockSObjectService;

        // Given
        CRUSH_Settings_Obj__c mockOrgSettings = new CRUSH_Settings_Obj__c(
            Type__c = 'Org',
            Task_Objects_Related_Exclusions__c = null,
            Task_Objects_Related_To_Account_Plan__c = null
        );
        md.mocks.startStubbing();
        md.mocks.when(mockService.getOrgSettingsAndCreateIfNeeded()).thenReturn(mockOrgSettings);
        md.mocks.when(mockSObjectService.getObjectsRelatedTo(Account_Plan__c.getSObjectType()))
            .thenReturn(
                new Set<Schema.SObjectType>{
                    Contact.getSObjectType(),
                    Opportunity.getSObjectType(),
                    User.getSObjectType()
                }
            );
        md.mocks.stopStubbing();

        Map<String, Boolean> result = StrategySettingsController.getObjectsRelatedToAccountPlan();

        System.assertEquals(false, result.get('Contact'));
        System.assertEquals(false, result.get('User'));
        System.assertEquals(false, result.get('Opportunity'));
        System.assertEquals(false, result.get('Account'));
    }

    @isTest
    static void updateCrossSellCreateObjectSettingsTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockService = md.mockSettingService;

        Boolean input = true;

        // When
        StrategySettingsController.updateCrossSellCreateObjectSettings(input);

        // Then
        ((SettingServiceImpl) md.mocks.verify(mockService, 1)).updateCrossSellCreateObjectSettings(input);
        System.assert(true, 'Assert verified by mock');
    }

    @isTest
    static void updateUseDefaultAPScoringSettingsTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockService = md.mockSettingService;

        Boolean input = true;

        // When
        StrategySettingsController.updateUseDefaultAPScoringSettings(input);

        // Then
        ((SettingServiceImpl) md.mocks.verify(mockService, 1)).updateUseDefaultAPScoringSettings(input);
        System.assert(true, 'Assert verified by mock');
    }

    @isTest
    static void updateUsePercentageAPScoringSettingsTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockService = md.mockSettingService;

        Boolean input = true;

        // When
        StrategySettingsController.updateUsePercentageAPScoringSettings(input);

        // Then
        ((SettingServiceImpl) md.mocks.verify(mockService, 1)).updateUsePercentageAPScoringSettings(input);
        System.assert(true, 'Assert verified by mock');
    }

    @isTest
    static void updateAllowAddTaskFromObjectiveComponentTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockService = md.mockSettingService;

        Boolean input = true;

        // When
        StrategySettingsController.updateAllowAddTaskFromObjectiveComponent(input);

        // Then
        ((SettingServiceImpl) md.mocks.verify(mockService, 1)).updateAllowAddTaskFromObjectiveComponent(input);
        System.assert(true, 'Assert verified by mock');
    }

    @isTest
    static void updateAllowTasksBasedObjStageFromObjectiveComponentTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockService = md.mockSettingService;

        Boolean input = true;

        // When
        StrategySettingsController.updateAllowTasksBasedObjStageFromObjectiveComponent(input);

        // Then
        ((SettingServiceImpl) md.mocks.verify(mockService, 1))
            .updateAllowTasksBasedObjStageFromObjectiveComponent(input);
        System.assert(true, 'Assert verified by mock');
    }

    @isTest
    static void updateUseSystemTaskModalFromObjectiveComponentTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockService = md.mockSettingService;

        Boolean input = true;

        // When
        StrategySettingsController.updateUseSystemTaskModalFromObjectiveComponent(input);

        // Then
        ((SettingServiceImpl) md.mocks.verify(mockService, 1)).updateUseSystemTaskModalFromObjectiveComponent(input);
        System.assert(true, 'Assert verified by mock');
    }

    @isTest
    static void updateWSFilterStringSettingEmptyListTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockService = md.mockSettingService;

        String input = 'test';

        md.mocks.startStubbing();
        md.mocks.when(mockService.getObjectNameListFromFilterString(input)).thenReturn(new List<String>());
        md.mocks.when(mockService.getFilterStringFromObjectNameList(new List<String>())).thenReturn('expected');
        md.mocks.stopStubbing();

        // When
        StrategySettingsController.updateWSFilterStringSetting(input);

        // Then
        ((SettingServiceImpl) md.mocks.verify(mockService, 1)).updateWSFilterStringSetting('expected');
        System.assert(true, 'Assert verified by mock');
    }

    @isTest
    static void updateWSFilterStringSettingBadValueTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockService = md.mockSettingService;

        String input = 'test';
        String badObjectName = 'uwsfssbvd_test_fake_object';

        md.mocks.startStubbing();
        md.mocks.when(mockService.getObjectNameListFromFilterString(input))
            .thenReturn(new List<String>{ 'Account', 'Contact', badObjectName });
        md.mocks.stopStubbing();

        // When
        try {
            StrategySettingsController.updateWSFilterStringSetting(input);
            System.assert(false, 'Should have thrown an exception');
        } catch (Exception e) {
            String expectedError = String.format(System.label.Invalid_Object_Name, new List<String>{ badObjectName });
            System.assertEquals(expectedError, e.getMessage(), 'Should have thrown the expected exception');
        }
    }

    @isTest
    static void updateWSFilterStringSettingHappyPathTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockService = md.mockSettingService;

        String input = 'test';

        md.mocks.startStubbing();
        md.mocks.when(mockService.getObjectNameListFromFilterString(input)).thenReturn(new List<String>{ 'Account' });
        md.mocks.when(mockService.getFilterStringFromObjectNameList(new List<String>{ 'Account' }))
            .thenReturn('expected');
        md.mocks.stopStubbing();

        // When
        StrategySettingsController.updateWSFilterStringSetting(input);

        // Then
        ((SettingServiceImpl) md.mocks.verify(mockService, 1)).updateWSFilterStringSetting('expected');
        System.assert(true, 'Assert verified by mock');
    }
}