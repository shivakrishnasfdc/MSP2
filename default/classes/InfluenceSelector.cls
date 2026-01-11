public with sharing class InfluenceSelector extends fflib_SObjectSelector {
    public static InfluenceSelector newInstance() {
        return (InfluenceSelector) Application.Selector.newInstance(pq_Influence__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ pq_Influence__c.Id, pq_Influence__c.Name, pq_Influence__c.Label__c };
    }

    public Schema.SObjectType getSObjectType() {
        return pq_Influence__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<pq_Influence__c> selectAll() {
        return (List<pq_Influence__c>) Database.query(newQueryFactory().toSOQL());
    }

    public List<pq_Influence__c> selectByName(Set<String> names) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Name IN :names');
        return (List<pq_Influence__c>) Database.query(query.toSOQL());
    }
}