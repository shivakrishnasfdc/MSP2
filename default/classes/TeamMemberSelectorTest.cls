@isTest
private class TeamMemberSelectorTest {
    private static final String USER1_LASTNAME = '1';
    private static final String USER2_LASTNAME = '2';
    private static final String ACCOUNT_PLAN1_NAME = 'Account Plan 1';
    private static final String ACCOUNT_PLAN2_NAME = 'Account Plan 2';

    public static final String CRUSH_ACCOUNT_PLAN_CREATOR = 'CRUSH_Account_Plan_Creator';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    public static final String STANDARD_USER = 'Standard User';

    @testSetup
    static void testSetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];

        User user1 = TestDataFactory.createUser('User', USER1_LASTNAME, p.Id);
        User user2 = TestDataFactory.createUser('User', USER2_LASTNAME, p.Id);

        PermissionSet creatorUserPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = :CRUSH_ACCOUNT_PLAN_CREATOR
        ];
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];

        List<PermissionSetAssignment> permissionSets = new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = user1.Id, PermissionSetId = creatorUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = user2.Id, PermissionSetId = creatorUserPermissionSet.Id)
        };

        Id systemUserId = UserInfo.getUserId();
        PermissionSetAssignment systemStrategyAdminPermissions = TestDataFactory.createPermissionSetAssignment(
            systemUserId,
            adminUserPermissionSet.Id
        );

        if (systemStrategyAdminPermissions != null) {
            permissionSets.add(systemStrategyAdminPermissions);
        }

        insert permissionSets;

        Application.bypassTrigger = true;
        AccountPlans.bypassEmailTrigger = true;
        TeamMembers.bypassEmailTrigger = true;

        System.runAs(user1) {
            Account a = new Account(Name = 'Account 1');
            insert a;

            Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan(ACCOUNT_PLAN1_NAME, a);
            TestDataFactory.createTeamMember(user1, accountPlan1, 'Edit');
        }

        System.runAs(user2) {
            Account a = new Account(Name = 'Account 1');
            insert a;

            Account_Plan__c accountPlan2 = TestDataFactory.createAccountPlan(ACCOUNT_PLAN2_NAME, a);
            TestDataFactory.createTeamMember(user1, accountPlan2, 'Edit');
        }
    }

    @isTest
    static void selectByAccountPlanIdsTest() {
        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(systemUser) {
            // Given
            Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
            Team_Member__c teamMember2 = [
                SELECT Id
                FROM Team_Member__c
                WHERE User__r.LastName = :USER1_LASTNAME
                LIMIT 1
            ];

            // When
            Test.startTest();
            List<Team_Member__c> teamMembers = TeamMemberSelector.newInstance()
                .selectByAccountPlanIds(new Set<Id>{ accountPlan1.Id });
            Test.stopTest();

            // Then
            System.assertEquals(1, teamMembers.size());
            System.assertEquals(teamMember2.Id, teamMembers[0].Id);
        }
    }

    @isTest
    static void selectByAccountPlanIdAndUserIdAsSystemTest() {
        // Given
        User user1 = [SELECT Id FROM User WHERE LastName = :USER1_LASTNAME];
        User user2 = [SELECT Id FROM User WHERE LastName = :USER2_LASTNAME];
        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
        Account_Plan__c accountPlan2 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME];
        Set<Id> accountPlanIds = new Set<Id>{ accountPlan1.Id, accountPlan2.Id };

        // When
        Test.startTest();

        List<Team_Member__c> user1TeamMembers;
        List<Team_Member__c> user2TeamMembers;

        System.runAs(user1) {
            user1TeamMembers = TeamMemberSelector.newInstance()
                .selectByAccountPlanIdAndUserIdAsSystem(accountPlanIds, new Set<Id>{ user1.Id });
        }

        System.runAs(user1) {
            user2TeamMembers = TeamMemberSelector.newInstance()
                .selectByAccountPlanIdAndUserIdAsSystem(accountPlanIds, new Set<Id>{ user2.Id });
        }

        Test.stopTest();

        // Then
        System.assertEquals(1, user1TeamMembers.size());
        System.assertEquals(user1.Id, user1TeamMembers[0].User__c);
        System.assertEquals(accountPlan1.Id, user1TeamMembers[0].Account_Plan__c);
    }

    @isTest
    static void selectDuplicatesTest() {
        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(systemUser) {
            // Given
            Team_Member__c teamMember1 = [
                SELECT Id, User__c, Account_Plan__c, Role__c
                FROM Team_Member__c
                WHERE User__r.LastName = :USER1_LASTNAME
                LIMIT 1
            ];
            Team_Member__c duplicateMember = new Team_Member__c(
                User__c = teamMember1.User__c,
                Account_Plan__c = teamMember1.Account_Plan__c,
                Role__c = teamMember1.Role__c
            );

            // When
            Test.startTest();
            List<Team_Member__c> duplicateMembers = TeamMemberSelector.newInstance()
                .selectDuplicatesAsSystem(new List<Team_Member__c>{ duplicateMember });
            Test.stopTest();

            // Then
            System.assertEquals(1, duplicateMembers.size());
            System.assertEquals(duplicateMember, duplicateMembers[0]);
        }
    }
}