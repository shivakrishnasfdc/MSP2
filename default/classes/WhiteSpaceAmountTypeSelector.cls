public with sharing class WhiteSpaceAmountTypeSelector extends fflib_SObjectSelector {
    public static WhiteSpaceAmountTypeSelector newInstance() {
        return (WhiteSpaceAmountTypeSelector) Application.Selector.newInstance(White_Space_Amount_Type__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            White_Space_Amount_Type__c.Id,
            White_Space_Amount_Type__c.Name,
            White_Space_Amount_Type__c.Abbreviation__c,
            White_Space_Amount_Type__c.Color_RGB__c,
            White_Space_Amount_Type__c.Order__c,
            White_Space_Amount_Type__c.Display_Type__c,
            White_Space_Amount_Type__c.IsActive__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return White_Space_Amount_Type__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<White_Space_Amount_Type__c> selectAll() {
        return Database.query(newQueryFactory().setCondition('IsActive__c = true').toSOQL());
    }

    public List<White_Space_Amount_Type__c> selectInactive() {
        return Database.query(newQueryFactory().setCondition('IsActive__c = false').toSOQL());
    }

    public List<White_Space_Amount_Type__c> selectById(Set<ID> idSet) {
        return Database.query(newQueryFactory().setCondition('id in :idSet and IsActive__c = true').toSOQL());
    }
}