public with sharing class WSSummaryFormulaService {
    public static List<WS_Summary_Formula__c> getSummaryFormulas(Id whiteSpaceId) {
        return service().getSummaryFormulas(whiteSpaceId);
    }

    /******************************
     *      PRIVATE METHODS
     ******************************/

    private static WSSummaryFormulaServiceImpl service() {
        return (WSSummaryFormulaServiceImpl) Application.Service.newInstance(WSSummaryFormulaServiceImpl.class);
    }
}