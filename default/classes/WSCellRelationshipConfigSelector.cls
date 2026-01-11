public with sharing class WSCellRelationshipConfigSelector extends fflib_SObjectSelector {
    public static WSCellRelationshipConfigSelector newInstance() {
        return (WSCellRelationshipConfigSelector) Application.Selector.newInstance(
            Cell_Relationship_Configuration__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Cell_Relationship_Configuration__c.Id,
            Cell_Relationship_Configuration__c.Object_API_Name__c,
            Cell_Relationship_Configuration__c.Color__c,
            Cell_Relationship_Configuration__c.Display_Field__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Cell_Relationship_Configuration__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Cell_Relationship_Configuration__c> selectAll() {
        return Database.query(newQueryFactory().toSOQL());
    }

    public List<Cell_Relationship_Configuration__c> selectByObjectName(Set<String> objectNames) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Object_API_Name__c IN :objectNames');
        return Database.query(query.toSOQL());
    }
}