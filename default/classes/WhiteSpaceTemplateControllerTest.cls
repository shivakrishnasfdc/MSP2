@isTest
private class WhiteSpaceTemplateControllerTest {
    public static final String USER1_FIRST_NAME = 'admin';
    public static final String USER1_LAST_NAME = 'adam';

    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    public static final String WHITE_SPACE_TEMPLATE_NAME = 'testTemplate';
    public static final String COLUMN_OBJECT_NAME = 'Account';
    public static final String ROW_OBJECT_NAME = 'Opportunity';
    public static final String COLUMN_LABEL_FIELD_NAME = 'Name';
    public static final String ROW_LABEL_FIELD_NAME = 'Name';

    public static final String STANDARD_USER = 'Standard User';

    static WhiteSpaceTemplateMappingWrapper accountMapping {
        get {
            if (accountMapping == null) {
                accountMapping = new WhiteSpaceTemplateMappingWrapper();
                accountMapping.name = 'account mapping';
                accountMapping.objectName = 'Account';
                accountMapping.labelFieldName = 'Name';
                accountMapping.parentIdFieldName = 'ParentId';
            }
            return accountMapping;
        }
        set;
    }

    static WhiteSpaceTemplateMappingWrapper productMapping {
        get {
            if (productMapping == null) {
                productMapping = new WhiteSpaceTemplateMappingWrapper();
                productMapping.name = 'product mapping';
                productMapping.objectName = 'Product2';
                productMapping.labelFieldName = 'Name';
            }
            return productMapping;
        }
        set;
    }

    static WhiteSpaceTemplateMappingWrapper opportunityAmountMapping {
        get {
            if (opportunityAmountMapping == null) {
                opportunityAmountMapping = new WhiteSpaceTemplateMappingWrapper();
                opportunityAmountMapping.name = 'opp mapping amount';
                opportunityAmountMapping.objectName = 'Opportunity';
                opportunityAmountMapping.labelFieldName = 'Name';
                opportunityAmountMapping.valueFieldName = 'Amount';
            }
            return opportunityAmountMapping;
        }
        set;
    }

    static WhiteSpaceTemplateMappingWrapper opportunityRevenueMapping {
        get {
            if (opportunityRevenueMapping == null) {
                opportunityRevenueMapping = new WhiteSpaceTemplateMappingWrapper();
                opportunityRevenueMapping.name = 'opp mapping revenue';
                opportunityRevenueMapping.objectName = 'Opportunity';
                opportunityRevenueMapping.labelFieldName = 'Name';
                opportunityRevenueMapping.valueFieldName = 'ExpectedRevenue';
            }
            return opportunityRevenueMapping;
        }
        set;
    }

    @testSetup
    static void testSetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];
        User adminAdam = TestDataFactory.createUser(USER1_FIRST_NAME, USER1_LAST_NAME, p.Id);
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];

        insert new PermissionSetAssignment(AssigneeId = adminAdam.Id, PermissionSetId = adminUserPermissionSet.Id);
    }

    @isTest
    static void createWhiteSpaceTemplateTest() {
        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME];

        Map<Id, WhiteSpaceTemplateCellFieldWrapper> amountTypeFields = new Map<Id, WhiteSpaceTemplateCellFieldWrapper>();

        WhiteSpaceTemplateWrapper wrapper = new WhiteSpaceTemplateWrapper();
        wrapper.name = 'test template';
        wrapper.rowConfiguration = new WhiteSpaceTemplateWrapper.HeaderConfiguration(accountMapping, false);
        wrapper.columnConfiguration = new WhiteSpaceTemplateWrapper.HeaderConfiguration(productMapping, false);
        wrapper.amountTypeFields = amountTypeFields;

        WhiteSpaceTemplateWrapper result;
        // When
        Test.startTest();
        System.runAs(adminUser) {
            result = WhiteSpaceTemplateController.createWhiteSpaceTemplate(wrapper);
        }
        Test.stopTest();

        // Then
        System.assertEquals(wrapper.name, result.name);
        System.assertEquals(wrapper.columnConfiguration.mapping.name, result.columnConfiguration.mapping.name);
        System.assertEquals(
            wrapper.columnConfiguration.mapping.objectName,
            result.columnConfiguration.mapping.objectName
        );
        System.assertEquals(
            wrapper.columnConfiguration.mapping.labelFieldName,
            result.columnConfiguration.mapping.labelFieldName
        );
        System.assertEquals(wrapper.rowConfiguration.mapping.objectName, result.rowConfiguration.mapping.objectName);
        System.assertEquals(wrapper.rowConfiguration.mapping.objectName, result.rowConfiguration.mapping.objectName);
        System.assertEquals(
            wrapper.rowConfiguration.mapping.labelFieldName,
            result.rowConfiguration.mapping.labelFieldName
        );
    }

    @isTest
    static void createWhiteSpaceTemplateWithCellDataTest() {
        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME];

        White_Space_Amount_Type__c amountType = TestDataFactory.createWhiteSpaceAmountType('test');
        Map<Id, WhiteSpaceTemplateCellFieldWrapper> amountTypeFields = new Map<Id, WhiteSpaceTemplateCellFieldWrapper>();
        WhiteSpaceTemplateCellFieldWrapper cellTemplate1 = new WhiteSpaceTemplateCellFieldWrapper();
        cellTemplate1.displayFieldId = amountType.id;
        cellTemplate1.mapping = opportunityAmountMapping;
        amountTypeFields.put(cellTemplate1.displayFieldId, cellTemplate1);

        WhiteSpaceTemplateWrapper wrapper = new WhiteSpaceTemplateWrapper();
        wrapper.name = 'test template';
        wrapper.rowConfiguration = new WhiteSpaceTemplateWrapper.HeaderConfiguration(accountMapping, false);
        wrapper.columnConfiguration = new WhiteSpaceTemplateWrapper.HeaderConfiguration(productMapping, false);
        wrapper.amountTypeFields = amountTypeFields;

        WhiteSpaceTemplateWrapper result;

        // When
        Test.startTest();
        System.runAs(adminUser) {
            result = WhiteSpaceTemplateController.createWhiteSpaceTemplate(wrapper);
        }
        Test.stopTest();

        // Then
        System.assertEquals(wrapper.name, result.name);
        System.assertEquals(wrapper.amountTypeFields.size(), result.amountTypeFields.size());
        System.assertEquals(accountMapping.parentIdFieldName, result.rowConfiguration.mapping.parentIdFieldName);
        WhiteSpaceTemplateMappingWrapper cellMappingResult = result.amountTypeFields.get(amountType.id).mapping;
        System.assertEquals(opportunityAmountMapping.name, cellMappingResult.name);
        System.assertEquals(opportunityAmountMapping.objectName, cellMappingResult.objectName);
        System.assertEquals(opportunityAmountMapping.labelFieldName, cellMappingResult.labelFieldName);
        System.assertEquals(opportunityAmountMapping.valueFieldName, cellMappingResult.valueFieldName);
    }

    @isTest
    static void createWhiteSpaceTemplateWithBasicCellDataTest() {
        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME];

        List<WhiteSpaceTemplateCellFieldWrapper> basicFields = new List<WhiteSpaceTemplateCellFieldWrapper>();
        WhiteSpaceTemplateCellFieldWrapper cellTemplate1 = new WhiteSpaceTemplateCellFieldWrapper();
        cellTemplate1.mapping = opportunityAmountMapping;
        basicFields.add(cellTemplate1);

        WhiteSpaceTemplateWrapper wrapper = new WhiteSpaceTemplateWrapper();
        wrapper.name = 'test template';
        wrapper.rowConfiguration = new WhiteSpaceTemplateWrapper.HeaderConfiguration(accountMapping, false);
        wrapper.columnConfiguration = new WhiteSpaceTemplateWrapper.HeaderConfiguration(productMapping, false);
        wrapper.basicFields = basicFields;

        WhiteSpaceTemplateWrapper result;

        // When
        Test.startTest();
        System.runAs(adminUser) {
            result = WhiteSpaceTemplateController.createWhiteSpaceTemplate(wrapper);
        }
        Test.stopTest();

        // Then
        System.assertEquals(wrapper.name, result.name);
        System.assertEquals(0, result.amountTypeFields.size());
        System.assertEquals(wrapper.basicFields.size(), result.basicFields.size());
        System.assertEquals(accountMapping.parentIdFieldName, result.rowConfiguration.mapping.parentIdFieldName);
        WhiteSpaceTemplateMappingWrapper cellMappingResult = result.basicFields[0].mapping;
        System.assertEquals(opportunityAmountMapping.name, cellMappingResult.name);
        System.assertEquals(opportunityAmountMapping.objectName, cellMappingResult.objectName);
        System.assertEquals(opportunityAmountMapping.labelFieldName, cellMappingResult.labelFieldName);
    }

    @isTest
    static void createWhiteSpaceTemplateNullParametersTest() {
        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME];

        WhiteSpaceTemplateWrapper result;

        // When
        Test.startTest();
        System.runAs(adminUser) {
            try {
                result = WhiteSpaceTemplateController.createWhiteSpaceTemplate(null);
                system.assert(false);
            } catch (AuraHandledException e) {
                system.assert(true);
            }
            try {
                WhiteSpaceTemplateWrapper wrapper = new WhiteSpaceTemplateWrapper();
                result = WhiteSpaceTemplateController.createWhiteSpaceTemplate(wrapper);
                system.assert(false);
            } catch (AuraHandledException e) {
                system.assert(true);
            }
            try {
                WhiteSpaceTemplateWrapper wrapper = new WhiteSpaceTemplateWrapper();
                wrapper.name = null;
                wrapper.rowConfiguration = new WhiteSpaceTemplateWrapper.HeaderConfiguration(accountMapping, false);
                wrapper.columnConfiguration = new WhiteSpaceTemplateWrapper.HeaderConfiguration(productMapping, false);
                result = WhiteSpaceTemplateController.createWhiteSpaceTemplate(wrapper);
                system.assert(false);
            } catch (AuraHandledException e) {
                system.assert(true);
            }
            try {
                WhiteSpaceTemplateWrapper wrapper = new WhiteSpaceTemplateWrapper();
                wrapper.name = 'test template';
                wrapper.columnConfiguration = new WhiteSpaceTemplateWrapper.HeaderConfiguration(productMapping, false);
                result = WhiteSpaceTemplateController.createWhiteSpaceTemplate(wrapper);
                system.assert(false);
            } catch (AuraHandledException e) {
                system.assert(true);
            }
            try {
                WhiteSpaceTemplateWrapper wrapper = new WhiteSpaceTemplateWrapper();
                wrapper.name = 'test template';
                wrapper.rowConfiguration = new WhiteSpaceTemplateWrapper.HeaderConfiguration(productMapping, false);
                result = WhiteSpaceTemplateController.createWhiteSpaceTemplate(wrapper);
                system.assert(false);
            } catch (AuraHandledException e) {
                system.assert(true);
            }
            try {
                WhiteSpaceTemplateWrapper wrapper = new WhiteSpaceTemplateWrapper();
                wrapper.name = 'test template';
                wrapper.rowConfiguration = new WhiteSpaceTemplateWrapper.HeaderConfiguration(accountMapping, false);
                wrapper.columnConfiguration = new WhiteSpaceTemplateWrapper.HeaderConfiguration(productMapping, false);
                result = WhiteSpaceTemplateController.createWhiteSpaceTemplate(wrapper);
                system.assert(true);
            } catch (AuraHandledException e) {
                system.assert(false);
            }
        }
        Test.stopTest();
    }

    @isTest
    static void createWhiteSpaceTemplateInvalidPropertyTest() {
        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME];

        String invalidName = 'blahblahblahxxcc';
        String invalidRelatedName = 'Account.Name';
        String invalidOLIRelatedName = 'OpportunityLineItem.blahblahblahxxcc';

        Id amountTypeId = fflib_IDGenerator.generate(White_Space_Amount_Type__c.SObjectType);
        Map<Id, WhiteSpaceTemplateCellFieldWrapper> amountTypeFields = new Map<Id, WhiteSpaceTemplateCellFieldWrapper>();
        WhiteSpaceTemplateCellFieldWrapper cellTemplate1 = new WhiteSpaceTemplateCellFieldWrapper();
        cellTemplate1.displayFieldId = amountTypeId;
        cellTemplate1.mapping = opportunityAmountMapping;
        amountTypeFields.put(cellTemplate1.displayFieldId, cellTemplate1);

        WhiteSpaceTemplateWrapper defaultWrapper = new WhiteSpaceTemplateWrapper();
        defaultWrapper.name = 'test template';
        defaultWrapper.rowConfiguration = new WhiteSpaceTemplateWrapper.HeaderConfiguration(accountMapping, false);
        defaultWrapper.columnConfiguration = new WhiteSpaceTemplateWrapper.HeaderConfiguration(productMapping, false);
        defaultWrapper.amountTypeFields = amountTypeFields;

        WhiteSpaceTemplateWrapper result;

        // When
        Test.startTest();
        System.runAs(adminUser) {
            try {
                WhiteSpaceTemplateWrapper wrapper = (WhiteSpaceTemplateWrapper) JSON.deserialize(
                    JSON.serialize(defaultWrapper),
                    WhiteSpaceTemplateWrapper.class
                );
                wrapper.columnConfiguration.mapping.objectName = invalidName;
                result = WhiteSpaceTemplateController.createWhiteSpaceTemplate(wrapper);
                system.assert(false);
            } catch (AuraHandledException e) {
                system.assert(true);
            }
            try {
                WhiteSpaceTemplateWrapper wrapper = (WhiteSpaceTemplateWrapper) JSON.deserialize(
                    JSON.serialize(defaultWrapper),
                    WhiteSpaceTemplateWrapper.class
                );
                wrapper.columnConfiguration.mapping.labelFieldName = invalidName;
                result = WhiteSpaceTemplateController.createWhiteSpaceTemplate(wrapper);
                system.assert(false);
            } catch (AuraHandledException e) {
                system.assert(true);
            }
            try {
                WhiteSpaceTemplateWrapper wrapper = (WhiteSpaceTemplateWrapper) JSON.deserialize(
                    JSON.serialize(defaultWrapper),
                    WhiteSpaceTemplateWrapper.class
                );
                wrapper.amountTypeFields.get(amountTypeId).mapping.valueFieldName = invalidName;
                result = WhiteSpaceTemplateController.createWhiteSpaceTemplate(wrapper);
                system.assert(false);
            } catch (AuraHandledException e) {
                system.assert(true);
            }
            try {
                WhiteSpaceTemplateWrapper wrapper = (WhiteSpaceTemplateWrapper) JSON.deserialize(
                    JSON.serialize(defaultWrapper),
                    WhiteSpaceTemplateWrapper.class
                );
                wrapper.amountTypeFields.get(amountTypeId).mapping.valueFieldName = invalidRelatedName;
                result = WhiteSpaceTemplateController.createWhiteSpaceTemplate(wrapper);
                system.assert(false);
            } catch (AuraHandledException e) {
                system.assert(true);
            }
            try {
                WhiteSpaceTemplateWrapper wrapper = (WhiteSpaceTemplateWrapper) JSON.deserialize(
                    JSON.serialize(defaultWrapper),
                    WhiteSpaceTemplateWrapper.class
                );
                wrapper.amountTypeFields.get(amountTypeId).mapping.valueFieldName = invalidOLIRelatedName;
                result = WhiteSpaceTemplateController.createWhiteSpaceTemplate(wrapper);
                system.assert(false);
            } catch (AuraHandledException e) {
                system.assert(true);
            }
        }
        Test.stopTest();
    }

    @isTest
    static void updateWhiteSpaceTemplateTest() {
        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME];

        White_Space_Template__c template = TestDataFactory.createWhiteSpaceTemplate(
            'test Name',
            'Account',
            'Name',
            null,
            'Campaign',
            'Name',
            null
        );
        WhiteSpaceTemplateWrapper wrapper = new WhiteSpaceTemplateWrapper(template);

        WhiteSpaceTemplateWrapper result;
        // When
        Test.startTest();
        System.runAs(adminUser) {
            wrapper.name = 'test Edit';
            result = WhiteSpaceTemplateController.updateWhiteSpaceTemplate(wrapper);
        }
        Test.stopTest();

        // Then
        System.assertEquals(wrapper.id, result.id);
        System.assertEquals('test Edit', result.name);
        System.assertEquals(wrapper.columnConfiguration.mapping.id, result.columnConfiguration.mapping.id);
        System.assertEquals(wrapper.columnConfiguration.mapping.name, result.columnConfiguration.mapping.name);
        System.assertEquals(
            wrapper.columnConfiguration.mapping.objectName,
            result.columnConfiguration.mapping.objectName
        );
        System.assertEquals(
            wrapper.columnConfiguration.mapping.labelFieldName,
            result.columnConfiguration.mapping.labelFieldName
        );
        System.assertEquals(wrapper.rowConfiguration.mapping.objectName, result.rowConfiguration.mapping.objectName);
        System.assertEquals(wrapper.rowConfiguration.mapping.objectName, result.rowConfiguration.mapping.objectName);
        System.assertEquals(
            wrapper.rowConfiguration.mapping.labelFieldName,
            result.rowConfiguration.mapping.labelFieldName
        );
    }

    @isTest
    static void updateWhiteSpaceTemplateConditionTest() {
        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME];

        White_Space_Template__c template = TestDataFactory.createWhiteSpaceTemplate(
            'test Name',
            'Account',
            'Name',
            null,
            'Campaign',
            'Name',
            null
        );
        Mapping_Condition_Group__c condGroup = TestDataFactory.createConditionGroup(template.ColumnMapping__r, 'AND');
        TestDataFactory.createCondition('AnnualRevenue', 'EQUALS', '100', condGroup);

        WhiteSpaceTemplateWrapper wrapper = new WhiteSpaceTemplateWrapper(template);

        WhiteSpaceTemplateWrapper result;
        // When
        Test.startTest();
        System.runAs(adminUser) {
            wrapper.columnConfiguration.mapping.conditions.singleConditions[0].singleCondition.Value__c = '200';
            result = WhiteSpaceTemplateController.updateWhiteSpaceTemplate(wrapper);
        }
        Test.stopTest();

        // Then
        System.assertEquals(wrapper.id, result.id);
        System.assertEquals(wrapper.columnConfiguration.mapping.id, result.columnConfiguration.mapping.id);
        System.assertEquals(wrapper.columnConfiguration.mapping.name, result.columnConfiguration.mapping.name);
        System.assertEquals(
            wrapper.columnConfiguration.mapping.objectName,
            result.columnConfiguration.mapping.objectName
        );
        System.assertEquals(
            wrapper.columnConfiguration.mapping.labelFieldName,
            result.columnConfiguration.mapping.labelFieldName
        );
        System.assertEquals(
            '200',
            result.columnConfiguration.mapping.conditions.singleConditions[0].singleCondition.Value__c
        );
    }

    @isTest
    static void updateWhiteSpaceTemplateCellDataTest() {
        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME];

        White_Space_Template__c template = TestDataFactory.createWhiteSpaceTemplate(
            'test Name',
            'Account',
            'Name',
            null,
            'Campaign',
            'Name',
            null
        );
        WhiteSpaceTemplateWrapper wrapper = new WhiteSpaceTemplateWrapper(template);

        Id amountTypeId = fflib_IDGenerator.generate(White_Space_Amount_Type__c.SObjectType);
        Map<Id, WhiteSpaceTemplateCellFieldWrapper> amountTypeFields = new Map<Id, WhiteSpaceTemplateCellFieldWrapper>();
        WhiteSpaceTemplateCellFieldWrapper cellTemplate1 = new WhiteSpaceTemplateCellFieldWrapper();
        cellTemplate1.displayFieldId = amountTypeId;
        cellTemplate1.mapping = opportunityAmountMapping;
        amountTypeFields.put(cellTemplate1.displayFieldId, cellTemplate1);

        WhiteSpaceTemplateWrapper result;
        // When
        Test.startTest();
        System.runAs(adminUser) {
            wrapper.amountTypeFields = amountTypeFields;
            result = WhiteSpaceTemplateController.updateWhiteSpaceTemplate(wrapper);
        }
        Test.stopTest();

        // Then
        System.assertEquals(wrapper.id, result.id);
        System.assertEquals(wrapper.columnConfiguration.mapping.id, result.columnConfiguration.mapping.id);
        System.assertEquals(wrapper.columnConfiguration.mapping.name, result.columnConfiguration.mapping.name);
        System.assertEquals(
            wrapper.columnConfiguration.mapping.objectName,
            result.columnConfiguration.mapping.objectName
        );
        System.assertEquals(
            wrapper.columnConfiguration.mapping.labelFieldName,
            result.columnConfiguration.mapping.labelFieldName
        );

        System.assertEquals(1, result.amountTypeFields.size());
        WhiteSpaceTemplateMappingWrapper cellMappingResult = result.amountTypeFields.get(amountTypeId).mapping;
        System.assertEquals(opportunityAmountMapping.name, cellMappingResult.name);
        System.assertEquals(opportunityAmountMapping.objectName, cellMappingResult.objectName);
        System.assertEquals(opportunityAmountMapping.labelFieldName, cellMappingResult.labelFieldName);
        System.assertEquals(opportunityAmountMapping.valueFieldName, cellMappingResult.valueFieldName);
    }

    @isTest
    static void getRelatedWhiteSpacesTest() {
        // mocks
        TestMockData md = new TestMockData();
        WhiteSpaceSelector mockWSSelector = md.mockWhiteSpaceSelector;

        // given
        md.mocks.startStubbing();
        md.mocks.when(mockWSSelector.selectByTemplateId(md.mockWhiteSpaceTemplateId))
            .thenReturn(new List<White_Space__c>{ md.mockWhiteSpace });
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        List<White_Space__c> result = WhiteSpaceTemplateController.getRelatedWhiteSpaces(md.mockWhiteSpaceTemplateId);
        Test.stopTest();

        System.assertEquals(1, result.size());
    }

    @isTest
    static void getRelatedObjectValuesTest() {
        // mocks
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl mockDOQService = md.mockDynamicObjectQueryService;

        // given
        md.mocks.startStubbing();
        md.mocks.when(
                mockDOQService.querySObjectListWithTypeAndFields(
                    Schema.Account.SObjectType,
                    new Set<String>{ 'Name' },
                    'Name'
                )
            )
            .thenReturn(new List<Account>{ md.mockAccount });
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        List<Map<String, String>> result = WhiteSpaceTemplateController.getRelatedObjectValues('Contact', 'AccountId');
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should return expected number of objects');
        System.assertEquals(md.mockAccount.Name, result[0].get('label'), 'label should match account name');
        System.assertEquals(md.mockAccount.Id, result[0].get('value'), 'value should match account Id');
    }

    @isTest
    static void getObjectsContainsOLITest() {
        // Given
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;

        md.mockSettings.WS_Object_Filter__c = null;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(mockSettingService.getObjectNameListFromFilterString(null)).thenReturn(new List<String>());
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        List<SObjectMetadata> result = WhiteSpaceTemplateController.getObjects();
        Test.stopTest();

        Boolean foundOLI = false;

        for (SObjectMetadata omd : result) {
            if (omd.apiName == OpportunityLineItem.SObjectType.getDescribe().getName()) {
                foundOLI = true;
                break;
            }
        }

        System.assert(foundOLI, 'OpportunityLineItem should be one of the objects returned');
    }

    @isTest
    static void getObjectsContainsUserTest() {
        // Given
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;

        md.mockSettings.WS_Object_Filter__c = null;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(mockSettingService.getObjectNameListFromFilterString(null)).thenReturn(new List<String>());
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        List<SObjectMetadata> result = WhiteSpaceTemplateController.getObjects();
        Test.stopTest();

        Boolean foundUser = false;

        for (SObjectMetadata omd : result) {
            if (omd.apiName == User.SObjectType.getDescribe().getName()) {
                foundUser = true;
                break;
            }
        }

        System.assert(foundUser, 'User should be one of the objects returned');
    }

    @isTest
    static void getObjectsFilteredSettingTest() {
        // Given
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;

        md.mockSettings.WS_Object_Filter__c = 'Account, Opportunity';

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(mockSettingService.getObjectNameListFromFilterString('Account, Opportunity'))
            .thenReturn(new List<String>{ 'Account', 'Opportunity' });
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        List<SObjectMetadata> result = WhiteSpaceTemplateController.getObjects();
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Should return expected number of objects');

        Boolean foundAccount = false;
        Boolean foundOpportunity = false;

        for (SObjectMetadata omd : result) {
            if (omd.apiName == Account.SObjectType.getDescribe().getName()) {
                foundAccount = true;
            }
            if (omd.apiName == Opportunity.SObjectType.getDescribe().getName()) {
                foundOpportunity = true;
            }
        }

        System.assert(foundAccount, 'Account should be one of the objects returned');
        System.assert(foundOpportunity, 'Opportunity should be one of the objects returned');
    }
}