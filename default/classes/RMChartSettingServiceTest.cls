@isTest
private class RMChartSettingServiceTest {
    @isTest
    static void getRelationshipMapSettingForObjectAccountPlanTest() {
        testMockData md = new testMockData();
        RMChartSettingSelector mockRMChartSettingSelector = md.mockRMChartSettingSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test

        md.mocks.startStubbing();
        md.mocks.when(mockRMChartSettingSelector.selectByObjectId(new Set<Id>{ md.mockAccountPlanId }))
            .thenReturn(new List<RM_Chart_Setting__c>{ md.mockRMChartSettingForAccountPlan });
        md.mocks.stopStubbing();

        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(md.mockAccountPlanId);

        System.assertEquals(md.mockRMChartSettingForAccountPlanId, setting.Id);
    }

    @isTest
    static void getRelationshipMapSettingForObjectRelationshipMapTest() {
        testMockData md = new testMockData();
        RMChartSettingSelector mockRMChartSettingSelector = md.mockRMChartSettingSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test

        md.mocks.startStubbing();
        md.mocks.when(mockRMChartSettingSelector.selectByObjectId(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<RM_Chart_Setting__c>{ md.mockRMChartSettingForRelationshipMap });
        md.mocks.stopStubbing();

        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(
            md.mockRelationshipMapId
        );

        System.assertEquals(md.mockRMChartSettingForRelationshipMapId, setting.Id);
    }

    @isTest
    static void getRelationshipMapSettingForObjectNewSettingTest() {
        testMockData md = new testMockData();
        RMChartSettingSelector mockRMChartSettingSelector = md.mockRMChartSettingSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        md.mocks.startStubbing();
        md.mocks.when(
                mockRMChartSettingSelector.selectByObjectId(new Set<Id>{ md.mockRMChartSettingForRelationshipMapId })
            )
            .thenReturn(new List<RM_Chart_Setting__c>());
        md.mocks.stopStubbing();

        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(
            md.mockRMChartSettingForRelationshipMapId
        );

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0))
            .registerNew(fflib_Match.sObjectOfType(RM_Chart_Setting__c.SObjectType));
        System.assertEquals(
            RM_Chart_Setting__c.Show_Parents__c.getDescribe().getDefaultValue(),
            setting.Show_Parents__c
        );
        System.assertEquals(
            RM_Chart_Setting__c.Show_Overview__c.getDescribe().getDefaultValue(),
            setting.Show_Overview__c
        );
    }

    @isTest
    static void getRelationshipMapSettingForObjectCreateIfNeededNewSettingTest() {
        testMockData md = new testMockData();
        RMChartSettingSelector mockRMChartSettingSelector = md.mockRMChartSettingSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        md.mocks.startStubbing();
        md.mocks.when(
                mockRMChartSettingSelector.selectByObjectId(new Set<Id>{ md.mockRMChartSettingForRelationshipMapId })
            )
            .thenReturn(new List<RM_Chart_Setting__c>());
        md.mocks.stopStubbing();

        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObjectCreateIfNeeded(
            md.mockRMChartSettingForRelationshipMapId
        );

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew(fflib_Match.sObjectOfType(RM_Chart_Setting__c.SObjectType));
        System.assertEquals(
            RM_Chart_Setting__c.Show_Parents__c.getDescribe().getDefaultValue(),
            setting.Show_Parents__c
        );
        System.assertEquals(
            RM_Chart_Setting__c.Show_Overview__c.getDescribe().getDefaultValue(),
            setting.Show_Overview__c
        );
    }

    @isTest
    static void getRelationshipMapSettingForObjectNewSettingFromOrgDefaultTest() {
        testMockData md = new testMockData();
        RMChartSettingSelector mockRMChartSettingSelector = md.mockRMChartSettingSelector;
        RMOrgSettingServiceImpl mockRMOrgSettingService = md.mockRMOrgSettingService;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        md.mockRMOrgSettingForRM.Auto_Layout__c = false;
        md.mockRMOrgSettingForRM.Card_Style__c = 'Compact';
        md.mockRMOrgSettingForRM.Enable_Drag_Select__c = true;
        md.mockRMOrgSettingForRM.Display_Style__c = 'Leaf_Vertical';
        md.mockRMOrgSettingForRM.Relationship_Line_Opacity__c = 23;
        md.mockRMOrgSettingForRM.Reports_To_Line_Opacity__c = 46;
        md.mockRMOrgSettingForRM.Show_Empty_Fields__c = true;
        md.mockRMOrgSettingForRM.Show_Overview__c = true;
        md.mockRMOrgSettingForRM.Show_Parents__c = true;
        md.mockRMOrgSettingForRM.Is_Group_Global_Scope__c = true;
        md.mockRMOrgSettingForRM.Is_Badge_Global_Scope__c = true;
        md.mockRMOrgSettingForRM.Is_Relationship_Line_Global_Scope__c = true;
        md.mockRMOrgSettingForRM.Is_Influence_Support_Global_Scope__c = true;
        md.mockRMOrgSettingForRM.Is_Reports_To_Global_Scope__c = true;

        md.mocks.startStubbing();
        md.mocks.when(mockRMOrgSettingService.getRMOrgSetting(md.mockRelationshipMapId))
            .thenReturn(md.mockRMOrgSettingForRM);
        md.mocks.when(mockRMChartSettingSelector.selectByObjectId(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<RM_Chart_Setting__c>());
        md.mocks.stopStubbing();

        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(
            md.mockRelationshipMapId
        );

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0))
            .registerNew(fflib_Match.sObjectOfType(RM_Chart_Setting__c.SObjectType));

        System.assertEquals(md.mockRMOrgSettingForRM.Auto_Layout__c, setting.Auto_Layout__c);
        System.assertEquals(md.mockRMOrgSettingForRM.Card_Style__c, setting.Card_Style__c);
        System.assertEquals(md.mockRMOrgSettingForRM.Enable_Drag_Select__c, setting.Enable_Drag_Select__c);
        System.assertEquals(md.mockRMOrgSettingForRM.Display_Style__c, setting.Display_Style__c);
        System.assertEquals(
            md.mockRMOrgSettingForRM.Relationship_Line_Opacity__c,
            setting.Relationship_Line_Opacity__c
        );
        System.assertEquals(md.mockRMOrgSettingForRM.Reports_To_Line_Opacity__c, setting.Reports_To_Line_Opacity__c);
        System.assertEquals(md.mockRMOrgSettingForRM.Show_Empty_Fields__c, setting.Show_Empty_Fields__c);
        System.assertEquals(md.mockRMOrgSettingForRM.Show_Overview__c, setting.Show_Overview__c);
        System.assertEquals(md.mockRMOrgSettingForRM.Show_Parents__c, setting.Show_Parents__c);
        System.assertEquals(md.mockRMOrgSettingForRM.Is_Group_Global_Scope__c, setting.Is_Group_Global_Scope__c);
        System.assertEquals(md.mockRMOrgSettingForRM.Is_Badge_Global_Scope__c, setting.Is_Badge_Global_Scope__c);
        System.assertEquals(
            md.mockRMOrgSettingForRM.Is_Influence_Support_Global_Scope__c,
            setting.Is_Influence_Support_Global_Scope__c
        );
        System.assertEquals(
            md.mockRMOrgSettingForRM.Is_Relationship_Line_Global_Scope__c,
            setting.Is_Relationship_Line_Global_Scope__c
        );
        System.assertEquals(
            md.mockRMOrgSettingForRM.Is_Reports_To_Global_Scope__c,
            setting.Is_Reports_To_Global_Scope__c
        );
    }
}