@isTest
private class AccountPlanSelectorTest {
    public static final String ADMIN_USER1_FIRST_NAME = 'AmyAdmin1';
    public static final String ADMIN_USER1_LAST_NAME = 'Arlie';

    public static final String ADMIN_USER2_FIRST_NAME = 'AaronAdmin2';
    public static final String ADMIN_USER2_LAST_NAME = 'Amber';

    public static final String STANDARD_USER1_FIRST_NAME = 'SamStandard';
    public static final String STANDARD_USER1_LAST_NAME = 'Sunlock';

    public static final String ACCOUNT_PLAN1_NAME = 'Account Plan 1';
    public static final String ACCOUNT_PLAN2_NAME = 'Account Plan 2';
    public static final String ACCOUNT_PLAN3_NAME = 'Account Plan 3';
    public static final String ACCOUNT_PLANCLOSED_NAME = 'Account Plan Closed';

    public static final String ACCOUNT1_NAME = 'Account Test1';
    public static final String ACCOUNT2_NAME = 'Account Test2';

    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';
    public static final String CRUSH_MASTERACCOUNTPLAN = 'CRUSH_Master_Account_Plan_User';
    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User adminUser1 = TestDataFactory.createUser(ADMIN_USER1_FIRST_NAME, ADMIN_USER1_LAST_NAME, standardProfile.Id);
        User adminUser2 = TestDataFactory.createUser(ADMIN_USER2_FIRST_NAME, ADMIN_USER2_LAST_NAME, standardProfile.Id);
        User standardUser1 = TestDataFactory.createUser(
            STANDARD_USER1_FIRST_NAME,
            STANDARD_USER1_LAST_NAME,
            standardProfile.Id
        );

        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];
        PermissionSet masterAccountPlanPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_MASTERACCOUNTPLAN];
        PermissionSet standardUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_STANDARD_USER];

        // Assigning two users with the admin perm set and one user with the standard perm set
        List<PermissionSetAssignment> permissionSets = new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = adminUser1.Id, PermissionSetId = adminUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = adminUser1.Id, PermissionSetId = masterAccountPlanPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = adminUser2.Id, PermissionSetId = adminUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = standardUser1.Id, PermissionSetId = standardUserPermissionSet.Id)
        };

        Id systemUserId = UserInfo.getUserId();
        PermissionSetAssignment systemCrushAdminPermissions = TestDataFactory.createPermissionSetAssignment(
            systemUserId,
            adminUserPermissionSet.Id
        );
        PermissionSetAssignment masterAccountPlanPermission = TestDataFactory.createPermissionSetAssignment(
            systemUserId,
            adminUserPermissionSet.Id
        );

        if (systemCrushAdminPermissions != null && !permissionSets.contains(systemCrushAdminPermissions)) {
            permissionSets.add(systemCrushAdminPermissions);
        }

        if (masterAccountPlanPermission != null && !permissionSets.contains(masterAccountPlanPermission)) {
            permissionSets.add(masterAccountPlanPermission);
        }
        insert permissionSets;

        // Disabling triggers as this class should not be testing them
        Application.bypassTrigger = true;

        // Creating one account plan with adminUser1 and sharing it to standardUser1
        System.runAs(adminUser1) {
            Account testAccount1 = new Account(Name = ACCOUNT1_NAME);
            insert testAccount1;

            AccountPlans.bypassEmailTrigger = true;
            Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan(ACCOUNT_PLAN1_NAME, testAccount1);

            TestDataFactory.createAccountPlanShare(standardUser1, accountPlan1, 'Edit', 'Manual');
        }

        // Creating two additional account plans with adminUser2 without sharing them to any other users
        System.runAs(adminUser2) {
            Account testAccount2 = new Account(Name = ACCOUNT2_NAME);
            insert testAccount2;

            TestDataFactory.createAccountPlan(ACCOUNT_PLAN2_NAME, testAccount2);
            TestDataFactory.createAccountPlan(ACCOUNT_PLAN3_NAME, testAccount2);
            TestDataFactory.createAccountPlan(ACCOUNT_PLANCLOSED_NAME, testAccount2, 'Closed');
        }

    }

    @isTest
    static void newInstanceTest() {
        AccountPlanSelector selector = AccountPlanSelector.newInstance();

        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        // Given a user with the admin perm set and a user with the standard perm set
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        User standardUser1 = [SELECT Id FROM User WHERE LastName = :STANDARD_USER1_LAST_NAME];
        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
        Account_Plan__c accountPlan2 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME];
        Account_Plan__c accountPlan3 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN3_NAME];
        Set<Id> accountPlanIds = new Set<Id>{ accountPlan1.Id, accountPlan2.Id, accountPlan3.Id };

        // When each user requests all three account plans
        Test.startTest();

        List<Account_Plan__c> accountPlansForAdminUser1;
        List<Account_Plan__c> accountPlansForStandardUser1;

        System.runAs(adminUser1) {
            accountPlansForAdminUser1 = new AccountPlanSelector().selectById(accountPlanIds);
        }

        System.runAs(standardUser1) {
            accountPlansForStandardUser1 = new AccountPlanSelector().selectById(accountPlanIds);
        }

        Test.stopTest();

        // Then the admin user should get back all three account plans
        System.assertEquals(3, accountPlansForAdminUser1.size());
        for (Account_Plan__c accountPlan : accountPlansForAdminUser1) {
            System.assert(accountPlanIds.contains(accountPlan.Id));
        }

        // And the standard user should only get back the account plan that was shared to them
        System.assertEquals(1, accountPlansForStandardUser1.size());
        System.assertEquals(accountPlan1.Id, accountPlansForStandardUser1[0].Id);
    }

    @isTest
    static void selectByClosedStatusTest() {
        // Given a user
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
        Account_Plan__c accountPlan2 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME];
        Account_Plan__c accountPlan3 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN3_NAME];
        Account_Plan__c accountPlanClosed = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLANCLOSED_NAME];
        Set<Id> accountPlanIds = new Set<Id>{ accountPlan1.Id, accountPlan2.Id, accountPlan3.Id, accountPlanClosed.Id };

        Test.startTest();
        List<Account_Plan__c> accountPlansForUser1;
        System.runAs(adminUser1) {
            accountPlansForUser1 = new AccountPlanSelector().selectClosedPlansById(accountPlanIds);
        }
        Test.stopTest();

        System.assertEquals(1, accountPlansForUser1.size());
        System.assertEquals('Closed', accountPlansForUser1[0].status__c);
    }

    @isTest
    static void selectByIdAsSystemTest() {
        // Given a standard user with only one plan shared to them
        User standardUser1 = [SELECT Id FROM User WHERE LastName = :STANDARD_USER1_LAST_NAME];
        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
        Account_Plan__c accountPlan2 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME];
        Account_Plan__c accountPlan3 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN3_NAME];

        Set<Id> accountPlanIds = new Set<Id>{ accountPlan1.Id, accountPlan2.Id, accountPlan3.Id };

        // When selectByIdAsSystem is called with the user
        Test.startTest();

        List<Account_Plan__c> accountPlans;

        System.runAs(standardUser1) {
            accountPlans = new AccountPlanSelector().selectByIdAsSystem(accountPlanIds);
        }
        Test.stopTest();
        // Then the user should get back all three account plans regardless of sharing rules
        System.assertNotEquals(3, accountPlans.size());

        for (Account_Plan__c accountPlan : accountPlans) {
            System.assert(accountPlanIds.contains(accountPlan.Id));
        }
    }

    @isTest
    static void selectByAccountIdsStandardUserTest() {
        User standardUser1 = [SELECT Id FROM User WHERE LastName = :STANDARD_USER1_LAST_NAME];
        Account account1 = [SELECT Id FROM Account WHERE Name = :ACCOUNT1_NAME];
        Account account2 = [SELECT Id FROM Account WHERE Name = :ACCOUNT2_NAME];
        System.runAs(standardUser1) {
            List<Account_Plan__c> plans = AccountPlanSelector.newInstance()
                .selectByAccountIds(new Set<Id>{ account1.Id });
            System.assertEquals(
                1,
                plans.size(),
                'Standard user should have access to the plans they\'ve been added to'
            );

            plans = AccountPlanSelector.newInstance().selectByAccountIds(new Set<Id>{ account2.Id });
            System.assertEquals(
                0,
                plans.size(),
                'Standard user should have access to the plans they\'ve been added to'
            );

            plans = AccountPlanSelector.newInstance().selectByAccountIds(new Set<Id>{ account1.Id, account2.Id });
            System.assertEquals(
                1,
                plans.size(),
                'Standard user should have access to the plans they\'ve been added to'
            );
        }
    }

    @isTest
    static void selectByAccountIdsAdminUserTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        Account account1 = [SELECT Id FROM Account WHERE Name = :ACCOUNT1_NAME];
        Account account2 = [SELECT Id FROM Account WHERE Name = :ACCOUNT2_NAME];
        System.runAs(adminUser1) {
            List<Account_Plan__c> plans = AccountPlanSelector.newInstance()
                .selectByAccountIds(new Set<Id>{ account1.Id });
            System.assertEquals(1, plans.size(), 'Admin user should have access to all plans');

            plans = AccountPlanSelector.newInstance().selectByAccountIds(new Set<Id>{ account2.Id });
            System.assertEquals(3, plans.size(), 'Admin user should have access to all plans');

            plans = AccountPlanSelector.newInstance().selectByAccountIds(new Set<Id>{ account1.Id, account2.Id });
            System.assertEquals(4, plans.size(), 'Admin user should have access to all plans');
        }
    }

    @isTest
    static void selectByIdWithTeamMembersTest() {
        // Given
        User teamMember1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        User teamMember2 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER2_LAST_NAME];
        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
        Account_Plan__c accountPlan2 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME];

        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(systemUser) {
            TestDataFactory.createTeamMember(teamMember2, accountPlan1, 'Read Only');
            TestDataFactory.createTeamMember(teamMember1, accountPlan2, 'Read Only');
            // When
            List<Account_Plan__c> plan1WithMembers = AccountPlanSelector.newInstance()
                .selectByIdWithTeamMembers(new Set<Id>{ accountPlan1.Id });
            List<Account_Plan__c> plan2WithMembers = AccountPlanSelector.newInstance()
                .selectByIdWithTeamMembers(new Set<Id>{ accountPlan2.Id });

            // Then
            System.assertEquals(1, plan1WithMembers.size());
            System.assertEquals(accountPlan1.Id, plan1WithMembers[0].Id);
            System.assertEquals(1, plan2WithMembers.size());
            System.assertEquals(accountPlan2.Id, plan2WithMembers[0].Id);

            List<Team_Member__c> plan1Members = plan1WithMembers[0].Team_Members__r;
            List<Team_Member__c> plan2Members = plan2WithMembers[0].Team_Members__r;

            System.assertEquals(1, plan1Members.size());
            System.assertEquals(1, plan2Members.size());
        }
    }

    @isTest
    static void selectByOwnerIdTest() {
        // Given adminUser1 that owns an account plan and standardUser1 that does not own any account plans
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        User standardUser1 = [SELECT Id FROM User WHERE LastName = :STANDARD_USER1_LAST_NAME];
        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];

        // When each user requests for accounts plans that they own
        List<Account_Plan__c> accountPlansOwnedByAdminUser1 = AccountPlanSelector.newInstance()
            .selectByOwnerIdAsSystem(new Set<Id>{ adminUser1.Id });
        List<Account_Plan__c> accountPlansOwnedByStandardUser1 = AccountPlanSelector.newInstance()
            .selectByOwnerIdAsSystem(new Set<Id>{ standardUser1.Id });

        // Then adminUser1 should get back the account plan that they own
        System.assertEquals(1, accountPlansOwnedByAdminUser1.size());
        System.assertEquals(accountPlan1.Id, accountPlansOwnedByAdminUser1[0].Id);

        // And standardUser1 should not get back any account plans
        System.assertEquals(0, accountPlansOwnedByStandardUser1.size());
    }

    @isTest
    static void selectByIdWithAccountAndOwnerTest() {
        // Given a user with the admin perm set
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];

        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
        Account_Plan__c accountPlan2 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME];

        Set<Id> accountPlanIds = new Set<Id>{ accountPlan1.Id, accountPlan2.Id };

        // When the user requests account plans
        Test.startTest();

        List<Account_Plan__c> accountPlansForAdminUser1;

        System.runAs(adminUser1) {
            accountPlansForAdminUser1 = new AccountPlanSelector().selectByIdWithAccountAndOwner(accountPlanIds);
        }

        Test.stopTest();

        // Then they should get back the account plans, each with Account Name and Account Owner fields populated
        System.assertEquals(2, accountPlansForAdminUser1.size());
        System.assertEquals(ACCOUNT1_NAME, accountPlansForAdminUser1[0].Account__r.Name);
        System.assertEquals(ACCOUNT2_NAME, accountPlansForAdminUser1[1].Account__r.Name);
    }

    @isTest
    static void selectByIdWithAccountAndOwnerAndMasterAccountPlanTest() {
        // Given a user with the admin perm set
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];

        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
        Account_Plan__c accountPlan2 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME];

        pq_Master_Account_Plan__c m = new pq_Master_Account_Plan__c(Name = 'test');
        Set<Id> accountPlanIds = new Set<Id>{ accountPlan1.Id, accountPlan2.Id };

        // When the user requests account plans
        Test.startTest();

        List<Account_Plan__c> accountPlansForAdminUser1;

        System.runAs(adminUser1) {
            accountPlansForAdminUser1 = new AccountPlanSelector().selectByIdWithAccountAndOwnerAndMasterAccountPlan(accountPlanIds, m.Id);
        }

        Test.stopTest();

        // Then they should get back the account plans, each with Account Name and Account Owner fields populated
        System.assertEquals(2, accountPlansForAdminUser1.size());
        System.assertEquals(ACCOUNT1_NAME, accountPlansForAdminUser1[0].Account__r.Name);
        System.assertEquals(ACCOUNT2_NAME, accountPlansForAdminUser1[1].Account__r.Name);
    }
}