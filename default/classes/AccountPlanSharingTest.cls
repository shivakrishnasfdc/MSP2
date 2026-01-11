@isTest
public with sharing class AccountPlanSharingTest {
    private static TestMockData md = new TestMockData();
    private static AccountTeamServiceImpl mockAccountTeamService = md.mockAccountTeamService;

    /******************************
     *            TESTS
     ******************************/

    @isTest
    private static void shareAccountPlansThrowsExceptionIfAccountTeamsAreNotEnabled() {
        // Given
        md.mocks.startStubbing();
        md.mocks.when(mockAccountTeamService.areAccountTeamsEnabled()).thenReturn(false);
        md.mocks.stopStubbing();

        List<AccountPlanSharing.AccountPlanSharingInput> shareAccountPlansInput = new List<AccountPlanSharing.AccountPlanSharingInput>();
        AccountPlanSharing.AccountPlanSharingException error;

        // When
        try {
            AccountPlanSharing.shareAccountPlans(shareAccountPlansInput);
        } catch (AccountPlanSharing.AccountPlanSharingException e) {
            error = e;
        }

        // Then
        ((AccountTeamServiceImpl) md.mocks.verify(mockAccountTeamService, 1)).areAccountTeamsEnabled();
        system.assertNotEquals(null, error);
    }

    @isTest
    private static void shareAccountPlansCreatesShareRecords() {
        // Given
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;
        UsersSelector mockUsersSelector = md.mockUsersSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        AccountPlanSharing.AccountPlanSharingInput input1 = new AccountPlanSharing.AccountPlanSharingInput();
        input1.userId = md.mockUserId;
        input1.accountId = md.mockAccountPlan.Account__c;
        input1.accessLevel = 'Read';

        List<AccountPlanSharing.AccountPlanSharingInput> shareAccountPlansInput = new List<AccountPlanSharing.AccountPlanSharingInput>{
            input1
        };

        md.mocks.startStubbing();
        md.mocks.when(mockAccountTeamService.areAccountTeamsEnabled()).thenReturn(true);
        md.mocks.when(mockAccountPlanSelector.selectByAccountIdsAsSystem(new Set<Id>{ input1.accountId }))
            .thenReturn(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mocks.when(mockUsersSelector.selectActiveUserIdsAsSystem(new Set<Id>{ md.mockUserId }))
            .thenReturn(new Set<Id>{ md.mockUserId });
        md.mocks.stopStubbing();

        // When
        AccountPlanSharing.shareAccountPlans(shareAccountPlansInput);

        // Then
        // expected insert
        Account_Plan__Share shareRecord = new Account_Plan__Share(
            ParentId = md.mockAccountPlan.Id,
            UserOrGroupId = input1.userId,
            AccessLevel = input1.accessLevel,
            RowCause = Schema.Account_Plan__Share.RowCause.AccountTeam__c
        );
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew(new List<Account_Plan__Share>{ shareRecord });
        System.assert(true);
    }

    @isTest
    private static void shareAccountPlansDoesntShareRecordsForInactiveUsers() {
        // Given
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;
        UsersSelector mockUsersSelector = md.mockUsersSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        AccountPlanSharing.AccountPlanSharingInput input1 = new AccountPlanSharing.AccountPlanSharingInput();
        input1.userId = md.mockUserId;
        input1.accountId = md.mockAccountPlan.Account__c;
        input1.accessLevel = 'Read';

        List<AccountPlanSharing.AccountPlanSharingInput> shareAccountPlansInput = new List<AccountPlanSharing.AccountPlanSharingInput>{
            input1
        };

        md.mocks.startStubbing();
        md.mocks.when(mockAccountTeamService.areAccountTeamsEnabled()).thenReturn(true);
        md.mocks.when(mockAccountPlanSelector.selectByAccountIdsAsSystem(new Set<Id>{ input1.accountId }))
            .thenReturn(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mocks.when(mockUsersSelector.selectActiveUserIdsAsSystem(new Set<Id>{ md.mockUserId }))
            .thenReturn(new Set<Id>());
        md.mocks.stopStubbing();

        // When
        AccountPlanSharing.shareAccountPlans(shareAccountPlansInput);

        // Then
        Account_Plan__Share shareRecord = new Account_Plan__Share(
            ParentId = md.mockAccountPlan.Id,
            UserOrGroupId = input1.userId,
            AccessLevel = input1.accessLevel,
            RowCause = Schema.Account_Plan__Share.RowCause.AccountTeam__c
        );
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, md.mocks.never()))
            .registerNew(new List<Account_Plan__Share>{ shareRecord });
        System.assert(true);
    }
}