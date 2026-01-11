@isTest
private class WhiteSpaceAbstractTest {
    private static TestMockData md = new TestMockData();

    private class WhiteSpaceTestClass extends WhiteSpaceAbstract {
        public WhiteSpaceTestClass() {
            super(md.mockWhiteSpace, WhiteSpaceTypeEnum.FREE_FORM);
        }

        protected override List<WhiteSpaceCollectionWrapper> getColumns() {
            WhiteSpaceCollectionWrapper testColumn = new WhiteSpaceCollectionWrapper(md.mockWhiteSpaceColumn);
            return new List<WhiteSpaceCollectionWrapper>{ testColumn };
        }

        protected override List<WhiteSpaceCollectionWrapper> getRows() {
            WhiteSpaceCollectionWrapper testRow = new WhiteSpaceCollectionWrapper(md.mockWhiteSpaceRow);
            return new List<WhiteSpaceCollectionWrapper>{ testRow };
        }

        protected override List<WhiteSpaceCellWrapper> getCells() {
            WhiteSpaceCellWrapper testCell = new WhiteSpaceCellWrapper(
                md.mockWhiteSpaceColumn.id,
                md.mockWhiteSpaceRow.id,
                new List<WhiteSpaceTileWrapper>()
            );
            return new List<WhiteSpaceCellWrapper>{ testCell };
        }
    }

    @isTest
    public static void buildTest() {
        WhiteSpaceAbstract result = new WhiteSpaceTestClass().build();
        system.assertEquals(1, result.columns.size());
        system.assertEquals(1, result.rows.size());
        system.assertEquals(1, result.cells.size());
        system.assertNotEquals(null, result.relatedCellFields);
        system.assertNotEquals(null, result.relatedObjects);
    }
}