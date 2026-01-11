public with sharing class WhiteSpaceRowSelector extends fflib_SObjectSelector {
    public static WhiteSpaceRowSelector newInstance() {
        return (WhiteSpaceRowSelector) Application.Selector.newInstance(White_Space_Row__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            White_Space_Row__c.Id,
            White_Space_Row__c.Name,
            White_Space_Row__c.Order__c,
            White_Space_Row__c.Related_Object_Id__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return White_Space_Row__c.sObjectType;
    }

    public override String getOrderBy() {
        return White_Space_Row__c.Order__c.getDescribe().getName();
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<White_Space_Row__c> selectById(Set<ID> recordIds) {
        return (List<White_Space_Row__c>) selectSObjectsById(recordIds);
    }

    public List<White_Space_Row__c> selectByWhiteSpaceId(Set<Id> whiteSpaceIds) {
        return Database.query(newQueryFactory().setCondition('White_Space__c IN :whiteSpaceIds').toSOQL());
    }
}