public with sharing class AccountPlanMatrixAssociationSelector extends fflib_SObjectSelector {
    public static AccountPlanMatrixAssociationSelector newInstance() {
        return (AccountPlanMatrixAssociationSelector) Application.Selector.newInstance(
            pq_Account_Plan_Matrix_Association__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            pq_Account_Plan_Matrix_Association__c.Id,
            pq_Account_Plan_Matrix_Association__c.Influence_And_Support_Matrix__c,
            pq_Account_Plan_Matrix_Association__c.Account_Plan__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return pq_Account_Plan_Matrix_Association__c.sObjectType;
    }

    public override String getOrderBy() {
        return pq_Account_Plan_Matrix_Association__c.LastModifiedDate.getDescribe().getName() + ' DESC';
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<pq_Account_Plan_Matrix_Association__c> selectByAccountPlans(Set<Id> accountPlanIds) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Account_Plan__c IN :accountPlanIds');

        fflib_SObjectSelector matrixSelector = new InfluenceSupportMatrixSelector();
        matrixSelector.configureQueryFactoryFields(query, 'Influence_And_Support_Matrix__r');
        
        return Database.query(query.toSOQL());
    }
}