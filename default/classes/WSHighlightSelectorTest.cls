@isTest
private class WSHighlightSelectorTest {
    @isTest
    static void selectByIdTest() {
        // Given
        WS_Highlight__c highlight = new WS_Highlight__c(Color__c = '#ff00ff', Label__c = 'testa');

        insert highlight;

        WS_Highlight__c highlight2 = new WS_Highlight__c(Color__c = '#00ff00', Label__c = 'testb');

        insert highlight2;

        // When
        List<WS_Highlight__c> results = new WSHighlightSelector().selectById(new Set<Id>{ highlight.Id });

        System.assertEquals(1, results.size());
    }

    @isTest
    static void selectAllTest() {
        // Given
        WS_Highlight__c highlight = new WS_Highlight__c(Color__c = '#ff00ff', Label__c = 'testa');

        insert highlight;

        WS_Highlight__c highlight2 = new WS_Highlight__c(Color__c = '#00ff00', Label__c = 'testb');

        insert highlight2;

        // When
        List<WS_Highlight__c> results = new WSHighlightSelector().selectAll();

        System.assertEquals(2, results.size());
    }

    @isTest
    static void selectApplyAllWSTest() {
        // Given
        WS_Highlight__c highlight = new WS_Highlight__c(
            Color__c = '#ff00ff',
            Label__c = 'testa',
            Apply_To_All_Cross_Sell_Maps__c = false
        );

        insert highlight;

        WS_Highlight__c highlight2 = new WS_Highlight__c(
            Color__c = '#00ff00',
            Label__c = 'testb',
            Apply_To_All_Cross_Sell_Maps__c = true
        );

        insert highlight2;

        // When
        List<WS_Highlight__c> results = new WSHighlightSelector().selectApplyAllWS();

        System.assertEquals(1, results.size());
        System.assertEquals(highlight2.Id, results[0].Id);
    }
}