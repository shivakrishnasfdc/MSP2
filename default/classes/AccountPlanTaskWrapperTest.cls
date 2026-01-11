@isTest
private class AccountPlanTaskWrapperTest {
    @isTest
    static void taskWrapperListInitTest() {
        TestMockData md = new TestMockData();

        AccountPlanTaskWrapper wrapper = new AccountPlanTaskWrapper(
            md.mockTask,
            new List<Account_plan__c>{ md.mockAccountPlan }
        );

        System.assertEquals(md.mockTask, wrapper.taskRecord, 'taskRecord should be the same as the mockTask');
        System.assertEquals(
            md.mockAccountPlan,
            wrapper.accountPlanRecords[0],
            'accountPlanRecords should be the same as the mockAccountPlan'
        );
    }

    @isTest
    static void taskWrapperSetInitTest() {
        TestMockData md = new TestMockData();

        AccountPlanTaskWrapper wrapper = new AccountPlanTaskWrapper(
            md.mockTask,
            new Set<Account_plan__c>{ md.mockAccountPlan }
        );

        System.assertEquals(md.mockTask, wrapper.taskRecord, 'taskRecord should be the same as the mockTask');
        System.assertEquals(
            md.mockAccountPlan,
            wrapper.accountPlanRecords[0],
            'accountPlanRecords should be the same as the mockAccountPlan'
        );
    }

    @isTest
    static void nullTaskTest() {
        TestMockData md = new TestMockData();

        AccountPlanTaskWrapper wrapper = new AccountPlanTaskWrapper(
            null,
            new List<Account_plan__c>{ md.mockAccountPlan }
        );
        System.assertEquals(null, wrapper.taskRecord, 'taskRecord should be null');
        System.assertEquals(
            md.mockAccountPlan,
            wrapper.accountPlanRecords[0],
            'accountPlanRecords should be the same as the mockAccountPlan'
        );
    }

    @isTest
    static void nullPlansListTest() {
        TestMockData md = new TestMockData();

        List<Account_Plan__c> planList = null;

        AccountPlanTaskWrapper wrapper = new AccountPlanTaskWrapper(md.mockTask, planList);
        System.assertEquals(md.mockTask, wrapper.taskRecord, 'taskRecord should be the same as the mockTask');
        System.assertEquals(0, wrapper.accountPlanRecords.size(), 'accountPlanRecords should be empty');
    }

    @isTest
    static void nullPlansSetTest() {
        TestMockData md = new TestMockData();

        Set<Account_Plan__c> planSet = null;

        AccountPlanTaskWrapper wrapper = new AccountPlanTaskWrapper(md.mockTask, planSet);
        System.assertEquals(md.mockTask, wrapper.taskRecord, 'taskRecord should be the same as the mockTask');
        System.assertEquals(0, wrapper.accountPlanRecords.size(), 'accountPlanRecords should be empty');
    }

    @isTest
    static void equalsTest() {
        TestMockData md = new TestMockData();

        AccountPlanTaskWrapper wrapper1 = new AccountPlanTaskWrapper(
            md.mockTask,
            new List<Account_plan__c>{ md.mockAccountPlan }
        );
        AccountPlanTaskWrapper wrapper2 = new AccountPlanTaskWrapper(md.mockTask, new List<Account_plan__c>());

        System.assertEquals(wrapper1, wrapper2, 'wrapper1 should be equal to wrapper2');
    }

    @isTest
    public static void hashCodeTest() {
        TestMockData md = new TestMockData();

        AccountPlanTaskWrapper wrapper = new AccountPlanTaskWrapper(
            md.mockTask,
            new List<Account_plan__c>{ md.mockAccountPlan }
        );

        System.assertEquals(
            String.valueOf(md.mockTaskId).hashCode(),
            wrapper.hashCode(),
            'wrapper hashcode should be the same as the task Id hashcode'
        );
    }
}