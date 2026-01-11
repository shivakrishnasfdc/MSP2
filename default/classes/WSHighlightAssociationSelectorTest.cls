@isTest
private class WSHighlightAssociationSelectorTest {
    @isTest
    static void newInstanceTest() {
        WSHighlightAssociationSelector selector = WSHighlightAssociationSelector.newInstance();

        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByWhiteSpaceIdTest() {
        // Given
        White_Space__c ws1 = TestDataFactory.createWhiteSpace('My WS');
        White_Space__c ws2 = TestDataFactory.createWhiteSpace('My WS');

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
            White_Space__c = ws2.Id,
            Cross_Sell_Highlight__c = highlight2.Id
        );
        insert asoc2;

        // When
        List<White_Space_Highlight_Association__c> result = WSHighlightAssociationSelector.newInstance()
            .selectByWhiteSpaceId(new Set<Id>{ ws1.Id });

        // Then
        System.assertEquals(1, result.size());
        System.assertEquals(highlight1.Id, result[0].Cross_Sell_Highlight__c);
    }
}