@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class GraphDataController {
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
                System.debug('===orgChartfield.FieldName__c==='+orgChartfield.FieldName__c);
                if (orgChartfield.ObjectName__c == Relationship_Map_Member__c.sObjectType.getDescribe().getName()) {

                    keyStakeholderFields.add(orgChartfield.FieldName__c);
                } else if (orgChartfield.ObjectName__c == Contact.sObjectType.getDescribe().getName()) {
                    contactFields.add(orgChartfield.FieldName__c);
                } else if (orgChartfield.ObjectName__c == User.sObjectType.getDescribe().getName()) {
                    userFields.add(orgChartfield.FieldName__c);
                }
            }
            System.debug('keyStakeholderFields==='+keyStakeholderFields);
            System.debug('contactFields==='+contactFields);
            System.debug('userFields==='+userFields);

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
            System.debug('====mapMembersAndContactFields==='+mapMembersAndContactFields.get('contacts'));
            System.debug('===mapMembersAndContactFields==='+mapMembersAndContactFields.get('members'));
            System.debug('===mapMembersAndContactFields==='+mapMembersAndContactFields.get('users'));
            return mapMembersAndContactFields;
        }
        set;
    }

    @AuraEnabled
    public static MatrixWrapper getMatrixByMemberId(Id memberId) {
        if (memberId == null) {
            return null;
        }

        if (memberId.getSobjectType() == Relationship_Map_Member__c.getSObjectType()) {
            return RelationshipMapMemberController.getMatrixByMemberId(memberId);
        } else if (memberId.getSobjectType() == Key_Stakeholder__c.getSObjectType()) {
            return KeyStakeholderController.getMatrixByMemberId(memberId);
        }

        return null;
    }

    @AuraEnabled
    public static MatrixMember getMatrixMemberById(Id memberId) {
        if (memberId == null) {
            return null;
        }

        if (memberId.getSobjectType() == Relationship_Map_Member__c.getSObjectType()) {
            return RelationshipMapMemberController.getMatrixMemberById(memberId);
        } else if (memberId.getSobjectType() == Key_Stakeholder__c.getSObjectType()) {
            return KeyStakeholderController.getMatrixMemberById(memberId);
        }

        return null;
    }

    @AuraEnabled
    public static void updateMatrixMember(Id memberId, String influence, String support) {
        if (memberId == null || String.isBlank(influence) || String.isBlank(support)) {
            return;
        }

        if (memberId.getSobjectType() == Relationship_Map_Member__c.getSObjectType()) {
            RelationshipMapMemberController.upsertMapMember(memberId, influence, support);
        } else if (memberId.getSobjectType() == Key_Stakeholder__c.getSObjectType()) {
            KeyStakeholderController.upsertKeyStakeholder(memberId, influence, support);
        }
    }

    // GROUPS
    @AuraEnabled
    public static void removeNodesFromGroup(String graphDataJsonString) {
        GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);
        RelationshipGroupService.removeNodesFromGroup(gd.nodeDataArray);
    }

    @AuraEnabled
    public static GraphNodeData createNewGroup(String graphDataJsonString, List<String> idList, Id objectId) {
        GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);
        if (gd != null && gd.nodeDataArray != null && gd.nodeDataArray.size() == 1) {
            return RelationshipGroupService.createNewGroup(gd.nodeDataArray[0], idList, objectId);
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static void updateGroupName(String graphDataJsonString, String newName) {
        GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);
        if (gd != null && gd.nodeDataArray != null && gd.nodeDataArray.size() == 1) {
            RelationshipGroupService.updateGroupName(gd.nodeDataArray[0], newName);
        }
    }

    @AuraEnabled
    public static void addContactsToGroup(String graphDataJsonString, List<String> contactIds, Id mapOrAccountPlanId) {
        GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);
        if (gd != null && gd.nodeDataArray != null && gd.nodeDataArray.size() == 1) {
            RelationshipGroupService.addContactsToGroup(gd.nodeDataArray[0], contactIds, mapOrAccountPlanId);
        }
    }

    @AuraEnabled
    public static void addGroupsToGroup(String graphDataJsonString, List<String> groupIds) {
        GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);
        System.debug('==graphdata gd==='+gd);
        if (gd != null && gd.nodeDataArray != null && gd.nodeDataArray.size() == 1) {
            RelationshipGroupService.addGroupsToGroup(gd.nodeDataArray[0], groupIds);
        }
    }

    @AuraEnabled
    public static void updateGroupLayout(String groupId, String type) {
        RelationshipGroupService.updateGroupLayout(groupId, type);
    }

    // CUSTOM LINKS
    @AuraEnabled
    public static void deleteCustomLinks(String graphDataJsonString) {
        GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);
        ContactRelationshipService.deleteCustomLinks(gd.linkDataArray);
    }

    @AuraEnabled
    public static void newCustomLinks(String graphDataJsonString, Id mapOrAccountPlanId) {
        GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);
        ContactRelationshipService.newCustomLinks(gd.linkDataArray, mapOrAccountPlanId);
    }

    @AuraEnabled
    public static void updateCustomLinks(String graphDataJsonString) {
        GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);
        ContactRelationshipService.updateCustomLinks(gd.linkDataArray);
    }

    // HIERARCHY LINKS
    @AuraEnabled
    public static void updateReportsTo(String graphDataJsonString, Id mapOrAccountPlanId) {
        GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);

        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapOrAccountPlanId);

        GraphDataService.updateReportsTo(gd.linkDataArray, mapOrAccountPlanId, setting);
    }
    // HIERARCHY LINKS
    @AuraEnabled
    public static void updateParentAccountId(String graphDataJsonString, Id mapOrAccountPlanId) {
        GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);

        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapOrAccountPlanId);

        GraphDataService.updateParentAccountId(gd.linkDataArray, mapOrAccountPlanId, setting);
    }

    // MAP MEMBER USERS
    @AuraEnabled
    public static GraphData createMapMemberUsers(String graphDataJsonString, Id mapOrAccountPlanId) {
        GraphData graphData = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);

        if (mapOrAccountPlanId == null || graphData == null || graphData.nodeDataArray == null) {
            return new GraphData();
        }

        GraphData result = MapMemberUserService.createMapMemberUsers(graphData, mapOrAccountPlanId);
        return result;
    }

    @AuraEnabled
    public static void deleteMapMemberUsers(List<Id> mapMemberUserIds) {
        MapMemberUserService.deleteMapMemberUsers(mapMemberUserIds);
    }

    @AuraEnabled
    public static GraphData getUserGraphDataForSearchTerm(
        String searchTerm,
        List<Id> excludeIds,
        List<String> queryFields,
        Id mapOrAccountPlanId,
        String searchKey
    ) {
        Set<String> queryFieldSet = new Set<String>(queryFields);

        GraphData gd = MapMemberUserService.getUserGraphDataForSearchTerm(
            searchTerm, // String
            excludeIds, // List<Id>
            orgChartfields, // List<Org_Chart_Field__c> orgChartfields
            //mapMembersAndContactFields.get('users'),  // Set<String>
            queryFieldSet, // TODO
            mapOrAccountPlanId // Id
        );

        if (gd != null) {
            gd.searchKey = searchKey;
        }

        return gd;
    }

    @AuraEnabled
    public static GraphData getLeadGraphDataForSearchTerm(
        String searchTerm,
        List<Id> excludeIds,
        Id mapOrAccountPlanId,
        String searchKey
    ) {
        GraphData gd = GraphDataService.getLeadGraphDataForSearchTerm(
            searchTerm, // String
            excludeIds, // List<Id>
            mapOrAccountPlanId // Id
        );

        if (gd != null) {
            gd.searchKey = searchKey;
        }

        return gd;
    }

    @AuraEnabled
    public static GraphData getParentNodesForUserIds(List<String> userIds, Id mapOrAccountPlanId) {
        return MapMemberUserService.getParentNodesForUserIds(
            userIds, // List<Id>
            orgChartfields, // List<Org_Chart_Field__c> orgChartfields
            //mapMembersAndContactFields.get('users'),  // Set<String>
            null,
            mapOrAccountPlanId // Id
        );
    }

    // PLACEHOLDERS
    @AuraEnabled
    public static GraphNodeData createNewPlaceholder(String graphDataJsonString, Id objectId) {
        GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);
        if (gd != null && gd.nodeDataArray != null && gd.nodeDataArray.size() == 1) {
            GraphNodeData result = MapMemberPlaceholderService.createNewPlaceholder(gd.nodeDataArray[0], objectId);
            RMNodeCoordinateService.updateNodeCoordinates(objectId, new List<GraphNodeData>{ result });
            return result;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static void updatePlaceholderDescription(String graphDataJsonString, String newDescription) {
        GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);
        if (gd != null && gd.nodeDataArray != null && gd.nodeDataArray.size() == 1) {
            MapMemberPlaceholderService.updatePlaceholderDescription(gd.nodeDataArray[0], newDescription);
        }
    }

    @AuraEnabled
    public static void updatePlaceholderNameAndLabel(String graphDataJsonString, String newLabel) {
        GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);
        if (gd != null && gd.nodeDataArray != null && gd.nodeDataArray.size() == 1) {
            MapMemberPlaceholderService.updatePlaceholderNameAndLabel(gd.nodeDataArray[0], newLabel);
        }
    }

    @AuraEnabled
    public static void deletePlaceholders(List<String> placeholderIds) {
        MapMemberPlaceholderService.deletePlaceholders(placeholderIds);
    }

    // SUPPORT COLORS
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getSupportColors() {
        return GraphDataService.getSupportColors();
    }

    // CONTACT RELATIONSHIP TYPES
    @AuraEnabled(cacheable=true)
    public static List<Contact_Relationship_Type__c> getContactRelationshipTypes(Id mapOrAccountPlanId) {
        return GraphDataService.getContactRelationshipTypes(mapOrAccountPlanId);
    }

    // ANCHORS
    @AuraEnabled
    public static List<RM_Anchor__c> getAnchors(String objectId) {
        return RMAnchorSelector.newInstance().selectByObjectId(new Set<Id>{ objectId });
    }

    @AuraEnabled
    public static void setAnchor(Id objectId, String rootNodeKey, String anchorNodeKey) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        List<RM_Anchor__c> anchors = RMAnchorSelector.newInstance()
            .selectByObjectIdAndFromField(objectId, new Set<String>{ rootNodeKey });

        if (anchors != null && anchors.size() > 0) {
            for (RM_Anchor__c anchor : anchors) {
                anchor.To__c = anchorNodeKey;
                uow.registerDirty(anchor);
            }
        } else {
            RM_Anchor__c anchor = new RM_Anchor__c(From__c = rootNodeKey, To__c = anchorNodeKey);
            if (objectId.getSobjectType() == Relationship_Map__c.getSObjectType()) {
                anchor.Relationship_Map__c = objectId;
            } else if (objectId.getSobjectType() == Account_Plan__c.getSObjectType()) {
                anchor.Account_Plan__c = objectId;
            }
            uow.registerNew(anchor);
        }
        uow.commitWork();
    }

    // NODE COORDINATES
    @AuraEnabled
    public static void saveAllNodeCoordinates(Id objectId, String graphDataJsonString) {
        GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);
        if (gd != null && gd.nodeDataArray != null && gd.nodeDataArray.size() > 0) {
            RMNodeCoordinateService.saveAllNodeCoordinates(objectId, gd.nodeDataArray);
        }
    }

    @AuraEnabled
    public static void updateNodeCoordinates(Id objectId, String graphDataJsonString) {
        GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);
        if (gd != null && gd.nodeDataArray != null && gd.nodeDataArray.size() > 0) {
            RMNodeCoordinateService.updateNodeCoordinates(objectId, gd.nodeDataArray);
        }
    }

    // Contact Extended Fields
    @AuraEnabled
    public static void updateProfileImageData(Id contactId, String base64Data) {
        ContactExtendedFieldService.updateProfileImageData(contactId, base64Data);
    }

    // Badge
    @AuraEnabled
    public static List<RM_Svg__c> getBadgeOptions(Id mapOrAccountPlanId) {
        Id mapId = mapOrAccountPlanId;
        List<Relationship_Map__c> maps = RelationshipMapSelector.newInstance().selectByIds(new Set<Id>{ mapId });
        Boolean hasAccountPlanSetting = false;
        Id accountPlanId = null;
        if (maps != null && !maps.isEmpty()) {
            Relationship_Map__c rmMap = maps[0];
            if (rmMap != null && rmMap?.Type_Setting__c == 'pqcrush__Account_Plan__c') {
                hasAccountPlanSetting = true;
            }

            accountPlanId = rmMap.pq_AccountPlanId__c;
        }

        return RMSvgSelector.newInstance()
            .selectByRelationshipMaps(new Set<Id>{ mapOrAccountPlanId }, hasAccountPlanSetting, accountPlanId);
    }

    @AuraEnabled
    public static void associateBadge(Id mapOrAccountPlanId, String badgeId, List<String> nodeIds) {
        RMSvgService.associateBadge(mapOrAccountPlanId, badgeId, nodeIds);
    }

    @AuraEnabled
    public static void removeBadge(Id mapOrAccountPlanId, List<String> nodeIds) {
        RMSvgService.removeBadge(mapOrAccountPlanId, nodeIds);
    }

    @AuraEnabled
    public static List<RelationshipGroupContactWrapper> getGroupsForContactId(Id contactId) {
        return RelationshipGroupService.getGroupsForContactId(contactId);
    }


}