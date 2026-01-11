public with sharing class MasterAccountPlanAssociationSelector extends fflib_SObjectSelector {
    public static MasterAccountPlanAssociationSelector newInstance() {
        return (MasterAccountPlanAssociationSelector) Application.Selector.newInstance(Master_Account_Plan_Associations__c.SObjectType);
    }

    /******************************
     *      QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Master_Account_Plan_Associations__c.Id,
            Master_Account_Plan_Associations__c.Account_Plan__c,
            Master_Account_Plan_Associations__c.Master_Account_Plan__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Master_Account_Plan_Associations__c.sObjectType;
    }

    /******************************
     *      SELECT METHODS
     ******************************/

    public List<Master_Account_Plan_Associations__c> selectByMasterAccountPlanId(Set<Id> ids) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Master_Account_Plan__c in :ids');
        return Database.query(query.toSOQL());
    }
}