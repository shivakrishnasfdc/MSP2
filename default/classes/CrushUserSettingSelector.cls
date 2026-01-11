public with sharing class CrushUserSettingSelector extends fflib_SObjectSelector {
    public static CrushUserSettingSelector newInstance() {
        return (CrushUserSettingSelector) Application.Selector.newInstance(pq_Crush_User_Setting__c.sObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            pq_Crush_User_Setting__c.Id,
            pq_Crush_User_Setting__c.Name,
            pq_Crush_User_Setting__c.Account_Plan_Task_Filter__c,
            pq_Crush_User_Setting__c.pqcrush__Account_Plan_Sort__c,
            pq_Crush_User_Setting__c.pqcrush__Objective_Task_Sort_Ascending__c,
            pq_Crush_User_Setting__c.pqcrush__Objective_Task_Sort_Field__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return pq_Crush_User_Setting__c.sObjectType;
    }

    public override String getOrderBy() {
        return pq_Crush_User_Setting__c.LastModifiedDate.getDescribe().getName() + ' DESC';
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<pq_Crush_User_Setting__c> selectForCurrentUser() {
        Id userId = UserInfo.getUserId(); //NOPMD
        return Database.query(newQueryFactory().setCondition('User__c = :userId').toSOQL());
    }
}