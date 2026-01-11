public with sharing class MappingSelector extends fflib_SObjectSelector {
    public static MappingSelector newInstance() {
        return (MappingSelector) Application.Selector.newInstance(Mapping__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Mapping__c.Name,
            Mapping__c.Id,
            Mapping__c.DisplayLabelField__c,
            Mapping__c.ObjectType__c,
            Mapping__c.ValueField__c,
            Mapping__c.ParentField__c,
            Mapping__c.GroupResults__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Mapping__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Mapping__c> selectById(Set<ID> idSet) {
        return (List<Mapping__c>) selectSObjectsById(idSet);
    }

    public List<Mapping__c> selectByIdWithConditionGroups(Set<ID> idSet) {
        fflib_QueryFactory queryFactory = newMappingQueryFactory();
        return Database.query(queryFactory.setCondition('Id IN :idSet').toSOQL());
    }

    private fflib_QueryFactory newMappingQueryFactory() {
        fflib_QueryFactory queryFactory = newQueryFactory();
        new MappingConditionGroupSelector().addQueryFactorySubselect(queryFactory);
        return queryFactory;
    }
}