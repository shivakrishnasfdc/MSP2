public with sharing class MasterAccountPlanSelector extends fflib_SObjectSelector {
    public static MasterAccountPlanSelector newInstance() {
        return (MasterAccountPlanSelector) Application.Selector.newInstance(pq_Master_Account_Plan__c.SObjectType);
    }

    /******************************
     *      QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            pq_Master_Account_Plan__c.Id,
            pq_Master_Account_Plan__c.Account__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return pq_Master_Account_Plan__c.sObjectType;
    }

    /******************************
     *      SELECT METHODS
     ******************************/


    public List<pq_Master_Account_Plan__c> selectById(Set<Id> idSet) {
        return (List<pq_Master_Account_Plan__c>) selectSObjectsById(idSet);
    }
}