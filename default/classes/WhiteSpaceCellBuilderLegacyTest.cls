@isTest
private class WhiteSpaceCellBuilderLegacyTest {
    private static TestMockData md = new TestMockData();
    private static WhiteSpaceAmountTypeSelector mockATSelector = md.mockWhiteSpaceAmountTypeSelector;
    private static list<WhiteSpaceCollectionWrapper> rows;
    private static list<WhiteSpaceCollectionWrapper> columns;

    @testSetup
    static void testSetup() {
        WhiteSpaceCollectionWrapper row = new WhiteSpaceCollectionWrapper(md.mockWhiteSpaceRow);
        WhiteSpaceCollectionWrapper column = new WhiteSpaceCollectionWrapper(md.mockWhiteSpaceColumn);
        rows = new List<WhiteSpaceCollectionWrapper>{ row };
        columns = new List<WhiteSpaceCollectionWrapper>{ column };
    }

    @isTest
    private static void initializerWithCellListAndAmountTypesTest() {
        Integer count = 300;
        List<White_Space_Cell__c> cellList = new List<White_Space_Cell__c>();
        Set<Id> expectedTileIds = new Set<Id>();
        for (Integer i = 0; i < count; i++) {
            White_Space_Cell__c cell = md.mockWhiteSpaceCell.clone(false, true);
            Id cellId = fflib_IDGenerator.generate(White_Space_Cell__c.SObjectType);
            expectedTileIds.add(cellId);
            cell.id = cellId;
            cellList.add(cell);
        }

        md.mocks.startStubbing();
        md.mocks.when(mockATSelector.selectAll())
            .thenReturn(new List<pqcrush__White_Space_Amount_Type__c>{ md.mockWhiteSpaceAmountType });
        md.mocks.stopStubbing();

        Map<String, List<WhiteSpaceTileWrapper>> result = new WhiteSpaceCellBuilderLegacy(
                columns,
                rows,
                cellList,
                null,
                null,
                new List<WhiteSpaceTemplateCellFieldWrapper>(),
                new List<WSRelatedObjectWrapper>(),
                new Map<String, Map<String, List<SObject>>>()
            )
            .populateDisplayTileMap();

        System.assertEquals(1, result.size());
        List<WhiteSpaceTileWrapper> tiles = result.values()[0];
        System.assertEquals(count, tiles.size());
        for (WhiteSpaceTileWrapper tile : tiles) {
            System.assert(expectedTileIds.contains(tile.id));
        }
    }
}