@isTest
private class FieldHistoryControllerTest {
    public static final String ADMIN_USER_FIRST_NAME = 'Apple';
    public static final String ADMIN_USER_LAST_NAME = 'Create';

    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User adminUser = TestDataFactory.createUser(ADMIN_USER_FIRST_NAME, ADMIN_USER_LAST_NAME, standardProfile.Id);

        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR LIMIT 1];

        insert new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = adminUserPermissionSet.Id);

        System.runAs(adminUser) {
            Account testAccount = new Account(Name = 'Account 1');
            insert testAccount;

            AccountPlans.bypassEmailTrigger = true;
            TestDataFactory.createAccountPlan('account plan 1', testAccount);
        }
    }

    @isTest
    static void getHistoryByAccountPlanIdTest() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AccountPlanSelector mockAccountPlanSelector = (AccountPlanSelector) FFLibHelper.mockSelector(
            AccountPlanSelector.class,
            mocks
        );
        AccountPlanOpportunitySelector mockAccountPlanOpportunitySelector = (AccountPlanOpportunitySelector) FFLibHelper.mockSelector(
            AccountPlanOpportunitySelector.class,
            mocks
        );
        KeyDateSelector mockKeyDateSelector = (KeyDateSelector) FFLibHelper.mockSelector(KeyDateSelector.class, mocks);
        RelationshipMapMemberSelector mockRMMSelector = (RelationshipMapMemberSelector) FFLibHelper.mockSelector(
            RelationshipMapMemberSelector.class,
            mocks
        );
        ObjectiveOpportunitySelector mockObjectiveOpportunitySelector = (ObjectiveOpportunitySelector) FFLibHelper.mockSelector(
            ObjectiveOpportunitySelector.class,
            mocks
        );
        ObjectiveSelector mockObjectiveSelector = (ObjectiveSelector) FFLibHelper.mockSelector(
            ObjectiveSelector.class,
            mocks
        );
        SWOTAnalysisSelector mockSWOTAnalysisSelector = (SWOTAnalysisSelector) FFLibHelper.mockSelector(
            SWOTAnalysisSelector.class,
            mocks
        );
        TeamMemberSelector mockTeamMemberSelector = (TeamMemberSelector) FFLibHelper.mockSelector(
            TeamMemberSelector.class,
            mocks
        );

        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c WHERE OwnerId = :adminUser.Id LIMIT 1];
        Set<Id> accountPlanIds = new Set<Id>{ accountPlan.Id };

        // Mock behavior
        mocks.startStubbing();

        mocks.when(mockAccountPlanSelector.selectSObjectsByIdWithHistory(accountPlanIds))
            .thenReturn(new List<SObject>());
        mocks.when(
                mockAccountPlanOpportunitySelector.selectByAccountPlanIdWithHistory(
                    accountPlanIds,
                    AccountPlanOpportunitySelector.HISTORY_FIELDS
                )
            )
            .thenReturn(new List<SObject>());
        mocks.when(mockKeyDateSelector.selectByAccountPlanIdWithHistory(accountPlanIds))
            .thenReturn(new List<SObject>());
        mocks.when(
                mockRMMSelector.selectByAccountPlanIdsWithHistory(
                    accountPlanIds,
                    RelationshipMapMemberSelector.HISTORY_FIELDS
                )
            )
            .thenReturn(new List<SObject>());
        mocks.when(
                mockObjectiveOpportunitySelector.selectByAccountPlanIdWithHistory(
                    accountPlanIds,
                    ObjectiveOpportunitySelector.HISTORY_FIELDS
                )
            )
            .thenReturn(new List<SObject>());
        mocks.when(mockObjectiveSelector.selectByAccountPlanIdWithHistory(accountPlanIds))
            .thenReturn(new List<SObject>());
        mocks.when(mockSWOTAnalysisSelector.selectByAccountPlanIdWithHistory(accountPlanIds))
            .thenReturn(new List<SObject>());
        mocks.when(
                mockTeamMemberSelector.selectByAccountPlanIdWithHistory(
                    accountPlanIds,
                    TeamMemberSelector.HISTORY_FIELDS
                )
            )
            .thenReturn(new List<SObject>());

        mocks.stopStubbing();

        Application.Selector.setMock(mockAccountPlanSelector);
        Application.Selector.setMock(mockAccountPlanOpportunitySelector);
        Application.Selector.setMock(mockKeyDateSelector);
        Application.Selector.setMock(mockRMMSelector);
        Application.Selector.setMock(mockObjectiveOpportunitySelector);
        Application.Selector.setMock(mockObjectiveSelector);
        Application.Selector.setMock(mockSWOTAnalysisSelector);
        Application.Selector.setMock(mockTeamMemberSelector);

        // When
        FieldHistoryController.getHistoryByAccountPlanId(accountPlan.Id);

        // Then
        try {
            ((AccountPlanSelector) mocks.verify(mockAccountPlanSelector, 1))
                .selectSObjectsByIdWithHistory(accountPlanIds);
            ((AccountPlanOpportunitySelector) mocks.verify(mockAccountPlanOpportunitySelector, 1))
                .selectByAccountPlanIdWithHistory(accountPlanIds, AccountPlanOpportunitySelector.HISTORY_FIELDS);
            ((KeyDateSelector) mocks.verify(mockKeyDateSelector, 1)).selectByAccountPlanIdWithHistory(accountPlanIds);
            ((RelationshipMapMemberSelector) mocks.verify(mockRMMSelector, 1))
                .selectByAccountPlanIdsWithHistory(accountPlanIds, RelationshipMapMemberSelector.HISTORY_FIELDS);
            ((ObjectiveOpportunitySelector) mocks.verify(mockObjectiveOpportunitySelector, 1))
                .selectByAccountPlanIdWithHistory(accountPlanIds, ObjectiveOpportunitySelector.HISTORY_FIELDS);
            ((ObjectiveSelector) mocks.verify(mockObjectiveSelector, 1))
                .selectByAccountPlanIdWithHistory(accountPlanIds);
            ((SWOTAnalysisSelector) mocks.verify(mockSWOTAnalysisSelector, 1))
                .selectByAccountPlanIdWithHistory(accountPlanIds);
            ((TeamMemberSelector) mocks.verify(mockTeamMemberSelector, 1))
                .selectByAccountPlanIdWithHistory(accountPlanIds, TeamMemberSelector.HISTORY_FIELDS);
            System.assert(true);
        } catch (fflib_ApexMocks.ApexMocksException e) {
            System.assert(false);
        }
    }
}