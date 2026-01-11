public with sharing class MappingConditionGroupSelector extends fflib_SObjectSelector {
    public static MappingConditionGroupSelector newInstance() {
        return (MappingConditionGroupSelector) Application.Selector.newInstance(Mapping_Condition_Group__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Mapping_Condition_Group__c.Id,
            Mapping_Condition_Group__c.Operator__c,
            Mapping_Condition_Group__c.Mapping__c,
            Mapping_Condition_Group__c.Parent_Condition_Group__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Mapping_Condition_Group__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Mapping_Condition_Group__c> selectById(Set<ID> idSet) {
        return (List<Mapping_Condition_Group__c>) selectSObjectsById(idSet);
    }

    public List<Mapping_Condition_Group__c> selectByMappingId(Set<ID> idSet) {
        fflib_QueryFactory queryFactory = newQueryFactory();
        return Database.query(queryFactory.setCondition('Mapping__c IN :idSet').toSOQL());
    }
}