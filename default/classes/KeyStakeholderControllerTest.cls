@SuppressWarnings('PMD.NcssMethodCount')
@isTest
private class KeyStakeholderControllerTest {
    public static final String CONTACT_LAST_NAME = 'Potatoes';
    public static final String CONTACT_ROOT1_LAST_NAME = 'Root1';
    public static final String CONTACT_CHILD1_LAST_NAME = 'Child1';
    public static final String CONTACT_ROOT2_LAST_NAME = 'Root2';
    public static final String CONTACT_CHILD2_LAST_NAME = 'Child2';
    public static final String CONTACT_CHILD3_LAST_NAME = 'Child3';
    public static final String CONTACT_GRANDCHILD1_LAST_NAME = 'GrandChild1';
    public static final String CONTACT_GRANDCHILD2_LAST_NAME = 'GrandChild2';
    public static final String CONTACT_GRANDCHILD3_LAST_NAME = 'GrandChild3';
    public static final String CONTACT_GRANDCHILD4_LAST_NAME = 'GrandChild4';
    public static final String CONTACT_GREATGRANDCHILD1_LAST_NAME = 'GreatGrandChild1';

    public static final String STANDARD_USER_FIRST_NAME = 'Manheim';
    public static final String STANDARD_USER_LAST_NAME = 'Visa';

    public static final String CREATOR_USER_FIRST_NAME = 'Shabby';
    public static final String CREATOR_USER_LAST_NAME = 'Break';

    public static final String ADMIN_USER_FIRST_NAME = 'Apple';
    public static final String ADMIN_USER_LAST_NAME = 'Create';

    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';
    public static final String CRUSH_ACCOUNT_PLAN_CREATOR = 'CRUSH_Account_Plan_Creator';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    public static final String ACCOUNT_PLAN1_NAME = 'Account Plan 1';
    public static final String ACCOUNT_PLAN2_NAME = 'Account Plan 2';

    public static final String STANDARD_USER = 'Standard User';

    @testSetup
    static void testSetup() {
        AccountPlans.bypassEmailTrigger = true;
        KeyStakeholders.bypassEmailTrigger = true;
        Application.bypassTrigger = true;

        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];

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
            new PermissionSetAssignment(AssigneeId = creatorUser.Id, PermissionSetId = standardUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = adminUserPermissionSet.Id)
        };

        System.runAs(creatorUser) {
            Account testAccount = new Account(Name = 'Account 1');
            insert testAccount;

            Contact testContact = new Contact(LastName = CONTACT_LAST_NAME);
            insert testContact;

            Account_Plan__c testAccountPlan = TestDataFactory.createAccountPlan(ACCOUNT_PLAN1_NAME, testAccount);
            TestDataFactory.createKeyStakeholder(testAccountPlan, testContact);

            // standard user can't create account plans so we'll give them edit access to some other ones
            TestDataFactory.createAccountPlanShare(standardUser, testAccountPlan, 'Edit', 'Manual');

            // CREATE HIERARCHY DATA
            Contact root1 = new Contact(LastName = CONTACT_ROOT1_LAST_NAME);
            insert root1;
            Contact child1 = new Contact(LastName = CONTACT_CHILD1_LAST_NAME, ReportsToId = root1.Id);
            insert child1;
            Contact root2 = new Contact(LastName = CONTACT_ROOT2_LAST_NAME);
            insert root2;
            Contact child2 = new Contact(LastName = CONTACT_CHILD2_LAST_NAME, ReportsToId = root2.Id);
            insert child2;
            Contact child3 = new Contact(LastName = CONTACT_CHILD3_LAST_NAME, ReportsToId = root2.Id);
            insert child3;
            Contact grandchild1 = new Contact(LastName = CONTACT_GRANDCHILD1_LAST_NAME, ReportsToId = child3.Id);
            insert grandchild1;
            Contact grandchild2 = new Contact(LastName = CONTACT_GRANDCHILD2_LAST_NAME, ReportsToId = child3.Id);
            insert grandchild2;
            Contact grandchild3 = new Contact(LastName = CONTACT_GRANDCHILD3_LAST_NAME, ReportsToId = child3.Id);
            insert grandchild3;
            Contact grandchild4 = new Contact(LastName = CONTACT_GRANDCHILD4_LAST_NAME, ReportsToId = child3.Id);
            insert grandchild4;
            Contact greatgrandchild1 = new Contact(
                LastName = CONTACT_GREATGRANDCHILD1_LAST_NAME,
                ReportsToId = grandchild4.Id
            );
            insert greatgrandchild1;

            Account_Plan__c testAccountPlan2 = TestDataFactory.createAccountPlan(ACCOUNT_PLAN2_NAME, testAccount);
            TestDataFactory.createKeyStakeholder(testAccountPlan2, child1);
            TestDataFactory.createKeyStakeholder(testAccountPlan2, greatgrandchild1);

            // standard user can't create account plans so we'll give them edit access to some other ones
            TestDataFactory.createAccountPlanShare(standardUser, testAccountPlan2, 'Edit', 'Manual');
        }

        System.runAs(adminUser) {
            Account testAccount = new Account(Name = 'Account 1');
            insert testAccount;

            Contact testContact = new Contact(LastName = CONTACT_LAST_NAME);
            insert testContact;

            Account_Plan__c testAccountPlan = TestDataFactory.createAccountPlan(ACCOUNT_PLAN1_NAME, testAccount);
            TestDataFactory.createKeyStakeholder(testAccountPlan, testContact);
        }
    }

    @isTest
    public static void getKeyStakeholderObjectLabelTest() {
        String result = KeyStakeholderController.getKeyStakeholderObjectLabel();
        System.assertEquals(result, 'Key Stakeholder');
    }

    @isTest
    public static void getContactGraphDataForSearchTermTest() {
        testMockData md = new testMockData();
        GraphDataServiceImpl mockGraphDataService = md.mockGraphDataService;

        List<String> excludeIds = new List<String>{ md.mockContactId };
        String searchTerm = 'abc';
        String searchKey = 'Some Random Key For gcgdfstt';
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);

        md.mocks.startStubbing();
        md.mocks.when(
                mockGraphDataService.getContactGraphDataForSearchTerm(
                    searchTerm,
                    excludeIds,
                    accountId,
                    KeyStakeholderController.orgChartfields,
                    KeyStakeholderController.mapKeyStakeholderAndContactFields.get('contacts'),
                    null
                )
            )
            .thenReturn(new GraphData());
        md.mocks.stopStubbing();

        GraphData result = KeyStakeholderController.getContactGraphDataForSearchTerm(
            searchTerm,
            excludeIds,
            accountId,
            null,
            searchKey
        );

        ((GraphDataServiceImpl) md.mocks.verify(mockGraphDataService, 1))
            .getContactGraphDataForSearchTerm(
                searchTerm,
                excludeIds,
                accountId,
                KeyStakeholderController.orgChartfields,
                KeyStakeholderController.mapKeyStakeholderAndContactFields.get('contacts'),
                null
            );
        System.assertEquals(searchKey, result.searchKey, 'Should return expected search key');
    }

    @isTest
    static void canDeleteKeyStakeholderStandardTest() {
        // Given
        User standardUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :STANDARD_USER_FIRST_NAME AND LastName = :STANDARD_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(standardUser) {
            // Then
            System.assertEquals(true, KeyStakeholderController.canDeleteKeyStakeholder());
        }
    }

    @isTest
    static void canDeleteKeyStakeholderCreatorTest() {
        // Given
        User creatorUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :CREATOR_USER_FIRST_NAME AND LastName = :CREATOR_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(creatorUser) {
            // Then
            System.assertEquals(true, KeyStakeholderController.canDeleteKeyStakeholder());
        }
    }

    @isTest
    static void canDeleteKeyStakeholderAdminTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(adminUser) {
            // Then
            System.assertEquals(true, KeyStakeholderController.canDeleteKeyStakeholder());
        }
    }

    @isTest
    static void getUpdatibilityStandardTest() {
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

            Map<String, ObjectUpdatibility> updatibility = KeyStakeholderController.getUpdatibility();

            Test.stopTest();

            // Then
            System.assertNotEquals(null, updatibility);

            ObjectUpdatibility keyStakeholderUpdatibility = updatibility.get('Key_Stakeholder__c');
            Map<String, Boolean> keyStakeholderMap = keyStakeholderUpdatibility.fields;
            System.assertEquals(true, keyStakeholderMap.get(Key_Stakeholder__c.InfluenceId__c.getDescribe().getName()));
            System.assertEquals(true, keyStakeholderMap.get(Key_Stakeholder__c.SupportId__c.getDescribe().getName()));

            ObjectUpdatibility contactUpdatibility = updatibility.get('Contact');
            Map<String, Boolean> contactMap = contactUpdatibility.fields;
            System.assertEquals(true, contactMap.get(Contact.FirstName.getDescribe().getName()));
            System.assertEquals(true, contactMap.get(Contact.LastName.getDescribe().getName()));
            System.assertEquals(true, contactMap.get(Contact.Title.getDescribe().getName()));
            System.assertEquals(true, contactMap.get(Contact.Email.getDescribe().getName()));
            System.assertEquals(true, contactMap.get(Contact.Phone.getDescribe().getName()));
        }
    }

    @isTest
    static void getUpdatibilityCreatorTest() {
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

            Map<String, ObjectUpdatibility> updatibility = KeyStakeholderController.getUpdatibility();

            Test.stopTest();

            // Then
            System.assertNotEquals(null, updatibility);

            ObjectUpdatibility keyStakeholderUpdatibility = updatibility.get('Key_Stakeholder__c');
            Map<String, Boolean> keyStakeholderMap = keyStakeholderUpdatibility.fields;
            System.assertEquals(true, keyStakeholderMap.get(Key_Stakeholder__c.InfluenceId__c.getDescribe().getName()));
            System.assertEquals(true, keyStakeholderMap.get(Key_Stakeholder__c.SupportId__c.getDescribe().getName()));

            ObjectUpdatibility contactUpdatibility = updatibility.get('Contact');
            Map<String, Boolean> contactMap = contactUpdatibility.fields;
            System.assertEquals(true, contactMap.get(Contact.FirstName.getDescribe().getName()));
            System.assertEquals(true, contactMap.get(Contact.LastName.getDescribe().getName()));
            System.assertEquals(true, contactMap.get(Contact.Title.getDescribe().getName()));
            System.assertEquals(true, contactMap.get(Contact.Email.getDescribe().getName()));
            System.assertEquals(true, contactMap.get(Contact.Phone.getDescribe().getName()));
        }
    }

    @isTest
    static void getUpdatibilityAdminTest() {
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

            Map<String, ObjectUpdatibility> updatibility = KeyStakeholderController.getUpdatibility();

            Test.stopTest();

            // Then
            System.assertNotEquals(null, updatibility);

            ObjectUpdatibility keyStakeholderUpdatibility = updatibility.get('Key_Stakeholder__c');
            Map<String, Boolean> keyStakeholderMap = keyStakeholderUpdatibility.fields;
            System.assertEquals(true, keyStakeholderMap.get(Key_Stakeholder__c.InfluenceId__c.getDescribe().getName()));
            System.assertEquals(true, keyStakeholderMap.get(Key_Stakeholder__c.SupportId__c.getDescribe().getName()));

            ObjectUpdatibility contactUpdatibility = updatibility.get('Contact');
            Map<String, Boolean> contactMap = contactUpdatibility.fields;
            System.assertEquals(true, contactMap.get(Contact.FirstName.getDescribe().getName()));
            System.assertEquals(true, contactMap.get(Contact.LastName.getDescribe().getName()));
            System.assertEquals(true, contactMap.get(Contact.Title.getDescribe().getName()));
            System.assertEquals(true, contactMap.get(Contact.Email.getDescribe().getName()));
            System.assertEquals(true, contactMap.get(Contact.Phone.getDescribe().getName()));
        }
    }

    @isTest
    static void getKeyStakeholderByIdOrContactTest() {
        testMockData md = new testMockData();
        KeystakeholderSelector mockKeystakeholderSelector = md.mockKeystakeholderSelector;

        // mocks
        md.mocks.startStubbing();
        md.mocks.when(
                mockKeystakeholderSelector.selectByIdOrContactIdAndPlanId(
                    (Set<Id>) FFLibHelper.eqIdSet(new Set<Id>{ md.mockKeyStakeholder.Contact__c }),
                    (Id) fflib_Match.eqId(md.mockAccountPlanId),
                    (Set<String>) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Key_Stakeholder__c>{ md.mockKeyStakeholder });
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        Key_Stakeholder__c keyStakeholder = KeyStakeholderController.getKeyStakeholderByIdORContactId(
            md.mockKeyStakeholder.Contact__c,
            md.mockAccountPlanId
        );
        Test.stopTest();

        System.assertEquals(md.mockKeyStakeholderId, keyStakeholder.Id);
    }

    @isTest
    static void getKeyStakeholderByIdStandardTest() {
        // Given
        User standardUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :STANDARD_USER_FIRST_NAME AND LastName = :STANDARD_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(standardUser) {
            Id accountPlanId = [SELECT Id FROM Account_Plan__c LIMIT 1].Id;

            Id keyStakeholderId = [SELECT Id FROM Key_Stakeholder__c WHERE Account_Plan__c = :accountPlanId LIMIT 1].Id;

            // When
            Test.startTest();

            Key_Stakeholder__c nullKeyStakeholder = KeyStakeholderController.getKeyStakeholderById(null);
            Key_Stakeholder__c keyStakeholder = KeyStakeholderController.getKeyStakeholderById(keyStakeholderId);

            Test.stopTest();

            // Then
            System.assertEquals(null, nullKeyStakeholder);

            System.assertNotEquals(null, keyStakeholder);
            System.assertEquals(keyStakeholderId, keyStakeholder.Id);
        }
    }

    @isTest
    static void getKeyStakeholderByIdCreatorTest() {
        // Given
        User creatorUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :CREATOR_USER_FIRST_NAME AND LastName = :CREATOR_USER_LAST_NAME
            LIMIT 1
        ];

        Id accountPlanId = [SELECT Id FROM Account_Plan__c WHERE OwnerId = :creatorUser.Id LIMIT 1].Id;

        Id keyStakeholderId = [SELECT Id FROM Key_Stakeholder__c WHERE Account_Plan__c = :accountPlanId LIMIT 1].Id;

        System.runAs(creatorUser) {
            // When
            Test.startTest();

            Key_Stakeholder__c nullKeyStakeholder = KeyStakeholderController.getKeyStakeholderById(null);
            Key_Stakeholder__c keyStakeholder = KeyStakeholderController.getKeyStakeholderById(keyStakeholderId);

            Test.stopTest();

            // Then
            System.assertEquals(null, nullKeyStakeholder);

            System.assertNotEquals(null, keyStakeholder);
            System.assertEquals(keyStakeholderId, keyStakeholder.Id);
        }
    }

    @isTest
    static void getKeyStakeholderByIdAdminTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :CREATOR_USER_FIRST_NAME AND LastName = :CREATOR_USER_LAST_NAME
            LIMIT 1
        ];

        Id accountPlanId = [SELECT Id FROM Account_Plan__c WHERE OwnerId = :adminUser.Id LIMIT 1].Id;

        Id keyStakeholderId = [SELECT Id FROM Key_Stakeholder__c WHERE Account_Plan__c = :accountPlanId LIMIT 1].Id;

        System.runAs(adminUser) {
            // When
            Test.startTest();

            Key_Stakeholder__c nullKeyStakeholder = KeyStakeholderController.getKeyStakeholderById(null);
            Key_Stakeholder__c keyStakeholder = KeyStakeholderController.getKeyStakeholderById(keyStakeholderId);

            Test.stopTest();

            // Then
            System.assertEquals(null, nullKeyStakeholder);

            System.assertNotEquals(null, keyStakeholder);
            System.assertEquals(keyStakeholderId, keyStakeholder.Id);
        }
    }

    @isTest
    static void getKeyStakeholdersByAccountPlanIdStandardTest() {
        testMockData md = new testMockData();
        KeystakeholderSelector mockKeystakeholderSelector = md.mockKeystakeholderSelector;

        Id accountPlanId = [SELECT Id, Name FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME LIMIT 1].Id;

        md.mocks.startStubbing();
        md.mocks.when(
                mockKeystakeholderSelector.selectByAccountPlanIdForYourContactsAndSelectFields(
                    (Set<Id>) FFLibHelper.eqIdSet(new Set<Id>{ accountPlanId }),
                    (Set<String>) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Key_Stakeholder__c>());
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        KeyStakeholderController.getKeyStakeholdersByAccountPlanId(accountPlanId);
        Test.stopTest();

        // Then
        ((KeystakeholderSelector) md.mocks.verify(mockKeystakeholderSelector, 1))
            .selectByAccountPlanIdForYourContactsAndSelectFields(
                (Set<Id>) FFLibHelper.eqIdSet(new Set<Id>{ accountPlanId }),
                (Set<String>) fflib_Match.anyObject(),
                (Set<String>) fflib_Match.anyObject()
            );
        System.assert(true, 'Verified by mocks.verify');
    }

    @isTest
    static void getKeyStakeholdersByAccountPlanIdCreatorTest() {
        // Given
        User creatorUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :CREATOR_USER_FIRST_NAME AND LastName = :CREATOR_USER_LAST_NAME
            LIMIT 1
        ];

        Id accountPlanId = [SELECT Id FROM Account_Plan__c WHERE OwnerId = :creatorUser.Id LIMIT 1].Id;

        Id keyStakeholderId = [SELECT Id FROM Key_Stakeholder__c WHERE Account_Plan__c = :accountPlanId LIMIT 1].Id;

        System.runAs(creatorUser) {
            // When
            Test.startTest();

            List<MatrixMember> emptyMatrixMembers = KeyStakeholderController.getKeyStakeholdersByAccountPlanId(null);
            List<MatrixMember> keyStakeholders = KeyStakeholderController.getKeyStakeholdersByAccountPlanId(
                accountPlanId
            );

            Test.stopTest();

            // Then
            System.assert(emptyMatrixMembers.isEmpty());

            System.assertNotEquals(null, keyStakeholders);
            System.assert(!keyStakeholders.isEmpty());
            System.assertEquals(keyStakeholderId, keyStakeholders.get(0).Id);
        }
    }

    @isTest
    static void getKeyStakeholdersByAccountPlanIdAdminTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        Id accountPlanId = [SELECT Id FROM Account_Plan__c WHERE OwnerId = :adminUser.Id LIMIT 1].Id;

        Id keyStakeholderId = [SELECT Id FROM Key_Stakeholder__c WHERE Account_Plan__c = :accountPlanId LIMIT 1].Id;

        System.runAs(adminUser) {
            // When
            Test.startTest();

            List<MatrixMember> nullKeyStakeholders = KeyStakeholderController.getKeyStakeholdersByAccountPlanId(null);
            List<MatrixMember> keyStakeholders = KeyStakeholderController.getKeyStakeholdersByAccountPlanId(
                accountPlanId
            );

            Test.stopTest();

            // Then
            System.assert(nullKeyStakeholders.isEmpty());

            System.assertNotEquals(null, keyStakeholders);
            System.assert(!keyStakeholders.isEmpty());
            System.assertEquals(keyStakeholderId, keyStakeholders.get(0).Id);
        }
    }

    @isTest
    static void upsertKeyStakeholderStandardTest() {
        AccountPlans.bypassEmailTrigger = true;
        KeyStakeholders.bypassEmailTrigger = true;
        Application.bypassTrigger = true;

        // Given
        String influence = 'Low';
        String support = 'Champion';

        User standardUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :STANDARD_USER_FIRST_NAME AND LastName = :STANDARD_USER_LAST_NAME
            LIMIT 1
        ];

        pq_Influence__c i1 = new pq_Influence__c(Name = 'Low', Label__c = 'highlabel');
        insert i1;
        pq_Support__c s1 = new pq_Support__c(Name = 'Champion', Label__c = 'champlabel', Color__c = '#ff0011');
        insert s1;

        testMockData md = new testMockData();
        KeystakeholderSelector mockKeystakeholderSelector = md.mockKeystakeholderSelector;

        System.runAs(standardUser) {
            Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c LIMIT 1];

            Contact c = new Contact(LastName = 'Test');
            insert c;

            Key_Stakeholder__c ks1 = new Key_Stakeholder__c(
                Contact__c = c.Id,
                InfluenceId__c = i1.Id,
                SupportId__c = s1.Id,
                Account_Plan__c = accountPlan.Id
            );
            insert ks1;

            Key_Stakeholder__c ks = [
                SELECT
                    Id,
                    Contact__c,
                    Contact__r.FirstName,
                    Contact__r.LastName,
                    Contact__r.Title,
                    Contact__r.Name,
                    Account_Plan__c,
                    InfluenceId__c,
                    InfluenceId__r.Name,
                    InfluenceId__r.Label__c,
                    SupportId__c,
                    SupportId__r.Name,
                    SupportId__r.Label__c,
                    SupportId__r.Color__c,
                    Account_Plan__r.Name,
                    Account_Plan__r.Status__c
                FROM Key_Stakeholder__c
                WHERE Id = :ks1.Id
            ];

            md.mocks.startStubbing();
            md.mocks.when(
                    mockKeystakeholderSelector.selectByAccountPlanIdForYourContactsAndSelectFields(
                        (Set<Id>) FFLibHelper.eqIdSet(new Set<Id>{ accountPlan.Id }),
                        (Set<String>) fflib_Match.anyObject(),
                        (Set<String>) fflib_Match.anyObject()
                    )
                )
                .thenReturn(new List<Key_Stakeholder__c>{ ks });

            md.mocks.when(mockKeystakeholderSelector.selectById((Set<Id>) FFLibHelper.eqIdSet(new Set<Id>{ ks.Id })))
                .thenReturn(new List<Key_Stakeholder__c>{ ks });
            md.mocks.stopStubbing();

            // When
            Test.startTest();

            MatrixMember matrixMember = KeyStakeholderController.upsertKeyStakeholder(ks.Id, influence, support);

            Test.stopTest();

            // Then
            System.assertEquals(influence, matrixMember.influence);
            System.assertEquals(support, matrixMember.support);
        }
    }

    @isTest
    static void upsertKeyStakeholderCreatorTest() {
        AccountPlans.bypassEmailTrigger = true;
        KeyStakeholders.bypassEmailTrigger = true;
        Application.bypassTrigger = true;

        // Given
        String influence = 'Low';
        String support = 'Champion';

        User creatorUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :CREATOR_USER_FIRST_NAME AND LastName = :CREATOR_USER_LAST_NAME
            LIMIT 1
        ];

        pq_Influence__c i1 = new pq_Influence__c(Name = 'Low', Label__c = 'highlabel');
        insert i1;
        pq_Support__c s1 = new pq_Support__c(Name = 'Champion', Label__c = 'champlabel', Color__c = '#ff0011');
        insert s1;

        Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c WHERE OwnerId = :creatorUser.Id LIMIT 1];

        Contact c = new Contact(LastName = 'Test');
        insert c;

        Key_Stakeholder__c ks1 = new Key_Stakeholder__c(
            Contact__c = c.Id,
            InfluenceId__c = i1.Id,
            SupportId__c = s1.Id,
            Account_Plan__c = accountPlan.Id
        );
        insert ks1;

        Key_Stakeholder__c ks = [
            SELECT
                Id,
                Contact__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Title,
                Contact__r.Name,
                Account_Plan__c,
                InfluenceId__c,
                InfluenceId__r.Name,
                InfluenceId__r.Label__c,
                SupportId__c,
                SupportId__r.Name,
                SupportId__r.Label__c,
                SupportId__r.Color__c,
                Account_Plan__r.Name,
                Account_Plan__r.Status__c
            FROM Key_Stakeholder__c
            WHERE Id = :ks1.Id
        ];

        testMockData md = new testMockData();
        KeystakeholderSelector mockKeystakeholderSelector = md.mockKeystakeholderSelector;

        System.runAs(creatorUser) {
            md.mocks.startStubbing();

            md.mocks.when(
                    mockKeystakeholderSelector.selectByAccountPlanIdForYourContactsAndSelectFields(
                        (Set<Id>) FFLibHelper.eqIdSet(new Set<Id>{ accountPlan.Id }),
                        (Set<String>) fflib_Match.anyObject(),
                        (Set<String>) fflib_Match.anyObject()
                    )
                )
                .thenReturn(new List<Key_Stakeholder__c>{ ks });

            md.mocks.when(mockKeystakeholderSelector.selectById((Set<Id>) FFLibHelper.eqIdSet(new Set<Id>{ ks.Id })))
                .thenReturn(new List<Key_Stakeholder__c>{ ks });
            md.mocks.stopStubbing();

            // When
            Test.startTest();

            MatrixMember keyStakeholder = KeyStakeholderController.upsertKeyStakeholder(ks.Id, influence, support);

            Test.stopTest();

            // Then
            System.assertEquals(influence, keyStakeholder.influence);
            System.assertEquals(support, keyStakeholder.support);
        }
    }

    @isTest
    static void upsertKeyStakeholderAdminTest() {
        AccountPlans.bypassEmailTrigger = true;
        KeyStakeholders.bypassEmailTrigger = true;
        Application.bypassTrigger = true;

        // Given
        String influence = 'Low';
        String support = 'Champion';

        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        pq_Influence__c i1 = new pq_Influence__c(Name = 'Low', Label__c = 'highlabel');
        insert i1;
        pq_Support__c s1 = new pq_Support__c(Name = 'Champion', Label__c = 'champlabel', Color__c = '#ff0011');
        insert s1;

        Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c WHERE OwnerId = :adminUser.Id LIMIT 1];

        Contact c = new Contact(LastName = 'Test');
        insert c;

        Key_Stakeholder__c ks1 = new Key_Stakeholder__c(
            Contact__c = c.Id,
            InfluenceId__c = i1.Id,
            SupportId__c = s1.Id,
            Account_Plan__c = accountPlan.Id
        );
        insert ks1;

        Key_Stakeholder__c ks = [
            SELECT
                Id,
                Contact__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Title,
                Contact__r.Name,
                Account_Plan__c,
                InfluenceId__c,
                InfluenceId__r.Name,
                InfluenceId__r.Label__c,
                SupportId__c,
                SupportId__r.Name,
                SupportId__r.Label__c,
                SupportId__r.Color__c,
                Account_Plan__r.Name,
                Account_Plan__r.Status__c
            FROM Key_Stakeholder__c
            WHERE Id = :ks1.Id
        ];

        testMockData md = new testMockData();
        KeystakeholderSelector mockKeystakeholderSelector = md.mockKeystakeholderSelector;

        System.runAs(adminUser) {
            md.mocks.startStubbing();

            md.mocks.when(
                    mockKeystakeholderSelector.selectByAccountPlanIdForYourContactsAndSelectFields(
                        (Set<Id>) FFLibHelper.eqIdSet(new Set<Id>{ accountPlan.Id }),
                        (Set<String>) fflib_Match.anyObject(),
                        (Set<String>) fflib_Match.anyObject()
                    )
                )
                .thenReturn(new List<Key_Stakeholder__c>{ ks });

            md.mocks.when(mockKeystakeholderSelector.selectById((Set<Id>) FFLibHelper.eqIdSet(new Set<Id>{ ks.Id })))
                .thenReturn(new List<Key_Stakeholder__c>{ ks });
            md.mocks.stopStubbing();

            // When
            Test.startTest();

            MatrixMember keyStakeholder = KeyStakeholderController.upsertKeyStakeholder(ks.Id, influence, support);

            Test.stopTest();

            // Then
            System.assertEquals(influence, keyStakeholder.influence);
            System.assertEquals(support, keyStakeholder.support);
        }
    }

    // @isTest
    // static void getGraphDataForYourContactsByAccountPlanIdStandardTestLevel1() {
    //     // Given
    //     User creatorUser = [
    //         SELECT Id
    //         FROM User
    //         WHERE FirstName = :CREATOR_USER_FIRST_NAME AND LastName = :CREATOR_USER_LAST_NAME
    //         LIMIT 1
    //     ];

    //     CRUSH_Settings_Obj__c orgSettings = new CRUSH_Settings_Obj__c(Type__c = 'Org', Contacts_Ancestry_Levels__c = 1);
    //     List<CRUSH_Settings_Obj__c> orgSettingsList = [SELECT Id FROM CRUSH_Settings_Obj__c WHERE Type__c = 'Org'];
    //     if (orgSettingsList.size() > 0) {
    //         orgSettings.Id = orgSettingsList[0].Id;
    //     }
    //     upsert orgSettings;

    //     System.runAs(creatorUser) {
    //         Account_Plan__c ap = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME LIMIT 1];

    //         GraphData gd = KeyStakeholderController.getGraphDataForYourContactsByAccountPlanId(ap.Id);

    //         // Then
    //         System.assertEquals(4, gd.nodeDataArray.size());
    //         System.assertEquals(3, gd.linkDataArray.size());
    //     }
    // }

    // @isTest
    // static void getGraphDataForYourContactsByAccountPlanIdStandardTestLevel2() {
    //     // Given
    //     User creatorUser = [
    //         SELECT Id
    //         FROM User
    //         WHERE FirstName = :CREATOR_USER_FIRST_NAME AND LastName = :CREATOR_USER_LAST_NAME
    //         LIMIT 1
    //     ];

    //     CRUSH_Settings_Obj__c orgSettings = new CRUSH_Settings_Obj__c(Type__c = 'Org', Contacts_Ancestry_Levels__c = 2);
    //     List<CRUSH_Settings_Obj__c> orgSettingsList = [SELECT Id FROM CRUSH_Settings_Obj__c WHERE Type__c = 'Org'];
    //     if (orgSettingsList.size() > 0) {
    //         orgSettings.Id = orgSettingsList[0].Id;
    //     }
    //     upsert orgSettings;

    //     System.runAs(creatorUser) {
    //         Account_Plan__c ap = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME LIMIT 1];

    //         GraphData gd = KeyStakeholderController.getGraphDataForYourContactsByAccountPlanId(ap.Id);

    //         // Then
    //         System.assertEquals(4, gd.nodeDataArray.size());
    //         System.assertEquals(3, gd.linkDataArray.size());
    //     }
    // }

    // @isTest
    // static void getGraphDataForYourContactsByAccountPlanIdStandardTestLevel3() {
    //     // Given
    //     User creatorUser = [
    //         SELECT Id
    //         FROM User
    //         WHERE FirstName = :CREATOR_USER_FIRST_NAME AND LastName = :CREATOR_USER_LAST_NAME
    //         LIMIT 1
    //     ];

    //     CRUSH_Settings_Obj__c orgSettings = new CRUSH_Settings_Obj__c(Type__c = 'Org', Contacts_Ancestry_Levels__c = 3);
    //     List<CRUSH_Settings_Obj__c> orgSettingsList = [SELECT Id FROM CRUSH_Settings_Obj__c WHERE Type__c = 'Org'];
    //     if (orgSettingsList.size() > 0) {
    //         orgSettings.Id = orgSettingsList[0].Id;
    //     }
    //     upsert orgSettings;

    //     System.runAs(creatorUser) {
    //         Account_Plan__c ap = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME LIMIT 1];

    //         GraphData gd = KeyStakeholderController.getGraphDataForYourContactsByAccountPlanId(ap.Id);

    //         // Then
    //         System.assertEquals(4, gd.nodeDataArray.size());
    //         System.assertEquals(3, gd.linkDataArray.size());
    //     }
    // }

    // @isTest
    // static void getGraphDataForYourContactsByAccountPlanIdStandardTestLevel4() {
    //     // Given
    //     User creatorUser = [
    //         SELECT Id
    //         FROM User
    //         WHERE FirstName = :CREATOR_USER_FIRST_NAME AND LastName = :CREATOR_USER_LAST_NAME
    //         LIMIT 1
    //     ];

    //     CRUSH_Settings_Obj__c orgSettings = new CRUSH_Settings_Obj__c(Type__c = 'Org', Contacts_Ancestry_Levels__c = 4);
    //     List<CRUSH_Settings_Obj__c> orgSettingsList = [SELECT Id FROM CRUSH_Settings_Obj__c WHERE Type__c = 'Org'];
    //     if (orgSettingsList.size() > 0) {
    //         orgSettings.Id = orgSettingsList[0].Id;
    //     }
    //     upsert orgSettings;

    //     System.runAs(creatorUser) {
    //         Account_Plan__c ap = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME LIMIT 1];

    //         GraphData gd = KeyStakeholderController.getGraphDataForYourContactsByAccountPlanId(ap.Id);

    //         // Then
    //         System.assertEquals(4, gd.nodeDataArray.size());
    //         System.assertEquals(3, gd.linkDataArray.size());
    //     }
    // }

    // @isTest
    // static void addKeystakeholdersTest() {
    //     // Given
    //     User creatorUser = [
    //         SELECT Id
    //         FROM User
    //         WHERE FirstName = :CREATOR_USER_FIRST_NAME AND LastName = :CREATOR_USER_LAST_NAME
    //         LIMIT 1
    //     ];

    //     testMockData md = new testMockData();
    //     RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;

    //     md.mocks.startStubbing();
    //     md.mocks.when(mockRelationshipMapService.hasAccountPlan(md.mockAccountPlanId))
    //         .thenReturn(false);
    //     md.mocks.stopStubbing();

    //     System.runAs(creatorUser) {
    //         Contact c1 = TestDataFactory.createContact('a', 'a');
    //         Contact c2 = TestDataFactory.createContact('b', 'b');
    //         Contact c3 = TestDataFactory.createContact('c', 'c');

    //         Account_Plan__c ap = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME LIMIT 1];

    //         GraphNodeData graphData1 = new GraphNodeData(c1.Id, 'groupKey', 'label', 'horizontal');
    //         GraphNodeData graphData2 = new GraphNodeData(c2.Id, 'groupKey', 'label', 'horizontal');
    //         GraphNodeData graphData3 = new GraphNodeData(c3.Id, 'groupKey', 'label', 'horizontal');
    //         GraphData gd = new graphData();
    //         gd.nodeDataArray = new List<GraphNodeData>{ graphData1, graphData2, graphData3 };

    //         GraphData result = KeyStakeholderController.addContactAsKeyStakeholders(ap.Id, JSON.serialize(gd));

    //         // Then
    //         System.assertEquals(3, result.nodeDataArray.size());
    //     }
    // }

    @isTest
    static void deleteKeyStakeholdersTest() {
        // Given
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        List<Id> stakeholderIds = new List<Id>{ md.mockKeyStakeholderId };

        KeyStakeholderController.deleteKeyStakeholders(stakeholderIds);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerDeleted((List<Key_Stakeholder__c>) fflib_Match.anyList());
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    static void getOrgSettingsTest() {
        // Given
        testMockData md = new testMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        KeyStakeholderController.getOrgSettings();

        ((SettingServiceImpl) md.mocks.verify(mockSettingService, 1)).getOrgSettingsAndCreateIfNeeded();
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    static void upsertSettingsTest() {
        // Given
        testMockData md = new testMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;
        Id mockSettingsId = fflib_IDGenerator.generate(CRUSH_Settings_Obj__c.SObjectType);
        String settingString =
            '{"accountPlanTransfer":"NONE","autoLayout":false,"cardStyle":"Detail","cardStyleOptions":[{"name":"Detail","value":"Detail"},{"name":"Compact","value":"Compact"}],"contactsAncestryLevels":2,"displayStyle":"Leaf_Vertical","displayStyleOptions":[{"name":"Horizontal","value":"Horizontal"},{"name":"Vertical","value":"Leaf_Vertical"}],"enableDragSelect":true,"enableNotifications":true,"id":"' +
            mockSettingsId +
            '","isGroupGlobalScope":true,"isRelationshipLineGlobalScope":true,"notifications":[{"enabled":true,"label":"Goal Updated","name":"Goal_Updated__c"},{"enabled":true,"label":"Key Dates Updated","name":"Key_Date_Updated__c"},{"enabled":true,"label":"Key Stakeholders Updated","name":"Key_Stakeholder_Updated__c"},{"enabled":true,"label":"Objectives Updated","name":"Objectives_Updated__c"},{"enabled":true,"label":"Opportunities Updated","name":"Opportunities_Added__c"},{"enabled":true,"label":"Plan Overview Updated","name":"Plan_Overview_Updated__c"},{"enabled":true,"label":"Plan Status Updated","name":"Status_Updated__c"},{"enabled":true,"label":"SWOT Analysis Updated","name":"SWOT_Analysis_Updated__c"},{"enabled":true,"label":"Team Members Added or Removed","name":"Team_Member_Added_Removed__c"},{"enabled":true,"label":"Team Member Roles Updated","name":"Team_Member_Permission_Updated__c"}],"relationshipLineOpacity":0.12,"showEmptyFields":true,"showOverview":true,"showParents":false,"type":"Org"}';
        CRUSH_Settings_Obj__c settingsObject = ((CrushSettings) JSON.deserialize(settingString, CrushSettings.class))
            .toSObject();

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.upsertSettings(settingsObject)).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        KeyStakeholderController.upsertSettings(settingString);

        ((SettingServiceImpl) md.mocks.verify(mockSettingService, 1)).upsertSettings(settingsObject);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    static void getMatrixByAccountPlanTest() {
        testMockData md = new testMockData();
        InfluenceSupportMatrixServiceImpl influenceSupportMatrixService = md.InfluenceSupportMatrixService;

        Map<Id, pq_Influence_And_Support_Matrix__c> matrixes = new Map<Id, pq_Influence_And_Support_Matrix__c>();
        matrixes.put(md.mockAccountPlanId, md.mockInfluenceSupportMatrix);

        pq_Influence__c i1 = new pq_Influence__c(Name = 'Low', Label__c = 'lowlabel');
        insert i1;
        pq_Support__c s1 = new pq_Support__c(Name = 'Champion', Label__c = 'champlabel', Color__c = '#ff0011');
        insert s1;

        List<pq_Influence__c> influences = new List<pq_Influence__c>();
        influences.add(i1);
        List<pq_Support__c> supports = new List<pq_Support__c>();
        supports.add(s1);

        md.mocks.startStubbing();
        md.mocks.when(influenceSupportMatrixService.getMatrixesForAccountPlan(new Set<Id>{ md.mockAccountPlanId }))
            .thenReturn(matrixes);
        md.mocks.when(
                influenceSupportMatrixService.getInfluencesByMatrixes(new Set<Id>{ md.mockInfluenceSupportMatrixId })
            )
            .thenReturn(influences);
        md.mocks.when(
                influenceSupportMatrixService.getSupportByMatrixes(new Set<Id>{ md.mockInfluenceSupportMatrixId })
            )
            .thenReturn(supports);
        md.mocks.stopStubbing();

        MatrixWrapper result = KeyStakeholderController.getMatrixByAccountPlan(md.mockAccountPlanId);
        System.assertNotEquals(null, result);
        // Extra one from TBD
        System.assertEquals(2, result.influenceList.size());
        System.assertEquals(2, result.supportList.size());
    }
}