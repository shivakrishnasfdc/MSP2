public with sharing class SupportMatrixAssociationSelector extends fflib_SObjectSelector {
    public static SupportMatrixAssociationSelector newInstance() {
        return (SupportMatrixAssociationSelector) Application.Selector.newInstance(
            pq_Support_Matrix_Association__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            pq_Support_Matrix_Association__c.Id,
            pq_Support_Matrix_Association__c.Influence_And_Support_Matrix__c,
            pq_Support_Matrix_Association__c.Support__c,
            pq_Support_Matrix_Association__c.Order__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return pq_Support_Matrix_Association__c.sObjectType;
    }

    public override String getOrderBy() {
        return pq_Support_Matrix_Association__c.Order__c.getDescribe().getName() + ' ASC';
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<pq_Support_Matrix_Association__c> selectByMatrixId(Set<Id> ids) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Influence_And_Support_Matrix__c IN :ids');

        fflib_SObjectSelector supportsSelector = new SupportSelector();
        supportsSelector.configureQueryFactoryFields(query, 'Support__r');

        return (List<pq_Support_Matrix_Association__c>) Database.query(query.toSOQL());
    }
}