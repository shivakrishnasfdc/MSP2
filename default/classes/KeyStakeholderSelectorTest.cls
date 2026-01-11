@isTest
private class KeyStakeholderSelectorTest {
    private static final String ACCOUNT_PLAN_NAME = 'Account Plan 1';
    private static final String CONTACT_LAST_NAME = 'Sonic';

    public static final String CREATOR_USER_FIRST_NAME = 'Billy';
    public static final String CREATOR_USER_LAST_NAME = 'Beans';

    public static final String NO_PREMISSION_USER_FIRST_NAME = 'chms test no perm user first';
    public static final String NO_PREMISSION_USER_LAST_NAME = 'chms test no perm user last';

    public static final String CRUSH_ACCOUNT_PLAN_CREATOR = 'CRUSH_Account_Plan_Creator';

    public static final String STANDARD_USER = 'Standard User';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];

        TestDataFactory.createUser(NO_PREMISSION_USER_FIRST_NAME, NO_PREMISSION_USER_LAST_NAME, standardProfile.Id);

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

            Contact testContact = new Contact(LastName = CONTACT_LAST_NAME, Title = 'CEO');
            insert testContact;

            Account_Plan__c accountPlan = TestDataFactory.createAccountPlan(ACCOUNT_PLAN_NAME, testAccount);
            TestDataFactory.createKeyStakeholder(accountPlan, testContact);
        }
    }

    @isTest
    static void selectByIdTest() {
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
            Contact testContact = [SELECT Id FROM Contact WHERE LastName = :CONTACT_LAST_NAME];
            Key_Stakeholder__c stakeholder = [
                SELECT Id, Contact__c, Account_Plan__c
                FROM Key_Stakeholder__c
                WHERE Account_Plan__c = :accountPlan.Id AND Contact__c = :testContact.Id
            ];

            // When
            Test.startTest();

            List<Key_Stakeholder__c> retrievedKeystakeholders = KeyStakeholderSelector.newInstance()
                .selectById(new Set<Id>{ stakeholder.Id });

            Test.stopTest();

            // Then
            System.assertEquals(1, retrievedKeystakeholders.size());
            System.assertEquals(stakeholder.Id, retrievedKeystakeholders.get(0).Id);
            System.assertEquals(stakeholder.Account_Plan__c, retrievedKeystakeholders.get(0).Account_Plan__c);
            System.assertEquals(stakeholder.Contact__c, retrievedKeystakeholders.get(0).Contact__c);
        }
    }

    /********************
     *** selectByContactId() ***
     *******************/

    @isTest
    static void selectByContactIdNullTest() {
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

            List<Key_Stakeholder__c> result = KeyStakeholderSelector.newInstance().selectByContactId(null);

            Test.stopTest();

            // Then
            System.assertEquals(0, result.size());
        }
    }

    @isTest
    static void selectByContactIdEmptyTest() {
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

            List<Key_Stakeholder__c> result = KeyStakeholderSelector.newInstance().selectByContactId(new Set<Id>());

            Test.stopTest();

            // Then
            System.assertEquals(0, result.size());
        }
    }

    @isTest
    static void selectByContactIdValidNoPermTest() {
        // Given
        User noPermUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :NO_PREMISSION_USER_FIRST_NAME AND LastName = :NO_PREMISSION_USER_LAST_NAME
            LIMIT 1
        ];

        // Given
        Contact contact = [SELECT Id FROM Contact WHERE LastName = :CONTACT_LAST_NAME];

        System.runAs(noPermUser) {
            // When
            Test.startTest();
            try {
                KeyStakeholderSelector.newInstance().selectByContactId(new Set<Id>{ contact.Id });
                System.assert(false, 'Should throw a access denied error');
            } catch (Exception e) {
                System.assert(true, 'Should throw a access denied error');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void selectByContactIdValidTest() {
        // Given
        User creatorUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :CREATOR_USER_FIRST_NAME AND LastName = :CREATOR_USER_LAST_NAME
            LIMIT 1
        ];

        Contact contact = [SELECT Id FROM Contact WHERE LastName = :CONTACT_LAST_NAME];

        System.runAs(creatorUser) {
            // When
            Test.startTest();

            List<Key_Stakeholder__c> result = KeyStakeholderSelector.newInstance()
                .selectByContactId(new Set<Id>{ contact.Id });

            Test.stopTest();

            // Then
            System.assertEquals(1, result.size());
        }
    }

    @isTest
    static void selectByIdOrContactIdAndPlanIdTest1() {
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
            Contact testContact = [SELECT Id, Title FROM Contact WHERE LastName = :CONTACT_LAST_NAME];
            Key_Stakeholder__c stakeholder = [
                SELECT Id, Contact__c, Contact__r.Title, Account_Plan__c
                FROM Key_Stakeholder__c
                WHERE Account_Plan__c = :accountPlan.Id AND Contact__c = :testContact.Id
            ];

            // When
            Test.startTest();

            List<Key_Stakeholder__c> retrievedKeystakeholders = KeyStakeholderSelector.newInstance()
                .selectByIdOrContactIdAndPlanId(
                    new Set<Id>{ stakeholder.Id },
                    accountPlan.Id,
                    new Set<String>(),
                    new Set<String>{ 'Title' }
                );

            Test.stopTest();

            // Then
            System.assertEquals(1, retrievedKeystakeholders.size());
            System.assertEquals(stakeholder.Id, retrievedKeystakeholders.get(0).Id);
            System.assertEquals(stakeholder.Account_Plan__c, retrievedKeystakeholders.get(0).Account_Plan__c);
            System.assertEquals(stakeholder.Contact__c, retrievedKeystakeholders.get(0).Contact__c);
            System.assertEquals(stakeholder.Contact__r.Title, retrievedKeystakeholders.get(0).Contact__r.Title);
        }
    }

    @isTest
    static void selectByIdOrContactIdAndPlanIdTest2() {
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
            Contact testContact = [SELECT Id, Title FROM Contact WHERE LastName = :CONTACT_LAST_NAME];
            Key_Stakeholder__c stakeholder = [
                SELECT Id, Contact__c, Contact__r.Title, Account_Plan__c
                FROM Key_Stakeholder__c
                WHERE Account_Plan__c = :accountPlan.Id AND Contact__c = :testContact.Id
            ];

            // When
            Test.startTest();

            List<Key_Stakeholder__c> retrievedKeystakeholders = KeyStakeholderSelector.newInstance()
                .selectByIdOrContactIdAndPlanId(
                    new Set<Id>{ testContact.Id },
                    accountPlan.Id,
                    new Set<String>(),
                    new Set<String>{ 'TItle' }
                );

            Test.stopTest();

            // Then
            System.assertEquals(1, retrievedKeystakeholders.size());
            System.assertEquals(stakeholder.Id, retrievedKeystakeholders.get(0).Id);
            System.assertEquals(stakeholder.Account_Plan__c, retrievedKeystakeholders.get(0).Account_Plan__c);
            System.assertEquals(stakeholder.Contact__c, retrievedKeystakeholders.get(0).Contact__c);
            System.assertEquals(stakeholder.Contact__r.Title, retrievedKeystakeholders.get(0).Contact__r.Title);
        }
    }

    @isTest
    static void selectByAccountPlanIdForYourContactsAndSelectFieldsTest() {
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
            Contact testContact = [SELECT Id, Title FROM Contact WHERE LastName = :CONTACT_LAST_NAME];
            Key_Stakeholder__c stakeholder = [
                SELECT Id, Contact__c, Contact__r.Title, Account_Plan__c, LastModifiedDate
                FROM Key_Stakeholder__c
                WHERE Account_Plan__c = :accountPlan.Id AND Contact__c = :testContact.Id
            ];

            Set<String> fields = new Set<String>{ 'Id', 'Contact__c', 'Account_Plan__c', 'LastModifiedDate' };

            Set<String> contactFields = new Set<String>{ 'Title' };

            // When
            Test.startTest();

            List<Key_Stakeholder__c> retrievedKeystakeholders = KeyStakeholderSelector.newInstance()
                .selectByAccountPlanIdForYourContactsAndSelectFields(
                    new Set<Id>{ accountPlan.Id },
                    fields,
                    contactFields
                );

            Test.stopTest();

            // Then
            System.assertEquals(1, retrievedKeystakeholders.size());
            System.assertEquals(stakeholder.Id, retrievedKeystakeholders.get(0).Id);
            System.assertEquals(stakeholder.Account_Plan__c, retrievedKeystakeholders.get(0).Account_Plan__c);
            System.assertEquals(stakeholder.Contact__c, retrievedKeystakeholders.get(0).Contact__c);
            System.assertEquals(stakeholder.LastModifiedDate, retrievedKeystakeholders.get(0).LastModifiedDate);
            System.assertEquals(stakeholder.Contact__r.Title, retrievedKeystakeholders.get(0).Contact__r.Title);
        }
    }

    @isTest
    static void selectByAccountPlanIdTest() {
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
            Contact testContact = [SELECT Id FROM Contact WHERE LastName = :CONTACT_LAST_NAME];
            Key_Stakeholder__c stakeholder = [
                SELECT Id, Contact__c, Account_Plan__c
                FROM Key_Stakeholder__c
                WHERE Account_Plan__c = :accountPlan.Id AND Contact__c = :testContact.Id
            ];

            // When
            Test.startTest();

            List<Key_Stakeholder__c> retrievedKeystakeholders = KeyStakeholderSelector.newInstance()
                .selectByAccountPlanId(new Set<Id>{ accountPlan.Id });

            Test.stopTest();

            // Then
            System.assertEquals(1, retrievedKeystakeholders.size());
            System.assertEquals(stakeholder.Id, retrievedKeystakeholders.get(0).Id);
            System.assertEquals(stakeholder.Account_Plan__c, retrievedKeystakeholders.get(0).Account_Plan__c);
            System.assertEquals(stakeholder.Contact__c, retrievedKeystakeholders.get(0).Contact__c);
        }
    }

    @isTest
    static void selectDuplicatesTest() {
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
            Contact testContact = [SELECT Id FROM Contact WHERE LastName = :CONTACT_LAST_NAME];
            Key_Stakeholder__c stakeholder = [
                SELECT Id, Contact__c, Account_Plan__c
                FROM Key_Stakeholder__c
                WHERE Account_Plan__c = :accountPlan.Id AND Contact__c = :testContact.Id
            ];

            Key_Stakeholder__c duplicateStakeholder = new Key_Stakeholder__c(
                Account_Plan__c = stakeholder.Account_Plan__c,
                Contact__c = stakeholder.Contact__c,
                InfluenceId__c = null,
                SupportId__c = null
            );

            // When
            Test.startTest();

            List<Key_Stakeholder__c> duplicateStakeholders = KeyStakeholderSelector.newInstance()
                .selectDuplicatesAsSystem(new List<Key_Stakeholder__c>{ duplicateStakeholder });

            Test.stopTest();

            // Then
            System.assertEquals(1, duplicateStakeholders.size());
            System.assertEquals(duplicateStakeholder, duplicateStakeholders[0]);
        }
    }
}