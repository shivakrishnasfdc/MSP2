@isTest
private class WhiteSpaceCellBuilderAbstractTest {
    private static TestMockData md = new TestMockData();
    private static WhiteSpaceCollectionWrapper testColumn = new WhiteSpaceCollectionWrapper(md.mockWhiteSpaceColumn);
    private static WhiteSpaceCollectionWrapper testRow = new WhiteSpaceCollectionWrapper(md.mockWhiteSpaceRow);
    private static List<WhiteSpaceCollectionWrapper> columns = new List<WhiteSpaceCollectionWrapper>{ testColumn };
    private static List<WhiteSpaceCollectionWrapper> rows = new List<WhiteSpaceCollectionWrapper>{ testRow };
    private static List<White_Space_Cell__c> cells = new List<White_Space_Cell__c>{ md.mockWhiteSpaceCell };

    private class WhiteSpaceCellBuilderTestClass extends WhiteSpaceCellBuilderAbstract {
        public WhiteSpaceCellBuilderTestClass() {
            super(
                columns,
                rows,
                cells,
                null,
                null,
                new List<WhiteSpaceTemplateCellFieldWrapper>(),
                new List<WSRelatedObjectWrapper>(),
                new Map<String, Map<String, List<SObject>>>()
            );
        }

        @testVisible
        protected override Map<String, List<WhiteSpaceTileWrapper>> populateDisplayTileMap() {
            Map<String, List<WhiteSpaceTileWrapper>> tileMap = new Map<String, List<WhiteSpaceTileWrapper>>();
            WhiteSpaceTileWrapper tile1 = new WhiteSpaceTileWrapper();
            WhiteSpaceTileWrapper tile2 = new WhiteSpaceTileWrapper();
            WhiteSpaceTileWrapper tile3 = new WhiteSpaceTileWrapper();
            List<WhiteSpaceTileWrapper> tiles = new List<WhiteSpaceTileWrapper>{ tile1, tile2, tile3 };
            for (String key : cellMap.keySet()) {
                tileMap.put(key, tiles);
            }
            return tileMap;
        }
    }

    @isTest
    static void mapCellsByRowAndColumnIdTest() {
        Map<String, List<White_Space_Cell__c>> result = new WhiteSpaceCellBuilderTestClass().cellMap;
        system.assertEquals(1, result.size());
        system.assertEquals(cells, result.get(testRow.id + ' - ' + testColumn.id));
    }

    @isTest
    static void buildTest() {
        List<WhiteSpaceCellWrapper> result = new WhiteSpaceCellBuilderTestClass().build();
        system.assertEquals(1, result.size());
        for (WhiteSpaceCellWrapper cell : result) {
            system.assertEquals(3, cell.tiles.size());
        }
    }
}