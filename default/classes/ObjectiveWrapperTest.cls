@isTest
private class ObjectiveWrapperTest {
    @isTest
    static void objectiveTest() {
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');
        Objective__c obj1 = TestDataFactory.createObjective(ap, 'test1', 'test2');

        ObjectiveWrapper wrapper = new ObjectiveWrapper(obj1, true, false);
        System.assertEquals(obj1.Id, wrapper.objective.Id);
        System.assertEquals('test1', wrapper.objective.Name);
        System.assertEquals('test2', wrapper.objective.Description__c);
        System.assertEquals(true, wrapper.updateable);
        System.assertEquals(false, wrapper.deleteable);
    }

    @isTest
    static void objectiveTaskTest() {
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');
        Objective__c obj1 = TestDataFactory.createObjective(ap, 'test1', 'test2');
        Task task1 = new Task(Subject = 'This is a task');
        insert task1;
        Task task2 = new Task(Subject = 'This is a another task');
        insert task2;

        ObjectiveWrapper wrapper = new ObjectiveWrapper(obj1, new List<Task>{ task1, task2 }, false, true);
        System.assertEquals(obj1.Id, wrapper.objective.Id);
        System.assertEquals('test1', wrapper.objective.Name);
        System.assertEquals('test2', wrapper.objective.Description__c);
        System.assertEquals(task1.Subject, wrapper.tasks[0].Subject);
        System.assertEquals(task2.Subject, wrapper.tasks[1].Subject);
        System.assertEquals(false, wrapper.updateable);
        System.assertEquals(true, wrapper.deleteable);
    }
}