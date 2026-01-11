public with sharing class OpportunityManagerSettingSelector extends fflib_SObjectSelector {
    public static OpportunityManagerSettingSelector newInstance() {
        return (OpportunityManagerSettingSelector) Application.Selector.newInstance(
            pq_Opportunity_Manager_Setting__c.SObjectType
        );
    }

    /******************************
     *      QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            pq_Opportunity_Manager_Setting__c.Id,
            pq_Opportunity_Manager_Setting__c.Days_of_Data_Used_In_Analysis__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return pq_Opportunity_Manager_Setting__c.sObjectType;
    }

    public override String getOrderBy() {
        return pq_Opportunity_Manager_Setting__c.LastModifiedDate.getDescribe().getName() + ' DESC';
    }

    /******************************
     *      SELECT METHODS
     ******************************/

    public pq_Opportunity_Manager_Setting__c selectOne() {
        List<pq_Opportunity_Manager_Setting__c> result = Database.query(newQueryFactory().setLimit(1).toSOQL());
        if (result != null && result.size() > 0) {
            return result[0];
        }
        return null;
    }

    public List<pqcrush__pq_Opportunity_Manager_Setting__c> getOppSetting(){
        system.debug('inside selector>>>');
        String oppSettingName = System.label.Opportunity_Manager_Setting;
        return [Select Id,pqcrush__Days_of_Data_Used_In_Analysis__c, pqcrush__Create_Opportunity_Plan__c,pqcrush__Opportunity_Setting_Name__c from pqcrush__pq_Opportunity_Manager_Setting__c WHERE pqcrush__Opportunity_Setting_Name__c =:oppSettingName LIMIT 1];
    }
}