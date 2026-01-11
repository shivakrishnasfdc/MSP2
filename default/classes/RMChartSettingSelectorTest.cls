@isTest
private class RMChartSettingSelectorTest {
    @isTest
    static void newInstanceTest() {
        RMChartSettingSelector selector = RMChartSettingSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        RM_Chart_Setting__c setting1 = TestDataFactory.createRMChartSetting('desc1', true);
        RM_Chart_Setting__c setting2 = TestDataFactory.createRMChartSetting('desc2', true);

        Test.startTest();
        List<RM_Chart_Setting__c> queriedResult = new RMChartSettingSelector()
            .selectById(new Set<Id>{ setting1.Id, setting2.Id });
        Test.stopTest();

        // Then the admin user should get back all three account plans
        System.assertEquals(2, queriedResult.size());
    }

    @isTest
    static void selectByObjectIdTest() {
        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;
        Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan('Account Plan 1', testAccount);
        Relationship_Map__c relMap = TestDataFactory.createRelationshipMap('mapname');

        TestDataFactory.createRMChartSetting('desc1', true, accountPlan1.Id, null);
        TestDataFactory.createRMChartSetting('desc2', true, null, relMap.Id);

        Test.startTest();
        List<RM_Chart_Setting__c> queriedResult = new RMChartSettingSelector()
            .selectByObjectId(new Set<Id>{ accountPlan1.Id, relMap.Id });
        Test.stopTest();

        // Then the admin user should get back all three account plans
        System.assertEquals(2, queriedResult.size());
    }
}