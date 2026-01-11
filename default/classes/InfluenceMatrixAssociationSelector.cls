public with sharing class InfluenceMatrixAssociationSelector extends fflib_SObjectSelector {
    public static InfluenceMatrixAssociationSelector newInstance() {
        return (InfluenceMatrixAssociationSelector) Application.Selector.newInstance(
            pq_Influence_Matrix_Association__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            pq_Influence_Matrix_Association__c.Id,
            pq_Influence_Matrix_Association__c.Influence_And_Support_Matrix__c,
            pq_Influence_Matrix_Association__c.Influence__c,
            pq_Influence_Matrix_Association__c.Order__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return pq_Influence_Matrix_Association__c.sObjectType;
    }

    public override String getOrderBy() {
        return pq_Influence_Matrix_Association__c.Order__c.getDescribe().getName() + ' ASC';
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<pq_Influence_Matrix_Association__c> selectByMatrixId(Set<Id> ids) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Influence_And_Support_Matrix__c IN :ids');

        fflib_SObjectSelector inflSelector = new InfluenceSelector();
        inflSelector.configureQueryFactoryFields(query, 'Influence__r');

        return (List<pq_Influence_Matrix_Association__c>) Database.query(query.toSOQL());
    }
}