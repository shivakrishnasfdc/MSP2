@isTest
private class InfluenceSupportMatrixControllerTest {
    @isTest
    static void getMatrixMembersNullTest() {
        List<String> additionalFields = new List<String>{ 'CreatedDate' };
        List<MatrixMember> result = InfluenceSupportMatrixController.getMatrixMembers(null, additionalFields);
        System.assertEquals(0, result.size());
    }

    @isTest
    static void getMatrixMembersMapLocalTest() {
        TestMockData md = new TestMockData();
        SObjectServiceImpl mockSObjectService = md.mockSObjectService;
        RelationshipMapMemberSelector mockRelationshipMapMemberselector = md.mockRelationshipMapMemberSelector;
        MapMemberPlaceholderRelationshipSelector mockMapMemberPlaceholderRelationshipSelector = md.mockMapMemberPlaceholderRelationshipSelector;
        ContactSelector mockContactSelector = md.mockContactSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;

        String field = 'CreatedDate';
        List<String> additionalFields = new List<String>{ field };
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Relationship_Map_Member__c.fields.getMap();
        schema.SobjectField sObjectField = mapFields.get(field);
        Map<String, FieldMetaData> descFieldMap = new Map<String, FieldMetaData>();
        descFieldMap.put(field, new FieldMetaData(Relationship_Map_Member__c.SObjectType, sObjectField));
        md.mockRMChartSettingForRelationshipMap.Is_Influence_Support_Global_Scope__c = false;

        List<Relationship_Map_Member__c> mapMembers = new List<Relationship_Map_Member__c>{
            md.mockRelationshipMapMember
        };
        Set<String> contactIdStrings = new Set<String>{ md.mockRelationshipMapMember.Contact__c };

        List<Map_Member_Placeholder_Relationship__c> hierarchyRels = new List<Map_Member_Placeholder_Relationship__c>{
            md.mockMapMemberPlaceholderRelationship
        };
        Set<Id> contactIds = new Set<Id>{
            md.mockRelationshipMapMember.Contact__c,
            md.mockMapMemberPlaceholderRelationship.To__c,
            md.mockMapMemberPlaceholderRelationship.From__c
        };

        md.mocks.startStubbing();
        md.mocks.when(
                mockSObjectService.getDescribeFieldMapsForFields(
                    Relationship_Map_Member__c.SObjectType,
                    additionalFields
                )
            )
            .thenReturn(descFieldMap);
        md.mocks.when(
                mockRelationshipMapMemberselector.selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
                    new Set<Id>{ md.mockRelationshipMapId },
                    new Set<String>(descFieldMap.keySet()),
                    new Set<String>{ 'Title' }
                )
            )
            .thenReturn(mapMembers);
        md.mocks.when(
                mockMapMemberPlaceholderRelationshipSelector.selectHierarchyLinksByPlaceholderId(
                    new Set<Id>{ md.mockRelationshipMapId },
                    contactIdStrings
                )
            )
            .thenReturn(hierarchyRels);
        md.mocks.when(mockContactSelector.selectByIdAndSelectFields(contactIds, new Set<String>{ 'ReportsToId' }))
            .thenReturn(new List<Contact>{ md.mockContact });
        md.mocks.when(
                mockContactSelector.selectByIdAndSelectFields(
                    new Set<Id>{ md.mockParentContactId },
                    new Set<String>{ 'ReportsToId' }
                )
            )
            .thenReturn(new List<Contact>{ md.mockParentContact });
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(md.mockRMChartSettingForRelationshipMap);
        md.mocks.stopStubbing();

        InfluenceSupportMatrixController.getMatrixMembers(md.mockRelationshipMapId, additionalFields);

        ((SObjectServiceImpl) md.mocks.verify(mockSObjectService, 1))
            .getDescribeFieldMapsForFields(Relationship_Map_Member__c.SObjectType, additionalFields);

        ((RelationshipMapMemberSelector) md.mocks.verify(mockRelationshipMapMemberselector, 1))
            .selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
                new Set<Id>{ md.mockRelationshipMapId },
                new Set<String>(descFieldMap.keySet()),
                new Set<String>{ 'Title' }
            );

        ((MapMemberPlaceholderRelationshipSelector) md.mocks.verify(mockMapMemberPlaceholderRelationshipSelector, 1))
            .selectHierarchyLinksByPlaceholderId(new Set<Id>{ md.mockRelationshipMapId }, contactIdStrings);

        ((ContactSelector) md.mocks.verify(mockContactSelector, 1))
            .selectByIdAndSelectFields(contactIds, new Set<String>{ 'ReportsToId' });

        ((ContactSelector) md.mocks.verify(mockContactSelector, 1))
            .selectByIdAndSelectFields(new Set<Id>{ md.mockParentContactId }, new Set<String>{ 'ReportsToId' });

        ((RMChartSettingServiceImpl) md.mocks.verify(mockRMChartSettingService, 1))
            .getRelationshipMapSettingForObject(md.mockRelationshipMapId);

        System.assert(true, 'Assert done by mock verify');
    }

    @isTest
    static void getMatrixMembersMapGlobalTest() {
        TestMockData md = new TestMockData();
        SObjectServiceImpl mockSObjectService = md.mockSObjectService;
        RelationshipMapMemberSelector mockRelationshipMapMemberselector = md.mockRelationshipMapMemberSelector;
        MapMemberPlaceholderRelationshipSelector mockMapMemberPlaceholderRelationshipSelector = md.mockMapMemberPlaceholderRelationshipSelector;
        ContactSelector mockContactSelector = md.mockContactSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        ContactExtendedFieldSelector mockContactExtendedFieldSelector = md.mockContactExtendedFieldSelector;

        String field = 'CreatedDate';
        List<String> additionalFields = new List<String>{ field };
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Relationship_Map_Member__c.fields.getMap();
        schema.SobjectField sObjectField = mapFields.get(field);
        Map<String, FieldMetaData> descFieldMap = new Map<String, FieldMetaData>();
        descFieldMap.put(field, new FieldMetaData(Relationship_Map_Member__c.SObjectType, sObjectField));
        md.mockRMChartSettingForRelationshipMap.Is_Influence_Support_Global_Scope__c = true;

        List<Relationship_Map_Member__c> mapMembers = new List<Relationship_Map_Member__c>{
            md.mockRelationshipMapMember
        };
        Set<String> contactIdStrings = new Set<String>{ md.mockRelationshipMapMember.Contact__c };
        Set<Id> contactIds = new Set<Id>{ md.mockRelationshipMapMember.Contact__c };

        List<Map_Member_Placeholder_Relationship__c> hierarchyRels = new List<Map_Member_Placeholder_Relationship__c>{
            md.mockMapMemberPlaceholderRelationship
        };
        Set<Id> allContactIds = new Set<Id>{
            md.mockRelationshipMapMember.Contact__c,
            md.mockMapMemberPlaceholderRelationship.To__c,
            md.mockMapMemberPlaceholderRelationship.From__c
        };

        md.mocks.startStubbing();
        md.mocks.when(
                mockSObjectService.getDescribeFieldMapsForFields(
                    Relationship_Map_Member__c.SObjectType,
                    additionalFields
                )
            )
            .thenReturn(descFieldMap);
        md.mocks.when(
                mockRelationshipMapMemberselector.selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
                    new Set<Id>{ md.mockRelationshipMapId },
                    new Set<String>(descFieldMap.keySet()),
                    new Set<String>{ 'Title' }
                )
            )
            .thenReturn(mapMembers);
        md.mocks.when(
                mockMapMemberPlaceholderRelationshipSelector.selectHierarchyLinksByPlaceholderId(
                    new Set<Id>{ md.mockRelationshipMapId },
                    contactIdStrings
                )
            )
            .thenReturn(hierarchyRels);
        md.mocks.when(mockContactSelector.selectByIdAndSelectFields(allContactIds, new Set<String>{ 'ReportsToId' }))
            .thenReturn(new List<Contact>());
        md.mocks.when(mockContactSelector.selectByIdAndSelectFields(new Set<Id>(), new Set<String>{ 'ReportsToId' }))
            .thenReturn(new List<Contact>());
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(md.mockRMChartSettingForRelationshipMap);
        md.mocks.when(mockContactExtendedFieldSelector.selectByContactId(contactIds))
            .thenReturn(new List<Contact_Extended_Field__c>{ md.mockContactExtendedField });
        md.mocks.stopStubbing();

        InfluenceSupportMatrixController.getMatrixMembers(md.mockRelationshipMapId, additionalFields);

        ((SObjectServiceImpl) md.mocks.verify(mockSObjectService, 1))
            .getDescribeFieldMapsForFields(Relationship_Map_Member__c.SObjectType, additionalFields);

        ((RelationshipMapMemberSelector) md.mocks.verify(mockRelationshipMapMemberselector, 1))
            .selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
                new Set<Id>{ md.mockRelationshipMapId },
                new Set<String>(descFieldMap.keySet()),
                new Set<String>{ 'Title' }
            );

        ((MapMemberPlaceholderRelationshipSelector) md.mocks.verify(mockMapMemberPlaceholderRelationshipSelector, 1))
            .selectHierarchyLinksByPlaceholderId(new Set<Id>{ md.mockRelationshipMapId }, contactIdStrings);

        ((ContactSelector) md.mocks.verify(mockContactSelector, 1))
            .selectByIdAndSelectFields(allContactIds, new Set<String>{ 'ReportsToId' });

        ((ContactSelector) md.mocks.verify(mockContactSelector, 1))
            .selectByIdAndSelectFields(new Set<Id>(), new Set<String>{ 'ReportsToId' });

        ((RMChartSettingServiceImpl) md.mocks.verify(mockRMChartSettingService, 1))
            .getRelationshipMapSettingForObject(md.mockRelationshipMapId);

        ((ContactExtendedFieldSelector) md.mocks.verify(mockContactExtendedFieldSelector, 1))
            .selectByContactId(contactIds);

        System.assert(true, 'Assert done by mock verify');
    }
}