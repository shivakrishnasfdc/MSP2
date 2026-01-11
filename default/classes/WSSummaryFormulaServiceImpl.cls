public with sharing class WSSummaryFormulaServiceImpl {
    public List<WS_Summary_Formula__c> getSummaryFormulas(Id whiteSpaceId) {
        List<WS_Summary_Formula__c> formulas = WSSummaryFormulaSelector.newInstance()
            .selectByWhiteSpaceId(whiteSpaceId);

        return formulas;
    }
}