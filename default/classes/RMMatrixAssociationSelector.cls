public with sharing class RMMatrixAssociationSelector extends fflib_SObjectSelector {
    public static RMMatrixAssociationSelector newInstance() {
        return (RMMatrixAssociationSelector) Application.Selector.newInstance(
            pq_Relationship_Map_Matrix_Association__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            pq_Relationship_Map_Matrix_Association__c.Id,
            pq_Relationship_Map_Matrix_Association__c.Influence_And_Support_Matrix__c,
            pq_Relationship_Map_Matrix_Association__c.Relationship_Map__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return pq_Relationship_Map_Matrix_Association__c.sObjectType;
    }

    public override String getOrderBy() {
        return pq_Relationship_Map_Matrix_Association__c.LastModifiedDate.getDescribe().getName() + ' DESC';
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<pq_Relationship_Map_Matrix_Association__c> selectByRelationshipMaps(Set<Id> mapIds) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Relationship_Map__c IN :mapIds');

        fflib_SObjectSelector matrixSelector = new InfluenceSupportMatrixSelector();
        matrixSelector.configureQueryFactoryFields(query, 'Influence_And_Support_Matrix__r');

        return Database.query(query.toSOQL());
    }
}