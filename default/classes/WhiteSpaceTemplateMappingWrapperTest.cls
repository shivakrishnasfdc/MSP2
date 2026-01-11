@isTest
private class WhiteSpaceTemplateMappingWrapperTest {
    @isTest
    private static void basicInitializerTest() {
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper();

        System.assertEquals(null, wrapper.objectName);
        System.assertEquals(null, wrapper.objectLabel);
        System.assertEquals(null, wrapper.objectLabelPlural);
        System.assertEquals(null, wrapper.labelFieldName);
        System.assertEquals(null, wrapper.labelFieldInfo);
        System.assertEquals(null, wrapper.valueFieldName);
        System.assertEquals(null, wrapper.valueFieldInfo);
    }

    @isTest
    private static void initializerWithStringsTest() {
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper('Opportunity', 'Name', 'Name');

        System.assertEquals('Opportunity', wrapper.objectName);
        System.assertEquals('Name', wrapper.labelFieldName);
        System.assertEquals('Name', wrapper.labelFieldInfo.apiName);
        System.assertEquals('Name', wrapper.valueFieldName);
        System.assertEquals('Name', wrapper.valueFieldInfo.apiName);
        System.assertEquals('Opportunity', wrapper.objectLabel);
        System.assertEquals('Opportunities', wrapper.objectLabelPlural);
    }

    @isTest
    private static void initializerWithCompoundFieldsTest() {
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper(
            'Opportunity',
            'OpportunityLineItem.Name',
            'OpportunityLineItem.Quantity'
        );

        System.assertEquals('Opportunity', wrapper.objectName);
        System.assertEquals('OpportunityLineItem.Name', wrapper.LabelFieldName);
        System.assertEquals('Name', wrapper.labelFieldInfo.apiName);
        System.assertEquals('OpportunityLineItem', wrapper.labelFieldInfo.sobjectApiName);
        System.assertEquals('OpportunityLineItem.Quantity', wrapper.valueFieldName);
        System.assertEquals('Quantity', wrapper.valueFieldInfo.apiName);
        System.assertEquals('OpportunityLineItem', wrapper.valueFieldInfo.sobjectApiName);
        System.assertEquals('Opportunity', wrapper.objectLabel);
        System.assertEquals('Opportunities', wrapper.objectLabelPlural);
    }

    @isTest
    private static void initializerWithStringsNullTest() {
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper(null, 'Name', 'Name');

        System.assertEquals(null, wrapper.objectName);
        System.assertEquals(null, wrapper.labelFieldName);
        System.assertEquals(null, wrapper.labelFieldInfo);
        System.assertEquals(null, wrapper.valueFieldName);
        System.assertEquals(null, wrapper.valueFieldInfo);
        System.assertEquals(null, wrapper.objectLabel);
        System.assertEquals(null, wrapper.objectLabelPlural);
    }

    @isTest
    private static void initializerWithMappingTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);

        System.assertEquals(md.mockOppMapping.ObjectType__c, wrapper.objectName);
        System.assertEquals(md.mockOppMapping.DisplayLabelField__c, wrapper.labelFieldName);
        System.assertEquals(md.mockOppMapping.DisplayLabelField__c, wrapper.labelFieldInfo.apiName);
        System.assertEquals(md.mockOppMapping.ValueField__c, wrapper.valueFieldName);
        System.assertEquals(md.mockOppMapping.ValueField__c, wrapper.valueFieldInfo.apiName);
        System.assertEquals('Opportunity', wrapper.objectLabel);
        System.assertEquals('Opportunities', wrapper.objectLabelPlural);
    }

    @isTest
    private static void initializerWithrelationshipWrapperTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper(md.mockWSRelatedObjectWrapper);

        System.assertEquals(md.mockWSRelatedObjectWrapper.objDesc.getName(), wrapper.objectName);
        System.assertEquals(md.mockWSRelatedObjectWrapper.labelFieldName, wrapper.labelFieldName);
        System.assertEquals(md.mockWSRelatedObjectWrapper.labelFieldName, wrapper.valueFieldName);
        System.assertEquals(md.mockWSRelatedObjectWrapper.labelFieldName, wrapper.valueFieldInfo.apiName);
        System.assertEquals(md.mockWSRelatedObjectWrapper.labelFieldName, wrapper.labelFieldInfo.apiName);
        System.assertEquals(md.mockWSRelatedObjectWrapper.objDesc.getLabel(), wrapper.objectLabel);
        System.assertEquals(md.mockWSRelatedObjectWrapper.objDesc.getLabelPlural(), wrapper.objectLabelPlural);
    }

    @isTest
    private static void getQueryFieldsOLIValuesTest() {
        TestMockData md = new TestMockData();
        md.mockOppMapping.DisplayLabelField__c = 'OpportunityLineItem.Name';
        md.mockOppMapping.ValueField__c = 'OpportunityLineItem.Quantity';
        md.mockOppMapping.ParentField__c = 'OpportunityLineItem.OpportunityId';
        md.mockOppMapping.GroupResults__c = true;
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        List<String> results = wrapper.getQueryFields();

        System.assertEquals(0, results.size());
    }

    @isTest
    private static void getQueryFieldsTest() {
        TestMockData md = new TestMockData();
        md.mockOppMapping.ParentField__c = 'CreatedById';
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        List<String> results = wrapper.getQueryFields();

        System.assert(results.contains(wrapper.labelFieldName));
        System.assert(results.contains(wrapper.valueFieldName));
        System.assert(results.contains(wrapper.parentIdFieldName));
        System.assertEquals(3, results.size());
    }

    @isTest
    private static void getgetOLIQueryFieldsNonOLIValuesTest() {
        TestMockData md = new TestMockData();
        md.mockOppMapping.ParentField__c = 'CreatedById';
        md.mockOppMapping.GroupResults__c = true;
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        List<String> results = wrapper.getOLIQueryFields();

        System.assertEquals(0, results.size());
    }

    @isTest
    private static void getgetOLIQueryFieldsTest() {
        TestMockData md = new TestMockData();
        md.mockOppMapping.DisplayLabelField__c = 'OpportunityLineItem.Name';
        md.mockOppMapping.ValueField__c = 'OpportunityLineItem.Quantity';
        md.mockOppMapping.ParentField__c = 'OpportunityLineItem.OpportunityId';
        md.mockOppMapping.GroupResults__c = true;
        WhiteSpaceTemplateMappingWrapper wrapper = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        List<String> results = wrapper.getOLIQueryFields();

        System.assert(results.contains(wrapper.labelFieldName));
        System.assert(results.contains(wrapper.valueFieldName));
        System.assert(results.contains(wrapper.parentIdFieldName));
        System.assertEquals(3, results.size());
    }
}