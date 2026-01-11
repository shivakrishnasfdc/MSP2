public with sharing class MapMemberUserServiceImpl {
    public Set<String> userFieldSet;

    /******************************
     *      PRIVATE MEMBERS
     ******************************/

    @TestVisible
    private static List<Org_Chart_Field__c> orgChartfields {
        get {
            if (orgChartfields != null) {
                return orgChartfields;
            }
            orgChartfields = OrgChartSettingsController.getVisibleOrgChartFields('Relationship Map');
            return orgChartfields;
        }
        set;
    }

    @TestVisible
    private static map<String, Set<String>> mapMembersAndContactFields {
        get {
            if (mapMembersAndContactFields != null) {
                return mapMembersAndContactFields;
            }

            Set<String> keyStakeholderFields = new Set<String>();
            Set<String> contactFields = new Set<String>();
            Set<String> userFields = new Set<String>();

            for (Org_Chart_Field__c orgChartfield : orgChartfields) {
                if (orgChartfield.ObjectName__c == Relationship_Map_Member__c.sObjectType.getDescribe().getName()) {
                    keyStakeholderFields.add(orgChartfield.FieldName__c);
                } else if (orgChartfield.ObjectName__c == Contact.sObjectType.getDescribe().getName()) {
                    contactFields.add(orgChartfield.FieldName__c);
                } else if (orgChartfield.ObjectName__c == User.sObjectType.getDescribe().getName()) {
                    userFields.add(orgChartfield.FieldName__c);
                }
            }

            if (UtilityForSObject.isFieldReadable(Contact.sObjectType, 'PhotoUrl')) {
                contactFields.add('PhotoUrl');
            }

            if (UtilityForSObject.isFieldReadable(Contact.sObjectType, 'ReportsToId')) {
                contactFields.add('ReportsToId');
            }

            if (UtilityForSObject.isFieldReadable(User.sObjectType, 'ManagerId')) {
                userFields.add('ManagerId');
            }

            mapMembersAndContactFields = new Map<String, Set<String>>();
            mapMembersAndContactFields.put('contacts', contactFields);
            mapMembersAndContactFields.put('members', keyStakeholderFields);
            mapMembersAndContactFields.put('users', userFields);

            return mapMembersAndContactFields;
        }
        set;
    }

    /******************************
     *      PUBLIC METHODS
     ******************************/

    public GraphData createMapMemberUsers(GraphData graphData, Id mapOrAccountPlanId) {
        if (mapOrAccountPlanId == null || graphData == null || graphData.nodeDataArray == null) {
            return new GraphData();
        }

        // ----------------------------------------
        // Create the new MME records
        Set<Id> userIdSet = new Set<Id>();
        for (GraphNodeData node : graphData.nodeDataArray) {
            userIdSet.add(node.key);
        }

        Id relationshipMapId = null;
        Id accountPlanId = null;
        if (mapOrAccountPlanId.getSobjectType() == Relationship_Map__c.getSObjectType()) {
            relationshipMapId = mapOrAccountPlanId;
        } else if (mapOrAccountPlanId.getSobjectType() == Account_Plan__c.getSObjectType()) {
            accountPlanId = mapOrAccountPlanId;
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Map_Member_User__c> mapMemberUsers = new List<Map_Member_User__c>();
        for (Id userId : userIdSet) {
            Map_Member_User__c mapMemberUser = new Map_Member_User__c(
                Account_Plan__c = accountPlanId,
                Relationship_Map__c = relationshipMapId,
                User__c = userId
            );
            mapMemberUsers.add(mapMemberUser);
            uow.registerNew(mapMemberUser);
        }
        uow.commitWork();

        // ----------------------------------------
        // Store the Node Location data as provided
        RMNodeCoordinateService.updateNodeCoordinates(mapOrAccountPlanId, graphData.nodeDataArray);

        // ----------------------------------------
        // HERE - pipe to generateMapMemberUserGraphData()

        List<MapMemberUserWrapper> wrapperList = new List<MapMemberUserWrapper>();
        for (Map_Member_User__c memberUser : mapMemberUsers) {
            MapMemberUserWrapper wrapper = new MapMemberUserWrapper(memberUser);
            wrapperList.add(wrapper);
        }

        return MapMemberUserService.generateMapMemberUserGraphData(
            wrapperList,
            false, // Boolean showParentNodes - disabled 4/29/2021 - hook to settings
            true, // Boolean showEmptyFields
            mapMembersAndContactFields.get('users'), // Duped Private on RelationshipMapMemberController
            orgChartfields, // Duped Private on RelationshipMapMemberController
            mapOrAccountPlanId
        );
    }

    public void deleteMapMemberUsers(List<String> mapMemberUserIds) {
        List<Map_Member_User__c> mapMemberUsers = new List<Map_Member_User__c>();
        for (String mapMemberUserId : mapMemberUserIds) {
            mapMemberUsers.add(new Map_Member_User__c(Id = mapMemberUserId));
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(mapMemberUsers);
        uow.commitWork();
    }

    public GraphData getMapMemberUsersAndLinksByObjectId(Id objectId) {
        List<Map_Member_User__c> mapMemberUsers = MapMemberUserSelector.newInstance()
            .selectByObjectIdsWithYourUsersAndFields(
                new Set<Id>{ objectId },
                null,
                mapMembersAndContactFields.get('users')
            );

        return generateGraphDataForMapMemberUsers(mapMemberUsers, objectId);
    }

    public GraphData getAndInjectMapMemberUserNodes(GraphData graphData, Id mapOrAccountPlanId) {
        if (graphData == null) {
            return null;
        }

        // Get list of all Map Member Users registered with the Map
        List<Map_Member_User__c> mapMemberUsers = MapMemberUserSelector.newInstance()
            .selectByObjectIdsWithYourUsersAndFields(
                new Set<Id>{ mapOrAccountPlanId },
                null,
                mapMembersAndContactFields.get('users')
            );

        List<MapMemberUserWrapper> wrapperList = new List<MapMemberUserWrapper>();
        for (Map_Member_User__c memberUser : mapMemberUsers) {
            MapMemberUserWrapper wrapper = new MapMemberUserWrapper(memberUser);
            wrapperList.add(wrapper);
        }

        GraphData mmuGraph = MapMemberUserService.generateMapMemberUserGraphData(
            wrapperList, // List<IRelationshipMapUserObject>
            false, // Boolean showParentNodes
            true, // Boolean showEmptyFields
            mapMembersAndContactFields.get('users'), // Set<String> userFieldSet
            orgChartfields, // List<Org_Chart_Field__c> orgChartfields
            mapOrAccountPlanId // Relationship Map Id or Account Plan Id
        );

        // Inject MMU nodes if they are unique
        Set<Id> nodeKeys = new Set<Id>();
        for (GraphNodeData gnd : graphData.nodeDataArray) {
            nodeKeys.add(gnd.key);
        }
        for (GraphNodeData gnd : mmuGraph.nodeDataArray) {
            if (nodeKeys.contains(gnd.key)) {
                continue;
            }
            graphData.nodeDataArray.add(gnd);
        }

        // Inject all MMU links
        graphData.linkDataArray.addAll(mmuGraph.linkDataArray);

        return graphData;
    }

    public GraphData getUserGraphDataForSearchTerm(
        String searchTerm,
        List<String> excludeIds,
        List<Org_Chart_Field__c> orgChartfields,
        Set<String> userFields,
        Id mapOrAccountPlanId
    ) {
        Integer max = 100;

        List<User> users;

        Set<Id> excludeSet = new Set<Id>();
        for (String exclude : excludeIds) {
            excludeSet.add(exclude);
        }

        if (searchTerm.length() < 3) {
            users = UsersSelector.newInstance().selectAll(excludeSet, userFields, max);
        } else {
            users = UsersSelector.newInstance().search(searchTerm, excludeSet, userFields, max);
        }

        Set<Id> userIds = (new Map<Id, User>(users)).keySet();

        Set<Id> managerIds = new Set<Id>();
        for (User u : users) {
            if (u.ManagerId != null && !userIds.contains(u.ManagerId) && !excludeSet.contains(u.ManagerId)) {
                managerIds.add(u.ManagerId);
            }
        }

        List<User> managerUsers = UsersSelector.newInstance().selectByIdAndSelectFields(managerIds, userFields);

        Set<User> allUsers = new Set<User>(users);
        allUsers.addAll(managerUsers);

        Set<Id> allUserIds = new Set<Id>(userIds);
        allUserIds.addAll(managerIds);

        // "rels" --> Get list of the Users that are in Map Groups
        List<Relationship_Group_User_Association__c> rels = RelationshipGroupUserSelector.newInstance()
            .selectWithGroupsByUserIds(allUserIds);

        GraphData gd = generateUserOrgGraph(
            new Set<User>(allUsers),
            null,
            rels,
            orgChartfields,
            mapOrAccountPlanId,
            false
        );

        // Denote any nodes that are parents for Users (ManagerId)
        for (GraphNodeData gnd : gd.nodeDataArray) {
            if (managerIds.contains(gnd.key)) {
                gnd.isParentNode = true;
            }
        }

        // MAKE LINK DATA FOR LIST OF USERS WHO ARE MANAGED BY SOMEONE IN OUR LIST OF USERS
        // SO THAT WHEN WE DROP THESE ON THE CHART, THE HIERARCHY LINES INTO & OUT OF THE USERS ARE ALL ACCOUNTED FOR
        List<User> managedBy = UsersSelector.newInstance().selectByManagerIds(userIds, new Set<String>());
        for (User u : managedBy) {
            if (!allUserIds.contains(u.Id)) {
                String linkId = String.valueOf(u.ManagerId) + String.valueOf(u.Id);
                gd.linkDataArray.add(new GraphLinkData(linkId, null, u.ManagerId, true, u.Id, '__standard', null));
            }
        }

        return gd;
    }

    public GraphData getParentNodesForUserIds(
        List<Id> userIds,
        List<Org_Chart_Field__c> orgChartfields,
        Set<String> userFields,
        Id mapOrAccountPlanId
    ) {
        Set<Id> userIdsSet = new Set<Id>();
        for (String userId : userIds) {
            userIdsSet.add(userId);
        }

        List<User> childUsers = UsersSelector.newInstance().selectByIdAndSelectFields(userIdsSet, userFields);

        Set<Id> parentIdSet = new Set<Id>();
        for (User u : childUsers) {
            if (u.ManagerId != null) {
                parentIdSet.add(u.ManagerId);
            }
        }

        List<User> parentUsers = UsersSelector.newInstance().selectByIdAndSelectFields(parentIdSet, userFields);

        List<Relationship_Group_User_Association__c> rels = RelationshipGroupUserSelector.newInstance()
            .selectWithGroupsByUserIds(parentIdSet);

        GraphData childgd = generateUserOrgGraph(
            new Set<User>(childUsers),
            null,
            rels,
            orgChartfields,
            mapOrAccountPlanId,
            false
        );

        GraphData gd = generateUserOrgGraph(
            new Set<User>(parentUsers),
            null,
            rels,
            orgChartfields,
            mapOrAccountPlanId,
            false
        );

        for (GraphNodeData gnd : gd.nodeDataArray) {
            gnd.isParentNode = true;
        }

        gd.linkDataArray.addAll(childgd.linkDataArray);

        return gd;
    }

    public GraphData generateMapMemberUserGraphData(
        List<IRelationshipMapUserObject> hierarchyObjects,
        Boolean showParentNodes,
        Boolean showEmptyFields,
        Set<String> userFieldSet,
        List<Org_Chart_Field__c> orgChartfields,
        Id mapOrAccountPlanId
    ) {
        if (hierarchyObjects == null || hierarchyObjects.size() == 0) {
            return new GraphData();
        }

        this.userFieldSet = userFieldSet;

        Integer levels = 0;
        if (showParentNodes) {
            levels = 1;
        }

        Map<Id, IRelationshipMapUserObject> mapRelationshipMapMemberUserObject = new Map<Id, IRelationshipMapUserObject>();
        for (IRelationshipMapUserObject hierarchyObject : hierarchyObjects) {
            mapRelationshipMapMemberUserObject.put(hierarchyObject.userId(), hierarchyObject);
        }

        Set<User> users = getUsersAncestry(hierarchyObjects, levels);

        Set<Id> allUserIds = new Set<Id>();
        for (User u : users) {
            allUserIds.add(u.Id);
        }

        List<Relationship_Group_User_Association__c> rels = RelationshipGroupUserSelector.newInstance()
            .selectWithGroupsByUserIds(allUserIds);

        return generateUserOrgGraph(
            users,
            mapRelationshipMapMemberUserObject,
            rels,
            orgChartfields,
            mapOrAccountPlanId,
            showEmptyFields
        );
    }

    /******************************
     *      PRIVATE METHODS
     ******************************/

    private GraphData generateGraphDataForMapMemberUsers(
        List<Map_Member_User__c> mapMemberUsers,
        Id mapOrAccountPlanId
    ) {
        Id mapId = mapOrAccountPlanId;
        Boolean hasAccountPlanSetting = RelationshipMapService.hasAccountPlanSetting(mapId);

        Set<Id> userIds = new Set<Id>();
        Set<String> mapMemberUserIds = new Set<String>();
        List<GraphNodeData> gndList = new List<GraphNodeData>();

        for (Map_Member_User__c mapMemberUser : mapMemberUsers) {
            userIds.add(mapMemberUser.User__r.Id);
            mapMemberUserIds.add(mapMemberUser.Id);
        }

        Map<Id, Id> mapMemberUserGroupMap = new Map<Id, Id>();
        List<Relationship_Group_User_Association__c> groupUserAssoc = RelationshipGroupUserSelector.newInstance()
            .selectWithGroupsByUserIds(userIds);

        Map<Id, Relationship_Group__c> relGroups = new Map<Id, Relationship_Group__c>();

        if (groupUserAssoc != null) {
            for (Relationship_Group_User_Association__c rel : groupUserAssoc) {
                mapMemberUserGroupMap.put(rel.User__c, rel.Relationship_Group__c);
                relGroups.put(rel.Relationship_Group__r.Id, rel.Relationship_Group__r);
            }
        }

        // List<OrgAdditionalField> additionalFields = generateAdditionalUserFields(
        //     u,
        //     hco,
        //     orgChartfields,
        //     showEmptyFields
        // );

        for (Map_Member_User__c mapMemberUser : mapMemberUsers) {
            GraphNodeData gnd = new GraphNodeData(
                mapMemberUser.Id, // String key
                mapMemberUser.User__c, // String secondary key -> User Id reference
                'user', // String category
                mapMemberUser.FullName__c, // String name -> TODO : Pull or build up name
                mapMemberUser.Title__c, // String title -> TODO : Need email and other fields
                mapMemberUser.User__r.FullPhotoUrl, // String profileImageUrlOrData
                null, // String influence
                null, // String influenceImageUrl
                null, // String support
                null, // String supportColor
                null, // String supportImageUrl
                null, // String accountName
                null
            ); // List<OrgAdditionalFields -> Extra User Fields Here?
            gnd.groupKey = mapMemberUserGroupMap.get(mapMemberUser.Id);
            gndList.add(gnd);
        }

        // Get User Relationship Links
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapOrAccountPlanId);

        List<Map_Member_Placeholder_Relationship__c> rels;

        if (setting.Is_Relationship_Line_Global_Scope__c) {
            rels = MapMemberPlaceholderRelationshipSelector.newInstance()
                .selectGlobalRelationshipsById(mapMemberUserIds, mapOrAccountPlanId, hasAccountPlanSetting);
        } else {
            rels = MapMemberPlaceholderRelationshipSelector.newInstance()
                .selectLocalRelationshipsById(mapMemberUserIds, mapOrAccountPlanId, hasAccountPlanSetting);
        }

        // Retrieve Hierarchy Links
        List<Map_Member_Placeholder_Relationship__c> hierarchyRels = MapMemberPlaceholderRelationshipSelector.newInstance()
            .selectHierarchyLinksByPlaceholderId(new Set<Id>{ mapOrAccountPlanId }, mapMemberUserIds);
        Set<Id> relLinkIds = new Set<Id>();

        List<GraphLinkData> gldList = new List<GraphLinkData>();
        for (Map_Member_Placeholder_Relationship__c rel : rels) {
            relLinkIds.add(rel.Id);
            gldList.add(
                new GraphLinkData(
                    rel.Id,
                    null,
                    rel.From__c,
                    true,
                    rel.To__c,
                    rel.Contact_Relationship_Type__c,
                    HierarchyHelperService.getLabelForRelationship(rel)
                )
            );
        }

        for (Map_Member_Placeholder_Relationship__c rel : hierarchyRels) {
            if (!relLinkIds.contains(rel.Id)) {
                gldList.add(
                    new GraphLinkData(
                        rel.Id,
                        null,
                        rel.From__c,
                        true,
                        rel.To__c,
                        rel.Contact_Relationship_Type__c,
                        HierarchyHelperService.getLabelForRelationship(rel)
                    )
                );
            }
        }

        Map<Id, Relationship_Group__c> allGroups = RelationshipGroupService.getAllGroups(relGroups, mapOrAccountPlanId);
        if (allGroups != null) {
            gndList.addAll(RelationshipGroupService.createNodeDataForGroups(allGroups.values()));
        }

        return new GraphData(gndList, gldList);
    }

    private GraphData generateUserOrgGraph(
        Set<User> users,
        Map<Id, IRelationshipMapUserObject> mapRelationshipMapMemberUserObject,
        List<Relationship_Group_User_Association__c> rels,
        List<Org_Chart_Field__c> orgChartfields,
        Id mapOrAccountPlanId,
        Boolean showEmptyFields
    ) {
        Boolean hasAccountPlanSetting = RelationshipMapService.hasAccountPlanSetting(mapOrAccountPlanId);

        Map<Id, Relationship_Group_User_Association__c> groupUserAssocByUserId = RelationshipGroupService.getGroupUserAssocMap(
            rels,
            mapOrAccountPlanId
        );

        // ALL USERS IN THE GRAPH
        Set<String> allUserIds = new Set<String>();
        for (User u : users) {
            allUserIds.add(u.Id);
        }

        List<GraphNodeData> nodeData = new List<GraphNodeData>();
        List<GraphLinkData> linkData = new List<GraphLinkData>();

        // No Influence for Users
        // No Support for Users

        Map<Id, Relationship_Group__c> relGroups = new Map<Id, Relationship_Group__c>();

        // No User Extended Fields (so far)

        for (User u : users) {
            IRelationshipMapUserObject hco = mapRelationshipMapMemberUserObject != null
                ? mapRelationshipMapMemberUserObject.get(u.Id)
                : null;

            List<OrgAdditionalField> additionalFields = new List<OrgAdditionalField>();
            // List<OrgAdditionalField> additionalFields = generateAdditionalUserFields(
            //     u,
            //     hco,
            //     orgChartfields,
            //     showEmptyFields
            // );

            GraphNodeData newNode = generateUserNodeData(u, hco, additionalFields);

            Relationship_Group_User_Association__c groupUserAssoc = groupUserAssocByUserId.get(u.Id);
            if (groupUserAssoc != null) {
                newNode.groupKey = groupUserAssoc.Relationship_Group__c;
                relGroups.put(groupUserAssoc.Relationship_Group__r.Id, groupUserAssoc.Relationship_Group__r);
            }

            nodeData.add(newNode);

            if (u.ManagerId != null) {
                String linkId = String.valueOf(u.ManagerId) + String.valueOf(u.Id);
                linkData.add(new GraphLinkData(linkId, null, u.ManagerId, true, u.Id, '__standard', null));
            }
        }

        Map<Id, Relationship_Group__c> allGroups = RelationshipGroupService.getAllGroups(relGroups, mapOrAccountPlanId);

        nodeData.addAll(RelationshipGroupService.createNodeDataForGroups(allGroups.values()));

        // Get Relationship Links
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapOrAccountPlanId);
        List<Map_Member_Placeholder_Relationship__c> links;
        if (setting.Is_Relationship_Line_Global_Scope__c) {
            links = MapMemberPlaceholderRelationshipSelector.newInstance()
                .selectGlobalRelationshipsById(allUserIds, mapOrAccountPlanId, hasAccountPlanSetting);
        } else {
            links = MapMemberPlaceholderRelationshipSelector.newInstance()
                .selectLocalRelationshipsById(allUserIds, mapOrAccountPlanId, hasAccountPlanSetting);
        }
        for (Map_Member_Placeholder_Relationship__c link : links) {
            linkData.add(
                new GraphLinkData(
                    link.Id,
                    null,
                    link.From__c,
                    true,
                    link.To__c,
                    link.Type__c,
                    HierarchyHelperService.getLabelForRelationship(link)
                )
            );
        }

        return new GraphData(nodeData, linkData);
    }

    private Set<User> getUsersAncestry(List<IRelationshipMapUserObject> hierarchyObjects, Integer levels) {
        // Use Map instead of Set to match Contact method
        Map<Id, User> userMap = new Map<Id, User>();

        Set<Id> userIds = new Set<Id>();
        for (IRelationshipMapUserObject hierarchyObject : hierarchyObjects) {
            userIds.add(hierarchyObject.userId());
        }

        for (Integer i = 0; i <= levels; i++) {
            List<User> selectedUsers = UsersSelector.newInstance()
                .selectByIdAndSelectFields(userIds, this.userFieldSet);
            Set<Id> selectedUserIds = new Map<Id, User>(selectedUsers).keyset();

            Set<Id> newUserIds = new Set<Id>();

            for (User u : selectedUsers) {
                if (u.ManagerId != null) {
                    newUserIds.add(u.ManagerId);
                }
            }

            for (IRelationshipMapUserObject hierarchyObject : hierarchyObjects) {
                Id userId = hierarchyObject.userId();
                if (!selectedUserIds.contains(userId) && userIds.contains(userId)) {
                    selectedUsers.add(
                        new User(
                            Id = hierarchyObject.userId(),
                            FirstName = hierarchyObject.userFirstName(),
                            LastName = hierarchyObject.userLastName(),
                            ManagerId = hierarchyObject.managerId()
                        )
                    );

                    if (hierarchyObject.managerId() != null) {
                        newUserIds.add(hierarchyObject.managerId());
                    }
                }
            }

            userIds.removeAll(userIds);
            userIds.addAll(newUserIds);

            userMap.putAll(selectedUsers);

            if (userIds.isEmpty()) {
                break;
            }
        }

        Set<User> users = new Set<User>(userMap.values());

        return users;
    }

    private GraphNodeData generateUserNodeData(
        User u,
        IRelationshipMapUserObject mapMemberUser,
        List<OrgAdditionalField> additionalFields
    ) {
        Id mapMemberUserId = null;
        String type = 'manager'; // TODO --> User category switcheroo

        // If a MapMemberUser was passed in, then hook up
        if (mapMemberUser != null) {
            mapMemberUserId = mapMemberUser.id();
            type = 'user';
        }

        GraphNodeData gnd = new GraphNodeData(
            u.Id, // key
            mapMemberUserId, // secondaryKey
            type, // category
            u.Name, // name
            (String) UtilityForSObject.getFieldValue(u, 'Title'), // title
            u.FullPhotoUrl, // profileurl
            null, // influence
            null, // influenceImageUrl
            null, // support
            null, // supportColor
            null, // supportImageUrl
            null, // accountName
            null
        ); // additionalFields
        return gnd;
    }
}