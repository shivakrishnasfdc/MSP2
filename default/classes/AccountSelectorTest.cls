@isTest
private class AccountSelectorTest {
    @testSetup
    static void setup() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        for (Integer i = 0; i < 2; i++) {
            testAccts.add(new Account(Name = 'TestAcct' + i));
        }
        insert testAccts;
    }

    @isTest
    static void selectByIdTest() {
        // Given
        Set<Id> givenAccountIds = new Map<Id, Account>([SELECT Id FROM Account]).keySet();

        // When
        Test.startTest();

        List<Account> accounts = new AccountSelector().selectById(givenAccountIds);

        Test.stopTest();

        // Then
        Set<Id> accountIds = new Map<Id, Account>(accounts).keyset();

        System.assertEquals(2, accounts.size(), 'Expected 2 Account records.');

        for (Id accountId : givenAccountIds) {
            System.assertEquals(true, accountIds.contains(accountId));
        }
    }
}