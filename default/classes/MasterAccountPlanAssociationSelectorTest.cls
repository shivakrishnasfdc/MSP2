@isTest
private class MasterAccountPlanAssociationSelectorTest {
    @isTest
    static void selectByMasterAccountPlanIdTest() {
        
        pq_Master_Account_Plan__c m = new pq_Master_Account_Plan__c(Name = 'test');
        insert m;

        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;

        Account_Plan__c ap1 = TestDataFactory.createAccountPlan('a', testAccount);
 
        Master_Account_Plan_Associations__c mpa = new Master_Account_Plan_Associations__c(
            Master_Account_Plan__c = m.Id,
            Account_Plan__c = ap1.Id
        );

        insert mpa;


        List<Master_Account_Plan_Associations__c> result = MasterAccountPlanAssociationSelector.newInstance().selectByMasterAccountPlanId(new Set<Id>{ m.Id });
        System.assertEquals(1, result.size());
        System.assertEquals(ap1.Id, result[0].Account_Plan__c);
    }
}