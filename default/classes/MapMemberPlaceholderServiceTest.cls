@isTest
private class MapMemberPlaceholderServiceTest {
    @isTest
    public static void createNewPlaceholderForAccountPlanTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        GraphNodeData graphData = new GraphNodeData('label', 'desc');
        graphData.tempId = 'tempId';

        MapMemberPlaceholderService.createNewPlaceholder(graphData, md.mockAccountPlanId);

        Map_Member_Placeholder__c mmp = new Map_Member_Placeholder__c(
            Name = 'label',
            Label__c = 'label',
            Description__c = 'desc',
            TempId__c = 'tempId',
            Account_Plan__c = md.mockAccountPlanId,
            Relationship_Map__c = null
        );

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew(mmp);
        System.assert(true, 'verify covering all the test cases');
    }

    @isTest
    public static void createNewPlaceholderForRelMapTestTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        GraphNodeData graphData = new GraphNodeData('label', 'desc');
        graphData.tempId = 'tempId';

        MapMemberPlaceholderService.createNewPlaceholder(graphData, md.mockRelationshipMapId);

        Map_Member_Placeholder__c mmp = new Map_Member_Placeholder__c(
            Name = 'label',
            Label__c = 'label',
            Description__c = 'desc',
            TempId__c = 'tempId',
            Account_Plan__c = null,
            Relationship_Map__c = md.mockRelationshipMapId
        );

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew(mmp);
        System.assert(true, 'verify covering all the test cases');
    }

    @isTest
    public static void deletePlaceholdersTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        Map_Member_Placeholder__c mmp = TestDataFactory.createMapMemberPlaceholder('label', 'desc');
        List<String> placeholderIds = new List<String>{ mmp.Id };

        MapMemberPlaceholderService.deletePlaceholders(placeholderIds);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerDeleted((List<Map_Member_Placeholder__c>) fflib_Match.anyList());
        System.assert(true, 'verify covering all the test cases');
    }

    @isTest
    public static void updatePlaceholderDescriptionTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        MapMemberPlaceholderSelector mockMapMemberPlaceholderSelector = md.mockMapMemberPlaceholderSelector;

        GraphNodeData graphData = new GraphNodeData('label', 'desc');
        graphData.key = md.mockMapMemberPlaceholderId;

        md.mocks.startStubbing();
        md.mocks.when(mockMapMemberPlaceholderSelector.selectByIdORTempKey(new Set<String>{ graphData.key }))
            .thenReturn(new List<Map_Member_Placeholder__c>{ md.mockMapMemberPlaceholder });
        md.mocks.stopStubbing();

        MapMemberPlaceholderService.updatePlaceholderDescription(graphData, 'newDescription');

        Map_Member_Placeholder__c newMMP = md.mockMapMemberPlaceholder.clone(true, true, true, true);
        newMMP.Description__c = 'newDescription';

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(newMMP);
        System.assert(true, 'verify covering all the test cases');
    }

    @isTest
    public static void updatePlaceholderNameAndLabelTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        MapMemberPlaceholderSelector mockMapMemberPlaceholderSelector = md.mockMapMemberPlaceholderSelector;

        GraphNodeData graphData = new GraphNodeData('label', 'desc');
        graphData.key = md.mockMapMemberPlaceholderId;

        md.mocks.startStubbing();
        md.mocks.when(mockMapMemberPlaceholderSelector.selectByIdORTempKey(new Set<String>{ graphData.key }))
            .thenReturn(new List<Map_Member_Placeholder__c>{ md.mockMapMemberPlaceholder });
        md.mocks.stopStubbing();

        MapMemberPlaceholderService.updatePlaceholderNameAndLabel(graphData, 'newLabel');

        Map_Member_Placeholder__c newMMP = md.mockMapMemberPlaceholder.clone(true, true, true, true);
        newMMP.Name = 'newLabel';
        newMMP.Label__c = 'newLabel';

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(newMMP);
        System.assert(true, 'verify covering all the test cases');
    }

    @isTest
    public static void updatePlaceholderReportToLinksTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        MapMemberPlaceholderRelationshipSelector mockMapMemberPlaceholderRelationshipSelector = md.mockMapMemberPlaceholderRelationshipSelector;

        List<GraphLinkData> graphLinkDataList = new List<GraphLinkData>();
        GraphLinkData gld = new GraphLinkData(
            'id1',
            'tempid1',
            md.mockMapMemberPlaceholderRelationship.From__c,
            false,
            md.mockMapMemberPlaceholderRelationship.To__c,
            'category1',
            'text1'
        );
        graphLinkDataList.add(gld);

        md.mocks.startStubbing();
        md.mocks.when(
                mockMapMemberPlaceholderRelationshipSelector.selectByTo(
                    new Set<String>{ gld.toKey },
                    new Set<Id>{ md.mockRelationshipMapId }
                )
            )
            .thenReturn(new List<Map_Member_Placeholder_Relationship__c>{ md.mockMapMemberPlaceholderRelationship });
        md.mocks.stopStubbing();

        RM_Chart_Setting__c setting = new RM_Chart_Setting__c(Is_Reports_To_Global_Scope__c = true);

        MapMemberPlaceholderService.updatePlaceholderReportToLinks(
            graphLinkDataList,
            md.mockRelationshipMapId,
            setting
        );

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew(
                new Map_Member_Placeholder_Relationship__c(
                    From__c = md.mockMapMemberPlaceholderRelationship.From__c,
                    To__c = md.mockMapMemberPlaceholderRelationship.To__c,
                    Relationship_Map__c = md.mockRelationshipMapId,
                    Is_Hierarchy__c = true
                )
            );

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerDeleted((Map_Member_Placeholder_Relationship__c) fflib_Match.anyObject());
        System.assert(true, 'verify covering all the test cases');
    }

    @isTest
    public static void getPlaceholdersAndLinksByRelationshipMapIdTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow; //NOPMD - Needs to be instantiated so any calls use the mock instance
        MapMemberPlaceholderSelector mockMapMemberPlaceholderSelector = md.mockMapMemberPlaceholderSelector;
        RelationshipGroupPlaceholderSelector mockRelationshipGroupPlaceholderSelector = md.mockRelationshipGroupPlaceholderSelector;
        MapMemberPlaceholderRelationshipSelector mockMapMemberPlaceholderRelationshipSelector = md.mockMapMemberPlaceholderRelationshipSelector;
        RelationshipGroupServiceImpl mockRelationshipGroupService = md.mockRelationshipGroupService;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;

        List<GraphLinkData> graphLinkDataList = new List<GraphLinkData>();
        GraphLinkData gld = new GraphLinkData(
            'id1',
            'tempid1',
            md.mockMapMemberPlaceholderRelationship.From__c,
            false,
            md.mockMapMemberPlaceholderRelationship.To__c,
            'category1',
            'text1'
        );
        graphLinkDataList.add(gld);

        Map<Id, Relationship_Group__c> relGroups = new Map<Id, Relationship_Group__c>();
        relGroups.put(md.mockRelationshipGroupId, md.mockRelationshipGroup);

        List<GraphNodeData> graphNodeDataList = new List<GraphNodeData>();
        GraphNodeData gnd = new GraphNodeData('key1', 'groupKey1', 'label', 'horizontal');
        graphNodeDataList.add(gnd);

        RM_Chart_Setting__c setting = new RM_Chart_Setting__c(
            Id = fflib_IDGenerator.generate(RM_Chart_Setting__c.SObjectType),
            Is_Relationship_Line_Global_Scope__c = true
        );

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMapId)).thenReturn(false);
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(setting);
        md.mocks.when(mockMapMemberPlaceholderSelector.selectByObjectId(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<Map_Member_Placeholder__c>{ md.mockMapMemberPlaceholder });
        md.mocks.when(
                mockRelationshipGroupPlaceholderSelector.selectWithGroupsByPlaceholderIds(
                    new Set<String>{ md.mockMapMemberPlaceholderId }
                )
            )
            .thenReturn(new List<Relationship_Group_Placeholder_Assoc__c>{ md.mockRelationshipGroupPlaceholderAssoc });
        md.mocks.when(
                mockMapMemberPlaceholderRelationshipSelector.selectGlobalRelationshipsById(
                    new Set<String>{ md.mockMapMemberPlaceholderId },
                    md.mockRelationshipMapId,
                    false
                )
            )
            .thenReturn(new List<Map_Member_Placeholder_Relationship__c>{ md.mockMapMemberPlaceholderRelationship });
        md.mocks.when(
                mockMapMemberPlaceholderRelationshipSelector.selectHierarchyLinksByPlaceholderId(
                    new Set<Id>{ md.mockRelationshipMapId },
                    new Set<String>{ md.mockMapMemberPlaceholderId }
                )
            )
            .thenReturn(new List<Map_Member_Placeholder_Relationship__c>{ md.mockMapMemberPlaceholderRelationship });
        md.mocks.when(
                mockRelationshipGroupService.getAllGroups(
                    (Map<Id, Relationship_Group__c>) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject()
                )
            )
            .thenReturn(relGroups);
        md.mocks.when(mockRelationshipGroupService.createNodeDataForGroups(relGroups.values()))
            .thenReturn(graphNodeDataList);
        md.mocks.stopStubbing();

        GraphData gd = MapMemberPlaceholderService.getPlaceholdersAndLinksByObjectId(md.mockRelationshipMapId);

        ((RelationshipGroupServiceImpl) md.mocks.verify(mockRelationshipGroupService, 1))
            .getAllGroups((Map<Id, Relationship_Group__c>) fflib_Match.anyObject(), (Id) fflib_Match.anyObject());
        ((RelationshipGroupServiceImpl) md.mocks.verify(mockRelationshipGroupService, 1))
            .createNodeDataForGroups(relGroups.values());

        System.assertEquals(1, gd.linkDataArray.size());
        System.assertEquals(2, gd.nodeDataArray.size());
    }

    @isTest
    public static void getAndInjectCustomLinksTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow; //NOPMD - Needs to be instantiated so any calls use the mock instance
        MapMemberPlaceholderRelationshipSelector mockMapMemberPlaceholderRelationshipSelector = md.mockMapMemberPlaceholderRelationshipSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;

        List<GraphLinkData> graphLinkDataList = new List<GraphLinkData>();
        GraphLinkData gld = new GraphLinkData(
            'id1',
            'tempid1',
            md.mockMapMemberPlaceholderRelationship.From__c,
            false,
            md.mockMapMemberPlaceholderRelationship.To__c,
            'category1',
            'text1'
        );
        graphLinkDataList.add(gld);

        Map<Id, Relationship_Group__c> relGroups = new Map<Id, Relationship_Group__c>();
        relGroups.put(md.mockRelationshipGroupId, md.mockRelationshipGroup);

        List<GraphNodeData> graphNodeDataList = new List<GraphNodeData>();
        GraphNodeData gnd = new GraphNodeData(md.mockRelationshipGroupId, 'groupKey1', 'label', 'horizontal');
        gnd.isGroup = true;
        graphNodeDataList.add(gnd);

        GraphData gd = new GraphData(graphNodeDataList, graphLinkDataList);

        RM_Chart_Setting__c setting = new RM_Chart_Setting__c(
            Id = fflib_IDGenerator.generate(RM_Chart_Setting__c.SObjectType),
            Is_Relationship_Line_Global_Scope__c = true
        );

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMapId)).thenReturn(false);
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(setting);
        md.mocks.when(
                mockMapMemberPlaceholderRelationshipSelector.selectGlobalRelationshipsById(
                    new Set<String>{ md.mockRelationshipGroupId },
                    md.mockRelationshipMapId,
                    false
                )
            )
            .thenReturn(new List<Map_Member_Placeholder_Relationship__c>{ md.mockMapMemberPlaceholderRelationship });
        md.mocks.stopStubbing();

        MapMemberPlaceholderService.getAndInjectCustomLinks(gd, md.mockRelationshipMapId);

        System.assertEquals(2, gd.linkDataArray.size());
        System.assertEquals(1, gd.nodeDataArray.size());
    }

    @isTest
    public static void getAndInjectCustomLinksLocalTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow; //NOPMD - Needs to be instantiated so any calls use the mock instance
        MapMemberPlaceholderRelationshipSelector mockMapMemberPlaceholderRelationshipSelector = md.mockMapMemberPlaceholderRelationshipSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;

        List<GraphLinkData> graphLinkDataList = new List<GraphLinkData>();
        GraphLinkData gld = new GraphLinkData(
            'id1',
            'tempid1',
            md.mockMapMemberPlaceholderRelationship.From__c,
            false,
            md.mockMapMemberPlaceholderRelationship.To__c,
            'category1',
            'text1'
        );
        graphLinkDataList.add(gld);

        Map<Id, Relationship_Group__c> relGroups = new Map<Id, Relationship_Group__c>();
        relGroups.put(md.mockRelationshipGroupId, md.mockRelationshipGroup);

        List<GraphNodeData> graphNodeDataList = new List<GraphNodeData>();
        GraphNodeData gnd = new GraphNodeData(md.mockRelationshipGroupId, 'groupKey1', 'label', 'horizontal');
        gnd.isGroup = true;
        graphNodeDataList.add(gnd);

        GraphData gd = new GraphData(graphNodeDataList, graphLinkDataList);

        RM_Chart_Setting__c setting = new RM_Chart_Setting__c(
            Id = fflib_IDGenerator.generate(RM_Chart_Setting__c.SObjectType),
            Is_Relationship_Line_Global_Scope__c = false
        );

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMapId)).thenReturn(false);
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(setting);
        md.mocks.when(
                mockMapMemberPlaceholderRelationshipSelector.selectLocalRelationshipsById(
                    new Set<String>{ md.mockRelationshipGroupId },
                    md.mockRelationshipMapId,
                    false
                )
            )
            .thenReturn(new List<Map_Member_Placeholder_Relationship__c>{ md.mockMapMemberPlaceholderRelationship });
        md.mocks.stopStubbing();

        MapMemberPlaceholderService.getAndInjectCustomLinks(gd, md.mockRelationshipMapId);

        System.assertEquals(2, gd.linkDataArray.size());
        System.assertEquals(1, gd.nodeDataArray.size());
    }
}