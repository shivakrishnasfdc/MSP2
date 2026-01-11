public with sharing class InfluenceSupportMatrixSelector extends fflib_SObjectSelector {
    public static InfluenceSupportMatrixSelector newInstance() {
        return (InfluenceSupportMatrixSelector) Application.Selector.newInstance(
            pq_Influence_And_Support_Matrix__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            pq_Influence_And_Support_Matrix__c.Id,
            pq_Influence_And_Support_Matrix__c.Name,
            pq_Influence_And_Support_Matrix__c.Is_Default__c,
            pq_Influence_And_Support_Matrix__c.Influence_Label__c,
            pq_Influence_And_Support_Matrix__c.Support_Label__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return pq_Influence_And_Support_Matrix__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<pq_Influence_And_Support_Matrix__c> selectById(Set<Id> ids) {
        return (List<pq_Influence_And_Support_Matrix__c>) selectSObjectsById(ids);
    }

    public pq_Influence_And_Support_Matrix__c selectDefault() {
        fflib_QueryFactory query = newQueryFactory().setCondition('Is_Default__c = true').setLimit(1);
        List<pq_Influence_And_Support_Matrix__c> result = Database.query(query.toSOQL());

        if (result.size() == 1) {
            return result[0];
        }

        return null;
    }
}