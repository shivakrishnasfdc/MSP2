@isTest
private class OpportunityControllerTest {
    @isTest
    static void getOpportunityContactsForContactIdsTest() {
        TestMockData md = new TestMockData();
        OpportunityContactRoleSelector selector = md.mockOpportunityContactRoleSelector;

        OpportunityController.getOpportunityContactsForContactId(md.mockContactId);

        ((OpportunityContactRoleSelector) md.mocks.verify(selector, 1))
            .selectByContactId(new Set<Id>{ md.mockContactId });
        System.assert(true, 'Assert by mock verify');
    }

    @isTest
    static void getTasksForOpportunityTest() {
        TestMockData md = new TestMockData();
        TasksSelector mockTasksSelector = md.mockTasksSelector;

        Task t1 = new Task(Subject = 'task1');
        Task t2 = new Task(Subject = 'task2');

        md.mocks.startStubbing();
        md.mocks.when(mockTasksSelector.selectByWhatId(new Set<Id>{ md.mockOpportunityId }, true, 50, false))
            .thenReturn(new List<Task>{ t1 });
        md.mocks.when(mockTasksSelector.selectByWhatId(new Set<Id>{ md.mockOpportunityId }, false, 50, true))
            .thenReturn(new List<Task>{ t2 });
        md.mocks.stopStubbing();

        // When
        List<TaskWrapper> result = OpportunityController.getTasksForOpportunity(md.mockOpportunityId);

        ((TasksSelector) md.mocks.verify(mockTasksSelector, 1))
            .selectByWhatId(new Set<Id>{ md.mockOpportunityId }, true, 50, false);
        ((TasksSelector) md.mocks.verify(mockTasksSelector, 1))
            .selectByWhatId(new Set<Id>{ md.mockOpportunityId }, false, 50, true);
        System.assertEquals(2, result.size());
    }
}