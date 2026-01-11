@isTest
private class MasterAccountPlanServiceTest {
    @isTest
    static void getRelatedAccountIdsByMasterAccountPlansTest() {
        TestMockData md = new TestMockData();
        MasterAccountPlanAssociationSelector mockMasterAccountPlanAssociationSelector = md.mockMasterAccountPlanAssociationSelector;
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;

        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        mapAccounts.put(md.mockAccountId, md.mockAccount);
        Set<Id> testSet = new Set<Id>{ md.mockAccountPlanId };

        md.mocks.startStubbing();
        md.mocks.when(
                mockMasterAccountPlanAssociationSelector.selectByMasterAccountPlanId(
                    new Set<Id>{ md.mockMasterAccountPlanId }
                )
            )
            .thenReturn(new List<Master_Account_Plan_Associations__c>{ md.mockMasterAccountPlanAssociation });
        md.mocks.when(mockAccountPlanSelector.selectByIdWithAccountAndOwnerAndMasterAccountPlan(testSet, md.mockMasterAccountPlanId))
            .thenReturn(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mocks.stopStubbing();

        MasterAccountPlanService.getRelatedAccountIdsByMasterAccountPlans(new Set<Id>{ md.mockMasterAccountPlanId });

        ((MasterAccountPlanAssociationSelector) md.mocks.verify(mockMasterAccountPlanAssociationSelector, 1))
            .selectByMasterAccountPlanId(new Set<Id>{ md.mockMasterAccountPlanId });
        ((AccountPlanSelector) md.mocks.verify(mockAccountPlanSelector, 1))
            .selectByIdWithAccountAndOwnerAndMasterAccountPlan(testSet, md.mockMasterAccountPlanId);
        System.assert(true, 'Assert verified by mocks');
    }

    // No Master Plan Test
    @isTest
    static void getAccountPlansByMasterAccountPlanTest1() {
        TestMockData md = new TestMockData();
        MasterAccountPlanSelector mockMasterAccountPlanSelector = md.mockMasterAccountPlanSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockMasterAccountPlanSelector.selectById(new Set<Id>{ md.mockMasterAccountPlanId }))
            .thenReturn(new List<pq_Master_Account_Plan__c>{ md.mockMasterAccountPlan });
        md.mocks.stopStubbing();

        List<Account_Plan__c> result = MasterAccountPlanService.getAccountPlansByMasterAccountPlan(
            md.mockMasterAccountPlanId
        );
        System.assertEquals(0, result.size());
    }
    @isTest
    static void getAccountPlansByMasterAccountPlanTest() {
        TestMockData md = new TestMockData();
        MasterAccountPlanSelector mockMasterAccountPlanSelector = md.mockMasterAccountPlanSelector;
        MasterAccountPlanAssociationSelector mockMasterAccountPlanAssociationSelector = md.mockMasterAccountPlanAssociationSelector;
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;
        AccountServiceImpl mockAccountService = md.mockAccountService;
        Set<Id> testAccountPlanSet = new Set<Id>{ md.mockAccountPlanId };
        Set<Id> testAccountSet = new Set<Id>{ md.mockAccountId };

        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        mapAccounts.put(md.mockAccountId, md.mockAccount);

        md.mocks.startStubbing();
        md.mocks.when(mockMasterAccountPlanSelector.selectById(new Set<Id>{ md.mockMasterAccountPlanId }))
            .thenReturn(new List<pq_Master_Account_Plan__c>{ md.mockMasterAccountPlan });
        md.mocks.when(
                mockMasterAccountPlanAssociationSelector.selectByMasterAccountPlanId(
                    new Set<Id>{ md.mockMasterAccountPlanId }
                )
            )
            .thenReturn(new List<Master_Account_Plan_Associations__c>{ md.mockMasterAccountPlanAssociation });
        md.mocks.when(mockAccountService.getAccountAndDescendents(md.mockAccountId)).thenReturn(mapAccounts);
        md.mocks.when(mockAccountPlanSelector.selectByAccountIdWithAccountAndOwner(testAccountSet, md.mockMasterAccountPlanId))
            .thenReturn(new List<Account_Plan__c>());
        md.mocks.when(mockAccountPlanSelector.selectByIdWithAccountAndOwnerAndMasterAccountPlan(testAccountPlanSet, md.mockMasterAccountPlanId))
            .thenReturn(new List<Account_Plan__c>());
        md.mocks.stopStubbing();

        MasterAccountPlanService.getAccountPlansByMasterAccountPlan(md.mockMasterAccountPlanId);
        ((MasterAccountPlanSelector) md.mocks.verify(mockMasterAccountPlanSelector, 1))
            .selectById(new Set<Id>{ md.mockMasterAccountPlanId });
        ((MasterAccountPlanAssociationSelector) md.mocks.verify(mockMasterAccountPlanAssociationSelector, 1))
            .selectByMasterAccountPlanId(new Set<Id>{ md.mockMasterAccountPlanId });
        ((AccountServiceImpl) md.mocks.verify(mockAccountService, 1)).getAccountAndDescendents(md.mockAccountId);
        ((AccountPlanSelector) md.mocks.verify(mockAccountPlanSelector, 1))
            .selectByAccountIdWithAccountAndOwner(testAccountSet, md.mockMasterAccountPlanId);
        ((AccountPlanSelector) md.mocks.verify(mockAccountPlanSelector, 1))
            .selectByIdWithAccountAndOwnerAndMasterAccountPlan(testAccountPlanSet, md.mockMasterAccountPlanId);
        System.assert(true, 'Assert verified by mocks');
    }

    @isTest
    static void updateClosedPlanFilterNoSettingsTest1() {
        TestMockData md = new TestMockData();
        MasterAccountPlanSelector mockMasterAccountPlanSelector = md.mockMasterAccountPlanSelector;

        Account mockAccount = new Account(Name= 'Mock Account', OwnerId = UserInfo.getUserId());
        insert mockAccount;

        pq_Master_Account_Plan__c mockMasterAp = new pq_Master_Account_Plan__c();
        mockMasterAp.Name = 'Fake master account name';
        mockMasterAp.OwnerId = UserInfo.getUserId();
        mockMasterAp.Account__c = mockAccount.Id;
        insert mockMasterAp;

        md.mocks.startStubbing();
        md.mocks.when(mockMasterAccountPlanSelector.selectById(new Set<Id>{ mockMasterAp.Id }))
            .thenReturn(new List<pq_Master_Account_Plan__c>{ mockMasterAp });
        md.mocks.stopStubbing();

        Boolean result = MasterAccountPlanService.updateClosedPlanFilter(
            true, mockMasterAp.Id
        );
        System.assertEquals(result, true);
    }

    @isTest
    static void updateClosedPlanFilterNoSettingsTest2() {
        TestMockData md = new TestMockData();
        MasterAccountPlanSelector mockMasterAccountPlanSelector = md.mockMasterAccountPlanSelector;

        Account mockAccount = new Account(Name= 'Mock Account', OwnerId = UserInfo.getUserId());
        insert mockAccount;

        pq_Master_Account_Plan__c mockMasterAp = new pq_Master_Account_Plan__c();
        mockMasterAp.Name = 'Fake master account name';
        mockMasterAp.OwnerId = UserInfo.getUserId();
        mockMasterAp.Account__c = mockAccount.Id;
        insert mockMasterAp;

        md.mocks.startStubbing();
        md.mocks.when(mockMasterAccountPlanSelector.selectById(new Set<Id>{ mockMasterAp.Id }))
            .thenReturn(new List<pq_Master_Account_Plan__c>{ mockMasterAp });
        md.mocks.stopStubbing();

        Boolean result = MasterAccountPlanService.updateClosedPlanFilter(
            false, mockMasterAp.Id
        );
        System.assertEquals(result, false);
    }

    @isTest
    static void updateClosedPlanFilterTest1() {
        TestMockData md = new TestMockData();
        MasterAccountPlanSelector mockMasterAccountPlanSelector = md.mockMasterAccountPlanSelector;

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

        md.mocks.startStubbing();
        md.mocks.when(mockMasterAccountPlanSelector.selectById(new Set<Id>{ mockMasterAp.Id }))
            .thenReturn(new List<pq_Master_Account_Plan__c>{ mockMasterAp });
        md.mocks.stopStubbing();

        Boolean result = MasterAccountPlanService.updateClosedPlanFilter(
            true, mockMasterAp.Id
        );
        
        List<Master_Account_Plan_User_Setting__c> updatedMasterAccountPlanList = MasterAccountPlanUserSettingSelector.newInstance().selectForCurrentUserAndMasterAccountPlan(mockMasterAp.Id );
        Boolean updatedFilterValue = updatedMasterAccountPlanList[0].Show_Closed_Account_Plans__c;

        System.assertEquals(result, true);
        System.assertEquals(updatedFilterValue, true);
    }
}