public with sharing class ContactExtendedFieldSelector extends fflib_SObjectSelector {
    public static ContactExtendedFieldSelector newInstance() {
        return (ContactExtendedFieldSelector) Application.Selector.newInstance(Contact_Extended_Field__c.SObjectType);
    }

    /******************************
     *      QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Contact_Extended_Field__c.Id,
            Contact_Extended_Field__c.Contact__c,
            Contact_Extended_Field__c.Profile_Picture_Data__c,
            Contact_Extended_Field__c.Influence__c,
            Contact_Extended_Field__c.Support__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Contact_Extended_Field__c.sObjectType;
    }

    /******************************
     *      SELECT METHODS
     ******************************/

    public List<Contact_Extended_Field__c> selectByContactId(Set<Id> ids) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Contact__c IN :ids');

        fflib_SObjectSelector inflSelector = new InfluenceSelector();
        inflSelector.configureQueryFactoryFields(query, 'Influence__r');

        fflib_SObjectSelector suppSelector = new SupportSelector();
        suppSelector.configureQueryFactoryFields(query, 'Support__r');

        return Database.query(query.toSOQL());
    }
}