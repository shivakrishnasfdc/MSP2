@isTest
private class WhiteSpaceDisplayFieldWrapperTest {
    private static TestMockData md = new TestMockData();

    @isTest
    private static void basicInitializerTest() {
        WhiteSpaceDisplayFieldWrapper wrapper = new WhiteSpaceDisplayFieldWrapper();

        System.assertEquals(null, wrapper.type);
        System.assertEquals(null, wrapper.abbreviation);
        System.assertEquals(null, wrapper.displayName);
        System.assertEquals(null, wrapper.color);
        System.assertEquals(null, wrapper.displayOrder);
        System.assertEquals(null, wrapper.id);
        System.assertEquals(null, wrapper.isEditable);
        System.assertEquals(null, wrapper.isInfoField);
        System.assertEquals(null, wrapper.data);
        System.assertEquals(null, wrapper.fieldType);
        System.assertEquals(null, wrapper.configuration);
    }

    @isTest
    private static void createWithNullAssociationsTest() {
        White_Space_Amount_Type__c at = md.mockWhiteSpaceAmountType;
        WhiteSpaceDisplayFieldWrapper wrapper = WhiteSpaceDisplayFieldWrapper.createFor(at, null, false);

        System.assertEquals(Schema.DisplayType.CURRENCY.name().toLowerCase(), wrapper.type);
        System.assertEquals(at.Abbreviation__c, wrapper.abbreviation);
        System.assertEquals(at.Name, wrapper.displayName);
        System.assertEquals(at.Color_RGB__c, wrapper.color);
        System.assertEquals(at.Order__c, wrapper.displayOrder);
        System.assertEquals(at.Id, wrapper.id);
        System.assertEquals(true, wrapper.isEditable);
        System.assertEquals(0, wrapper.data.size());
        System.assertEquals('amountType', wrapper.fieldType);
    }

    @isTest
    private static void createWithAssociationsNoPrimaryTest() {
        White_Space_Amount_Type__c at = md.mockWhiteSpaceAmountType;
        List<White_Space_Amount_Type_Association__c> ataList = new List<White_Space_Amount_Type_Association__c>{
            md.mockWhiteSpaceAmountTypeAssociation
        };
        WhiteSpaceDisplayFieldWrapper wrapper = WhiteSpaceDisplayFieldWrapper.createFor(at, ataList, null);

        System.assertEquals(Schema.DisplayType.CURRENCY.name().toLowerCase(), wrapper.type);
        System.assertEquals(at.Abbreviation__c, wrapper.abbreviation);
        System.assertEquals(at.Name, wrapper.displayName);
        System.assertEquals(at.Color_RGB__c, wrapper.color);
        System.assertEquals(at.Order__c, wrapper.displayOrder);
        System.assertEquals(at.Id, wrapper.id);
        System.assertEquals(true, wrapper.isEditable);
        System.assertEquals(false, wrapper.isPrimary);
        System.assertEquals(1, wrapper.data.size());
        System.assertEquals('amountType', wrapper.fieldType);
    }

    @isTest
    private static void createWithTemplateAndNullObjectList() {
        White_Space_Amount_Type__c at = md.mockWhiteSpaceAmountType;
        WhiteSpaceTemplateCellFieldWrapper template = new WhiteSpaceTemplateCellFieldWrapper();
        template.mapping = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        WhiteSpaceDisplayFieldWrapper wrapper = WhiteSpaceDisplayFieldWrapper.createFor(at, template, null, null);

        System.assertEquals(0, wrapper.data.size());
        System.assertEquals('amountType', wrapper.fieldType);
    }

    @isTest
    private static void createWithNullTemplateAndObjectList() {
        White_Space_Amount_Type__c at = md.mockWhiteSpaceAmountType;
        List<Opportunity> opps = new List<Opportunity>{ md.mockOpportunity };
        WhiteSpaceDisplayFieldWrapper wrapper = WhiteSpaceDisplayFieldWrapper.createFor(at, null, opps, null);

        System.assertEquals(0, wrapper.data.size());
        System.assertEquals('amountType', wrapper.fieldType);
    }

    @isTest
    private static void createWithTemplateAndRelatedObjects() {
        List<Opportunity> opps = new List<Opportunity>{ md.mockOpportunity };
        White_Space_Amount_Type__c at = md.mockWhiteSpaceAmountType;
        WhiteSpaceTemplateCellFieldWrapper template = new WhiteSpaceTemplateCellFieldWrapper();
        template.mapping = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        WhiteSpaceDisplayFieldWrapper wrapper = WhiteSpaceDisplayFieldWrapper.createFor(at, template, opps, null);

        System.assertEquals(1, wrapper.data.size());
        System.assertEquals('amountType', wrapper.fieldType);
    }

    @isTest
    private static void createWithTemplateAndNonMatchingOliObjectsTest() {
        Id oli1 = fflib_IDGenerator.generate(OpportunityLineItem.SObjectType);
        Id oli2 = fflib_IDGenerator.generate(OpportunityLineItem.SObjectType);
        Id productId = fflib_IDGenerator.generate(Product2.SObjectType);
        String oliJSON =
            '[{"Id": "' +
            oli1 +
            '", "OpportunityId":"' +
            md.mockOpportunityId +
            '","Product2Id":"' +
            productId +
            '","Quantity":1}, {"Id": "' +
            oli2 +
            '", "OpportunityId":"' +
            md.mockOpportunityId +
            '","Product2Id":"' +
            productId +
            '","Quantity":2}]';
        String oppsJSON =
            '{"Id": "' +
            md.mockOpportunityId +
            '", "OpportunityLineItems": {"totalSize":2,"done":true,"records": ' +
            oliJSON +
            '}, "Name": "Fake Opportunity name", "StageName": "Prospecting", "Amount": 12.05}';
        Opportunity opp = (Opportunity) JSON.deserialize(oppsJSON, Opportunity.class);
        List<Opportunity> opps = new List<Opportunity>{ opp };
        White_Space_Amount_Type__c at = md.mockWhiteSpaceAmountType;
        WhiteSpaceTemplateCellFieldWrapper template = new WhiteSpaceTemplateCellFieldWrapper();
        md.mockOppMapping.ValueField__c = 'OpportunityLineItem.Quantity';
        template.mapping = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        WhiteSpaceDisplayFieldWrapper wrapper = WhiteSpaceDisplayFieldWrapper.createFor(
            at,
            template,
            opps,
            new Set<String>{ md.mockProductId }
        );

        System.assertEquals(0, wrapper.data.size());
    }

    @isTest
    private static void createWithTemplateAndOliObjectsCountTest() {
        Id oli1 = fflib_IDGenerator.generate(OpportunityLineItem.SObjectType);
        Id oli2 = fflib_IDGenerator.generate(OpportunityLineItem.SObjectType);
        Id oli3 = fflib_IDGenerator.generate(OpportunityLineItem.SObjectType);
        Id productId = fflib_IDGenerator.generate(Product2.SObjectType);
        String oliJSON =
            '[{"Id": "' +
            oli1 +
            '", "OpportunityId":"' +
            md.mockOpportunityId +
            '","Product2Id":"' +
            md.mockProductId +
            '","Quantity":1}, {"Id": "' +
            oli2 +
            '", "OpportunityId":"' +
            md.mockOpportunityId +
            '","Product2Id":"' +
            md.mockProductId +
            '","Quantity":2}, {"Id": "' +
            oli3 +
            '", "OpportunityId":"' +
            md.mockOpportunityId +
            '","Product2Id":"' +
            productId +
            '","Quantity":2}]';
        String oppsJSON =
            '{"Id": "' +
            md.mockOpportunityId +
            '", "OpportunityLineItems": {"totalSize":2,"done":true,"records": ' +
            oliJSON +
            '}, "Name": "Fake Opportunity name", "StageName": "Prospecting", "Amount": 12.05}';
        Opportunity opp = (Opportunity) JSON.deserialize(oppsJSON, Opportunity.class);
        List<Opportunity> opps = new List<Opportunity>{ opp };
        White_Space_Amount_Type__c at = md.mockWhiteSpaceAmountType;
        WhiteSpaceTemplateCellFieldWrapper template = new WhiteSpaceTemplateCellFieldWrapper();
        md.mockOppMapping.ValueField__c = 'OpportunityLineItem.Quantity';
        template.mapping = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        WhiteSpaceDisplayFieldWrapper wrapper = WhiteSpaceDisplayFieldWrapper.createFor(
            at,
            template,
            opps,
            new Set<String>{ md.mockProductId }
        );

        System.assertEquals(2, wrapper.data.size());
    }

    @isTest
    private static void createWithTemplateAndOliObjectsValuesTest() {
        Id oli1 = fflib_IDGenerator.generate(OpportunityLineItem.SObjectType);
        String expectedLabel = 'Fake Opportunity name';
        String oliJSON =
            '[{"Id": "' +
            oli1 +
            '", "OpportunityId":"' +
            md.mockOpportunityId +
            '","Product2Id":"' +
            md.mockProductId +
            '","Quantity":1}]';
        String oppsJSON =
            '{"Id": "' +
            md.mockOpportunityId +
            '", "OpportunityLineItems": {"totalSize":2,"done":true,"records": ' +
            oliJSON +
            '}, "Name": "' +
            expectedLabel +
            '", "StageName": "Prospecting", "Amount": 12.05}';
        Opportunity opp = (Opportunity) JSON.deserialize(oppsJSON, Opportunity.class);
        List<Opportunity> opps = new List<Opportunity>{ opp };
        White_Space_Amount_Type__c at = md.mockWhiteSpaceAmountType;
        WhiteSpaceTemplateCellFieldWrapper template = new WhiteSpaceTemplateCellFieldWrapper();
        md.mockOppMapping.ValueField__c = 'OpportunityLineItem.Quantity';
        template.mapping = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        WhiteSpaceDisplayFieldWrapper wrapper = WhiteSpaceDisplayFieldWrapper.createFor(
            at,
            template,
            opps,
            new Set<String>{ md.mockProductId }
        );

        System.assertEquals(1, wrapper.data.size());
        System.assertEquals(oli1, wrapper.data[0].objectId);
        System.assertEquals(md.mockOpportunityId, wrapper.data[0].secondaryObjectId);
        System.assertEquals(1, wrapper.data[0].value);
        System.assertEquals(expectedLabel, wrapper.data[0].displayName);
        System.assertEquals('amountType', wrapper.fieldType);
    }

    @isTest
    private static void createForBasicMapping() {
        List<Opportunity> opps = new List<Opportunity>{ md.mockOpportunity };
        WhiteSpaceTemplateCellFieldWrapper template = new WhiteSpaceTemplateCellFieldWrapper();
        template.mapping = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        WhiteSpaceDisplayFieldWrapper wrapper = WhiteSpaceDisplayFieldWrapper.createFor(template, opps);

        System.assertEquals(1, wrapper.data.size());
        System.assertEquals('text', wrapper.type);
        System.assertEquals('basicMapping', wrapper.fieldType);
        System.assertEquals(template.mapping.objectLabelPlural, wrapper.displayName);
    }

    @isTest
    private static void createForInfoField() {
        WhiteSpaceDisplayFieldWrapper wrapper = WhiteSpaceDisplayFieldWrapper.infoFieldWrapper(md.mockWhiteSpaceCell);

        System.assertEquals(White_Space_Cell__c.Info__c.getDescribe().getType().name().toLowerCase(), wrapper.type);
        System.assertEquals(System.Label.Info_Abbreviation, wrapper.abbreviation);
        System.assertEquals(System.Label.Info, wrapper.displayName);
        System.assertEquals(null, wrapper.color);
        System.assertEquals(-1, wrapper.displayOrder);
        System.assertEquals(null, wrapper.id);
        System.assertEquals(true, wrapper.isEditable);
        System.assertNotEquals(null, wrapper.data);
        System.assertEquals(1, wrapper.data.size());
        System.assertEquals('info', wrapper.fieldType);
    }

    @isTest
    private static void createForRelatedObjectWrapper() {
        WSRelatedObjectWrapper relWrap = md.mockWSRelatedObjectWrapper;
        WhiteSpaceTemplateCellFieldWrapper config = md.mockRelatedCellFieldWrapper;
        List<SObject> records = new List<SObject>{ md.mockAccount };
        WhiteSpaceDisplayFieldWrapper wrapper = WhiteSpaceDisplayFieldWrapper.createFor(relWrap, config, records);

        System.assertEquals(1, wrapper.data.size());
        System.assertEquals(md.mockAccountId, wrapper.data[0].objectId);
        System.assertEquals('STRING', wrapper.type);
        System.assertEquals('relatedMapping', wrapper.fieldType);
        System.assertEquals(config.mapping.objectLabelPlural, wrapper.displayName);
        System.assertEquals(relWrap.color, wrapper.color);
    }

    @isTest
    private static void createForCompoundRelatedObjectWrapper() {
        WSRelatedObjectWrapper relWrap = md.mockWSRelatedObjectWrapperCompound;
        WhiteSpaceTemplateCellFieldWrapper config = md.mockRelatedCellFieldWrapperCompound;
        List<SObject> records = new List<SObject>{ md.mockContactWithAccount };
        WhiteSpaceDisplayFieldWrapper wrapper = WhiteSpaceDisplayFieldWrapper.createFor(relWrap, config, records);

        System.assertEquals(1, wrapper.data.size());
        System.assertEquals(md.mockAccountId, wrapper.data[0].objectId);
        System.assertEquals(md.mockAccount.Name, wrapper.data[0].value);
        System.assertEquals('STRING', wrapper.type);
        System.assertEquals('relatedMapping', wrapper.fieldType);
        System.assertEquals(config.mapping.objectLabelPlural, wrapper.displayName);
        System.assertEquals(relWrap.color, wrapper.color);
    }

    @isTest
    private static void compareToTest() {
        WhiteSpaceDisplayFieldWrapper wrapper1 = new WhiteSpaceDisplayFieldWrapper();
        WhiteSpaceDisplayFieldWrapper wrapper2 = new WhiteSpaceDisplayFieldWrapper();

        wrapper1.displayOrder = 0;
        wrapper2.displayOrder = 1;
        System.assertEquals(1, wrapper2.compareTo(wrapper1));

        wrapper1.displayOrder = 2;
        wrapper2.displayOrder = 1;
        System.assertEquals(-1, wrapper2.compareTo(wrapper1));

        wrapper1.displayOrder = 0;
        wrapper1.displayName = 'aa';
        wrapper2.displayOrder = 0;
        wrapper2.displayName = 'ab';
        System.assertEquals(1, wrapper2.compareTo(wrapper1));

        wrapper1.displayOrder = 0;
        wrapper1.displayName = 'ab';
        wrapper2.displayOrder = 0;
        wrapper2.displayName = 'aa';
        System.assertEquals(-1, wrapper2.compareTo(wrapper1));

        wrapper1.displayOrder = 0;
        wrapper1.displayName = 'aa';
        wrapper2.displayOrder = 0;
        wrapper2.displayName = 'aa';
        System.assertEquals(0, wrapper2.compareTo(wrapper1));
    }

    @isTest
    private static void compareToDifferentTypesTest() {
        White_Space_Amount_Type__c at = md.mockWhiteSpaceAmountType;
        WhiteSpaceDisplayFieldWrapper wrapperAT = WhiteSpaceDisplayFieldWrapper.createFor(at, null, false);
        wrapperAT.displayOrder = 0;

        WhiteSpaceTemplateCellFieldWrapper template = new WhiteSpaceTemplateCellFieldWrapper();
        template.mapping = new WhiteSpaceTemplateMappingWrapper(md.mockOppMapping);
        WhiteSpaceDisplayFieldWrapper wrapperBT = WhiteSpaceDisplayFieldWrapper.createFor(template, null);
        wrapperBT.displayOrder = 0;

        WSRelatedObjectWrapper relWrap = md.mockWSRelatedObjectWrapper;
        WhiteSpaceTemplateCellFieldWrapper config = md.mockRelatedCellFieldWrapper;
        WhiteSpaceDisplayFieldWrapper wrapperRT = WhiteSpaceDisplayFieldWrapper.createFor(relWrap, config, null);
        wrapperRT.displayOrder = 0;

        System.assert(wrapperRT.compareTo(wrapperAT) > 0);
        System.assert(wrapperRT.compareTo(wrapperBT) > 0);
        System.assert(wrapperBT.compareTo(wrapperAT) > 0);
    }
}