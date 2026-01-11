public with sharing class MasterAccountPlanUserSettingSelector extends fflib_SObjectSelector {
    public static MasterAccountPlanUserSettingSelector newInstance() {
        return (MasterAccountPlanUserSettingSelector) Application.Selector.newInstance(Master_Account_Plan_User_Setting__c.sObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Master_Account_Plan_User_Setting__c.Id,
            Master_Account_Plan_User_Setting__c.Name,
            Master_Account_Plan_User_Setting__c.Master_Account_Plan__c,
            Master_Account_Plan_User_Setting__c.Show_Closed_Account_Plans__c,
            Master_Account_Plan_User_Setting__c.User__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Master_Account_Plan_User_Setting__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Master_Account_Plan_User_Setting__c> selectForCurrentUserAndMasterAccountPlan(Id masterAccountPlanId) {
        Id userId = UserInfo.getUserId(); //NOPMD
        String condition = 'User__c = :userId AND Master_Account_Plan__c = :masterAccountPlanId';
        return Database.query(newQueryFactory().setCondition(condition).toSOQL());
    }
}