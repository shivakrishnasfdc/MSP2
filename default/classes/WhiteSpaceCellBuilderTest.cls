@isTest
private class WhiteSpaceCellBuilderTest {
    private static TestMockData md = new TestMockData();
    private static WhiteSpaceAmountTypeSelector mockATSelector = md.mockWhiteSpaceAmountTypeSelector;

    @isTest
    private static void populateDisplayTileMapTest() {
        Account acc1 = new Account(Name = 'acc1');
        insert acc1;

        Contact con1 = new Contact(FirstName = 'contact1', LastName = 'test');
        insert con1;

        Opportunity testOpportunity1 = TestDataFactory.createOpportunity(acc1, 'opp1');
        testOpportunity1.ContactId = con1.id;
        Opportunity testOpportunity2 = TestDataFactory.createOpportunity(acc1, 'opp2');
        testOpportunity2.ContactId = con1.id;
        List<Opportunity> opps = new List<Opportunity>{ testOpportunity1, testOpportunity2 };
        insert opps;

        White_Space_Template_Cell_Field__c cf = new White_Space_Template_Cell_Field__c(
            Id = md.mockCellFieldId,
            pqcrush__DisplayFieldId__c = md.mockWhiteSpaceAmountTypeId,
            pqcrush__ValueMapping__c = md.mockOppMappingId,
            pqcrush__ValueMapping__r = md.mockOppMapping,
            pqcrush__WhitespaceTemplate__c = md.mockWhiteSpaceTemplateId
        );

        White_Space_Template_Cell_Field__c cf2 = new White_Space_Template_Cell_Field__c(
            Id = fflib_IDGenerator.generate(White_Space_Template_Cell_Field__c.SObjectType),
            pqcrush__ValueMapping__c = md.mockOppMappingId,
            pqcrush__ValueMapping__r = md.mockOppMapping,
            pqcrush__WhitespaceTemplate__c = md.mockWhiteSpaceTemplateId
        );

        WhiteSpaceTemplateMappingWrapper rowMapping = new WhiteSpaceTemplateMappingWrapper(md.mockAccountMapping);
        Mapping__c mockContactMapping = new Mapping__c(
            ObjectType__c = 'Contact',
            DisplayLabelField__c = 'Name',
            ValueField__c = 'Name',
            Id = fflib_IDGenerator.generate(Mapping__c.SObjectType)
        );
        WhiteSpaceTemplateMappingWrapper columnMapping = new WhiteSpaceTemplateMappingWrapper(mockContactMapping);

        WhiteSpaceTemplateCellFieldWrapper wrapper1 = new WhiteSpaceTemplateCellFieldWrapper(
            cf,
            md.mockOppMapping,
            rowMapping,
            columnMapping,
            true
        );

        WhiteSpaceTemplateCellFieldWrapper wrapper2 = new WhiteSpaceTemplateCellFieldWrapper(
            cf2,
            md.mockOppMapping,
            rowMapping,
            columnMapping,
            true
        );

        WhiteSpaceTemplateCellFieldWrapper wrapperRel = md.mockRelatedCellFieldWrapper;

        List<WhiteSpaceTemplateCellFieldWrapper> amountTypeFields = new List<WhiteSpaceTemplateCellFieldWrapper>{
            wrapper1
        };
        List<WhiteSpaceTemplateCellFieldWrapper> basicFields = new List<WhiteSpaceTemplateCellFieldWrapper>{ wrapper2 };

        White_Space_Row__c row = md.mockWhiteSpaceRow;
        row.pqcrush__Related_Object_Id__c = acc1.id;
        White_Space_Column__c column = md.mockWhiteSpaceColumn;
        column.pqcrush__Related_Object_Id__c = con1.id;
        WhiteSpaceCollectionWrapper wrappedRow = new WhiteSpaceCollectionWrapper(row, rowMapping, acc1);
        WhiteSpaceCollectionWrapper wrappedColumn = new WhiteSpaceCollectionWrapper(column, columnMapping, con1);
        WSRelatedObjectWrapper wsrobjr = md.mockWSRelatedObjectWrapper;

        Map<String, Map<String, List<SObject>>> fieldDataByRelatedIds = new Map<String, Map<String, List<SObject>>>();
        Map<String, List<SObject>> wrapper1Data = wrapper1.getMapForRecordList(
            new List<SObject>{ testOpportunity1, testOpportunity2 },
            null
        );
        Map<String, List<SObject>> wrapper2Data = wrapper2.getMapForRecordList(
            new List<SObject>{ testOpportunity1, testOpportunity2 },
            null
        );
        Map<String, List<SObject>> wrapperRelData = new Map<String, List<SObject>>{
            md.mockWhiteSpaceCellId => new List<SObject>{ acc1 }
        };

        fillMap(fieldDataByRelatedIds, wrapper1Data, wrapper1);
        fillMap(fieldDataByRelatedIds, wrapper2Data, wrapper2);
        fillMap(fieldDataByRelatedIds, wrapperRelData, wrapperRel);

        md.mocks.startStubbing();
        md.mocks.when(mockATSelector.selectById(new Set<Id>{ md.mockWhiteSpaceAmountTypeId }))
            .thenReturn(new List<pqcrush__White_Space_Amount_Type__c>{ md.mockWhiteSpaceAmountType });
        md.mocks.stopStubbing();

        Map<String, List<WhiteSpaceTileWrapper>> result = new WhiteSpaceCellBuilder(
                new List<WhiteSpaceCollectionWrapper>{ wrappedColumn },
                new List<WhiteSpaceCollectionWrapper>{ wrappedRow },
                new List<White_Space_Cell__c>{ md.mockWhiteSpaceCell },
                amountTypeFields,
                basicFields,
                new List<pqcrush__White_Space_Amount_Type__c>{ md.mockWhiteSpaceAmountType },
                new List<WS_Data_Type__c>(),
                new List<WhiteSpaceTemplateCellFieldWrapper>{ wrapperRel },
                new List<WSRelatedObjectWrapper>{ wsrobjr },
                fieldDataByRelatedIds
            )
            .populateDisplayTileMap();

        System.assertEquals(1, result.size());
        List<WhiteSpaceTileWrapper> tiles = result.values()[0];
        System.assertEquals(1, tiles.size());
        WhiteSpaceTileWrapper tile = tiles[0];
        System.assertEquals(md.mockWhiteSpaceCellId, tile.id);
        System.assertEquals(4, tile.displayFields.size());

        Map<String, WhiteSpaceDisplayFieldWrapper> displayFieldMap = new Map<String, WhiteSpaceDisplayFieldWrapper>();
        for (WhiteSpaceDisplayFieldWrapper field : tile.displayFields) {
            if (
                field.fieldType == 'amountType' ||
                field.fieldType == 'basicMapping' ||
                field.fieldType == 'relatedMapping'
            ) {
                displayFieldMap.put(field.id, field);
            }
        }

        WhiteSpaceDisplayFieldWrapper amountTypeField = displayFieldMap.get(md.mockWhiteSpaceAmountType.Id);
        System.assert(amountTypeField != null);
        System.assertEquals(2, amountTypeField.data.size());

        WhiteSpaceDisplayFieldWrapper basicMappingField = displayFieldMap.get(cf2.id);
        System.assert(basicMappingField != null);
        System.assertEquals(2, basicMappingField.data.size());

        WhiteSpaceDisplayFieldWrapper relatedMappingField = displayFieldMap.get('Account');
        System.assert(relatedMappingField != null);
        System.assertEquals(1, relatedMappingField.data.size());
    }

    private static void fillMap(
        Map<String, Map<String, List<SObject>>> fieldDataByRelatedIds,
        Map<String, List<SObject>> resultsMap,
        WhiteSpaceTemplateCellFieldWrapper field
    ) {
        for (String key : resultsMap.keySet()) {
            List<SObject> matchingRecords = resultsMap.get(key);
            Map<String, List<SObject>> dataByFieldId = fieldDataByRelatedIds.get(key);
            if (dataByFieldId == null) {
                dataByFieldId = new Map<String, List<SObject>>();
            }
            dataByFieldId.put(field.id, matchingRecords);
            fieldDataByRelatedIds.put(key, dataByFieldId);
        }
    }
}