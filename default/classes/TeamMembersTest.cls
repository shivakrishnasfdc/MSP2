@isTest
private class TeamMembersTest {
    private static final String USER1_LASTNAME = '1';
    private static final String USER2_LASTNAME = '2';
    private static final String USER3_LASTNAME = '3';
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
        User user3 = TestDataFactory.createUser('User', USER3_LASTNAME, p.Id);

        PermissionSet creatorUserPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = :CRUSH_ACCOUNT_PLAN_CREATOR
        ];
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];

        List<PermissionSetAssignment> permissionSets = new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = user1.Id, PermissionSetId = creatorUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = user2.Id, PermissionSetId = creatorUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = user3.Id, PermissionSetId = creatorUserPermissionSet.Id)
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

        System.runAs(user1) {
            Account a = new Account(Name = 'Account 1');
            insert a;

            Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan(ACCOUNT_PLAN1_NAME, a);
            TestDataFactory.createTeamMember(user2, accountPlan1, 'Edit');
            TestDataFactory.createTeamMember(user3, accountPlan1, 'Read Only');
        }

        System.runAs(user2) {
            Account a = new Account(Name = 'Account 1');
            insert a;

            Account_Plan__c accountPlan2 = TestDataFactory.createAccountPlan(ACCOUNT_PLAN2_NAME, a);
            TestDataFactory.createTeamMember(user1, accountPlan2, 'Read Only');
        }
    }

    @isTest
    static void getUniqueKeyForTeamMemberTest() {
        // Given
        Team_Member__c teamMember = [SELECT Id, User__c, Account_Plan__c FROM Team_Member__c][0];

        // When
        Test.startTest();

        String uniqueKey = TeamMembers.getUniqueKey(teamMember);

        Test.stopTest();

        // Then
        String expectedValue = String.valueOf(TeamMember.Account_Plan__c) + String.valueOf(teamMember.User__c);
        System.assertEquals(expectedValue, uniqueKey);
    }

    @isTest
    static void getUniqueKeyForAccountPlanAndUserTest() {
        // Given
        Team_Member__c teamMember = [SELECT Id, User__c, Account_Plan__c FROM Team_Member__c][0];

        // When
        Test.startTest();

        String uniqueKey = TeamMembers.getUniqueKey(teamMember.Account_Plan__c, teamMember.User__c);

        Test.stopTest();

        // Then
        String expectedValue = String.valueOf(TeamMember.Account_Plan__c) + String.valueOf(teamMember.User__c);
        System.assertEquals(expectedValue, uniqueKey);
    }

    @isTest
    static void onValidateInsertDuplicateTest() {
        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(systemUser) {
            // Given
            User user1 = [SELECT Id FROM User WHERE LastName = :USER1_LASTNAME];
            Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME];
            Team_Member__c duplicateMember = new Team_Member__c(
                User__c = user1.Id,
                Account_Plan__c = accountPlan.Id,
                Role__c = 'Edit'
            );

            // When
            Test.startTest();

            TeamMembers teamMemberRecords = TeamMembers.newInstance(new List<Team_Member__c>{ duplicateMember });
            teamMemberRecords.onValidate();
            Database.saveResult saveResult = Database.insert(teamMemberRecords.getRecords(), false)[0];

            Test.stopTest();

            // Then
            List<Database.Error> errors = saveResult.getErrors();

            System.assertEquals(false, saveResult.isSuccess());
            System.assertEquals(1, errors.size());
            System.assertEquals(System.Label.error_duplicate_account_plan_team_member, errors[0].getMessage());
        }
    }

    @isTest
    static void onValidateUpdateDuplicateTest() {
        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(systemUser) {
            // Given
            User user2 = [SELECT Id FROM User WHERE LastName = :USER2_LASTNAME];
            User user3 = [SELECT Id FROM User WHERE LastName = :USER3_LASTNAME];
            Team_Member__c teamMember = [
                SELECT Id, User__c, Account_Plan__c, Role__c
                FROM Team_Member__c
                WHERE User__c = :user3.Id
            ];

            // When
            Test.startTest();

            Team_Member__c updatedTeamMember = teamMember.clone(true, false, true, false); // preserve Id and read-only fields
            updatedTeamMember.User__c = user2.Id;

            TeamMembers teamMemberRecords = TeamMembers.newInstance(new List<Team_Member__c>{ updatedTeamMember });
            teamMemberRecords.onValidate(new Map<Id, Team_Member__c>(new List<Team_Member__c>{ teamMember }));

            Database.saveResult saveResult = Database.update(teamMemberRecords.getRecords(), false)[0];

            Test.stopTest();

            // Then
            List<Database.Error> errors = saveResult.getErrors();

            System.assertEquals(false, saveResult.isSuccess());
            System.assertEquals(1, errors.size());
            System.assertEquals(System.Label.error_duplicate_account_plan_team_member, errors[0].getMessage());
        }
    }

    @isTest
    static void onAfterInsertTest() {
        // Given
        List<Team_Member__c> teamMemberRecords = [SELECT User__c, Account_Plan__c, Role__c FROM Team_Member__c];

        // When
        Test.startTest();

        TeamMembers.newInstance(teamMemberRecords).onAfterInsert();

        Test.stopTest();

        // Then
        List<Account_Plan__Share> accountPlanShares = [
            SELECT AccessLevel, ParentId, UserOrGroupId
            FROM Account_Plan__Share
            WHERE RowCause = :Schema.Account_Plan__Share.RowCause.Account_Plan_Team__c
        ];

        System.assertEquals(3, accountPlanShares.size());
        System.assertEquals(teamMemberRecords[0].User__c, accountPlanShares[0].UserOrGroupId);
        System.assertEquals('Edit', accountPlanShares[0].AccessLevel);
        System.assertEquals(teamMemberRecords[1].User__c, accountPlanShares[1].UserOrGroupId);
        System.assertEquals('Read', accountPlanShares[1].AccessLevel);
        System.assertEquals(teamMemberRecords[2].User__c, accountPlanShares[2].UserOrGroupId);
        System.assertEquals('Read', accountPlanShares[1].AccessLevel);
    }

    @isTest
    static void onAfterUpdateTest() {
        // Given
        List<Team_Member__c> teamMemberRecords = [SELECT User__c, Account_Plan__c, Role__c FROM Team_Member__c];
        List<Team_Member__c> updatedRecords = teamMemberRecords.clone();
        teamMemberRecords[0].Role__c = 'Read Only';
        teamMemberRecords[1].Role__c = 'Edit';
        teamMemberRecords[2].Role__c = 'Edit';

        // When
        Test.startTest();

        TeamMembers.newInstance(updatedRecords).onAfterUpdate(new Map<Id, Team_Member__c>(teamMemberRecords));

        Test.stopTest();

        // Then
        List<Account_Plan__Share> accountPlanShares = [
            SELECT AccessLevel, ParentId, UserOrGroupId
            FROM Account_Plan__Share
            WHERE RowCause = :Schema.Account_Plan__Share.RowCause.Account_Plan_Team__c
        ];

        System.assertEquals(3, accountPlanShares.size());
        System.assertEquals(teamMemberRecords[0].User__c, accountPlanShares[0].UserOrGroupId);
        System.assertEquals('Read', accountPlanShares[0].AccessLevel);
        System.assertEquals(teamMemberRecords[1].User__c, accountPlanShares[1].UserOrGroupId);
        System.assertEquals('Edit', accountPlanShares[1].AccessLevel);
        System.assertEquals(teamMemberRecords[2].User__c, accountPlanShares[2].UserOrGroupId);
        System.assertEquals('Edit', accountPlanShares[1].AccessLevel);
    }

    @isTest
    static void onAfterDeleteTest() {
        // Given
        List<Team_Member__c> teamMemberRecords = [SELECT User__c, Account_Plan__c, Role__c FROM Team_Member__c];

        // When
        Test.startTest();

        TeamMembers.newInstance(teamMemberRecords).onAfterDelete();

        Test.stopTest();

        List<Account_Plan__Share> accountPlanShares = [
            SELECT AccessLevel, ParentId, UserOrGroupId
            FROM Account_Plan__Share
            WHERE RowCause = :Schema.Account_Plan__Share.RowCause.Account_Plan_Team__c
        ];

        System.assertEquals(0, accountPlanShares.size());
    }
}