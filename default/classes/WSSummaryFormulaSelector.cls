public with sharing class WSSummaryFormulaSelector extends fflib_SObjectSelector {
    public static WSSummaryFormulaSelector newInstance() {
        return (WSSummaryFormulaSelector) Application.Selector.newInstance(WS_Summary_Formula__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            WS_Summary_Formula__c.Id,
            WS_Summary_Formula__c.Name,
            WS_Summary_Formula__c.Label__c,
            WS_Summary_Formula__c.Display_Type__c,
            WS_Summary_Formula__c.Formula__c,
            WS_Summary_Formula__c.Color__c,
            WS_Summary_Formula__c.White_Space__c,
            WS_Summary_Formula__c.Apply_To_All_Cross_Sell_Maps__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return WS_Summary_Formula__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<WS_Summary_Formula__c> selectById(Set<ID> idSet) {
        return (List<WS_Summary_Formula__c>) selectSObjectsById(idSet);
    }

    public List<WS_Summary_Formula__c> selectByWhiteSpaceId(Id whiteSpaceId) {
        fflib_QueryFactory query = newQueryFactory();
        return Database.query(
            query.setCondition('White_Space__c = :whiteSpaceId OR Apply_To_All_Cross_Sell_Maps__c = true').toSOQL()
        );
    }
}