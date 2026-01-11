@isTest
private class RMOrgSettingSelectorTest {
    @isTest
    static void newInstanceTest() {
        RMOrgSettingSelector selector = RMOrgSettingSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        RM_Org_Setting__c setting1 = TestDataFactory.createRMOrgSetting('rm', true, 'Detail', 'Horizontal');
        RM_Org_Setting__c setting2 = TestDataFactory.createRMOrgSetting(
            'keystakeholder',
            false,
            'Compact',
            'Leaf_Vertical'
        );

        Test.startTest();
        List<RM_Org_Setting__c> queriedResult = new RMOrgSettingSelector()
            .selectById(new Set<Id>{ setting1.Id, setting2.Id });
        Test.stopTest();

        // Then the admin user should get back all three account plans
        System.assertEquals(2, queriedResult.size());
    }

    @isTest
    static void selectByTypeTest() {
        TestDataFactory.createRMOrgSetting('rm', true, 'Detail', 'Horizontal');
        TestDataFactory.createRMOrgSetting('rm', false, 'Compact', 'Leaf_Vertical');
        TestDataFactory.createRMOrgSetting('keystakeholder', false, 'Compact', 'Leaf_Vertical');

        Test.startTest();
        List<RM_Org_Setting__c> queriedResult = new RMOrgSettingSelector().selectByType('keystakeholder');
        List<RM_Org_Setting__c> queriedResult2 = new RMOrgSettingSelector().selectByType('rm');
        Test.stopTest();

        // Then the admin user should get back all three account plans
        System.assertEquals(1, queriedResult.size());
        System.assertEquals(2, queriedResult2.size());
    }
}