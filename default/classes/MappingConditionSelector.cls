public with sharing class MappingConditionSelector extends fflib_SObjectSelector {
    public static MappingConditionSelector newInstance() {
        return (MappingConditionSelector) Application.Selector.newInstance(Mapping_Condition__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Mapping_Condition__c.Id,
            Mapping_Condition__c.Field__c,
            Mapping_Condition__c.Operator__c,
            Mapping_Condition__c.Value__c,
            Mapping_Condition__c.Condition_Group__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Mapping_Condition__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Mapping_Condition__c> selectById(Set<ID> idSet) {
        return (List<Mapping_Condition__c>) selectSObjectsById(idSet);
    }

    public List<Mapping_Condition__c> selectByConditionGroupId(Set<ID> idSet) {
        fflib_QueryFactory queryFactory = newQueryFactory();
        return Database.query(queryFactory.setCondition('Condition_Group__c IN :idSet').toSOQL());
    }
}