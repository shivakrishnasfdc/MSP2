public with sharing class SWOTAnalysisSelector extends AccountPlanChildSelector {
    /******************************
     *      STATIC METHODS
     ******************************/

    public static SWOTAnalysisSelector newInstance() {
        return (SWOTAnalysisSelector) Application.Selector.newInstance(SWOT_Analysis__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            SWOT_Analysis__c.Id,
            SWOT_Analysis__c.Name,
            SWOT_Analysis__c.Description_Rich_Text__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return SWOT_Analysis__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<SWOT_Analysis__c> selectById(Set<Id> ids) {
        return Database.query(
            newQueryFactory().selectField('RecordType.DeveloperName').setCondition('id in :ids').toSOQL()
        );
    }

    public List<SWOT_Analysis__c> selectByAccountPlanId(Id accountPlanId) {
        return Database.query(
            newQueryFactory()
                .selectField('RecordType.DeveloperName')
                .setCondition('Account_Plan__c = :accountPlanId')
                .toSOQL()
        );
    }
}