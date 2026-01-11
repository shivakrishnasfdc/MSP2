@isTest
private class ObjectiveWrapperListTest {
    @isTest
    static void newInstanceTest() {
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');
        Objective__c obj1 = TestDataFactory.createObjective(ap, 'test1', 'test2');

        ObjectiveWrapper wrapper = new ObjectiveWrapper(obj1, true, true);

        ObjectiveWrapperList objWrapperList = new ObjectiveWrapperList(new List<ObjectiveWrapper>{ wrapper });
        System.assertNotEquals(null, objWrapperList);
        System.assertEquals(1, objWrapperList.objectives.size());
    }
}