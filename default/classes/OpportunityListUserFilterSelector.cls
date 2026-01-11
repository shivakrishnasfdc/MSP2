public with sharing class OpportunityListUserFilterSelector extends fflib_SObjectSelector {
    public static OpportunityListUserFilterSelector newInstance() {
        return (OpportunityListUserFilterSelector) Application.Selector.newInstance(
            Opportunity_List_User_Filter__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Opportunity_List_User_Filter__c.Id,
            Opportunity_List_User_Filter__c.User__c,
            Opportunity_List_User_Filter__c.AccountPlan__c,
            Opportunity_List_User_Filter__c.Filters__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Opportunity_List_User_Filter__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Opportunity_List_User_Filter__c> selectByAccountPlanAndUser(Id accountPlanId, Id userId) {
        fflib_QueryFactory query = newQueryFactory();
        return Database.query(query.setCondition('AccountPlan__c = :accountPlanId AND User__c = :userId').toSOQL());
    }
}