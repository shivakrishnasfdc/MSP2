@isTest
private class RMSvgServiceTest {
    // Test for when Global Scope is true
    @isTest
    static void injectBadgesTest() {
        TestMockData md = new TestMockData();
        RMSvgNodeAssociationSelector mockRMSvgNodeAssociationSelector = md.mockRMSvgNodeAssociationSelector;
        RMSvgSelector mockRMSvgSelector = md.mockRMSvgSelector;
        RMSvgHelperServiceImpl mockRMSvgHelperService = md.mockRMSvgHelperService;
        RelationshipMapSelector mockRelationshipMapSelector = md.mockRelationshipMapSelector;

        Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        md.mockRelationshipMap.Type_Setting__c = 'pqcrush__Account_Plan__c';
        md.mockRelationshipMap.pq_AccountPlanId__c = accountPlanId;

        List<GraphNodeData> nodeData = new List<GraphNodeData>();
        nodeData.add(new GraphNodeData(md.mockRMSvgNodeAssociation.Key__c, 'groupKey1', 'label', 'horizontal'));

        RM_Chart_Setting__c setting = new RM_Chart_Setting__c(Is_Badge_Global_Scope__c = true);
        List<RM_Svg__c> svgList = new List<RM_Svg__c>{ md.mockRMSvg };

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.when(
                mockRMSvgSelector.selectByRelationshipMaps(new Set<Id>{ md.mockRelationshipMapId }, true, accountPlanId)
            )
            .thenReturn(svgList);
        md.mocks.when(mockRMSvgHelperService.injectBoundBadges(svgList, nodeData)).thenReturn(nodeData);
        md.mocks.when(
                mockRMSvgNodeAssociationSelector.selectByKeysGlobalForSvgs(
                    svgList,
                    new Set<String>{ md.mockRMSvgNodeAssociation.Key__c }
                )
            )
            .thenReturn(new List<RM_Svg_Node_Association__c>{ md.mockRMSvgNodeAssociation });
        md.mocks.stopStubbing();

        GraphData result = RMSvgService.injectBadges(md.mockRelationshipMapId, new GraphData(nodeData, null), setting);

        ((RMSvgNodeAssociationSelector) md.mocks.verify(mockRMSvgNodeAssociationSelector, 0))
            .selectByKeysLocal((Id) fflib_Match.anyObject(), (Set<String>) fflib_Match.anyObject());
        System.assertEquals(md.mockRMSvg.Id, result.nodeDataArray[0].badges[0].id);
    }

    // Test for when Global Scope is false
    @isTest
    static void injectBadgesTest2() {
        TestMockData md = new TestMockData();
        RMSvgNodeAssociationSelector mockRMSvgNodeAssociationSelector = md.mockRMSvgNodeAssociationSelector;
        RMSvgSelector mockRMSvgSelector = md.mockRMSvgSelector;
        RMSvgHelperServiceImpl mockRMSvgHelperService = md.mockRMSvgHelperService;
        RelationshipMapSelector mockRelationshipMapSelector = md.mockRelationshipMapSelector;

        Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        md.mockRelationshipMap.Type_Setting__c = 'pqcrush__Account_Plan__c';
        md.mockRelationshipMap.pq_AccountPlanId__c = accountPlanId;

        List<GraphNodeData> nodeData = new List<GraphNodeData>();
        nodeData.add(new GraphNodeData(md.mockRMSvgNodeAssociation.Key__c, 'groupKey1', 'label', 'horizontal'));

        RM_Chart_Setting__c setting = new RM_Chart_Setting__c(Is_Badge_Global_Scope__c = false);
        List<RM_Svg__c> svgList = new List<RM_Svg__c>{ md.mockRMSvg };

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.when(
                mockRMSvgSelector.selectByRelationshipMaps(new Set<Id>{ md.mockRelationshipMapId }, true, accountPlanId)
            )
            .thenReturn(svgList);
        md.mocks.when(mockRMSvgHelperService.injectBoundBadges(svgList, nodeData)).thenReturn(nodeData);
        md.mocks.when(
                mockRMSvgNodeAssociationSelector.selectByKeysLocalForSvgs(
                    md.mockRelationshipMapId,
                    svgList,
                    new Set<String>{ md.mockRMSvgNodeAssociation.Key__c }
                )
            )
            .thenReturn(new List<RM_Svg_Node_Association__c>{ md.mockRMSvgNodeAssociation });
        md.mocks.stopStubbing();

        GraphData result = RMSvgService.injectBadges(md.mockRelationshipMapId, new GraphData(nodeData, null), setting);

        ((RMSvgNodeAssociationSelector) md.mocks.verify(mockRMSvgNodeAssociationSelector, 0))
            .selectByKeysGlobal((Set<String>) fflib_Match.anyObject());
        System.assertEquals(md.mockRMSvg.Id, result.nodeDataArray[0].badges[0].id);
    }

    @isTest
    static void associateBadgeForRMTest1() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        RMSvgNodeAssociationSelector mockRMSvgNodeAssociationSelector = md.mockRMSvgNodeAssociationSelector;

        List<String> nodeIds = new List<String>{ 'test1' };

        md.mocks.startStubbing();
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(new RM_Chart_Setting__c(Is_Badge_Global_Scope__c = true));
        md.mocks.when(mockRMSvgNodeAssociationSelector.selectByKeysGlobal(new Set<String>(nodeIds)))
            .thenReturn(new List<RM_Svg_Node_Association__c>{ md.mockRMSvgNodeAssociation });
        md.mocks.stopStubbing();

        RMSvgService.associateBadge(md.mockRelationshipMapId, md.mockRMSvg.Id, nodeIds);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew(
                new RM_Svg_Node_Association__c(Key__c = 'test1', RM_Svg__c = md.mockRMSvgNodeAssociation.RM_Svg__c)
            );
        System.assert(true);
    }

    @isTest
    static void associateBadgeForRMTest2() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        RMSvgNodeAssociationSelector mockRMSvgNodeAssociationSelector = md.mockRMSvgNodeAssociationSelector;

        List<String> nodeIds = new List<String>{ 'test1' };

        md.mocks.startStubbing();
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(new RM_Chart_Setting__c(Is_Badge_Global_Scope__c = false));
        md.mocks.when(
                mockRMSvgNodeAssociationSelector.selectByKeysLocal(md.mockRelationshipMapId, new Set<String>(nodeIds))
            )
            .thenReturn(new List<RM_Svg_Node_Association__c>{ md.mockRMSvgNodeAssociation });
        md.mocks.stopStubbing();

        RMSvgService.associateBadge(md.mockRelationshipMapId, md.mockRMSvg.Id, nodeIds);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew(
                new RM_Svg_Node_Association__c(
                    Account_Plan__c = null,
                    Relationship_Map__c = md.mockRelationshipMapId,
                    Key__c = 'test1',
                    RM_Svg__c = md.mockRMSvgNodeAssociation.RM_Svg__c
                )
            );
        System.assert(true);
    }

    // Test accountOrMapId is null
    @isTest
    static void removeBadgeTest1() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        RMSvgNodeAssociationSelector mockRMSvgNodeAssociationSelector = md.mockRMSvgNodeAssociationSelector;

        List<String> nodeIds = new List<String>{ 'test1' };

        RMSvgService.removeBadge(null, nodeIds);

        ((RMChartSettingServiceImpl) md.mocks.verify(mockRMChartSettingService, 0))
            .getRelationshipMapSettingForObject((Id) fflib_Match.anyObject());

        ((RMSvgNodeAssociationSelector) md.mocks.verify(mockRMSvgNodeAssociationSelector, 0))
            .selectByKeysGlobal((Set<String>) fflib_Match.anyObject());
        ((RMSvgNodeAssociationSelector) md.mocks.verify(mockRMSvgNodeAssociationSelector, 0))
            .selectByKeysLocal((Id) fflib_Match.anyObject(), (Set<String>) fflib_Match.anyObject());

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0))
            .registerDeleted((List<RM_Svg_Node_Association__c>) fflib_Match.anyObject());

        System.assert(true);
    }

    @isTest
    static void removeBadgeTest2() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        RMSvgNodeAssociationSelector mockRMSvgNodeAssociationSelector = md.mockRMSvgNodeAssociationSelector;

        List<String> nodeIds = new List<String>{ 'test1' };

        md.mocks.startStubbing();
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(new RM_Chart_Setting__c(Is_Badge_Global_Scope__c = true));
        md.mocks.when(
                mockRMSvgNodeAssociationSelector.selectByKeysGlobalWithAutomation(new Set<String>(nodeIds), false)
            )
            .thenReturn(new List<RM_Svg_Node_Association__c>{ md.mockRMSvgNodeAssociation });
        md.mocks.stopStubbing();

        RMSvgService.removeBadge(md.mockRelationshipMapId, nodeIds);

        ((RMSvgNodeAssociationSelector) md.mocks.verify(mockRMSvgNodeAssociationSelector, 0))
            .selectByKeysLocalWithAutomation(
                (Id) fflib_Match.anyObject(),
                (Set<String>) fflib_Match.anyObject(),
                (Boolean) fflib_Match.anyObject()
            );
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerDeleted(new List<RM_Svg_Node_Association__c>{ md.mockRMSvgNodeAssociation });

        System.assert(true);
    }

    @isTest
    static void removeBadgeTest3() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        RMSvgNodeAssociationSelector mockRMSvgNodeAssociationSelector = md.mockRMSvgNodeAssociationSelector;

        List<String> nodeIds = new List<String>{ 'test1' };

        md.mocks.startStubbing();
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(new RM_Chart_Setting__c(Is_Badge_Global_Scope__c = false));
        md.mocks.when(
                mockRMSvgNodeAssociationSelector.selectByKeysLocalWithAutomation(
                    md.mockRelationshipMapId,
                    new Set<String>(nodeIds),
                    false
                )
            )
            .thenReturn(new List<RM_Svg_Node_Association__c>{ md.mockRMSvgNodeAssociation });
        md.mocks.stopStubbing();

        RMSvgService.removeBadge(md.mockRelationshipMapId, nodeIds);

        ((RMSvgNodeAssociationSelector) md.mocks.verify(mockRMSvgNodeAssociationSelector, 0))
            .selectByKeysGlobalWithAutomation((Set<String>) fflib_Match.anyObject(), (Boolean) fflib_Match.anyObject());
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerDeleted(new List<RM_Svg_Node_Association__c>{ md.mockRMSvgNodeAssociation });

        System.assert(true);
    }
}