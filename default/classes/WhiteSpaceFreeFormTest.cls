@isTest
private class WhiteSpaceFreeFormTest {
    private static TestMockData md = new TestMockData();

    @isTest
    public static void canInstantiateTest() {
        White_Space__c mockWs = md.mockWhiteSpace;

        WhiteSpaceFreeForm result = new WhiteSpaceFreeForm(mockWs);

        system.assertEquals(WhiteSpaceFreeForm.type, result.type);
    }

    @isTest
    public static void canBuildTest() {
        WhiteSpaceColumnSelector mockColSelector = md.mockWhiteSpaceColumnSelector;
        WhiteSpaceRowSelector mockRowSelector = md.mockWhiteSpaceRowSelector;
        WhiteSpaceCellSelector mockCellSelector = md.mockWhiteSpaceCellSelector;

        List<pqcrush__White_Space_Column__c> columns = new List<pqcrush__White_Space_Column__c>{
            md.mockWhiteSpaceColumn
        };
        List<pqcrush__White_Space_Row__c> rows = new List<pqcrush__White_Space_Row__c>{ md.mockWhiteSpaceRow };
        White_Space__c mockWs = createMockFreeFormWs(md.mockWhiteSpace, columns, rows);

        List<White_Space_Cell__c> cells = new List<White_Space_Cell__c>{ md.mockWhiteSpaceCell };

        md.mocks.startStubbing();
        md.mocks.when(mockColSelector.selectByWhiteSpaceId(new Set<Id>{ mockWs.id })).thenReturn(columns);
        md.mocks.when(mockRowSelector.selectByWhiteSpaceId(new Set<Id>{ mockWs.id })).thenReturn(rows);
        md.mocks.when(mockCellSelector.selectByWhiteSpaceIdWithAmountTypeAssociations(mockWs.id)).thenReturn(cells);
        md.mocks.stopStubbing();

        WhiteSpaceAbstract result = new WhiteSpaceFreeForm(mockWs).build();

        system.assertEquals(1, result.columns.size());
        system.assertEquals(1, result.rows.size());
        system.assertEquals(1, result.cells.size());
    }

    private static White_Space__c createMockFreeFormWs(
        White_Space__c ws,
        List<White_Space_Column__c> columns,
        List<White_Space_Row__c> rows
    ) {
        List<White_Space__c> mockWSList = (List<White_Space__c>) fflib_ApexMocksUtils.makeRelationship(
            List<White_Space__c>.class,
            new List<White_Space__c>{ ws },
            White_Space_Column__c.White_Space__c,
            new List<List<White_Space_Column__c>>{ columns }
        );

        mockWSList = (List<White_Space__c>) fflib_ApexMocksUtils.makeRelationship(
            List<White_Space__c>.class,
            mockWSList,
            White_Space_Row__c.White_Space__c,
            new List<List<White_Space_Row__c>>{ rows }
        );

        return mockWSList[0];
    }
}