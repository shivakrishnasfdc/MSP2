public with sharing class RMAnchorSelector extends fflib_SObjectSelector {
    public static RMAnchorSelector newInstance() {
        return (RMAnchorSelector) Application.Selector.newInstance(RM_Anchor__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ RM_Anchor__c.Id, RM_Anchor__c.From__c, RM_Anchor__c.To__c };
    }

    public Schema.SObjectType getSObjectType() {
        return RM_Anchor__c.sObjectType;
    }

    public override String getOrderBy() {
        return RM_Anchor__c.LastModifiedDate.getDescribe().getName() + ' ASC';
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<RM_Anchor__c> selectByObjectId(Set<Id> objectId) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Account_Plan__c IN :objectId OR Relationship_Map__c IN :objectId');
        return Database.query(query.toSOQL());
    }

    public List<RM_Anchor__c> selectByObjectIdAndFromField(Id objectId, Set<String> fromField) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('(Account_Plan__c = :objectId OR Relationship_Map__c = :objectId) AND From__c IN :fromField');
        return Database.query(query.toSOQL());
    }
}