public with sharing class RMGroupHelperServiceImpl {
    /******************************
     *      PUBLIC METHODS
     ******************************/

    public void addObjectsToGroup(Id groupId, List<String> objectIds, Id mapOrAccountPlanId) {
        List<Relationship_Group_Contact_Association__c> newRels = new List<Relationship_Group_Contact_Association__c>();
        List<Relationship_Group_Placeholder_Assoc__c> newPlaceholderRels = new List<Relationship_Group_Placeholder_Assoc__c>();
        List<Relationship_Group_User_Association__c> newUserRels = new List<Relationship_Group_User_Association__c>();
        List<Relationship_Group_Lead_Association__c> newLeadRels = new List<Relationship_Group_Lead_Association__c>();

        for (String idString : objectIds) {
            Id objectId = Id.valueOf(idString);

            if (objectId.getSobjectType() == Contact.sObjectType) {
                newRels.add(
                    new Relationship_Group_Contact_Association__c(
                        Contact__c = objectId,
                        Relationship_Group__c = groupId
                    )
                );
            } else if (objectId.getSobjectType() == Map_Member_Placeholder__c.sObjectType) {
                newPlaceholderRels.add(
                    new Relationship_Group_Placeholder_Assoc__c(
                        Map_Member_Placeholder__c = objectId,
                        Relationship_Group__c = groupId
                    )
                );
            } else if (objectId.getSobjectType() == User.sObjectType) {
                newUserRels.add(
                    new Relationship_Group_User_Association__c(User__c = objectId, Relationship_Group__c = groupId)
                );
            } else if (objectId.getSobjectType() == Lead.sObjectType) {
                newLeadRels.add(
                    new Relationship_Group_Lead_Association__c(Lead__c = objectId, Relationship_Group__c = groupId)
                );
            }
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerNew(newRels);
        uow.registerNew(newPlaceholderRels);
        uow.registerNew(newUserRels);
        uow.registerNew(newLeadRels);
        uow.commitWork();
    }

    public void removeGroupRelationships(Set<String> objectIds, Id mapOrAccountPlanId) {
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapOrAccountPlanId);

        List<Relationship_Group_Contact_Association__c> oldRels;
        List<Relationship_Group_Placeholder_Assoc__c> oldPlaceholderRels;
        List<Relationship_Group_User_Association__c> oldUserRels;
        List<Relationship_Group_Lead_Association__c> oldLeadRels;

        if (setting.Is_Group_Global_Scope__c) {
            oldRels = RelationshipGroupContactSelector.newInstance().selectByContactIdsForGlobalGroup(objectIds);
            oldPlaceholderRels = RelationshipGroupPlaceholderSelector.newInstance()
                .selectByPlaceholderIdsForGlobalGroup(objectIds);
            oldUserRels = RelationshipGroupUserSelector.newInstance().selectByUserIdsForGlobalGroup(objectIds);
            oldLeadRels = RelationshipGroupLeadSelector.newInstance().selectByLeadIdsForGlobalGroup(objectIds);
        } else {
            oldRels = RelationshipGroupContactSelector.newInstance()
                .selectByContactIdsForLocalGroup(objectIds, mapOrAccountPlanId);
            oldPlaceholderRels = RelationshipGroupPlaceholderSelector.newInstance()
                .selectByPlaceholderIdsForLocalGroup(objectIds, mapOrAccountPlanId);
            oldUserRels = RelationshipGroupUserSelector.newInstance()
                .selectByUserIdsForLocalGroup(objectIds, mapOrAccountPlanId);
            oldLeadRels = RelationshipGroupLeadSelector.newInstance()
                .selectByLeadIdsForLocalGroup(objectIds, mapOrAccountPlanId);
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(oldRels);
        uow.registerDeleted(oldPlaceholderRels);
        uow.registerDeleted(oldUserRels);
        uow.registerDeleted(oldLeadRels);
        uow.commitWork();
    }

    public void removeContactsFromGroup(Map<String, String> mapObjectGroup) {
        System.debug('===mapObjectGroup=='+mapObjectGroup);
        Set<String> itemIds = mapObjectGroup.keySet();

        // REMOVE CONTACT GROUP LINKS
        List<Relationship_Group_Contact_Association__c> groupContactAssocs = RelationshipGroupContactSelector.newInstance()
            .selectByContactIds(itemIds);

        List<Relationship_Group_Contact_Association__c> contactGroupsToDelete = new List<Relationship_Group_Contact_Association__c>();
        for (Relationship_Group_Contact_Association__c groupContactAssoc : groupContactAssocs) {
            String groupKey = mapObjectGroup.get(groupContactAssoc.Contact__c);
            if (String.valueOf(groupContactAssoc.Relationship_Group__c) == groupKey) {
                contactGroupsToDelete.add(groupContactAssoc);
            }
        }
        System.debug('===contactGroupsToDelete=='+contactGroupsToDelete);
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(contactGroupsToDelete);
        uow.commitWork();
    }

    public void removePlaceholdersFromGroup(Map<String, String> mapObjectGroup) {
        Set<String> itemIds = mapObjectGroup.keySet();

        List<Relationship_Group_Placeholder_Assoc__c> groupPlaceholderAssocs = RelationshipGroupPlaceholderSelector.newInstance()
            .selectByPlaceholderIds(itemIds);

        List<Relationship_Group_Placeholder_Assoc__c> groupPlaceholderAssocToDelete = new List<Relationship_Group_Placeholder_Assoc__c>();
        for (Relationship_Group_Placeholder_Assoc__c groupPlaceholderAssoc : groupPlaceholderAssocs) {
            String groupKey = mapObjectGroup.get(groupPlaceholderAssoc.Map_Member_Placeholder__c);
            if (String.valueOf(groupPlaceholderAssoc.Relationship_Group__c) == groupKey) {
                groupPlaceholderAssocToDelete.add(groupPlaceholderAssoc);
            }
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(groupPlaceholderAssocToDelete);
        uow.commitWork();
    }

    public void removeUsersFromGroup(Map<String, String> mapObjectGroup) {
        Set<String> itemIds = mapObjectGroup.keySet();

        List<Relationship_Group_User_Association__c> groupUserAssocs = RelationshipGroupUserSelector.newInstance()
            .selectByUserIds(itemIds);

        List<Relationship_Group_User_Association__c> groupUserAssocToDelete = new List<Relationship_Group_User_Association__c>();
        for (Relationship_Group_User_Association__c groupUserAssoc : groupUserAssocs) {
            String groupKey = mapObjectGroup.get(groupUserAssoc.User__c);
            if (String.valueOf(groupUserAssoc.Relationship_Group__c) == groupKey) {
                groupUserAssocToDelete.add(groupUserAssoc);
            }
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(groupUserAssocToDelete);
        uow.commitWork();
    }

    public void removeLeadsFromGroup(Map<String, String> mapObjectGroup) {
        Set<String> itemIds = mapObjectGroup.keySet();

        List<Relationship_Group_Lead_Association__c> groupLeadAssocs = RelationshipGroupLeadSelector.newInstance()
            .selectByLeadIds(itemIds);

        List<Relationship_Group_Lead_Association__c> groupLeadAssocToDelete = new List<Relationship_Group_Lead_Association__c>();
        for (Relationship_Group_Lead_Association__c groupLeadAssoc : groupLeadAssocs) {
            String groupKey = mapObjectGroup.get(groupLeadAssoc.Lead__c);
            if (String.valueOf(groupLeadAssoc.Relationship_Group__c) == groupKey) {
                groupLeadAssocToDelete.add(groupLeadAssoc);
            }
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(groupLeadAssocToDelete);
        uow.commitWork();
    }

    public void removeGroupsFromGroup(Map<String, String> mapObjectGroup) {
        Set<String> itemIds = mapObjectGroup.keySet();

        List<Relationship_Group__c> childGrps = RelationshipGroupSelector.newInstance().selectByIdORTempKey(itemIds);

        List<Relationship_Group__c> groupsToUpdate = new List<Relationship_Group__c>();
        for (Relationship_Group__c childGrp : childGrps) {
            String parentId = mapObjectGroup.get(childGrp.Id);
            if (String.valueOf(childGrp.Parent_Relationship_Group__c) == parentId) {
                childGrp.Parent_Relationship_Group__c = null;
                groupsToUpdate.add(childGrp);
            }
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(groupsToUpdate);
        uow.commitWork();
    }

    public Relationship_Group__c createGroup(
        String newName,
        String newLabel,
        String tempId,
        String parentKey,
        Id mapOrAccountPlanId,
        String groupLayout
    ) {
        Relationship_Group__c newGroup = new Relationship_Group__c(
            Name = newName,
            Label__c = newLabel,
            TempId__c = tempId,
            Parent_Relationship_Group__c = parentKey,
            Layout__c = groupLayout,
            Relationship_Map__c = null,
            Account_Plan__c = null
        );

        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapOrAccountPlanId);

        if (!setting.Is_Group_Global_Scope__c && mapOrAccountPlanId != null) {
            newGroup.put(String.valueOf(mapOrAccountPlanId.getSobjectType()), mapOrAccountPlanId);
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerNew(newGroup);
        uow.commitWork();

        return newGroup;
    }
}