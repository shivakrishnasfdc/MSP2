public with sharing class WSDataTypeAssociationSelector extends fflib_SObjectSelector {
    public static WSDataTypeAssociationSelector newInstance() {
        return (WSDataTypeAssociationSelector) Application.Selector.newInstance(
            WS_Data_Type_Association__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            WS_Data_Type_Association__c.Id,
            WS_Data_Type_Association__c.White_Space_Cell__c,
            WS_Data_Type_Association__c.WS_Data_Type__c,
            WS_Data_Type_Association__c.WS_Data_Value__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return WS_Data_Type_Association__c.sObjectType;
    }

    public override String getOrderBy() {
        return WS_Data_Type_Association__c.WS_Data_Type__c.getDescribe().getName();
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<WS_Data_Type_Association__c> selectById(Set<ID> idSet) {
        return (List<WS_Data_Type_Association__c>) selectSObjectsById(idSet);
    }

    public List<WS_Data_Type_Association__c> selectByCellAndDataType(Id cellId, Id dataTypeId) {
        fflib_QueryFactory query = newQueryFactory();
        return Database.query(
            query.setCondition('White_Space_Cell__c = :cellId AND WS_Data_Type__c = :dataTypeId').toSOQL()
        );
    }

    public List<WS_Data_Type_Association__c> selectByCellId(Id cellId) {
        fflib_QueryFactory query = newQueryFactory();
        return Database.query(query.setCondition('White_Space_Cell__c = :cellId').toSOQL());
    }
}