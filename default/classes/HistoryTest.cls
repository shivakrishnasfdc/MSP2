@isTest
private class HistoryTest {
    @isTest
    static void newInstanceTest() {
        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;

        Account_Plan__c ap1 = TestDataFactory.createAccountPlan('a', testAccount);
        Account_Plan__c ap2 = TestDataFactory.createAccountPlan('b', testAccount);

        List<SObject> accountPlans = AccountPlanSelector.newInstance()
            .selectSObjectsByIdWithHistory(new Set<Id>{ ap1.Id, ap2.Id });

        List<SObject> histories = new List<SObject>();
        for (SObject iterationObject : accountPlans) {
            if (iterationObject.getSObjects('Histories') != null) {
                histories.addAll((List<SObject>) iterationObject.getSObjects('Histories'));
            }
        }

        History tempHistory;
        for (SObject historyObject : histories) {
            tempHistory = new History(historyObject);
            System.assertNotEquals(null, tempHistory);
        }
    }
}