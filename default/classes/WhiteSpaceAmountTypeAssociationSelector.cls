public with sharing class WhiteSpaceAmountTypeAssociationSelector extends fflib_SObjectSelector {
    public static WhiteSpaceAmountTypeAssociationSelector newInstance() {
        return (WhiteSpaceAmountTypeAssociationSelector) Application.Selector.newInstance(
            White_Space_Amount_Type_Association__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            White_Space_Amount_Type_Association__c.Id,
            White_Space_Amount_Type_Association__c.Amount__c,
            White_Space_Amount_Type_Association__c.White_Space_Amount_Type__c,
            White_Space_Amount_Type_Association__c.White_Space_Cell__c,
            White_Space_Amount_Type_Association__c.White_Space_Amount_Type__r.Name
        };
    }

    public Schema.SObjectType getSObjectType() {
        return White_Space_Amount_Type_Association__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<White_Space_Amount_Type_Association__c> selectByAmountTypeAndCellId(Id amountTypeId, Id cellId) {
        return Database.query(
            newQueryFactory()
                .setCondition('White_Space_Amount_Type__c = :amountTypeId AND White_Space_Cell__c = :cellId')
                .toSOQL()
        );
    }
}