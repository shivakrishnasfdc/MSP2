@isTest
private class AccountServiceTest {
    @testSetup
    static void setup() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        for (Integer i = 0; i < 2; i++) {
            testAccts.add(new Account(Name = 'TestAcct' + i));
        }
        insert testAccts;
    }

    // Passing AccountId up, should get AccountId back
    @isTest
    static void getRelatedAccountIdForRecordIdTest1() {
        // Given
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;

        // When
        Test.startTest();
        Id result = AccountService.getRelatedAccountIdForRecordId(accountId);
        Test.stopTest();

        // Then
        System.assertEquals(accountId, result, 'Expected matching account id.');
    }

    @isTest
    static void getRelatedAccountIdForRecordIdOpportunityPlanTest() {
        // Given
        TestMockData md = new TestMockData();
        OpportunityPlanServiceImpl mockService = md.mockOpportunityPlanService;
        SObjectServiceImpl mockSObjectService = md.mockSObjectService;

        md.mocks.startStubbing();
        md.mocks.when(mockService.getAccountIdForOppPlanId(md.mockOpportunityPlanId)).thenReturn(md.mockAccountId);
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        Id result = AccountService.getRelatedAccountIdForRecordId(md.mockOpportunityPlanId);
        Test.stopTest();

        // Then
        System.assertEquals(md.mockAccountId, result, 'Expected matching account id.');
        ((SObjectServiceImpl) md.mocks.verify(mockSObjectService, 0))
            .relationshipsFromDescribeMatchingObjectType(
                (Schema.DescribeSObjectResult) fflib_Match.anyObject(),
                (Schema.SObjectType) fflib_Match.anyObject()
            );
    }

    // Passing Contact Id up with AccountId populated
    @isTest
    static void getRelatedAccountIdForRecordIdTest2() {
        // Given
        Account acct = new Account(Name = 'testaccount');
        insert acct;
        Contact testContact1 = new Contact(
            LastName = 'Hudson',
            MobilePhone = '123-456-6789',
            Email = 'a@acme.com',
            AccountId = acct.Id
        );
        insert testContact1;

        // When
        Test.startTest();
        Id result = AccountService.getRelatedAccountIdForRecordId(testContact1.Id);
        Test.stopTest();

        // Then
        System.assertEquals(acct.Id, result, 'Expected matching account id.');
    }

    // Passing Contact Id without an Account Id populated
    @isTest
    static void getRelatedAccountIdForRecordIdTest3() {
        // Given
        Account acct = new Account(Name = 'testaccount');
        insert acct;
        Contact testContact1 = new Contact(LastName = 'Hudson', MobilePhone = '123-456-6789', Email = 'a@acme.com');
        insert testContact1;

        // When
        Test.startTest();
        Id result = AccountService.getRelatedAccountIdForRecordId(testContact1.Id);
        Test.stopTest();

        // Then
        System.assertEquals(null, result, 'Expected null.');
    }

    // Passing Account Plan Id up, should get AccountId back
    @isTest
    static void getRelatedAccountIdForRecordIdTest() {
        // Given
        Account acct = new Account(Name = 'testaccount');
        insert acct;

        Account_Plan__c acctPlan = new Account_Plan__c(Account__c = acct.Id);
        insert acctPlan;

        // When
        Test.startTest();
        Id result = AccountService.getRelatedAccountIdForRecordId(acctPlan.Id);
        Test.stopTest();

        // Then
        System.assertEquals(acct.Id, result, 'Expected matchin result account Id.');
    }

    @isTest
    static void getAccountAndDescendentsTest() {
        // Given
        Account acct = new Account(Name = 'testaccount');
        insert acct;

        Account acct2 = new Account(Name = 'testaccount2');
        insert acct2;

        Account child1 = new Account(Name = 'child1', ParentId = acct.Id);
        insert child1;

        Account child2 = new Account(Name = 'child2', ParentId = acct.Id);
        insert child2;

        Account child3 = new Account(Name = 'child3', ParentId = acct2.Id);
        insert child3;

        // When
        Test.startTest();
        Map<Id, Account> result = AccountService.getAccountAndDescendents(acct.Id);
        Test.stopTest();

        // Then
        Set<Id> keys = result.keySet();
        System.assertEquals(3, keys.size(), 'Expect 3 Accounts, 1 parent & 2 children');
        System.assert(keys.contains(acct.Id));
        System.assert(keys.contains(child1.Id));
        System.assert(keys.contains(child2.Id));
    }

    @isTest
    static void getIdsForRelatedObjectsToAccountTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockService = md.mockSettingService;
        SObjectServiceImpl mockSObjectService = md.mockSObjectService;

        // Given
        CRUSH_Settings_Obj__c mockOrgSettings = new CRUSH_Settings_Obj__c(
            Type__c = 'Org',
            Task_Objects_Related_To_Account__c = 'Opportunity,Contact'
        );

        md.mocks.startStubbing();
        md.mocks.when(mockService.getOrgSettingsAndCreateIfNeeded()).thenReturn(mockOrgSettings);
        md.mocks.stopStubbing();

        AccountService.getIdsForRelatedObjectsToAccount(md.mockAccountId);

        ((SObjectServiceImpl) md.mocks.verify(mockSObjectService, 1))
            .getIdsForRelatedObjects(
                md.mockAccountId,
                new List<Schema.sObjectType>{ Opportunity.getSObjectType(), Contact.getSObjectType() }
            );
        System.assert(true, 'Assert done by mock verify');
    }

    @isTest
    static void getIdsForRelatedObjectsToAccountNullTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockService = md.mockSettingService;
        SObjectServiceImpl mockSObjectService = md.mockSObjectService;

        // Given
        CRUSH_Settings_Obj__c mockOrgSettings = new CRUSH_Settings_Obj__c(
            Type__c = 'Org',
            Task_Objects_Related_To_Account__c = null
        );

        md.mocks.startStubbing();
        md.mocks.when(mockService.getOrgSettingsAndCreateIfNeeded()).thenReturn(mockOrgSettings);
        md.mocks.stopStubbing();

        Set<Id> result = AccountService.getIdsForRelatedObjectsToAccount(md.mockAccountId);

        ((SObjectServiceImpl) md.mocks.verify(mockSObjectService, 0))
            .getIdsForRelatedObjects(md.mockAccountId, new List<Schema.sObjectType>());
        System.assertEquals(0, result.size());
    }

    @isTest
    static void getContactIdsForAccountTest() {
        Account acc = TestDataFactory.createAccount('Test');
        Contact c1 = new Contact(FirstName = 'joe', LastName = 'smith', AccountId = acc.Id);
        Contact c2 = new Contact(FirstName = 'jane', LastName = 'smith', AccountId = acc.Id);
        insert c1;
        insert c2;

        TestMockData md = new TestMockData();
        AccountContactRelationServiceImpl mockAccountContactRelationService = md.mockAccountContactRelationService;

        md.mocks.startStubbing();
        md.mocks.when(mockAccountContactRelationService.areAccountContactRelationEnabled()).thenReturn(false);
        md.mocks.stopStubbing();

        Set<Id> result = AccountService.getContactIdsForAccount(new Set<Id>{ acc.Id });

        System.assertEquals(2, result.size());
    }

    @isTest
    static void getContactIdsForAccountTest2() {
        Account acc = TestDataFactory.createAccount('Test');
        Contact c1 = new Contact(FirstName = 'joe', LastName = 'smith', AccountId = acc.Id);
        Contact c2 = new Contact(FirstName = 'jane', LastName = 'smith', AccountId = acc.Id);
        insert c1;
        insert c2;

        TestMockData md = new TestMockData();
        AccountContactRelationServiceImpl mockAccountContactRelationService = md.mockAccountContactRelationService;

        md.mocks.startStubbing();
        md.mocks.when(mockAccountContactRelationService.areAccountContactRelationEnabled()).thenReturn(true);
        md.mocks.stopStubbing();

        AccountService.getContactIdsForAccount(new Set<Id>{ acc.Id });

        ((AccountContactRelationServiceImpl) md.mocks.verify(mockAccountContactRelationService, 1))
            .getContactIdsForAccounts(new Set<Id>{ acc.Id });

        System.assert(true, 'Assert by mock verify');
    }
}