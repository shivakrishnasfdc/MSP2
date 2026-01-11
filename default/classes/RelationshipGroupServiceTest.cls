@isTest
private class RelationshipGroupServiceTest {
    @isTest
    public static void createNewGroupTest() {
        TestMockData md = new TestMockData();
        RelationshipGroupSelector mockRelationshipGroupSelector = md.mockRelationshipGroupSelector;
        ContactSelector mockContactSelector = md.mockContactSelector;
        RelationshipGroupContactSelector mockRelationshipGroupContactSelector = md.mockRelationshipGroupContactSelector; //NOPMD - Needs to be called in order for it to be mocked in the test
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        RMGroupHelperServiceImpl mockRMGroupHelperService = md.mockRMGroupHelperService;

        GraphNodeData graphData = new GraphNodeData('tempkeyabcdefgh', 'groupKey', 'label', 'horizontal');
        List<String> idList = new List<String>{ md.mockContactId };
        Id newGroupId = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType);
        Relationship_Group__c newGroup = new Relationship_Group__c(Id = newGroupId);

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipGroupSelector.selectByIdORTempKey(new Set<String>{ graphData.key }))
            .thenReturn(new List<Relationship_Group__c>{ md.mockRelationshipGroup });
        md.mocks.when(
                mockRMGroupHelperService.createGroup(
                    graphData.text,
                    graphData.text,
                    'tempkeyabcdefgh',
                    null,
                    md.mockRelationshipMapId,
                    graphData.groupLayout
                )
            )
            .thenReturn(newGroup);
        md.mocks.when(mockContactSelector.selectById(new Set<Id>{ md.mockContactId }))
            .thenReturn(new List<Contact>{ md.mockContact });
        md.mocks.when(mockRelationshipGroupSelector.selectById(new Set<Id>{ md.mockContactId }))
            .thenReturn(new List<Relationship_Group__c>());
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(null))
            .thenReturn(new RM_Chart_Setting__c());
        md.mocks.stopStubbing();

        RelationshipGroupService.createNewGroup(graphData, idList, md.mockRelationshipMapId);

        ((RMGroupHelperServiceImpl) md.mocks.verify(mockRMGroupHelperService, 1))
            .createGroup(
                graphData.text,
                graphData.text,
                'tempkeyabcdefgh',
                null,
                md.mockRelationshipMapId,
                graphData.groupLayout
            );
        ((RMGroupHelperServiceImpl) md.mocks.verify(mockRMGroupHelperService, 1))
            .removeGroupRelationships(new Set<String>(idList), md.mockRelationshipMapId);
        ((RMGroupHelperServiceImpl) md.mocks.verify(mockRMGroupHelperService, 1))
            .addObjectsToGroup(newGroup.Id, idList, md.mockRelationshipMapId);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerDirty((List<Relationship_Group__c>) fflib_Match.anyList());
        System.assert(true, 'verify covering all the test cases');
    }

    @isTest
    public static void updateGroupNameTest() {
        TestMockData md = new TestMockData();
        RelationshipGroupSelector mockRelationshipGroupSelector = md.mockRelationshipGroupSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        GraphNodeData graphData = new GraphNodeData('tempkeyabcdefgh', 'groupKey', 'label', 'horizontal');
        String name = 'newGroupName';

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipGroupSelector.selectByIdORTempKey(new Set<String>{ graphData.key }))
            .thenReturn(new List<Relationship_Group__c>{ md.mockRelationshipGroup });
        md.mocks.stopStubbing();

        RelationshipGroupService.updateGroupName(graphData, name);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerDirty((List<Relationship_Group__c>) fflib_Match.anyList());
        System.assert(true, 'verify covering all the test cases');
    }

    @isTest
    public static void addContactsToGroupTest() {
        TestMockData md = new TestMockData();
        RMGroupHelperServiceImpl mockRMGroupHelperService = md.mockRMGroupHelperService;
        RelationshipGroupSelector mockRelationshipGroupSelector = md.mockRelationshipGroupSelector;

        GraphNodeData graphData = new GraphNodeData('tempkeyabcdefgh', 'groupKey', 'label', 'horizontal');
        List<String> contactIds = new List<String>{ md.mockContactId };

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipGroupSelector.selectByIdORTempKey(new Set<String>{ graphData.key }))
            .thenReturn(new List<Relationship_Group__c>{ md.mockRelationshipGroup });
        md.mocks.stopStubbing();

        RelationshipGroupService.addContactsToGroup(graphData, contactIds, md.mockRelationshipMapId);

        ((RMGroupHelperServiceImpl) md.mocks.verify(mockRMGroupHelperService, 1))
            .removeGroupRelationships(new Set<String>(contactIds), md.mockRelationshipMapId);
        ((RMGroupHelperServiceImpl) md.mocks.verify(mockRMGroupHelperService, 1))
            .addObjectsToGroup(md.mockRelationshipGroup.Id, contactIds, md.mockRelationshipMapId);

        System.assert(true, 'verify covering all the test cases');
    }

    @isTest
    public static void addGroupsToGroupTest() {
        TestMockData md = new TestMockData();
        RelationshipGroupSelector mockRelationshipGroupSelector = md.mockRelationshipGroupSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        GraphNodeData graphData = new GraphNodeData(
            md.mockRelationshipGroupParentId,
            'groupKey',
            'label',
            'horizontal'
        );
        List<String> groupIds = new List<String>{ md.mockRelationshipGroupId };

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipGroupSelector.selectByIdORTempKey(new Set<String>{ graphData.key }))
            .thenReturn(new List<Relationship_Group__c>{ md.mockRelationshipGroupParent });
        md.mocks.when(mockRelationshipGroupSelector.selectByIdORTempKey(new Set<String>{ md.mockRelationshipGroupId }))
            .thenReturn(new List<Relationship_Group__c>{ md.mockRelationshipGroup });
        md.mocks.stopStubbing();

        RelationshipGroupService.addGroupsToGroup(graphData, groupIds);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerDirty((List<Relationship_Group_Contact_Association__c>) fflib_Match.anyList());
        System.assert(true, 'verify covering all the test cases');
    }

    @isTest
    public static void removeNodesFromGroupTest() {
        TestMockData md = new TestMockData();
        RMGroupHelperServiceImpl mockRMGroupHelperService = md.mockRMGroupHelperService;

        GraphNodeData graphData1 = new GraphNodeData('a', 'groupKey', 'label', 'horizontal');
        GraphNodeData graphData2 = new GraphNodeData('b', 'groupKey', 'label', 'horizontal');
        GraphNodeData graphData3 = new GraphNodeData('c', 'groupKey', 'label', 'horizontal');
        List<GraphNodeData> gndList = new List<GraphNodeData>{ graphData1, graphData2, graphData3 };

        RelationshipGroupService.removeNodesFromGroup(gndList);

        ((RMGroupHelperServiceImpl) md.mocks.verify(mockRMGroupHelperService, 1))
            .removeContactsFromGroup((Map<String, String>) fflib_Match.anyObject());
        ((RMGroupHelperServiceImpl) md.mocks.verify(mockRMGroupHelperService, 1))
            .removePlaceholdersFromGroup((Map<String, String>) fflib_Match.anyObject());
        ((RMGroupHelperServiceImpl) md.mocks.verify(mockRMGroupHelperService, 1))
            .removeUsersFromGroup((Map<String, String>) fflib_Match.anyObject());
        ((RMGroupHelperServiceImpl) md.mocks.verify(mockRMGroupHelperService, 1))
            .removeLeadsFromGroup((Map<String, String>) fflib_Match.anyObject());
        ((RMGroupHelperServiceImpl) md.mocks.verify(mockRMGroupHelperService, 1))
            .removeGroupsFromGroup((Map<String, String>) fflib_Match.anyObject());
        System.assert(true, 'verify covering all the test cases');
    }

    @isTest
    public static void getAllGroupsTestForGlobal() {
        TestMockData md = new TestMockData();
        RelationshipGroupSelector mockRelationshipGroupSelector = md.mockRelationshipGroupSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test

        Map<Id, Relationship_Group__c> relGroups = new Map<Id, Relationship_Group__c>();
        relGroups.put(md.mockRelationshipGroupId, md.mockRelationshipGroup);

        RM_Chart_Setting__c settings = new RM_Chart_Setting__c(Is_Group_Global_Scope__c = true);

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipGroupSelector.selectAllGlobalGroups())
            .thenReturn(new List<Relationship_Group__c>{ md.mockRelationshipGroup });
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(settings);
        md.mocks.stopStubbing();

        Map<Id, Relationship_Group__c> result = RelationshipGroupService.getAllGroups(
            relGroups,
            md.mockRelationshipMapId
        );

        System.assertEquals(1, result.size());
    }

    @isTest
    public static void getAllGroupsTestForLocal() {
        TestMockData md = new TestMockData();
        RelationshipGroupSelector mockRelationshipGroupSelector = md.mockRelationshipGroupSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test

        RM_Chart_Setting__c settings = new RM_Chart_Setting__c(Is_Group_Global_Scope__c = false);

        Map<Id, Relationship_Group__c> relGroups = new Map<Id, Relationship_Group__c>();
        relGroups.put(md.mockRelationshipGroupId, md.mockRelationshipGroup);

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipGroupSelector.selectAllLocalGroups(md.mockRelationshipMapId))
            .thenReturn(new List<Relationship_Group__c>{ md.mockRelationshipGroup });
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(settings);
        md.mocks.stopStubbing();

        Map<Id, Relationship_Group__c> result = RelationshipGroupService.getAllGroups(
            relGroups,
            md.mockRelationshipMapId
        );

        System.assertEquals(1, result.size());
    }

    @isTest
    public static void convertLeadsToContactGroupsTest() {
        TestMockData md = new TestMockData();
        RelationshipGroupLeadSelector mockRelationshipGroupLeadSelector = md.mockRelationshipGroupLeadSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        Map<Id, Id> leadContactMap = new Map<Id, Id>();
        leadContactMap.put(md.mockLeadId, md.mockContactId);

        List<Relationship_Group_Lead_Association__c> relationshipGroupLeadAssociations = new List<Relationship_Group_Lead_Association__c>{
            new Relationship_Group_Lead_Association__c(
                Relationship_Group__c = md.mockRelationshipGroupId,
                Lead__c = md.mockLeadId
            )
        };

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipGroupLeadSelector.selectByLeadIds(new Set<String>{ md.mockLeadId }))
            .thenReturn(relationshipGroupLeadAssociations);
        md.mocks.stopStubbing();

        RelationshipGroupService.convertLeadsToContactGroups(new Set<String>{ md.mockLeadId }, leadContactMap);

        Relationship_Group_Contact_Association__c newGroupContactAssociation = new Relationship_Group_Contact_Association__c(
            Contact__c = md.mockContactId,
            Relationship_Group__c = md.mockRelationshipGroupId
        );

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew(newGroupContactAssociation);
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDeleted(relationshipGroupLeadAssociations);

        System.assert(true, 'Assert verified by mocks');
    }

    // Testing not finding a group to update
    @isTest
    public static void updateGroupLayoutTest1() {
        TestMockData md = new TestMockData();
        RelationshipGroupSelector mockRelationshipGroupSelector = md.mockRelationshipGroupSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test

        String groupId = 'a';
        String type = 'Horizontal';

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipGroupSelector.selectByIdORTempKey(new Set<String>{ groupId }))
            .thenReturn(new List<Relationship_Group__c>());
        md.mocks.stopStubbing();

        RelationshipGroupService.updateGroupLayout(groupId, type);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0)).registerDirty(new List<Relationship_Group__c>());
        System.assert(true, 'Assert verified by mocks');
    }

    // Testing happy path
    @isTest
    public static void updateGroupLayoutTest2() {
        TestMockData md = new TestMockData();
        RelationshipGroupSelector mockRelationshipGroupSelector = md.mockRelationshipGroupSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test

        String groupId = 'a';
        String type = 'Horizontal';

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipGroupSelector.selectByIdORTempKey(new Set<String>{ groupId }))
            .thenReturn(new List<Relationship_Group__c>{ md.mockRelationshipGroup });
        md.mocks.stopStubbing();

        RelationshipGroupService.updateGroupLayout(groupId, type);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerDirty(new List<Relationship_Group__c>{ md.mockRelationshipGroup });
        System.assert(true, 'Assert verified by mocks');
    }

    @isTest
    public static void getGroupsForContactIdTest() {
        TestMockData md = new TestMockData();
        RelationshipGroupContactSelector mockRelationshipGroupContactSelector = md.mockRelationshipGroupContactSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test

        RelationshipGroupService.getGroupsForContactId(md.mockContactId);

        ((RelationshipGroupContactSelector) md.mocks.verify(mockRelationshipGroupContactSelector, 1))
            .selectWithGroupsByContactIds(new Set<Id>{ md.mockContactId });
        System.assert(true, 'Assert verified by mocks');
    }
}