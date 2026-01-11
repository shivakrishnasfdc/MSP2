@isTest
private class RMChartSettingsWrapperTest {
    @isTest
    static void basicInitTest() {
        RMChartSettingsWrapper wrapper = new RMChartSettingsWrapper();
        System.assertEquals(false, wrapper.showOverview);
        System.assertEquals('Detail', wrapper.cardStyle);
        System.assertEquals('Horizontal', wrapper.displayStyle);
        System.assertEquals(false, wrapper.showParent);
        System.assertEquals(false, wrapper.enableDragSelect);
        System.assertEquals(true, wrapper.autoLayout);
        System.assertEquals(false, wrapper.showEmptyFields);
        System.assertEquals(1, wrapper.relationshipLineOpacity);
        System.assertEquals(1, wrapper.reportsToLineOpacity);
        System.assertEquals(true, wrapper.createNewContact);
        System.assertEquals(false, wrapper.isInfluenceSupportGlobal);
        System.assertEquals(true, wrapper.isCloneEnabled);
        System.assertEquals(true, wrapper.isSettingsEnabled);
    }

    @isTest
    static void initNullObjectsTest() {
        RMChartSettingsWrapper wrapper = new RMChartSettingsWrapper(null, null);
        System.assertEquals(false, wrapper.showOverview);
        System.assertEquals('Detail', wrapper.cardStyle);
        System.assertEquals('Horizontal', wrapper.displayStyle);
        System.assertEquals(false, wrapper.showParent);
        System.assertEquals(false, wrapper.enableDragSelect);
        System.assertEquals(true, wrapper.autoLayout);
        System.assertEquals(false, wrapper.showEmptyFields);
        System.assertEquals(1, wrapper.relationshipLineOpacity);
        System.assertEquals(1, wrapper.reportsToLineOpacity);
        System.assertEquals(true, wrapper.createNewContact);
        System.assertEquals(false, wrapper.isInfluenceSupportGlobal);
        System.assertEquals(true, wrapper.isCloneEnabled);
        System.assertEquals(true, wrapper.isSettingsEnabled);
    }

    @isTest
    static void initEmptyObjectsTest() {
        RMChartSettingsWrapper wrapper = new RMChartSettingsWrapper(new RM_Chart_Setting__c(), new RM_Org_Setting__c());
        System.assertEquals(false, wrapper.showOverview);
        System.assertEquals('Detail', wrapper.cardStyle);
        System.assertEquals('Horizontal', wrapper.displayStyle);
        System.assertEquals(false, wrapper.showParent);
        System.assertEquals(false, wrapper.enableDragSelect);
        System.assertEquals(false, wrapper.autoLayout); //Object initializes with false not null
        System.assertEquals(false, wrapper.showEmptyFields);
        System.assertEquals(1, wrapper.relationshipLineOpacity);
        System.assertEquals(1, wrapper.reportsToLineOpacity);
        System.assertEquals(false, wrapper.createNewContact); //Object initializes with false not null
        System.assertEquals(false, wrapper.isInfluenceSupportGlobal);
        System.assertEquals(false, wrapper.isCloneEnabled); //Object empty initializes with false not true
        System.assertEquals(false, wrapper.isSettingsEnabled); //Object empty initializes with false not true
    }

    @isTest
    static void initValidObjectsTest() {
        TestMockData md = new TestMockData();
        md.mockRMChartSettingForAccountPlan.Show_Overview__c = true;
        md.mockRMChartSettingForAccountPlan.Card_Style__c = 'Expanded';
        md.mockRMChartSettingForAccountPlan.Display_Style__c = 'Vertical';
        md.mockRMChartSettingForAccountPlan.Show_Parents__c = true;
        md.mockRMChartSettingForAccountPlan.Enable_Drag_Select__c = true;
        md.mockRMChartSettingForAccountPlan.Auto_Layout__c = false;
        md.mockRMChartSettingForAccountPlan.Show_Empty_Fields__c = true;
        md.mockRMChartSettingForAccountPlan.Relationship_Line_Opacity__c = .5;
        md.mockRMChartSettingForAccountPlan.Reports_To_Line_Opacity__c = .5;
        md.mockRMChartSettingForAccountPlan.Is_Influence_Support_Global_Scope__c = true;

        md.mockRMOrgSettingForAccountPlan.Create_New_Contact__c = false;
        md.mockRMOrgSettingForAccountPlan.Show_Clone_Relationship_Map__c = true;
        md.mockRMOrgSettingForAccountPlan.Show_Chart_Settings__c = false;

        RMChartSettingsWrapper wrapper = new RMChartSettingsWrapper(
            md.mockRMChartSettingForAccountPlan,
            md.mockRMOrgSettingForAccountPlan
        );
        System.assertEquals(md.mockRMChartSettingForAccountPlan.Show_Overview__c, wrapper.showOverview);
        System.assertEquals(md.mockRMChartSettingForAccountPlan.Card_Style__c, wrapper.cardStyle);
        System.assertEquals(md.mockRMChartSettingForAccountPlan.Display_Style__c, wrapper.displayStyle);
        System.assertEquals(md.mockRMChartSettingForAccountPlan.Show_Parents__c, wrapper.showParent);
        System.assertEquals(md.mockRMChartSettingForAccountPlan.Enable_Drag_Select__c, wrapper.enableDragSelect);
        System.assertEquals(md.mockRMChartSettingForAccountPlan.Auto_Layout__c, wrapper.autoLayout);
        System.assertEquals(md.mockRMChartSettingForAccountPlan.Show_Empty_Fields__c, wrapper.showEmptyFields);
        System.assertEquals(
            md.mockRMChartSettingForAccountPlan.Relationship_Line_Opacity__c / 100,
            wrapper.relationshipLineOpacity
        );
        System.assertEquals(
            md.mockRMChartSettingForAccountPlan.Reports_To_Line_Opacity__c / 100,
            wrapper.reportsToLineOpacity
        );
        System.assertEquals(md.mockRMOrgSettingForAccountPlan.Create_New_Contact__c, wrapper.createNewContact);
        System.assertEquals(
            md.mockRMChartSettingForAccountPlan.Is_Influence_Support_Global_Scope__c,
            wrapper.isInfluenceSupportGlobal
        );
        System.assertEquals(md.mockRMOrgSettingForAccountPlan.Show_Clone_Relationship_Map__c, wrapper.isCloneEnabled);
        System.assertEquals(md.mockRMOrgSettingForAccountPlan.Show_Chart_Settings__c, wrapper.isSettingsEnabled);
    }

    @isTest
    static void toChartSettingsNullChartObjTest() {
        RMChartSettingsWrapper wrapper = new RMChartSettingsWrapper();
        wrapper.showOverview = true;
        wrapper.cardStyle = 'Expanded';
        wrapper.displayStyle = 'Vertical';
        wrapper.showParent = true;
        wrapper.enableDragSelect = true;
        wrapper.autoLayout = false;
        wrapper.showEmptyFields = true;
        wrapper.relationshipLineOpacity = .5;
        wrapper.reportsToLineOpacity = .5;

        RM_Chart_Setting__c chartSetting = wrapper.toChartSettings();
        System.assertEquals(true, chartSetting.Show_Overview__c);
        System.assertEquals('Expanded', chartSetting.Card_Style__c);
        System.assertEquals('Vertical', chartSetting.Display_Style__c);
        System.assertEquals(true, chartSetting.Show_Parents__c);
        System.assertEquals(true, chartSetting.Enable_Drag_Select__c);
        System.assertEquals(false, chartSetting.Auto_Layout__c);
        System.assertEquals(true, chartSetting.Show_Empty_Fields__c);
        System.assertEquals(50, chartSetting.Relationship_Line_Opacity__c);
        System.assertEquals(50, chartSetting.Reports_To_Line_Opacity__c);
        System.assertEquals(null, chartSetting.Id);
    }

    @isTest
    static void toChartSettingsTest() {
        TestMockData md = new TestMockData();

        md.mockRMChartSettingForAccountPlan.Show_Overview__c = true;
        md.mockRMChartSettingForAccountPlan.Card_Style__c = 'Expanded';
        md.mockRMChartSettingForAccountPlan.Display_Style__c = 'Vertical';
        md.mockRMChartSettingForAccountPlan.Show_Parents__c = true;
        md.mockRMChartSettingForAccountPlan.Enable_Drag_Select__c = true;
        md.mockRMChartSettingForAccountPlan.Auto_Layout__c = false;
        md.mockRMChartSettingForAccountPlan.Show_Empty_Fields__c = true;
        md.mockRMChartSettingForAccountPlan.Relationship_Line_Opacity__c = .5;
        md.mockRMChartSettingForAccountPlan.Reports_To_Line_Opacity__c = .5;

        RMChartSettingsWrapper wrapper = new RMChartSettingsWrapper(
            md.mockRMChartSettingForAccountPlan,
            md.mockRMOrgSettingForAccountPlan
        );

        RM_Chart_Setting__c returnedSettings = wrapper.toChartSettings();
        System.assertEquals(md.mockRMChartSettingForAccountPlan, returnedSettings);
    }

    @isTest
    static void toOrgSettingsNullOrgObjTest() {
        RMChartSettingsWrapper wrapper = new RMChartSettingsWrapper();
        wrapper.createNewContact = false;
        wrapper.isCloneEnabled = true;
        wrapper.isSettingsEnabled = false;

        RM_Org_Setting__c orgSetting = wrapper.toOrgSettings();
        System.assertEquals(false, orgSetting.Create_New_Contact__c);
        System.assertEquals(wrapper.isCloneEnabled, orgSetting.Show_Clone_Relationship_Map__c);
        System.assertEquals(wrapper.isSettingsEnabled, orgSetting.Show_Chart_Settings__c);
        System.assertEquals(null, orgSetting.Id);
    }

    @isTest
    static void toOrgSettingsTest() {
        TestMockData md = new TestMockData();

        md.mockRMOrgSettingForAccountPlan.Create_New_Contact__c = false;
        md.mockRMOrgSettingForAccountPlan.Show_Clone_Relationship_Map__c = true;
        md.mockRMOrgSettingForAccountPlan.Show_Chart_Settings__c = false;

        RMChartSettingsWrapper wrapper = new RMChartSettingsWrapper(
            md.mockRMChartSettingForAccountPlan,
            md.mockRMOrgSettingForAccountPlan
        );

        RM_Org_Setting__c returnedSettings = wrapper.toOrgSettings();
        System.assertEquals(md.mockRMOrgSettingForAccountPlan, returnedSettings);
    }
}