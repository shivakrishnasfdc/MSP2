@SuppressWarnings('PMD.ExcessivePublicCount')
@IsTest
private class GraphDataServiceTest {
    /**************************
     *** getSupportColors() ***
     *************************/

    @isTest
    public static void getSupportColorsNullSettingsTest() {
        testMockData md = new testMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(null);
        md.mocks.stopStubbing();

        Map<String, String> returnedColors = GraphDataService.getSupportColors();

        System.assertEquals(
            0,
            returnedColors.size(),
            'If settings are somehow null then support colors should be an empty map'
        );
    }

    @isTest
    public static void getSupportColorsNullColorsTest() {
        testMockData md = new testMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        Map<String, String> returnedColors = GraphDataService.getSupportColors();

        System.assertEquals(
            0,
            returnedColors.size(),
            'If colors are somehow null then support colors should be an empty map'
        );
    }

    @isTest
    public static void getSupportColorsEmptyColorsTest() {
        testMockData md = new testMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;

        md.mockSettings.pqcrush__Support_Colors_Long__c = '';

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        Map<String, String> returnedColors = GraphDataService.getSupportColors();

        System.assertEquals(
            0,
            returnedColors.size(),
            'If colors are somehow empty then support colors should be an empty map'
        );
    }

    @isTest
    public static void getSupportColorsHappyPathTest() {
        testMockData md = new testMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;

        Map<String, String> mapToConvert = new Map<String, String>();
        mapToConvert.put('Champion', '#eeeeee');
        mapToConvert.put('Floater', '#2a479e');
        mapToConvert.put('Supporter', '#c43d20');
        mapToConvert.put('Blocker', '#000000');

        md.mockSettings.pqcrush__Support_Colors_Long__c = UtilityForString.parseMapToNameValueString(mapToConvert);

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        Map<String, String> returnedColors = GraphDataService.getSupportColors();

        System.assertEquals(
            mapToConvert,
            returnedColors,
            'The returned support colors should match the map that was set'
        );
    }

    /******************************************
     *** getContactGraphDataForSearchTerm() ***
     ******************************************/
    @isTest
    public static void getContactGraphDataForSearchTermEmptyTest() {
        TestMockData md = new TestMockData();
        ContactSelector mockContactSelector = md.mockContactSelector;
        RelationshipGroupContactSelector mockRelationshipGroupContactSelector = md.mockRelationshipGroupContactSelector;
        AccountServiceImpl mockAccountService = md.mockAccountService;
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;

        String searchTerm = '';
        List<String> excludeIds = new List<String>();
        Set<String> additionalFields = new Set<String>{ 'Name' };
        List<Org_Chart_Field__c> orgChartfields = new List<Org_Chart_Field__c>();
        Integer max = 100;

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMapId)).thenReturn(false);
        md.mocks.when(
                mockContactSelector.selectByAccountIdWithAdditionalFields(
                    new Set<Id>(),
                    additionalFields,
                    max,
                    new Set<Id>()
                )
            )
            .thenReturn(new List<Contact>{ md.mockContact });
        md.mocks.when(
                mockContactSelector.selectByIdAndSelectFields(
                    new Set<Id>{ md.mockContact.ReportsToId },
                    additionalFields
                )
            )
            .thenReturn(new List<Contact>{ md.mockContact });
        md.mocks.when(
                mockRelationshipGroupContactSelector.selectWithGroupsByContactIds(
                    new Set<Id>{ md.mockContact.Id, md.mockContact.ReportsToId }
                )
            )
            .thenReturn(
                new List<Relationship_Group_Contact_Association__c>{ md.mockRelationshipGroupContactAssociation }
            );
        md.mocks.when(mockContactSelector.selectByReportsToId(new Set<Id>{ md.mockContact.Id }, new Set<String>()))
            .thenReturn(new List<Contact>{ md.mockContact });
        md.mocks.when(mockAccountService.getAccountAndDescendents(null)).thenReturn(new Set<Id>());
        md.mocks.stopStubbing();

        GraphData result = GraphDataService.getContactGraphDataForSearchTerm(
            searchTerm,
            excludeIds,
            null,
            orgChartfields,
            additionalFields,
            null
        );

        System.assertEquals(1, result.nodeDataArray.size());
        ((ContactSelector) md.mocks.verify(mockContactSelector, 1))
            .selectByAccountIdWithAdditionalFields(new Set<Id>(), additionalFields, max, new Set<Id>());
        ((ContactSelector) md.mocks.verify(mockContactSelector, 1))
            .selectByIdAndSelectFields(new Set<Id>{ md.mockContact.ReportsToId }, additionalFields);
        ((RelationshipGroupContactSelector) md.mocks.verify(mockRelationshipGroupContactSelector, 1))
            .selectWithGroupsByContactIds(new Set<Id>{ md.mockContact.Id, md.mockContact.ReportsToId });
        ((ContactSelector) md.mocks.verify(mockContactSelector, 1))
            .selectByReportsToId(new Set<Id>{ md.mockContact.Id }, new Set<String>());
    }

    @isTest
    public static void getContactGraphDataForSearchTermTest() {
        TestMockData md = new TestMockData();
        ContactSelector mockContactSelector = md.mockContactSelector;
        RelationshipGroupContactSelector mockRelationshipGroupContactSelector = md.mockRelationshipGroupContactSelector;
        AccountServiceImpl mockAccountService = md.mockAccountService;
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;

        String searchTerm = 'abcde';
        List<String> excludeIds = new List<String>();
        Set<String> additionalFields = new Set<String>{ 'Name' };
        List<Org_Chart_Field__c> orgChartfields = new List<Org_Chart_Field__c>();
        Integer max = 100;

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMapId)).thenReturn(false);
        md.mocks.when(mockContactSelector.search(searchTerm, new Set<Id>(), additionalFields, max, new Set<Id>()))
            .thenReturn(new List<Contact>{ md.mockContact });
        md.mocks.when(
                mockContactSelector.selectByIdAndSelectFields(
                    new Set<Id>{ md.mockContact.ReportsToId },
                    additionalFields
                )
            )
            .thenReturn(new List<Contact>{ md.mockContact });
        md.mocks.when(
                mockRelationshipGroupContactSelector.selectWithGroupsByContactIds(
                    new Set<Id>{ md.mockContact.Id, md.mockContact.ReportsToId }
                )
            )
            .thenReturn(
                new List<Relationship_Group_Contact_Association__c>{ md.mockRelationshipGroupContactAssociation }
            );
        md.mocks.when(mockContactSelector.selectByReportsToId(new Set<Id>{ md.mockContact.Id }, new Set<String>()))
            .thenReturn(new List<Contact>{ md.mockContact });
        md.mocks.when(mockAccountService.getAccountAndDescendents(null)).thenReturn(new Set<Id>());
        md.mocks.stopStubbing();

        GraphData result = GraphDataService.getContactGraphDataForSearchTerm(
            searchTerm,
            excludeIds,
            null,
            orgChartfields,
            additionalFields,
            null
        );

        System.assertEquals(1, result.nodeDataArray.size());
        ((ContactSelector) md.mocks.verify(mockContactSelector, 1))
            .search(searchTerm, new Set<Id>(), additionalFields, max, new Set<Id>());
        ((ContactSelector) md.mocks.verify(mockContactSelector, 1))
            .selectByIdAndSelectFields(new Set<Id>{ md.mockContact.ReportsToId }, additionalFields);
        ((RelationshipGroupContactSelector) md.mocks.verify(mockRelationshipGroupContactSelector, 1))
            .selectWithGroupsByContactIds(new Set<Id>{ md.mockContact.Id, md.mockContact.ReportsToId });
        ((ContactSelector) md.mocks.verify(mockContactSelector, 1))
            .selectByReportsToId(new Set<Id>{ md.mockContact.Id }, new Set<String>());
    }

    @isTest
    public static void getParentNodesForContactIdsTest() {
        TestMockData md = new TestMockData();
        ContactSelector mockContactSelector = md.mockContactSelector;
        RelationshipGroupContactSelector mockRelationshipGroupContactSelector = md.mockRelationshipGroupContactSelector;
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;

        List<String> contactIdList = new List<String>{ md.mockContactId };
        Set<Id> contactIdSet = new Set<Id>{ md.mockContactId };
        Set<Id> parentIdSet = new Set<Id>{ md.mockParentContactId };
        Set<String> additionalFields = new Set<String>{ 'ReportsToId', 'PhotoUrl' };
        List<Org_Chart_Field__c> orgChartfields = new List<Org_Chart_Field__c>();

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMapId)).thenReturn(false);
        md.mocks.when(mockContactSelector.selectByIdAndSelectFields(contactIdSet, additionalFields))
            .thenReturn(new List<Contact>{ md.mockContact });

        md.mocks.when(mockContactSelector.selectByIdAndSelectFields(parentIdSet, additionalFields))
            .thenReturn(new List<Contact>{ md.mockParentContact });

        md.mocks.when(
                mockRelationshipGroupContactSelector.selectWithGroupsByContactIds(new Set<Id>{ md.mockParentContactId })
            )
            .thenReturn(
                new List<Relationship_Group_Contact_Association__c>{ md.mockRelationshipGroupContactAssociation }
            );
        md.mocks.stopStubbing();

        GraphData result = GraphDataService.getParentNodesForContactIds(
            contactIdList,
            orgChartfields,
            additionalFields,
            null
        );

        System.assertEquals(1, result.nodeDataArray.size());
        System.assertEquals(2, result.linkDataArray.size());
        ((ContactSelector) md.mocks.verify(mockContactSelector, 1))
            .selectByIdAndSelectFields(contactIdSet, additionalFields);
        ((ContactSelector) md.mocks.verify(mockContactSelector, 1))
            .selectByIdAndSelectFields(parentIdSet, additionalFields);
        ((RelationshipGroupContactSelector) md.mocks.verify(mockRelationshipGroupContactSelector, 1))
            .selectWithGroupsByContactIds(new Set<Id>{ md.mockParentContactId });
    }

    /***************************
     *** generateGraphData() ***
     **************************/

    @isTest
    public static void generateGraphDataNullTest() {
        Map<String, String> influenceMap = new Map<String, String>{ 'High' => 'High' };
        Map<String, String> supportMap = new Map<String, String>{ 'Supporter' => 'Supporter' };
        Set<String> contactFieldSet = new Set<String>{ 'Name' };
        List<Org_Chart_Field__c> orgChartfields = new List<Org_Chart_Field__c>();
        RM_Chart_Setting__c setting = new RM_Chart_Setting__c(Show_Parents__c = true, Show_Empty_Fields__c = true);

        GraphData result = GraphDataService.generateGraphData(
            null,
            setting,
            influenceMap,
            supportMap,
            contactFieldSet,
            orgChartfields,
            null
        );

        System.assertEquals(0, result.nodeDataArray.size(), 'Null members means no nodes');
    }

    @isTest
    public static void generateGraphDataEmptyTest() {
        Map<String, String> influenceMap = new Map<String, String>{ 'High' => 'High' };
        Map<String, String> supportMap = new Map<String, String>{ 'Supporter' => 'Supporter' };
        Set<String> contactFieldSet = new Set<String>{ 'Name' };
        List<IRelationshipMapObject> hierarchyObjects = new List<IRelationshipMapObject>();
        List<Org_Chart_Field__c> orgChartfields = new List<Org_Chart_Field__c>();

        RM_Chart_Setting__c setting = new RM_Chart_Setting__c(Show_Parents__c = true, Show_Empty_Fields__c = true);

        GraphData result = GraphDataService.generateGraphData(
            hierarchyObjects,
            setting,
            influenceMap,
            supportMap,
            contactFieldSet,
            orgChartfields,
            null
        );

        System.assertEquals(0, result.nodeDataArray.size(), 'No members means no nodes');
    }

    @isTest
    public static void generateGraphDataTwoMembersOneContactTest() {
        testMockData md = new testMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;
        ContactSelector mockContactSelector = md.mockContactSelector;
        StaticResourceServiceImpl mockResourceService = md.mockStaticResourceService;
        ContactRelationshipServiceImpl mockRelatiobshipService = md.mockContactRelationshipService;
        RelationshipGroupServiceImpl mockRelationshipGroupService = md.mockRelationshipGroupService;
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;

        List<Org_Chart_Field__c> mockFields = new List<Org_Chart_Field__c>{
            md.mockKeyStakeholderOrgChartField,
            md.mockContactOrgChartField
        };
        md.mockSettings.Contacts_Ancestry_Levels__c = 1;
        md.mockContact.ReportsToId = null;
        Map<String, String> influenceMap = new Map<String, String>{ 'High' => 'High' };
        Map<String, String> supportMap = new Map<String, String>{ 'Supporter' => 'Supporter' };
        Set<String> contactFieldSet = new Set<String>{ 'Name' };
        RelationshipMapMemberWrapper chmWrapper1 = new RelationshipMapMemberWrapper(md.mockRelationshipMapMember);
        RelationshipMapMemberWrapper chmWrapper2 = new RelationshipMapMemberWrapper(md.mockRelationshipMapMember);
        List<IRelationshipMapObject> hierarchyObjects = new List<IRelationshipMapObject>{ chmWrapper1, chmWrapper2 };

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMapId)).thenReturn(false);
        md.mocks.when(
                mockRelationshipGroupService.getGroupContactAssocMap(
                    (List<Relationship_Group_Contact_Association__c>) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<Id, Relationship_Group_Contact_Association__c>());
        md.mocks.when(
                mockRelationshipGroupService.getAllGroups(
                    (Map<Id, Relationship_Group__c>) fflib_Match.anyObject(),
                    (Id) fflib_Match.eq(md.mockRelationshipMapId)
                )
            )
            .thenReturn(new Map<Id, Relationship_Group__c>());
        md.mocks.when(
                mockRelationshipGroupService.createNodeDataForGroups(
                    (List<Relationship_Group__c>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<GraphNodeData>());
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(mockContactSelector.selectByIdAndSelectFields(new Set<Id>{ md.mockContactId }, contactFieldSet))
            .thenReturn(new List<Contact>{ md.mockContact });
        md.mocks.when(mockResourceService.getResourceUrlsForResourceNames((Set<String>) fflib_Match.anyObject()))
            .thenReturn(new Map<String, String>());
        md.mocks.when(
                mockRelatiobshipService.getRelationships(
                    (Set<Id>) fflib_Match.anyObject(),
                    (Id) fflib_Match.eq(md.mockRelationshipMapId),
                    (Boolean) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<GraphLinkData>());
        md.mocks.stopStubbing();

        RM_Chart_Setting__c setting = new RM_Chart_Setting__c(Show_Parents__c = true, Show_Empty_Fields__c = true);

        GraphData result = GraphDataService.generateGraphData(
            hierarchyObjects,
            setting,
            influenceMap,
            supportMap,
            contactFieldSet,
            mockFields,
            md.mockRelationshipMapId
        );

        System.assertEquals(1, result.nodeDataArray.size(), 'Should only be one node since it will ignore duplicates');
    }

    @isTest
    public static void generateGraphDataHappyPathSimpleTest() {
        testMockData md = new testMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;
        ContactSelector mockContactSelector = md.mockContactSelector;
        StaticResourceServiceImpl mockResourceService = md.mockStaticResourceService;
        ContactRelationshipServiceImpl mockRelatiobshipService = md.mockContactRelationshipService;
        RelationshipGroupServiceImpl mockRelationshipGroupService = md.mockRelationshipGroupService;
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;

        List<Org_Chart_Field__c> mockFields = new List<Org_Chart_Field__c>{
            md.mockKeyStakeholderOrgChartField,
            md.mockContactOrgChartField
        };
        md.mockSettings.Contacts_Ancestry_Levels__c = 1;
        md.mockContact.ReportsToId = null;
        Map<String, String> influenceMap = new Map<String, String>{ 'High' => 'High' };
        Map<String, String> supportMap = new Map<String, String>{ 'Supporter' => 'Supporter' };
        Set<String> contactFieldSet = new Set<String>{ 'Name' };
        RelationshipMapMemberWrapper chmWrapper = new RelationshipMapMemberWrapper(md.mockRelationshipMapMember);
        List<IRelationshipMapObject> hierarchyObjects = new List<IRelationshipMapObject>{ chmWrapper };

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMapId)).thenReturn(false);
        md.mocks.when(
                mockRelationshipGroupService.getGroupContactAssocMap(
                    (List<Relationship_Group_Contact_Association__c>) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<Id, Relationship_Group_Contact_Association__c>());
        md.mocks.when(
                mockRelationshipGroupService.getAllGroups(
                    (Map<Id, Relationship_Group__c>) fflib_Match.anyObject(),
                    (Id) fflib_Match.eq(md.mockRelationshipMapId)
                )
            )
            .thenReturn(new Map<Id, Relationship_Group__c>());
        md.mocks.when(
                mockRelationshipGroupService.createNodeDataForGroups(
                    (List<Relationship_Group__c>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<GraphNodeData>());
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(mockContactSelector.selectByIdAndSelectFields(new Set<Id>{ md.mockContactId }, contactFieldSet))
            .thenReturn(new List<Contact>{ md.mockContact });
        md.mocks.when(mockResourceService.getResourceUrlsForResourceNames((Set<String>) fflib_Match.anyObject()))
            .thenReturn(new Map<String, String>());
        md.mocks.when(
                mockRelatiobshipService.getRelationships(
                    (Set<Id>) fflib_Match.anyObject(),
                    (Id) fflib_Match.eq(md.mockRelationshipMapId),
                    (Boolean) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<GraphLinkData>());
        md.mocks.stopStubbing();

        RM_Chart_Setting__c setting = new RM_Chart_Setting__c(Show_Parents__c = true, Show_Empty_Fields__c = true);

        GraphData result = GraphDataService.generateGraphData(
            hierarchyObjects,
            setting,
            influenceMap,
            supportMap,
            contactFieldSet,
            mockFields,
            md.mockRelationshipMapId
        );

        System.assertEquals(1, result.nodeDataArray.size(), 'Should only be one node');
        System.assertEquals(0, result.linkDataArray.size(), 'Should be no links');
    }

    @isTest
    public static void generateGraphDataHappyPathComplicatedTest() {
        testMockData md = new testMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;
        ContactSelector mockContactSelector = md.mockContactSelector;
        StaticResourceServiceImpl mockResourceService = md.mockStaticResourceService;
        ContactRelationshipServiceImpl mockContactRelationshipService = md.mockContactRelationshipService;
        RelationshipGroupServiceImpl mockRelationshipGroupService = md.mockRelationshipGroupService;
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;

        List<Org_Chart_Field__c> mockFields = new List<Org_Chart_Field__c>{
            md.mockKeyStakeholderOrgChartField,
            md.mockContactOrgChartField
        };
        md.mockSettings.Contacts_Ancestry_Levels__c = 4;
        Contact mockReportsTo = md.mockContact.clone(false, true);
        mockReportsTo.ReportsToId = null;
        mockReportsTo.Id = md.mockContact.ReportsToId;
        Map<String, String> influenceMap = new Map<String, String>{ 'High' => 'High' };
        Map<String, String> supportMap = new Map<String, String>{ 'Supporter' => 'Supporter' };
        Set<String> contactFieldSet = new Set<String>{ 'Name' };
        RelationshipMapMemberWrapper chmWrapper = new RelationshipMapMemberWrapper(md.mockRelationshipMapMember);
        List<IRelationshipMapObject> hierarchyObjects = new List<IRelationshipMapObject>{ chmWrapper };
        GraphLinkData mockLink = new GraphLinkData(
            fflib_IDGenerator.generate(Contact_Relationship__c.SObjectType),
            null,
            md.mockContactId,
            true,
            mockReportsTo.Id,
            'Custom',
            'The missing link'
        );

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMapId)).thenReturn(false);
        md.mocks.when(
                mockRelationshipGroupService.getGroupContactAssocMap(
                    (List<Relationship_Group_Contact_Association__c>) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<Id, Relationship_Group_Contact_Association__c>());
        md.mocks.when(
                mockRelationshipGroupService.getAllGroups(
                    (Map<Id, Relationship_Group__c>) fflib_Match.anyObject(),
                    (Id) fflib_Match.eq(md.mockRelationshipMapId)
                )
            )
            .thenReturn(new Map<Id, Relationship_Group__c>());
        md.mocks.when(
                mockRelationshipGroupService.createNodeDataForGroups(
                    (List<Relationship_Group__c>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<GraphNodeData>());
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(mockContactSelector.selectByIdAndSelectFields(new Set<Id>{ md.mockContactId }, contactFieldSet))
            .thenReturn(new List<Contact>{ md.mockContact });
        md.mocks.when(mockContactSelector.selectByIdAndSelectFields(new Set<Id>{ mockReportsTo.Id }, contactFieldSet))
            .thenReturn(new List<Contact>{ mockReportsTo });
        md.mocks.when(mockResourceService.getResourceUrlsForResourceNames((Set<String>) fflib_Match.anyObject()))
            .thenReturn(new Map<String, String>());
        md.mocks.when(
                mockContactRelationshipService.getRelationships(
                    (Set<Id>) fflib_Match.anyObject(),
                    (Id) fflib_Match.eq(md.mockRelationshipMapId),
                    (Boolean) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<GraphLinkData>{ mockLink });
        md.mocks.stopStubbing();

        RM_Chart_Setting__c setting = new RM_Chart_Setting__c(
            Is_Reports_To_Global_Scope__c = true,
            Show_Parents__c = true,
            Show_Empty_Fields__c = true
        );

        GraphData result = GraphDataService.generateGraphData(
            hierarchyObjects,
            setting,
            influenceMap,
            supportMap,
            contactFieldSet,
            mockFields,
            md.mockRelationshipMapId
        );

        System.assertEquals(2, result.nodeDataArray.size(), 'Should only be two people');
        System.assertEquals(
            2,
            result.linkDataArray.size(),
            'Should be a link form reportsTo and a link from relationship'
        );
    }

    @isTest
    public static void generateGraphDataHappyPathZeroLevelTest() {
        testMockData md = new testMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;
        ContactSelector mockContactSelector = md.mockContactSelector;
        StaticResourceServiceImpl mockResourceService = md.mockStaticResourceService;
        ContactRelationshipServiceImpl mockRelatiobshipService = md.mockContactRelationshipService;
        RelationshipGroupServiceImpl mockRelationshipGroupService = md.mockRelationshipGroupService;
        RelationshipMapServiceImpl mockRelationshipMapService = md.mockRelationshipMapService;

        List<Org_Chart_Field__c> mockFields = new List<Org_Chart_Field__c>{
            md.mockKeyStakeholderOrgChartField,
            md.mockContactOrgChartField
        };
        md.mockSettings.Contacts_Ancestry_Levels__c = 0;
        Contact mockReportsTo = md.mockContact.clone(false, true);
        mockReportsTo.ReportsToId = null;
        mockReportsTo.Id = md.mockContact.ReportsToId;
        Map<String, String> influenceMap = new Map<String, String>{ 'High' => 'High' };
        Map<String, String> supportMap = new Map<String, String>{ 'Supporter' => 'Supporter' };
        Set<String> contactFieldSet = new Set<String>{ 'Name' };
        RelationshipMapMemberWrapper chmWrapper = new RelationshipMapMemberWrapper(md.mockRelationshipMapMember);
        List<IRelationshipMapObject> hierarchyObjects = new List<IRelationshipMapObject>{ chmWrapper };

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMapId)).thenReturn(false);
        md.mocks.when(
                mockRelationshipGroupService.getGroupContactAssocMap(
                    (List<Relationship_Group_Contact_Association__c>) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<Id, Relationship_Group_Contact_Association__c>());
        md.mocks.when(
                mockRelationshipGroupService.getAllGroups(
                    (Map<Id, Relationship_Group__c>) fflib_Match.anyObject(),
                    (Id) fflib_Match.eq(md.mockRelationshipMapId)
                )
            )
            .thenReturn(new Map<Id, Relationship_Group__c>());
        md.mocks.when(
                mockRelationshipGroupService.createNodeDataForGroups(
                    (List<Relationship_Group__c>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<GraphNodeData>());
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(mockContactSelector.selectByIdAndSelectFields(new Set<Id>{ md.mockContactId }, contactFieldSet))
            .thenReturn(new List<Contact>{ md.mockContact });
        md.mocks.when(mockContactSelector.selectByIdAndSelectFields(new Set<Id>{ mockReportsTo.Id }, contactFieldSet))
            .thenReturn(new List<Contact>{ mockReportsTo });
        md.mocks.when(mockResourceService.getResourceUrlsForResourceNames((Set<String>) fflib_Match.anyObject()))
            .thenReturn(new Map<String, String>());
        md.mocks.when(
                mockRelatiobshipService.getRelationships(
                    (Set<Id>) fflib_Match.anyObject(),
                    (Id) fflib_Match.eq(md.mockRelationshipMapId),
                    (Boolean) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<GraphLinkData>());
        md.mocks.stopStubbing();

        RM_Chart_Setting__c setting = new RM_Chart_Setting__c(
            Show_Parents__c = true,
            Show_Empty_Fields__c = true,
            Is_Reports_To_Global_Scope__c = true
        );

        GraphData result = GraphDataService.generateGraphData(
            hierarchyObjects,
            setting,
            influenceMap,
            supportMap,
            contactFieldSet,
            mockFields,
            md.mockRelationshipMapId
        );

        System.assertEquals(
            2,
            result.nodeDataArray.size(),
            'Should still be two people since it changes the level to 1 if 0'
        );
    }

    @isTest
    public static void updateReportsToTest() {
        testMockData md = new testMockData();
        ContactSelector mockContactSelector = md.mockContactSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        Id parentId1 = fflib_IDGenerator.generate(Contact.SObjectType);
        Id newParentId = fflib_IDGenerator.generate(Contact.SObjectType);

        Contact c1 = new Contact(
            Id = fflib_IDGenerator.generate(Contact.SObjectType),
            LastName = 'ab',
            ReportsToId = parentId1
        );

        Contact c2 = new Contact(
            Id = fflib_IDGenerator.generate(Contact.SObjectType),
            LastName = 'ab',
            ReportsToId = parentId1
        );

        List<GraphLinkData> graphLinkDataList = new List<GraphLinkData>();
        graphLinkDataList.add(new GraphLinkData('', null, newParentId, false, c1.Id, '', ''));
        graphLinkDataList.add(new GraphLinkData('', null, null, false, c2.Id, '', ''));

        RM_Chart_Setting__c setting = new RM_Chart_Setting__c(Is_Reports_To_Global_Scope__c = true);

        md.mocks.startStubbing();
        md.mocks.when(
                mockContactSelector.selectByIdAndSelectFields(
                    new Set<Id>{ c1.Id, c2.Id },
                    new Set<String>{ 'ReportsToId' }
                )
            )
            .thenReturn(new List<Contact>{ c1, c2 });
        md.mocks.stopStubbing();

        GraphDataService.updateReportsTo(graphLinkDataList, md.mockRelationshipMapId, setting);

        try {
            ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 2))
                .registerDirty(fflib_Match.sObjectOfType(Contact.SObjectType));
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, e.getMessage());
        }
    }

    @isTest
    public static void getContactRelationshipTypesForRMTest() {
        testMockData md = new testMockData();
        ContactRelationshipTypeSelector mockContactRelationshipTypeSelector = md.mockContactRelationshipTypeSelector;
        RelationshipMapSelector mockRelationshipMapSelector = md.mockRelationshipMapSelector;

        Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        md.mockRelationshipMap.Type_Setting__c = 'pqcrush__Account_Plan__c';
        md.mockRelationshipMap.pq_AccountPlanId__c = accountPlanId;

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.when(
                mockContactRelationshipTypeSelector.selectByRelationshipMaps(
                    new Set<Id>{ md.mockRelationshipMapId },
                    true,
                    accountPlanId
                )
            )
            .thenReturn(new List<Contact_Relationship_Type__c>());
        md.mocks.stopStubbing();

        GraphDataService.getContactRelationshipTypes(md.mockRelationshipMapId);

        ((ContactRelationshipTypeSelector) md.mocks.verify(mockContactRelationshipTypeSelector, 1))
            .selectByRelationshipMaps(new Set<Id>{ md.mockRelationshipMapId }, true, accountPlanId);
        System.assert(true, 'test verified by mocks');
    }

    @isTest
    private static void getAndInjectCustomLinksTest() {
        testMockData md = new testMockData();
        MapMemberPlaceholderServiceImpl mockMapMemberPlaceholderService = md.mockMapMemberPlaceholderService;

        GraphData gd = new GraphData();

        md.mocks.startStubbing();
        md.mocks.when(mockMapMemberPlaceholderService.getAndInjectCustomLinks(gd, md.mockRelationshipMapId))
            .thenReturn(gd);
        md.mocks.stopStubbing();

        GraphDataService.getAndInjectCustomLinks(new GraphData(), md.mockRelationshipMapId);

        ((MapMemberPlaceholderServiceImpl) md.mocks.verify(mockMapMemberPlaceholderService, 1))
            .getAndInjectCustomLinks(gd, md.mockRelationshipMapId);
        System.assert(true);
    }

    @isTest
    private static void getAndInjectLocalHierarchyLinksForContactsTest() {
        testMockData md = new testMockData();
        MapMemberPlaceholderRelationshipSelector mockMapMemberPlaceholderRelationshipSelector = md.mockMapMemberPlaceholderRelationshipSelector;

        GraphData gd = new GraphData();
        Set<String> contactIdSet = new Set<String>{ 'a', 'b' };

        Map_Member_Placeholder_Relationship__c c2 = new Map_Member_Placeholder_Relationship__c(
            Id = fflib_IDGenerator.generate(Map_Member_Placeholder_Relationship__c.SObjectType),
            TempId__c = 'b',
            From__c = 'from',
            To__c = 'to'
        );

        md.mocks.startStubbing();
        md.mocks.when(
                mockMapMemberPlaceholderRelationshipSelector.selectHierarchyLinksByPlaceholderId(
                    new Set<Id>{ md.mockRelationshipMapId },
                    contactIdSet
                )
            )
            .thenReturn(new List<Map_Member_Placeholder_Relationship__c>{ c2 });
        md.mocks.stopStubbing();

        GraphData result = GraphDataService.getAndInjectLocalHierarchyLinksForContacts(
            md.mockRelationshipMapId,
            gd,
            contactIdSet
        );

        System.assertEquals(1, result.linkDataArray.size());

        System.assertEquals('from', result.linkDataArray[0].fromKey);
        System.assertEquals('to', result.linkDataArray[0].toKey);
    }

    @isTest
    private static void getLeadGraphDataForSearchTermNoPermTest() {
        testMockData md = new testMockData();

        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User'];
        User noPermUser = TestDataFactory.createUser('firsname', 'lastname', standardProfile.Id);

        String searchTerm = 'abc';
        List<String> excludeIds = new List<String>();

        GraphData result;
        System.runAs(noPermUser) {
            result = GraphDataService.getLeadGraphDataForSearchTerm(searchTerm, excludeIds, md.mockRelationshipMapId);
        }

        System.assertEquals(new GraphData(), result);
    }
}