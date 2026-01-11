@isTest
private class RMAnchorSelectorTest {
    @isTest
    static void newInstanceTest() {
        RMAnchorSelector selector = RMAnchorSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByObjectIdTest() {
        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;
        Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan('Account Plan 1', testAccount);
        Relationship_Map__c relMap = TestDataFactory.createRelationshipMap('mapname');

        TestDataFactory.createRMAnchor('from1', 'to1', accountPlan1.Id, null);
        TestDataFactory.createRMAnchor('from2', 'to2', null, relMap.Id);

        Test.startTest();
        List<RM_Anchor__c> queriedResult = new RMAnchorSelector()
            .selectByObjectId(new Set<Id>{ accountPlan1.Id, relMap.Id });
        Test.stopTest();

        // Should get 2 anchors back
        System.assertEquals(2, queriedResult.size());
    }

    @isTest
    static void selectByObjectIdAndFromFieldTest1() {
        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;
        Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan('Account Plan 1', testAccount);
        TestDataFactory.createRMAnchor('from1', 'to1', accountPlan1.Id, null);

        Test.startTest();
        List<RM_Anchor__c> queriedResult = new RMAnchorSelector()
            .selectByObjectIdAndFromField(accountPlan1.Id, new Set<String>{ 'from1' });
        Test.stopTest();

        // Should get 1 anchor back
        System.assertEquals(1, queriedResult.size());
    }

    @isTest
    static void selectByObjectIdAndFromFieldTest2() {
        Relationship_Map__c relMap = TestDataFactory.createRelationshipMap('mapname');
        TestDataFactory.createRMAnchor('from2', 'to2', null, relMap.Id);

        Test.startTest();
        List<RM_Anchor__c> queriedResult = new RMAnchorSelector()
            .selectByObjectIdAndFromField(relMap.Id, new Set<String>{ 'from2' });
        Test.stopTest();

        // // Should get 1 anchor back
        System.assertEquals(1, queriedResult.size());
    }
}