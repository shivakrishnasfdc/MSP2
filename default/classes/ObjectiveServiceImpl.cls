@SuppressWarnings('PMD.NcssMethodCount')
public with sharing class ObjectiveServiceImpl {
    public List<ObjectiveWrapper> getObjectivesForAccountPlans(Set<Id> accountPlanIds) {
        if (accountPlanIds == null || accountPlanIds.size() <= 0) {
            return new List<ObjectiveWrapper>();
        }

        List<Objective__c> objectives = ObjectiveSelector.newInstance().selectByAccountPlanId(accountPlanIds);

        Set<Id> objectiveIds = new Set<Id>();
        for (Objective__c obj : objectives) {
            objectiveIds.add(obj.Id);
        }

        List<Objective_Task_Association__c> otas = ObjectiveTaskAssociationSelector.newInstance()
            .selectByObjectives(objectiveIds);

        Set<Id> taskIds = new Set<Id>();
        Map<Id, Set<Id>> objectTaskMap = new Map<Id, Set<Id>>();
        for (Objective_Task_Association__c ota : otas) {
            taskIds.add(ota.TaskId__c);
            if (objectTaskMap.containsKey(ota.Objective__c)) {
                Set<Id> tIds = objectTaskMap.get(ota.Objective__c);
                tIds.add(ota.TaskId__c);
                objectTaskMap.put(ota.Objective__c, tIds);
            } else {
                objectTaskMap.put(ota.Objective__c, new Set<Id>{ ota.TaskId__c });
            }
        }

        pqcrush__pq_Crush_User_Setting__c userSetting = TasksSelector.newInstance().getObjectiveTaskOrderBy();
        String sortField = userSetting.pqcrush__Objective_Task_Sort_Field__c;
        Boolean sortOrderAscending = userSetting.pqcrush__Objective_Task_Sort_Ascending__c;

        List<Task> tasks = TasksSelector.newInstance()
            .selectByIdOrWhatIds(taskIds, objectiveIds, sortField, sortOrderAscending);

        Map<Id, Task> taskMap = new Map<Id, Task>();
        for (Task task : tasks) {
            taskMap.put(task.Id, task);
            if (objectiveIds.contains(task.WhatId)) {
                Set<Id> taskIdSet = objectTaskMap.get(task.WhatId);
                if (taskIdSet != null) {
                    taskIdSet.add(task.Id);
                } else {
                    taskIdSet = new Set<Id>{ task.Id };
                }
                objectTaskMap.put(task.WhatId, taskIdSet);
            }
        }

        Boolean updateable = Schema.sObjectType.Objective__c.isUpdateable();
        Boolean deleteable = Schema.sObjectType.Objective__c.isDeletable();

        // TYPICALLY We get the access record info on demand because user record access is an expensive call
        // but this should ok cause it should be a small list
        Map<Id, UserRecordAccess> mapAccessRecord = UserRecordAccessService.recordAccessForRecords(objectives);

        List<ObjectiveWrapper> wrapper = new List<ObjectiveWrapper>();
        for (Objective__c obj : objectives) {
            List<Task> taskList = getTaskListForTaskIds(objectTaskMap.get(obj.Id), taskMap);
            UserRecordAccess ura = mapAccessRecord.get(obj.Id);
            Boolean canUpdate = updateable && (ura.HasAllAccess || ura.HasEditAccess);
            Boolean canDelete = deleteable && (ura.HasAllAccess || ura.HasDeleteAccess);
            wrapper.add(new ObjectiveWrapper(obj, taskList, canUpdate, canDelete));
        }

        return wrapper;
    }

    public void updateObjectiveRecords(List<Objective__c> objectives) {
        if (!objectives.isEmpty() && Schema.sObjectType.Objective__c.isUpdateable()) {
            update objectives;
        }
    }

    private List<Task> getTaskListForTaskIds(Set<Id> tasksForObj, Map<Id, Task> taskMap) {
        List<Task> taskList = new List<Task>();
        if (tasksForObj != null) {
            for (Id taskId : tasksForObj) {
                Task t = taskMap.get(taskId);
                if (t != null) {
                    taskList.add(taskMap.get(taskId));
                }
            }
        }
        return taskList;
    }

    public void removeTaskFromObjective(Id objectiveId, Id taskId, Boolean alsoDelete) {
        // Check to see if user can delete the task
        Boolean deleteable = Schema.sObjectType.Task.isDeletable();
        if (alsoDelete && !deleteable) {
            throw new AuraHandledException('You do not have access to delete tasks.');
        }
        List<UserRecordAccess> recordAccess = UserRecordAccessSelector.newInstance()
            .selectByRecordId(new Set<Id>{ taskId });
        if (recordAccess.size() == 1) {
            UserRecordAccess ura = recordAccess[0];
            Boolean canDelete = deleteable && (ura.HasAllAccess || ura.HasDeleteAccess);
            if (alsoDelete && !canDelete) {
                throw new AuraHandledException('You do not have access to delete this task.');
            }
        }

        // Get Task and set WhatId to null
        List<Task> tasks = TasksSelector.newInstance().selectById(new Set<Id>{ taskID });
        if (tasks.size() == 1) {
            Task t = tasks[0];
            if (t.WhatId == objectiveId) {
                t.WhatId = null;
                fflib_ISObjectUnitOfWork uowTask = Application.UnitOfWork.newInstance();
                uowTask.registerDirty(t);
                uowTask.commitWork();
            }
        }

        List<Objective_Task_Association__c> otas = ObjectiveTaskAssociationSelector.newInstance()
            .selectByObjectiveAndTask(objectiveId, taskId);

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(otas);
        if (alsoDelete) {
            uow.registerDeleted(tasks);
        }
        uow.commitWork();
    }

    public void deleteObjective(Id objectiveId, List<Id> taskIds, Boolean alsoDelete) {
        List<Task> tasks = new List<Task>();
        List<Objective_Task_Association__c> otas = new List<Objective_Task_Association__c>();

        if (alsoDelete && taskIds.size() > 0) {
            tasks.addAll(this.getTasksToDelete(taskIds));
            otas.addAll(this.getOtasToDelete(objectiveId));
        }

        if (!alsoDelete && taskIds.size() > 0) {
            this.clearTasks(objectiveId, taskIds);
        }

        List<UserRecordAccess> recordAccess = UserRecordAccessSelector.newInstance()
            .selectByRecordId(new Set<Id>(taskIds));
        Set<Id> taskIdsThatCanBeDeleted = new Set<Id>();
        if (recordAccess != null) {
            for (UserRecordAccess ura : recordAccess) {
                if (ura.HasAllAccess || ura.HasDeleteAccess) {
                    taskIdsThatCanBeDeleted.add(ura.RecordId);
                }
            }
        }

        List<Objective__c> objectives = ObjectiveSelector.newInstance().selectById(new Set<Id>{ objectiveId });

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(objectives);
        uow.registerDeleted(otas);
        if (alsoDelete) {
            uow.registerDeleted(tasks);
        }
        uow.commitWork();
    }

    private List<Task> getTasksToDelete(List<Id> taskIds) {
        List<Task> tasks = new List<Task>();
        Boolean deleteable = Schema.sObjectType.Task.isDeletable();
        if (!deleteable) {
            throw new AuraHandledException('You do not have access to delete tasks.');
        }
        // Check to see if user can delete a task, if provided
        Set<Id> taskIdsThatCanBeDeleted = this.checkTaskRecordAccess(taskIds);
        tasks.addAll(TasksSelector.newInstance().selectById(taskIdsThatCanBeDeleted));
        return tasks;
    }

    private List<Objective_Task_Association__c> getOtasToDelete(Id objectiveId) {
        List<Objective_Task_Association__c> otas = new List<Objective_Task_Association__c>();
        otas.addAll(ObjectiveTaskAssociationSelector.newInstance().selectByObjectives(new Set<Id>{ objectiveId }));
        return otas;
    }

    private void clearTasks(Id objectiveId, List<Id> taskIds) {
        // If keeping tasks, first clear WhatIds from tasks before deleting Objectives or they will be deleted
        fflib_ISObjectUnitOfWork uowTasks = Application.UnitOfWork.newInstance();
        List<Task> taskTargets = TasksSelector.newInstance().selectById(new Set<Id>(taskIds));
        for (Task t : taskTargets) {
            if (t.WhatId == objectiveId) {
                t.WhatId = null;
                uowTasks.registerDirty(t);
            }
        }
        uowTasks.commitWork();
    }

    public List<Task> getTasksForAccountPlan(Set<Id> accountPlanIds, List<FilterObject> selectedFilters) {
        // GET OBJECTIVES
        List<Objective__c> objectives = ObjectiveSelector.newInstance().selectByAccountPlanId(accountPlanIds);

        Set<Id> objectiveIds = new Set<Id>();
        for (Objective__c obj : objectives) {
            objectiveIds.add(obj.Id);
        }

        // GET TASKS OBJECTIVE ASSOCIATIONS FOR OBJECTIVES
        List<Objective_Task_Association__c> otas = ObjectiveTaskAssociationSelector.newInstance()
            .selectByObjectives(objectiveIds);

        Set<Id> taskIds = new Set<Id>();
        for (Objective_Task_Association__c ota : otas) {
            taskIds.add(ota.TaskId__c);
        }

        // GET TASKS
        return TasksSelector.newInstance().selectByIdAndFilters(taskIds, selectedFilters);
    }

    public Set<Id> checkTaskRecordAccess(List<Id> taskIds) {
        List<UserRecordAccess> recordAccess = UserRecordAccessSelector.newInstance()
            .selectByRecordId(new Set<Id>(taskIds));
        Set<Id> taskIdsThatCanBeDeleted = new Set<Id>();
        if (recordAccess != null) {
            for (UserRecordAccess ura : recordAccess) {
                if (ura.HasAllAccess || ura.HasDeleteAccess) {
                    taskIdsThatCanBeDeleted.add(ura.RecordId);
                }
            }
        }
        return taskIdsThatCanBeDeleted;
    }
}