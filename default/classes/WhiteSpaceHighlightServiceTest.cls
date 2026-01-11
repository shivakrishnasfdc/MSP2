@IsTest
private class WhiteSpaceHighlightServiceTest {
    @IsTest
    static void getHighlightsForWhiteSpaceTest() {
        testMockData md = new testMockData();
        WSHighlightSelector mockWSHighlightSelector = md.mockWSHighlightSelector;
        WSHighlightAssociationSelector mockWSHighlightAssociationSelector = md.mockWSHighlightAssociationSelector;

        // Given
        White_Space__c ws1 = TestDataFactory.createWhiteSpace('My WS');

        WS_Highlight__c highlight1 = new WS_Highlight__c(
            Color__c = '#00ff00',
            Label__c = 'test',
            Apply_To_All_Cross_Sell_Maps__c = false
        );
        insert highlight1;

        WS_Highlight__c highlight2 = new WS_Highlight__c(
            Color__c = '#00ff00',
            Label__c = 'test',
            Apply_To_All_Cross_Sell_Maps__c = false
        );
        insert highlight2;

        White_Space_Highlight_Association__c asoc1 = new White_Space_Highlight_Association__c(
            White_Space__c = ws1.Id,
            Cross_Sell_Highlight__c = highlight1.Id
        );
        insert asoc1;

        White_Space_Highlight_Association__c asoc2 = new White_Space_Highlight_Association__c(
            White_Space__c = ws1.Id,
            Cross_Sell_Highlight__c = highlight2.Id
        );
        insert asoc2;

        md.mocks.startStubbing();
        md.mocks.when(mockWSHighlightSelector.selectApplyAllWS())
            .thenReturn(new List<WS_Highlight__c>{ md.mockWSHighlight });
        md.mocks.when(mockWSHighlightAssociationSelector.selectByWhiteSpaceId(new Set<Id>{ ws1.Id }))
            .thenReturn(new List<White_Space_Highlight_Association__c>{ asoc1, asoc2 });
        md.mocks.stopStubbing();

        List<WS_Highlight__c> result = WhiteSpaceHighlightService.getHighlightsForWhiteSpace(ws1.Id);

        System.assertEquals(3, result.size());
    }
}