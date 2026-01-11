public with sharing class WhiteSpaceHighlightServiceImpl {
    public List<WS_Highlight__c> getHighlightsForWhiteSpace(Id whiteSpaceId) {
        List<WS_Highlight__c> wsHighlights = WSHighlightSelector.newInstance().selectApplyAllWS();

        List<White_Space_Highlight_Association__c> associations = WSHighlightAssociationSelector.newInstance()
            .selectByWhiteSpaceId(new Set<Id>{ whiteSpaceId });
        for (White_Space_Highlight_Association__c assoc : associations) {
            WS_Highlight__c newHighlight = new WS_Highlight__c(
                Id = assoc.Cross_Sell_Highlight__c,
                Color__c = assoc.Cross_Sell_Highlight__r.Color__c,
                Label__c = assoc.Cross_Sell_Highlight__r.Label__c,
                Apply_To_All_Cross_Sell_Maps__c = assoc.Cross_Sell_Highlight__r.Apply_To_All_Cross_Sell_Maps__c
            );
            wsHighlights.add(newHighlight);
        }

        return wsHighlights;
    }
}