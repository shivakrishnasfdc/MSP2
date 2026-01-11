@isTest
private class MasterAccountPlanSelectorTest {
    @isTest
    static void selectByMasterAccountPlanIdTest() {
        
        pq_Master_Account_Plan__c m = new pq_Master_Account_Plan__c(Name = 'test');
        insert m;

        List<pq_Master_Account_Plan__c> result = MasterAccountPlanSelector.newInstance().selectById(new Set<Id>{ m.Id });
        System.assertEquals(1, result.size());
        System.assertEquals(m.Id, result[0].Id);
    }
}