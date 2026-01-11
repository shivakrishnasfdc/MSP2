public with sharing class WhiteSpaceColumnSelector extends fflib_SObjectSelector {
    public static WhiteSpaceColumnSelector newInstance() {
        return (WhiteSpaceColumnSelector) Application.Selector.newInstance(White_Space_Column__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            White_Space_Column__c.Id,
            White_Space_Column__c.Name,
            White_Space_Column__c.Order__c,
            White_Space_Column__c.Related_Object_Id__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return White_Space_Column__c.sObjectType;
    }

    public override String getOrderBy() {
        return White_Space_Column__c.Order__c.getDescribe().getName();
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<White_Space_Column__c> selectById(Set<ID> idSet) {
        return (List<White_Space_Column__c>) selectSObjectsById(idSet);
    }

    public List<White_Space_Column__c> selectByWhiteSpaceId(Set<Id> whiteSpaceIds) {
        return Database.query(newQueryFactory().setCondition('White_Space__c IN :whiteSpaceIds').toSOQL());
    }
}