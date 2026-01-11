public with sharing class WhiteSpaceTemplateSelector extends fflib_SObjectSelector {
    public static WhiteSpaceTemplateSelector newInstance() {
        return (WhiteSpaceTemplateSelector) Application.Selector.newInstance(White_Space_Template__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            White_Space_Template__c.Id,
            White_Space_Template__c.Name,
            White_Space_Template__c.isLegacy__c,
            White_Space_Template__c.hasDependentPicklistColumns__c,
            White_Space_Template__c.hasDependentPicklistRows__c,
            White_Space_Template__c.Column_Object_Name__c,
            White_Space_Template__c.Column_Label_Field_Name__c,
            White_Space_Template__c.ColumnMapping__c,
            White_Space_Template__c.Row_Object_Name__c,
            White_Space_Template__c.Row_Label_Field_Name__c,
            White_Space_Template__c.RowMapping__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return White_Space_Template__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<White_Space_Template__c> selectById(Set<ID> idSet) {
        return new SystemSelector().selectById(this, idSet);
    }

    public List<White_Space_Template__c> selectAll() {
        return new SystemSelector().selectAll(this);
    }

    public List<White_Space_Template__c> selectAllWithRowColumnMappings() {
        fflib_QueryFactory templateQueryFactory = newQueryFactory();

        new MappingSelector()
            .configureQueryFactoryFields(
                templateQueryFactory,
                White_Space_Template__c.ColumnMapping__c.getDescribe().getRelationshipName()
            );
        new MappingSelector()
            .configureQueryFactoryFields(
                templateQueryFactory,
                White_Space_Template__c.RowMapping__c.getDescribe().getRelationshipName()
            );

        return Database.query(templateQueryFactory.toSOQL());
    }

    /******************************
     *       INNER CLASSES
     ******************************/
    private with sharing class SystemSelector {
        public List<White_Space_Template__c> selectById(WhiteSpaceTemplateSelector selector, Set<Id> ids) {
            return Database.query(selector.newQueryFactory(false, false, true).setCondition('id in :ids').toSOQL());
        }

        public List<White_Space_Template__c> selectAll(WhiteSpaceTemplateSelector selector) {
            return Database.query(selector.newQueryFactory(false, false, true).toSOQL());
        }
    }
}