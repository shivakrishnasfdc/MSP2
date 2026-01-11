public with sharing class SupportSelector extends fflib_SObjectSelector {
    public static SupportSelector newInstance() {
        return (SupportSelector) Application.Selector.newInstance(pq_Support__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            pq_Support__c.Id,
            pq_Support__c.Name,
            pq_Support__c.Label__c,
            pq_Support__c.Color__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return pq_Support__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<pq_Support__c> selectAll() {
        return (List<pq_Support__c>) Database.query(newQueryFactory().toSOQL());
    }

    public List<pq_Support__c> selectByName(Set<String> names) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Name IN :names');
        return (List<pq_Support__c>) Database.query(query.toSOQL());
    }
}