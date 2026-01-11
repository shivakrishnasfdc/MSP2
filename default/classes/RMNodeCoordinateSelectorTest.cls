@isTest
private class RMNodeCoordinateSelectorTest {
    @isTest
    static void newInstanceTest() {
        RMNodeCoordinateSelector selector = RMNodeCoordinateSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        RM_Node_Coordinate__c coordinate1 = TestDataFactory.createRMNodeCoordinate(
            'key1',
            'tempid1',
            (Double) 111.11,
            (Double) 111.111,
            null,
            null
        );
        RM_Node_Coordinate__c coordinate2 = TestDataFactory.createRMNodeCoordinate(
            'key2',
            'tempid2',
            (Double) 222.22,
            (Double) 222.22,
            null,
            null
        );

        Test.startTest();
        List<RM_Node_Coordinate__c> queriedResult = new RMNodeCoordinateSelector()
            .selectById(new Set<Id>{ coordinate1.Id, coordinate2.Id });
        Test.stopTest();

        System.assertEquals(2, queriedResult.size());
    }

    @isTest
    static void selectByObjectIdTest1() {
        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;
        Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan('Account Plan 1', testAccount);

        TestDataFactory.createRMNodeCoordinate(
            'key1',
            'tempid1',
            (Double) 111.11,
            (Double) 111.111,
            accountPlan1.Id,
            null
        );
        Test.startTest();
        List<RM_Node_Coordinate__c> queriedResult = new RMNodeCoordinateSelector().selectByObjectId(accountPlan1.Id);
        Test.stopTest();

        System.assertEquals(1, queriedResult.size());
    }

    @isTest
    static void selectByObjectIdTest2() {
        Relationship_Map__c relMap = TestDataFactory.createRelationshipMap('mapname');

        TestDataFactory.createRMNodeCoordinate('key2', 'tempid2', (Double) 222.22, (Double) 222.22, null, relMap.Id);

        Test.startTest();
        List<RM_Node_Coordinate__c> queriedResult = new RMNodeCoordinateSelector().selectByObjectId(relMap.Id);
        Test.stopTest();

        System.assertEquals(1, queriedResult.size());
    }

    @isTest
    static void selectByObjectIdAndKeysTest() {
        Relationship_Map__c relMap = TestDataFactory.createRelationshipMap('mapname');

        TestDataFactory.createRMNodeCoordinate('key1', 'tempid1', (Double) 111.11, (Double) 111.11, null, relMap.Id);
        TestDataFactory.createRMNodeCoordinate('key2', 'tempid2', (Double) 222.22, (Double) 222.22, null, relMap.Id);
        TestDataFactory.createRMNodeCoordinate('key3', 'tempid3', (Double) 333.33, (Double) 333.33, null, relMap.Id);
        TestDataFactory.createRMNodeCoordinate('key4', 'tempid4', (Double) 444.44, (Double) 444.44, null, null);

        Test.startTest();
        List<RM_Node_Coordinate__c> queriedResult = new RMNodeCoordinateSelector()
            .selectByObjectIdAndKeys(relMap.Id, new Set<String>{ 'key1', 'key2' });
        Test.stopTest();

        System.assertEquals(2, queriedResult.size());
    }
}