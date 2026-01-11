public with sharing class ObjectiveTaskAssociationSelector extends fflib_SObjectSelector {
    public static ObjectiveTaskAssociationSelector newInstance() {
        return (ObjectiveTaskAssociationSelector) Application.Selector.newInstance(
            Objective_Task_Association__c.SObjectType
        );
    }

    /******************************
     *      QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Objective_Task_Association__c.Id,
            Objective_Task_Association__c.Objective__c,
            Objective_Task_Association__c.TaskId__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Objective_Task_Association__c.sObjectType;
    }

    public override String getOrderBy() {
        return Objective_Task_Association__c.CreatedDate.getDescribe().getName() + ' ASC';
    }

    /******************************
     *      SELECT METHODS
     ******************************/

    public List<Objective_Task_Association__c> selectByObjectives(Set<Id> ids) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Objective__c IN :ids');
        return Database.query(query.toSOQL());
    }

    public List<Objective_Task_Association__c> selectByObjectiveAndTask(Id objectiveId, Id taskId) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Objective__c = :objectiveId AND TaskId__c = :taskId');
        return Database.query(query.toSOQL());
    }
}