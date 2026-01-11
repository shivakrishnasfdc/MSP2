@isTest
private class TaskWrapperTest {
    @isTest
    static void taskTest() {
        Id tId = fflib_IDGenerator.generate(Task.SObjectType);
        String subject = 'abc';
        String assignedTo = 'me';
        String status = 'completed';
        Date dueDate = Date.today();
        Boolean isClosed = true;

        TaskWrapper wrapper = new TaskWrapper(tId, subject, status, assignedTo, dueDate, isClosed);

        System.assertEquals(tId, wrapper.id);
        System.assertEquals(subject, wrapper.subject);
        System.assertEquals(assignedTo, wrapper.assignedTo);
        System.assertEquals(status, wrapper.status);
        System.assertEquals(dueDate, wrapper.dueDate);
        System.assertEquals(isClosed, wrapper.isClosed);
    }

    @isTest
    static void convertTest() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User someUser = TestDataFactory.createUser('FirstName', 'LastName', standardProfile.Id);

        Date d1 = Date.today();
        Date d2 = d1.addDays(-10);

        String s1 = 'task 1';
        String s2 = 'task 2';

        String status1 = 'Completed';
        String status2 = 'In Progress';

        Task task1 = new Task(Subject = s1, OwnerId = someUser.Id, ActivityDate = d1, Status = 'Completed');
        insert task1;
        Task task2 = new Task(Subject = s2, OwnerId = someUser.Id, ActivityDate = d2, Status = 'In Progress');
        insert task2;

        Task t1 = [
            SELECT Id, Subject, Owner.Name, ActivityDate, Status, TaskSubType, WhatId, WhoId, Who.Name, IsClosed
            FROM Task
            WHERE Id = :task1.Id
        ];
        Task t2 = [
            SELECT Id, Subject, Owner.Name, ActivityDate, Status, TaskSubType, WhatId, WhoId, Who.Name, IsClosed
            FROM Task
            WHERE Id = :task2.Id
        ];

        List<TaskWrapper> result = TaskWrapper.convert(new List<Task>{ t1, t2 });

        System.assertEquals(2, result.size());
        System.assertEquals(t1.Id, result[0].id);
        System.assertEquals(s1, result[0].subject);
        System.assertEquals(d1, result[0].dueDate);
        System.assertEquals('FirstName LastName', result[0].assignedTo);
        System.assertEquals(status1, result[0].status);
        System.assertEquals(true, result[0].isClosed);

        System.assertEquals(t2.Id, result[1].id);
        System.assertEquals(s2, result[1].subject);
        System.assertEquals(d2, result[1].dueDate);
        System.assertEquals('FirstName LastName', result[1].assignedTo);
        System.assertEquals(status2, result[1].status);
        System.assertEquals(false, result[1].isClosed);
    }

    @isTest
    static void convertNullTest() {
        List<TaskWrapper> result = TaskWrapper.convert(null);
        System.assertEquals(0, result.size());
    }
}