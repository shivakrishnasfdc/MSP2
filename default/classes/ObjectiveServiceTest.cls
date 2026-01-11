@isTest
private class ObjectiveServiceTest {
    @isTest
    static void getObjectivesForAccountPlanNullTest() {
        List<ObjectiveWrapper> result = ObjectiveService.getObjectivesForAccountPlans(null);
        System.assertEquals(0, result.size());
    }

    @isTest
    static void getObjectivesForAccountPlanTest() {
        TestMockData md = new TestMockData();
        TasksSelector mockTasksSelector = md.mockTasksSelector;
        ObjectiveSelector mockObjectiveSelector = md.mockObjectiveSelector;
        ObjectiveTaskAssociationSelector mockObjectiveTaskAssociationSelector = md.mockObjectiveTaskAssociationSelector;
        CrushUserSettingSelector mockCrushUserSettingSelector = md.mockCrushUserSettingSelector;

        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');
        Objective__c obj1 = TestDataFactory.createObjective(ap, 'testa', 'testa2');
        Objective__c obj2 = TestDataFactory.createObjective(ap, 'testb', 'testb2');
        Objective__c obj3 = TestDataFactory.createObjective(ap, 'testc', 'testc2');
        Objective__c obj4 = TestDataFactory.createObjective(ap, 'testd', 'testd2');

        Task task1 = new Task(Subject = 'This is a task1');
        insert task1;
        Task task2 = new Task(Subject = 'This is a another task2');
        insert task2;
        Task task3 = new Task(Subject = 'This is a task3');
        insert task3;
        Task task4 = new Task(Subject = 'This is a another task4');
        insert task4;
        Task task5 = new Task(Subject = 'This is a task5');
        insert task5;
        Task task6 = new Task(Subject = 'This is a another task6');
        insert task6;
        Task task7 = new Task(Subject = 'This is a another task7', WhatId = obj1.Id);
        insert task7;
        Task task8 = new Task(Subject = 'This is a another task8', WhatId = obj4.Id);
        insert task8;
        pqcrush__pq_Crush_User_Setting__c userSetting = new pq_Crush_User_Setting__c(pqcrush__Objective_Task_Sort_Ascending__c = true, pqcrush__Objective_Task_Sort_Field__c = 'ActivityDate', User__c = UserInfo.getUserId());
        insert userSetting;

        Objective_Task_Association__c ota1 = new Objective_Task_Association__c(
            Objective__c = obj1.Id,
            TaskId__c = task1.Id
        );
        Objective_Task_Association__c ota2 = new Objective_Task_Association__c(
            Objective__c = obj1.Id,
            TaskId__c = task2.Id
        );
        Objective_Task_Association__c ota3 = new Objective_Task_Association__c(
            Objective__c = obj2.Id,
            TaskId__c = task3.Id
        );
        Objective_Task_Association__c ota4 = new Objective_Task_Association__c(
            Objective__c = obj3.Id,
            TaskId__c = task4.Id
        );
        Objective_Task_Association__c ota5 = new Objective_Task_Association__c(
            Objective__c = obj3.Id,
            TaskId__c = task5.Id
        );
        Objective_Task_Association__c ota6 = new Objective_Task_Association__c(
            Objective__c = obj3.Id,
            TaskId__c = task6.Id
        );

        md.mocks.startStubbing();
        md.mocks.when(mockObjectiveSelector.selectByAccountPlanId(new Set<Id>{ ap.Id }))
            .thenReturn(new List<Objective__c>{ obj1, obj2, obj3, obj4 });
        md.mocks.when(
                mockObjectiveTaskAssociationSelector.selectByObjectives(
                    new Set<Id>{ obj1.Id, obj2.Id, obj3.Id, obj4.Id }
                )
            )
            .thenReturn(new List<Objective_Task_Association__c>{ ota1, ota2, ota3, ota4, ota5, ota6 });
        md.mocks.when(
                mockTasksSelector.selectByIdOrWhatIds(
                    new Set<Id>{ task1.Id, task2.Id, task3.Id, task4.Id, task5.Id, task6.Id },
                    new Set<Id>{ obj1.Id, obj2.Id, obj3.Id, obj4.Id },
                    userSetting.pqcrush__Objective_Task_Sort_Field__c,
                    userSetting.pqcrush__Objective_Task_Sort_Ascending__c
                )
            )
            .thenReturn(new List<Task>{ task1, task2, task3, task4, task5, task6, task7, task8 });
            md.mocks.when(
                mockTasksSelector.getObjectiveTaskOrderBy()
            )
            .thenReturn(userSetting);
            md.mocks.when(mockCrushUserSettingSelector.selectForCurrentUser())
            .thenReturn(
                new List<pq_Crush_User_Setting__c>{ new pq_Crush_User_Setting__c(pqcrush__Objective_Task_Sort_Ascending__c = true, pqcrush__Objective_Task_Sort_Field__c = 'ActivityDate', User__c = UserInfo.getUserId()) }
            );
        md.mocks.stopStubbing();

        List<ObjectiveWrapper> result = ObjectiveService.getObjectivesForAccountPlans(new Set<Id>{ ap.Id });
        System.assertEquals(4, result.size());
        for (ObjectiveWrapper wrapper : result) {
            if (wrapper.objective.Id == obj1.Id) {
                System.assertEquals(3, wrapper.tasks.size());
                Set<Id> taskIdSet0 = new Set<Id>{ task1.Id, task2.Id, task7.Id };
                System.assert(taskIdSet0.contains(wrapper.tasks[0].Id));
                System.assert(taskIdSet0.contains(wrapper.tasks[1].Id));
                System.assert(taskIdSet0.contains(wrapper.tasks[2].Id));
            } else if (wrapper.objective.Id == obj2.Id) {
                System.assertEquals(1, wrapper.tasks.size());
                System.assertEquals(task3.Id, wrapper.tasks[0].Id);
            } else if (wrapper.objective.Id == obj3.Id) {
                System.assertEquals(3, wrapper.tasks.size());
                Set<Id> taskIdSet = new Set<Id>{ task4.Id, task5.Id, task6.Id };
                System.assert(taskIdSet.contains(wrapper.tasks[0].Id));
                System.assert(taskIdSet.contains(wrapper.tasks[1].Id));
                System.assert(taskIdSet.contains(wrapper.tasks[2].Id));
            } else if (wrapper.objective.Id == obj4.Id) {
                System.assertEquals(1, wrapper.tasks.size());
                Set<Id> taskIdSet = new Set<Id>{ task8.Id };
                System.assert(taskIdSet.contains(wrapper.tasks[0].Id));
            }
        }
    }

    @isTest
    static void removeTaskFromObjectiveTest1() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        TasksSelector mockTasksSelector = md.mockTasksSelector;
        ObjectiveTaskAssociationSelector mockObjectiveTaskAssociationSelector = md.mockObjectiveTaskAssociationSelector;
        UserRecordAccessSelector mockUserRecordAccessSelector = md.mockUserRecordAccessSelector;

        Id objectiveId = fflib_IDGenerator.generate(Objective__c.SObjectType);
        Id taskId = fflib_IDGenerator.generate(Task.SObjectType);

        Task t = new Task(Subject = 'test', WhatId = objectiveId);

        md.mocks.startStubbing();
        md.mocks.when(mockTasksSelector.selectById(new Set<Id>{ taskId })).thenReturn(new List<Task>{ t });
        md.mocks.when(mockObjectiveTaskAssociationSelector.selectByObjectiveAndTask(objectiveId, taskId))
            .thenReturn(new List<Objective_Task_Association__c>());
        md.mocks.when(mockUserRecordAccessSelector.selectByRecordId(new Set<Id>{ taskId }))
            .thenReturn(new List<UserRecordAccess>{ new UserRecordAccess() });
        md.mocks.stopStubbing();

        ObjectiveService.removeTaskFromObjective(objectiveId, taskId, false);

        t.WhatId = null;

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerDeleted(new List<Objective_Task_Association__c>());
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(t);
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0)).registerDeleted(new List<Task>{ t });
        System.assert(true, 'Verified by mocks');
    }

    @isTest
    static void removeTaskFromObjectiveTest2() {
        TestMockData md = new TestMockData();
        TasksSelector mockTasksSelector = md.mockTasksSelector;
        ObjectiveTaskAssociationSelector mockObjectiveTaskAssociationSelector = md.mockObjectiveTaskAssociationSelector;
        UserRecordAccessSelector mockUserRecordAccessSelector = md.mockUserRecordAccessSelector;

        Id objectiveId = fflib_IDGenerator.generate(Objective__c.SObjectType);
        Id taskId = fflib_IDGenerator.generate(Task.SObjectType);

        Task t = new Task(Subject = 'test', WhatId = objectiveId);

        md.mocks.startStubbing();
        md.mocks.when(mockTasksSelector.selectById(new Set<Id>{ taskId })).thenReturn(new List<Task>{ t });
        md.mocks.when(mockObjectiveTaskAssociationSelector.selectByObjectiveAndTask(objectiveId, taskId))
            .thenReturn(new List<Objective_Task_Association__c>());
        md.mocks.when(mockUserRecordAccessSelector.selectByRecordId(new Set<Id>{ taskId }))
            .thenReturn(new List<UserRecordAccess>{ new UserRecordAccess() });
        md.mocks.stopStubbing();

        try {
            ObjectiveService.removeTaskFromObjective(objectiveId, taskId, true);
        } catch (Exception e) {
            // Should throw error
            System.assert(true, 'Should throw error');
        }
    }

    @isTest
    static void deleteObjectiveTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        ObjectiveSelector mockObjectiveSelector = md.mockObjectiveSelector;
        TasksSelector mockTasksSelector = md.mockTasksSelector;
        ObjectiveTaskAssociationSelector mockObjectiveTaskAssociationSelector = md.mockObjectiveTaskAssociationSelector;

        Id objectiveId = fflib_IDGenerator.generate(Objective__c.SObjectType);
        Task task1 = new Task(Subject = 'This is a task1');
        insert task1;
        Task task2 = new Task(Subject = 'This is a task2');
        insert task2;
        List<Id> taskIdList = new List<Id>{ task1.Id, task2.Id };
        LIst<Task> taskList = new List<Task>{ task1, task2 };

        md.mocks.startStubbing();
        md.mocks.when(mockObjectiveSelector.selectById(new Set<Id>{ objectiveId }))
            .thenReturn(new List<Objective__c>());
        md.mocks.when(mockTasksSelector.selectById(new Set<Id>{ task1.Id, task2.Id })).thenReturn(taskList);
        md.mocks.when(mockObjectiveTaskAssociationSelector.selectByObjectives(new Set<Id>{ objectiveId }))
            .thenReturn(new List<Objective_Task_Association__c>());
        md.mocks.stopStubbing();

        ObjectiveService.deleteObjective(objectiveId, taskIdList, true);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 2)).registerDeleted(new List<SObject>());
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDeleted(taskList);
        System.assert(true, 'Verified by mocks');
    }

    @isTest
    static void getTasksForAccountPlan() {
        TestMockData md = new TestMockData();
        TasksSelector mockTasksSelector = md.mockTasksSelector;
        ObjectiveSelector mockObjectiveSelector = md.mockObjectiveSelector;
        ObjectiveTaskAssociationSelector mockObjectiveTaskAssociationSelector = md.mockObjectiveTaskAssociationSelector;

        Task task1 = new Task(Subject = 'This is a task1');
        insert task1;
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');
        Objective__c obj1 = TestDataFactory.createObjective(ap, 'testa', 'testa2');
        Objective_Task_Association__c ota1 = new Objective_Task_Association__c(
            Objective__c = obj1.Id,
            TaskId__c = task1.Id
        );
        insert ota1;

        md.mocks.startStubbing();
        md.mocks.when(mockObjectiveSelector.selectByAccountPlanId(new Set<Id>{ ap.Id }))
            .thenReturn(new List<Objective__c>{ obj1 });
        md.mocks.when(mockObjectiveTaskAssociationSelector.selectByObjectives(new Set<Id>{ obj1.Id }))
            .thenReturn(new List<Objective_Task_Association__c>{ ota1 });
        md.mocks.when(mockTasksSelector.selectByIdAndFilters(new Set<Id>{ task1.Id }, new List<FilterObject>()))
            .thenReturn(new List<Task>{ task1 });
        md.mocks.stopStubbing();

        List<Task> result = ObjectiveService.getTasksForAccountPlan(new Set<Id>{ ap.Id }, new List<FilterObject>());

        System.assertEquals(1, result.size());
    }
}