@isTest
private class GraphDataControllerTest {
    @isTest
    public static void removeNodesFromGroupTest() {
        testMockData md = new testMockData();
        RelationshipGroupServiceImpl mockRelationshipGroupService = md.mockRelationshipGroupService;

        GraphNodeData graphData = new GraphNodeData('abcdefg', 'groupKey', 'label', 'horizontal');
        GraphData gd = new graphData();
        gd.nodeDataArray = new List<GraphNodeData>{ graphData };

        GraphDataController.removeNodesFromGroup(JSON.serialize(gd));

        ((RelationshipGroupServiceImpl) md.mocks.verify(mockRelationshipGroupService, 1))
            .removeNodesFromGroup(gd.nodeDataArray);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    public static void createNewGroupTest() {
        testMockData md = new testMockData();
        RelationshipGroupServiceImpl mockRelationshipGroupService = md.mockRelationshipGroupService;

        GraphNodeData graphData = new GraphNodeData('abcdefg', 'groupKey', 'label', 'horizontal');
        GraphData gd = new graphData();
        gd.nodeDataArray = new List<GraphNodeData>{ graphData };
        List<String> contactIds = new List<String>{ md.mockContactId };

        GraphDataController.createNewGroup(JSON.serialize(gd), contactIds, null);

        ((RelationshipGroupServiceImpl) md.mocks.verify(mockRelationshipGroupService, 1))
            .createNewGroup(graphData, contactIds, null);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    public static void updateGroupNameTest() {
        testMockData md = new testMockData();
        RelationshipGroupServiceImpl mockRelationshipGroupService = md.mockRelationshipGroupService;

        GraphNodeData graphData = new GraphNodeData('abcdefg', 'groupKey', 'label', 'horizontal');
        GraphData gd = new graphData();
        gd.nodeDataArray = new List<GraphNodeData>{ graphData };
        String newName = 'new name';

        GraphDataController.updateGroupName(JSON.serialize(gd), newName);

        ((RelationshipGroupServiceImpl) md.mocks.verify(mockRelationshipGroupService, 1))
            .updateGroupName(graphData, newName);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    public static void addContactsToGroupTest() {
        testMockData md = new testMockData();
        RelationshipGroupServiceImpl mockRelationshipGroupService = md.mockRelationshipGroupService;

        GraphNodeData graphData = new GraphNodeData('abcdefg', 'groupKey', 'label', 'horizontal');
        GraphData gd = new graphData();
        gd.nodeDataArray = new List<GraphNodeData>{ graphData };
        List<String> contactIds = new List<String>{ md.mockContactId };

        GraphDataController.addContactsToGroup(JSON.serialize(gd), contactIds, null);

        ((RelationshipGroupServiceImpl) md.mocks.verify(mockRelationshipGroupService, 1))
            .addContactsToGroup(graphData, contactIds, null);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    public static void addGroupsToGroupTest() {
        testMockData md = new testMockData();
        RelationshipGroupServiceImpl mockRelationshipGroupService = md.mockRelationshipGroupService;

        GraphNodeData graphData = new GraphNodeData('abcdefg', 'groupKey', 'label', 'horizontal');
        GraphData gd = new graphData();
        gd.nodeDataArray = new List<GraphNodeData>{ graphData };
        List<String> groupIds = new List<String>{ md.mockRelationshipGroupId };

        GraphDataController.addGroupsToGroup(JSON.serialize(gd), groupIds);

        ((RelationshipGroupServiceImpl) md.mocks.verify(mockRelationshipGroupService, 1))
            .addGroupsToGroup(graphData, groupIds);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    public static void updateGroupLayoutTest() {
        testMockData md = new testMockData();
        RelationshipGroupServiceImpl mockRelationshipGroupService = md.mockRelationshipGroupService;

        String groupId = 'a';
        String type = 'Horizontal';

        GraphDataController.updateGroupLayout(groupId, type);

        ((RelationshipGroupServiceImpl) md.mocks.verify(mockRelationshipGroupService, 1))
            .updateGroupLayout(groupId, type);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    public static void deleteCustomLinksTest() {
        testMockData md = new testMockData();
        ContactRelationshipServiceImpl mockContactRelationshipService = md.mockContactRelationshipService;

        GraphLinkData graphData = new GraphLinkData('abcdefg', '', '', false, '', '', '');
        GraphData gd = new graphData();
        gd.linkDataArray = new List<GraphLinkData>{ graphData };

        GraphDataController.deleteCustomLinks(JSON.serialize(gd));

        ((ContactRelationshipServiceImpl) md.mocks.verify(mockContactRelationshipService, 1))
            .deleteCustomLinks(gd.linkDataArray);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    public static void newCustomLinksTest() {
        testMockData md = new testMockData();
        ContactRelationshipServiceImpl mockContactRelationshipService = md.mockContactRelationshipService;

        GraphLinkData graphData = new GraphLinkData('abcdefg', '', '', false, '', '', '');
        GraphData gd = new graphData();
        gd.linkDataArray = new List<GraphLinkData>{ graphData };

        GraphDataController.newCustomLinks(JSON.serialize(gd), md.mockRelationshipMapId);

        ((ContactRelationshipServiceImpl) md.mocks.verify(mockContactRelationshipService, 1))
            .newCustomLinks(gd.linkDataArray, md.mockRelationshipMapId);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    public static void updateCustomLinksTest() {
        testMockData md = new testMockData();
        ContactRelationshipServiceImpl mockContactRelationshipService = md.mockContactRelationshipService;

        GraphLinkData graphData = new GraphLinkData('abcdefg', '', '', false, '', '', '');
        GraphData gd = new graphData();
        gd.linkDataArray = new List<GraphLinkData>{ graphData };

        GraphDataController.updateCustomLinks(JSON.serialize(gd));

        ((ContactRelationshipServiceImpl) md.mocks.verify(mockContactRelationshipService, 1))
            .updateCustomLinks(gd.linkDataArray);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    public static void updateReportsToTest() {
        testMockData md = new testMockData();
        GraphDataServiceImpl mockGraphDataService = md.mockGraphDataService;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;

        GraphData gd = new GraphData();
        gd.linkDataArray = new List<GraphLinkData>{ new GraphLinkData('abcdefg', '', '', false, '', '', '') };

        md.mocks.startStubbing();
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(md.mockRMChartSettingForRelationshipMap);
        md.mocks.stopStubbing();

        GraphDataController.updateReportsTo(JSON.serialize(gd), md.mockRelationshipMapId);

        ((GraphDataServiceImpl) md.mocks.verify(mockGraphDataService, 1))
            .updateReportsTo(gd.linkDataArray, md.mockRelationshipMapId, md.mockRMChartSettingForRelationshipMap);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    public static void getSupportColorsTest() {
        testMockData md = new testMockData();
        GraphDataServiceImpl mockGraphDataService = md.mockGraphDataService;

        GraphDataController.getSupportColors();

        ((GraphDataServiceImpl) md.mocks.verify(mockGraphDataService, 1)).getSupportColors();
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    public static void getContactRelationshipTypesTest() {
        testMockData md = new testMockData();
        GraphDataServiceImpl mockGraphDataService = md.mockGraphDataService;

        GraphDataController.getContactRelationshipTypes(md.mockRelationshipMapId);

        ((GraphDataServiceImpl) md.mocks.verify(mockGraphDataService, 1))
            .getContactRelationshipTypes(md.mockRelationshipMapId);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    static void getAnchorsForRelMapTest() {
        // Given
        testMockData md = new testMockData();
        RMAnchorSelector selector = md.mockRMAnchorSelector;

        GraphDataController.getAnchors(md.mockRelationshipMapId);

        ((RMAnchorSelector) md.mocks.verify(selector, 1)).selectByObjectId(new Set<Id>{ md.mockRelationshipMapId });
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    static void getAnchorsForKSTest() {
        // Given
        testMockData md = new testMockData();
        RMAnchorSelector selector = md.mockRMAnchorSelector;

        GraphDataController.getAnchors(md.mockAccountPlanId);

        ((RMAnchorSelector) md.mocks.verify(selector, 1)).selectByObjectId(new Set<Id>{ md.mockAccountPlanId });
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    static void setAnchorForRMTest() {
        // Given
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RMAnchorSelector selector = md.mockRMAnchorSelector;
        Id toId = fflib_IDGenerator.generate(Contact.SObjectType);

        md.mocks.startStubbing();
        md.mocks.when(
                selector.selectByObjectIdAndFromField(
                    md.mockRelationshipMapId,
                    new Set<String>{ md.mockRelationshipMapMemberId }
                )
            )
            .thenReturn(new List<RM_Anchor__c>{ md.mockRMAnchor });
        md.mocks.stopStubbing();

        GraphDataController.setAnchor(md.mockRelationshipMapId, md.mockRelationshipMapMemberId, toId);

        RM_Anchor__c anchor = md.mockRMAnchor;
        anchor.To__c = anchor.To__c = toId;

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(anchor);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    static void setAnchorForRMNewTest() {
        // Given
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RMAnchorSelector selector = md.mockRMAnchorSelector;
        Id toId = fflib_IDGenerator.generate(Contact.SObjectType);

        md.mocks.startStubbing();
        md.mocks.when(
                selector.selectByObjectIdAndFromField(
                    md.mockRelationshipMapId,
                    new Set<String>{ md.mockRelationshipMapMemberId }
                )
            )
            .thenReturn(new List<RM_Anchor__c>());
        md.mocks.stopStubbing();

        GraphDataController.setAnchor(md.mockRelationshipMapId, md.mockRelationshipMapMemberId, toId);

        RM_Anchor__c anchor = new RM_Anchor__c(
            From__c = md.mockRelationshipMapMemberId,
            To__c = toId,
            Relationship_Map__c = md.mockRelationshipMapId
        );

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew(anchor);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    static void setAnchorForAPTest() {
        // Given
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RMAnchorSelector selector = md.mockRMAnchorSelector;
        Id toId = fflib_IDGenerator.generate(Contact.SObjectType);

        md.mocks.startStubbing();
        md.mocks.when(
                selector.selectByObjectIdAndFromField(md.mockAccountPlanId, new Set<String>{ md.mockKeystakeholderId })
            )
            .thenReturn(new List<RM_Anchor__c>{ md.mockRMAnchor });
        md.mocks.stopStubbing();

        GraphDataController.setAnchor(md.mockAccountPlanId, md.mockKeyStakeholderId, toId);

        RM_Anchor__c anchor = md.mockRMAnchor;
        anchor.To__c = anchor.To__c = toId;

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(anchor);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    static void setAnchorForAPNewTest() {
        // Given
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RMAnchorSelector selector = md.mockRMAnchorSelector;
        Id toId = fflib_IDGenerator.generate(Contact.SObjectType);

        md.mocks.startStubbing();
        md.mocks.when(
                selector.selectByObjectIdAndFromField(md.mockAccountPlanId, new Set<String>{ md.mockKeystakeholderId })
            )
            .thenReturn(new List<RM_Anchor__c>());
        md.mocks.stopStubbing();

        GraphDataController.setAnchor(md.mockAccountPlanId, md.mockKeyStakeholderId, toId);

        RM_Anchor__c anchor = new RM_Anchor__c(
            From__c = md.mockKeyStakeholderId,
            To__c = toId,
            Account_Plan__c = md.mockAccountPlanId
        );

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew(anchor);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    static void saveAllNodeCoordinatesTest() {
        // Given
        testMockData md = new testMockData();
        RMNodeCoordinateServiceImpl mockRMNodeCoordinateService = md.mockRMNodeCoordinateService;

        GraphNodeData graphData = new GraphNodeData('abcdefg', 'groupKey', 'label', 'horizontal');
        GraphData gd = new graphData();
        gd.nodeDataArray = new List<GraphNodeData>{ graphData };

        GraphDataController.saveAllNodeCoordinates(md.mockAccountPlanId, JSON.serialize(gd));

        ((RMNodeCoordinateServiceImpl) md.mocks.verify(mockRMNodeCoordinateService, 1))
            .saveAllNodeCoordinates(md.mockAccountPlanId, gd.nodeDataArray);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    static void updateNodeCoordinatesTest() {
        // Given
        testMockData md = new testMockData();
        RMNodeCoordinateServiceImpl mockRMNodeCoordinateService = md.mockRMNodeCoordinateService;

        GraphNodeData graphData = new GraphNodeData('abcdefg', 'groupKey', 'label', 'horizontal');
        GraphData gd = new graphData();
        gd.nodeDataArray = new List<GraphNodeData>{ graphData };

        GraphDataController.updateNodeCoordinates(md.mockAccountPlanId, JSON.serialize(gd));

        ((RMNodeCoordinateServiceImpl) md.mocks.verify(mockRMNodeCoordinateService, 1))
            .updateNodeCoordinates(md.mockAccountPlanId, gd.nodeDataArray);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    static void getBadgeOptionsForMapTest() {
        // Given
        testMockData md = new testMockData();
        RMSvgSelector mockRMSvgSelector = md.mockRMSvgSelector;
        RelationshipMapSelector mockRelationshipMapSelector = md.mockRelationshipMapSelector;

        Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        md.mockRelationshipMap.Type_Setting__c = 'pqcrush__Account_Plan__c';
        md.mockRelationshipMap.pq_AccountPlanId__c = accountPlanId;

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.stopStubbing();

        GraphDataController.getBadgeOptions(md.mockRelationshipMapId);

        ((RMSvgSelector) md.mocks.verify(mockRMSvgSelector, 1))
            .selectByRelationshipMaps(new Set<Id>{ md.mockRelationshipMapId }, true, accountPlanId);
        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    static void associateBadgeTest() {
        // Given
        testMockData md = new testMockData();
        RMSvgServiceImpl mockRMSvgService = md.mockRMSvgService;

        String badgeId = 'testbadgeid';
        List<String> nodeIds = new List<String>{ 'testnodeId' };

        GraphDataController.associateBadge(md.mockRelationshipMapId, badgeId, nodeIds);

        ((RMSvgServiceImpl) md.mocks.verify(mockRMSvgService, 1))
            .associateBadge(md.mockRelationshipMapId, badgeId, nodeIds);

        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    static void removeBadgeTest() {
        // Given
        testMockData md = new testMockData();
        RMSvgServiceImpl mockRMSvgService = md.mockRMSvgService;

        List<String> nodeIds = new List<String>{ 'testnodeId' };

        GraphDataController.removeBadge(md.mockRelationshipMapId, nodeIds);

        ((RMSvgServiceImpl) md.mocks.verify(mockRMSvgService, 1)).removeBadge(md.mockRelationshipMapId, nodeIds);

        System.assert(true, 'assert done by mock verify');
    }

    @isTest
    static void getGroupsForContactIdTest() {
        testMockData md = new testMockData();
        RelationshipGroupServiceImpl mockRelationshipGroupService = md.mockRelationshipGroupService;

        GraphDataController.getGroupsForContactId(md.mockContactId);

        ((RelationshipGroupServiceImpl) md.mocks.verify(mockRelationshipGroupService, 1))
            .getGroupsForContactId(md.mockContactId);
        System.assert(true, 'assert done by mock verify');
    }
}