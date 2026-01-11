@isTest
private class RelationshipMapMemberControllerTest {
    private static final String ADMIN_USER_FIRST_NAME = 'rmm test admin user first';
    private static final String ADMIN_USER_LAST_NAME = 'rmm test admin user last';

    private static final String PRM_ADMIN_PERM = 'PROLIFIQ_RELATIONSHIP_MAP';
    private static final String STANDARD_USER = 'Standard User';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];
        User adminUser = TestDataFactory.createUser(ADMIN_USER_FIRST_NAME, ADMIN_USER_LAST_NAME, standardProfile.Id);
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :PRM_ADMIN_PERM LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = adminUserPermissionSet.Id);
    }

    /**************************
     *** getSupportColors() ***
     *************************/

    @isTest
    private static void getSupportColorsTest() {
        Map<String, String> expected = GraphDataService.getSupportColors();
        Map<String, String> result = RelationshipMapMemberController.getSupportColors();
        System.assertEquals(
            expected,
            result,
            'Color map should be exactly the same as the one retrived from the GraphDataService'
        );
    }

    /*************************************
     *** getMapMemberByIdORContactId() ***
     ************************************/

    @isTest
    private static void getMapMemberByIdORContactIdNullTest() {
        Relationship_Map_Member__c result = RelationshipMapMemberController.getMapMemberByIdORContactId(null, null);
        System.assertEquals(null, result, 'null Id should return null member');
    }

    @isTest
    private static void getMapMemberByIdORContactIdNotFoundTest() {
        testMockData md = new testMockData();
        RelationshipMapMemberSelector selector = md.mockRelationshipMapMemberSelector;

        md.mocks.startStubbing();
        md.mocks.when(
                selector.selectByIdOrContactIdAndMapId(
                    (Set<Id>) FFLibHelper.eqIdSet(new Set<Id>{ md.mockRelationshipMapMemberId }),
                    (Id) fflib_Match.eqId(md.mockRelationshipMapId),
                    (Set<String>) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Relationship_Map_Member__c>());
        md.mocks.stopStubbing();

        Relationship_Map_Member__c result = RelationshipMapMemberController.getMapMemberByIdORContactId(
            md.mockRelationshipMapMemberId,
            md.mockRelationshipMapId
        );
        System.assertEquals(null, result, 'not found Id should return null member');
    }

    @isTest
    private static void getMapMemberByIdORContactIdValidTest() {
        testMockData md = new testMockData();
        RelationshipMapMemberSelector selector = md.mockRelationshipMapMemberSelector;

        md.mocks.startStubbing();
        md.mocks.when(
                selector.selectByIdOrContactIdAndMapId(
                    (Set<Id>) FFLibHelper.eqIdSet(new Set<Id>{ md.mockRelationshipMapMemberId }),
                    (Id) fflib_Match.eqId(md.mockRelationshipMapId),
                    (Set<String>) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Relationship_Map_Member__c>{ md.mockRelationshipMapMember });
        md.mocks.stopStubbing();

        Relationship_Map_Member__c result = RelationshipMapMemberController.getMapMemberByIdORContactId(
            md.mockRelationshipMapMemberId,
            md.mockRelationshipMapId
        );
        System.assertEquals(md.mockRelationshipMapMember, result, 'valid Id should return expected member');
    }

    /********************************************
     *** getMatrixMemberByIdORContactIdTest() ***
     ********************************************/

    @isTest
    private static void getMatrixMemberByIdORContactIdTest() {
        testMockData md = new testMockData();
        RelationshipMapMemberSelector selector = md.mockRelationshipMapMemberSelector;

        md.mocks.startStubbing();
        md.mocks.when(
                selector.selectByIdOrContactIdAndMapId(
                    (Set<Id>) FFLibHelper.eqIdSet(new Set<Id>{ md.mockRelationshipMapMemberId }),
                    (Id) fflib_Match.eqId(md.mockRelationshipMapId),
                    (Set<String>) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Relationship_Map_Member__c>{ md.mockRelationshipMapMember });
        md.mocks.stopStubbing();

        MatrixMember result = RelationshipMapMemberController.getMatrixMemberByIdORContactId(
            md.mockRelationshipMapMemberId,
            md.mockRelationshipMapId
        );
        System.assertNotEquals(null, result, 'valid Id should return expected member');
    }

    /**************************
     *** getMapMemberById() ***
     *************************/

    @isTest
    private static void getMapMemberByIdNullTest() {
        Relationship_Map_Member__c result = RelationshipMapMemberController.getMapMemberById(null);
        System.assertEquals(null, result, 'null Id should return null member');
    }

    @isTest
    private static void getMapMemberByIdNotFoundTest() {
        testMockData md = new testMockData();
        RelationshipMapMemberSelector selector = md.mockRelationshipMapMemberSelector;

        md.mocks.startStubbing();
        md.mocks.when(selector.selectById(new Set<Id>{ md.mockRelationshipMapMemberId }))
            .thenReturn(new List<Relationship_Map_Member__c>());
        md.mocks.stopStubbing();

        Relationship_Map_Member__c result = RelationshipMapMemberController.getMapMemberById(
            md.mockRelationshipMapMemberId
        );
        System.assertEquals(null, result, 'not found Id should return null member');
    }

    @isTest
    private static void getMapMemberByIdValidTest() {
        testMockData md = new testMockData();
        RelationshipMapMemberSelector selector = md.mockRelationshipMapMemberSelector;

        md.mocks.startStubbing();
        md.mocks.when(selector.selectById(new Set<Id>{ md.mockRelationshipMapMemberId }))
            .thenReturn(new List<Relationship_Map_Member__c>{ md.mockRelationshipMapMember });
        md.mocks.stopStubbing();

        Relationship_Map_Member__c result = RelationshipMapMemberController.getMapMemberById(
            md.mockRelationshipMapMemberId
        );
        System.assertEquals(md.mockRelationshipMapMember, result, 'valid Id should return expected member');
    }

    /******************************
     *** getMapMembersByMapId() ***
     *****************************/

    @isTest
    private static void getMapMembersByMapIdNullTest() {
        List<MatrixMember> result = RelationshipMapMemberController.getMapMembersByMapId(null);
        System.assertEquals(0, result.size(), 'null Id should return empty member list');
    }

    // With Local Influence Support
    @isTest
    private static void getMapMembersByMapIdValidTest() {
        testMockData md = new testMockData();
        RelationshipMapMemberSelector selector = md.mockRelationshipMapMemberSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;

        md.mocks.startStubbing();
        md.mocks.when(
                selector.selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
                    (Set<Id>) FFLibHelper.eqIdSet(new Set<Id>{ md.mockRelationshipMapId }),
                    (Set<String>) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Relationship_Map_Member__c>{ md.mockRelationshipMapMember });
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(md.mockRMChartSettingForRelationshipMap);
        md.mocks.stopStubbing();

        List<MatrixMember> result = RelationshipMapMemberController.getMapMembersByMapId(md.mockRelationshipMapId);
        System.assertEquals(1, result.size(), 'Should return expected list size');
    }

    // With Global Influence Support
    @isTest
    private static void getMapMembersByMapIdValidTest2() {
        testMockData md = new testMockData();
        RelationshipMapMemberSelector selector = md.mockRelationshipMapMemberSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        ContactExtendedFieldSelector mockContactExtendedFieldSelector = md.mockContactExtendedFieldSelector;

        md.mockRMChartSettingForRelationshipMap.Is_Influence_Support_Global_Scope__c = true;

        md.mocks.startStubbing();
        md.mocks.when(
                selector.selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
                    (Set<Id>) FFLibHelper.eqIdSet(new Set<Id>{ md.mockRelationshipMapId }),
                    (Set<String>) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Relationship_Map_Member__c>{ md.mockRelationshipMapMember });
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(md.mockRMChartSettingForRelationshipMap);
        md.mocks.when(
                mockContactExtendedFieldSelector.selectByContactId(
                    new Set<Id>{ md.mockRelationshipMapMember.Contact__c }
                )
            )
            .thenReturn(new List<Contact_Extended_Field__c>{ md.mockContactExtendedField });
        md.mocks.stopStubbing();

        List<MatrixMember> result = RelationshipMapMemberController.getMapMembersByMapId(md.mockRelationshipMapId);
        System.assertEquals(1, result.size(), 'Should return expected list size');
    }

    /*************************
     *** upsertMapMember() ***
     ************************/

    @isTest
    private static void upsertMapMemberNullIdTest() {
        testMockData md = new testMockData();
        RelationshipMapMembers mapMembersDomain = md.mockRelationshipMapMembersDomain;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUow;

        RelationshipMapMemberController.upsertMapMember(null, null, null);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUoW, 0)).commitWork();
        ((RelationshipMapMembers) md.mocks.verify(mapMembersDomain, 0))
            .updateField(
                (Schema.SObjectField) fflib_Match.anyObject(),
                fflib_Match.anyObject(),
                (fflib_ISObjectUnitOfWork) fflib_Match.anyObject()
            );
        System.assert(true, 'Asserts done by mock verify');
    }

    @isTest
    private static void upsertMapMemberValidTest() {
        testMockData md = new testMockData();
        RelationshipMapMembers mapMembersDomain = md.mockRelationshipMapMembersDomain;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUow;
        RelationshipMapMemberSelector selector = md.mockRelationshipMapMemberSelector;
        OrgChartFieldSelector mockOCFSelector = md.mockOrgChartFieldSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        SupportSelector mockSupportSelector = md.mockSupportSelector;
        InfluenceSelector mockInfluenceSelector = md.mockInfluenceSelector;

        List<Org_Chart_Field__c> mockFields = new List<Org_Chart_Field__c>{
            md.mockMapMemberOrgChartField,
            md.mockMapMemberContactOrgChartField
        };

        md.mocks.startStubbing();
        md.mocks.when(mockInfluenceSelector.selectByName(new Set<String>{ null }))
            .thenReturn(new List<pq_Influence__c>());
        md.mocks.when(mockSupportSelector.selectByName(new Set<String>{ null })).thenReturn(new List<pq_Support__c>());
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(md.mockRMChartSettingForRelationshipMap);
        md.mocks.when(mockOCFSelector.selectVisibleByMapType('Relationship Map')).thenReturn(mockFields);
        md.mocks.when(selector.selectById(new Set<Id>{ md.mockRelationshipMapMemberId }))
            .thenReturn(new List<Relationship_Map_Member__c>{ md.mockRelationshipMapMember });
        md.mocks.when(
                selector.selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
                    (Set<Id>) FFLibHelper.eqIdSet(new Set<Id>{ md.mockRelationshipMapId }),
                    (Set<String>) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Relationship_Map_Member__c>{ md.mockRelationshipMapMember });
        md.mocks.stopStubbing();

        RelationshipMapMemberController.upsertMapMember(md.mockRelationshipMapMemberId, null, null);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUoW, 1)).commitWork();
        ((RelationshipMapMembers) md.mocks.verify(mapMembersDomain, 2))
            .updateField(
                (Schema.SObjectField) fflib_Match.anyObject(),
                fflib_Match.isNull(),
                (fflib_ISObjectUnitOfWork) fflib_Match.anyObject()
            );
        System.assert(true, 'Asserts done by mock verify');
    }

    // Global Influence & Support Setting
    @isTest
    private static void upsertMapMemberValid2Test() {
        testMockData md = new testMockData();
        RelationshipMapMembers mapMembersDomain = md.mockRelationshipMapMembersDomain; //NOPMD - Needs to be called in order for it to be mocked in the test
        fflib_ISObjectUnitOfWork mockUoW = md.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test
        RelationshipMapMemberSelector selector = md.mockRelationshipMapMemberSelector;
        OrgChartFieldSelector mockOCFSelector = md.mockOrgChartFieldSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        SupportSelector mockSupportSelector = md.mockSupportSelector;
        InfluenceSelector mockInfluenceSelector = md.mockInfluenceSelector;
        ContactExtendedFieldServiceImpl mockContactExtendedFieldService = md.mockContactExtendedFieldService;

        List<Org_Chart_Field__c> mockFields = new List<Org_Chart_Field__c>{
            md.mockMapMemberOrgChartField,
            md.mockMapMemberContactOrgChartField
        };

        md.mockRMChartSettingForRelationshipMap.Is_Influence_Support_Global_Scope__c = true;

        md.mocks.startStubbing();
        md.mocks.when(mockInfluenceSelector.selectByName(new Set<String>{ 'Low' }))
            .thenReturn(new List<pq_Influence__c>{ md.mockInfluence });
        md.mocks.when(mockSupportSelector.selectByName(new Set<String>{ 'Champ' }))
            .thenReturn(new List<pq_Support__c>{ md.mockSupport });
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(md.mockRMChartSettingForRelationshipMap);
        md.mocks.when(mockOCFSelector.selectVisibleByMapType('Relationship Map')).thenReturn(mockFields);
        md.mocks.when(selector.selectById(new Set<Id>{ md.mockRelationshipMapMemberId }))
            .thenReturn(new List<Relationship_Map_Member__c>{ md.mockRelationshipMapMember });
        md.mocks.when(
                selector.selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
                    (Set<Id>) FFLibHelper.eqIdSet(new Set<Id>{ md.mockRelationshipMapId }),
                    (Set<String>) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Relationship_Map_Member__c>{ md.mockRelationshipMapMember });
        md.mocks.stopStubbing();

        RelationshipMapMemberController.upsertMapMember(md.mockRelationshipMapMemberId, 'Low', 'Champ');

        ((ContactExtendedFieldServiceImpl) md.mocks.verify(mockContactExtendedFieldService, 1))
            .updateInfluenceSupport(md.mockRelationshipMapMember.Contact__c, md.mockInfluence.Id, md.mockSupport.Id);

        System.assert(true, 'Asserts done by mock verify');
    }

    /******************************************
     *** getContactGraphDataForSearchTerm() ***
     *****************************************/

    @isTest
    private static void getContactGraphDataForSearchTermTest() {
        testMockData md = new testMockData();
        GraphDataServiceImpl mockGraphDataService = md.mockGraphDataService;

        List<String> excludeIds = new List<String>{ md.mockContactId };
        String searchTerm = 'abc';
        String searchKey = 'Some Random Key For gcgdfstt';
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);

        md.mocks.startStubbing();
        md.mocks.when(
                mockGraphDataService.getContactGraphDataForSearchTerm(
                    searchTerm,
                    excludeIds,
                    accountId,
                    RelationshipMapMemberController.orgChartfields,
                    RelationshipMapMemberController.mapMembersAndContactFields.get('contacts'),
                    md.mockRelationshipMapId
                )
            )
            .thenReturn(new GraphData());
        md.mocks.stopStubbing();

        GraphData response = RelationshipMapMemberController.getContactGraphDataForSearchTerm(
            searchTerm,
            excludeIds,
            accountId,
            md.mockRelationshipMapId,
            searchKey
        );

        ((GraphDataServiceImpl) md.mocks.verify(mockGraphDataService, 1))
            .getContactGraphDataForSearchTerm(
                searchTerm,
                excludeIds,
                accountId,
                RelationshipMapMemberController.orgChartfields,
                RelationshipMapMemberController.mapMembersAndContactFields.get('contacts'),
                md.mockRelationshipMapId
            );
        System.assertEquals(searchKey, response.searchKey, 'Should return expected search key');
    }

    /****************************************
     *** getUserGraphDataForHierarchyId() ***
     ***************************************/

    @isTest
    private static void getUserGraphDataForHierarchyIdNullTest() {
        GraphData result = RelationshipMapMemberController.getUserGraphDataForHierarchyId(null);
        System.assertEquals(0, result.nodeDataArray.size(), 'Null hierarchy Id should result in no node data');
        System.assertEquals(0, result.linkDataArray.size(), 'Null hierarchy Id should result in no link data');
    }

    @isTest
    private static void getUserGraphDataForHierarchyIdInvalidTest() {
        GraphData result = RelationshipMapMemberController.getUserGraphDataForHierarchyId(UserInfo.getUserId());
        System.assertEquals(0, result.nodeDataArray.size(), 'Invalid hierarchy Id should result in no node data');
        System.assertEquals(0, result.linkDataArray.size(), 'Invalid hierarchy Id should result in no link data');
    }

    @isTest
    private static void getUserGraphDataForHierarchyIdNoMapTest() {
        testMockData md = new testMockData();
        try {
            RelationshipMapMemberController.getUserGraphDataForHierarchyId(md.mockRelationshipMapId);
            System.assert(false, 'No error thrown, should throw an error');
        } catch (Exception e) {
            String expectedErrorMessage = String.format(
                System.label.error_insufficient_access,
                new List<String>{ String.valueOf(md.mockRelationshipMapId) }
            );
            System.assertEquals(expectedErrorMessage, e.getMessage(), 'Actual error should match expected error');
        }
    }

    @isTest
    private static void getUserGraphDataForHierarchyIdValidTest() {
        testMockData md = new testMockData();
        OrgChartFieldSelector mockOCFSelector = md.mockOrgChartFieldSelector;
        RelationshipMapMemberSelector mockMemberSelector = md.mockRelationshipMapMemberSelector;
        RelationshipMapSelector mockMapSelector = md.mockRelationshipMapSelector;
        MapMemberLeadServiceImpl mockMapMemberLeadService = md.mockMapMemberLeadService; //NOPMD - Needs to be called in order for it to be mocked in the test
        GraphDataServiceImpl chService = md.mockGraphDataService;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        RMSvgServiceImpl mockRMSvgService = md.mockRMSvgService;

        List<Org_Chart_Field__c> mockFields = new List<Org_Chart_Field__c>{
            md.mockMapMemberOrgChartField,
            md.mockMapMemberContactOrgChartField
        };

        Set<String> contactFieldSet = new Set<String>{
            md.mockKeyStakeholderOrgChartField.pqcrush__FieldName__c,
            'PhotoUrl',
            'ReportsToId'
        };

        Map<Id, RM_Chart_Setting__c> settingsMap = new Map<Id, RM_Chart_Setting__c>();
        settingsMap.put(md.mockRelationshipMapId, md.mockRMChartSettingForRelationshipMap);

        md.mocks.startStubbing();
        md.mocks.when(mockOCFSelector.selectVisibleByMapType('Relationship Map')).thenReturn(mockFields);
        md.mocks.when(
                mockMemberSelector.selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
                    new Set<Id>{ md.mockRelationshipMapId },
                    new Set<String>{ md.mockKeyStakeholderOrgChartField.pqcrush__FieldName__c },
                    contactFieldSet
                )
            )
            .thenReturn(new List<Relationship_Map_Member__c>{ md.mockRelationshipMapMember });
        md.mocks.when(mockMapSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.when(
                mockRMChartSettingService.getRelationshipMapSettingForObjects(
                    new Set<Id>{ md.mockRelationshipMapId },
                    false
                )
            )
            .thenReturn(settingsMap);
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(md.mockRMChartSettingForRelationshipMap);
        md.mocks.stopStubbing();

        RelationshipMapMemberController.getUserGraphDataForHierarchyId(md.mockRelationshipMapId);

        RelationshipMapMemberWrapper expectedWrapper = new RelationshipMapMemberWrapper(md.mockRelationshipMapMember);

        ((GraphDataServiceImpl) md.mocks.verify(chService, 1))
            .generateGraphData(
                (List<RelationshipMapMemberWrapper>) fflib_Match.eqList(
                    new List<RelationshipMapMemberWrapper>{ expectedWrapper }
                ),
                (RM_Chart_Setting__c) fflib_Match.anyObject(),
                (Map<String, String>) fflib_Match.anyObject(),
                (Map<String, String>) fflib_Match.anyObject(),
                (Set<String>) fflib_Match.anyObject(),
                (List<Org_Chart_Field__c>) fflib_Match.anyObject(),
                (Id) fflib_Match.anyObject()
            );

        ((RMSvgServiceImpl) md.mocks.verify(mockRMSvgService, 1))
            .injectBadges(md.mockRelationshipMapId, null, md.mockRMChartSettingForRelationshipMap);

        System.assert(true, 'Tests verified by mock data');
    }

    @isTest
    static void addContactToRelationshipMapTest() {
        TestMockData md = new TestMockData();
        GraphDataServiceImpl chService = md.mockGraphDataService;
        RMNodeCoordinateServiceImpl mockRMNodeCoordinateServiceImpl = md.mockRMNodeCoordinateService;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        GraphNodeData graphData = new GraphNodeData(md.mockContactId, 'groupKey', 'label', 'horizontal');
        GraphData gd = new graphData();
        gd.nodeDataArray = new List<GraphNodeData>{ graphData };

        RelationshipMapMemberController.addContactToRelationshipMap(md.mockRelationshipMapId, JSON.serialize(gd));

        Relationship_Map_Member__c mapM = new Relationship_Map_Member__c(
            Relationship_Map__c = md.mockRelationshipMapId,
            Contact__c = md.mockContactId
        );

        RelationshipMapMemberWrapper expectedWrapper = new RelationshipMapMemberWrapper(mapM);

        // Then
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew(fflib_Match.sObjectOfType(Relationship_Map_Member__c.SObjectType));
        ((RMNodeCoordinateServiceImpl) md.mocks.verify(mockRMNodeCoordinateServiceImpl, 1))
            .updateNodeCoordinates(md.mockRelationshipMapId, gd.nodeDataArray);
        ((GraphDataServiceImpl) md.mocks.verify(chService, 1))
            .generateGraphData(
                (List<RelationshipMapMemberWrapper>) fflib_Match.eqList(
                    new List<RelationshipMapMemberWrapper>{ expectedWrapper }
                ),
                (RM_Chart_Setting__c) fflib_Match.anyObject(),
                (Map<String, String>) fflib_Match.anyObject(),
                (Map<String, String>) fflib_Match.anyObject(),
                (Set<String>) fflib_Match.anyObject(),
                (List<Org_Chart_Field__c>) fflib_Match.anyObject(),
                (Id) fflib_Match.anyObject()
            );
        System.assert(true, 'Test verified by mock verifications');
    }

    /*************************************
     *** getMapIdForSObjectId() ***
     ************************************/

    @isTest
    private static void getMapIdForSObjectIdNullIdTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        // When
        Id result;
        System.runAs(adminUser) {
            Test.startTest();
            result = RelationshipMapMemberController.getMapIdForSObjectId(null);
            Test.stopTest();
        }

        // Then
        System.assertEquals(null, result, 'Should not find a matching id');
    }

    @isTest
    private static void getMapIdForSObjectIdValidIsMapTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];
        Id expected = fflib_IDGenerator.generate(pqcrush__Relationship_Map__c.SObjectType);

        // When
        Id result;
        System.runAs(adminUser) {
            Test.startTest();
            result = RelationshipMapMemberController.getMapIdForSObjectId(expected);
            Test.stopTest();
        }

        // Then
        System.assertEquals(expected, result, 'Should return the Id passed in');
    }

    @isTest
    private static void getMapIdForSObjectIdValidRelationshipNoMatchWithoutAutoTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockSettings.Auto_Create_Relationship_Maps__c = false;
        md.mockSettings.Auto_Create_Stakeholder_Maps__c = true;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        // When
        Id result;
        System.runAs(adminUser) {
            Test.startTest();
            result = RelationshipMapMemberController.getMapIdForSObjectId(
                fflib_IDGenerator.generate(pqcrush__Relationship_Map_Member__c.SObjectType)
            );
            Test.stopTest();
        }

        // Then
        System.assertEquals(null, result, 'Should not find a matching id');
    }

    @isTest
    private static void getMapIdForSObjectIdValidRelationshipNoMatchWithAutoTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockSettings.Auto_Create_Relationship_Maps__c = true;
        md.mockSettings.Auto_Create_Stakeholder_Maps__c = false;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        String expectedError = String.format(
            System.label.error_insufficient_access,
            new List<String>{ md.mockRelationshipMapMemberId }
        );

        // When
        System.runAs(adminUser) {
            Test.startTest();
            try {
                RelationshipMapMemberController.getMapIdForSObjectId(md.mockRelationshipMapMemberId);
            } catch (Exception e) {
                System.assertEquals(
                    expectedError,
                    e.getMessage(),
                    'Should throw expected error for no access to create map'
                );
            }
            Test.stopTest();
        }
    }

    @isTest
    private static void getMapIdForSObjectIdValidRelatesToTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        // When
        Relationship_Map__c theMap;
        Id result;
        System.runAs(adminUser) {
            theMap = TestDataFactory.createRelationshipMap('Relationship map valid test map name');
            Contact theContact = TestDataFactory.createContact(
                'RM test contact first name',
                'RM test contact last name'
            );
            Relationship_Map_Member__c theMember = TestDataFactory.createRelationshipMapMember(
                theMap.Id,
                theContact.Id
            );

            Test.startTest();
            result = RelationshipMapMemberController.getMapIdForSObjectId(theMember.Id);
            Test.stopTest();
        }

        // Then
        System.assertEquals(theMap.Id, result, 'Should match the map Id');
    }

    @isTest
    private static void getMapIdForSObjectIdValidChildRelationshipTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        // When
        Relationship_Map__c theMap;
        Id result;
        System.runAs(adminUser) {
            theMap = TestDataFactory.createRelationshipMap('Relationship map valid test map name');
            Test.startTest();
            result = RelationshipMapMemberController.getMapIdForSObjectId(adminUser.Id);
            Test.stopTest();
        }

        // Then
        System.assertEquals(theMap.Id, result, 'Should match the map Id');
    }

    @isTest
    private static void getMapIdForSObjectIdValidOrderTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        // When
        Relationship_Map__c theExpectedMap;
        Id result;
        System.runAs(adminUser) {
            theExpectedMap = TestDataFactory.createRelationshipMap('Relationship map valid test map name');

            for (Integer i = 0; i < 3; i++) {
                TestDataFactory.createRelationshipMap('Relationship map getMapIdForSObjectIdValidOrderTest name' + i);
                // 2 second "pause" to have noticable time between creations
                Long startTime = DateTime.now().getTime();
                Long finalTime = DateTime.now().getTime();
                Long millisecondsToWait = 2000; // vary this depending on your "sleep" needs
                while (finalTime - startTime < millisecondsToWait) {
                    finalTime = DateTime.now().getTime();
                }
            }
            Test.startTest();
            result = RelationshipMapMemberController.getMapIdForSObjectId(adminUser.Id);
            Test.stopTest();
        }

        // Then
        System.assertEquals(theExpectedMap.Id, result, 'Should match the map Id');
    }

    @isTest
    private static void getMapIdForSObjectIdValidChildRelationshipCreateMapTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;
        RelationshipMapServiceImpl mockRMService = md.mockRelationshipMapService;
        md.mockSettings.Auto_Create_Relationship_Maps__c = true;
        md.mockSettings.Auto_Create_Stakeholder_Maps__c = false;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(
                mockRMService.createRelatedMap(
                    (List<Schema.SObjectField>) fflib_Match.anyList(),
                    (List<Schema.SObjectField>) fflib_Match.anyList(),
                    (Schema.DescribeSObjectResult) fflib_Match.anyObject(),
                    fflib_Match.eqId(adminUser.Id)
                )
            )
            .thenReturn(md.mockRelationshipMap);
        md.mocks.stopStubbing();

        // When
        Id result;
        System.runAs(adminUser) {
            Test.startTest();
            result = RelationshipMapMemberController.getMapIdForSObjectId(adminUser.Id);
            Test.stopTest();
        }

        // Then
        System.assertEquals(md.mockRelationshipMapId, result, 'Should call service being mocked to create a map');
    }

    @isTest
    private static void getMapIdForSObjectIdValidPlanRelationshipCreateMapTest() {
        // Given
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;
        RelationshipMapServiceImpl mockRMService = md.mockRelationshipMapService;
        md.mockSettings.Auto_Create_Relationship_Maps__c = false;
        md.mockSettings.Auto_Create_Stakeholder_Maps__c = true;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(
                mockRMService.createRelatedMap(
                    (List<Schema.SObjectField>) fflib_Match.anyList(),
                    (List<Schema.SObjectField>) fflib_Match.anyList(),
                    (Schema.DescribeSObjectResult) fflib_Match.anyObject(),
                    fflib_Match.eqId(md.mockAccountPlanId)
                )
            )
            .thenReturn(md.mockRelationshipMap);
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        Id result = RelationshipMapMemberController.getMapIdForSObjectId(md.mockAccountPlanId);
        Test.stopTest();

        // Then
        System.assertEquals(md.mockRelationshipMapId, result, 'Should call service being mocked to create a map');
    }

    /***********************
     *** deleteMembers() ***
     **********************/

    @isTest
    static void deleteMembersTest() {
        // Given
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        List<Id> memberIds = new List<Id>{ md.mockRelationshipMapMemberId };

        RelationshipMapMemberController.deleteMembers(memberIds);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerDeleted((List<Relationship_Map_Member__c>) fflib_Match.anyList());
        System.assert(true, 'assert done by mock verify');
    }

    /*****************************************
     *** getParentIdForRelationshipMapId() ***
     ****************************************/

    @isTest
    static void getParentIdForRelationshipMapIdNullTest() {
        TestMockData md = new TestMockData();
        RelationshipMapServiceImpl mockRMService = md.mockRelationshipMapService;

        Id result = RelationshipMapMemberController.getParentIdForRelationshipMapId(null);

        System.assertEquals(null, result, 'Should return null parent for null map Id passed');
        ((RelationshipMapServiceImpl) md.mocks.verify(mockRMService, 0))
            .getParentIdForRelationshipMapId(fflib_Match.anyId());
    }

    @isTest
    static void getParentIdForRelationshipMapIdWrongObjectIdTest() {
        TestMockData md = new TestMockData();
        RelationshipMapServiceImpl mockRMService = md.mockRelationshipMapService;

        Id result = RelationshipMapMemberController.getParentIdForRelationshipMapId(UserInfo.getUserId());

        System.assertEquals(null, result, 'Should return null parent for wrong object type passed');
        ((RelationshipMapServiceImpl) md.mocks.verify(mockRMService, 0))
            .getParentIdForRelationshipMapId(fflib_Match.anyId());
    }

    @isTest
    static void getParentIdForRelationshipMapIdHappyPathTest() {
        TestMockData md = new TestMockData();
        RelationshipMapServiceImpl mockRMService = md.mockRelationshipMapService;

        md.mocks.startStubbing();
        md.mocks.when(mockRMService.getParentIdForRelationshipMapId(md.mockRelationshipMapId))
            .thenReturn(md.mockAccountPlanId);
        md.mocks.stopStubbing();

        Id result = RelationshipMapMemberController.getParentIdForRelationshipMapId(md.mockRelationshipMapId);

        ((RelationshipMapServiceImpl) md.mocks.verify(mockRMService, 1))
            .getParentIdForRelationshipMapId(md.mockRelationshipMapId);

        System.assertEquals(md.mockAccountPlanId, result, 'Should return expected parent Id');
    }

    /************************************
     *** getMatrixByRelationshipMap() ***
     ***********************************/

    @isTest
    static void getMatrixByRelationshipMapTest() {
        testMockData md = new testMockData();
        InfluenceSupportMatrixServiceImpl influenceSupportMatrixService = md.InfluenceSupportMatrixService;

        Map<Id, pq_Influence_And_Support_Matrix__c> matrixes = new Map<Id, pq_Influence_And_Support_Matrix__c>();
        matrixes.put(md.mockRelationshipMapId, md.mockInfluenceSupportMatrix);

        pq_Influence__c i1 = new pq_Influence__c(Name = 'Low', Label__c = 'lowlabel');
        insert i1;
        pq_Support__c s1 = new pq_Support__c(Name = 'Champion', Label__c = 'champlabel', Color__c = '#ff0011');
        insert s1;

        List<pq_Influence__c> influences = new List<pq_Influence__c>();
        influences.add(i1);
        List<pq_Support__c> supports = new List<pq_Support__c>();
        supports.add(s1);

        md.mocks.startStubbing();
        md.mocks.when(
                influenceSupportMatrixService.getMatrixesForRelationshipMap(new Set<Id>{ md.mockRelationshipMapId })
            )
            .thenReturn(matrixes);
        md.mocks.when(
                influenceSupportMatrixService.getInfluencesByMatrixes(new Set<Id>{ md.mockInfluenceSupportMatrixId })
            )
            .thenReturn(influences);
        md.mocks.when(
                influenceSupportMatrixService.getSupportByMatrixes(new Set<Id>{ md.mockInfluenceSupportMatrixId })
            )
            .thenReturn(supports);
        md.mocks.stopStubbing();

        MatrixWrapper result = RelationshipMapMemberController.getMatrixByRelationshipMap(md.mockRelationshipMapId);
        System.assertNotEquals(null, result);
        //Extra one is for TBD
        System.assertEquals(2, result.influenceList.size());
        System.assertEquals(2, result.supportList.size());
    }
}