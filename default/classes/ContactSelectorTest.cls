@isTest
private class ContactSelectorTest {
    @testSetup
    static void testSetup() {
        Account acct = new Account(Name = 'testaccount');
        insert acct;

        Account child1 = new Account(Name = 'child1', ParentId = acct.Id);
        insert child1;

        Account child2 = new Account(Name = 'child2', ParentId = acct.Id);
        insert child2;

        Contact testContact1 = new Contact(
            LastName = 'Hudson',
            MobilePhone = '123-456-6789',
            Email = 'a@acme.com',
            AccountId = acct.Id
        );
        insert testContact1;

        Contact testContact2 = new Contact(
            LastName = 'Terry',
            MobilePhone = '123-456-6789',
            Email = 'a@acme.com',
            ReportsToId = testContact1.Id
        );
        insert testContact2;

        Contact testContact3 = new Contact(
            LastName = 'Mudson',
            MobilePhone = '123-456-6789',
            Email = 'child1@acme.com',
            AccountId = child1.Id
        );
        insert testContact3;

        Contact testContact4 = new Contact(
            LastName = 'Crudson',
            MobilePhone = '123-456-6789',
            Email = 'child1@acme.com',
            AccountId = child2.Id
        );
        insert testContact4;
    }

    @isTest
    static void selectByIdTest() {
        // Given
        Set<Id> givenContactIds = new Map<Id, Contact>([SELECT Id FROM Contact]).keySet();

        // When
        Test.startTest();

        List<Contact> contacts = new ContactSelector().selectById(givenContactIds);

        Test.stopTest();

        // Then
        Set<Id> contactIds = new Map<Id, Contact>(contacts).keyset();

        System.assertEquals(4, contactIds.size(), 'Expected 4 Contact records.');

        for (Id contactId : givenContactIds) {
            System.assertEquals(true, contactIds.contains(contactId));
        }
    }

    @isTest
    static void selectByReportsToIdTest() {
        // Given
        Contact c1 = [SELECT Id, ReportsToId FROM Contact WHERE LastName = 'Hudson' LIMIT 1];
        Contact c2 = [SELECT Id, ReportsToId FROM Contact WHERE LastName = 'Terry' LIMIT 1];

        // When
        Test.startTest();
        List<Contact> contacts = new ContactSelector().selectByReportsToId(new Set<Id>{ c1.Id }, new Set<String>());
        Test.stopTest();

        // Then
        System.assertEquals(1, contacts.size(), 'Expected 1 Contact record1.');
        System.assertEquals(c2.Id, contacts[0].Id);
    }

    @isTest
    static void selectByReportsToIdNullFieldTest() {
        // Given
        Contact c1 = [SELECT Id, ReportsToId FROM Contact WHERE LastName = 'Hudson' LIMIT 1];
        Contact c2 = [SELECT Id, ReportsToId FROM Contact WHERE LastName = 'Terry' LIMIT 1];

        // When
        Test.startTest();
        List<Contact> contacts = new ContactSelector().selectByReportsToId(new Set<Id>{ c1.Id }, null);
        Test.stopTest();

        // Then
        System.assertEquals(1, contacts.size(), 'Expected 1 Contact record1.');
        System.assertEquals(c2.Id, contacts[0].Id);
    }

    @isTest
    static void selectByIdAndSelectFieldsTest() {
        // Given
        Set<Id> givenContactIds = new Map<Id, Contact>(
                [SELECT Id FROM Contact WHERE LastName = 'Hudson' OR LastName = 'Terry']
            )
            .keySet();

        Set<String> fields = new Set<String>{ 'MobilePhone', 'Email' };

        // When
        Test.startTest();

        List<Contact> contacts = new ContactSelector().selectByIdAndSelectFields(givenContactIds, fields);

        Test.stopTest();

        // Then
        Set<Id> contactIds = new Map<Id, Contact>(contacts).keyset();

        System.assertEquals(2, contactIds.size(), 'Expected 2 Contact records.');

        for (Id contactId : givenContactIds) {
            System.assertEquals(true, contactIds.contains(contactId));
        }

        for (Contact c : contacts) {
            System.assertEquals('a@acme.com', (String) c.get('Email'));
            System.assertEquals('123-456-6789', (String) c.get('MobilePhone'));
        }
    }

    @isTest
    static void selectByIdAndSelectFieldsNullTest() {
        // Given
        Set<Id> givenContactIds = new Map<Id, Contact>(
                [SELECT Id FROM Contact WHERE LastName = 'Hudson' OR LastName = 'Terry']
            )
            .keySet();

        // When
        Test.startTest();

        List<Contact> contacts = new ContactSelector().selectByIdAndSelectFields(givenContactIds, null);

        Test.stopTest();

        // Then
        Set<Id> contactIds = new Map<Id, Contact>(contacts).keyset();

        System.assertEquals(2, contactIds.size(), 'Expected 2 Contact records.');

        for (Id contactId : givenContactIds) {
            System.assertEquals(true, contactIds.contains(contactId));
        }
    }

    @isTest
    static void selectWithAdditionalFieldsMaxResultTest1() {
        // Given
        Set<Id> excludedContactIds = new Set<Id>();
        Set<String> additionalFields = new Set<String>();
        Integer maxResult = -1;

        // When
        Test.startTest();
        List<Contact> contacts = new ContactSelector()
            .selectByAccountIdWithAdditionalFields(excludedContactIds, additionalFields, maxResult, null);
        Test.stopTest();

        // Then
        System.assertEquals(0, contacts.size(), 'Expected 0 Contact record.');
    }

    @isTest
    static void selectWithAdditionalFieldsTest1() {
        // Given
        Set<Id> excludedContactIds = new Set<Id>();
        Set<String> additionalFields = new Set<String>();
        Integer maxResult = 1;

        // When
        Test.startTest();
        List<Contact> contacts = new ContactSelector()
            .selectByAccountIdWithAdditionalFields(excludedContactIds, additionalFields, maxResult, null);
        Test.stopTest();

        // Then
        System.assertEquals(1, contacts.size(), 'Expected 1 Contact record.');
    }

    @isTest
    static void selectWithAdditionalFieldsTest2() {
        // Given
        Set<Id> excludedContactIds = new Set<Id>();
        Set<String> additionalFields = new Set<String>();
        Integer maxResult = 100;

        // When
        Test.startTest();
        List<Contact> contacts = new ContactSelector()
            .selectByAccountIdWithAdditionalFields(excludedContactIds, additionalFields, maxResult, null);
        Test.stopTest();

        // Then
        System.assertEquals(4, contacts.size(), 'Expected 4 Contact record.');
    }

    @isTest
    static void selectWithAdditionalFieldsTest3() {
        // Given
        Contact c1 = [SELECT Id, ReportsToId FROM Contact WHERE LastName = 'Hudson' LIMIT 1];
        Contact c2 = [SELECT Id, ReportsToId FROM Contact WHERE LastName = 'Mudson' LIMIT 1];
        Contact c3 = [SELECT Id, ReportsToId FROM Contact WHERE LastName = 'Crudson' LIMIT 1];

        Contact c = [SELECT Id FROM Contact WHERE LastName = 'Terry' LIMIT 1];
        Set<Id> excludedContactIds = new Set<Id>{ c.Id, c2.Id, c3.Id };
        Set<String> additionalFields = new Set<String>{ 'ReportsToId' };
        Integer maxResult = 100;

        // When
        Test.startTest();
        List<Contact> contacts = new ContactSelector()
            .selectByAccountIdWithAdditionalFields(excludedContactIds, additionalFields, maxResult, null);
        Test.stopTest();

        // Then
        System.assertEquals(1, contacts.size(), 'Expected 1 Contact record.');
        System.assertEquals(c1.ReportsToId, contacts[0].ReportsToId, 'Expected query field matches record.');
    }

    // Test Get Contacts For Account
    @isTest
    static void selectWithAdditionalFieldsTest4() {
        // Given
        Account a = [SELECT Id FROM Account LIMIT 1];
        Contact c1 = [SELECT Id, ReportsToId, AccountId FROM Contact WHERE LastName = 'Hudson' LIMIT 1];
        Set<Id> excludedContactIds = new Set<Id>();
        Set<String> additionalFields = new Set<String>{ 'ReportsToId' };
        Integer maxResult = 100;

        // When
        Test.startTest();
        List<Contact> contacts = new ContactSelector()
            .selectByAccountIdWithAdditionalFields(
                excludedContactIds,
                additionalFields,
                maxResult,
                new Set<Id>{ a.Id }
            );
        Test.stopTest();

        // Then
        System.assertEquals(1, contacts.size(), 'Expected 1 Contact record.');
        System.assertEquals(c1.ReportsToId, contacts[0].ReportsToId, 'Expected query field matches record.');
    }

    @isTest
    static void selectByAccountIdWithAdditionalFieldsCapTest() {
        TestMockData md = new TestMockData();
        // Given
        Contact c2 = [SELECT Id FROM Contact WHERE LastName = 'Terry' LIMIT 1];
        Set<Id> excludedContactIds = new Set<Id>{ c2.Id };
        Set<String> additionalFields = new Set<String>{ 'ReportsToId' };
        Integer maxResult = 400;

        Integer contactsCount = 400;
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < contactsCount; i++) {
            Contact c = md.mockContact.clone(false, true);
            c.Id = null;
            c.ReportsToId = null;
            c.Email = 'FakeContactEmail' + i + '@FakeTMDTestDomain.com';
            contacts.add(c);
        }
        insert contacts;

        // When
        Test.startTest();
        List<Contact> result = new ContactSelector()
            .selectByAccountIdWithAdditionalFields(excludedContactIds, additionalFields, maxResult, null);
        Test.stopTest();

        // Then
        System.assertEquals(300, result.size(), 'Expected 300 Contact records.');
    }

    // TEST SEARCHING MULTIPLE ACCOUNTS
    @isTest
    static void selectByAccountIdWithAdditionalFieldsManyAccountsTest() {
        // Given
        Account a = [SELECT Id FROM Account WHERE Name = 'testaccount' LIMIT 1];
        Account b = [SELECT Id FROM Account WHERE Name = 'child1' LIMIT 1];

        Set<Id> excludedContactIds = new Set<Id>();
        Set<String> additionalFields = new Set<String>{ 'ReportsToId' };
        Integer maxResult = 100;

        // When
        Test.startTest();
        List<Contact> result = new ContactSelector()
            .selectByAccountIdWithAdditionalFields(
                excludedContactIds,
                additionalFields,
                maxResult,
                new Set<Id>{ a.Id, b.Id }
            );
        Test.stopTest();

        // Then
        System.assertEquals(2, result.size(), 'Expected 2 Contact record.');
    }

    // TEST MAXRESULT < 0
    @isTest
    static void searchTest0() {
        // Given
        Contact c1 = [SELECT Id, ReportsToId FROM Contact WHERE LastName = 'Hudson' LIMIT 1];
        String query = 'udso';
        Set<Id> excludedContactIds = new Set<Id>();
        Set<String> additionalFields = new Set<String>{ 'ReportsToId' };
        Integer maxResult = -1;

        Test.setFixedSearchResults(new List<String>{ c1.Id });

        // When
        Test.startTest();
        List<Contact> contacts = ContactSelector.newInstance()
            .search(query, excludedContactIds, additionalFields, maxResult, null);
        Test.stopTest();

        // Then
        System.assertEquals(0, contacts.size(), 'Expected 0 Contact record.');
    }

    // TEST TRIM & QUERY < 3
    @isTest
    static void searchTest1() {
        // Given
        String query = ' a ';
        Set<Id> excludedContactIds = new Set<Id>();
        Set<String> additionalFields = new Set<String>();
        Integer maxResult = 100;

        // When
        Test.startTest();
        List<Contact> contacts = ContactSelector.newInstance()
            .search(query, excludedContactIds, additionalFields, maxResult, null);
        Test.stopTest();

        // Then
        System.assertEquals(0, contacts.size(), 'Expected 0 Contact record.');
    }

    // TEST SEARCH
    @isTest
    static void searchTest2() {
        // Given
        Contact c1 = [SELECT Id, ReportsToId FROM Contact WHERE LastName = 'Hudson' LIMIT 1];
        String query = 'udso';
        Set<Id> excludedContactIds = new Set<Id>();
        Set<String> additionalFields = new Set<String>{ 'ReportsToId' };
        Integer maxResult = 100;

        Test.setFixedSearchResults(new List<String>{ c1.Id });

        // When
        Test.startTest();
        List<Contact> contacts = ContactSelector.newInstance()
            .search(query, excludedContactIds, additionalFields, maxResult, null);
        Test.stopTest();

        // Then
        System.assertEquals(1, contacts.size(), 'Expected 1 Contact record.');
    }

    // TEST maxResult > MAX_RESULT
    @isTest
    static void searchTest3() {
        // Given
        Contact c1 = [SELECT Id, ReportsToId FROM Contact WHERE LastName = 'Hudson' LIMIT 1];
        String query = 'udso';
        Set<Id> excludedContactIds = new Set<Id>();
        Set<String> additionalFields = new Set<String>{ 'ReportsToId' };
        Integer maxResult = 400;

        Test.setFixedSearchResults(new List<String>{ c1.Id });

        // When
        Test.startTest();
        List<Contact> contacts = ContactSelector.newInstance()
            .search(query, excludedContactIds, additionalFields, maxResult, null);
        Test.stopTest();

        // Then
        System.assertEquals(1, contacts.size(), 'Expected 1 Contact record.');
    }

    // TEST SEARCH WITH ACCOUNT
    @isTest
    static void searchTest4() {
        // Given
        Contact c1 = [SELECT Id, AccountId, ReportsToId FROM Contact WHERE LastName = 'Hudson' LIMIT 1];
        String query = 'udso';
        Set<Id> excludedContactIds = new Set<Id>();
        Set<String> additionalFields = new Set<String>{ 'ReportsToId' };
        Integer maxResult = 100;

        TestMockData md = new TestMockData();

        AccountServiceImpl mockAccountService = md.mockAccountService;

        md.mocks.startStubbing();
        md.mocks.when(mockAccountService.getContactIdsForAccount(new Set<Id>{ c1.AccountId }))
            .thenReturn(new Set<Id>{ c1.Id });
        md.mocks.stopStubbing();

        Test.setFixedSearchResults(new List<String>{ c1.Id });

        // When
        Test.startTest();
        List<Contact> contacts = ContactSelector.newInstance()
            .search(query, excludedContactIds, additionalFields, maxResult, new Set<Id>{ c1.AccountId });
        Test.stopTest();

        // Then
        System.assertEquals(1, contacts.size(), 'Expected 1 Contact record.');
    }

    //
    @isTest
    static void selectByAccountIdWithCustomConditionTest1() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Set<String> additionalFields = new Set<String>{ 'FirstName', 'LastName' };
        Set<Id> accountIds = new Set<Id>{ testAccount.Id };
        Set<Id> excludedContactIds = new Set<Id>{};
        Integer maxResult = -5;
        String dynamicQuery = '';

        // Test method invocation
        List<Contact> resultContacts = ContactSelector.newInstance()
            .selectByAccountIdWithCustomCondition(
                additionalFields,
                accountIds,
                excludedContactIds,
                maxResult,
                dynamicQuery
            );

        // Assertions
        System.assertEquals(0, resultContacts.size(), 'Unexpected contacts for the test account');
    }

    //maxResult > MAX_RESULT
    // accountIds != null && accountIds.size() > 0
    // dynamicQuery = ''
    @isTest
    static void selectByAccountIdWithCustomConditionTest2() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Set<String> additionalFields = new Set<String>{ 'FirstName', 'LastName' };
        Set<Id> accountIds = new Set<Id>{ testAccount.Id };
        Set<Id> excludedContactIds = new Set<Id>{};
        Integer maxResult = 302;
        String dynamicQuery = '';

        // Test method invocation
        List<Contact> resultContacts = ContactSelector.newInstance()
            .selectByAccountIdWithCustomCondition(
                additionalFields,
                accountIds,
                excludedContactIds,
                maxResult,
                dynamicQuery
            );

        // Assertions
        System.assertEquals(1, resultContacts.size(), 'Unexpected contacts for the test account');
    }

    // accountIds != null && accountIds.size() > 0
    // dynamicQuery != ''
    @isTest
    static void selectByAccountIdWithCustomConditionTest3() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Set<String> additionalFields = new Set<String>{ 'FirstName', 'LastName' };
        Set<Id> accountIds = new Set<Id>{ testAccount.Id };
        Set<Id> excludedContactIds = new Set<Id>{};
        Integer maxResult = 302;
        String dynamicQuery = '(Email = \'a@acme.com\')';

        // Test method invocation
        List<Contact> resultContacts = ContactSelector.newInstance()
            .selectByAccountIdWithCustomCondition(
                additionalFields,
                accountIds,
                excludedContactIds,
                maxResult,
                dynamicQuery
            );

        // Assertions
        System.assertEquals(1, resultContacts.size(), 'Unexpected contacts for the test account');
    }

    // accountIds = null
    // excludedContactIds != null
    // dynamicQuery = ''
    @isTest
    static void selectByAccountIdWithCustomConditionTest4() {
        contact testContact = [SELECT Id FROM Contact LIMIT 1];

        Set<String> additionalFields = new Set<String>{ 'FirstName', 'LastName' };
        Set<Id> accountIds = new Set<Id>();
        Set<Id> excludedContactIds = new Set<Id>{ testContact.Id };
        Integer maxResult = 10;
        String dynamicQuery = '';

        // Test method invocation
        List<Contact> resultContacts = ContactSelector.newInstance()
            .selectByAccountIdWithCustomCondition(
                additionalFields,
                accountIds,
                excludedContactIds,
                maxResult,
                dynamicQuery
            );

        // Assertions
        System.assertEquals(3, resultContacts.size(), 'Unexpected contacts for the test account');
    }

    // accountIds = null
    // excludedContactIds != null
    // dynamicQuery != ''
    @isTest
    static void selectByAccountIdWithCustomConditionTest5() {
        contact testContact = [SELECT Id FROM Contact LIMIT 1];

        Set<String> additionalFields = new Set<String>{ 'FirstName', 'LastName' };
        Set<Id> accountIds = new Set<Id>();
        Set<Id> excludedContactIds = new Set<Id>{ testContact.Id };
        Integer maxResult = 10;
        String dynamicQuery = '(Email = \'a@acme.com\')';

        // Test method invocation
        List<Contact> resultContacts = ContactSelector.newInstance()
            .selectByAccountIdWithCustomCondition(
                additionalFields,
                accountIds,
                excludedContactIds,
                maxResult,
                dynamicQuery
            );

        // Assertions
        System.assertEquals(1, resultContacts.size(), 'Unexpected contacts for the test account');
    }

    // accountIds = null
    // excludedContactIds = null
    // dynamicQuery != ''
    @isTest
    static void selectByAccountIdWithCustomConditionTest6() {
        Set<String> additionalFields = new Set<String>{ 'FirstName', 'LastName' };
        Set<Id> accountIds = new Set<Id>();
        Set<Id> excludedContactIds = new Set<Id>();
        Integer maxResult = 10;
        String dynamicQuery = '(Email = \'a@acme.com\')';

        // Test method invocation
        List<Contact> resultContacts = ContactSelector.newInstance()
            .selectByAccountIdWithCustomCondition(
                additionalFields,
                accountIds,
                excludedContactIds,
                maxResult,
                dynamicQuery
            );

        // Assertions
        System.assertEquals(2, resultContacts.size(), 'Unexpected contacts for the test account');
    }
}