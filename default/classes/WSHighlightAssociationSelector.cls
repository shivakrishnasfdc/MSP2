public with sharing class WSHighlightAssociationSelector extends fflib_SObjectSelector {
    public static WSHighlightAssociationSelector newInstance() {
        return (WSHighlightAssociationSelector) Application.Selector.newInstance(
            White_Space_Highlight_Association__c.SObjectType
        );
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            White_Space_Highlight_Association__c.Id,
            White_Space_Highlight_Association__c.Cross_Sell_Highlight__c,
            White_Space_Highlight_Association__c.White_Space__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return White_Space_Highlight_Association__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<White_Space_Highlight_Association__c> selectByWhiteSpaceId(Set<Id> whiteSpaceIds) {
        fflib_QueryFactory query = newQueryFactory().setCondition('White_Space__c IN :whiteSpaceIds');

        fflib_SObjectSelector highlightSelector = new WSHighlightSelector();
        highlightSelector.configureQueryFactoryFields(query, 'Cross_Sell_Highlight__r');

        return (List<White_Space_Highlight_Association__c>) Database.query(query.toSOQL());
    }
}