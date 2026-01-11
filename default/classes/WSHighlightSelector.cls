public with sharing class WSHighlightSelector extends fflib_SObjectSelector {
    public static WSHighlightSelector newInstance() {
        return (WSHighlightSelector) Application.Selector.newInstance(WS_Highlight__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            WS_Highlight__c.Id,
            WS_Highlight__c.Color__c,
            WS_Highlight__c.Label__c,
            WS_Highlight__c.Apply_To_All_Cross_Sell_Maps__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return WS_Highlight__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<WS_Highlight__c> selectById(Set<ID> idSet) {
        return (List<WS_Highlight__c>) selectSObjectsById(idSet);
    }

    public List<WS_Highlight__c> selectAll() {
        return Database.query(newQueryFactory().toSOQL());
    }

    public List<WS_Highlight__c> selectApplyAllWS() {
        return Database.query(newQueryFactory().setCondition('Apply_To_All_Cross_Sell_Maps__c = true').toSOQL());
    }
}