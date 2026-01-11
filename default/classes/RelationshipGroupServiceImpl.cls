@SuppressWarnings('PMD.NcssMethodCount')
public with sharing class RelationshipGroupServiceImpl {
    /******************************
     *      PUBLIC METHODS
     ******************************/

    public GraphNodeData createNewGroup(GraphNodeData graphData, List<String> idList, Id mapOrAccountPlanId) {
        // idList is the list of id of members (user, contact, placeholder or group) that is being grouped
        System.debug('===createNewGroup called===');
        System.debug('==idList==' + idList);
        System.debug('==mapOrAccountPlanId==' + mapOrAccountPlanId);
        System.debug('==graphData==' + graphData);
        if (!graphData.isGroup) {
            return null;
        }

        String newName = graphData.text.length() > 80 ? graphData.text.substring(0, 80) : graphData.text;
        String newLabel = graphData.text.length() > 255 ? graphData.text.substring(0, 255) : graphData.text;

        // Find the parent group of this group (if users created a group that's within a group)
        List<Relationship_Group__c> parentGroups = RelationshipGroupSelector.newInstance()
            .selectByIdORTempKey(new Set<String>{ graphData.groupKey });
        Id parentGroupKey = null;
        if (parentGroups != null && parentGroups.size() == 1) {
            parentGroupKey = parentGroups[0].Id;
        }

        Relationship_Group__c newGroup = RMGroupHelperService.createGroup(
            newName,
            newLabel,
            graphData.key,
            parentGroupKey,
            mapOrAccountPlanId,
            graphData.groupLayout
        );

        Set<Id> idSet = new Set<Id>();
        for (String c : idList) {
            idSet.add(c);
        }

        RMGroupHelperService.removeGroupRelationships(new Set<String>(idList), mapOrAccountPlanId);
        RMGroupHelperService.addObjectsToGroup(newGroup.Id, idList, mapOrAccountPlanId);

        // Set parent groups
        List<Relationship_Group__c> groups = RelationshipGroupSelector.newInstance().selectById(idSet);

        for (Relationship_Group__c g : groups) {
            g.Parent_Relationship_Group__c = newGroup.Id;
        }

        fflib_ISObjectUnitOfWork uow2 = Application.UnitOfWork.newInstance();
        uow2.registerDirty(groups);
        uow2.commitWork();

        // Return data with new Group Id
        graphData.key = newGroup.Id;
        return graphData;
    }

    public void updateGroupName(GraphNodeData graphData, String name) {
        System.debug('===updateGroupName called===');
        System.debug('===graphData==' + graphData);
        System.debug('===name==' + name);
        if (!graphData.isGroup) {
            return;
        }

        List<Relationship_Group__c> grps = RelationshipGroupSelector.newInstance()
            .selectByIdORTempKey(new Set<String>{ graphData.key });

        String newName = name.length() > 80 ? name.substring(0, 80) : name;
        String newLabel = name.length() > 255 ? name.substring(0, 255) : name;
        System.debug('===grps before==' + grps);
        for (Relationship_Group__c grp : grps) {
            grp.Name = newName;
            grp.Label__c = newLabel;
        }
        System.debug('===grps after==' + grps);
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(grps);
        uow.commitWork();
    }

    public void addContactsToGroup(GraphNodeData graphData, List<String> objectIds, Id mapOrAccountPlanId) {
        if (!graphData.isGroup) {
            return;
        }

        List<Relationship_Group__c> grps = RelationshipGroupSelector.newInstance()
            .selectByIdORTempKey(new Set<String>{ graphData.key });

        if (grps.size() == 1) {
            Relationship_Group__c grp = grps[0];
            RMGroupHelperService.removeGroupRelationships(new Set<String>(objectIds), mapOrAccountPlanId);
            RMGroupHelperService.addObjectsToGroup(grp.Id, objectIds, mapOrAccountPlanId);
        }
    }

    public void addGroupsToGroup(GraphNodeData graphData, List<String> groupIds) {
        System.debug('===addGroupsToGroup called===');
        System.debug('==groupIds=='+groupIds);
        System.debug('==graphData=='+graphData);
        if (!graphData.isGroup) {
            return;
        }

        List<Relationship_Group__c> parentGrps = RelationshipGroupSelector.newInstance()
            .selectByIdORTempKey(new Set<String>{ graphData.key });
        System.debug('===parentGrps==='+parentGrps);
        if (parentGrps.size() == 1) {
            Relationship_Group__c parentGrp = parentGrps[0];
            List<Relationship_Group__c> childGrps = RelationshipGroupSelector.newInstance()
                .selectByIdORTempKey(new Set<String>(groupIds));
            for (Relationship_Group__c childGrp : childGrps) {
                childGrp.Parent_Relationship_Group__c = parentGrp.Id;
            }
            System.debug('===childGrps==='+childGrps);
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            uow.registerDirty(childGrps);
            uow.commitWork();
        }
    }

    public Map<Id, Relationship_Group__c> getAllGroups(
        Map<Id, Relationship_Group__c> relGroups,
        Id mapOrAccountPlanId
    ) {
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapOrAccountPlanId);

        Set<Id> groupIds = relGroups.keySet().clone();

        Map<Id, Relationship_Group__c> result = new Map<Id, Relationship_Group__c>();

        List<Relationship_Group__c> retrievedGroups;
        if (setting.Is_Group_Global_Scope__c) {
            retrievedGroups = RelationshipGroupSelector.newInstance().selectAllGlobalGroups();
        } else {
            retrievedGroups = RelationshipGroupSelector.newInstance().selectAllLocalGroups(mapOrAccountPlanId);
        }

        Map<Id, Relationship_Group__c> allGroups = new Map<Id, Relationship_Group__c>(retrievedGroups);

        do {
            Map<Id, Relationship_Group__c> grps = getGroupsForGroupIds(allGroups, groupIds);
            result.putAll(grps);

            Set<Id> parentGroupIds = getParentIdsForRelGroups(grps.values());

            groupIds.clear();

            for (Id groupId : parentGroupIds) {
                if (!result.containsKey(groupId)) {
                    groupIds.add(groupId);
                }
            }
        } while (groupIds.size() > 0);

        return result;
    }

    private Map<Id, Relationship_Group__c> getGroupsForGroupIds(
        Map<Id, Relationship_Group__c> allGroups,
        Set<Id> groupIds
    ) {
        Map<Id, Relationship_Group__c> result = new Map<Id, Relationship_Group__c>();
        for (Id groupId : groupIds) {
            Relationship_Group__c g = allGroups.get(groupId);
            if (g != null) {
                result.put(g.Id, g);
            }
        }

        return result;
    }

    private Set<Id> getParentIdsForRelGroups(List<Relationship_Group__c> grps) {
        Set<Id> groupIds = new Set<Id>();
        for (Relationship_Group__c grp : grps) {
            if (grp.Parent_Relationship_Group__c != null) {
                groupIds.add(grp.Parent_Relationship_Group__c);
            }
        }
        return groupIds;
    }

    public List<GraphNodeData> createNodeDataForGroups(List<Relationship_Group__c> relGroups) {
        List<GraphNodeData> groupNodes = new List<GraphNodeData>();
        for (Relationship_Group__c relGroup : relGroups) {
            GraphNodeData newGroupNode = new GraphNodeData(
                relGroup.Id,
                relGroup.Parent_Relationship_Group__c,
                relGroup.Label__c,
                String.IsBlank(relGroup.Layout__c) ? 'horizontal' : relGroup.Layout__c
            );
            groupNodes.add(newGroupNode);
        }
        return groupNodes;
    }

    // TURN CONTACT NODES OR GROUP NODES INTO ORPHANS (NO PARENTS)
    public void removeNodesFromGroup(List<GraphNodeData> graphNodeDataList) {
        System.debug('===removeNodesFromGroup called===');
        System.debug('==graphNodeDataList=='+graphNodeDataList);
        Map<String, String> mapObjectGroup = new Map<String, String>();
        for (GraphNodeData gnd : graphNodeDataList) {
            mapObjectGroup.put(gnd.key, gnd.groupKey);
        }

        RMGroupHelperService.removeContactsFromGroup(mapObjectGroup);
        RMGroupHelperService.removePlaceholdersFromGroup(mapObjectGroup);
        RMGroupHelperService.removeUsersFromGroup(mapObjectGroup);
        RMGroupHelperService.removeLeadsFromGroup(mapObjectGroup);
        RMGroupHelperService.removeGroupsFromGroup(mapObjectGroup);
    }

    public Map<Id, Relationship_Group_Contact_Association__c> getGroupContactAssocMap(
        List<Relationship_Group_Contact_Association__c> rels,
        Id mapOrAccountPlanId
    ) {
        Map<Id, Relationship_Group_Contact_Association__c> groupContactAssocByContactId = new Map<Id, Relationship_Group_Contact_Association__c>();
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapOrAccountPlanId);

        if (rels == null) {
            return groupContactAssocByContactId;
        }

        for (Relationship_Group_Contact_Association__c rel : rels) {
            if (rel.Relationship_Group__r == null) {
                continue;
            }
            if (setting.Is_Group_Global_Scope__c) {
                if (
                    rel.Relationship_Group__r.Relationship_Map__c == null &&
                    rel.Relationship_Group__r.Account_Plan__c == null
                ) {
                    groupContactAssocByContactId.put(rel.Contact__c, rel);
                }
            } else {
                if (
                    rel.Relationship_Group__r.get(String.valueOf(mapOrAccountPlanId.getSobjectType())) ==
                    mapOrAccountPlanId
                ) {
                    groupContactAssocByContactId.put(rel.Contact__c, rel);
                }
            }
        }

        return groupContactAssocByContactId;
    }

    public Map<Id, Relationship_Group_User_Association__c> getGroupUserAssocMap(
        List<Relationship_Group_User_Association__c> rels,
        Id mapOrAccountPlanId
    ) {
        Map<Id, Relationship_Group_User_Association__c> groupUserAssocMapByUserId = new Map<Id, Relationship_Group_User_Association__c>();
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapOrAccountPlanId);

        if (rels == null) {
            return groupUserAssocMapByUserId;
        }

        for (Relationship_Group_User_Association__c rel : rels) {
            if (rel.Relationship_Group__r == null) {
                continue;
            }
            if (setting.Is_Group_Global_Scope__c) {
                if (
                    rel.Relationship_Group__r.Relationship_Map__c == null &&
                    rel.Relationship_Group__r.Account_Plan__c == null
                ) {
                    groupUserAssocMapByUserId.put(rel.User__c, rel);
                }
            } else {
                if (
                    rel.Relationship_Group__r.get(String.valueOf(mapOrAccountPlanId.getSobjectType())) ==
                    mapOrAccountPlanId
                ) {
                    groupUserAssocMapByUserId.put(rel.User__c, rel);
                }
            }
        }

        return groupUserAssocMapByUserId;
    }

    public Map<Id, Relationship_Group_Lead_Association__c> getGroupLeadAssocMap(
        List<Relationship_Group_Lead_Association__c> rels,
        Id mapOrAccountPlanId
    ) {
        Map<Id, Relationship_Group_Lead_Association__c> groupLeadAssocMapByUserId = new Map<Id, Relationship_Group_Lead_Association__c>();
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapOrAccountPlanId);

        if (rels == null) {
            return groupLeadAssocMapByUserId;
        }

        for (Relationship_Group_Lead_Association__c rel : rels) {
            if (rel.Relationship_Group__r == null) {
                continue;
            }
            if (setting.Is_Group_Global_Scope__c) {
                if (
                    rel.Relationship_Group__r.Relationship_Map__c == null &&
                    rel.Relationship_Group__r.Account_Plan__c == null
                ) {
                    groupLeadAssocMapByUserId.put(rel.Lead__c, rel);
                }
            } else {
                if (
                    rel.Relationship_Group__r.get(String.valueOf(mapOrAccountPlanId.getSobjectType())) ==
                    mapOrAccountPlanId
                ) {
                    groupLeadAssocMapByUserId.put(rel.Lead__c, rel);
                }
            }
        }

        return groupLeadAssocMapByUserId;
    }

    // This method converts relationship group lead associations to relationship group contact associations

    public void convertLeadsToContactGroups(Set<String> leadIds, Map<Id, Id> leadContactMap) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        List<Relationship_Group_Lead_Association__c> relationshipGroupLeadAssociations = RelationshipGroupLeadSelector.newInstance()
            .selectByLeadIds(leadIds);
        for (Relationship_Group_Lead_Association__c rel : relationshipGroupLeadAssociations) {
            Id contactId = leadContactMap.get(rel.Lead__c);
            if (contactId != null) {
                Relationship_Group_Contact_Association__c newGroupContactAssociation = new Relationship_Group_Contact_Association__c(
                    Contact__c = contactId,
                    Relationship_Group__c = rel.Relationship_Group__c
                );
                uow.registerNew(newGroupContactAssociation);
            }
        }

        uow.registerDeleted(relationshipGroupLeadAssociations);
        uow.commitWork();
    }

    public void updateGroupLayout(String groupId, String type) {
        System.debug('===updateGroupLayout called===');
        System.debug('===type=='+type);
        System.debug('===groupId=='+groupId);
        List<Relationship_Group__c> grps = RelationshipGroupSelector.newInstance()
            .selectByIdORTempKey(new Set<String>{ groupId });

        if (grps.size() <= 0) {
            return;
        }

        for (Relationship_Group__c grp : grps) {
            grp.Layout__c = type;
        }
        System.debug('===grps=='+grps);
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(grps);
        uow.commitWork();
    }

    public List<RelationshipGroupContactWrapper> getGroupsForContactId(Id contactId) {
        List<Relationship_Group_Contact_Association__c> rels = RelationshipGroupContactSelector.newInstance()
            .selectWithGroupsByContactIds(new Set<Id>{ contactId });

        return RelationshipGroupContactWrapper.convert(rels);
    }
}