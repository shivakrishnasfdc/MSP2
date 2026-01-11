@isTest
private class RMGroupHelperServiceTest {
    @isTest
    static void addObjectsToGroupTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        Id groupId = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType);
        Id contactId1 = fflib_IDGenerator.generate(Contact.SObjectType);
        Id placeholderId1 = fflib_IDGenerator.generate(Map_Member_Placeholder__c.SObjectType);
        Id userId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id leadId1 = fflib_IDGenerator.generate(Lead.SObjectType);

        List<String> objectIds = new List<String>{
            String.valueOf(contactId1),
            String.valueOf(placeholderId1),
            String.valueOf(userId1),
            String.valueOf(leadId1)
        };

        RMGroupHelperService.addObjectsToGroup(groupId, objectIds, md.mockRelationshipMapId);

        List<Relationship_Group_Contact_Association__c> newRels = new List<Relationship_Group_Contact_Association__c>{
            new Relationship_Group_Contact_Association__c(Contact__c = contactId1, Relationship_Group__c = groupId)
        };
        List<Relationship_Group_Placeholder_Assoc__c> newPlaceholderRels = new List<Relationship_Group_Placeholder_Assoc__c>{
            new Relationship_Group_Placeholder_Assoc__c(
                Map_Member_Placeholder__c = placeholderId1,
                Relationship_Group__c = groupId
            )
        };
        List<Relationship_Group_User_Association__c> newUserRels = new List<Relationship_Group_User_Association__c>{
            new Relationship_Group_User_Association__c(User__c = userId1, Relationship_Group__c = groupId)
        };
        List<Relationship_Group_Lead_Association__c> newLeadRels = new List<Relationship_Group_Lead_Association__c>{
            new Relationship_Group_Lead_Association__c(Lead__c = leadId1, Relationship_Group__c = groupId)
        };

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew(newRels);
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew(newPlaceholderRels);
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew(newUserRels);
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew(newLeadRels);
        System.assert(true, 'Assert by mock verify');
    }

    @isTest
    static void removeGroupRelationshipsGlobalTest() {
        TestMockData md = new TestMockData();
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        RelationshipGroupContactSelector mockRelationshipGroupContactSelector = md.mockRelationshipGroupContactSelector;
        RelationshipGroupPlaceholderSelector mockRelationshipGroupPlaceholderSelector = md.mockRelationshipGroupPlaceholderSelector;
        RelationshipGroupUserSelector mockRelationshipGroupUserSelector = md.mockRelationshipGroupUserSelector;
        RelationshipGroupLeadSelector mockRelationshipGroupLeadSelector = md.mockRelationshipGroupLeadSelector;

        Id contactId1 = fflib_IDGenerator.generate(Contact.SObjectType);
        Id placeholderId1 = fflib_IDGenerator.generate(Map_Member_Placeholder__c.SObjectType);
        Id userId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id leadId1 = fflib_IDGenerator.generate(Lead.SObjectType);

        Set<String> objectIds = new Set<String>{
            String.valueOf(contactId1),
            String.valueOf(placeholderId1),
            String.valueOf(userId1),
            String.valueOf(leadId1)
        };

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipGroupContactSelector.selectByContactIdsForGlobalGroup(objectIds))
            .thenReturn(new List<Relationship_Group_Contact_Association__c>());
        md.mocks.when(mockRelationshipGroupPlaceholderSelector.selectByPlaceholderIdsForGlobalGroup(objectIds))
            .thenReturn(new List<Relationship_Group_Placeholder_Assoc__c>());
        md.mocks.when(mockRelationshipGroupUserSelector.selectByUserIdsForGlobalGroup(objectIds))
            .thenReturn(new List<Relationship_Group_User_Association__c>());
        md.mocks.when(mockRelationshipGroupLeadSelector.selectByLeadIdsForGlobalGroup(objectIds))
            .thenReturn(new List<Relationship_Group_Lead_Association__c>());
        md.mocks.stopStubbing();

        RM_Chart_Setting__c chartSetting = new RM_Chart_Setting__c(Is_Group_Global_Scope__c = true);

        md.mocks.startStubbing();
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(chartSetting);
        md.mocks.stopStubbing();

        RMGroupHelperService.removeGroupRelationships(objectIds, md.mockRelationshipMapId);

        ((RelationshipGroupContactSelector) md.mocks.verify(mockRelationshipGroupContactSelector, 1))
            .selectByContactIdsForGlobalGroup(objectIds);
        ((RelationshipGroupPlaceholderSelector) md.mocks.verify(mockRelationshipGroupPlaceholderSelector, 1))
            .selectByPlaceholderIdsForGlobalGroup(objectIds);
        ((RelationshipGroupUserSelector) md.mocks.verify(mockRelationshipGroupUserSelector, 1))
            .selectByUserIdsForGlobalGroup(objectIds);
        ((RelationshipGroupLeadSelector) md.mocks.verify(mockRelationshipGroupLeadSelector, 1))
            .selectByLeadIdsForGlobalGroup(objectIds);
        System.assert(true, 'Assert by mock verify');
    }

    @isTest
    static void removeGroupRelationshipsLocalTest() {
        TestMockData md = new TestMockData();
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        RelationshipGroupContactSelector mockRelationshipGroupContactSelector = md.mockRelationshipGroupContactSelector;
        RelationshipGroupPlaceholderSelector mockRelationshipGroupPlaceholderSelector = md.mockRelationshipGroupPlaceholderSelector;
        RelationshipGroupUserSelector mockRelationshipGroupUserSelector = md.mockRelationshipGroupUserSelector;
        RelationshipGroupLeadSelector mockRelationshipGroupLeadSelector = md.mockRelationshipGroupLeadSelector;

        Id contactId1 = fflib_IDGenerator.generate(Contact.SObjectType);
        Id placeholderId1 = fflib_IDGenerator.generate(Map_Member_Placeholder__c.SObjectType);
        Id userId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id leadId1 = fflib_IDGenerator.generate(Lead.SObjectType);

        Set<String> objectIds = new Set<String>{
            String.valueOf(contactId1),
            String.valueOf(placeholderId1),
            String.valueOf(userId1),
            String.valueOf(leadId1)
        };

        md.mocks.startStubbing();
        md.mocks.when(
                mockRelationshipGroupContactSelector.selectByContactIdsForLocalGroup(
                    objectIds,
                    md.mockRelationshipMapId
                )
            )
            .thenReturn(new List<Relationship_Group_Contact_Association__c>());
        md.mocks.when(
                mockRelationshipGroupPlaceholderSelector.selectByPlaceholderIdsForLocalGroup(
                    objectIds,
                    md.mockRelationshipMapId
                )
            )
            .thenReturn(new List<Relationship_Group_Placeholder_Assoc__c>());
        md.mocks.when(
                mockRelationshipGroupUserSelector.selectByUserIdsForLocalGroup(objectIds, md.mockRelationshipMapId)
            )
            .thenReturn(new List<Relationship_Group_User_Association__c>());
        md.mocks.when(
                mockRelationshipGroupLeadSelector.selectByLeadIdsForLocalGroup(objectIds, md.mockRelationshipMapId)
            )
            .thenReturn(new List<Relationship_Group_Lead_Association__c>());
        md.mocks.stopStubbing();

        RM_Chart_Setting__c chartSetting = new RM_Chart_Setting__c(Is_Group_Global_Scope__c = false);

        md.mocks.startStubbing();
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(chartSetting);
        md.mocks.stopStubbing();

        RMGroupHelperService.removeGroupRelationships(objectIds, md.mockRelationshipMapId);

        ((RelationshipGroupContactSelector) md.mocks.verify(mockRelationshipGroupContactSelector, 1))
            .selectByContactIdsForLocalGroup(objectIds, md.mockRelationshipMapId);
        ((RelationshipGroupPlaceholderSelector) md.mocks.verify(mockRelationshipGroupPlaceholderSelector, 1))
            .selectByPlaceholderIdsForLocalGroup(objectIds, md.mockRelationshipMapId);
        ((RelationshipGroupUserSelector) md.mocks.verify(mockRelationshipGroupUserSelector, 1))
            .selectByUserIdsForLocalGroup(objectIds, md.mockRelationshipMapId);
        ((RelationshipGroupLeadSelector) md.mocks.verify(mockRelationshipGroupLeadSelector, 1))
            .selectByLeadIdsForLocalGroup(objectIds, md.mockRelationshipMapId);
        System.assert(true, 'Assert by mock verify');
    }

    @isTest
    static void removeContactsFromGroupTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RelationshipGroupContactSelector mockRelationshipGroupContactSelector = md.mockRelationshipGroupContactSelector;

        Id groupId = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType);
        Id contactId1 = fflib_IDGenerator.generate(Contact.SObjectType);
        Id placeholderId1 = fflib_IDGenerator.generate(Map_Member_Placeholder__c.SObjectType);
        Id userId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id leadId1 = fflib_IDGenerator.generate(Lead.SObjectType);

        Set<String> objectIds = new Set<String>{
            String.valueOf(contactId1),
            String.valueOf(placeholderId1),
            String.valueOf(userId1),
            String.valueOf(leadId1)
        };

        Map<String, String> mapObjectGroup = new Map<String, String>();
        mapObjectGroup.put(String.valueOf(contactId1), String.valueOf(groupId));
        mapObjectGroup.put(String.valueOf(placeholderId1), String.valueOf(groupId));
        mapObjectGroup.put(String.valueOf(userId1), String.valueOf(groupId));
        mapObjectGroup.put(String.valueOf(leadId1), String.valueOf(groupId));

        List<Relationship_Group_Contact_Association__c> groupContactAssocs = new List<Relationship_Group_Contact_Association__c>();
        groupContactAssocs.add(
            new Relationship_Group_Contact_Association__c(Contact__c = contactId1, Relationship_Group__c = groupId)
        );

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipGroupContactSelector.selectByContactIds(objectIds))
            .thenReturn(groupContactAssocs);
        md.mocks.stopStubbing();

        RMGroupHelperService.removeContactsFromGroup(mapObjectGroup);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDeleted(groupContactAssocs);
        System.assert(true, 'Assert by mock verify');
    }

    @isTest
    static void removePlaceholdersFromGroupTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RelationshipGroupPlaceholderSelector mockRelationshipGroupPlaceholderSelector = md.mockRelationshipGroupPlaceholderSelector;

        Id groupId = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType);
        Id contactId1 = fflib_IDGenerator.generate(Contact.SObjectType);
        Id placeholderId1 = fflib_IDGenerator.generate(Map_Member_Placeholder__c.SObjectType);
        Id userId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id leadId1 = fflib_IDGenerator.generate(Lead.SObjectType);

        Set<String> objectIds = new Set<String>{
            String.valueOf(contactId1),
            String.valueOf(placeholderId1),
            String.valueOf(userId1),
            String.valueOf(leadId1)
        };

        Map<String, String> mapObjectGroup = new Map<String, String>();
        mapObjectGroup.put(String.valueOf(contactId1), String.valueOf(groupId));
        mapObjectGroup.put(String.valueOf(placeholderId1), String.valueOf(groupId));
        mapObjectGroup.put(String.valueOf(userId1), String.valueOf(groupId));
        mapObjectGroup.put(String.valueOf(leadId1), String.valueOf(groupId));

        List<Relationship_Group_Placeholder_Assoc__c> assocs = new List<Relationship_Group_Placeholder_Assoc__c>();
        assocs.add(
            new Relationship_Group_Placeholder_Assoc__c(
                Map_Member_Placeholder__c = placeholderId1,
                Relationship_Group__c = groupId
            )
        );

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipGroupPlaceholderSelector.selectByPlaceholderIds(objectIds)).thenReturn(assocs);
        md.mocks.stopStubbing();

        RMGroupHelperService.removePlaceholdersFromGroup(mapObjectGroup);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDeleted(assocs);
        System.assert(true, 'Assert by mock verify');
    }

    @isTest
    static void removeUsersFromGroupTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RelationshipGroupUserSelector mockRelationshipGroupUserSelector = md.mockRelationshipGroupUserSelector;

        Id groupId = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType);
        Id contactId1 = fflib_IDGenerator.generate(Contact.SObjectType);
        Id placeholderId1 = fflib_IDGenerator.generate(Map_Member_Placeholder__c.SObjectType);
        Id userId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id leadId1 = fflib_IDGenerator.generate(Lead.SObjectType);

        Set<String> objectIds = new Set<String>{
            String.valueOf(contactId1),
            String.valueOf(placeholderId1),
            String.valueOf(userId1),
            String.valueOf(leadId1)
        };

        Map<String, String> mapObjectGroup = new Map<String, String>();
        mapObjectGroup.put(String.valueOf(contactId1), String.valueOf(groupId));
        mapObjectGroup.put(String.valueOf(placeholderId1), String.valueOf(groupId));
        mapObjectGroup.put(String.valueOf(userId1), String.valueOf(groupId));
        mapObjectGroup.put(String.valueOf(leadId1), String.valueOf(groupId));

        List<Relationship_Group_User_Association__c> assocs = new List<Relationship_Group_User_Association__c>();
        assocs.add(new Relationship_Group_User_Association__c(User__c = userId1, Relationship_Group__c = groupId));

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipGroupUserSelector.selectByUserIds(objectIds)).thenReturn(assocs);
        md.mocks.stopStubbing();

        RMGroupHelperService.removeUsersFromGroup(mapObjectGroup);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDeleted(assocs);
        System.assert(true, 'Assert by mock verify');
    }

    @isTest
    static void removeLeadsFromGroupTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RelationshipGroupLeadSelector mockRelationshipGroupLeadSelector = md.mockRelationshipGroupLeadSelector;

        Id groupId = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType);
        Id contactId1 = fflib_IDGenerator.generate(Contact.SObjectType);
        Id placeholderId1 = fflib_IDGenerator.generate(Map_Member_Placeholder__c.SObjectType);
        Id userId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id leadId1 = fflib_IDGenerator.generate(Lead.SObjectType);

        Set<String> objectIds = new Set<String>{
            String.valueOf(contactId1),
            String.valueOf(placeholderId1),
            String.valueOf(userId1),
            String.valueOf(leadId1)
        };

        Map<String, String> mapObjectGroup = new Map<String, String>();
        mapObjectGroup.put(String.valueOf(contactId1), String.valueOf(groupId));
        mapObjectGroup.put(String.valueOf(placeholderId1), String.valueOf(groupId));
        mapObjectGroup.put(String.valueOf(userId1), String.valueOf(groupId));
        mapObjectGroup.put(String.valueOf(leadId1), String.valueOf(groupId));

        List<Relationship_Group_Lead_Association__c> assocs = new List<Relationship_Group_Lead_Association__c>();
        assocs.add(new Relationship_Group_Lead_Association__c(Lead__c = leadId1, Relationship_Group__c = groupId));

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipGroupLeadSelector.selectByLeadIds(objectIds)).thenReturn(assocs);
        md.mocks.stopStubbing();

        RMGroupHelperService.removeLeadsFromGroup(mapObjectGroup);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDeleted(assocs);
        System.assert(true, 'Assert by mock verify');
    }

    @isTest
    static void removeGroupsFromGroupTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RelationshipGroupSelector mockRelationshipGroupSelector = md.mockRelationshipGroupSelector;

        Id groupId = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType);
        Id contactId1 = fflib_IDGenerator.generate(Contact.SObjectType);
        Id placeholderId1 = fflib_IDGenerator.generate(Map_Member_Placeholder__c.SObjectType);
        Id userId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id leadId1 = fflib_IDGenerator.generate(Lead.SObjectType);

        Set<String> objectIds = new Set<String>{
            String.valueOf(contactId1),
            String.valueOf(placeholderId1),
            String.valueOf(userId1),
            String.valueOf(leadId1)
        };

        Map<String, String> mapObjectGroup = new Map<String, String>();
        mapObjectGroup.put(String.valueOf(contactId1), String.valueOf(groupId));
        mapObjectGroup.put(String.valueOf(placeholderId1), String.valueOf(groupId));
        mapObjectGroup.put(String.valueOf(userId1), String.valueOf(groupId));
        mapObjectGroup.put(String.valueOf(leadId1), String.valueOf(groupId));

        List<Relationship_Group__c> groups = new List<Relationship_Group__c>();
        groups.add(new Relationship_Group__c(Parent_Relationship_Group__c = groupId));

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipGroupSelector.selectByIdORTempKey(objectIds)).thenReturn(groups);
        md.mocks.stopStubbing();

        groups[0].Parent_Relationship_Group__c = null;

        RMGroupHelperService.removeGroupsFromGroup(mapObjectGroup);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(groups);
        System.assert(true, 'Assert by mock verify');
    }

    @isTest
    static void createGroupTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;

        String newName = 'groupName';
        String newLabel = 'groupLabel';
        String tempId = 'abc';
        String parentKey = (String) fflib_IDGenerator.generate(Relationship_Group__c.SObjectType);
        Id mapOrAccountPlanId = md.mockRelationshipMapId;
        String groupLayout = 'Horizontal';

        RM_Chart_Setting__c chartSetting = new RM_Chart_Setting__c(Is_Group_Global_Scope__c = false);

        md.mocks.startStubbing();
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(chartSetting);
        md.mocks.stopStubbing();

        RMGroupHelperService.createGroup(newName, newLabel, tempId, parentKey, mapOrAccountPlanId, groupLayout);

        Relationship_Group__c newGroup = new Relationship_Group__c(
            Name = newName,
            Label__c = newLabel,
            TempId__c = tempId,
            Parent_Relationship_Group__c = parentKey,
            Layout__c = groupLayout,
            Relationship_Map__c = mapOrAccountPlanId,
            Account_Plan__c = null
        );

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew(newGroup);
        System.assert(true, 'Assert by mock verify');
    }
}