@isTest
private class AccountPlanControllerTest {
    public static final String STANDARD_USER_FIRST_NAME = 'Manheim';
    public static final String STANDARD_USER_LAST_NAME = 'Visa';

    public static final String CREATOR_USER_FIRST_NAME = 'Shabby';
    public static final String CREATOR_USER_LAST_NAME = 'Break';

    public static final String ADMIN_USER_FIRST_NAME = 'Apple';
    public static final String ADMIN_USER_LAST_NAME = 'Create';

    public static final String ACCOUNT1_NAME = 'Account Test1';
    public static final String ACCOUNT2_NAME = 'Account Test2';

    public static final String ACCOUNT_PLAN1_NAME = 'Account Plan 1';
    public static final String ACCOUNT_PLAN2_NAME = 'Account Plan 2';
    public static final String ACCOUNT_PLAN3_NAME = 'Account Plan 3';
    public static final String ACCOUNT_PLAN4_NAME = 'Account Plan 4';

    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';
    public static final String CRUSH_ACCOUNT_PLAN_CREATOR = 'CRUSH_Account_Plan_Creator';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User standardUser = TestDataFactory.createUser(
            STANDARD_USER_FIRST_NAME,
            STANDARD_USER_LAST_NAME,
            standardProfile.Id
        );
        PermissionSet standardUserPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = :CRUSH_STANDARD_USER
            LIMIT 1
        ];

        User creatorUser = TestDataFactory.createUser(
            CREATOR_USER_FIRST_NAME,
            CREATOR_USER_LAST_NAME,
            standardProfile.Id
        );
        PermissionSet creatorUserPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = :CRUSH_ACCOUNT_PLAN_CREATOR
            LIMIT 1
        ];

        User adminUser = TestDataFactory.createUser(ADMIN_USER_FIRST_NAME, ADMIN_USER_LAST_NAME, standardProfile.Id);
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR LIMIT 1];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = standardUser.Id, PermissionSetId = standardUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = creatorUser.Id, PermissionSetId = creatorUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = adminUserPermissionSet.Id)
        };

        System.runAs(creatorUser) {
            Account testAccount = new Account(Name = ACCOUNT1_NAME);
            insert testAccount;

            Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan(ACCOUNT_PLAN1_NAME, testAccount);
            Account_Plan__c accountPlan2 = TestDataFactory.createAccountPlan(ACCOUNT_PLAN2_NAME, testAccount);

            // standard user can't create account plans so we'll give them edit access to some other ones
            TestDataFactory.createAccountPlanShare(standardUser, accountPlan1, 'Edit', 'Manual');
            TestDataFactory.createAccountPlanShare(standardUser, accountPlan2, 'Edit', 'Manual');
        }

        System.runAs(adminUser) {
            Account testAccount = new Account(Name = ACCOUNT2_NAME);
            insert testAccount;

            TestDataFactory.createAccountPlan(ACCOUNT_PLAN3_NAME, testAccount);
            TestDataFactory.createAccountPlan(ACCOUNT_PLAN4_NAME, testAccount);
        }
    }

    @isTest
    static void checkPlanOverviewUpdateAccessibilityStandardTest() {
        // Given
        User standardUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :STANDARD_USER_FIRST_NAME AND LastName = :STANDARD_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(standardUser) {
            // When
            Test.startTest();

            Boolean adminUpdateAccessibility = AccountPlanController.checkPlanOverviewUpdateAccessibility();

            Test.stopTest();

            // Then
            System.assertEquals(true, adminUpdateAccessibility);
        }
    }

    @isTest
    static void checkPlanOverviewUpdateAccessibilityCreatorTest() {
        // Given
        User creatorUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :CREATOR_USER_FIRST_NAME AND LastName = :CREATOR_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(creatorUser) {
            // When
            Test.startTest();

            Boolean adminUpdateAccessibility = AccountPlanController.checkPlanOverviewUpdateAccessibility();

            Test.stopTest();

            // Then
            System.assertEquals(true, adminUpdateAccessibility);
        }
    }

    @isTest
    static void checkPlanOverviewUpdateAccessibilityAdminTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(adminUser) {
            // When
            Test.startTest();

            Boolean adminUpdateAccessibility = AccountPlanController.checkPlanOverviewUpdateAccessibility();

            Test.stopTest();

            // Then
            System.assertEquals(true, adminUpdateAccessibility);
        }
    }

    @isTest
    static void getUserRecordAccessStandardTest() {
        // Given
        User standardUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :STANDARD_USER_FIRST_NAME AND LastName = :STANDARD_USER_LAST_NAME
            LIMIT 1
        ];
        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
        Account_Plan__c accountPlan3 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN3_NAME];

        System.runAs(standardUser) {
            // When
            Test.startTest();

            UserRecordAccess plan1Access = AccountPlanController.getUserRecordAccess(accountPlan1.Id);
            UserRecordAccess plan3Access = AccountPlanController.getUserRecordAccess(accountPlan3.Id);

            Test.stopTest();

            // Then
            System.assertEquals(false, plan1Access.HasAllAccess);
            System.assertEquals(true, plan1Access.HasReadAccess);
            System.assertEquals(true, plan1Access.HasEditAccess);

            System.assertEquals(false, plan3Access.HasAllAccess);
            System.assertEquals(false, plan3Access.HasReadAccess);
            System.assertEquals(false, plan3Access.HasEditAccess);
        }
    }

    @isTest
    static void getAccountPlansForAccountIdsNoPlansTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AccountPlanSelector mockSelector = (AccountPlanSelector) FFLibHelper.mockSelector(
            AccountPlanSelector.class,
            mocks
        );
        Application.Selector.setMock(mockSelector);

        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<Account_Plan__c> accountPlans = new List<Account_Plan__c>();
        Set<Id> accountIds = new Set<Id>{ accountId };

        mocks.startStubbing();
        mocks.when(mockSelector.selectByAccountIds(accountIds)).thenReturn(accountPlans);
        mocks.stopStubbing();

        List<Account_Plan__c> plans = AccountPlanController.getAccountPlansForAccountIds(new List<Id>{ accountId });

        ((AccountPlanSelector) mocks.verify(mockSelector, 1)).selectByAccountIds(accountIds);
        System.assertEquals(accountPlans, plans, 'Plans should be empty');
    }

    @isTest
    static void getAccountPlansForAccountIdsOnePlanTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AccountPlanSelector mockSelector = (AccountPlanSelector) FFLibHelper.mockSelector(
            AccountPlanSelector.class,
            mocks
        );
        Application.Selector.setMock(mockSelector);

        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account_Plan__c firstPlan = new Account_Plan__c(Id = fflib_IDGenerator.generate(Account_Plan__c.SObjectType));
        List<Account_Plan__c> accountPlans = new List<Account_Plan__c>{ firstPlan };
        Set<Id> accountIds = new Set<Id>{ accountId };

        mocks.startStubbing();
        mocks.when(mockSelector.selectByAccountIds(accountIds)).thenReturn(accountPlans);
        mocks.stopStubbing();

        List<Account_Plan__c> plans = AccountPlanController.getAccountPlansForAccountIds(new List<Id>{ accountId });

        ((AccountPlanSelector) mocks.verify(mockSelector, 1)).selectByAccountIds(accountIds);
        System.assertEquals(accountPlans, plans, 'Plans should match expected');
    }

    @isTest
    static void getAccountPlansForAccountIdsMultiplePlanTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AccountPlanSelector mockSelector = (AccountPlanSelector) FFLibHelper.mockSelector(
            AccountPlanSelector.class,
            mocks
        );
        Application.Selector.setMock(mockSelector);

        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account_Plan__c firstPlan = new Account_Plan__c(Id = fflib_IDGenerator.generate(Account_Plan__c.SObjectType));
        List<Account_Plan__c> accountPlans = new List<Account_Plan__c>{ firstPlan };
        for (Integer i = 0; i < 20; i++) {
            accountPlans.add(new Account_Plan__c(Id = fflib_IDGenerator.generate(Account_Plan__c.SObjectType)));
        }
        Set<Id> accountIds = new Set<Id>{ accountId };

        mocks.startStubbing();
        mocks.when(mockSelector.selectByAccountIds(accountIds)).thenReturn(accountPlans);
        mocks.stopStubbing();

        List<Account_Plan__c> plans = AccountPlanController.getAccountPlansForAccountIds(new List<Id>{ accountId });

        ((AccountPlanSelector) mocks.verify(mockSelector, 1)).selectByAccountIds(accountIds);
        System.assertEquals(accountPlans, plans, 'Plans should match expected');
    }

    @isTest
    static void getAccountPlanByIdStandardTest() {
        // Given
        User standardUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :STANDARD_USER_FIRST_NAME AND LastName = :STANDARD_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(standardUser) {
            Id accountPlanId = [SELECT Id FROM Account_Plan__c LIMIT 1].Id;

            // When
            Test.startTest();

            Account_Plan__c nullAccountPlan = AccountPlanController.getAccountPlanById(null);
            Account_Plan__c accountPlan = AccountPlanController.getAccountPlanById(accountPlanId);

            Test.stopTest();

            // Then
            System.assertEquals(null, nullAccountPlan);

            System.assertNotEquals(null, accountPlan);
            System.assertEquals(accountPlanId, accountPlan.Id);
        }
    }

    @isTest
    static void getAccountPlanByIdCreatorTest() {
        // Given
        User creatorUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :CREATOR_USER_FIRST_NAME AND LastName = :CREATOR_USER_LAST_NAME
            LIMIT 1
        ];

        Id accountPlanId = [SELECT Id FROM Account_Plan__c WHERE OwnerId = :creatorUser.Id LIMIT 1].Id;

        System.runAs(creatorUser) {
            // When
            Test.startTest();

            Account_Plan__c nullAccountPlan = AccountPlanController.getAccountPlanById(null);
            Account_Plan__c accountPlan = AccountPlanController.getAccountPlanById(accountPlanId);

            Test.stopTest();

            // Then
            System.assertEquals(null, nullAccountPlan);

            System.assertNotEquals(null, accountPlan);
            System.assertEquals(accountPlanId, accountPlan.Id);
        }
    }

    @isTest
    static void getAccountPlanByIdAdminTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        Id accountPlanId = [SELECT Id FROM Account_Plan__c WHERE OwnerId = :adminUser.Id LIMIT 1].Id;

        System.runAs(adminUser) {
            // When
            Test.startTest();

            Account_Plan__c nullAccountPlan = AccountPlanController.getAccountPlanById(null);
            Account_Plan__c accountPlan = AccountPlanController.getAccountPlanById(accountPlanId);

            Test.stopTest();

            // Then
            System.assertEquals(null, nullAccountPlan);

            System.assertNotEquals(null, accountPlan);
            System.assertEquals(accountPlanId, accountPlan.Id);
        }
    }

    @isTest
    static void upsertAccountPlanStandardTest() {
        // Given
        String planOverviewTitle = 'Little';
        String planOverview = 'This stops right now';

        User standardUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :STANDARD_USER_FIRST_NAME AND LastName = :STANDARD_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(standardUser) {
            Id accountPlanId = [SELECT Id FROM Account_Plan__c LIMIT 1].Id;

            // When
            Test.startTest();

            Account_Plan__c accountPlan = AccountPlanController.upsertAccountPlan(
                accountPlanId,
                planOverviewTitle,
                planOverview
            );

            Test.stopTest();

            // Then
            System.assertNotEquals(null, accountPlan);
            System.assertEquals(accountPlan.Plan_Overview_Title__c, planOverviewTitle);
            System.assertEquals(accountPlan.Plan_Overview__c, planOverview);
        }
    }

    @isTest
    static void upsertAccountPlanCreatorTest() {
        // Given
        String planOverviewTitle = 'Little';
        String planOverview = 'This stops right now';

        User creatorUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :CREATOR_USER_FIRST_NAME AND LastName = :CREATOR_USER_LAST_NAME
            LIMIT 1
        ];

        Id accountPlanId = [SELECT Id FROM Account_Plan__c WHERE OwnerId = :creatorUser.Id LIMIT 1].Id;

        System.runAs(creatorUser) {
            // When
            Test.startTest();

            Account_Plan__c accountPlan = AccountPlanController.upsertAccountPlan(
                accountPlanId,
                planOverviewTitle,
                planOverview
            );

            Test.stopTest();

            // Then
            System.assertNotEquals(null, accountPlan);
            System.assertEquals(accountPlan.Plan_Overview_Title__c, planOverviewTitle);
            System.assertEquals(accountPlan.Plan_Overview__c, planOverview);
        }
    }

    @isTest
    static void upsertAccountPlanAdminTest() {
        // Given
        String planOverviewTitle = 'Little';
        String planOverview = 'This stops right now';

        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        Id accountPlanId = [SELECT Id FROM Account_Plan__c WHERE OwnerId = :adminUser.Id LIMIT 1].Id;

        System.runAs(adminUser) {
            // When
            Test.startTest();

            Account_Plan__c accountPlan = AccountPlanController.upsertAccountPlan(
                accountPlanId,
                planOverviewTitle,
                planOverview
            );

            Test.stopTest();

            // Then
            System.assertNotEquals(null, accountPlan);
            System.assertEquals(accountPlan.Plan_Overview_Title__c, planOverviewTitle);
            System.assertEquals(accountPlan.Plan_Overview__c, planOverview);
        }
    }

    @isTest
    static void recordAccessForAccountPlansTest() {
        // Given
        User standardUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :STANDARD_USER_FIRST_NAME AND LastName = :STANDARD_USER_LAST_NAME
            LIMIT 1
        ];
        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
        Account_Plan__c accountPlan3 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN3_NAME];

        List<Account_Plan__c> planList = new List<Account_Plan__c>{ accountPlan1, accountPlan3 };

        System.runAs(standardUser) {
            // When
            Test.startTest();

            Map<Id, UserRecordAccess> planAccessMap = AccountPlanController.recordAccessForAccountPlans(planList);

            Test.stopTest();

            // Then
            System.assertEquals(false, planAccessMap.get(accountPlan1.Id).HasAllAccess);
            System.assertEquals(true, planAccessMap.get(accountPlan1.Id).HasReadAccess);
            System.assertEquals(true, planAccessMap.get(accountPlan1.Id).HasEditAccess);

            System.assertEquals(false, planAccessMap.get(accountPlan3.Id).HasAllAccess);
            System.assertEquals(false, planAccessMap.get(accountPlan3.Id).HasReadAccess);
            System.assertEquals(false, planAccessMap.get(accountPlan3.Id).HasEditAccess);
        }
    }

    @isTest
    static void getRelationshipMapsByAccountPlanTest() {
        Account_Plan__c plan1 = TestDataFactory.createAccountPlan('rmst_sbapnt_test_1');
        TestDataFactory.createRelationshipMap('mapname', plan1.Id);
        TestDataFactory.createRelationshipMap('mapname', plan1.Id);
        TestDataFactory.createRelationshipMap('mapname');

        // When
        List<Relationship_Map__c> whiteSpaces = AccountPlanController.getRelationshipMapsByAccountPlan(plan1.Id);

        // Then
        System.assertEquals(2, whiteSpaces.size());
    }
}