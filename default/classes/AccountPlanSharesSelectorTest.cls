@isTest
private class AccountPlanSharesSelectorTest {
    private static final String USER1_LASTNAME = '1';
    private static final String USER2_LASTNAME = '2';
    private static final String USER3_LASTNAME = '3';

    private static final String ACCOUNT_PLAN1_NAME = '1';
    private static final String ACCOUNT_PLAN2_NAME = '2';

    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    public static final String STANDARD_USER = 'Standard User';

    @testSetup
    static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];

        User user1 = TestDataFactory.createUser('User', USER1_LASTNAME, p.Id);
        User user2 = TestDataFactory.createUser('User', USER2_LASTNAME, p.Id);
        User user3 = TestDataFactory.createUser('User', USER3_LASTNAME, p.Id);

        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];

        Id systemUserId = UserInfo.getUserId();
        PermissionSetAssignment systemStrategyAdminPermissions = TestDataFactory.createPermissionSetAssignment(
            systemUserId,
            adminUserPermissionSet.Id
        );
        Application.bypassTrigger = true;

        if (systemStrategyAdminPermissions != null) {
            insert systemStrategyAdminPermissions;
        }

        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(systemUser) {
            Account a = new Account(Name = 'Account 1');
            insert a;

            AccountPlans.bypassEmailTrigger = true;
            TeamMembers.bypassEmailTrigger = true;

            Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan(ACCOUNT_PLAN1_NAME, a);
            Account_Plan__c accountPlan2 = TestDataFactory.createAccountPlan(ACCOUNT_PLAN2_NAME, a);

            TestDataFactory.createAccountPlanShare(user1, accountPlan1, 'Read');
            TestDataFactory.createAccountPlanShare(user1, accountPlan2, 'Read');
            TestDataFactory.createAccountPlanShare(user2, accountPlan1, 'Read');
            TestDataFactory.createAccountPlanShare(user2, accountPlan2, 'Read');
            TestDataFactory.createAccountPlanShare(
                user3,
                accountPlan1,
                'Read',
                AccountPlanSharesSelector.ACCOUNT_TEAM_SHARE_REASON
            );
            TestDataFactory.createAccountPlanShare(
                user3,
                accountPlan2,
                'Read',
                AccountPlanSharesSelector.ACCOUNT_TEAM_SHARE_REASON
            );

            TestDataFactory.createTeamMember(user1, accountPlan1, 'Read Only');
            TestDataFactory.createTeamMember(user1, accountPlan2, 'Read Only');
            TestDataFactory.createTeamMember(user2, accountPlan1, 'Read Only');
            TestDataFactory.createTeamMember(user2, accountPlan2, 'Read Only');
        }
    }

    @isTest
    static void selectByAccountPlanIdsTest() {
        // Given
        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];

        // When
        Test.startTest();

        List<Account_Plan__Share> selectedRecords = new AccountPlanSharesSelector()
            .selectByAccountPlanIdsAsSystem(new Set<Id>{ accountPlan1.Id });

        Test.stopTest();

        // Then
        System.assertEquals(3, selectedRecords.size(), 'Expected only 3 records.');
        System.assertEquals(accountPlan1.Id, selectedRecords[0].ParentId);
        System.assertEquals(accountPlan1.Id, selectedRecords[1].ParentId);
        System.assertEquals(accountPlan1.Id, selectedRecords[2].ParentId);
    }

    @isTest
    static void selectByTeamMembersTest() {
        // Given
        User user1 = [SELECT Id FROM User WHERE LastName = :USER1_LASTNAME];
        User user2 = [SELECT Id FROM User WHERE LastName = :USER2_LASTNAME];
        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
        Account_Plan__c accountPlan2 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME];

        Team_Member__c user1AccountPlan2Member = [
            SELECT Id, User__c, Account_Plan__c
            FROM Team_Member__c
            WHERE User__c = :user1.Id AND Account_Plan__c = :accountPlan2.Id
        ];
        Team_Member__c user2AccountPlan1Member = [
            SELECT Id, User__c, Account_Plan__c
            FROM Team_Member__c
            WHERE User__c = :user2.Id AND Account_Plan__c = :accountPlan1.Id
        ];

        Account_Plan__Share user1AccountPlan2Share = [
            SELECT Id
            FROM Account_Plan__Share
            WHERE UserOrGroupId = :user1.Id AND ParentId = :accountPlan2.Id
        ];
        Account_Plan__Share user2AccountPlan1Share = [
            SELECT Id
            FROM Account_Plan__Share
            WHERE UserOrGroupId = :user2.Id AND ParentId = :accountPlan1.Id
        ];

        // When
        Test.startTest();

        List<Account_Plan__Share> accountPlanShares = new AccountPlanSharesSelector()
            .selectByTeamMembers(new List<Team_Member__c>{ user1AccountPlan2Member, user2AccountPlan1Member });

        Test.stopTest();

        // Then
        Set<Id> accountPlanShareIds = new Map<Id, Account_Plan__Share>(accountPlanShares).keyset();

        System.assertEquals(2, accountPlanShareIds.size(), 'Expected 2 Account Plan Share records.');
        System.assertEquals(true, accountPlanShareIds.contains(user1AccountPlan2Share.Id));
        System.assertEquals(true, accountPlanShareIds.contains(user2AccountPlan1Share.Id));
    }

    @isTest
    static void selectByAccoundPlanIdsAndUserIdsAsSystem() {
        // Given
        User user3 = [SELECT Id FROM User WHERE LastName = :USER3_LASTNAME];
        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];

        // When
        Test.startTest();
        List<Account_Plan__Share> selectedRecords = new AccountPlanSharesSelector()
            .selectByAccoundPlanIdsAndUserIdsAsSystem(
                new Set<Id>{ accountPlan1.Id },
                new Set<Id>{ user3.Id },
                AccountPlanSharesSelector.ACCOUNT_TEAM_SHARE_REASON
            );
        Test.stopTest();

        // Then
        System.assertEquals(1, selectedRecords.size());
        System.assertEquals(accountPlan1.Id, selectedRecords[0].ParentId);
    }
}