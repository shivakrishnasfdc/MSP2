@isTest
private class WhiteSpaceTemplateCellFieldWrapperTest {
    @isTest
    private static void basicInitializerTest() {
        WhiteSpaceTemplateCellFieldWrapper wrapper = new WhiteSpaceTemplateCellFieldWrapper();

        System.assertEquals(null, wrapper.displayFieldId);
        System.assertEquals(true, wrapper.isManual);
        System.assertEquals(null, wrapper.mapping);
        System.assertEquals(null, wrapper.rowRelation);
        System.assertEquals(null, wrapper.columnRelation);
        System.assertEquals(null, wrapper.type);
    }

    @isTest
    private static void initializerNoMappingTest() {
        TestMockData md = new TestMockData();

        White_Space_Template_Cell_Field__c cf = md.mockCellField;

        WhiteSpaceTemplateMappingWrapper rowWrap = new WhiteSpaceTemplateMappingWrapper(md.mockAccountMapping);
        WhiteSpaceTemplateMappingWrapper columnWrap = new WhiteSpaceTemplateMappingWrapper(md.mockProductMapping);

        Map<Id, Mapping__c> cellMappingById = null;

        WhiteSpaceTemplateCellFieldWrapper wrapper = new WhiteSpaceTemplateCellFieldWrapper(
            cf,
            cellMappingById,
            rowWrap,
            columnWrap,
            true
        );

        System.assertEquals(md.mockWhiteSpaceAmountTypeId, wrapper.displayFieldId);
        System.assertEquals(true, wrapper.isManual);
        System.assertEquals(null, wrapper.mapping);
        System.assertEquals(null, wrapper.rowRelation);
        System.assertEquals(null, wrapper.columnRelation);
        System.assertEquals('amountType', wrapper.type);
    }

    @isTest
    private static void initializerWithMappingByIdTest() {
        TestMockData md = new TestMockData();

        White_Space_Template_Cell_Field__c cf = md.mockCellField;

        WhiteSpaceTemplateMappingWrapper rowWrap = new WhiteSpaceTemplateMappingWrapper(md.mockAccountMapping);
        WhiteSpaceTemplateMappingWrapper columnWrap = new WhiteSpaceTemplateMappingWrapper(md.mockProductMapping);

        Map<Id, Mapping__c> cellMappingById = new Map<Id, Mapping__c>();
        cellMappingById.put(md.mockAssetMappingId, md.mockAssetMapping);

        WhiteSpaceTemplateCellFieldWrapper wrapper = new WhiteSpaceTemplateCellFieldWrapper(
            cf,
            cellMappingById,
            rowWrap,
            columnWrap,
            true
        );

        System.assertEquals(md.mockWhiteSpaceAmountTypeId, wrapper.displayFieldId);
        System.assertEquals(false, wrapper.isManual);
        System.assertEquals(md.mockAssetMapping.ObjectType__c, wrapper.mapping.objectName);
        System.assertEquals(md.mockAssetMapping.ValueField__c, wrapper.mapping.valueFieldName);
        System.assertEquals('AccountId', wrapper.rowRelation);
        System.assertEquals('Product2Id', wrapper.columnRelation);
        System.assertEquals('amountType', wrapper.type);
    }

    @isTest
    private static void initializerWithMappingTest() {
        TestMockData md = new TestMockData();
        White_Space_Template_Cell_Field__c cf = md.mockCellField;

        WhiteSpaceTemplateMappingWrapper rowWrap = new WhiteSpaceTemplateMappingWrapper(md.mockAccountMapping);
        WhiteSpaceTemplateMappingWrapper columnWrap = new WhiteSpaceTemplateMappingWrapper(md.mockProductMapping);

        WhiteSpaceTemplateCellFieldWrapper wrapper = new WhiteSpaceTemplateCellFieldWrapper(
            cf,
            md.mockAssetMapping,
            rowWrap,
            columnWrap,
            true
        );

        System.assertEquals(md.mockWhiteSpaceAmountTypeId, wrapper.displayFieldId);
        System.assertEquals(false, wrapper.isManual);
        System.assertEquals(md.mockAssetMapping.ObjectType__c, wrapper.mapping.objectName);
        System.assertEquals(md.mockAssetMapping.ValueField__c, wrapper.mapping.valueFieldName);
        System.assertEquals('AccountId', wrapper.rowRelation);
        System.assertEquals('Product2Id', wrapper.columnRelation);
        System.assertEquals('amountType', wrapper.type);
    }

    @isTest
    private static void initializerBasicTypeWithMappingTest() {
        TestMockData md = new TestMockData();
        White_Space_Template_Cell_Field__c cf = md.mockBasicCellField;

        WhiteSpaceTemplateMappingWrapper rowWrap = new WhiteSpaceTemplateMappingWrapper(md.mockAccountMapping);
        WhiteSpaceTemplateMappingWrapper columnWrap = new WhiteSpaceTemplateMappingWrapper(md.mockProductMapping);

        WhiteSpaceTemplateCellFieldWrapper wrapper = new WhiteSpaceTemplateCellFieldWrapper(
            cf,
            md.mockAssetMapping,
            rowWrap,
            columnWrap,
            true
        );

        System.assertEquals(null, wrapper.displayFieldId);
        System.assertEquals(false, wrapper.isManual);
        System.assertEquals(md.mockAssetMapping.ObjectType__c, wrapper.mapping.objectName);
        System.assertEquals(md.mockAssetMapping.ValueField__c, wrapper.mapping.valueFieldName);
        System.assertEquals('AccountId', wrapper.rowRelation);
        System.assertEquals('Product2Id', wrapper.columnRelation);
        System.assertEquals('basicMapping', wrapper.type);
    }

    @isTest
    private static void initializerRelatedWrapperTest() {
        TestMockData md = new TestMockData();
        WSRelatedObjectWrapper relationshipWrapper = md.mockWSRelatedObjectWrapperCompound;

        WhiteSpaceTemplateCellFieldWrapper wrapper = new WhiteSpaceTemplateCellFieldWrapper(relationshipWrapper);

        System.assertEquals(relationshipWrapper.objDesc.getName(), wrapper.id);
        System.assertEquals(relationshipWrapper.objDesc.getName(), wrapper.displayFieldId);
        System.assertEquals('relatedMapping', wrapper.type);
        System.assertEquals(true, wrapper.isManual);
        System.assertEquals(relationshipWrapper.objDesc.getName(), wrapper.mapping.objectName);
        System.assertEquals(relationshipWrapper.labelFieldName, wrapper.mapping.valueFieldName);
        System.assertEquals(relationshipWrapper.relationshipField.getName(), wrapper.cellRelation);
        System.assertEquals(relationshipWrapper.fieldList, wrapper.additionalCellRelationFields);
        System.assertEquals(null, wrapper.rowRelation);
        System.assertEquals(null, wrapper.columnRelation);
    }

    @isTest
    private static void getQueryBuilderOpportunityProductQueryTest() {
        TestMockData md = new TestMockData();
        Id objId = md.mockAccountId;
        // Given wsTemplateCellFieldWrapper with Opportunities as the selected objects and Products and Accounts as the row and column objects
        String expectedQueryString =
            'SELECT name, amount, accountid, (SELECT product2id FROM OpportunityLineItems) FROM Opportunity WHERE (Id IN (SELECT opportunityid FROM OpportunityLineItem WHERE (Product2Id IN (\'' +
            objId +
            '\')))) AND (AccountId IN (\'' +
            objId +
            '\')) ORDER BY Name ASC NULLS FIRST';
        White_Space_Template_Cell_Field__c cf = md.mockCellField;

        WhiteSpaceTemplateMappingWrapper rowWrap = new WhiteSpaceTemplateMappingWrapper(md.mockProductMapping);
        WhiteSpaceTemplateMappingWrapper columnWrap = new WhiteSpaceTemplateMappingWrapper(md.mockAccountMapping);

        WhiteSpaceTemplateCellFieldWrapper wrapper = new WhiteSpaceTemplateCellFieldWrapper(
            cf,
            md.mockOppMapping,
            rowWrap,
            columnWrap,
            true
        );

        // When getQueryBuilder is called
        Query queryBuilder = wrapper.getQueryBuilder(
            new Set<String>{ objId },
            new Set<String>{ objId },
            new Set<String>(),
            null,
            false
        );

        // Then it should return a queryBuilder with a query containing relevant relationship fields and an OpportunityLineItems subquery
        System.assertEquals(expectedQueryString, queryBuilder.toQueryString());
    }

    @isTest
    private static void getQueryBuilderNullMappingTestTest() {
        TestMockData md = new TestMockData();

        WhiteSpaceTemplateCellFieldWrapper wrapper = md.mockRelatedCellFieldWrapper;
        wrapper.mapping = null;

        // When getQueryBuilder is called
        Query queryBuilder = wrapper.getQueryBuilder(null, null, null, null, false);

        // Then it should return a queryBuilder with a query containing relevant relationship fields and an OpportunityLineItems subquery
        System.assertEquals(null, queryBuilder);
    }

    @isTest
    private static void getQueryBuilderNullAndEmptyRowColumnTest() {
        TestMockData md = new TestMockData();
        Id objId = md.mockAccountId;
        White_Space_Template_Cell_Field__c cf = md.mockCellField;

        WhiteSpaceTemplateMappingWrapper rowWrap = new WhiteSpaceTemplateMappingWrapper(md.mockAccountMapping);
        WhiteSpaceTemplateMappingWrapper columnWrap = new WhiteSpaceTemplateMappingWrapper(md.mockAccountMapping);

        WhiteSpaceTemplateCellFieldWrapper wrapper = new WhiteSpaceTemplateCellFieldWrapper(
            cf,
            md.mockOppMapping,
            rowWrap,
            columnWrap,
            true
        );

        // When getQueryBuilder is called
        Query queryBuilder = wrapper.getQueryBuilder(null, new Set<String>{ objId }, new Set<String>(), null, false);
        System.assertEquals(null, queryBuilder);

        queryBuilder = wrapper.getQueryBuilder(new Set<String>{ objId }, null, new Set<String>(), null, false);
        System.assertEquals(null, queryBuilder);

        wrapper.getQueryBuilder(new Set<String>(), new Set<String>{ objId }, new Set<String>(), null, false);
        System.assertEquals(null, queryBuilder);

        queryBuilder = wrapper.getQueryBuilder(
            new Set<String>{ objId },
            new Set<String>(),
            new Set<String>(),
            null,
            false
        );
        System.assertEquals(null, queryBuilder);
    }

    @isTest
    private static void getQueryBuilderRelatedObjectNullsTest() {
        TestMockData md = new TestMockData();

        WhiteSpaceTemplateCellFieldWrapper wrapper = md.mockRelatedCellFieldWrapper;

        // When getQueryBuilder is called
        Query queryBuilder = wrapper.getQueryBuilder(null, null, null, null, false);

        // Should return null if no cells to query for the related object
        System.assertEquals(null, queryBuilder, 'Should return null if no cells to query for the related object');
    }

    @isTest
    private static void getQueryBuilderRelatedObjectWithDataTest() {
        TestMockData md = new TestMockData();
        Id ownerId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id ownerId2 = fflib_IDGenerator.generate(User.SObjectType);
        Set<String> idsToMatch = new Set<String>{ ownerId1, ownerId2 };
        Set<Id> idSet = new Set<Id>{ ownerId1, ownerId2 };
        // Given wsTemplateCellFieldWrapper with Cell Relation to Accounts (Faked via OwnerId)
        String expectedQueryString = new Query(Account.getSObjectType(), null)
            .selectFields(new Set<Schema.SObjectField>{ Account.Name, Account.OwnerId })
            .orderBy(Schema.SObjectType.Account.fields.Name.getName())
            .lookup(Account.OwnerId.getDescribe().getName(), idSet)
            .toQueryString();

        WhiteSpaceTemplateCellFieldWrapper wrapper = md.mockRelatedCellFieldWrapper;

        // When getQueryBuilder is called
        Query queryBuilder = wrapper.getQueryBuilder(null, null, idsToMatch, null, false);

        // Then it should return a queryBuilder with a query containing relevant relationship fields and an OpportunityLineItems subquery
        System.assertEquals(expectedQueryString, queryBuilder.toQueryString());
    }

    @isTest
    private static void getQueryBuilderComplexRelatedObjectWithDataTest() {
        TestMockData md = new TestMockData();
        Id ownerId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id ownerId2 = fflib_IDGenerator.generate(User.SObjectType);
        Set<String> idsToMatch = new Set<String>{ ownerId1, ownerId2 };
        Set<Id> idSet = new Set<Id>{ ownerId1, ownerId2 };
        // Given wsTemplateCellFieldWrapper with Cell Relation to Accounts (Faked via OwnerId)
        String expectedQueryString = new Query(Contact.getSObjectType(), null)
            .selectFields(new Set<String>{ 'Account.Name', 'Ownerid', 'Account.Id' })
            .orderBy('Account.Name')
            .lookup(Contact.OwnerId.getDescribe().getName(), idSet)
            .toQueryString();
        WhiteSpaceTemplateCellFieldWrapper wrapper = md.mockRelatedCellFieldWrapperCompound;

        // When getQueryBuilder is called
        Query queryBuilder = wrapper.getQueryBuilder(null, null, idsToMatch, null, false);

        // Then it should return a queryBuilder with a query containing relevant relationship fields and an OpportunityLineItems subquery
        System.assertEquals(expectedQueryString, queryBuilder.toQueryString());
    }

    @isTest
    private static void getQueryBuilderOpportunityProductQueryWithOLITest() {
        TestMockData md = new TestMockData();
        Id objId = md.mockAccountId;
        // Given wsTemplateCellFieldWrapper with Opportunities as the selected objects and Products and Accounts as the row and column objects
        String expectedQueryString =
            'SELECT name, accountid, (SELECT product2id, quantity FROM OpportunityLineItems) FROM Opportunity WHERE (Id IN (SELECT opportunityid FROM OpportunityLineItem WHERE (Product2Id IN (\'' +
            objId +
            '\')))) AND (AccountId IN (\'' +
            objId +
            '\')) ORDER BY Name ASC NULLS FIRST';
        md.mockOppMapping.ValueField__c = 'OpportunityLineItem.Quantity';
        White_Space_Template_Cell_Field__c cf = new White_Space_Template_Cell_Field__c(
            Id = md.mockCellFieldId,
            displayFieldId__c = md.mockWhiteSpaceAmountTypeId,
            ValueMapping__c = md.mockOppMappingId,
            ValueMapping__r = md.mockOppMapping,
            WhiteSpaceTemplate__c = md.mockWhiteSpaceTemplateId
        );

        WhiteSpaceTemplateMappingWrapper columnWrap = new WhiteSpaceTemplateMappingWrapper(md.mockProductMapping);
        WhiteSpaceTemplateMappingWrapper rowWrap = new WhiteSpaceTemplateMappingWrapper(md.mockAccountMapping);

        WhiteSpaceTemplateCellFieldWrapper wrapper = new WhiteSpaceTemplateCellFieldWrapper(
            cf,
            md.mockOppMapping,
            rowWrap,
            columnWrap,
            true
        );

        // When getQueryBuilder is called
        Query queryBuilder = wrapper.getQueryBuilder(
            new Set<String>{ objId },
            new Set<String>{ objId },
            new Set<String>(),
            null,
            false
        );

        // Then it should return a queryBuilder with a query containing relevant relationship fields and an OpportunityLineItems subquery
        System.assertEquals(expectedQueryString, queryBuilder.toQueryString());
    }

    @isTest
    private static void getMapForRecordListRelatedObjectTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceTemplateCellFieldWrapper wrapper = md.mockRelatedCellFieldWrapper;

        Id ownerId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id ownerId2 = fflib_IDGenerator.generate(User.SObjectType);

        Account a1 = md.mockAccount.clone(false, true, false, false); //deep clone, does not preserve Id, timestamps, or autonumber
        a1.Id = fflib_IDGenerator.generate(Account.SObjectType);
        a1.OwnerId = ownerId1;
        Account a2 = md.mockAccount.clone(false, true, false, false); //deep clone, does not preserve Id, timestamps, or autonumber
        a2.Id = fflib_IDGenerator.generate(Account.SObjectType);
        a2.OwnerId = ownerId1;
        Account a3 = md.mockAccount.clone(false, true, false, false); //deep clone, does not preserve Id, timestamps, or autonumber
        a3.Id = fflib_IDGenerator.generate(Account.SObjectType);
        a3.OwnerId = ownerId2;

        Map<String, List<SObject>> result = wrapper.getMapForRecordList(new List<Account>{ a1, a2, a3 }, null);

        System.assertEquals(2, result.keySet().size(), 'Should be two keys in the map');
        List<SObject> objList = result.get(ownerId1);
        System.assertEquals(2, objList.size(), 'There should be two accounts for owner 1');
        objList = result.get(ownerId2);
        System.assertEquals(1, objList.size(), 'There should be one account for owner 2');
    }

    @isTest
    private static void getMapForRecordListRelatedObjectWithConversionsTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceTemplateCellFieldWrapper wrapper = md.mockRelatedCellFieldWrapper;

        Id ownerId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id ownerId2 = fflib_IDGenerator.generate(User.SObjectType);

        Account a1 = md.mockAccount.clone(false, true, false, false); //deep clone, does not preserve Id, timestamps, or autonumber
        a1.Id = fflib_IDGenerator.generate(Account.SObjectType);
        a1.OwnerId = ownerId1;
        Account a2 = md.mockAccount.clone(false, true, false, false); //deep clone, does not preserve Id, timestamps, or autonumber
        a2.Id = fflib_IDGenerator.generate(Account.SObjectType);
        a2.OwnerId = ownerId1;
        Account a3 = md.mockAccount.clone(false, true, false, false); //deep clone, does not preserve Id, timestamps, or autonumber
        a3.Id = fflib_IDGenerator.generate(Account.SObjectType);
        a3.OwnerId = ownerId2;

        Map<String, List<String>> conversionMap = new Map<String, List<String>>{
            ownerId1 => new List<String>{ 'test' },
            ownerId2 => new List<String>{ 'test' }
        };

        Map<String, List<SObject>> result = wrapper.getMapForRecordList(new List<Account>{ a1, a2, a3 }, conversionMap);

        System.assertEquals(1, result.keySet().size(), 'Should be one key in the map');
        List<SObject> objList = result.get('test');
        System.assertEquals(3, objList.size(), 'All accounts should be under the "test" key');
    }
}