public with sharing class AccountPlanUserSettingSelector extends fflib_SObjectSelector {
    public static AccountPlanUserSettingSelector newInstance() {
        return (AccountPlanUserSettingSelector) Application.Selector.newInstance(
            pq_CRUSH_Account_Plan_User_Setting__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            pq_CRUSH_Account_Plan_User_Setting__c.Id,
            pq_CRUSH_Account_Plan_User_Setting__c.Objective_Overview_Chart_Type__c,
            pq_CRUSH_Account_Plan_User_Setting__c.Account_Plan__c,
            pq_CRUSH_Account_Plan_User_Setting__c.User__c,
            pq_CRUSH_Account_Plan_User_Setting__c.Account_Plan_RM_Sort__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return pq_CRUSH_Account_Plan_User_Setting__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<pq_CRUSH_Account_Plan_User_Setting__c> selectById(Set<Id> ids) {
        return (List<pq_CRUSH_Account_Plan_User_Setting__c>) selectSObjectsById(ids);
    }

    public List<pq_CRUSH_Account_Plan_User_Setting__c> selectByAccountPlans(Set<Id> accountPlanIds, Id userId) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Account_Plan__c IN :accountPlanIds AND User__c = :userId');
        return Database.query(query.toSOQL());
    }

    public List<pq_CRUSH_Account_Plan_User_Setting__c> selectByAccPlanID(Set<Id> accountPlanId) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Account_Plan__c IN :accountPlanId');
        return Database.query(query.toSOQL());
    }
}