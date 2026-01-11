@isTest
private class WhiteSpaceUtilsTest {
    public static final String USER1_FIRST_NAME = 'admin';
    public static final String USER1_LAST_NAME = 'adam';
    public static final String USER2_FIRST_NAME = 'standard';
    public static final String USER2_LAST_NAME = 'suzie';

    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';
    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';

    public static final String WHITE_SPACE_TEMPLATE_NAME = 'testTemplate';

    public static final String STANDARD_USER = 'Standard User';
    public static final String ACCOUNT1_NAME = 'Account 1';
    public static final String ACCOUNT2_NAME = 'Account 2';
    public static final String ACCOUNT3_NAME = 'Account 3';

    static final WhiteSpaceTemplateMappingWrapper ACCOUNT_MAPPING = new WhiteSpaceTemplateMappingWrapper(
        'Account',
        'Name',
        null
    );

    static final WhiteSpaceTemplateMappingWrapper CONTACT_MAPPING = new WhiteSpaceTemplateMappingWrapper(
        'Contact',
        'Name',
        null
    );

    static final WhiteSpaceTemplateMappingWrapper OPPORTUNITY_MAPPING = new WhiteSpaceTemplateMappingWrapper(
        'Opportunity',
        'Description',
        'Description'
    );

    @testSetup
    static void testSetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];
        User adminAdam = TestDataFactory.createUser(USER1_FIRST_NAME, USER1_LAST_NAME, p.Id);
        User standardSuzie = TestDataFactory.createUser(USER2_FIRST_NAME, USER2_LAST_NAME, p.Id);
        PermissionSet standardUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_STANDARD_USER];
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = standardSuzie.Id, PermissionSetId = standardUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = adminAdam.Id, PermissionSetId = adminUserPermissionSet.Id)
        };

        System.runAs(adminAdam) {
            Account account = new Account(Name = ACCOUNT1_NAME);
            Account account2 = new Account(Name = ACCOUNT2_NAME);
            Account account3 = new Account(Name = ACCOUNT3_NAME);
            insert new List<Account>{ account, account2, account3 };

            Asset asset1 = new Asset(Name = 'lone Asset', AccountId = account.Id, Quantity = 12);
            Asset asset2 = new Asset(Name = 'Asset Group', AccountId = account.Id, Quantity = 13);
            Asset asset3 = new Asset(Name = 'Asset Group', AccountId = account.Id, Quantity = 14);
            insert new List<Asset>{ asset1, asset2, asset3 };

            Contact contact = new Contact(FirstName = 'Joe', LastName = 'Test1', AccountId = account.Id);
            insert contact;

            Contact contact2 = new Contact(FirstName = 'Bob', LastName = 'Test2');
            insert contact2;
        }
    }

    @isTest
    static void getTotalCountTest() {
        // when
        Integer result;
        Test.startTest();
        result = WhiteSpaceUtils.getTotalCount(ACCOUNT_MAPPING);
        Test.stopTest();

        // then
        System.assertEquals(3, result);
    }

    @isTest
    static void getTotalCountGroupedStringTest() {
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper('Asset', 'Name', null);
        wrapper.groupResults = true;
        // when
        Integer result;
        Test.startTest();
        result = WhiteSpaceUtils.getTotalCount(wrapper);
        Test.stopTest();

        // then
        System.assertEquals(2, result, 'should be two groups');
    }

    @isTest
    static void getTotalCountGroupedIdTest() {
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper('Asset', 'AccountId', null);
        wrapper.groupResults = true;
        // when
        Integer result;
        Test.startTest();
        result = WhiteSpaceUtils.getTotalCount(wrapper);
        Test.stopTest();

        // then
        System.assertEquals(1, result, 'should be one group');
    }

    @isTest
    static void getTotalCountGroupedNumberTest() {
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper('Asset', 'Quantity', null);
        wrapper.groupResults = true;
        // when
        Integer result;
        Test.startTest();
        result = WhiteSpaceUtils.getTotalCount(wrapper);
        Test.stopTest();

        // then
        System.assertEquals(3, result, 'should be three groups');
    }

    @isTest
    static void getTotalCountWithLookupTest() {
        // given
        Id accId = [SELECT Id FROM Account WHERE Name = :ACCOUNT1_NAME LIMIT 1].Id;

        // when
        Integer result;
        Test.startTest();
        result = WhiteSpaceUtils.getTotalCountWithLookup(CONTACT_MAPPING, accId);
        Test.stopTest();

        // then
        System.assertEquals(1, result);
    }

    @isTest
    static void getTotalCountWithLookupIncludesLookupRecordTest() {
        // given
        Id accId = [SELECT Id FROM Account WHERE Name = :ACCOUNT1_NAME LIMIT 1].Id;

        // when
        Integer result;
        Test.startTest();
        result = WhiteSpaceUtils.getTotalCountWithLookup(ACCOUNT_MAPPING, accId);
        Test.stopTest();

        // then
        System.assertEquals(1, result);
    }

    @isTest
    static void getResultsTest() {
        // when
        List<SObject> result;
        Test.startTest();
        result = WhiteSpaceUtils.getResults(ACCOUNT_MAPPING);
        Test.stopTest();

        // then
        System.assertEquals(3, result.size());
    }

    @isTest
    static void getResultsWithLookupTest() {
        // given
        Id accId = [SELECT Id FROM Account WHERE Name = :ACCOUNT1_NAME LIMIT 1].Id;

        // when
        List<SObject> result;
        Test.startTest();
        result = WhiteSpaceUtils.getResults(CONTACT_MAPPING, accId);
        Test.stopTest();

        // then
        System.assertEquals(1, result.size());
    }

    @isTest
    static void getResultsWithLookupIncludesLookupRecordTest() {
        // given
        Id accId = [SELECT Id FROM Account WHERE Name = :ACCOUNT1_NAME LIMIT 1].Id;

        // when
        List<SObject> result;
        Test.startTest();
        result = WhiteSpaceUtils.getResults(ACCOUNT_MAPPING, accId);
        Test.stopTest();

        // then
        System.assertEquals(1, result.size());
    }

    @isTest
    static void getQueryFromMappingTest() {
        // when
        Query result;
        Test.startTest();
        result = WhiteSpaceUtils.getQueryFromMapping(ACCOUNT_MAPPING);
        Test.stopTest();

        String expectedQuery = 'SELECT name FROM Account ORDER BY Name ASC NULLS FIRST';

        // then
        System.assertEquals(expectedQuery, result.toQueryString());
    }

    @isTest
    static void getQueryFromMappingNoSortTest() {
        // when
        Query result;
        Test.startTest();
        result = WhiteSpaceUtils.getQueryFromMapping(OPPORTUNITY_MAPPING);
        Test.stopTest();

        String expectedQuery = 'SELECT description FROM Opportunity';

        // then
        System.assertEquals(expectedQuery, result.toQueryString());
    }

    @isTest
    static void isMultiPicklistMappingTypeTest() {
        Boolean result = WhiteSpaceUtils.isMultiPicklistMappingType(OPPORTUNITY_MAPPING);
        System.assertEquals(false, result, 'The mapping is not a multi picklist');
    }

    @isTest
    static void isMultiPicklistMappingTypeWithFieldTest() {
        Boolean result = WhiteSpaceUtils.isMultiPicklistMappingType(OPPORTUNITY_MAPPING, 'Name');
        System.assertEquals(false, result, 'The mapping is not a multi picklist');
    }

    @isTest
    static void getCellDataMapNullsTest() {
        Map<String, Map<String, List<SObject>>> result = WhiteSpaceUtils.getCellDataMap(
            null,
            null,
            null,
            null,
            false,
            null,
            null,
            null,
            null,
            null
        );
        System.assertEquals(0, result.size(), 'Passing all nulls should return an empty map');
    }

    @isTest
    static void getCellDataMapEmptyTest() {
        Map<String, Map<String, List<SObject>>> result = WhiteSpaceUtils.getCellDataMap(
            new Set<String>(),
            new Set<String>(),
            new Set<String>(),
            null,
            false,
            new List<WhiteSpaceTemplateCellFieldWrapper>(),
            new List<WhiteSpaceTemplateCellFieldWrapper>(),
            new List<WhiteSpaceTemplateCellFieldWrapper>(),
            new Set<String>(),
            null
        );
        System.assertEquals(0, result.size(), 'Passing all empty values should return an empty map');
    }

    @isTest
    static void registerLookupSimpleNullQueryTestTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceUtils.registerLookup(null, 'Account', md.mockAccountId);
        System.assert(true, 'just care that no exception was thrown');
    }

    @isTest
    static void registerLookupComplexNullQueryTestTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceUtils.registerLookup(null, 'Account', md.mockAccountId, true);
        WhiteSpaceUtils.registerLookup(null, 'Account', md.mockAccountId, false);
        System.assert(true, 'just care that no exception was thrown');
    }

    @IsTest
    static void registerLookupSimpleNullObjectNameTest() {
        TestMockData md = new TestMockData();
        Query q = new Query(Account.SObjectType, null);
        String expected = q.toQueryString();
        WhiteSpaceUtils.registerLookup(q, null, md.mockAccountId);
        String result = q.toQueryString();
        System.assertEquals(expected, result, 'Should not modify the query if no objectName passed');
    }

    @IsTest
    static void registerLookupComplexNullObjectNameTest() {
        TestMockData md = new TestMockData();
        Query q = new Query(Account.SObjectType, null);
        String expected = q.toQueryString();
        WhiteSpaceUtils.registerLookup(q, null, md.mockAccountId, true);
        WhiteSpaceUtils.registerLookup(q, null, md.mockAccountId, false);
        String result = q.toQueryString();
        System.assertEquals(
            expected,
            result,
            'Should not modify the query if no objectName passed regardless of filter flag'
        );
    }

    @IsTest
    static void registerLookupSimpleNullIdTest() {
        Query q = new Query(Account.SObjectType, null);
        String expected = q.toQueryString();
        WhiteSpaceUtils.registerLookup(q, 'Account', null);
        String result = q.toQueryString();
        System.assertEquals(expected, result, 'Should not modify the query if no id passed');
    }

    @IsTest
    static void registerLookupComplexNullIdTest() {
        Query q = new Query(Account.SObjectType, null);
        String expected = q.toQueryString();
        WhiteSpaceUtils.registerLookup(q, 'Account', null, true);
        WhiteSpaceUtils.registerLookup(q, 'Account', null, false);
        String result = q.toQueryString();
        System.assertEquals(expected, result, 'Should not modify the query if no id passed regardless of filter flag');
    }

    @IsTest
    static void registerLookupSimpleInvalidObjectNameTest() {
        TestMockData md = new TestMockData();
        Query q = new Query(Account.SObjectType, null);
        String expected = q.toQueryString();
        WhiteSpaceUtils.registerLookup(q, 'RandomObjectNameTest', md.mockAccountId);
        String result = q.toQueryString();
        System.assertNotEquals(expected, result, 'Will still modify the query if invalid objectName passed');
    }

    @IsTest
    static void registerLookupTrueInvalidObjectNameTest() {
        TestMockData md = new TestMockData();
        Query q = new Query(Account.SObjectType, null);
        String expected = q.toQueryString();
        WhiteSpaceUtils.registerLookup(q, 'RandomObjectNameTest', md.mockAccountId, true);
        String result = q.toQueryString();
        System.assertNotEquals(
            expected,
            result,
            'Will still modify the query if invalid objectName passed when filter flag is true'
        );
    }

    @IsTest
    static void registerLookupFalseInvalidObjectNameTest() {
        TestMockData md = new TestMockData();
        Query q = new Query(Account.SObjectType, null);
        String expected = q.toQueryString();
        WhiteSpaceUtils.registerLookup(q, 'RandomObjectNameTest', md.mockAccountId, false);
        String result = q.toQueryString();
        System.assertEquals(
            expected,
            result,
            'Should not modify the query if invalid objectName passed when filter flag is false'
        );
    }

    @IsTest
    static void registerLookupSimpleHappyPathTest() {
        TestMockData md = new TestMockData();
        Query q = new Query(Contact.SObjectType, null);
        String expected = q.toQueryString();
        WhiteSpaceUtils.registerLookup(q, 'Contact', md.mockAccountId);
        String result = q.toQueryString();
        System.assertNotEquals(expected, result, 'Should modify the query if valid objectName passed');
        System.assert(result.contains(md.mockAccountId), 'Query should have condition that includes the id passed in');
    }

    @IsTest
    static void registerLookupTrueHappyPathTest() {
        TestMockData md = new TestMockData();
        Query q = new Query(Contact.SObjectType, null);
        String expected = q.toQueryString();
        WhiteSpaceUtils.registerLookup(q, 'Contact', md.mockAccountId, true);
        String result = q.toQueryString();
        System.assertNotEquals(
            expected,
            result,
            'Should modify the query if valid objectName passed and filter flag is true'
        );
        System.assert(result.contains(md.mockAccountId), 'Query should have condition that includes the id passed in');
    }

    @IsTest
    static void registerLookupFalseHappyPathTest() {
        TestMockData md = new TestMockData();
        Query q = new Query(Contact.SObjectType, null);
        String expected = q.toQueryString();
        WhiteSpaceUtils.registerLookup(q, 'Contact', md.mockAccountId, false);
        String result = q.toQueryString();
        System.assertNotEquals(
            expected,
            result,
            'Should modify the query if valid objectName with relationships passed and filter flag is false'
        );
        System.assert(result.contains(md.mockAccountId), 'Query should have condition that includes the id passed in');
    }

    @IsTest
    static void registerLookupSimpleNoRelationshipsTest() {
        TestMockData md = new TestMockData();
        Query q = new Query(Product2.SObjectType, null);
        String expected = q.toQueryString();
        WhiteSpaceUtils.registerLookup(q, 'Product2', md.mockAccountId);
        String result = q.toQueryString();
        System.assertNotEquals(expected, result, 'Should modify the query even if there are no relationships');
        System.assert(result.contains(md.mockAccountId), 'Query should have condition that includes the id passed in');
    }

    @IsTest
    static void registerLookupTrueNoRelationshipsTest() {
        TestMockData md = new TestMockData();
        Query q = new Query(Product2.SObjectType, null);
        String expected = q.toQueryString();
        WhiteSpaceUtils.registerLookup(q, 'Product2', md.mockAccountId, true);
        String result = q.toQueryString();
        System.assertNotEquals(
            expected,
            result,
            'Should modify the query even if there are no relationships if filter is true'
        );
        System.assert(result.contains(md.mockAccountId), 'Query should have condition that includes the id passed in');
    }

    @IsTest
    static void registerLookupFalseFilterNoRelationshipsTest() {
        TestMockData md = new TestMockData();
        Query q = new Query(Product2.SObjectType, null);
        String expected = q.toQueryString();
        WhiteSpaceUtils.registerLookup(q, 'Product2', md.mockAccountId, false);
        String result = q.toQueryString();
        System.assertEquals(
            expected,
            result,
            'Should not modify the query if there are no relationships and filter is false'
        );
    }

    @IsTest
    static void registerLookupSimpleSameObjectTest() {
        TestMockData md = new TestMockData();
        Query q = new Query(Account.SObjectType, null);
        String expected = q.toQueryString();
        WhiteSpaceUtils.registerLookup(q, 'Account', md.mockAccountId);
        String result = q.toQueryString();
        System.assertNotEquals(expected, result, 'Should modify the query when same object is passed in');
        System.assert(result.contains(md.mockAccountId), 'Query should have condition that includes the id passed in');
    }

    @IsTest
    static void registerLookupTrueSameObjectTest() {
        TestMockData md = new TestMockData();
        Query q = new Query(Account.SObjectType, null);
        String expected = q.toQueryString();
        WhiteSpaceUtils.registerLookup(q, 'Account', md.mockAccountId, true);
        String result = q.toQueryString();
        System.assertNotEquals(
            expected,
            result,
            'Should modify the query when same object is passed in and filter is true'
        );
        System.assert(result.contains(md.mockAccountId), 'Query should have condition that includes the id passed in');
    }

    @IsTest
    static void registerLookupFalseSameObjectTest() {
        TestMockData md = new TestMockData();
        Query q = new Query(Account.SObjectType, null);
        String expected = q.toQueryString();
        WhiteSpaceUtils.registerLookup(q, 'Account', md.mockAccountId, false);
        String result = q.toQueryString();
        System.assertNotEquals(
            expected,
            result,
            'Should modify the query when same object is passed in and filter is false'
        );
        System.assert(result.contains(md.mockAccountId), 'Query should have condition that includes the id passed in');
    }

    @isTest
    static void getCellDataMapNoMatchingCellsTest() {
        TestMockData md = new TestMockData();
        Map<String, Map<String, List<SObject>>> result = WhiteSpaceUtils.getCellDataMap(
            new Set<String>{ md.mockWhiteSpaceCellId },
            new Set<String>(),
            new Set<String>(),
            null,
            false,
            new List<WhiteSpaceTemplateCellFieldWrapper>{ md.mockRelatedCellFieldWrapper },
            new List<WhiteSpaceTemplateCellFieldWrapper>(),
            new List<WhiteSpaceTemplateCellFieldWrapper>(),
            new Set<String>(),
            null
        );
        System.assertEquals(0, result.size(), 'If no data matches then empty map should be returned');
    }

    @isTest
    static void getCellDataMapHappyPathTest() {
        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;
        TestMockData md = new TestMockData();
        Map<String, Map<String, List<SObject>>> result = WhiteSpaceUtils.getCellDataMap(
            new Set<String>{ UserInfo.getUserId() },
            new Set<String>(),
            new Set<String>(),
            null,
            false,
            new List<WhiteSpaceTemplateCellFieldWrapper>{ md.mockRelatedCellFieldWrapper },
            new List<WhiteSpaceTemplateCellFieldWrapper>(),
            new List<WhiteSpaceTemplateCellFieldWrapper>(),
            new Set<String>(),
            null
        );
        System.assertEquals(1, result.size(), 'Should match the ownerId of the account');
        System.assert(result.containsKey(UserInfo.getUserId()), 'Existing key should be the passed in Id');
        System.assertEquals(1, result.get(UserInfo.getUserId()).size(), 'Should be one matching account');
    }

    @isTest
    static void getCellDataMapHappyPathWithConversionMapTest() {
        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;
        String replaceKey = 'test replacekey';
        Map<String, List<String>> conversionMap = new Map<String, List<String>>{
            UserInfo.getUserId() => new List<String>{ replaceKey }
        };
        TestMockData md = new TestMockData();
        Map<String, Map<String, List<SObject>>> result = WhiteSpaceUtils.getCellDataMap(
            new Set<String>{ UserInfo.getUserId() },
            new Set<String>(),
            new Set<String>(),
            null,
            false,
            new List<WhiteSpaceTemplateCellFieldWrapper>{ md.mockRelatedCellFieldWrapper },
            new List<WhiteSpaceTemplateCellFieldWrapper>(),
            new List<WhiteSpaceTemplateCellFieldWrapper>(),
            new Set<String>(),
            conversionMap
        );
        System.assertEquals(1, result.size(), 'Should have one key');
        System.assert(result.containsKey(replaceKey), 'replaced key should be the passed in Id');
        System.assertEquals(1, result.get(replaceKey).size(), 'Should be one matching account');
    }

    @isTest
    static void getWSRelatedObjectWrappersWithoutConfigsTest() {
        // given
        TestMockData md = new TestMockData();
        WSCellRelationshipConfigSelector selector = md.mockWSCellRelationshipConfigSelector;

        md.mocks.startStubbing();
        md.mocks.when(selector.selectAll()).thenReturn(new List<Cell_Relationship_Configuration__c>());
        md.mocks.stopStubbing();

        // when
        List<WSRelatedObjectWrapper> result = null;
        Test.startTest();
        result = WhiteSpaceUtils.getWSRelatedObjectWrappers();
        Test.stopTest();

        // then
        System.assertNotEquals(null, result, 'Should return some non null value'); //cannot really test beyond this due to not know what is set up in an org and not having anything set up in the package
    }

    @isTest
    static void getWSRelatedObjectWrappersWithConfigsTest() {
        // given
        TestMockData md = new TestMockData();
        WSCellRelationshipConfigSelector selector = md.mockWSCellRelationshipConfigSelector;

        md.mocks.startStubbing();
        md.mocks.when(selector.selectAll())
            .thenReturn(new List<Cell_Relationship_Configuration__c>{ md.mockWSCellRelationshipConfig });
        md.mocks.stopStubbing();

        // when
        List<WSRelatedObjectWrapper> result = null;
        Test.startTest();
        result = WhiteSpaceUtils.getWSRelatedObjectWrappers();
        Test.stopTest();

        // then
        System.assertNotEquals(null, result, 'Should return some non null value'); //cannot really test beyond this due to not know what is set up in an org and not having anything set up in the package
    }

    @isTest
    static void isAnyPicklistMappingTypeTest() {
        Boolean result = WhiteSpaceUtils.isAnyPicklistMappingType(null, null);
        system.assertEquals(false, result);

        result = WhiteSpaceUtils.isAnyPicklistMappingType(null, 'Type');
        system.assertEquals(false, result);

        result = WhiteSpaceUtils.isAnyPicklistMappingType(ACCOUNT_MAPPING, null);
        system.assertEquals(false, result);

        result = WhiteSpaceUtils.isAnyPicklistMappingType(ACCOUNT_MAPPING, 'Id');
        system.assertEquals(false, result);

        result = WhiteSpaceUtils.isAnyPicklistMappingType(ACCOUNT_MAPPING, 'Type');
        system.assertEquals(true, result);

        // Invalid test, unable to create a wrapper with an invalid object name so can never reach this situation
        // WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper('pq_test_fakeObject__c', 'Name', null);
        // result = WhiteSpaceUtils.isAnyPicklistMappingType(wrapper, null);
        // system.assertEquals(false, result);

        // Invalid test, unable to create a wrapper with an invalid label field name so can never reach this situation
        // WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper('Account', 'pq_test_fakeField__c', null);
        // result = WhiteSpaceUtils.isAnyPicklistMappingType(wrapper, null);
        // system.assertEquals(false, result);

        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper('Account', null, null);
        result = WhiteSpaceUtils.isAnyPicklistMappingType(wrapper, null);
        system.assertEquals(false, result);

        wrapper = new WhiteSpaceTemplateMappingWrapper(null, 'Name', null);
        result = WhiteSpaceUtils.isAnyPicklistMappingType(wrapper, null);
        system.assertEquals(false, result);

        wrapper = new WhiteSpaceTemplateMappingWrapper('Account', 'Type', null);
        result = WhiteSpaceUtils.isAnyPicklistMappingType(wrapper, null);
        system.assertEquals(true, result);

        result = WhiteSpaceUtils.isAnyPicklistMappingType(wrapper, 'Name');
        system.assertEquals(false, result);
    }

    @isTest
    static void isGroupMappingTypeObjectTest() {
        Mapping__c mapping = null;

        System.assert(!WhiteSpaceUtils.isGroupMappingType(mapping), 'Should return false if passed null');

        TestMockData md = new TestMockData();
        mapping = md.mockOppMapping;
        mapping.GroupResults__c = false;

        System.assert(!WhiteSpaceUtils.isGroupMappingType(mapping), 'Should return false if GroupResults__c is false');

        mapping.GroupResults__c = true;
        System.assert(WhiteSpaceUtils.isGroupMappingType(mapping), 'Should return true if GroupResults__c is true');
    }

    @isTest
    static void isGroupMappingTypeWrapperTest() {
        WhiteSpaceTemplateWrapper.HeaderConfiguration wrapper = null;

        System.assert(!WhiteSpaceUtils.isGroupMappingType(wrapper), 'Should return false if passed null');

        wrapper = new WhiteSpaceTemplateWrapper.HeaderConfiguration();
        System.assert(!WhiteSpaceUtils.isGroupMappingType(wrapper), 'Should return false if wrapper has no mapping');

        TestMockData md = new TestMockData();
        wrapper = new WhiteSpaceTemplateWrapper.HeaderConfiguration(md.mockOppMapping, false);
        wrapper.mapping.groupResults = false;

        System.assert(!WhiteSpaceUtils.isGroupMappingType(wrapper), 'Should return false if groupResults is false');

        wrapper.mapping.groupResults = true;
        System.assert(WhiteSpaceUtils.isGroupMappingType(wrapper), 'Should return true if groupResults is true');
    }

    @isTest
    static void registerConditionsCUSTOMTest() {
        WhiteSpaceTemplateMappingWrapper mapping = TestDataFactory.createWhiteSpaceTemplateMappingWrapper(
            '(A AND B) OR C'
        );
        Query queryObj = new Query(Asset.SObjectType, null);

        Test.startTest();
        WhiteSpaceUtils.registerConditions(queryObj, mapping);
        Test.stopTest();

        Assert.areNotEqual(queryObj, new Query(Asset.SObjectType, null), '"queryObj" not expected same.');
    }
    @isTest
    static void registerConditionsANDTest() {
        WhiteSpaceTemplateMappingWrapper mapping = TestDataFactory.createWhiteSpaceTemplateMappingWrapper('AND');
        Query queryObj = new Query(Asset.SObjectType, null);

        Test.startTest();
        WhiteSpaceUtils.registerConditions(queryObj, mapping);
        Test.stopTest();

        Assert.areNotEqual(queryObj, new Query(Asset.SObjectType, null), '"queryObj" not expected same.');
    }
    @isTest
    static void registerConditionsORTest() {
        WhiteSpaceTemplateMappingWrapper mapping = TestDataFactory.createWhiteSpaceTemplateMappingWrapper('OR');
        Query queryObj = new Query(Asset.SObjectType, null);

        Test.startTest();
        WhiteSpaceUtils.registerConditions(queryObj, mapping);
        Test.stopTest();

        Assert.areNotEqual(queryObj, new Query(Asset.SObjectType, null), '"queryObj" not expected same.');
    }
}