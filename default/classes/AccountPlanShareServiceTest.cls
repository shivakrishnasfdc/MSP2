@isTest
public with sharing class AccountPlanShareServiceTest {
    private static TestMockData md = new TestMockData();
    private static AccountTeamServiceImpl mockAccountTeamService = md.mockAccountTeamService;
    private static fflib_ISObjectUnitOfWork mockUow = md.mockUow;

    // /******************************
    //  *            TESTS
    //  ******************************/

    @isTest
    static void updateAllAccountTeamSharesWithNoParameters() {
        // Given
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;
        Account_Plan__c mockAccountPlan = md.mockAccountPlan;

        AccountTeamService.AccountTeamMemberWrapper teamMember1 = new AccountTeamService.AccountTeamMemberWrapper();
        teamMember1.UserId = md.mockUserId;
        teamMember1.AccountAccessLevel = 'Edit';
        teamMember1.AccountId = mockAccountPlan.Account__c;

        List<Account_Plan__c> accountPlans = new List<Account_Plan__c>{ mockAccountPlan };

        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanSelector.selectAllWithSharesAsSystem()).thenReturn(accountPlans);
        md.mocks.when(mockAccountTeamService.getAccountTeamMembersAsSystem(new Set<Id>{ mockAccountPlan.Account__c }))
            .thenReturn(new List<AccountTeamService.AccountTeamMemberWrapper>{ teamMember1 });
        md.mocks.stopStubbing();

        AccountPlanShareService.updateAllAccountTeamShares();

        ((AccountPlanSelector) md.mocks.verify(mockAccountPlanSelector, 1)).selectAllWithSharesAsSystem();
        ((AccountTeamServiceImpl) md.mocks.verify(mockAccountTeamService, 1))
            .getAccountTeamMembersAsSystem(new Set<Id>{ mockAccountPlan.Account__c });
        System.assert(true);
    }

    @isTest
    static void updateAllAccountTeamSharesByAccountPlanIds() {
        // Given
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;
        fflib_ISObjectUnitOfWork mockUow = MD.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test

        Account_Plan__c mockAccountPlan = md.mockAccountPlan;

        AccountTeamService.AccountTeamMemberWrapper teamMember1 = new AccountTeamService.AccountTeamMemberWrapper();
        teamMember1.UserId = md.mockUserId;
        teamMember1.AccountAccessLevel = 'Edit';
        teamMember1.AccountId = mockAccountPlan.Account__c;

        List<Account_Plan__c> accountPlans = new List<Account_Plan__c>{ mockAccountPlan };

        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanSelector.selectByIdWithSharesAsSystem(new Set<Id>{ mockAccountPlan.Id }))
            .thenReturn(accountPlans);
        md.mocks.when(mockAccountTeamService.getAccountTeamMembersAsSystem(new Set<Id>{ mockAccountPlan.Account__c }))
            .thenReturn(new List<AccountTeamService.AccountTeamMemberWrapper>{ teamMember1 });
        md.mocks.stopStubbing();

        AccountPlanShareService.updateAllAccountTeamShares(new List<Id>{ mockAccountPlan.Id });

        ((AccountPlanSelector) md.mocks.verify(mockAccountPlanSelector, 1))
            .selectByIdWithSharesAsSystem(new Set<Id>{ mockAccountPlan.Id });
        ((AccountTeamServiceImpl) md.mocks.verify(mockAccountTeamService, 1))
            .getAccountTeamMembersAsSystem(new Set<Id>{ mockAccountPlan.Account__c });
        System.assert(true);
    }

    @isTest
    static void updateAllAccountTeamSharesByAccountPlansCreatesSharesForNewTeamMembers() {
        // Given
        Account_Plan__c mockAccountPlan = md.mockAccountPlan;

        AccountTeamService.AccountTeamMemberWrapper teamMember1 = new AccountTeamService.AccountTeamMemberWrapper();
        teamMember1.UserId = md.mockUserId;
        teamMember1.AccountAccessLevel = 'Edit';
        teamMember1.AccountId = mockAccountPlan.Account__c;

        List<Account_Plan__c> accountPlans = new List<Account_Plan__c>{ mockAccountPlan };

        md.mocks.startStubbing();
        md.mocks.when(mockAccountTeamService.getAccountTeamMembersAsSystem(new Set<Id>{ mockAccountPlan.Account__c }))
            .thenReturn(new List<AccountTeamService.AccountTeamMemberWrapper>{ teamMember1 });
        md.mocks.stopStubbing();

        AccountPlanShareService.updateAllAccountTeamShares(accountPlans);

        Account_Plan__Share accountPlanShare = new Account_Plan__Share(
            ParentId = mockAccountPlan.Id,
            UserOrGroupId = teamMember1.UserId,
            AccessLevel = teamMember1.AccountAccessLevel,
            RowCause = Schema.Account_Plan__Share.RowCause.AccountTeam__c
        );

        ((AccountTeamServiceImpl) md.mocks.verify(mockAccountTeamService, 1))
            .getAccountTeamMembersAsSystem(new Set<Id>{ mockAccountPlan.Account__c });
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew(new List<Account_Plan__Share>{ accountPlanShare });
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDeleted(new List<Account_Plan__Share>());
        System.assert(true);
    }

    @isTest
    static void updateAllAccountTeamSharesByAccountPlansDeletesSharesForTeamMembersThatNoLongerExist() {
        // Given
        Account_Plan__c mockAccountPlan = md.mockAccountPlan;

        Account_Plan__Share accountPlanShare = new Account_Plan__Share(
            ParentId = mockAccountPlan.Id,
            UserOrGroupId = md.mockUserId,
            AccessLevel = 'Edit',
            RowCause = Schema.Account_Plan__Share.RowCause.AccountTeam__c
        );

        Account_Plan__c mockAPWithShares = createMockAccountPlanWithShares(
            mockAccountPlan,
            new List<Account_Plan__Share>{ accountPlanShare }
        );

        List<Account_Plan__c> accountPlans = new List<Account_Plan__c>{ mockAPWithShares };

        md.mocks.startStubbing();
        md.mocks.when(mockAccountTeamService.getAccountTeamMembersAsSystem(new Set<Id>{ mockAccountPlan.Account__c }))
            .thenReturn(new List<AccountTeamService.AccountTeamMemberWrapper>());
        md.mocks.stopStubbing();

        AccountPlanShareService.updateAllAccountTeamShares(accountPlans);

        ((AccountTeamServiceImpl) md.mocks.verify(mockAccountTeamService, 1))
            .getAccountTeamMembersAsSystem(new Set<Id>{ mockAccountPlan.Account__c });
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew(new List<Account_Plan__Share>());
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerDeleted(new List<Account_Plan__Share>{ accountPlanShare });
        System.assert(true);
    }

    private static Account_Plan__c createMockAccountPlanWithShares(
        Account_Plan__c accountPlan,
        List<Account_Plan__Share> shares
    ) {
        List<Account_Plan__c> mockAPList = (List<Account_Plan__c>) fflib_ApexMocksUtils.makeRelationship(
            List<Account_Plan__c>.class,
            new List<Account_Plan__c>{ accountPlan },
            Account_Plan__Share.ParentId,
            new List<List<Account_Plan__Share>>{ shares }
        );
        return mockAPList[0];
    }
}