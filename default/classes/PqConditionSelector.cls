public with sharing class PqConditionSelector extends fflib_SObjectSelector {
    public static PqConditionSelector newInstance() {
        return (PqConditionSelector) Application.Selector.newInstance(pq_Condition__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            pq_Condition__c.Id,
            pq_Condition__c.Field__c,
            pq_Condition__c.Operator__c,
            pq_Condition__c.Value__c,
            pq_Condition__c.Parent_Object_Name__c,
            pq_Condition__c.Parent_Object_Id__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return pq_Condition__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<pq_Condition__c> selectById(Set<ID> idSet) {
        return (List<pq_Condition__c>) selectSObjectsById(idSet);
    }

    public List<pq_Condition__c> selectByParentObjectId(Set<ID> idSet) {
        fflib_QueryFactory queryFactory = newQueryFactory();
        return Database.query(queryFactory.setCondition('Parent_Object_Id__c IN :idSet').toSOQL());
    }
}