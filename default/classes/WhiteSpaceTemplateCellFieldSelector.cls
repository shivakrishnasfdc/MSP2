public with sharing class WhiteSpaceTemplateCellFieldSelector extends fflib_SObjectSelector {
    public static WhiteSpaceTemplateCellFieldSelector newInstance() {
        return (WhiteSpaceTemplateCellFieldSelector) Application.Selector.newInstance(
            White_Space_Template_Cell_Field__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            White_Space_Template_Cell_Field__c.Id,
            White_Space_Template_Cell_Field__c.DisplayFieldId__c,
            White_Space_Template_Cell_Field__c.ValueMapping__c,
            White_Space_Template_Cell_Field__c.WhitespaceTemplate__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return White_Space_Template_Cell_Field__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<White_Space_Template_Cell_Field__c> selectById(Set<ID> idSet) {
        if (idSet == null) {
            return new List<White_Space_Template_Cell_Field__c>();
        }
        return (List<White_Space_Template_Cell_Field__c>) selectSObjectsById(idSet);
    }

    public List<White_Space_Template_Cell_Field__c> selectByWhiteSpaceTemplateId(Set<Id> templateIds) {
        if (templateIds == null) {
            return new List<White_Space_Template_Cell_Field__c>();
        }
        return Database.query(newQueryFactory().setCondition('WhitespaceTemplate__c IN :templateIds').toSOQL());
    }

    public List<White_Space_Template_Cell_Field__c> selectByWhiteSpaceTemplateIdAndDisplayFieldIds(
        Set<Id> templateIds,
        Set<Id> displayFieldIds
    ) {
        if (templateIds == null) {
            return new List<White_Space_Template_Cell_Field__c>();
        }
        return Database.query(
            newQueryFactory()
                .setCondition('WhitespaceTemplate__c IN :templateIds AND DisplayFieldId__c IN :displayFieldIds')
                .toSOQL()
        );
    }

    public List<White_Space_Template_Cell_Field__c> selectByWhiteSpaceTemplateIdExcludingDisplayFieldIds(
        Set<Id> templateIds,
        Set<Id> displayFieldIdsToExclude
    ) {
        if (templateIds == null) {
            return new List<White_Space_Template_Cell_Field__c>();
        }
        return Database.query(
            newQueryFactory()
                .setCondition(
                    'WhitespaceTemplate__c IN :templateIds AND DisplayFieldId__c  NOT IN :displayFieldIdsToExclude'
                )
                .toSOQL()
        );
    }
}