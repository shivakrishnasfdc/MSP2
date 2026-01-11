@isTest
private class ObjectiveTaskAssociationSelectorTest {
    @isTest
    static void newInstanceTest() {
        ObjectiveTaskAssociationSelector selector = ObjectiveTaskAssociationSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByObjectivesTest() {
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');
        Objective__c obj1 = TestDataFactory.createObjective(ap, 'test1', 'test2');

        Task task1 = new Task(Subject = 'This is a task');
        insert task1;
        Task task2 = new Task(Subject = 'This is a another task');
        insert task2;

        Objective_Task_Association__c ota1 = new Objective_Task_Association__c(
            Objective__c = obj1.Id,
            TaskId__c = task1.Id
        );
        insert ota1;
        Objective_Task_Association__c ota2 = new Objective_Task_Association__c(
            Objective__c = obj1.Id,
            TaskId__c = task2.Id
        );
        insert ota2;

        List<Objective_Task_Association__c> result = ObjectiveTaskAssociationSelector.newInstance()
            .selectByObjectives(new Set<Id>{ obj1.Id });

        System.assertEquals(2, result.size());
    }

    @isTest
    static void selectByObjectiveAndTaskTest() {
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');
        Objective__c obj1 = TestDataFactory.createObjective(ap, 'test1', 'test2');

        Task task1 = new Task(Subject = 'This is a task');
        insert task1;
        Task task2 = new Task(Subject = 'This is a another task');
        insert task2;

        Objective_Task_Association__c ota1 = new Objective_Task_Association__c(
            Objective__c = obj1.Id,
            TaskId__c = task1.Id
        );
        insert ota1;
        Objective_Task_Association__c ota2 = new Objective_Task_Association__c(
            Objective__c = obj1.Id,
            TaskId__c = task2.Id
        );
        insert ota2;

        List<Objective_Task_Association__c> result = ObjectiveTaskAssociationSelector.newInstance()
            .selectByObjectiveAndTask(obj1.Id, task1.Id);

        System.assertEquals(1, result.size());
        System.assertEquals(ota1.Id, result[0].Id);
    }
}