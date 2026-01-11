@isTest
private class KeyStakeholdersTest {
    private static final String ACCOUNT_PLAN_NAME = 'Account Plan 1';
    private static final String FIRST_CONTACT_LAST_NAME = 'Sonic';
    private static final String SECOND_CONTACT_LAST_NAME = 'Flash';

    public static final String CREATOR_USER_FIRST_NAME = 'Billy';
    public static final String CREATOR_USER_LAST_NAME = 'Beans';

    public static final String CRUSH_ACCOUNT_PLAN_CREATOR = 'CRUSH_Account_Plan_Creator';

    public static final String STANDARD_USER = 'Standard User';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];

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

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = creatorUser.Id, PermissionSetId = creatorUserPermissionSet.Id)
        };

        System.runAs(creatorUser) {
            Account testAccount = new Account(Name = 'Account 1');
            insert testAccount;

            Contact testContact1 = new Contact(LastName = FIRST_CONTACT_LAST_NAME);
            insert testContact1;

            Contact testContact2 = new Contact(LastName = SECOND_CONTACT_LAST_NAME);
            insert testContact2;

            Account_Plan__c accountPlan = TestDataFactory.createAccountPlan(ACCOUNT_PLAN_NAME, testAccount);
            TestDataFactory.createKeyStakeholder(accountPlan, testContact1);
            TestDataFactory.createKeyStakeholder(accountPlan, testContact2);
        }
    }

    @isTest
    static void constructorTest() {
        System.assertNotEquals(null, new KeyStakeholders(new List<Key_Stakeholder__c>()));
        System.assertEquals(
            false,
            new KeyStakeholders(new List<Key_Stakeholder__c>()).Configuration.EnforcingTriggerCRUDSecurity,
            'Should not be enforcing Trigger CRUD Security due to complications with automation in customer orgs'
        );
    }

    @isTest
    static void getUniqueKeyTest() {
        // Given
        User creatorUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :CREATOR_USER_FIRST_NAME AND LastName = :CREATOR_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(creatorUser) {
            // Given
            Key_Stakeholder__c stakeholder = [SELECT Id, Contact__c, Account_Plan__c FROM Key_Stakeholder__c][0];

            // When
            Test.startTest();

            String uniqueKey = KeyStakeholders.getUniqueKey(stakeholder);

            Test.stopTest();

            // Then
            String expectedValue = String.valueOf(stakeholder.Account_Plan__c) + String.valueOf(stakeholder.Contact__c);
            System.assertEquals(expectedValue, uniqueKey);
        }
    }

    @isTest
    static void onValidateInsertTest() {
        // Given
        User creatorUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :CREATOR_USER_FIRST_NAME AND LastName = :CREATOR_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(creatorUser) {
            // Given
            Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN_NAME];
            Contact testContact = [SELECT Id FROM Contact WHERE LastName = :FIRST_CONTACT_LAST_NAME];

            Key_Stakeholder__c duplicateStakeholder = new Key_Stakeholder__c(
                Account_Plan__c = accountPlan.Id,
                Contact__c = testContact.Id,
                Influence__c = 'High',
                Support__c = 'Floater'
            );

            // When
            Test.startTest();

            KeyStakeholders stakeholderRecords = KeyStakeholders.newInstance(
                new List<Key_Stakeholder__c>{ duplicateStakeholder }
            );
            stakeholderRecords.onValidate();
            Database.saveResult saveResult = Database.insert(stakeholderRecords.getRecords(), false)[0];

            Test.stopTest();

            // Then
            List<Database.Error> errors = saveResult.getErrors();

            System.assertEquals(false, saveResult.isSuccess());
            System.assertEquals(1, errors.size());
            System.assertEquals(System.Label.error_duplicate_account_plan_key_stakeholder, errors[0].getMessage());
        }
    }

    @isTest
    static void onValidateUpdateTest() {
        // Given
        User creatorUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :CREATOR_USER_FIRST_NAME AND LastName = :CREATOR_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(creatorUser) {
            // Given
            Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN_NAME];
            Contact testContact1 = [SELECT Id FROM Contact WHERE LastName = :FIRST_CONTACT_LAST_NAME];
            Contact testContact2 = [SELECT Id FROM Contact WHERE LastName = :SECOND_CONTACT_LAST_NAME];
            Key_Stakeholder__c stakeholder = [
                SELECT Id, Account_Plan__c
                FROM Key_Stakeholder__c
                WHERE Account_Plan__c = :accountPlan.Id AND Contact__c = :testContact1.Id
            ];

            // When
            Test.startTest();

            Key_Stakeholder__c updatedStakeholder = stakeholder.clone(true, false, true, false); // preserve Id and read-only fields
            updatedStakeholder.Contact__c = testContact2.Id;

            KeyStakeholders stakeholderRecords = KeyStakeholders.newInstance(
                new List<Key_Stakeholder__c>{ updatedStakeholder }
            );
            stakeholderRecords.onValidate(new Map<Id, Key_Stakeholder__c>(new List<Key_Stakeholder__c>{ stakeholder }));

            Database.saveResult saveResult = Database.update(stakeholderRecords.getRecords(), false)[0];

            Test.stopTest();

            // Then
            List<Database.Error> errors = saveResult.getErrors();

            System.assertEquals(false, saveResult.isSuccess());
            System.assertEquals(1, errors.size());
            System.assertEquals(System.Label.error_duplicate_account_plan_key_stakeholder, errors[0].getMessage());
        }
    }
}