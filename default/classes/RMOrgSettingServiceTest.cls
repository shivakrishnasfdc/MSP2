@isTest
private class RMOrgSettingServiceTest {
    @testSetup
    static void testSetup() {
        testMockData md = new testMockData();
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;
        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMapId)).thenReturn(false);
        md.mocks.stopStubbing();

        // Need to do this first so it creates the org setting.  Otherwise, test will create and then compare will be from teh query
        RMOrgSettingService.getRMOrgSetting(md.mockRelationshipMapId);
    }

    @isTest
    static void getRMOrgSettingTest() {
        testMockData md = new testMockData();
        RMOrgSettingSelector mockRMOrgSettingSelector = md.mockRMOrgSettingSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMapId)).thenReturn(false);
        md.mocks.when(mockRMOrgSettingSelector.selectByType('rm'))
            .thenReturn(new List<RM_Org_Setting__c>{ md.mockRMOrgSettingForRM });
        md.mocks.stopStubbing();

        RM_Org_Setting__c setting = RMOrgSettingService.getRMOrgSetting(md.mockRelationshipMapId);

        ((RMOrgSettingSelector) md.mocks.verify(mockRMOrgSettingSelector, 1)).selectByType('rm');

        System.assertNotEquals(null, setting);
    }

    @isTest
    static void setRMOrgSettingNewTest() {
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        md.mockRMOrgSettingForRM.id = null;

        RMOrgSettingService.setRMOrgSetting(md.mockRMOrgSettingForRM);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew(md.mockRMOrgSettingForRM);
        System.assert(true, 'Assert from mock verify');
    }

    @isTest
    static void setRMOrgSettingDirtyTest() {
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        RMOrgSettingService.setRMOrgSetting(md.mockRMOrgSettingForRM);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(md.mockRMOrgSettingForRM);
        System.assert(true, 'Assert from mock verify');
    }

    @isTest
    static void setAdvancedOrgSettingTest() {
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMapId)).thenReturn(false);
        md.mocks.stopStubbing();

        RM_Org_Setting__c input = RMOrgSettingService.getRMOrgSetting(md.mockRelationshipMapId);
        input.Prolifiq_Extended_Tools_URL__c = 'https://example.com';
        RMOrgSettingService.setAdvancedOrgSetting(input);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(input);
        System.assert(true, 'Assert from mock verify');
    }

    @isTest
    static void setDefaultChartSettingTest() {
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMapId)).thenReturn(false);
        md.mocks.stopStubbing();

        RM_Org_Setting__c input = RMOrgSettingService.getRMOrgSetting(md.mockRelationshipMapId);
        input.Prolifiq_Extended_Tools_URL__c = 'https://example.com';
        RMOrgSettingService.setDefaultChartSetting(input);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(input);
        System.assert(true, 'Assert from mock verify');
    }

    @isTest
    static void setTabsSettingNullTest() {
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMapId)).thenReturn(false);
        md.mocks.stopStubbing();

        RM_Org_Setting__c result = RMOrgSettingService.getRMOrgSetting(md.mockRelationshipMapId);

        RMOrgSettingService.setTabsSetting('rm', null, null, null, null, null, null, null, null, null, null);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(result);
        System.assert(true, 'Assert from mock verify');
    }

    @isTest
    static void setTabsSettingTest() {
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMapId)).thenReturn(false);
        md.mocks.stopStubbing();

        RM_Org_Setting__c result = RMOrgSettingService.getRMOrgSetting(md.mockRelationshipMapId);

        RMOrgSettingService.setTabsSetting('rm', true, false, true, true, true, true, false, true, true, true);

        result.Lead_Tab__c = true;
        result.User_Tab__c = false;
        result.Create_New_Contact__c = true;
        result.Show_Auto_Manual_Toggle__c = true;
        result.Enable_Contact_Context_Menu__c = true;
        result.Enable_Map_Member_Context_Menu__c = true;
        result.Enable_Omni_Viewer_Context_Menu__c = false;
        result.Enable_Group_Selection_Context_Menu__c = true;
        result.Show_Chart_Settings__c = true;
        result.Show_Clone_Relationship_Map__c = true;

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(result);
        System.assert(true, 'Assert from mock verify');
    }
}