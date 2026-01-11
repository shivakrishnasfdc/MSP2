@isTest
private class WhiteSpaceCellWrapperTest {
    @isTest
    private static void basicInitializerTest() {
        WhiteSpaceCellWrapper wrapper = new WhiteSpaceCellWrapper();

        System.assertEquals(null, wrapper.columnId);
        System.assertEquals(null, wrapper.rowId);
        System.assertEquals(new List<WhiteSpaceTileWrapper>(), wrapper.tiles);
    }
}