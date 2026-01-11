@isTest
private class WhiteSpaceTemplateWrapperTest {
    @isTest
    private static void basicInitializerTest() {
        WhiteSpaceTemplateWrapper wrapper = new WhiteSpaceTemplateWrapper();

        System.assertEquals(null, wrapper.id);
        System.assertEquals(null, wrapper.name);
        System.assertEquals(null, wrapper.rowConfiguration);
        System.assertEquals(null, wrapper.columnConfiguration);
        System.assertEquals(null, wrapper.amountTypeFields);
        System.assertEquals(null, wrapper.basicFields);
    }

    @isTest
    private static void initializerWithTemplateTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceAmountTypeSelector mockAtSelector = md.mockWhiteSpaceAmountTypeSelector;
        WhiteSpaceTemplateCellFieldSelector mockCFSelector = md.mockWSTCellFieldSelector;
        MappingSelector mockMappingSelector = md.mockMappingSelector;
        White_Space_Amount_Type__c mockAT = md.mockWhiteSpaceAmountType; //NOPMD - Needs to be called in order for it to be mocked in the test

        md.mocks.startStubbing();
        md.mocks.when(mockAtSelector.selectInactive()).thenReturn(new List<White_Space_Amount_Type__c>());
        md.mocks.when(
                mockCFSelector.selectByWhiteSpaceTemplateIdExcludingDisplayFieldIds(
                    new Set<Id>{ md.mockWhiteSpaceTemplateId },
                    new Set<Id>()
                )
            )
            .thenReturn(new List<White_Space_Template_Cell_Field__c>{ md.mockCellField });
        md.mocks.when(
                mockMappingSelector.selectByIdWithConditionGroups(
                    new Set<Id>{ md.mockAssetMappingId, md.mockProductMappingId, md.mockAccountMappingId }
                )
            )
            .thenReturn(new List<Mapping__c>{ md.mockAssetMapping, md.mockProductMapping, md.mockAccountMapping });
        md.mocks.stopStubbing();

        WhiteSpaceTemplateWrapper wrapper = new WhiteSpaceTemplateWrapper(md.mockWhiteSpaceTemplate);

        System.assertEquals(md.mockWhiteSpaceTemplateId, wrapper.id);
        System.assertEquals(md.mockWhiteSpaceTemplate.Name, wrapper.name);
        System.assertEquals(md.mockAccountMapping.ObjectType__c, wrapper.rowConfiguration.mapping.objectName);
        System.assertEquals(md.mockProductMapping.ObjectType__c, wrapper.columnConfiguration.mapping.objectName);
        System.assertEquals(1, wrapper.amountTypeFields.size());
        System.assertNotEquals(null, wrapper.amountTypeFields.get(md.mockWhiteSpaceAmountTypeId));
    }

    @isTest
    private static void initializerWithTemplateNoCellFieldTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceAmountTypeSelector mockAtSelector = md.mockWhiteSpaceAmountTypeSelector;
        WhiteSpaceTemplateCellFieldSelector mockCFSelector = md.mockWSTCellFieldSelector;
        MappingSelector mockMappingSelector = md.mockMappingSelector;
        White_Space_Amount_Type__c mockAT = md.mockWhiteSpaceAmountType; //NOPMD - Needs to be called in order for it to be mocked in the test

        md.mocks.startStubbing();
        md.mocks.when(mockAtSelector.selectInactive()).thenReturn(new List<White_Space_Amount_Type__c>());
        md.mocks.when(
                mockCFSelector.selectByWhiteSpaceTemplateIdExcludingDisplayFieldIds(
                    new Set<Id>{ md.mockWhiteSpaceTemplateId },
                    new Set<Id>()
                )
            )
            .thenReturn(new List<White_Space_Template_Cell_Field__c>());
        md.mocks.when(
                mockMappingSelector.selectByIdWithConditionGroups(
                    new Set<Id>{ md.mockProductMappingId, md.mockAccountMappingId }
                )
            )
            .thenReturn(new List<Mapping__c>{ md.mockProductMapping, md.mockAccountMapping });
        md.mocks.stopStubbing();

        WhiteSpaceTemplateWrapper wrapper = new WhiteSpaceTemplateWrapper(md.mockWhiteSpaceTemplate);

        System.assertEquals(md.mockWhiteSpaceTemplateId, wrapper.id);
        System.assertEquals(md.mockWhiteSpaceTemplate.Name, wrapper.name);
        System.assertEquals(md.mockAccountMapping.ObjectType__c, wrapper.rowConfiguration.mapping.objectName);
        System.assertEquals(md.mockProductMapping.ObjectType__c, wrapper.columnConfiguration.mapping.objectName);
        System.assertEquals(0, wrapper.amountTypeFields.size());
    }

    @isTest
    private static void initializerWithLegacyTemplateTest() {
        TestMockData md = new TestMockData();

        White_Space_Template__c mockLegacyWhiteSpaceTemplate = md.mockLegacyWhiteSpaceTemplate;
        mockLegacyWhiteSpaceTemplate.id = null;
        insert md.mockLegacyWhiteSpaceTemplate;
        White_Space_Template__c template = getTemplate(mockLegacyWhiteSpaceTemplate.Name);

        WhiteSpaceTemplateWrapper wrapper = new WhiteSpaceTemplateWrapper(template);

        System.assertEquals(true, wrapper.isLegacyTemplate);
        System.assertEquals(mockLegacyWhiteSpaceTemplate.Id, wrapper.id);
        System.assertEquals(mockLegacyWhiteSpaceTemplate.Name, wrapper.name);
        System.assertEquals(
            mockLegacyWhiteSpaceTemplate.Row_Object_Name__c,
            wrapper.rowConfiguration.mapping.objectName
        );
        System.assertEquals(
            mockLegacyWhiteSpaceTemplate.Column_Object_Name__c,
            wrapper.columnConfiguration.mapping.objectName
        );
        System.assertEquals(0, wrapper.amountTypeFields.size());
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