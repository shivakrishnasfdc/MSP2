public with sharing class TaskStatusSelector extends fflib_SObjectSelector {
    public static TaskStatusSelector newInstance() {
        return (TaskStatusSelector) Application.Selector.newInstance(TaskStatus.SObjectType);
    }

    public override String getOrderBy() {
        return TaskStatus.SortOrder.getDescribe().getName();
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            TaskStatus.ApiName,
            TaskStatus.IsClosed,
            TaskStatus.SortOrder,
            TaskStatus.MasterLabel
        };
    }

    public Schema.SObjectType getSObjectType() {
        return TaskStatus.sObjectType;
    }

    public List<TaskStatus> selectTasksStatusForClosed() {
        fflib_QueryFactory taskStatusQueryFactory = newQueryFactory();
        List<TaskStatus> result = new List<TaskStatus>();
        result = Database.query(taskStatusQueryFactory.setCondition('IsClosed = true').toSOQL());

        return result;
    }

    public List<TaskStatus> selectTasksStatusForOpen() {
        fflib_QueryFactory taskStatusQueryFactory = newQueryFactory();
        List<TaskStatus> result = new List<TaskStatus>();
        result = Database.query(taskStatusQueryFactory.setCondition('IsClosed = false').toSOQL());

        return result;
    }
}