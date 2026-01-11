public with sharing class MapMemberPlaceholderSelector extends fflib_SObjectSelector {
    public static MapMemberPlaceholderSelector newInstance() {
        return (MapMemberPlaceholderSelector) Application.Selector.newInstance(Map_Member_Placeholder__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Map_Member_Placeholder__c.Id,
            Map_Member_Placeholder__c.Label__c,
            Map_Member_Placeholder__c.Description__c,
            Map_Member_Placeholder__c.TempId__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Map_Member_Placeholder__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Map_Member_Placeholder__c> selectById(Set<Id> ids) {
        return (List<Map_Member_Placeholder__c>) selectSObjectsById(ids);
    }

    public List<Map_Member_Placeholder__c> selectByIdOrTempKey(Set<String> keys) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Id IN :keys OR TempId__c IN :keys');
        return Database.query(query.toSOQL());
    }

    public List<Map_Member_Placeholder__c> selectByObjectId(Set<Id> objectIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Relationship_Map__c IN :objectIds OR Account_Plan__c IN :objectIds');
        return Database.query(query.toSOQL());
    }
}