@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class TaskWrapper {
    @AuraEnabled
    public Id id { get; set; }
    @AuraEnabled
    public Id ownerId { get; set; }
    @AuraEnabled
    public Id whatId { get; set; }
    @AuraEnabled
    public Id whoId { get; set; }
    @AuraEnabled
    public String whoName { get; set; }
    @AuraEnabled
    public String subject { get; set; }
    @AuraEnabled
    public String status { get; set; }
    @AuraEnabled
    public String assignedTo { get; set; }
    @AuraEnabled
    public Date dueDate { get; set; }
    @AuraEnabled
    public Boolean isClosed { get; set; }
    @AuraEnabled
    public String taskSubType { get; set; }

    public TaskWrapper(Id id, String subject, String status, String assignedTo, Date dueDate, Boolean isClosed) {
        this.id = id;
        this.subject = subject;
        this.status = status;
        this.assignedTo = assignedTo;
        this.dueDate = dueDate;
        this.isClosed = isClosed;
    }

    public TaskWrapper(
        Id id,
        String subject,
        String status,
        String assignedTo,
        Date dueDate,
        Boolean isClosed,
        string taskSubType,
        Id ownerId,
        Id whatId,
        Id whoId
    ) {
        this.id = id;
        this.subject = subject;
        this.status = status;
        this.assignedTo = assignedTo;
        this.dueDate = dueDate;
        this.isClosed = isClosed;
        this.taskSubType = taskSubType;
        this.ownerId = ownerId;
        this.whatId = whatId;
        this.whoId = whoId;
    }

    public TaskWrapper(
        Id id,
        String subject,
        String status,
        String assignedTo,
        Date dueDate,
        Boolean isClosed,
        string taskSubType,
        Id ownerId,
        Id whatId,
        Id whoId,
        string whoName
    ) {
        this.id = id;
        this.subject = subject;
        this.status = status;
        this.assignedTo = assignedTo;
        this.dueDate = dueDate;
        this.isClosed = isClosed;
        this.taskSubType = taskSubType;
        this.ownerId = ownerId;
        this.whatId = whatId;
        this.whoId = whoId;
        this.whoName = whoName;
    }

    public static List<TaskWrapper> convert(List<Task> taskList) {
        if (taskList == null || taskList.size() == 0) {
            return new List<TaskWrapper>();
        }

        // Get Picklist values for Status
        Schema.DescribeFieldResult statusFieldResult = SObjectType.Task.fields.Status;

        Map<String, String> pickListMap = new Map<String, String>();

        for (Schema.PicklistEntry entry : statusFieldResult.getPicklistValues()) {
            pickListMap.put(entry.getValue(), entry.getLabel());
        }

        List<TaskWrapper> result = new List<TaskWrapper>();
        for (Task t : taskList) {
            result.add(
                new TaskWrapper(
                    t.Id,
                    t.Subject,
                    (pickListMap != null && pickListMap.get(t.Status) != null) ? pickListMap.get(t.Status) : '',
                    t.Owner.Name,
                    t.ActivityDate,
                    t.IsClosed,
                    t.TaskSubType,
                    t.OwnerId,
                    t.WhatId,
                    t.WhoId,
                    t.Who.Name
                )
            );
        }

        return result;
    }
}