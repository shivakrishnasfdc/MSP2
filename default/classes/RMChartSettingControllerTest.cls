@isTest
private class RMChartSettingControllerTest {
    @isTest
    static void getRelationshipMapAccessRecordForObjectTest() {
        TestMockData md = new TestMockData();
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        UserRecordAccessSelector mockUserRecordAccessSelector = md.mockUserRecordAccessSelector;

        md.mocks.startStubbing();
        md.mocks.when(
                mockRMChartSettingService.getRelationshipMapSettingForObjectCreateIfNeeded(md.mockRelationshipMapId)
            )
            .thenReturn(md.mockRMChartSettingForRelationshipMap);
        md.mocks.when(
                mockUserRecordAccessSelector.selectByRecordId(new Set<Id>{ md.mockRMChartSettingForRelationshipMapId })
            )
            .thenReturn(new List<UserRecordAccess>{ new UserRecordAccess() });
        md.mocks.stopStubbing();

        UserRecordAccess ura = RMChartSettingController.getRelationshipMapAccessRecordForObject(
            md.mockRelationshipMapId
        );

        System.assertNotEquals(null, ura);
    }

    @isTest
    static void getRelationshipMapSettingForObjectTest() {
        TestMockData md = new TestMockData();
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        RMOrgSettingServiceImpl mockRMOrgSettingService = md.mockRMOrgSettingService;
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapService.hasAccountPlanSetting(md.mockAccountPlanId)).thenReturn(false);
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockAccountPlanId))
            .thenReturn(md.mockRMChartSettingForAccountPlan);
        md.mocks.when(mockRMOrgSettingService.getRMOrgSetting(md.mockAccountPlanId))
            .thenReturn(md.mockRMOrgSettingForAccountPlan);
        md.mocks.stopStubbing();

        RMChartSettingController.getRelationshipMapSettingForObject(md.mockAccountPlanId);

        ((RMChartSettingServiceImpl) md.mocks.verify(mockRMChartSettingService, 1))
            .getRelationshipMapSettingForObject(md.mockAccountPlanId);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    static void updateAutoLayoutTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;

        md.mocks.startStubbing();
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObjectCreateIfNeeded(md.mockAccountPlanId))
            .thenReturn(md.mockRMChartSettingForAccountPlan);
        md.mocks.stopStubbing();

        RMChartSettingController.updateAutoLayout(md.mockAccountPlanId, true);

        md.mockRMChartSettingForAccountPlan.Auto_Layout__c = true;

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(md.mockRMChartSettingForAccountPlan);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    static void updateCardStyleTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;

        md.mocks.startStubbing();
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObjectCreateIfNeeded(md.mockAccountPlanId))
            .thenReturn(md.mockRMChartSettingForAccountPlan);
        md.mocks.stopStubbing();

        RMChartSettingController.updateCardStyle(md.mockAccountPlanId, 'Detail');

        md.mockRMChartSettingForAccountPlan.Card_Style__c = 'Detail';

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(md.mockRMChartSettingForAccountPlan);
        System.assert(true, 'assert done by mock verify');
    }
}