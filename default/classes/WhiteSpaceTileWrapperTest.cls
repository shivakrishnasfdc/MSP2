@isTest
private class WhiteSpaceTileWrapperTest {
    private static TestMockData md = new TestMockData();

    @isTest
    private static void basicInitializerTest() {
        WhiteSpaceTileWrapper wrapper = new WhiteSpaceTileWrapper();

        System.assertEquals(null, wrapper.id);
        System.assertEquals(null, wrapper.headerColor);
        System.assertEquals(null, wrapper.headerText);
        System.assertEquals(null, wrapper.displayFields);
    }

    @isTest
    private static void initializerWithCellTest() {
        WhiteSpaceTileWrapper wrapper = WhiteSpaceTileWrapper.createFor(
            md.mockWhiteSpaceCell,
            null,
            null,
            new Map<String, List<SObject>>(),
            md.mockWhiteSpaceCell.White_Space_Amount_Type_Associations__r,
            new List<WhiteSpaceTemplateCellFieldWrapper>(),
            new List<WSRelatedObjectWrapper>()
        );

        System.assertEquals(md.mockWhiteSpaceCell.id, wrapper.id);
        System.assertEquals(null, wrapper.headerColor);
        System.assertEquals(null, wrapper.headerText);
        System.assertEquals(1, wrapper.displayFields.size());
    }

    @isTest
    private static void initializerWithCellAndAmountTypesNoAssociationTest() {
        md.mockWhiteSpaceCell.pqcrush__Primary_Amount_Type__c = md.mockWhiteSpaceAmountTypeId;
        List<White_Space_Amount_Type__c> amountTypes = new List<White_Space_Amount_Type__c>{
            md.mockWhiteSpaceAmountType
        };
        List<WS_Data_Type__c> dataTypeValues = new List<WS_Data_Type__c>();

        WhiteSpaceTileWrapper wrapper = WhiteSpaceTileWrapper.createFor(
            md.mockWhiteSpaceCell,
            amountTypes,
            dataTypeValues,
            new Map<String, List<SObject>>(),
            md.mockWhiteSpaceCell.White_Space_Amount_Type_Associations__r,
            new List<WhiteSpaceTemplateCellFieldWrapper>(),
            new List<WSRelatedObjectWrapper>()
        );

        System.assertEquals(md.mockWhiteSpaceCell.id, wrapper.id);
        System.assertEquals(md.mockWhiteSpaceAmountType.pqcrush__Color_RGB__c, wrapper.headerColor);
        System.assertEquals(md.mockWhiteSpaceAmountType.Name, wrapper.headerText);
        System.assertEquals(2, wrapper.displayFields.size());
        System.assertEquals(
            White_Space_Cell__c.Info__c.getDescribe().getType().name().toLowerCase(),
            wrapper.displayFields[0].type
        );
        System.assertEquals(md.mockWhiteSpaceAmountType.id, wrapper.displayFields[1].id);
    }

    @isTest
    private static void initializerWithCellAndAmountTypesWithCellRelatedAssociationTest() {
        List<White_Space_Cell__c> mockCellList = (List<White_Space_Cell__c>) fflib_ApexMocksUtils.makeRelationship(
            List<White_Space_Cell__c>.class,
            new List<White_Space_Cell__c>{ md.mockWhiteSpaceCell },
            White_Space_Amount_Type_Association__c.White_Space_Cell__c,
            new List<List<White_Space_Amount_Type_Association__c>>{
                new List<White_Space_Amount_Type_Association__c>{ md.mockWhiteSpaceAmountTypeAssociation }
            }
        );
        md.mockWhiteSpaceCell = mockCellList[0];
        md.mockWhiteSpaceCell.pqcrush__Primary_Amount_Type__c = md.mockWhiteSpaceAmountTypeId;
        List<White_Space_Amount_Type__c> amountTypes = new List<White_Space_Amount_Type__c>{
            md.mockWhiteSpaceAmountType
        };
        List<WS_Data_Type__c> dataTypeValues = new List<WS_Data_Type__c>();

        WhiteSpaceTileWrapper wrapper = WhiteSpaceTileWrapper.createFor(
            md.mockWhiteSpaceCell,
            amountTypes,
            dataTypeValues,
            new Map<String, List<SObject>>(),
            md.mockWhiteSpaceCell.White_Space_Amount_Type_Associations__r,
            new List<WhiteSpaceTemplateCellFieldWrapper>(),
            new List<WSRelatedObjectWrapper>()
        );

        System.assertEquals(md.mockWhiteSpaceCell.id, wrapper.id);
        System.assertEquals(md.mockWhiteSpaceAmountType.pqcrush__Color_RGB__c, wrapper.headerColor);
        System.assertEquals(md.mockWhiteSpaceAmountType.Name, wrapper.headerText);
        System.assertEquals(2, wrapper.displayFields.size());
        System.assertEquals(null, wrapper.displayFields[0].id);
        System.assertEquals(
            White_Space_Cell__c.Info__c.getDescribe().getType().name().toLowerCase(),
            wrapper.displayFields[0].type
        );
        System.assertEquals(md.mockWhiteSpaceAmountType.id, wrapper.displayFields[1].id);
        System.assertEquals(1, wrapper.displayFields[1].data.size());
        System.assert(wrapper.displayFields[1].isPrimary);
    }

    @isTest
    private static void initializerWithCellAndAmountTypesAndAssociationsTest() {
        List<White_Space_Amount_Type_Association__c> associations = new List<White_Space_Amount_Type_Association__c>{
            md.mockWhiteSpaceAmountTypeAssociation
        };
        md.mockWhiteSpaceCell.pqcrush__Primary_Amount_Type__c = md.mockWhiteSpaceAmountTypeId;
        List<White_Space_Amount_Type__c> amountTypes = new List<White_Space_Amount_Type__c>{
            md.mockWhiteSpaceAmountType
        };
        List<WS_Data_Type__c> dataTypeValues = new List<WS_Data_Type__c>();

        WhiteSpaceTileWrapper wrapper = WhiteSpaceTileWrapper.createFor(
            md.mockWhiteSpaceCell,
            amountTypes,
            dataTypeValues,
            new Map<String, List<SObject>>(),
            associations,
            new List<WhiteSpaceTemplateCellFieldWrapper>(),
            new List<WSRelatedObjectWrapper>()
        );

        System.assertEquals(md.mockWhiteSpaceCell.id, wrapper.id);
        System.assertEquals(md.mockWhiteSpaceAmountType.pqcrush__Color_RGB__c, wrapper.headerColor);
        System.assertEquals(md.mockWhiteSpaceAmountType.Name, wrapper.headerText);
        System.assertEquals(2, wrapper.displayFields.size());
        System.assertEquals(null, wrapper.displayFields[0].id);
        System.assertEquals(
            White_Space_Cell__c.Info__c.getDescribe().getType().name().toLowerCase(),
            wrapper.displayFields[0].type
        );
        System.assertEquals(md.mockWhiteSpaceAmountType.id, wrapper.displayFields[1].id);
        System.assertEquals(1, wrapper.displayFields[1].data.size());
        System.assert(wrapper.displayFields[1].isPrimary);
    }

    @isTest
    private static void initializerWithCellAndAmountTypesWithRelatedObjectWrappersTest() {
        md.mockWhiteSpaceCell.pqcrush__Primary_Amount_Type__c = md.mockWhiteSpaceAmountTypeId;
        List<White_Space_Amount_Type__c> amountTypes = new List<White_Space_Amount_Type__c>{
            md.mockWhiteSpaceAmountType
        };
        List<WS_Data_Type__c> dataTypeValues = new List<WS_Data_Type__c>();

        WhiteSpaceTileWrapper wrapper = WhiteSpaceTileWrapper.createFor(
            md.mockWhiteSpaceCell,
            amountTypes,
            dataTypeValues,
            new Map<String, List<SObject>>(),
            md.mockWhiteSpaceCell.White_Space_Amount_Type_Associations__r,
            new List<WhiteSpaceTemplateCellFieldWrapper>{ md.mockRelatedCellFieldWrapper },
            new List<WSRelatedObjectWrapper>{ md.mockWSRelatedObjectWrapper }
        );

        System.assertEquals(md.mockWhiteSpaceCell.id, wrapper.id);
        System.assertEquals(md.mockWhiteSpaceAmountType.pqcrush__Color_RGB__c, wrapper.headerColor);
        System.assertEquals(md.mockWhiteSpaceAmountType.Name, wrapper.headerText);
        System.assertEquals(3, wrapper.displayFields.size());
        System.assertEquals(
            White_Space_Cell__c.Info__c.getDescribe().getType().name().toLowerCase(),
            wrapper.displayFields[0].type
        );
        System.assertEquals(md.mockWhiteSpaceAmountType.id, wrapper.displayFields[1].id);
        System.assertEquals('Account', wrapper.displayFields[2].id);
    }

    @isTest
    private static void initializerWithTemplateAndValidRelatedTest() {
        List<White_Space_Amount_Type__c> amountTypes = new List<White_Space_Amount_Type__c>{
            md.mockWhiteSpaceAmountType
        };

        WhiteSpaceTemplateMappingWrapper rowWrap = new WhiteSpaceTemplateMappingWrapper(md.mockAccountMapping);
        WhiteSpaceTemplateMappingWrapper columnWrap = new WhiteSpaceTemplateMappingWrapper(md.mockProductMapping);

        Map<Id, Mapping__c> cellMappingById = new Map<Id, Mapping__c>();
        cellMappingById.put(md.mockAssetMappingId, md.mockAssetMapping);

        WhiteSpaceTemplateCellFieldWrapper cfWrapper = new WhiteSpaceTemplateCellFieldWrapper(
            md.mockCellField,
            cellMappingById,
            rowWrap,
            columnWrap,
            true
        );

        Map<String, List<SObject>> relatedMap = new Map<String, List<SObject>>();
        relatedMap.put(cfWrapper.id, new List<SObject>{ md.mockAsset });

        List<WhiteSpaceTemplateCellFieldWrapper> displayFieldTemplates = new List<WhiteSpaceTemplateCellFieldWrapper>{
            cfWrapper
        };
        List<WS_Data_Type__c> dataTypeValues = new List<WS_Data_Type__c>();

        WhiteSpaceTileWrapper wrapper = WhiteSpaceTileWrapper.createFor(
            md.mockWhiteSpaceCell,
            amountTypes,
            dataTypeValues,
            relatedMap,
            displayFieldTemplates,
            new List<WhiteSpaceTemplateCellFieldWrapper>{ md.mockRelatedCellFieldWrapper },
            new List<WSRelatedObjectWrapper>{ md.mockWSRelatedObjectWrapper }
        );

        System.assertEquals(md.mockWhiteSpaceCell.id, wrapper.id);
        System.assertEquals(null, wrapper.headerColor);
        System.assertEquals(null, wrapper.headerText);
        System.assertEquals(3, wrapper.displayFields.size());
        System.assertEquals(null, wrapper.displayFields[0].id);
        System.assertEquals(
            White_Space_Cell__c.Info__c.getDescribe().getType().name().toLowerCase(),
            wrapper.displayFields[0].type
        );
        System.assertEquals(md.mockWhiteSpaceAmountType.id, wrapper.displayFields[1].id);
        System.assertEquals(1, wrapper.displayFields[1].data.size());
        System.assertEquals(md.mockAssetId, wrapper.displayFields[1].data[0].objectId);
        System.assertEquals('Account', wrapper.displayFields[2].id);
        System.assertEquals(0, wrapper.displayFields[2].data.size());
    }

    @isTest
    private static void toSObjectCellTest() {
        WhiteSpaceTileWrapper wrapper = WhiteSpaceTileWrapper.createFor(
            md.mockWhiteSpaceCell,
            null,
            null,
            new Map<String, List<SObject>>(),
            md.mockWhiteSpaceCell.White_Space_Amount_Type_Associations__r,
            new List<WhiteSpaceTemplateCellFieldWrapper>(),
            new List<WSRelatedObjectWrapper>()
        );
        White_Space_Cell__c cell = wrapper.toSObjectCell();

        System.assertEquals(md.mockWhiteSpaceCell.Id, cell.Id);
        System.assertEquals(md.mockWhiteSpaceCell.Info__c, cell.Info__c);
        System.assertEquals(md.mockWhiteSpaceCell.Primary_Amount_Type__c, cell.Primary_Amount_Type__c);
    }
}