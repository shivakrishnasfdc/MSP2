@isTest
private with sharing class WhiteSpaceFromTemplateTest {
    private static final String USER1_FIRST_NAME = 'admin';
    private static final String USER1_LAST_NAME = 'adam';

    private static final String USER2_FIRST_NAME = 'standard';
    private static final String USER2_LAST_NAME = 'suzie';

    private static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';
    private static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    public static final String STANDARD_USER = 'Standard User';

    public static final String WHITE_SPACE_NAME = 'testWs';
    public static final String WHITE_SPACE_PICKLIST_NAME = 'testPicklistWs';
    public static final String WHITE_SPACE_GROUP_NAME = 'testGroupWs';

    public static final String WHITE_SPACE_TEMPLATE_NAME = 'testTemplate';
    public static final String WHITE_SPACE_PICKLIST_TEMPLATE_NAME = 'testPicklistTemplate';
    public static final String WHITE_SPACE_GROUP_TEMPLATE_NAME = 'testGroupTemplate';

    public static final String ACCOUNT_PLAN1_NAME = 'AccountPlan1';
    public static final String ACCOUNT1_NAME = 'zzzzAccount 1';

    @testSetup
    static void testSetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];
        User adminUser = TestDataFactory.createUser(USER1_FIRST_NAME, USER1_LAST_NAME, p.Id);
        User standardUser = TestDataFactory.createUser(USER2_FIRST_NAME, USER2_LAST_NAME, p.Id);

        PermissionSet standardUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_STANDARD_USER];
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = standardUser.Id, PermissionSetId = standardUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = adminUserPermissionSet.Id)
        };

        System.runAs(adminUser) {
            AccountPlans.bypassEmailTrigger = true;
            Account testAccount1 = new Account(Name = ACCOUNT1_NAME);
            insert testAccount1;
            Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan(ACCOUNT_PLAN1_NAME, testAccount1);

            White_Space_Template__c template = TestDataFactory.createWhiteSpaceTemplate(
                WHITE_SPACE_TEMPLATE_NAME,
                'Product2',
                'Name',
                'Account',
                'Name'
            );

            TestDataFactory.createWhiteSpaceFromTemplate(accountPlan1, template, WHITE_SPACE_NAME);

            // Template with picklist value columns
            Mapping__c columnMapping = new Mapping__c(
                Name = 'column',
                ObjectType__c = 'Opportunity',
                ValueField__c = 'Type'
            );

            Mapping__c rowMapping = new Mapping__c(
                Name = 'row',
                ObjectType__c = 'Account',
                DisplayLabelField__c = 'Name'
            );

            White_Space_Template__c picklistTemplate = TestDataFactory.createWhiteSpaceTemplate(
                WHITE_SPACE_PICKLIST_TEMPLATE_NAME,
                columnMapping,
                rowMapping
            );
            TestDataFactory.createWhiteSpaceFromTemplate(accountPlan1, picklistTemplate, WHITE_SPACE_PICKLIST_NAME);

            // Template with grouped value columns
            Mapping__c columnGroupMapping = new Mapping__c(
                Name = 'column',
                ObjectType__c = 'Opportunity',
                DisplayLabelField__c = 'Type',
                GroupResults__c = true
            );

            Mapping__c rowGroupMapping = new Mapping__c(
                Name = 'row',
                ObjectType__c = 'Account',
                DisplayLabelField__c = 'Name'
            );

            White_Space_Template__c groupTemplate = TestDataFactory.createWhiteSpaceTemplate(
                WHITE_SPACE_GROUP_TEMPLATE_NAME,
                columnGroupMapping,
                rowGroupMapping
            );
            TestDataFactory.createWhiteSpaceFromTemplate(accountPlan1, groupTemplate, WHITE_SPACE_GROUP_NAME);
        }
    }

    @isTest
    private static void canInstantiateTest() {
        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_TEMPLATE_NAME);

        WhiteSpaceFromTemplate result = new WhiteSpaceFromTemplate(whiteSpace, template);

        system.assertEquals(WhiteSpaceFromTemplate.type, result.type);
    }

    @isTest
    private static void canBuildTest() {
        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_TEMPLATE_NAME);

        WhiteSpaceAbstract result = new WhiteSpaceFromTemplate(whiteSpace, template).build();

        system.assertNotEquals(null, result);
    }

    @isTest
    private static void canBuildGroupTest() {
        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_GROUP_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_GROUP_TEMPLATE_NAME);

        WhiteSpaceAbstract result = new WhiteSpaceFromTemplate(whiteSpace, template).build();

        system.assertNotEquals(null, result);
    }

    @isTest
    static void canAddRowsAndColumnsDynamically() {
        AccountPlans.bypassEmailTrigger = true;
        //The codepath of the method being tested has dynamic queries that cannot be mocked so using actual data
        List<SObject> objectsForTest = new List<SObject>();
        String accName1 = 'Test_Account_1';
        String accName2 = 'Test_Account_2456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789';
        String accName3 = 'Test_Account_3';
        String prodName1 = 'Test_Product_1';
        String prodName2 = 'Test_Product_2456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789';
        String prodName3 = 'Test_Product_3';
        objectsForTest.add(new Schema.Account(Name = accName3));
        objectsForTest.add(new Schema.Account(Name = accName1));
        objectsForTest.add(new Schema.Product2(Name = prodName3));
        objectsForTest.add(new Schema.Product2(Name = prodName1));
        Database.insert(objectsForTest);

        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_TEMPLATE_NAME);

        new WhiteSpaceFromTemplate(whiteSpace, template).build();

        Database.insert(new Schema.Account(Name = accName2));
        Database.insert(new Schema.Product2(Name = prodName2));

        Test.startTest();
        WhiteSpaceAbstract result = new WhiteSpaceFromTemplate(whiteSpace, template).build();
        Test.stopTest();

        System.assertEquals(
            4,
            result.rows.size(),
            'Should have four rows (two original accounts + one account related to the plan + one new account)'
        );
        System.assertEquals(accName1, result.rows[0].name, 'Rows should be ordered by name [0]');
        System.assertEquals(accName2, result.rows[1].name, 'Rows should be ordered by name [1]');
        System.assertEquals(accName3, result.rows[2].name, 'Rows should be ordered by name [2]');
        System.assertEquals(3, result.columns.size(), 'Should have three columns (two original + one new)');
        System.assertEquals(prodName1, result.columns[0].name, 'Columns should be ordered by name [0]');
        System.assertEquals(prodName2, result.columns[1].name, 'Columns should be ordered by name [1]');
        System.assertEquals(prodName3, result.columns[2].name, 'Columns should be ordered by name [2]');
    }

    @isTest
    static void canBuildWithPicklistValueColumnsDynamically() {
        AccountPlans.bypassEmailTrigger = true;
        //The codepath of the method being tested has dynamic queries that cannot be mocked so using actual data
        List<SObject> objectsForTest = new List<SObject>();
        String accName1 = 'Test_Account_1';
        String accName2 = 'Test_Account_2456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789';
        String accName3 = 'Test_Account_3';
        objectsForTest.add(new Schema.Account(Name = accName3));
        objectsForTest.add(new Schema.Account(Name = accName1));
        Database.insert(objectsForTest);

        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_PICKLIST_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_PICKLIST_TEMPLATE_NAME);

        new WhiteSpaceFromTemplate(whiteSpace, template).build();

        Database.insert(new Schema.Account(Name = accName2));

        Test.startTest();
        WhiteSpaceAbstract result = new WhiteSpaceFromTemplate(whiteSpace, template).build();
        Test.stopTest();

        System.assertEquals(
            4,
            result.rows.size(),
            'Should have four rows (two original accounts + one account related to the plan + one new account)'
        );
        System.assertEquals(accName1, result.rows[0].name, 'Rows should be ordered by name [0]');
        System.assertEquals(accName2, result.rows[1].name, 'Rows should be ordered by name [1]');
        System.assertEquals(accName3, result.rows[2].name, 'Rows should be ordered by name [2]');

        Integer expectedColumnSize = UtilityForSObject.getPicklistSelectOptions(
                template.ColumnMapping__r.ObjectType__c,
                template.ColumnMapping__r.ValueField__c
            )
            .size();
        System.assertEquals(
            expectedColumnSize,
            result.columns.size(),
            'Should have same number of columns as values for picklist field)'
        );
    }

    @isTest
    static void canDeleteRowsAndColumnsDynamically() {
        AccountPlans.bypassEmailTrigger = true;
        //The codepath of the method being tested has dynamic queries that cannot be mocked so using actual data
        List<SObject> objectsForTest = new List<SObject>();
        objectsForTest.add(new Schema.Account(Name = 'Test_Account_1'));
        Schema.Account accDelete = new Schema.Account(Name = 'Test_Account_2');
        objectsForTest.add(accDelete);
        objectsForTest.add(new Schema.Product2(Name = 'Test_Product_1'));
        Product2 productDelete = new Schema.Product2(Name = 'Test_Product_2');
        objectsForTest.add(productDelete);
        Database.insert(objectsForTest);

        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_TEMPLATE_NAME);

        new WhiteSpaceFromTemplate(whiteSpace, template).build();

        Database.delete(accDelete);
        Database.delete(productDelete);

        Test.startTest();
        WhiteSpaceAbstract result = new WhiteSpaceFromTemplate(whiteSpace, template).build();
        Test.stopTest();

        System.assertEquals(
            2,
            result.rows.size(),
            'Should have two rows (two original accounts + one account related to the plan - one deleted account)'
        );
        System.assertEquals(1, result.columns.size(), 'Should have one column (two original - one deleted)');
    }

    @isTest
    static void orderRowColumnsByObjectsTest() {
        //The codepath of the method being tested has dynamic queries that cannot be mocked so using actual data
        List<SObject> objectsForTest = new List<SObject>();
        String contactName1 = 'Test_Contact_a';
        String contactName2 = 'Test_Contact_b';
        String contactNameMiddle = 'Test_Contact_c';
        String contactNameLast = 'Test_Contact_d';
        String contactNameWouldBeLast = 'zzz_Test_Contact';
        Contact parentContact = new Schema.Contact(LastName = contactNameMiddle);
        Contact childContact = new Schema.Contact(LastName = contactNameWouldBeLast);
        objectsForTest.add(new Schema.Contact(LastName = contactNameLast));
        objectsForTest.add(new Schema.Contact(LastName = contactName1));
        objectsForTest.add(new Schema.Contact(LastName = contactName2));
        objectsForTest.add(childContact);
        objectsForTest.add(parentContact);
        objectsForTest.add(new Schema.Product2(Name = 'Test_Product_1'));
        Database.insert(objectsForTest);
        childContact.ReportsToId = parentContact.Id;
        Database.update(childContact);
        Account_Plan__c plan = [SELECT Id, Name FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
        White_Space_Template__c template = TestDataFactory.createWhiteSpaceTemplate(
            'The_Test_Template',
            'Product2',
            'Name',
            null,
            'Contact',
            'LastName',
            'ReportsToId'
        );

        White_Space__c whiteSpace = TestDataFactory.createWhiteSpaceFromTemplate(plan, template, WHITE_SPACE_NAME);

        Test.startTest();
        WhiteSpaceAbstract result = new WhiteSpaceFromTemplate(whiteSpace, template).build();
        Test.stopTest();

        System.assertEquals(5, result.rows.size(), 'Should have five rows');
        System.assertEquals(contactName1, result.rows[0].name, 'Rows should be ordered by name [0]');
        System.assertEquals(contactName2, result.rows[1].name, 'Rows should be ordered by name [1]');
        System.assertEquals(contactNameMiddle, result.rows[2].name, 'Rows should be ordered by name [2]');
        System.assertEquals(
            contactNameWouldBeLast,
            result.rows[3].name,
            'Child row should immediately follow parent [3]'
        );
        System.assertEquals(contactNameLast, result.rows[4].name, 'Rows should be ordered by name [4]');
    }

    @isTest
    static void fillRelatedRecordsListMapForGroupedHeaderTypeEmptyResultsTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceUtilsImpl mockWSUtils = md.mockWhiteSpaceUtils;
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        String key = 'rows';

        md.mocks.startStubbing();
        md.mocks.when(mockWSUtils.getResults(wrapper, null)).thenReturn(new List<SObject>());
        md.mocks.when(mockWSUtils.getWSRelatedObjectWrappers()).thenReturn(new List<WSRelatedObjectWrapper>());
        md.mocks.stopStubbing();

        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_TEMPLATE_NAME);

        WhiteSpaceFromTemplate wsft = new WhiteSpaceFromTemplate(whiteSpace, template);

        Map<String, List<SObject>> result = wsft.fillRelatedRecordsListMapForGroupedHeaderType(key, wrapper, false);

        System.assertEquals(0, result.keySet().size(), 'Empty object list should give empty map');
        System.assertEquals(
            wsft.relatedGroupedRecordsMap.get(key),
            result,
            'Should save result to key of groupedResultsMap'
        );
    }

    @isTest
    static void fillRelatedRecordsListMapForGroupedHeaderTypeWithRowResultsTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceUtilsImpl mockWSUtils = md.mockWhiteSpaceUtils;
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        String key = 'rows';

        String nameOneMatch = 'frrlmfghtwrt_Name One Match';
        String nameTwoMatch = 'frrlmfghtwrt_Name Two Match';

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = nameOneMatch),
            new Opportunity(Name = nameTwoMatch),
            new Opportunity(Name = nameTwoMatch)
        };

        md.mocks.startStubbing();
        md.mocks.when(mockWSUtils.getResults(wrapper, null)).thenReturn(opps);
        md.mocks.when(mockWSUtils.getWSRelatedObjectWrappers()).thenReturn(new List<WSRelatedObjectWrapper>()); //accessed in base class during initialization
        md.mocks.when(mockWSUtils.isMultiPicklistMappingType(wrapper, wrapper.labelFieldName)).thenReturn(false);
        md.mocks.stopStubbing();

        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_TEMPLATE_NAME);

        WhiteSpaceFromTemplate wsft = new WhiteSpaceFromTemplate(whiteSpace, template);

        Map<String, List<SObject>> result = wsft.fillRelatedRecordsListMapForGroupedHeaderType(key, wrapper, false);

        System.assertEquals(2, result.keySet().size(), 'Result map should have two keys, one for each Name');
        System.assertEquals(1, result.get(nameOneMatch).size(), 'Should have one opp matching the first name');
        System.assertEquals(2, result.get(nameTwoMatch).size(), 'Should have two opps matching the second name');
        System.assertEquals(
            wsft.relatedGroupedRecordsMap.get(key),
            result,
            'Should save result to key of groupedResultsMap'
        );
    }

    @isTest
    static void fillRelatedRecordsListMapForGroupedHeaderTypeWithColumnResultsTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceUtilsImpl mockWSUtils = md.mockWhiteSpaceUtils;
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        String key = 'columns';

        String nameOneMatch = 'frrlmfghtwrt_Name One Match';
        String nameTwoMatch = 'frrlmfghtwrt_Name Two Match';

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = nameOneMatch),
            new Opportunity(Name = nameTwoMatch),
            new Opportunity(Name = nameTwoMatch)
        };

        md.mocks.startStubbing();
        md.mocks.when(mockWSUtils.getResults(wrapper, null)).thenReturn(opps);
        md.mocks.when(mockWSUtils.getWSRelatedObjectWrappers()).thenReturn(new List<WSRelatedObjectWrapper>()); //accessed in base class during initialization
        md.mocks.when(mockWSUtils.isMultiPicklistMappingType(wrapper, wrapper.labelFieldName)).thenReturn(false);
        md.mocks.stopStubbing();

        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_TEMPLATE_NAME);

        WhiteSpaceFromTemplate wsft = new WhiteSpaceFromTemplate(whiteSpace, template);

        Map<String, List<SObject>> result = wsft.fillRelatedRecordsListMapForGroupedHeaderType(key, wrapper, false);

        System.assertEquals(2, result.keySet().size(), 'Result map should have two keys, one for each Name');
        System.assertEquals(1, result.get(nameOneMatch).size(), 'Should have one opp matching the first name');
        System.assertEquals(2, result.get(nameTwoMatch).size(), 'Should have two opps matching the second name');
        System.assertEquals(
            wsft.relatedGroupedRecordsMap.get(key),
            result,
            'Should save result to key of groupedResultsMap'
        );
    }

    @isTest
    static void fillRelatedRecordsListMapForGroupedHeaderTypeMultipicklistTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceUtilsImpl mockWSUtils = md.mockWhiteSpaceUtils;
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        String key = 'columns';

        String nameOneMatch = 'frrlmfghtwrt_Name One Match';
        String multi1 = 'frrlmfghtwrt_Name';
        String multi2 = 'Two';
        String multi3 = 'Match';

        String nameTwoMatch = 'frrlmfghtwrt_Name;Two;Match';

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = nameOneMatch),
            new Opportunity(Name = multi1 + ';' + multi3),
            new Opportunity(Name = nameTwoMatch)
        };

        md.mocks.startStubbing();
        md.mocks.when(mockWSUtils.getResults(wrapper, null)).thenReturn(opps);
        md.mocks.when(mockWSUtils.getWSRelatedObjectWrappers()).thenReturn(new List<WSRelatedObjectWrapper>()); //accessed in base class during initialization
        md.mocks.when(mockWSUtils.isMultiPicklistMappingType(wrapper, wrapper.labelFieldName)).thenReturn(true);
        md.mocks.stopStubbing();

        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_TEMPLATE_NAME);

        WhiteSpaceFromTemplate wsft = new WhiteSpaceFromTemplate(whiteSpace, template);

        Map<String, List<SObject>> result = wsft.fillRelatedRecordsListMapForGroupedHeaderType(key, wrapper, false);

        System.assertEquals(4, result.keySet().size(), 'Result map should have two keys, one for each Name');
        System.assertEquals(1, result.get(nameOneMatch).size(), 'Should have one opp matching the first name');
        System.assertEquals(2, result.get(multi1).size(), 'Should have two opps matching the first multipart');
        System.assertEquals(1, result.get(multi2).size(), 'Should have one opps matching the second multipart');
        System.assertEquals(2, result.get(multi3).size(), 'Should have two opps matching the third multipart');
        System.assertEquals(
            wsft.relatedGroupedRecordsMap.get(key),
            result,
            'Should save result to key of groupedResultsMap'
        );
    }

    @isTest
    static void buildHeaderComponentsPicklistEmptyTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceUtilsImpl mockWSUtils = md.mockWhiteSpaceUtils;
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        String key = 'rows';
        List<SObject> rowObjects = new List<SObject>();

        md.mocks.startStubbing();
        md.mocks.when(mockWSUtils.getWSRelatedObjectWrappers()).thenReturn(new List<WSRelatedObjectWrapper>());
        md.mocks.when(mockWSUtils.isPicklistMappingType(wrapper)).thenReturn(true);
        md.mocks.when(mockWSUtils.isGroupMappingType(wrapper)).thenReturn(false);
        md.mocks.stopStubbing();

        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_TEMPLATE_NAME);

        WhiteSpaceFromTemplate wsft = new WhiteSpaceFromTemplate(whiteSpace, template);

        List<WhiteSpaceCollectionWrapper> result = wsft.buildHeaderComponents(key, rowObjects, wrapper);

        System.assertEquals(0, result.size(), 'Result list should be empty if no objects passed in');
    }

    @isTest
    static void buildHeaderComponentsPicklistTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceUtilsImpl mockWSUtils = md.mockWhiteSpaceUtils;
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        String key = 'rows';
        White_Space_Row__c row1 = md.mockWhiteSpaceRow.clone();
        row1.pqcrush__Related_Object_Id__c = 'bhcpt_value1';
        White_Space_Row__c row2 = md.mockWhiteSpaceRow.clone();
        row2.pqcrush__Related_Object_Id__c = 'bhcpt_value2';
        List<SObject> rowObjects = new List<SObject>{ row1, row2 };
        Map<String, String> fieldMap = new Map<String, String>{
            'bhcpt_value1' => 'label1',
            'bhcpt_value2' => 'label2'
        };

        md.mocks.startStubbing();
        md.mocks.when(mockWSUtils.getWSRelatedObjectWrappers()).thenReturn(new List<WSRelatedObjectWrapper>());
        md.mocks.when(mockWSUtils.isPicklistMappingType(wrapper)).thenReturn(true);
        md.mocks.when(mockWSUtils.isGroupMappingType(wrapper)).thenReturn(false);
        md.mocks.stopStubbing();

        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_TEMPLATE_NAME);

        WhiteSpaceFromTemplate wsft = new WhiteSpaceFromTemplate(whiteSpace, template);
        wsft.relatedPicklistValuesMap.put(key, fieldMap);

        List<WhiteSpaceCollectionWrapper> result = wsft.buildHeaderComponents(key, rowObjects, wrapper);

        System.assertEquals(2, result.size(), 'Result list should have two items');
    }

    @isTest
    static void buildHeaderComponentsStandardEmptyTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceUtilsImpl mockWSUtils = md.mockWhiteSpaceUtils;
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        String key = 'rows';
        List<SObject> rowObjects = new List<SObject>();

        md.mocks.startStubbing();
        md.mocks.when(mockWSUtils.getWSRelatedObjectWrappers()).thenReturn(new List<WSRelatedObjectWrapper>());
        md.mocks.when(mockWSUtils.isPicklistMappingType(wrapper)).thenReturn(false);
        md.mocks.when(mockWSUtils.isGroupMappingType(wrapper)).thenReturn(false);
        md.mocks.stopStubbing();

        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_TEMPLATE_NAME);

        WhiteSpaceFromTemplate wsft = new WhiteSpaceFromTemplate(whiteSpace, template);

        List<WhiteSpaceCollectionWrapper> result = wsft.buildHeaderComponents(key, rowObjects, wrapper);

        System.assertEquals(0, result.size(), 'Result list should be empty if no objects passed in');
    }

    @isTest
    static void buildHeaderComponentsStandardTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceUtilsImpl mockWSUtils = md.mockWhiteSpaceUtils;
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        String key = 'rows';
        md.mockWhiteSpaceRow.pqcrush__Related_Object_Id__c = md.mockOpportunityId;
        List<SObject> rowObjects = new List<SObject>{ md.mockWhiteSpaceRow };
        List<Opportunity> opps = new List<Opportunity>{ md.mockOpportunity };

        md.mocks.startStubbing();
        md.mocks.when(mockWSUtils.getWSRelatedObjectWrappers()).thenReturn(new List<WSRelatedObjectWrapper>());
        md.mocks.when(mockWSUtils.isPicklistMappingType(wrapper)).thenReturn(false);
        md.mocks.when(mockWSUtils.isGroupMappingType(wrapper)).thenReturn(false);
        md.mocks.stopStubbing();

        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_TEMPLATE_NAME);

        WhiteSpaceFromTemplate wsft = new WhiteSpaceFromTemplate(whiteSpace, template);
        wsft.relatedRecordsMap.put(key, opps);

        List<WhiteSpaceCollectionWrapper> result = wsft.buildHeaderComponents(key, rowObjects, wrapper);

        System.assertEquals(1, result.size(), 'Result list should have one result');
    }

    @isTest
    static void buildHeaderComponentsGroupedEmptyTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceUtilsImpl mockWSUtils = md.mockWhiteSpaceUtils;
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        String key = 'rows';
        List<SObject> rowObjects = new List<SObject>();

        md.mocks.startStubbing();
        md.mocks.when(mockWSUtils.getWSRelatedObjectWrappers()).thenReturn(new List<WSRelatedObjectWrapper>());
        md.mocks.when(mockWSUtils.isPicklistMappingType(wrapper)).thenReturn(false);
        md.mocks.when(mockWSUtils.isGroupMappingType(wrapper)).thenReturn(true);
        md.mocks.stopStubbing();

        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_TEMPLATE_NAME);

        WhiteSpaceFromTemplate wsft = new WhiteSpaceFromTemplate(whiteSpace, template);

        List<WhiteSpaceCollectionWrapper> result = wsft.buildHeaderComponents(key, rowObjects, wrapper);

        System.assertEquals(0, result.size(), 'Result list should be empty if no objects passed in');
    }

    @isTest
    static void buildHeaderComponentsGroupedTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceUtilsImpl mockWSUtils = md.mockWhiteSpaceUtils;
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        String key = 'rows';
        String relatedObjectId = 'bhcgt_relatedId';
        md.mockWhiteSpaceRow.pqcrush__Related_Object_Id__c = relatedObjectId;
        List<SObject> rowObjects = new List<SObject>{ md.mockWhiteSpaceRow };
        Opportunity opp1 = md.mockOpportunity.clone();
        opp1.Id = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Opportunity opp2 = md.mockOpportunity.clone();
        opp2.Id = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Opportunity> opps = new List<Opportunity>{ opp1, opp2 };

        md.mocks.startStubbing();
        md.mocks.when(mockWSUtils.getWSRelatedObjectWrappers()).thenReturn(new List<WSRelatedObjectWrapper>());
        md.mocks.when(mockWSUtils.isPicklistMappingType(wrapper)).thenReturn(false);
        md.mocks.when(mockWSUtils.isGroupMappingType(wrapper)).thenReturn(true);
        md.mocks.stopStubbing();

        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_TEMPLATE_NAME);

        WhiteSpaceFromTemplate wsft = new WhiteSpaceFromTemplate(whiteSpace, template);
        wsft.relatedGroupedRecordsMap.put(key, new Map<String, List<Opportunity>>{ relatedObjectId => opps });

        List<WhiteSpaceCollectionWrapper> result = wsft.buildHeaderComponents(key, rowObjects, wrapper);

        System.assertEquals(1, result.size(), 'Result list should have one result');
        System.assertEquals(
            2,
            result[0].groupedRelatedRecordIds.size(),
            'Row wrapper should have two matching group related Ids'
        );
    }

    @isTest
    static void buildHeaderComponentsGroupedWithoutMatchTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceUtilsImpl mockWSUtils = md.mockWhiteSpaceUtils;
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        String key = 'rows';
        String relatedObjectId = 'bhcgt_relatedId';
        md.mockWhiteSpaceRow.pqcrush__Related_Object_Id__c = relatedObjectId;
        List<SObject> rowObjects = new List<SObject>{ md.mockWhiteSpaceRow };

        md.mocks.startStubbing();
        md.mocks.when(mockWSUtils.getWSRelatedObjectWrappers()).thenReturn(new List<WSRelatedObjectWrapper>());
        md.mocks.when(mockWSUtils.isPicklistMappingType(wrapper)).thenReturn(false);
        md.mocks.when(mockWSUtils.isGroupMappingType(wrapper)).thenReturn(true);
        md.mocks.stopStubbing();

        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_TEMPLATE_NAME);

        WhiteSpaceFromTemplate wsft = new WhiteSpaceFromTemplate(whiteSpace, template);

        List<WhiteSpaceCollectionWrapper> result = wsft.buildHeaderComponents(key, rowObjects, wrapper);

        System.assertEquals(1, result.size(), 'Result list should have one result');
        System.assertEquals(
            0,
            result[0].groupedRelatedRecordIds.size(),
            'Row wrapper should have null group related Ids'
        );
    }

    @isTest
    static void updateGroupedHeadersEmptyRowTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceServiceImpl mockWSService = md.mockWhiteSpaceService;

        List<White_Space_Row__c> rowOrColumns = new List<White_Space_Row__c>();
        Map<String, List<SObject>> allMatchingRecordsMap = new Map<String, List<SObject>>();

        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_TEMPLATE_NAME);

        WhiteSpaceFromTemplate wsft = new WhiteSpaceFromTemplate(whiteSpace, template);
        wsft.updateGroupedHeaders(rowOrColumns, allMatchingRecordsMap);
        ((WhiteSpaceServiceImpl) md.mocks.verify(mockWSService, 1))
            .createWhiteSpaceRows((List<White_Space_Row__c>) fflib_Match.listIsEmpty());
        ((WhiteSpaceServiceImpl) md.mocks.verify(mockWSService, 0))
            .createWhiteSpaceColumns((List<White_Space_Column__c>) fflib_Match.anyList());
        System.assert(true, 'verified by mocks');
    }

    @isTest
    static void updateGroupedHeadersEmptyColumnTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceServiceImpl mockWSService = md.mockWhiteSpaceService;

        List<White_Space_Column__c> rowOrColumns = new List<White_Space_Column__c>();
        Map<String, List<SObject>> allMatchingRecordsMap = new Map<String, List<SObject>>();

        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_TEMPLATE_NAME);

        WhiteSpaceFromTemplate wsft = new WhiteSpaceFromTemplate(whiteSpace, template);
        wsft.updateGroupedHeaders(rowOrColumns, allMatchingRecordsMap);
        ((WhiteSpaceServiceImpl) md.mocks.verify(mockWSService, 0))
            .createWhiteSpaceRows((List<White_Space_Row__c>) fflib_Match.anyList());
        ((WhiteSpaceServiceImpl) md.mocks.verify(mockWSService, 1))
            .createWhiteSpaceColumns((List<White_Space_Column__c>) fflib_Match.listIsEmpty());
        System.assert(true, 'verified by mocks');
    }

    @isTest
    static void updateGroupedHeadersNoCreateTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceServiceImpl mockWSService = md.mockWhiteSpaceService;

        md.mockWhiteSpaceRow.Related_Object_Id__c = md.mockOpportunityId;
        List<White_Space_Row__c> rowOrColumns = new List<White_Space_Row__c>{ md.mockWhiteSpaceRow };
        Map<String, List<SObject>> allMatchingRecordsMap = new Map<String, List<SObject>>{
            md.mockOpportunityId => new List<SObject>{ md.mockOpportunity }
        };

        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_TEMPLATE_NAME);

        WhiteSpaceFromTemplate wsft = new WhiteSpaceFromTemplate(whiteSpace, template);
        wsft.updateGroupedHeaders(rowOrColumns, allMatchingRecordsMap);
        ((WhiteSpaceServiceImpl) md.mocks.verify(mockWSService, 1))
            .createWhiteSpaceRows((List<White_Space_Row__c>) fflib_Match.listIsEmpty());
        ((WhiteSpaceServiceImpl) md.mocks.verify(mockWSService, 0))
            .createWhiteSpaceColumns((List<White_Space_Column__c>) fflib_Match.anyList());
        System.assert(true, 'verified by mocks');
    }

    @isTest
    static void updateGroupedHeadersNeedsCreateTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceServiceImpl mockWSService = md.mockWhiteSpaceService;

        List<White_Space_Row__c> rowOrColumns = new List<White_Space_Row__c>();
        Map<String, List<SObject>> allMatchingRecordsMap = new Map<String, List<SObject>>{
            md.mockOpportunityId => new List<SObject>{ md.mockOpportunity }
        };

        White_Space__c whiteSpace = getWhiteSpace(WHITE_SPACE_NAME);
        White_Space_Template__c template = getTemplate(WHITE_SPACE_TEMPLATE_NAME);

        WhiteSpaceFromTemplate wsft = new WhiteSpaceFromTemplate(whiteSpace, template);
        wsft.updateGroupedHeaders(rowOrColumns, allMatchingRecordsMap);
        ((WhiteSpaceServiceImpl) md.mocks.verify(mockWSService, 0))
            .createWhiteSpaceRows((List<White_Space_Row__c>) fflib_Match.listIsEmpty());
        ((WhiteSpaceServiceImpl) md.mocks.verify(mockWSService, 1))
            .createWhiteSpaceRows((List<White_Space_Row__c>) fflib_Match.anyList());
        ((WhiteSpaceServiceImpl) md.mocks.verify(mockWSService, 0))
            .createWhiteSpaceColumns((List<White_Space_Column__c>) fflib_Match.anyList());
        System.assert(true, 'verified by mocks');
    }

    private static White_Space__c getWhiteSpace(String whiteSpaceName) {
        return [
            SELECT
                Id,
                Name,
                Account_Plan__c,
                White_Space_Template__c,
                AreColumnsFiltered__c,
                AreRowsFiltered__c,
                AreCellsFiltered__c,
                AreUnrelatedCellsFiltered__c
            FROM White_Space__c
            WHERE Name = :whiteSpaceName
            LIMIT 1
        ];
    }

    private static White_Space_Template__c getTemplate(String templateName) {
        return [
            SELECT
                Id,
                Name,
                Column_Object_Name__c,
                Column_Label_Field_Name__c,
                ColumnMapping__c,
                ColumnMapping__r.ObjectType__c,
                ColumnMapping__r.ValueField__c,
                Row_Object_Name__c,
                Row_Label_Field_Name__c,
                RowMapping__c,
                RowMapping__r.ObjectType__c,
                RowMapping__r.ValueField__c,
                hasDependentPicklistColumns__c,
                hasDependentPicklistRows__c,
                isLegacy__c
            FROM White_Space_Template__c
            WHERE Name = :templateName
            LIMIT 1
        ];
    }
}