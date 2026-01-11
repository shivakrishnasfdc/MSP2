@isTest
public with sharing class AccountPlanUnsharingTest {
    private static TestMockData md = new TestMockData();
    private static AccountTeamServiceImpl mockAccountTeamService = md.mockAccountTeamService;

    /******************************
     *            TESTS
     ******************************/

    @isTest
    private static void unshareAccountPlansThrowsExceptionIfAccountTeamsAreNotEnabled() {
        // Given
        md.mocks.startStubbing();
        md.mocks.when(mockAccountTeamService.areAccountTeamsEnabled()).thenReturn(false);
        md.mocks.stopStubbing();

        List<AccountPlanUnsharing.AccountPlanUnsharingInput> shareAccountPlansInput = new List<AccountPlanUnsharing.AccountPlanUnsharingInput>();
        AccountPlanUnsharing.AccountPlanUnsharingException error;

        // When
        try {
            AccountPlanUnsharing.unshareAccountPlans(shareAccountPlansInput);
        } catch (AccountPlanUnsharing.AccountPlanUnsharingException e) {
            error = e;
        }

        // Then
        ((AccountTeamServiceImpl) md.mocks.verify(mockAccountTeamService, 1)).areAccountTeamsEnabled();
        system.assertNotEquals(null, error);
    }

    @isTest
    private static void unsharingWorksForActiveUsers() {
        // Given
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;
        AccountPlanSharesSelector mockAccountPlanSharesSelector = md.mockAccountPlanSharesSelector;
        UsersSelector mockUsersSelector = md.mockUsersSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        AccountPlanUnsharing.AccountPlanUnsharingInput input1 = new AccountPlanUnsharing.AccountPlanUnsharingInput();
        input1.userId = md.mockUserId;
        input1.accountId = md.mockAccountPlan.Account__c;

        List<AccountPlanUnsharing.AccountPlanUnsharingInput> unshareAccountPlansInput = new List<AccountPlanUnsharing.AccountPlanUnsharingInput>{
            input1
        };

        Account_Plan__Share shareRecord = new Account_Plan__Share(
            ParentId = md.mockAccountPlan.Id,
            UserOrGroupId = input1.userId,
            RowCause = Schema.Account_Plan__Share.RowCause.AccountTeam__c
        );

        List<Account_Plan__Share> sharesToDelete = new List<Account_Plan__Share>{ shareRecord };

        md.mocks.startStubbing();
        md.mocks.when(mockAccountTeamService.areAccountTeamsEnabled()).thenReturn(true);
        md.mocks.when(mockUsersSelector.selectActiveUserIdsAsSystem(new Set<Id>{ md.mockUserId }))
            .thenReturn(new Set<Id>{ md.mockUserId });
        md.mocks.when(mockAccountPlanSelector.selectByAccountIdsAsSystem(new Set<Id>{ input1.accountId }))
            .thenReturn(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mocks.when(
                mockAccountPlanSharesSelector.selectByAccoundPlanIdsAndUserIdsAsSystem(
                    new Set<Id>{ md.mockAccountPlan.Id },
                    new Set<Id>{ input1.userId },
                    Schema.Account_Plan__Share.RowCause.AccountTeam__c
                )
            )
            .thenReturn(sharesToDelete);
        md.mocks.stopStubbing();

        // When
        AccountPlanUnsharing.unshareAccountPlans(unshareAccountPlansInput);

        // Then
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDeleted(sharesToDelete);
        system.assert(true);
    }

    @isTest
    private static void unsharingDoesNotHappenForInactiveUsers() {
        // Given
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;
        AccountPlanSharesSelector mockAccountPlanSharesSelector = md.mockAccountPlanSharesSelector; //NOPMD - Needs to be called in order for it to be mocked in the test
        UsersSelector mockUsersSelector = md.mockUsersSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        AccountPlanUnsharing.AccountPlanUnsharingInput input1 = new AccountPlanUnsharing.AccountPlanUnsharingInput();
        input1.userId = md.mockUserId;
        input1.accountId = md.mockAccountPlan.Account__c;

        List<AccountPlanUnsharing.AccountPlanUnsharingInput> unshareAccountPlansInput = new List<AccountPlanUnsharing.AccountPlanUnsharingInput>{
            input1
        };

        Account_Plan__Share shareRecord = new Account_Plan__Share(
            ParentId = md.mockAccountPlan.Id,
            UserOrGroupId = input1.userId,
            RowCause = Schema.Account_Plan__Share.RowCause.AccountTeam__c
        );

        List<Account_Plan__Share> sharesToDelete = new List<Account_Plan__Share>{ shareRecord };

        md.mocks.startStubbing();
        md.mocks.when(mockAccountTeamService.areAccountTeamsEnabled()).thenReturn(true);
        md.mocks.when(mockUsersSelector.selectActiveUserIdsAsSystem(new Set<Id>{ md.mockUserId }))
            .thenReturn(new Set<Id>{});
        md.mocks.when(mockAccountPlanSelector.selectByAccountIdsAsSystem(new Set<Id>{ input1.accountId }))
            .thenReturn(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mocks.stopStubbing();

        // When
        AccountPlanUnsharing.unshareAccountPlans(unshareAccountPlansInput);

        // Then
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, md.mocks.never())).registerDeleted(sharesToDelete);
        System.assert(true);
    }
}