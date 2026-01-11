public with sharing class OrgChartFieldSelector extends fflib_SObjectSelector {
    public static OrgChartFieldSelector newInstance() {
        return (OrgChartFieldSelector) Application.Selector.newInstance(Org_Chart_Field__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Org_Chart_Field__c.Id,
            Org_Chart_Field__c.Name,
            Org_Chart_Field__c.ObjectName__c,
            Org_Chart_Field__c.FieldName__c,
            Org_Chart_Field__c.FieldLabel__c,
            Org_Chart_Field__c.isRequired__c,
            Org_Chart_Field__c.isVisible__c,
            Org_Chart_Field__c.Order__c,
            Org_Chart_Field__c.Map_Type__c,
            Org_Chart_Field__c.IsMain__c,
            Org_Chart_Field__c.Related_FieldName__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Org_Chart_Field__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Org_Chart_Field__c> selectById(Set<Id> ids) {
        return (List<Org_Chart_Field__c>) selectSObjectsById(ids);
    }

    public List<Org_Chart_Field__c> selectByObjectNameAndMapType(String objectName, String mapType) {
        return Database.query(
            newQueryFactory().setCondition('ObjectName__c = :objectName AND Map_Type__c = :mapType').toSOQL()
        );
    }

    public List<Org_Chart_Field__c> selectByMapType(String mapType) {
        String objname ='Account';
        return Database.query(newQueryFactory().setCondition('Map_Type__c = :mapType AND ObjectName__c!=:objname').toSOQL());
    }

    public List<Org_Chart_Field__c> selectAll() {
        return Database.query(newQueryFactory().toSOQL());
    }

    public List<Org_Chart_Field__c> selectVisibleByMapType(String mapType) {
        System.debug('===OrgChartFieldSelector selectVisibleByMapType===');

        System.debug('=====query building===='+newQueryFactory().setCondition('(isRequired__c = true OR isVisible__c = true) AND Map_Type__c = :mapType').toSOQL());
        return Database.query(
            newQueryFactory()
                .setCondition('(isRequired__c = true OR isVisible__c = true) AND Map_Type__c = :mapType')
                .toSOQL()
        );
    }

    public List<Org_Chart_Field__c> selectVisibleByMapTypeAndObjectName(String mapType,Set<String> objectNameSet) {
        System.debug('===OrgChartFieldSelector selectVisibleByMapType===');

        System.debug('=====query building===='+newQueryFactory().setCondition('(isRequired__c = true OR isVisible__c = true) AND Map_Type__c = :mapType').toSOQL());
        if(!objectNameSet.isEmpty()){
            return Database.query(
                newQueryFactory()
                    .setCondition('(isRequired__c = true OR isVisible__c = true) AND Map_Type__c = :mapType AND pqcrush__ObjectName__c IN :objectNameSet')
                    .toSOQL()
            );
        }
        return Database.query(
            newQueryFactory()
                .setCondition('(isRequired__c = true OR isVisible__c = true) AND Map_Type__c = :mapType')
                .toSOQL()
        );
    }

    public List<Org_Chart_Field__c> selectAllVisible() {
        return Database.query(newQueryFactory().setCondition('isRequired__c = true OR isVisible__c = true').toSOQL());
    }
}