public with sharing class TemplateSectionSelector extends fflib_SObjectSelector {
    /******************************
     *      STATIC METHODS
     ******************************/

    public static TemplateSectionSelector newInstance() {
        return (TemplateSectionSelector) Application.Selector.newInstance(pqcrush__Template_Section__c.SObjectType);
    }
    /******************************
     *    QUERY CONFIGURATION
     ******************************/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            pqcrush__Template_Section__c.pqcrush__Component_Index__c,
            pqcrush__Template_Section__c.pqcrush__Component_Name__c,
            pqcrush__Template_Section__c.pqcrush__Template__c,
            pqcrush__Template_Section__c.pqcrush__Is_Related_Object__c,
            pqcrush__Template_Section__c.pqcrush__Component_Label__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return pqcrush__Template_Section__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<pqcrush__Template_Section__c> getTemplateID(Id planId) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('pqcrush__Template__c = :planId');
        return (List<pqcrush__Template_Section__c>) Database.query(query.toSOQL());
    }
}