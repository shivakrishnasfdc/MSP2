public with sharing class WSDataTypeSelector extends fflib_SObjectSelector {
    public static WSDataTypeSelector newInstance() {
        return (WSDataTypeSelector) Application.Selector.newInstance(WS_Data_Type__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            WS_Data_Type__c.Id,
            WS_Data_Type__c.Label__c,
            WS_Data_Type__c.White_Space__c,
            WS_Data_Type__c.Data_Type__c,
            WS_Data_Type__c.Picklist_Values__c,
            WS_Data_Type__c.Color__c,
            WS_Data_Type__c.Apply_To_All_Cross_Sell_Maps__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return WS_Data_Type__c.sObjectType;
    }

    public override String getOrderBy() {
        return WS_Data_Type__c.Label__c.getDescribe().getName();
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<WS_Data_Type__c> selectById(Set<ID> idSet) {
        return (List<WS_Data_Type__c>) selectSObjectsById(idSet);
    }

    public List<WS_Data_Type__c> selectByWhiteSpaceId(Id whiteSpaceId) {
        fflib_QueryFactory query = newQueryFactory();
        return Database.query(
            query.setCondition('White_Space__c = :whiteSpaceId OR Apply_To_All_Cross_Sell_Maps__c = true').toSOQL()
        );
    }
}