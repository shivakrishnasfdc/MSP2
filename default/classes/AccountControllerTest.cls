@isTest
private class AccountControllerTest {
    public static final String STANDARD_USER_FIRST_NAME = 'Alex';
    public static final String STANDARD_USER_LAST_NAME = 'Allen';

    public static final String CREATOR_USER_FIRST_NAME = 'Billy';
    public static final String CREATOR_USER_LAST_NAME = 'Beans';

    public static final String ADMIN_USER_FIRST_NAME = 'Crispy';
    public static final String ADMIN_USER_LAST_NAME = 'Creme';

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

        System.runAs(standardUser) {
            Account testAccount = new Account(Name = 'Account 1');
            insert testAccount;
        }

        System.runAs(creatorUser) {
            AccountPlans.bypassEmailTrigger = true;

            Account testAccount = new Account(Name = 'Account 1');
            insert testAccount;

            Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan('Account Plan 1', testAccount);
            Account_Plan__c accountPlan2 = TestDataFactory.createAccountPlan('Account Plan 2', testAccount);

            // standard user can't create account plans so we'll give them edit access to some other ones
            TestDataFactory.createAccountPlanShare(standardUser, accountPlan1, 'Edit', 'Manual');
            TestDataFactory.createAccountPlanShare(standardUser, accountPlan2, 'Edit', 'Manual');
        }

        System.runAs(adminUser) {
            AccountPlans.bypassEmailTrigger = true;

            Account testAccount = new Account(Name = 'Account 1');
            insert testAccount;

            TestDataFactory.createAccountPlan('Account Plan 1', testAccount);
            TestDataFactory.createAccountPlan('Account Plan 2', testAccount);
        }
    }

    @isTest
    static void getAccountByAccountPlanIdStandardTest() {
        // Given
        User standardUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :STANDARD_USER_FIRST_NAME AND LastName = :STANDARD_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(standardUser) {
            Account_Plan__c accountPlan = [SELECT Id, Account__c FROM Account_Plan__c LIMIT 1];

            // When
            Test.startTest();

            Account nullAccount = AccountController.getAccountByAccountPlanId(null);
            Account account = AccountController.getAccountByAccountPlanId(accountPlan.Id);

            Test.stopTest();

            // Then
            System.assertEquals(null, nullAccount);

            System.assertNotEquals(null, account);
            System.assertEquals(accountPlan.Account__c, account.Id);
        }
    }

    @isTest
    static void getAccountByIdStandardTest() {
        // Given
        User standardUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :STANDARD_USER_FIRST_NAME AND LastName = :STANDARD_USER_LAST_NAME
            LIMIT 1
        ];

        Id accountId = [SELECT Id FROM Account WHERE OwnerId = :standardUser.Id LIMIT 1].Id;

        System.runAs(standardUser) {
            // When
            Test.startTest();

            Account nullAccount = AccountController.getAccountById(null);
            Account account = AccountController.getAccountById(accountId);

            Test.stopTest();

            // Then
            System.assertEquals(null, nullAccount);

            System.assertNotEquals(null, account);
            System.assertEquals(accountId, account.Id);
        }
    }

    @isTest
    static void upsertAccountPlanStandardTest() {
        // Given
        User standardUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :STANDARD_USER_FIRST_NAME AND LastName = :STANDARD_USER_LAST_NAME
            LIMIT 1
        ];

        Account newAccount = [SELECT Id FROM Account WHERE OwnerId = :standardUser.Id LIMIT 1];

        newAccount.Name = 'test';
        newAccount.Type = 'Prospect';
        newAccount.Ownership = 'Public';
        newAccount.Industry = 'Communications';
        newAccount.AnnualRevenue = 20.0;

        System.runAs(standardUser) {
            // When
            Test.startTest();

            Account account = AccountController.upsertAccount(newAccount);

            Test.stopTest();

            // Then
            System.assertNotEquals(null, account);
            System.assertEquals(newAccount.Name, account.Name);
            System.assertEquals(newAccount.Type, account.Type);
            System.assertEquals(newAccount.Ownership, account.Ownership);
            System.assertEquals(newAccount.Industry, account.Industry);
            System.assertEquals(newAccount.AnnualRevenue, account.AnnualRevenue);
        }
    }

    @isTest
    static void getAccountDescribeFieldsTest() {
        // Given
        User standardUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :STANDARD_USER_FIRST_NAME AND LastName = :STANDARD_USER_LAST_NAME
            LIMIT 1
        ];

        List<String> fieldsToCheck = new List<String>();
        fieldsToCheck.add('AnnualRevenue');
        fieldsToCheck.add('Type');
        fieldsToCheck.add('Name');
        fieldsToCheck.add('Ownership');
        fieldsToCheck.add('Industry');

        System.runAs(standardUser) {
            // When
            Test.startTest();

            String jsonStr = AccountController.getAccountDescribeFields(fieldsToCheck);

            Test.stopTest();

            // Then
            JSONParser parser = JSON.createParser(jsonStr);
            List<DescribeObject> describeObjects = new List<DescribeObject>();
            while (parser.nextToken() != null) {
                // Start at the array of DescribeObjects.
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            describeObjects.add((DescribeObject) parser.readValueAs(DescribeObject.class));
                            parser.skipChildren();
                        }
                    }
                }
            }

            System.assertEquals(5, describeObjects.size());
        }
    }
}