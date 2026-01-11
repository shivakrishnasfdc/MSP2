@isTest
private class OmniViewerControllerTest {
    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User admin = TestDataFactory.createUser('user', 'Admin', standardProfile.Id);

        PermissionSet adminUserPermissionSet1 = [SELECT Id FROM PermissionSet WHERE Name = 'CRUSH_Administrator'];
        PermissionSet adminUserPermissionSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'PROLIFIQ_RELATIONSHIP_MAP'];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = admin.Id, PermissionSetId = adminUserPermissionSet1.Id),
            new PermissionSetAssignment(AssigneeId = admin.Id, PermissionSetId = adminUserPermissionSet2.Id)
        };
    }

    @isTest
    static void getMapMemberByIdORContactIdTest() {
        TestMockData md = new TestMockData();
        RelationshipMapMemberSelector selector = md.mockRelationshipMapMemberSelector;

        OmniViewerController.getMapMemberByIdORContactId(md.mockRelationshipMapMemberId, md.mockRelationshipMapId);

        ((RelationshipMapMemberSelector) md.mocks.verify(selector, 1))
            .selectByIdOrContactIdAndMapId(
                (Set<Id>) FFLibHelper.eqIdSet(new Set<Id>{ md.mockRelationshipMapMemberId }),
                (Id) fflib_Match.eqId(md.mockRelationshipMapId),
                (Set<String>) fflib_Match.anyObject(),
                (Set<String>) fflib_Match.anyObject()
            );

        System.Assert(true, 'Test verified by mock assertion');
    }

    @isTest
    static void getKeyStakeholderByIdORContactIdTest() {
        TestMockData md = new TestMockData();
        KeyStakeholderSelector selector = md.mockKeyStakeholderSelector;

        OmniViewerController.getKeyStakeholderByIdORContactId(md.mockKeyStakeholderId, md.mockAccountPlanId);

        ((KeyStakeholderSelector) md.mocks.verify(selector, 1))
            .selectByIdOrContactIdAndPlanId(
                (Set<Id>) FFLibHelper.eqIdSet(new Set<Id>{ md.mockKeyStakeholderId }),
                (Id) fflib_Match.eqId(md.mockAccountPlanId),
                (Set<String>) fflib_Match.anyObject(),
                (Set<String>) fflib_Match.anyObject()
            );

        System.Assert(true, 'Test verified by mock assertion');
    }

    @isTest
    static void getContactExtendedFieldsTest() {
        TestMockData md = new TestMockData();
        ContactExtendedFieldSelector selector = md.mockContactExtendedFieldSelector;

        List<Contact_Extended_Field__c> cefList = new List<Contact_Extended_Field__c>{
            new Contact_Extended_Field__c(Contact__c = md.mockContactId)
        };

        md.mocks.startStubbing();
        md.mocks.when(selector.selectByContactId(new Set<Id>{ md.mockContactId })).thenReturn(cefList);
        md.mocks.stopStubbing();

        Map<Id, Contact_Extended_Field__c> result = OmniViewerController.getContactExtendedFields(md.mockContactId);

        System.AssertEquals(1, result.size());
        System.AssertNotEquals(null, result.get(md.mockContactId));
    }

    @isTest
    static void getMatrixMemberByIdTestGlobalInfluenceSupport() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'Admin' LIMIT 1];

        TestMockData md = new TestMockData();
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;

        // The reason why we are using actual data and not mocking is because mocking won't be able to return
        // related data, which is what we need to verify the related influence & support

        pq_Influence__c i1 = new pq_Influence__c(Name = 'Low', Label__c = 'lowlabel');
        insert i1;
        pq_Support__c s1 = new pq_Support__c(Name = 'Champion', Label__c = 'champlabel', Color__c = '#ff0011');
        insert s1;

        pq_Influence__c i2 = new pq_Influence__c(Name = 'High', Label__c = 'highlabel');
        insert i2;
        pq_Support__c s2 = new pq_Support__c(Name = 'Blocker', Label__c = 'blockerlabel', Color__c = '#ff0011');
        insert s2;

        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('map');
        Contact con = TestDataFactory.createContact('john', 'smith');

        Contact_Extended_Field__c cef1 = new Contact_Extended_Field__c(
            Contact__c = con.Id,
            Influence__c = i2.Id,
            Support__c = s2.Id
        );
        insert cef1;

        Relationship_Map_Member__c mapMember = new Relationship_Map_Member__c(
            Relationship_Map__c = rm.Id,
            Contact__c = con.Id,
            InfluenceId__c = i1.Id,
            SupportId__c = s1.Id
        );
        insert mapMember;

        RM_Chart_Setting__c chartSettings = md.mockRMChartSettingForRelationshipMap;
        chartSettings.Is_Influence_Support_Global_Scope__c = true;

        md.mocks.startStubbing();
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(rm.Id)).thenReturn(chartSettings);
        md.mocks.stopStubbing();

        MatrixMember result;
        System.runAs(adminUser) {
            result = OmniViewerController.getMatrixMemberById(mapMember.Id);
        }

        System.AssertNotEquals(null, result);
        System.AssertEquals(i2.Name, result.influence);
        System.AssertEquals(s2.Name, result.support);
    }

    @isTest
    static void getMatrixMemberByIdTestLocalInfluenceSupport() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'Admin' LIMIT 1];

        TestMockData md = new TestMockData();
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;

        // The reason why we are using actual data and not mocking is because mocking won't be able to return
        // related data, which is what we need to verify the related influence & support

        pq_Influence__c i1 = new pq_Influence__c(Name = 'Low', Label__c = 'lowlabel');
        insert i1;
        pq_Support__c s1 = new pq_Support__c(Name = 'Champion', Label__c = 'champlabel', Color__c = '#ff0011');
        insert s1;

        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('map');
        Contact con = TestDataFactory.createContact('john', 'smith');

        Relationship_Map_Member__c mapMember = new Relationship_Map_Member__c(
            Relationship_Map__c = rm.Id,
            Contact__c = con.Id,
            InfluenceId__c = i1.Id,
            SupportId__c = s1.Id
        );
        insert mapMember;

        RM_Chart_Setting__c chartSettings = md.mockRMChartSettingForRelationshipMap;
        chartSettings.Is_Influence_Support_Global_Scope__c = false;

        md.mocks.startStubbing();
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(rm.Id)).thenReturn(chartSettings);
        md.mocks.stopStubbing();

        MatrixMember result;
        System.runAs(adminUser) {
            result = OmniViewerController.getMatrixMemberById(mapMember.Id);
        }

        System.AssertNotEquals(null, result);
        System.AssertEquals(i1.Name, result.influence);
        System.AssertEquals(s1.Name, result.support);
    }

    @isTest
    static void getMatrixMembersByContactIdTest() {
        TestMockData md = new TestMockData();
        RelationshipMapMemberSelector mockRMMselector = md.mockRelationshipMapMemberSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        InfluenceSupportMatrixServiceImpl mockInfluenceSupportMatrixService = md.mockInfluenceSupportMatrixService;

        Map<Id, RM_Chart_Setting__c> settingsMap = new Map<Id, RM_Chart_Setting__c>();
        settingsMap.put(md.mockRelationshipMapId, md.mockRMChartSettingForRelationshipMap);

        Map<Id, pq_Influence_And_Support_Matrix__c> matrixMap = new Map<Id, pq_Influence_And_Support_Matrix__c>();
        matrixMap.put(md.mockRelationshipMapId, md.mockInfluenceSupportMatrix);
        matrixMap.put(md.mockRelationshipMapId, md.mockInfluenceSupportMatrix);

        md.mocks.startStubbing();
        md.mocks.when(mockRMMselector.selectByContactId(new Set<Id>{ md.mockContactId }))
            .thenReturn(new List<Relationship_Map_Member__c>{ md.mockRelationshipMapMember });
        md.mocks.when(
                mockRMChartSettingService.getRelationshipMapSettingForObjects(
                    new Set<Id>{ md.mockRelationshipMapId, md.mockRelationshipMapId },
                    false
                )
            )
            .thenReturn(settingsMap);
        md.mocks.when(
                mockInfluenceSupportMatrixService.getMatrixesForRelationshipMap(new Set<Id>{ md.mockRelationshipMapId })
            )
            .thenReturn(matrixMap);
        md.mocks.stopStubbing();

        OmniViewerController.getMatrixMembersByContactId(md.mockContactId);

        ((RelationshipMapMemberSelector) md.mocks.verify(mockRMMselector, 1))
            .selectByContactId(new Set<Id>{ md.mockContactId });

        System.Assert(true, 'Test verified by mock assertion');
    }

    @isTest
    static void getRelationshipsForContactTest() {
        TestMockData md = new TestMockData();
        ContactRelationshipSelector mockContactRelationshipSelector = md.mockContactRelationshipSelector;
        MapMemberPlaceholderRelationshipSelector mockMapMemberPlaceholderRelationshipSelector = md.mockMapMemberPlaceholderRelationshipSelector;

        OmniViewerController.getRelationshipsForContact(md.mockContactId);

        ((ContactRelationshipSelector) md.mocks.verify(mockContactRelationshipSelector, 1))
            .selectActiveCustomRelsByToOrFrom(new Set<String>{ md.mockContactId });

        ((MapMemberPlaceholderRelationshipSelector) md.mocks.verify(mockMapMemberPlaceholderRelationshipSelector, 1))
            .selectActiveCustomRelsByToOrFrom(new Set<String>{ md.mockContactId });

        System.Assert(true, 'Test verified by mock assertion');
    }

    @isTest
    static void getReportingStructureForContactTest() {
        TestMockData md = new TestMockData();
        ContactSelector mockContactSelector = md.mockContactSelector;
        MapMemberPlaceholderRelationshipSelector mockMapMemberPlaceholderRelationshipSelector = md.mockMapMemberPlaceholderRelationshipSelector;

        md.mocks.startStubbing();
        md.mocks.when(
                mockContactSelector.selectByIdAndSelectFields(
                    new Set<Id>{ md.mockContactId },
                    new Set<String>{ 'ReportsTo.Name' }
                )
            )
            .thenReturn(new List<Contact>{ md.mockContact });
        md.mocks.when(mockContactSelector.selectByReportsToId(new Set<Id>{ md.mockContactId }, new Set<String>()))
            .thenReturn(new List<Contact>{ md.mockContact });
        md.mocks.stopStubbing();

        OmniViewerController.getReportingStructureForContact(md.mockContactId);

        ((ContactSelector) md.mocks.verify(mockContactSelector, 1))
            .selectByIdAndSelectFields(new Set<Id>{ md.mockContactId }, new Set<String>{ 'ReportsTo.Name' });

        ((ContactSelector) md.mocks.verify(mockContactSelector, 1))
            .selectByReportsToId(new Set<Id>{ md.mockContactId }, new Set<String>());

        ((MapMemberPlaceholderRelationshipSelector) md.mocks.verify(mockMapMemberPlaceholderRelationshipSelector, 1))
            .selectHierarchyLinksByContactId(new Set<String>{ md.mockContactId });

        System.Assert(true, 'Test verified by mock assertion');
    }
}