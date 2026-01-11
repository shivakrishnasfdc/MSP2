@isTest
private class MapMemberLeadServiceTest {
    public static final String ADMIN_USER1_FIRST_NAME = 'SamStandard';
    public static final String ADMIN_USER1_LAST_NAME = 'Sunlock';
    public static final String NO_PERM_FIRST_NAME = 'First';
    public static final String NO_PERM_LAST_NAME = 'Last';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User adminUser1 = TestDataFactory.createUser(ADMIN_USER1_FIRST_NAME, ADMIN_USER1_LAST_NAME, standardProfile.Id);
        TestDataFactory.createUser(NO_PERM_FIRST_NAME, NO_PERM_LAST_NAME, standardProfile.Id);

        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];

        // Assigning two users with the admin perm set and one user with the standard perm set
        List<PermissionSetAssignment> permissionSets = new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = adminUser1.Id, PermissionSetId = adminUserPermissionSet.Id)
        };
        insert permissionSets;
    }

    @isTest
    static void createLeadsForMapNullTest() {
        GraphData gd = null;
        Id relationshipMapId = null;
        Map<String, String> mapInfluence = null;
        Map<String, String> mapSupport = null;

        GraphData result = MapMemberLeadService.createLeadsForMap(gd, relationshipMapId, mapInfluence, mapSupport);
        System.assertEquals(new GraphData(), result);
    }

    @isTest
    static void createLeadsForMapTest() {
        testMockData md = new testMockData();
        LeadSelector mockLeadSelector = md.mockLeadSelector;
        GraphDataLeadServiceImpl mockGraphDataLeadService = md.mockGraphDataLeadService;
        RMNodeCoordinateServiceImpl mockRMNodeCoordinateService = md.mockRMNodeCoordinateService;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        GraphNodeData graphData1 = new GraphNodeData(leadId, 'groupKey', 'label', 'horizontal');
        GraphData gd = new GraphData();
        gd.nodeDataArray = new List<GraphNodeData>{ graphData1 };
        Id relationshipMapId = md.mockRelationshipMapId;
        Map<String, String> mapInfluence = new Map<String, String>();
        Map<String, String> mapSupport = new Map<String, String>();

        Map<Id, IRelationshipMapLeadObject2> mapOfLeadAndMapmembers = new Map<Id, IRelationshipMapLeadObject2>();
        Map_Member_Lead__c mapMemberLead = new Map_Member_Lead__c(
            Relationship_Map__c = relationshipMapId,
            Lead__c = leadId
        );
        MapMemberLeadWrapper wrapper = new MapMemberLeadWrapper(mapMemberLead);
        mapOfLeadAndMapmembers.put(leadId, wrapper);

        md.mocks.startStubbing();
        md.mocks.when(mockLeadSelector.selectById(new Set<Id>{ leadId })).thenReturn(new List<Lead>());
        md.mocks.stopStubbing();

        MapMemberLeadService.createLeadsForMap(gd, relationshipMapId, mapInfluence, mapSupport);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew((Map_Member_Lead__c) fflib_Match.anyObject());
        ((RMNodeCoordinateServiceImpl) md.mocks.verify(mockRMNodeCoordinateService, 1))
            .updateNodeCoordinates(relationshipMapId, gd.nodeDataArray);
        ((GraphDataLeadServiceImpl) md.mocks.verify(mockGraphDataLeadService, 1))
            .createGraphDataNodes(new List<Lead>(), mapOfLeadAndMapmembers, null, relationshipMapId);
        System.assert(true, 'Asserts from mock verify');
    }

    @isTest
    static void createLeadsForAccountPlanNullTest() {
        GraphData gd = null;
        Id accountPlanId = null;
        Map<String, String> mapInfluence = null;
        Map<String, String> mapSupport = null;

        GraphData result = MapMemberLeadService.createLeadsForAccountPlan(gd, accountPlanId, mapInfluence, mapSupport);
        System.assertEquals(new GraphData(), result);
    }

    @isTest
    static void createLeadsForAccountPlanTest() {
        testMockData md = new testMockData();
        LeadSelector mockLeadSelector = md.mockLeadSelector;
        GraphDataLeadServiceImpl mockGraphDataLeadService = md.mockGraphDataLeadService;
        RMNodeCoordinateServiceImpl mockRMNodeCoordinateService = md.mockRMNodeCoordinateService;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        GraphNodeData graphData1 = new GraphNodeData(leadId, 'groupKey', 'label', 'horizontal');
        GraphData gd = new GraphData();
        gd.nodeDataArray = new List<GraphNodeData>{ graphData1 };
        Id accountPlanId = md.mockAccountPlanId;
        Map<String, String> mapInfluence = new Map<String, String>();
        Map<String, String> mapSupport = new Map<String, String>();

        Map<Id, IRelationshipMapLeadObject2> mapOfLeadAndKS = new Map<Id, IRelationshipMapLeadObject2>();
        Key_Stakeholder_Lead__c ksLead = new Key_Stakeholder_Lead__c(Account_Plan__c = accountPlanId, Lead__c = leadId);
        StakeholderLeadWrapper wrapper = new StakeholderLeadWrapper(ksLead);
        mapOfLeadAndKS.put(leadId, wrapper);

        md.mocks.startStubbing();
        md.mocks.when(mockLeadSelector.selectById(new Set<Id>{ leadId })).thenReturn(new List<Lead>());
        md.mocks.stopStubbing();

        MapMemberLeadService.createLeadsForAccountPlan(gd, accountPlanId, mapInfluence, mapSupport);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew((Key_Stakeholder_Lead__c) fflib_Match.anyObject());
        ((RMNodeCoordinateServiceImpl) md.mocks.verify(mockRMNodeCoordinateService, 1))
            .updateNodeCoordinates(accountPlanId, gd.nodeDataArray);
        ((GraphDataLeadServiceImpl) md.mocks.verify(mockGraphDataLeadService, 1))
            .createGraphDataNodes(new List<Lead>(), mapOfLeadAndKS, null, accountPlanId);
        System.assert(true, 'Asserts from mock verify');
    }

    @isTest
    static void deleteMapMemberLeadsTest() {
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        MapMemberLeadSelector mockMapMemberLeadSelector = md.mockMapMemberLeadSelector;

        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        List<String> input = new List<String>{ leadId };
        Set<Id> inputSet = new Set<Id>{ leadId };
        List<Map_Member_Lead__c> mmLeads = new List<Map_Member_Lead__c>{ md.mockMapMemberLead };

        md.mocks.startStubbing();
        md.mocks.when(mockMapMemberLeadSelector.selectByLeadId(inputSet)).thenReturn(mmLeads);
        md.mocks.stopStubbing();

        MapMemberLeadService.deleteMapMemberLeads(input);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDeleted(mmLeads);
        System.assert(true, 'Asserts from mock verify');
    }

    @isTest
    static void deleteKeyStakeholderLeadsTest() {
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        KeyStakeholderLeadSelector mockKeyStakeholderLeadSelector = md.mockKeyStakeholderLeadSelector;

        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        List<String> input = new List<String>{ leadId };
        Set<Id> inputSet = new Set<Id>{ leadId };
        List<Key_Stakeholder_Lead__c> mmLeads = new List<Key_Stakeholder_Lead__c>{ md.mockKeyStakeholderLead };

        md.mocks.startStubbing();
        md.mocks.when(mockKeyStakeholderLeadSelector.selectByLeadId(inputSet)).thenReturn(mmLeads);
        md.mocks.stopStubbing();

        MapMemberLeadService.deleteKeyStakeholderLeads(input);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDeleted(mmLeads);
        System.assert(true, 'Asserts from mock verify');
    }

    @isTest
    static void getAndInjectMapMemberLeadNodesNoPermTest() {
        testMockData md = new testMockData();

        User noPermUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :NO_PERM_FIRST_NAME AND LastName = :NO_PERM_LAST_NAME
            LIMIT 1
        ];

        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        GraphNodeData graphData1 = new GraphNodeData(leadId, 'groupKey', 'label', 'horizontal');
        GraphData gd = new GraphData();
        gd.nodeDataArray = new List<GraphNodeData>{ graphData1 };
        Id relationshipMapId = md.mockRelationshipMapId;
        Map<String, String> mapInfluence = new Map<String, String>();
        Map<String, String> mapSupport = new Map<String, String>();

        GraphData result;
        System.runAs(noPermUser) {
            result = MapMemberLeadService.getAndInjectMapMemberLeadNodes(
                gd,
                relationshipMapId,
                mapInfluence,
                mapSupport
            );
        }

        System.assertEquals(gd, result);
    }

    @isTest
    static void getAndInjectMapMemberLeadNodesNullTest() {
        testMockData md = new testMockData();

        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER1_FIRST_NAME AND LastName = :ADMIN_USER1_LAST_NAME
            LIMIT 1
        ];

        Id relationshipMapId = md.mockRelationshipMapId;
        Map<String, String> mapInfluence = new Map<String, String>();
        Map<String, String> mapSupport = new Map<String, String>();

        GraphData result;
        System.runAs(adminUser) {
            result = MapMemberLeadService.getAndInjectMapMemberLeadNodes(
                null,
                relationshipMapId,
                mapInfluence,
                mapSupport
            );
        }

        System.assertEquals(null, result);
    }

    @isTest
    static void getAndInjectMapMemberLeadNodesTest() {
        testMockData md = new testMockData();
        MapMemberLeadSelector mockMapMemberLeadSelector = md.mockMapMemberLeadSelector;
        LeadSelector mockLeadSelector = md.mockLeadSelector;
        RelationshipGroupLeadSelector mockRelationshipGroupLeadSelector = md.mockRelationshipGroupLeadSelector;
        GraphDataLeadServiceImpl mockGraphDataLeadService = md.mockGraphDataLeadService;

        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER1_FIRST_NAME AND LastName = :ADMIN_USER1_LAST_NAME
            LIMIT 1
        ];

        Id leadId = md.mockMapMemberLead.Lead__c;
        GraphNodeData graphData1 = new GraphNodeData(leadId, 'groupKey', 'label', 'horizontal');
        GraphData gd = new GraphData();
        gd.nodeDataArray = new List<GraphNodeData>{ graphData1 };
        Id relationshipMapId = md.mockRelationshipMapId;
        Map<String, String> mapInfluence = new Map<String, String>();
        Map<String, String> mapSupport = new Map<String, String>();

        List<Map_Member_Lead__c> mmLeads = new List<Map_Member_Lead__c>{ md.mockMapMemberLead };
        List<Relationship_Group_Lead_Association__c> groupRel = new List<Relationship_Group_Lead_Association__c>();

        Map<Id, IRelationshipMapLeadObject2> mapOfLeadAndMapmembers = new Map<Id, IRelationshipMapLeadObject2>();
        MapMemberLeadWrapper wrapper = new MapMemberLeadWrapper(mmLeads[0]);
        mapOfLeadAndMapmembers.put(leadId, wrapper);

        md.mocks.startStubbing();
        md.mocks.when(mockMapMemberLeadSelector.selectByRelationshipMaps(new Set<Id>{ relationshipMapId }))
            .thenReturn(mmLeads);
        md.mocks.when(mockLeadSelector.selectById(new Set<Id>{ leadId })).thenReturn(new List<Lead>());
        md.mocks.when(mockRelationshipGroupLeadSelector.selectWithGroupsByLeadIds(new Set<Id>{ mmLeads[0].Lead__c }))
            .thenReturn(groupRel);
        md.mocks.stopStubbing();

        GraphData result;
        System.runAs(adminUser) {
            result = MapMemberLeadService.getAndInjectMapMemberLeadNodes(
                gd,
                relationshipMapId,
                mapInfluence,
                mapSupport
            );
        }

        ((GraphDataLeadServiceImpl) md.mocks.verify(mockGraphDataLeadService, 1))
            .createGraphDataNodes(new List<Lead>(), mapOfLeadAndMapmembers, groupRel, relationshipMapId);

        System.assertNotEquals(null, result);
    }

    @isTest
    static void getAndInjectKeyStakeholderLeadNodesNoPermTest() {
        testMockData md = new testMockData();

        User noPermUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :NO_PERM_FIRST_NAME AND LastName = :NO_PERM_LAST_NAME
            LIMIT 1
        ];

        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        GraphNodeData graphData1 = new GraphNodeData(leadId, 'groupKey', 'label', 'horizontal');
        GraphData gd = new GraphData();
        gd.nodeDataArray = new List<GraphNodeData>{ graphData1 };
        Id accountPlanId = md.mockAccountPlanId;
        Map<String, String> mapInfluence = new Map<String, String>();
        Map<String, String> mapSupport = new Map<String, String>();

        GraphData result;
        System.runAs(noPermUser) {
            result = MapMemberLeadService.getAndInjectKeyStakeholderLeadNodes(
                gd,
                accountPlanId,
                mapInfluence,
                mapSupport
            );
        }

        System.assertEquals(gd, result);
    }

    @isTest
    static void getAndInjectKeyStakeholderLeadNodesNullTest() {
        testMockData md = new testMockData();

        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER1_FIRST_NAME AND LastName = :ADMIN_USER1_LAST_NAME
            LIMIT 1
        ];

        Id accountPlanId = md.mockAccountPlanId;
        Map<String, String> mapInfluence = new Map<String, String>();
        Map<String, String> mapSupport = new Map<String, String>();

        GraphData result;
        System.runAs(adminUser) {
            result = MapMemberLeadService.getAndInjectKeyStakeholderLeadNodes(
                null,
                accountPlanId,
                mapInfluence,
                mapSupport
            );
        }

        System.assertEquals(null, result);
    }

    @isTest
    static void getAndInjectKeyStakeholderLeadNodesTest() {
        testMockData md = new testMockData();
        KeyStakeholderLeadSelector mockKeyStakeholderLeadSelector = md.mockKeyStakeholderLeadSelector;
        LeadSelector mockLeadSelector = md.mockLeadSelector;
        RelationshipGroupLeadSelector mockRelationshipGroupLeadSelector = md.mockRelationshipGroupLeadSelector;
        GraphDataLeadServiceImpl mockGraphDataLeadService = md.mockGraphDataLeadService;

        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER1_FIRST_NAME AND LastName = :ADMIN_USER1_LAST_NAME
            LIMIT 1
        ];

        Id leadId = md.mockKeyStakeholderLead.Lead__c;
        GraphNodeData graphData1 = new GraphNodeData(leadId, 'groupKey', 'label', 'horizontal');
        GraphData gd = new GraphData();
        gd.nodeDataArray = new List<GraphNodeData>{ graphData1 };
        Id accountPlanId = md.mockAccountPlanId;
        Map<String, String> mapInfluence = new Map<String, String>();
        Map<String, String> mapSupport = new Map<String, String>();

        List<Key_Stakeholder_Lead__c> ksLeads = new List<Key_Stakeholder_Lead__c>{ md.mockKeyStakeholderLead };
        List<Relationship_Group_Lead_Association__c> groupRel = new List<Relationship_Group_Lead_Association__c>();

        Map<Id, IRelationshipMapLeadObject2> mapOfLeadAndMapmembers = new Map<Id, IRelationshipMapLeadObject2>();
        StakeholderLeadWrapper wrapper = new StakeholderLeadWrapper(ksLeads[0]);
        mapOfLeadAndMapmembers.put(leadId, wrapper);

        md.mocks.startStubbing();
        md.mocks.when(mockKeyStakeholderLeadSelector.selectByAccountPlans(new Set<Id>{ accountPlanId }))
            .thenReturn(ksLeads);
        md.mocks.when(mockLeadSelector.selectById(new Set<Id>{ ksLeads[0].Lead__c })).thenReturn(new List<Lead>());
        md.mocks.when(mockRelationshipGroupLeadSelector.selectWithGroupsByLeadIds(new Set<Id>{ ksLeads[0].Lead__c }))
            .thenReturn(groupRel);
        md.mocks.stopStubbing();

        GraphData result;
        System.runAs(adminUser) {
            result = MapMemberLeadService.getAndInjectKeyStakeholderLeadNodes(
                gd,
                accountPlanId,
                mapInfluence,
                mapSupport
            );
        }

        ((GraphDataLeadServiceImpl) md.mocks.verify(mockGraphDataLeadService, 1))
            .createGraphDataNodes(new List<Lead>(), mapOfLeadAndMapmembers, groupRel, accountPlanId);

        System.assertNotEquals(null, result);
    }

    @isTest
    static void convertLeadsToMapMembersTest() {
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER1_FIRST_NAME AND LastName = :ADMIN_USER1_LAST_NAME
            LIMIT 1
        ];

        testMockData md = new testMockData();
        MapMemberLeadSelector mockMapMemberLeadSelector = md.mockMapMemberLeadSelector;
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService; //NOPMD - Needs to be called in order for it to be mocked in the test
        RelationshipGroupServiceImpl mockRelationshipGroupService = md.mockRelationshipGroupService; //NOPMD - Needs to be called in order for it to be mocked in the test
        MapMemberPlaceholderServiceImpl mockMapMemberPlaceholderService = md.mockMapMemberPlaceholderService; //NOPMD - Needs to be called in order for it to be mocked in the test
        RMNodeCoordinateServiceImpl mockRMNodeCoordinateServiceImpl = md.mockRMNodeCoordinateService; //NOPMD - Needs to be called in order for it to be mocked in the test

        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        List<Map_Member_Lead__c> mmLeads = new List<Map_Member_Lead__c>{ md.mockMapMemberLead };

        md.mocks.startStubbing();
        md.mocks.when(
                mockMapMemberLeadSelector.selectConvertedLeadsByRelationshipMaps(
                    new Set<Id>{ md.mockRelationshipMapId }
                )
            )
            .thenReturn(mmLeads);
        md.mocks.stopStubbing();

        System.runAs(adminUser) {
            MapMemberLeadService.convertLeadsToMapMembers(md.mockRelationshipMapId);
        }

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerDeleted((List<Map_Member_Lead__c>) fflib_Match.anyList());

        System.assert(true, 'Asserts from mock verify');
    }

    @isTest
    static void convertLeadsToMapMembersNoPermTest() {
        User noPermUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :NO_PERM_FIRST_NAME AND LastName = :NO_PERM_LAST_NAME
            LIMIT 1
        ];

        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        System.runAs(noPermUser) {
            MapMemberLeadService.convertLeadsToMapMembers(md.mockRelationshipMapId);
        }

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0))
            .registerDeleted((List<Map_Member_Lead__c>) fflib_Match.anyList());

        System.assert(true, 'Asserts from mock verify');
    }

    @isTest
    static void convertLeadsToKeyStakeholdersNoPermTest() {
        User noPermUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :NO_PERM_FIRST_NAME AND LastName = :NO_PERM_LAST_NAME
            LIMIT 1
        ];

        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        System.runAs(noPermUser) {
            MapMemberLeadService.convertLeadsToKeyStakeholders(md.mockAccountPlanId);
        }

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0))
            .registerDeleted((List<Key_Stakeholder_Lead__c>) fflib_Match.anyList());

        System.assert(true, 'Asserts from mock verify');
    }

    @isTest
    static void convertLeadsToKeyStakeholdersTest() {
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER1_FIRST_NAME AND LastName = :ADMIN_USER1_LAST_NAME
            LIMIT 1
        ];

        testMockData md = new testMockData();
        KeyStakeholderLeadSelector mockKeyStakeholderLeadSelector = md.mockKeyStakeholderLeadSelector;
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService; //NOPMD - Needs to be called in order for it to be mocked in the test
        RelationshipGroupServiceImpl mockRelationshipGroupService = md.mockRelationshipGroupService; //NOPMD - Needs to be called in order for it to be mocked in the test
        MapMemberPlaceholderServiceImpl mockMapMemberPlaceholderService = md.mockMapMemberPlaceholderService; //NOPMD - Needs to be called in order for it to be mocked in the test
        RMNodeCoordinateServiceImpl mockRMNodeCoordinateServiceImpl = md.mockRMNodeCoordinateService; //NOPMD - Needs to be called in order for it to be mocked in the test

        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        List<Key_Stakeholder_Lead__c> ksLeads = new List<Key_Stakeholder_Lead__c>{ md.mockKeyStakeholderLead };

        md.mocks.startStubbing();
        md.mocks.when(
                mockKeyStakeholderLeadSelector.selectConvertedLeadsByAccountPlans(new Set<Id>{ md.mockAccountPlanId })
            )
            .thenReturn(ksLeads);
        md.mocks.stopStubbing();

        System.runAs(adminUser) {
            MapMemberLeadService.convertLeadsToKeyStakeholders(md.mockAccountPlanId);
        }

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerDeleted((List<Key_Stakeholder_Lead__c>) fflib_Match.anyList());

        System.assert(true, 'Asserts from mock verify');
    }
}