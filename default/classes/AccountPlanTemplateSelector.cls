public with sharing class AccountPlanTemplateSelector extends fflib_SObjectSelector {
    /******************************
     *      STATIC METHODS
     ******************************/

    public static AccountPlanTemplateSelector newInstance() {
        return (AccountPlanTemplateSelector) Application.Selector.newInstance(
            pqcrush__Account_Plan_Template__c.SObjectType
        );
    }
    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            pqcrush__Account_Plan_Template__c.pqcrush__Header_Title__c,
            pqcrush__Account_Plan_Template__c.Name,
            pqcrush__Account_Plan_Template__c.Id,
            pqcrush__Account_Plan_Template__c.pqcrush__Default__c,
            pqcrush__Account_Plan_Template__c.pqcrush__Account_Plan__c
        };
    }
    public Schema.SObjectType getSObjectType() {
        return pqcrush__Account_Plan_Template__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/
    public List<pqcrush__Account_Plan_Template__c> selectByDefault(Integer i) {
        fflib_QueryFactory query = newQueryFactory().setCondition('pqcrush__Default__c = TRUE');
        query.setLimit(i);
        return Database.query(query.toSOQL());
    }

    public List<pqcrush__Account_Plan_Template__c> selectByLimit(Integer i) {
        fflib_QueryFactory query = newQueryFactory();
        query.setLimit(i);
        return Database.query(query.toSOQL());
    }

    public List<pqcrush__Account_Plan_Template__c> selectByName(String templateName) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Name = :templateName');
        return Database.query(query.toSOQL());
    }

    public List<pqcrush__Account_Plan_Template__c> selectById(String id) {
        fflib_QueryFactory query = newQueryFactory().setCondition('id = :id');
        return Database.query(query.toSOQL());
    }

    public List<pqcrush__Account_Plan_Template__c> selectBySearch(String accTempName) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Name like \'%' + accTempName + '%\'');
        return Database.query(query.toSOQL());
    }

    public List<pqcrush__Account_Plan_Template__c> getTitleOfTemplate(string planId, Integer limitValue) {
        fflib_QueryFactory query = newQueryFactory().setCondition('ID = :planId');
        query.setLimit(limitValue);
        return Database.query(query.toSOQL());
    }
    public List<pqcrush__Account_Plan_Template__c> defaultCheck() {
        fflib_QueryFactory query = newQueryFactory().setCondition('pqcrush__Default__c = true');
        return Database.query(query.toSOQL());
    }
}