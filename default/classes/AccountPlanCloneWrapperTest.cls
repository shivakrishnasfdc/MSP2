@isTest
private with sharing class AccountPlanCloneWrapperTest {
    @isTest
    private static void initializationTest() {
        AccountPlanCloneWrapper basic = new AccountPlanCloneWrapper();
        System.assertNotEquals(null, basic, 'A wrapper was successfully created');

        Id planId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        String name = 'The Account Plan Name';
        Id ownerId = fflib_IDGenerator.generate(User.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<String> relationshipsToClone = new List<String>{ 'pqcrush__Key_Date__r' };
        AccountPlanCloneWrapper full = new AccountPlanCloneWrapper(
            planId,
            name,
            ownerId,
            accountId,
            relationshipsToClone
        );
        System.assertNotEquals(null, full, 'A detailed wrapper was successfully created');
        System.assertEquals(planId, full.planId, 'The plan Id was assigned');
        System.assertEquals(name, full.newName, 'The new name was assigned');
        System.assertEquals(ownerId, full.newOwnerId, 'The new owner was assigned');
        System.assertEquals(accountId, full.newAccountId, 'The new account Id was assigned');
        System.assertEquals(relationshipsToClone, full.relationships, 'The relationships to clone were assigned');
    }
    @isTest
    private static void validationCheckTest() {
        Id planId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        String name = 'The Account Plan Name';
        Id ownerId = fflib_IDGenerator.generate(User.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<String> relationshipsToClone = new List<String>{ 'pqcrush__Key_Date__r' };
        AccountPlanCloneWrapper wrapper = new AccountPlanCloneWrapper(
            null,
            name,
            ownerId,
            accountId,
            relationshipsToClone
        );
        try {
            wrapper.validationCheck();
            System.assert(false, 'Expected no account plan id exception');
        } catch (Exception e) {
            System.assertEquals(
                'No account plan information passed when trying to clone an account plan',
                e.getMessage()
            );
        }
        wrapper = new AccountPlanCloneWrapper(planId, name, ownerId, null, relationshipsToClone);
        try {
            wrapper.validationCheck();
            System.assert(false, 'Expected no account id exception');
        } catch (Exception e) {
            System.assertEquals('No account information passed when trying to clone an account plan', e.getMessage());
        }
    }
}