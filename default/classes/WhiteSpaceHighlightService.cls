public with sharing class WhiteSpaceHighlightService {
    private static WhiteSpaceHighlightServiceImpl instance = null;

    public static List<WS_Highlight__c> getHighlightsForWhiteSpace(Id whiteSpaceId) {
        return service().getHighlightsForWhiteSpace(whiteSpaceId);
    }

    private static WhiteSpaceHighlightServiceImpl service() {
        if (instance == null) {
            instance = (WhiteSpaceHighlightServiceImpl) Application.Service.newInstance(
                WhiteSpaceHighlightServiceImpl.class
            );
        }
        return instance;
    }
}