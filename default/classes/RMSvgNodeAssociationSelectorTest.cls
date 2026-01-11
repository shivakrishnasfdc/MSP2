@isTest
private class RMSvgNodeAssociationSelectorTest {
    @isTest
    static void newInstanceTest() {
        RMSvgNodeAssociationSelector selector = RMSvgNodeAssociationSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        RM_Svg__c svg1 = TestDataFactory.createRMSvg('test1');
        RM_Svg__c svg2 = TestDataFactory.createRMSvg('test2');

        RM_Svg_Node_Association__c a = TestDataFactory.createRMSvgNodeAssociation('key1', svg1);
        RM_Svg_Node_Association__c b = TestDataFactory.createRMSvgNodeAssociation('key1', svg2);
        TestDataFactory.createRMSvgNodeAssociation('key2', svg1);

        Test.startTest();
        List<RM_Svg_Node_Association__c> queriedResult = new RMSvgNodeAssociationSelector()
            .selectById(new Set<Id>{ a.Id, b.Id });
        Test.stopTest();

        // Then the admin user should get 2 back
        System.assertEquals(2, queriedResult.size());
    }

    @isTest
    static void selectByKeysGlobalTest() {
        RM_Svg__c svg1 = TestDataFactory.createRMSvg('test1');
        RM_Svg__c svg2 = TestDataFactory.createRMSvg('test2');

        TestDataFactory.createRMSvgNodeAssociation('key1', svg1);
        TestDataFactory.createRMSvgNodeAssociation('key1', svg2);
        TestDataFactory.createRMSvgNodeAssociation('key2', svg1);
        TestDataFactory.createRMSvgNodeAssociation('key3', svg1);

        Test.startTest();
        List<RM_Svg_Node_Association__c> queriedResult = new RMSvgNodeAssociationSelector()
            .selectByKeysGlobal(new Set<String>{ 'key1', 'key2' });
        Test.stopTest();

        // Then the admin user should get back all three
        System.assertEquals(3, queriedResult.size());
    }

    @isTest
    static void selectByKeysGlobalForSvgsTest() {
        RM_Svg__c svg1 = TestDataFactory.createRMSvg('test1');
        RM_Svg__c svg2 = TestDataFactory.createRMSvg('test2');

        TestDataFactory.createRMSvgNodeAssociation('key1', svg1);
        TestDataFactory.createRMSvgNodeAssociation('key1', svg2);
        TestDataFactory.createRMSvgNodeAssociation('key2', svg1);
        TestDataFactory.createRMSvgNodeAssociation('key3', svg1);

        Test.startTest();
        List<RM_Svg_Node_Association__c> queriedResult = new RMSvgNodeAssociationSelector()
            .selectByKeysGlobalForSvgs(new List<RM_Svg__c>{ svg1 }, new Set<String>{ 'key1', 'key2' });
        Test.stopTest();

        // Then the admin user should get 2 back
        System.assertEquals(2, queriedResult.size());
    }

    // Test when relationship map id is null
    @isTest
    static void selectByKeysLocalTest() {
        RM_Svg__c svg1 = TestDataFactory.createRMSvg('test1');
        RM_Svg__c svg2 = TestDataFactory.createRMSvg('test2');

        TestDataFactory.createRMSvgNodeAssociation('key1', svg1);
        TestDataFactory.createRMSvgNodeAssociation('key1', svg2);
        TestDataFactory.createRMSvgNodeAssociation('key2', svg1);
        TestDataFactory.createRMSvgNodeAssociation('key3', svg1);

        Test.startTest();
        List<RM_Svg_Node_Association__c> queriedResult = new RMSvgNodeAssociationSelector()
            .selectByKeysLocal(null, new Set<String>{ 'key1', 'key2' });
        Test.stopTest();

        // Then the admin user should get 0 back
        System.assertEquals(0, queriedResult.size());
    }

    // Test when relationship map id is not null
    @isTest
    static void selectByKeysLocalTest2() {
        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('my map');
        RM_Svg__c svg1 = TestDataFactory.createRMSvg('test1');
        RM_Svg__c svg2 = TestDataFactory.createRMSvg('test2');

        TestDataFactory.createRMSvgNodeAssociation('key1', svg1, rm.Id, null);
        TestDataFactory.createRMSvgNodeAssociation('key1', svg2);
        TestDataFactory.createRMSvgNodeAssociation('key2', svg1, rm.Id, null);
        TestDataFactory.createRMSvgNodeAssociation('key3', svg1);

        Test.startTest();
        List<RM_Svg_Node_Association__c> queriedResult = new RMSvgNodeAssociationSelector()
            .selectByKeysLocal(rm.Id, new Set<String>{ 'key1', 'key2' });
        Test.stopTest();

        // Then the admin user should get 2 back
        System.assertEquals(2, queriedResult.size());
    }

    // Test when account plan id is not null
    @isTest
    static void selectByKeysLocalTest3() {
        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;

        Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan('Account Plan 1', testAccount);

        RM_Svg__c svg1 = TestDataFactory.createRMSvg('test1');
        RM_Svg__c svg2 = TestDataFactory.createRMSvg('test2');

        TestDataFactory.createRMSvgNodeAssociation('key1', svg1, null, accountPlan1.Id);
        TestDataFactory.createRMSvgNodeAssociation('key1', svg2);
        TestDataFactory.createRMSvgNodeAssociation('key2', svg1, null, accountPlan1.Id);
        TestDataFactory.createRMSvgNodeAssociation('key3', svg1);

        Test.startTest();
        List<RM_Svg_Node_Association__c> queriedResult = new RMSvgNodeAssociationSelector()
            .selectByKeysLocal(accountPlan1.Id, new Set<String>{ 'key1', 'key2' });
        Test.stopTest();

        // Then the admin user should get 2 back
        System.assertEquals(2, queriedResult.size());
    }

    // Test when relationship map id is not null
    @isTest
    static void selectByKeysLocalForSvgsTest() {
        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('my map');
        RM_Svg__c svg1 = TestDataFactory.createRMSvg('test1');
        RM_Svg__c svg2 = TestDataFactory.createRMSvg('test2');

        RM_Svg_Node_Association__c a = TestDataFactory.createRMSvgNodeAssociation('key1', svg1, rm.Id, null);
        TestDataFactory.createRMSvgNodeAssociation('key1', svg2);
        TestDataFactory.createRMSvgNodeAssociation('key2', svg2, rm.Id, null);
        TestDataFactory.createRMSvgNodeAssociation('key3', svg1);

        Test.startTest();
        List<RM_Svg_Node_Association__c> queriedResult = new RMSvgNodeAssociationSelector()
            .selectByKeysLocalForSvgs(rm.Id, new List<RM_Svg__c>{ svg1 }, new Set<String>{ 'key1', 'key2' });
        Test.stopTest();

        // Then the admin user should get 1 back
        System.assertEquals(1, queriedResult.size());
        System.assertEquals(a.Id, queriedResult[0].Id);
    }

    @isTest
    static void selectByKeysLocalForSvgsNullMapTest() {
        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('my map');
        RM_Svg__c svg1 = TestDataFactory.createRMSvg('test1');
        RM_Svg__c svg2 = TestDataFactory.createRMSvg('test2');

        TestDataFactory.createRMSvgNodeAssociation('key1', svg2);
        TestDataFactory.createRMSvgNodeAssociation('key2', svg2, rm.Id, null);
        TestDataFactory.createRMSvgNodeAssociation('key3', svg1);

        Id input = null;

        Test.startTest();
        List<RM_Svg_Node_Association__c> queriedResult = new RMSvgNodeAssociationSelector()
            .selectByKeysLocalForSvgs(input, new List<RM_Svg__c>{ svg1 }, new Set<String>{ 'key1', 'key2' });
        Test.stopTest();

        // Then the admin user should get 1 back
        System.assertEquals(0, queriedResult.size());
    }

    @isTest
    static void selectByKeysGlobalWithAutomationTest() {
        RM_Svg__c svg1 = TestDataFactory.createRMSvg('test1');
        RM_Svg__c svg2 = TestDataFactory.createRMSvg('test2');
        RM_Svg__c svg3 = TestDataFactory.createRMSvg('test2');

        svg1.For_Automation_Use_Only__c = true;
        update svg1;

        svg3.For_Automation_Use_Only__c = true;
        update svg3;

        TestDataFactory.createRMSvgNodeAssociation('key1', svg1);
        TestDataFactory.createRMSvgNodeAssociation('key1', svg2);
        TestDataFactory.createRMSvgNodeAssociation('key2', svg1);
        TestDataFactory.createRMSvgNodeAssociation('key3', svg1);
        TestDataFactory.createRMSvgNodeAssociation('key1', svg3);

        Test.startTest();
        List<RM_Svg_Node_Association__c> queriedResult1 = new RMSvgNodeAssociationSelector()
            .selectByKeysGlobalWithAutomation(new Set<String>{ 'key1', 'key2' }, true);

        List<RM_Svg_Node_Association__c> queriedResult2 = new RMSvgNodeAssociationSelector()
            .selectByKeysGlobalWithAutomation(new Set<String>{ 'key1', 'key2' }, false);
        Test.stopTest();

        System.assertEquals(3, queriedResult1.size());
        System.assertEquals(1, queriedResult2.size());
    }

    // Test when relationship map id is not null with automation
    @isTest
    static void selectByKeysLocalWithAutomationTest() {
        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('my map');
        RM_Svg__c svg1 = TestDataFactory.createRMSvg('test1');
        RM_Svg__c svg2 = TestDataFactory.createRMSvg('test2');
        RM_Svg__c svg3 = TestDataFactory.createRMSvg('test3');

        svg1.For_Automation_Use_Only__c = true;
        update svg1;

        TestDataFactory.createRMSvgNodeAssociation('key1', svg1, rm.Id, null);
        TestDataFactory.createRMSvgNodeAssociation('key1', svg2);
        TestDataFactory.createRMSvgNodeAssociation('key2', svg1, rm.Id, null);
        TestDataFactory.createRMSvgNodeAssociation('key3', svg1);
        TestDataFactory.createRMSvgNodeAssociation('key4', svg3, rm.Id, null);

        Test.startTest();
        List<RM_Svg_Node_Association__c> queriedResult = new RMSvgNodeAssociationSelector()
            .selectByKeysLocalWithAutomation(rm.Id, new Set<String>{ 'key1', 'key2', 'key4' }, true);
        Test.stopTest();

        // Then the admin user should get 2 back
        System.assertEquals(2, queriedResult.size());
    }

    // Test when relationship map id is not null with automation
    @isTest
    static void selectByKeysLocalWithAutomationNullTest() {
        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('my map');
        RM_Svg__c svg1 = TestDataFactory.createRMSvg('test1');
        RM_Svg__c svg2 = TestDataFactory.createRMSvg('test2');
        RM_Svg__c svg3 = TestDataFactory.createRMSvg('test3');

        svg1.For_Automation_Use_Only__c = true;
        update svg1;

        TestDataFactory.createRMSvgNodeAssociation('key1', svg1, rm.Id, null);
        TestDataFactory.createRMSvgNodeAssociation('key1', svg2);
        TestDataFactory.createRMSvgNodeAssociation('key2', svg1, rm.Id, null);
        TestDataFactory.createRMSvgNodeAssociation('key3', svg1);
        TestDataFactory.createRMSvgNodeAssociation('key4', svg3, rm.Id, null);

        Id input = null;

        Test.startTest();
        List<RM_Svg_Node_Association__c> queriedResult = new RMSvgNodeAssociationSelector()
            .selectByKeysLocalWithAutomation(input, new Set<String>{ 'key1', 'key2', 'key4' }, true);
        Test.stopTest();

        // Then the admin user should get 2 back
        System.assertEquals(0, queriedResult.size());
    }
}