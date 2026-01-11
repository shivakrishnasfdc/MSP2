@isTest
private class MasterAccountPlanControllerTest {
    @isTest
    static void getAccountPlansByMasterAccountPlanTest() {
        TestMockData md = new TestMockData();
        MasterAccountPlanServiceImpl mockMasterAccountPlanService = md.mockMasterAccountPlanService;

        md.mocks.startStubbing();
        md.mocks.when(mockMasterAccountPlanService.getAccountPlansByMasterAccountPlan(md.mockMasterAccountPlanId))
            .thenReturn(new List<Account_Plan__c>());
        md.mocks.stopStubbing();

        MasterAccountPlanController.getAccountPlansByMasterAccountPlan(md.mockMasterAccountPlanId);

        ((MasterAccountPlanServiceImpl) md.mocks.verify(mockMasterAccountPlanService, 1))
            .getAccountPlansByMasterAccountPlan(md.mockMasterAccountPlanId);

        System.assert(true, 'Assert verified by mocks');
    }

    @isTest
    static void getRelationshipMapsByMasterAccountPlanTest() {
        TestMockData md = new TestMockData();
        MasterAccountPlanServiceImpl mockMasterAccountPlanService = md.mockMasterAccountPlanService;
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;
        RelationshipMapSelector mockRelationshipMapSelector = md.mockRelationshipMapSelector;

        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        mapAccounts.put(md.mockAccountId, md.mockAccount);

        Schema.SObjectType objType = SObjectService.getSObjectType('Account');

        md.mocks.startStubbing();
        md.mocks.when(mockMasterAccountPlanService.getAccountPlansByMasterAccountPlan(md.mockMasterAccountPlanId))
            .thenReturn(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mocks.when(mockRelationshipMapService.getMapsForObjectFromObject(objType, new Set<Id>{ md.mockAccountId }))
            .thenReturn(new Set<Id>());
        md.mocks.when(mockRelationshipMapService.getMapsForObjectFromRM(objType, new Set<Id>{ md.mockAccountId }))
            .thenReturn(new Set<Id>{ md.mockRelationshipMapId });
        md.mocks.when(mockRelationshipMapSelector.selectByAccountPlanIds(new Set<Id>{ md.mockAccountPlanId }))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.when(mockRelationshipMapSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.stopStubbing();

        MasterAccountPlanController.getRelationshipMapsByMasterAccountPlan(md.mockMasterAccountPlanId);

        ((MasterAccountPlanServiceImpl) md.mocks.verify(mockMasterAccountPlanService, 1))
            .getAccountPlansByMasterAccountPlan(md.mockMasterAccountPlanId);
        ((RelationshipMapServiceImpl) md.mocks.verify(mockRelationshipMapService, 1))
            .getMapsForObjectFromObject(objType, new Set<Id>{ md.mockAccountId });
        ((RelationshipMapServiceImpl) md.mocks.verify(mockRelationshipMapService, 1))
            .getMapsForObjectFromRM(objType, new Set<Id>{ md.mockAccountId });
        ((RelationshipMapSelector) md.mocks.verify(mockRelationshipMapSelector, 1))
            .selectByAccountPlanIds(new Set<Id>{ md.mockAccountPlanId });
        ((RelationshipMapSelector) md.mocks.verify(mockRelationshipMapSelector, 1))
            .selectByIds(new Set<Id>{ md.mockRelationshipMapId });
        System.assert(true, 'Assert verified by mocks');
    }

    @isTest
    static void getRelationshipMapsByMasterAccountPlanTest2() {
        TestMockData md = new TestMockData();
        MasterAccountPlanServiceImpl mockMasterAccountPlanService = md.mockMasterAccountPlanService;
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;
        RelationshipMapSelector mockRelationshipMapSelector = md.mockRelationshipMapSelector;

        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        mapAccounts.put(md.mockAccountId, md.mockAccount);

        Schema.SObjectType objType = SObjectService.getSObjectType('Account');

        md.mocks.startStubbing();
        md.mocks.when(mockMasterAccountPlanService.getAccountPlansByMasterAccountPlan(md.mockMasterAccountPlanId))
            .thenReturn(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mocks.when(mockRelationshipMapService.getMapsForObjectFromObject(objType, new Set<Id>{ md.mockAccountId }))
            .thenReturn(new Set<Id>{ md.mockRelationshipMapId });
        md.mocks.when(mockRelationshipMapSelector.selectByAccountPlanIds(new Set<Id>{ md.mockAccountPlanId }))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.when(mockRelationshipMapSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.stopStubbing();

        MasterAccountPlanController.getRelationshipMapsByMasterAccountPlan(md.mockMasterAccountPlanId);

        ((MasterAccountPlanServiceImpl) md.mocks.verify(mockMasterAccountPlanService, 1))
            .getAccountPlansByMasterAccountPlan(md.mockMasterAccountPlanId);
        ((RelationshipMapServiceImpl) md.mocks.verify(mockRelationshipMapService, 1))
            .getMapsForObjectFromObject(objType, new Set<Id>{ md.mockAccountId });
        ((RelationshipMapSelector) md.mocks.verify(mockRelationshipMapSelector, 1))
            .selectByAccountPlanIds(new Set<Id>{ md.mockAccountPlanId });
        ((RelationshipMapSelector) md.mocks.verify(mockRelationshipMapSelector, 1))
            .selectByIds(new Set<Id>{ md.mockRelationshipMapId });
        System.assert(true, 'Assert verified by mocks');
    }

    @isTest
    static void getScoreHistoryByMasterAccountPlanTest() {
        TestMockData md = new TestMockData();
        MasterAccountPlanServiceImpl mockMasterAccountPlanService = md.mockMasterAccountPlanService;
        AccountPlanScoreHistorySelector mockAccountPlanScoreHistorySelector = md.mockAccountPlanScoreHistorySelector;

        DateTime todaysDate = DateTime.now();
        DateTime startDate = todaysDate.addMonths(-3);
        fflib_MatcherDefinitions.DatetimeBetween matchBetween = new fflib_MatcherDefinitions.DatetimeBetween(
            startDate.addDays(-1),
            false,
            startDate.addDays(1),
            false
        );
        Set<Id> planIds = new Set<Id>{ md.mockAccountPlanId };

        md.mocks.startStubbing();
        md.mocks.when(mockMasterAccountPlanService.getAccountPlansByMasterAccountPlan(md.mockMasterAccountPlanId))
            .thenReturn(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mocks.when(
                mockAccountPlanScoreHistorySelector.selectByAccountPlansAfterDate(
                    (Set<Id>) fflib_Match.eq(planIds),
                    (DateTime) fflib_Match.matches(matchBetween)
                )
            )
            .thenReturn(new List<pq_Account_Plan_Score_History__c>());
        md.mocks.stopStubbing();

        MasterAccountPlanController.getScoreHistoryByMasterAccountPlan(md.mockMasterAccountPlanId);

        ((AccountPlanScoreHistorySelector) md.mocks.verify(mockAccountPlanScoreHistorySelector, 1))
            .selectByAccountPlansAfterDate(
                (Set<Id>) fflib_Match.eq(planIds),
                (DateTime) fflib_Match.matches(matchBetween)
            );
        System.assert(true, 'Assert verified by mocks');
    }

    @isTest
    static void getSortOrderValuesTest() {
        List<String> actualValues = new List<String>(MasterAccountPlanController.getSortOrderValues());
        System.assert(actualValues.contains('Created: Newest to Oldest,CreatedDate DESC'), 'Result should contain default sort order');
        System.assert(actualValues.size() >= 4, 'Result should contain all available selection');
    }

    @isTest
    static void getRmSortOrderNoUserSettingsTest() {
        String expectedSortOrder = 'CreatedDate DESC';
        String actualSortOrder = MasterAccountPlanController.getRmSortOrder();
        System.assertEquals(expectedSortOrder, actualSortOrder, 'Result should contain the default sort order');
    }

    @isTest
    static void getRmSortOrderWithUserSettingsTest() {
        pq_Crush_User_Setting__c userSetting = new pq_Crush_User_Setting__c();
        Id userId = UserInfo.getUserId();
        userSetting.Account_Plan_Sort__c = 'Name ASC';
        userSetting.User__c = userId;
        insert userSetting;
        String actualSortOrder = MasterAccountPlanController.getRmSortOrder();
        System.assertEquals('Name ASC', actualSortOrder, 'Result should contain the specified sort order');
    }

    @isTest
    static void updateAccountPlanSortBlankTest() {
        pq_Crush_User_Setting__c userSetting = new pq_Crush_User_Setting__c();
        Id userId = UserInfo.getUserId();
        userSetting.Account_Plan_Sort__c = 'Name ASC';
        userSetting.User__c = userId;
        insert userSetting;

        MasterAccountPlanController.updateAccountPlanSort('');
        List<pq_Crush_User_Setting__c> settings = CrushUserSettingSelector.newInstance().selectForCurrentUser();
        pq_Crush_User_Setting__c setting = settings[0];
        System.assertEquals('Name ASC', setting.pqcrush__Account_Plan_Sort__c, 'Result should be unchanged');
    }

    @isTest
    static void updateAccountPlanSortNullTest() {
        pq_Crush_User_Setting__c userSetting = new pq_Crush_User_Setting__c();
        Id userId = UserInfo.getUserId();
        userSetting.Account_Plan_Sort__c = 'Name ASC';
        userSetting.User__c = userId;
        insert userSetting;

        MasterAccountPlanController.updateAccountPlanSort(null);
        List<pq_Crush_User_Setting__c> settings = CrushUserSettingSelector.newInstance().selectForCurrentUser();
        pq_Crush_User_Setting__c setting = settings[0];
        System.assertEquals('Name ASC', setting.pqcrush__Account_Plan_Sort__c, 'Result should be unchanged');
    }

    @isTest
    static void updateAccountPlanSortValidTest() {
        pq_Crush_User_Setting__c userSetting = new pq_Crush_User_Setting__c();
        Id userId = UserInfo.getUserId();
        userSetting.Account_Plan_Sort__c = 'Name ASC';
        userSetting.User__c = userId;
        insert userSetting;

        MasterAccountPlanController.updateAccountPlanSort('CreatedDate DESC');
        List<pq_Crush_User_Setting__c> settings = CrushUserSettingSelector.newInstance().selectForCurrentUser();
        pq_Crush_User_Setting__c setting = settings[0];
        System.assertEquals('CreatedDate DESC', setting.pqcrush__Account_Plan_Sort__c, 'Result should contain the specified sort order');
    }

    @isTest
    static void updateAccountPlanSortValidNoUserSettingsTest() {
        MasterAccountPlanController.updateAccountPlanSort('CreatedDate DESC');
        List<pq_Crush_User_Setting__c> settings = CrushUserSettingSelector.newInstance().selectForCurrentUser();
        pq_Crush_User_Setting__c setting = settings[0];
        System.assertEquals('CreatedDate DESC', setting.pqcrush__Account_Plan_Sort__c, 'Result should contain the specified sort order');
    }

    @isTest
    static void getClosedPlanFilterNoUserSettingsTest() {
        TestMockData md = new TestMockData();

        Id masterAccountPlanId = md.mockMasterAccountPlanId;

        Boolean expectedFilterValue = true;
        Boolean actualFilterValue = MasterAccountPlanController.getClosedPlanFilter(masterAccountPlanId);
        System.assertEquals(expectedFilterValue, actualFilterValue, 'Result should contain the default sort order');
    }

    @isTest
    static void getClosedPlanFilterWithUserSettingsTest() {
        Account mockAccount = new Account(Name= 'Mock Account', OwnerId = UserInfo.getUserId());
        insert mockAccount;

        pq_Master_Account_Plan__c mockMasterAp = new pq_Master_Account_Plan__c();
        mockMasterAp.Name = 'Fake master account name';
        mockMasterAp.OwnerId = UserInfo.getUserId();
        mockMasterAp.Account__c = mockAccount.Id;
        insert mockMasterAp;

        Master_Account_Plan_User_Setting__c mockMasterApUserSettings = new Master_Account_Plan_User_Setting__c();
        mockMasterApUserSettings.Show_Closed_Account_Plans__c = false;
        mockMasterApUserSettings.User__c = UserInfo.getUserId();
        mockMasterApUserSettings.Master_Account_Plan__c = mockMasterAp.Id;
        insert mockMasterApUserSettings;

        Boolean expectedFilterValue = false;
        Boolean actualFilterValue = MasterAccountPlanController.getClosedPlanFilter(mockMasterAp.Id);
        System.assertEquals(expectedFilterValue, actualFilterValue, 'Result should contain the default sort order');
    }

}