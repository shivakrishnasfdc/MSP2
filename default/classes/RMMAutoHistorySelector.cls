public with sharing class RMMAutoHistorySelector extends fflib_SObjectSelector {
    public static RMMAutoHistorySelector newInstance() {
        return (RMMAutoHistorySelector) Application.Selector.newInstance(
            Relationship_Map_Member_Auto_History__c.SObjectType
        );
    }

    /******************************
     *      QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Relationship_Map_Member_Auto_History__c.Id,
            Relationship_Map_Member_Auto_History__c.ContactId__c,
            Relationship_Map_Member_Auto_History__c.RelationshipMapId__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Relationship_Map_Member_Auto_History__c.sObjectType;
    }

    /******************************
     *      SELECT METHODS
     ******************************/

    public List<Relationship_Map_Member_Auto_History__c> selectByMapIds(Set<Id> mapIdSet) {
        if (mapIdSet == null || mapIdSet.isEmpty()) {
            return new List<Relationship_Map_Member_Auto_History__c>();
        }
        return Database.query(newQueryFactory().setCondition('RelationshipMapId__c IN :mapIdSet').toSOQL());
    }
}