@isTest
private class TasksSelectorTest {
    @isTest
    static void newInstanceTest() {
        TasksSelector selector = TasksSelector.newInstance();

        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        Task t1 = new Task(Subject = 'test');
        Task t2 = new Task(Subject = 'test2');
        insert t1;
        insert t2;

        List<Task> result = TasksSelector.newInstance().selectById(new Set<Id>{ t1.Id, t2.Id });
        System.assertEquals(2, result.size());
    }

    @isTest
    static void selectByIdOrWhatIdsTest() {
        Account_Plan__c ap = TestDataFactory.createAccountPlan('Plan Name');
        Objective__c obj = new Objective__c(Name = 'obj test', Account_Plan__c = ap.Id);
        insert obj;
        Task t1 = new Task(Subject = 'test');
        Task t2 = new Task(Subject = 'test2', WhatId = obj.Id);
        insert t1;
        insert t2;
        pqcrush__pq_Crush_User_Setting__c userSetting = new pq_Crush_User_Setting__c(pqcrush__Objective_Task_Sort_Ascending__c = true, pqcrush__Objective_Task_Sort_Field__c = 'ActivityDate', User__c = UserInfo.getUserId());
        insert userSetting;
        List<Task> result = TasksSelector.newInstance()
            .selectByIdOrWhatIds(new Set<Id>{ t1.Id }, new Set<Id>{ obj.Id }, userSetting.pqcrush__Objective_Task_Sort_Field__c, userSetting.pqcrush__Objective_Task_Sort_Ascending__c);
        System.assertEquals(2, result.size());
    }

    @isTest
    static void selectByIdAndFiltersTest() {
        Task t1 = new Task(Subject = 'test');
        Task t2 = new Task(Subject = 'test2');
        insert t1;
        insert t2;

        List<Task> result = TasksSelector.newInstance()
            .selectByIdAndFilters(new Set<Id>{ t1.Id, t2.Id }, new List<FilterObject>());
        System.assertEquals(2, result.size());
    }

    @isTest
    static void selectByIdAndFiltersTest2() {
        Task t1 = new Task(Subject = 'test', Status = 'In Progress');
        Task t2 = new Task(Subject = 'test2', Status = 'Completed');
        insert t1;
        insert t2;

        FilterObject fo = new FilterObject('Completed', 'Completed', 'Status', false, false);
        FilterObject fo2 = new FilterObject('Mine', 'OwnerMine', 'OwnerId', false, false);

        List<Task> result = TasksSelector.newInstance()
            .selectByIdAndFilters(new Set<Id>{ t1.Id, t2.Id }, new List<FilterObject>{ fo, fo2 });
        System.assertEquals(1, result.size());
    }

    @isTest
    static void selectByIdAndFiltersTest3() {
        Task t1 = new Task(Subject = 'test', Status = 'In Progress');
        insert t1;

        FilterObject fo = new FilterObject('TODAY', 'TODAY', 'ActivityDate', false, false);

        List<Task> result = TasksSelector.newInstance()
            .selectByIdAndFilters(new Set<Id>{ t1.Id }, new List<FilterObject>{ fo });
        System.assertEquals(0, result.size());
    }

    @isTest
    static void selectByWhoIdTest() {
        Contact c1 = TestDataFactory.createContact('john', 'smith');

        Date date1 = Date.newInstance(2022, 6, 10);
        Date date2 = Date.newInstance(2022, 6, 11);
        Date date3 = Date.newInstance(2022, 6, 12);
        Date date4 = Date.newInstance(2022, 6, 13);
        Date date5 = Date.newInstance(2022, 6, 14);
        Date date6 = Date.newInstance(2022, 6, 15);

        Task t1 = new Task(Subject = 'test1', WhoId = c1.Id, ActivityDate = date1);
        Task t2 = new Task(Subject = 'test2');
        Task t3 = new Task(Subject = 'test3', WhoId = c1.Id, ActivityDate = date2, Status = 'Completed');
        Task t4 = new Task(Subject = 'test4', WhoId = c1.Id, ActivityDate = date3);
        Task t5 = new Task(Subject = 'test5', WhoId = c1.Id, ActivityDate = date4, Status = 'Completed');
        Task t6 = new Task(Subject = 'test6', WhoId = c1.Id, ActivityDate = date5);
        Task t7 = new Task(Subject = 'test7', WhoId = c1.Id, ActivityDate = date6, Status = 'Completed');
        insert t1;
        insert t2;
        insert t3;
        insert t4;
        insert t5;
        insert t6;
        insert t7;

        List<Task> result = TasksSelector.newInstance().selectByWhoId(new Set<Id>{ c1.Id }, true, 2, false);
        System.assertEquals(2, result.size());
        System.assertEquals(t1.Id, result[0].Id);

        List<Task> result2 = TasksSelector.newInstance().selectByWhoId(new Set<Id>{ c1.Id }, false, 2, true);
        System.assertEquals(2, result2.size());
        System.assertEquals(t7.Id, result2[0].Id);
    }

    @isTest
    static void selectByWhatIdTest() {
        Account_Plan__c ap = TestDataFactory.createAccountPlan('Plan Name');
        Objective__c obj = new Objective__c(Name = 'obj test', Account_Plan__c = ap.Id);
        insert obj;

        Task t1 = new Task(Subject = 'test1', WhatId = obj.Id);
        Task t2 = new Task(Subject = 'test2', WhatId = obj.Id);
        insert t1;
        insert t2;

        List<Task> result = TasksSelector.newInstance().selectByWhatId(new Set<Id>{ obj.Id }, true, 2, false);
        System.assertEquals(2, result.size());
    }

    @isTest
    static void getTasksWithRelatedIdsTest() {
        Contact c1 = TestDataFactory.createContact('john', 'smith');
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');

        Task t1 = new Task(Subject = 'test', WhoId = c1.Id, WhatId = ap.Id, Status = 'Completed');
        Task t2 = new Task(Subject = 'test2');
        insert t1;
        insert t2;

        FilterObject fo1 = new FilterObject('Mine', 'OwnerMine', 'OwnerId', false, false);
        FilterObject fo2 = new FilterObject('Completed', 'Completed', 'Status', false, false);

        List<Task> result = TasksSelector.newInstance()
            .getTasksWithRelatedIds(new Set<Id>{ ap.Id }, new List<FilterObject>{ fo1, fo2 });
        System.assertEquals(1, result.size());
    }

    @isTest
    static void getTasksWithRelatedIdsWhoIdTest() {
        Contact c1 = TestDataFactory.createContact('john', 'smith');
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');

        Task t1 = new Task(Subject = 'test', WhoId = c1.Id, WhatId = ap.Id, Status = 'Completed');
        Task t2 = new Task(Subject = 'test2');
        insert t1;
        insert t2;

        FilterObject fo1 = new FilterObject('Mine', 'OwnerMine', 'OwnerId', false, false);
        FilterObject fo2 = new FilterObject('Completed', 'Completed', 'Status', false, false);

        List<Task> result = TasksSelector.newInstance()
            .getTasksWithRelatedIds(new Set<Id>{ c1.Id }, new List<FilterObject>{ fo1, fo2 });
        System.assertEquals(1, result.size());
    }

    @isTest
    static void getTasksWithRelatedIdsTest2() {
        Contact c1 = TestDataFactory.createContact('john', 'smith');
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');

        Task t1 = new Task(Subject = 'test', WhoId = c1.Id, WhatId = ap.Id, Status = 'Completed');
        insert t1;

        FilterObject fo = new FilterObject('TODAY', 'TODAY', 'ActivityDate', false, false);

        List<Task> result = TasksSelector.newInstance()
            .getTasksWithRelatedIds(new Set<Id>{ ap.Id }, new List<FilterObject>{ fo });
        System.assertEquals(0, result.size());
    }

    @isTest
    static void getTaskCountForObjectTypeTest() {
        Contact c1 = TestDataFactory.createContact('john', 'smith');
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');

        Task t1 = new Task(Subject = 'test', WhoId = c1.Id, WhatId = ap.Id, Status = 'Completed');
        Task t2 = new Task(Subject = 'test2');
        insert t1;
        insert t2;

        FilterObject fo1 = new FilterObject('Mine', 'OwnerMine', 'OwnerId', false, false);
        FilterObject fo2 = new FilterObject('Completed', 'Completed', 'Status', false, false);

        Integer result = TasksSelector.newInstance()
            .getTaskCountForObjectType('pqcrush__Account_Plan__c', new List<FilterObject>{ fo1, fo2 });
        System.assertEquals(1, result);
    }

    @isTest
    static void getTaskCountForObjectTypeTest2() {
        Contact c1 = TestDataFactory.createContact('john', 'smith');
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');

        Task t1 = new Task(Subject = 'test', WhoId = c1.Id, WhatId = ap.Id, Status = 'Completed');
        insert t1;

        FilterObject fo = new FilterObject('TODAY', 'TODAY', 'ActivityDate', false, false);

        Integer result = TasksSelector.newInstance()
            .getTaskCountForObjectType('pqcrush__Account_Plan__c', new List<FilterObject>{ fo });
        System.assertEquals(0, result);
    }

    @isTest
    static void selectByRelatedIdsWithFiltersPagedTest() {
        Contact c1 = TestDataFactory.createContact('john', 'smith');
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');

        Task t1 = new Task(Subject = 'test', WhoId = c1.Id, WhatId = ap.Id, Status = 'Completed');
        Task t2 = new Task(Subject = 'test2');
        insert t1;
        insert t2;

        Set<Id> idSet = new Set<Id>{ ap.Id };
        Integer pageNumber = 0;
        Integer recordsPerPage = 50;

        FilterObject fo1 = new FilterObject('Mine', 'OwnerMine', 'OwnerId', false, false);
        FilterObject fo2 = new FilterObject('Completed', 'Completed', 'Status', false, false);

        List<FilterObject> selectedFilters = new List<FilterObject>{ fo1, fo2 };

        List<Task> result = TasksSelector.newInstance()
            .selectByRelatedIdsWithFiltersPaged(idSet, pageNumber, recordsPerPage, selectedFilters);
        System.assertEquals(1, result.size());
        System.assertEquals(t1.Id, result[0].Id);
    }

    @isTest
    static void selectByRelatedIdsWithFiltersTest() {
        Contact c1 = TestDataFactory.createContact('john', 'smith');
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');

        Task t1 = new Task(Subject = 'test', WhoId = c1.Id, WhatId = ap.Id, Status = 'Completed');
        Task t2 = new Task(Subject = 'test2');
        insert t1;
        insert t2;

        Set<Id> idSet = new Set<Id>{ ap.Id };

        FilterObject fo1 = new FilterObject('Mine', 'OwnerMine', 'OwnerId', false, false);
        FilterObject fo2 = new FilterObject('Completed', 'Completed', 'Status', false, false);

        List<FilterObject> selectedFilters = new List<FilterObject>{ fo1, fo2 };

        List<Task> result = TasksSelector.newInstance().selectByRelatedIdsWithFilters(idSet, selectedFilters);
        System.assertEquals(1, result.size());
        System.assertEquals(t1.Id, result[0].Id);
    }

    @isTest
    static void selectByRelatedIdsWithFiltersPagedWhoIdTest() {
        Contact c1 = TestDataFactory.createContact('john', 'smith');
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');

        Task t1 = new Task(Subject = 'test', WhoId = c1.Id, WhatId = ap.Id, Status = 'Completed');
        Task t2 = new Task(Subject = 'test2');
        insert t1;
        insert t2;

        Set<Id> idSet = new Set<Id>{ c1.Id };
        Integer pageNumber = 0;
        Integer recordsPerPage = 50;

        FilterObject fo1 = new FilterObject('Mine', 'OwnerMine', 'OwnerId', false, false);
        FilterObject fo2 = new FilterObject('Completed', 'Completed', 'Status', false, false);

        List<FilterObject> selectedFilters = new List<FilterObject>{ fo1, fo2 };

        List<Task> result = TasksSelector.newInstance()
            .selectByRelatedIdsWithFiltersPaged(idSet, pageNumber, recordsPerPage, selectedFilters);
        System.assertEquals(1, result.size());
        System.assertEquals(t1.Id, result[0].Id);
    }

    @isTest
    static void selectByRelatedIdsWithFiltersWhoIdTest() {
        Contact c1 = TestDataFactory.createContact('john', 'smith');
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');

        Task t1 = new Task(Subject = 'test', WhoId = c1.Id, WhatId = ap.Id, Status = 'Completed');
        Task t2 = new Task(Subject = 'test2');
        insert t1;
        insert t2;

        Set<Id> idSet = new Set<Id>{ c1.Id };

        FilterObject fo1 = new FilterObject('Mine', 'OwnerMine', 'OwnerId', false, false);
        FilterObject fo2 = new FilterObject('Completed', 'Completed', 'Status', false, false);

        List<FilterObject> selectedFilters = new List<FilterObject>{ fo1, fo2 };

        List<Task> result = TasksSelector.newInstance().selectByRelatedIdsWithFilters(idSet, selectedFilters);
        System.assertEquals(1, result.size());
        System.assertEquals(t1.Id, result[0].Id);
    }

    @isTest
    static void selectByRelatedIdsWithFiltersPagedTest2() {
        Contact c1 = TestDataFactory.createContact('john', 'smith');
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');

        Task t1 = new Task(Subject = 'test', WhoId = c1.Id, WhatId = ap.Id, Status = 'Completed');
        insert t1;

        Set<Id> idSet = new Set<Id>{ ap.Id };
        Integer pageNumber = 0;
        Integer recordsPerPage = 50;

        FilterObject fo = new FilterObject('TODAY', 'TODAY', 'ActivityDate', false, false);

        List<FilterObject> selectedFilters = new List<FilterObject>{ fo };

        List<Task> result = TasksSelector.newInstance()
            .selectByRelatedIdsWithFiltersPaged(idSet, pageNumber, recordsPerPage, selectedFilters);
        System.assertEquals(0, result.size());
    }

    @isTest
    static void selectByRelatedIdsWithFiltersTest2() {
        Contact c1 = TestDataFactory.createContact('john', 'smith');
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');

        Task t1 = new Task(Subject = 'test', WhoId = c1.Id, WhatId = ap.Id, Status = 'Completed');
        insert t1;

        Set<Id> idSet = new Set<Id>{ ap.Id };

        FilterObject fo = new FilterObject('TODAY', 'TODAY', 'ActivityDate', false, false);

        List<FilterObject> selectedFilters = new List<FilterObject>{ fo };

        List<Task> result = TasksSelector.newInstance().selectByRelatedIdsWithFilters(idSet, selectedFilters);
        System.assertEquals(0, result.size());
    }

    @isTest
    static void selectByObjectTypeTest() {
        Contact c1 = TestDataFactory.createContact('john', 'smith');
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');

        Task t1 = new Task(Subject = 'test', WhoId = c1.Id, WhatId = ap.Id, Status = 'Completed');
        Task t2 = new Task(Subject = 'test2');
        insert t1;
        insert t2;

        FilterObject fo1 = new FilterObject('Mine', 'OwnerMine', 'OwnerId', false, false);
        FilterObject fo2 = new FilterObject('Completed', 'Completed', 'Status', false, false);

        Integer pageNumber = 0;
        Integer recordsPerPage = 50;
        List<FilterObject> selectedFilters = new List<FilterObject>{ fo1, fo2 };

        List<Task> result = TasksSelector.newInstance()
            .selectByObjectType('pqcrush__Account_Plan__c', pageNumber, recordsPerPage, selectedFilters);
        System.assertEquals(1, result.size());
        System.assertEquals(t1.Id, result[0].Id);
    }

    @isTest
    static void selectByObjectTypeTest2() {
        Contact c1 = TestDataFactory.createContact('john', 'smith');
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');

        Task t1 = new Task(Subject = 'test', WhoId = c1.Id, WhatId = ap.Id, Status = 'Completed');
        insert t1;

        FilterObject fo = new FilterObject('TODAY', 'TODAY', 'ActivityDate', false, false);

        Integer pageNumber = 0;
        Integer recordsPerPage = 50;
        List<FilterObject> selectedFilters = new List<FilterObject>{ fo };

        List<Task> result = TasksSelector.newInstance()
            .selectByObjectType('pqcrush__Account_Plan__c', pageNumber, recordsPerPage, selectedFilters);
        System.assertEquals(0, result.size());
    }
}