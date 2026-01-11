@isTest
private class WSSummaryFormulaServiceTest {
    @isTest
    static void getSummaryFormulasTest() {
        // mocks
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork uow = md.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test
        WSSummaryFormulaSelector wsFormulaSelector = md.mockWSSummaryFormulaSelector;

        md.mocks.startStubbing();
        md.mocks.when(wsFormulaSelector.selectByWhiteSpaceId(md.mockWhiteSpaceId))
            .thenReturn(new List<WS_Summary_Formula__c>());
        md.mocks.stopStubbing();

        WSSummaryFormulaService.getSummaryFormulas(md.mockWhiteSpaceId);

        // Then
        ((WSSummaryFormulaSelector) md.mocks.verify(wsFormulaSelector, 1)).selectByWhiteSpaceId(md.mockWhiteSpaceId);
        System.assert(true, 'Assertion from mock verify');
    }
}