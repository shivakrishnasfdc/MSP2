public with sharing class RMNodeCoordinateSelector extends fflib_SObjectSelector {
    public static RMNodeCoordinateSelector newInstance() {
        return (RMNodeCoordinateSelector) Application.Selector.newInstance(RM_Node_Coordinate__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            RM_Node_Coordinate__c.Id,
            RM_Node_Coordinate__c.Key__c,
            RM_Node_Coordinate__c.TempId__c,
            RM_Node_Coordinate__c.Account_Plan__c,
            RM_Node_Coordinate__c.Relationship_Map__c,
            RM_Node_Coordinate__c.X__c,
            RM_Node_Coordinate__c.Y__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return RM_Node_Coordinate__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<RM_Node_Coordinate__c> selectById(Set<Id> ids) {
        return (List<RM_Node_Coordinate__c>) selectSObjectsById(ids);
    }

    public List<RM_Node_Coordinate__c> selectByKeys(Set<String> keys) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Key__c IN :keys');
        return Database.query(query.toSOQL());
    }

    public List<RM_Node_Coordinate__c> selectByObjectId(Id objectId) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Account_Plan__c = :objectId OR Relationship_Map__c = :objectId');
        return Database.query(query.toSOQL());
    }

    public List<RM_Node_Coordinate__c> selectByObjectIdAndKeys(Id objectId, Set<String> keys) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                '(Account_Plan__c = :objectId OR Relationship_Map__c = :objectId) AND (Key__c in :keys OR TempId__c in :keys)'
            );
        return Database.query(query.toSOQL());
    }
}