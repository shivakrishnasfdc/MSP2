@SuppressWarnings('PMD.NcssMethodCount')
public with sharing class RelationshipMapCloneServiceImpl {
    public static final Integer BATCH_SIZE = 5000;

    public List<Relationship_Map__c> cloneRelationshipMaps(
        List<RelationshipMapCloneWrapper> cloneWrappers,
        List<SObject> clonedRelatedObjs,
        Set<Schema.SObjectType> relatedObjectTypes,
        Boolean startBatches
    ) {
        Application.bypassTrigger = true;
        if (cloneWrappers.isEmpty()) {
            return new List<Relationship_Map__c>();
        }

        Set<Id> mapIds = new Set<Id>();
        for (RelationshipMapCloneWrapper cloneData : cloneWrappers) {
            cloneData.validationCheck();
            mapIds.add(cloneData.mapId);
        }

        List<Relationship_Map__c> maps = (List<Relationship_Map__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            pqcrush__Relationship_Map__c.getSObjectType(),
            mapIds,
            new Set<String>{ 'Id' }
        );
        Map<Id, Relationship_Map__c> originalMapsByMapId = new Map<Id, Relationship_Map__c>(maps);
        List<Relationship_Map__c> clonedMaps = new List<Relationship_Map__c>();
        List<RelationshipMapCloneWrapper> wrappersWithRelatedObj = new List<RelationshipMapCloneWrapper>();
        List<Schema.SObjectType> objTypes = new List<Schema.SObjectType>();
        for (RelationshipMapCloneWrapper cloneData : cloneWrappers) {
            Relationship_Map__c relMap = originalMapsByMapId.get(cloneData.mapId);
            Relationship_Map__c clone = relMap.clone(false, true, false, false); //deep clone, does not preserve Id, timestamps, or autonumber
            system.debug('cloneData>>>>'+cloneData);
            system.debug('cloneData.newName>>>'+cloneData.newName);
            /*if (!String.isBlank(cloneData.newName)) {
                clone.Name = cloneData.newName;
            }*/
            //clone.Name='Lakshman';
            if (!String.isBlank(cloneData.newOwnerId)) {
                clone.OwnerId = cloneData.newOwnerId;
            }
            if (cloneData.relatedField != null) {
                if (cloneData.relatedFieldObjType == Relationship_Map__c.SObjectType) {
                    clone.put(cloneData.relatedField, cloneData.newRelatedObjId);
                } else {
                    objTypes.add(cloneData.relatedFieldObjType);
                    wrappersWithRelatedObj.add(cloneData);
                }
            }
            clonedMaps.add(clone);
            cloneData.clonedMap = clone;
        }
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerNew(clonedMaps);
        new SystemContext().commitWork(uow);

        if (wrappersWithRelatedObj.size() > 0) {
            fflib_ISObjectUnitOfWork relatedUow = new fflib_Application.UnitOfWorkFactory(objTypes)
                .newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
            for (RelationshipMapCloneWrapper cloneData : wrappersWithRelatedObj) {
                SObject obj = cloneData.relatedFieldObjType.newSObject(cloneData.newRelatedObjId);
                obj.put(cloneData.relatedField, cloneData.clonedMap.Id);
                relatedUow.registerDirty(obj, new List<SObjectField>{ cloneData.relatedField });
            }
            new SystemContext().commitWork(relatedUow);
        }

        clonedRelationshipsForMaps(
            originalMapsByMapId,
            cloneWrappers,
            clonedRelatedObjs,
            relatedObjectTypes,
            startBatches
        );
        Application.bypassTrigger = false;
        return clonedMaps;
    }

    private void clonedRelationshipsForMaps(
        Map<Id, Relationship_Map__c> originalMaps,
        List<RelationshipMapCloneWrapper> wrappers,
        List<SObject> clonedRelatedObjs,
        Set<Schema.SObjectType> relatedObjectTypes,
        Boolean startBatches
    ) {
        List<Schema.ChildRelationship> relationships = Schema.SObjectType.Relationship_Map__c.getChildRelationships();
        Map<String, Schema.ChildRelationship> childRelationshipsByRelationshipName = new Map<String, Schema.ChildRelationship>();
        for (Schema.ChildRelationship cr : relationships) {
            childRelationshipsByRelationshipName.put(cr.getRelationshipName(), cr);
        }
        Map<String, Set<Id>> mapIdsByRelationship = mapIdsByRelationshipForWrappers(wrappers);
        if (clonedRelatedObjs == null) {
            clonedRelatedObjs = new List<SObject>();
        }
        if (relatedObjectTypes == null) {
            relatedObjectTypes = new Set<Schema.SObjectType>();
        }
        List<Map<Id, RelationshipMapCloneWrapper>> wrapperByMapIdNoDupeLists = dedupedWrapperByMapIdList(wrappers);
        for (String relationshipName : mapIdsByRelationship.keySet()) {
            Schema.ChildRelationship relationship = childRelationshipsByRelationshipName.get(relationshipName);
            if (relationship == null) {
                continue;
            }
            Set<Id> mapIdset = mapIdsByRelationship.get(relationshipName);
            String parentRelationshipName = relationship.getField().getDescribe().getName();
            String childObjectName = relationship.getChildSObject().getDescribe().getName();
            relatedObjectTypes.add(relationship.getChildSObject());
            List<SObject> relatedObjects = CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
                Application.getGlobalDescribe().get(childObjectName),
                mapIdset,
                new Set<String>{ parentRelationshipName }
            );
            if (relationshipName == RelationshipMapCloneService.PLACEHOLDER_RELATIONSHIP_NAME) {
                relatedObjectTypes.add(Map_Member_User__c.getSObjectType());
                relatedObjectTypes.add(Map_Member_Placeholder_Relationship__c.getSObjectType());
                relatedObjectTypes.add(Relationship_Group__c.getSObjectType());
                relatedObjectTypes.add(Relationship_Group_Placeholder_Assoc__c.getSObjectType());
                relatedObjectTypes.add(Relationship_Group_Contact_Association__c.getSObjectType());
                relatedObjectTypes.add(Relationship_Group_Lead_Association__c.getSObjectType());
                relatedObjectTypes.add(Relationship_Group_User_Association__c.getSObjectType());
                relatedObjectTypes.add(RM_Node_Coordinate__c.getSObjectType());
                relatedObjectTypes.add(RM_Anchor__c.getSObjectType());
                relatedObjectTypes.add(RM_Svg_Node_Association__c.getSObjectType());

                clonedRelatedObjs.addAll(
                    cloneMapMemberDependenciesWithPlaceholders(
                        relatedObjects,
                        parentRelationshipName,
                        wrapperByMapIdNoDupeLists,
                        mapIdset
                    )
                );
            } else {
                for (Map<Id, RelationshipMapCloneWrapper> wrapperList : wrapperByMapIdNoDupeLists) {
                    Map<Id, Relationship_Map__c> clonedMaps = clonedMapMapForWrapperByRelationshipMap(
                        wrapperList,
                        relationshipName
                    );
                    if (clonedMaps.size() == 0) {
                        continue;
                    }
                    clonedRelatedObjs.addAll(
                        CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                                relatedObjects,
                                clonedMaps,
                                new Set<String>{ parentRelationshipName }
                            )
                            .values()
                    );
                }
            }
        }
        if (startBatches) {
            BatchInsert batch = new BatchInsert();
            batch.bypassTriggers = true;
            batch.objsToInsert = clonedRelatedObjs;
            batch.relatedObjectTypes = new List<Schema.SObjectType>(relatedObjectTypes);
            Database.executeBatch(batch, BATCH_SIZE);
        }
    }

    private List<SObject> cloneMapMemberDependenciesWithPlaceholders(
        List<Map_Member_Placeholder__c> relatedPlaceholders,
        String mapRelationshipName,
        List<Map<Id, RelationshipMapCloneWrapper>> dedupedWrappers,
        Set<Id> mapIdset
    ) {
        //Placeholders, Users & Groups
        String userMapRelationshipName = Map_Member_User__c.Relationship_Map__c.getDescribe().getName();
        List<Map_Member_User__c> relatedUsers = (List<Map_Member_User__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            Map_Member_User__c.getSObjectType(),
            mapIdset,
            new Set<String>{ userMapRelationshipName }
        );

        String groupMapRelationshipName = Relationship_Group__c.Relationship_Map__c.getDescribe().getName();
        List<Relationship_Group__c> relatedGroups = (List<Relationship_Group__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            Relationship_Group__c.getSObjectType(),
            mapIdset,
            new Set<String>{ groupMapRelationshipName }
        );
        List<Map<Id, SObject>> dedupedClonedPlaceholdersByOriginalId = new List<Map<Id, SObject>>();
        List<Map<Id, SObject>> dedupedClonedUsersByOriginalId = new List<Map<Id, SObject>>();
        List<Map<Id, Relationship_Group__c>> dedupedClonedGroupsByOriginalId = new List<Map<Id, Relationship_Group__c>>();
        List<Map<Id, SObject>> dedupedClonedMixedObjectsByOriginalId = new List<Map<Id, SObject>>();
        fflib_ISObjectUnitOfWork placeholderUoW = new fflib_Application.UnitOfWorkFactory(
                new List<Schema.SObjectType>{
                    Map_Member_Placeholder__c.getSObjectType(),
                    Map_Member_User__c.getSObjectType(),
                    Relationship_Group__c.getSObjectType()
                }
            )
            .newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        for (Map<Id, RelationshipMapCloneWrapper> wrapperList : dedupedWrappers) {
            Map<Id, Relationship_Map__c> clonedMapsByOriginalId = clonedMapMapForWrapperByRelationshipMap(
                wrapperList,
                RelationshipMapCloneService.PLACEHOLDER_RELATIONSHIP_NAME
            );
            if (clonedMapsByOriginalId.size() == 0) {
                continue;
            }

            //Clone placeholders and seperate into deduped list for next step
            Map<Id, SObject> clonedPlaceholdersByOriginalId = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedPlaceholders,
                clonedMapsByOriginalId,
                new Set<String>{ mapRelationshipName }
            );
            dedupedClonedPlaceholdersByOriginalId.add(clonedPlaceholdersByOriginalId);
            placeholderUoW.registerNew(clonedPlaceholdersByOriginalId.values());
            //Clone Users and seperate into deduped list for next step
            Map<Id, SObject> clonedUsersByOriginalId = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedUsers,
                clonedMapsByOriginalId,
                new Set<String>{ userMapRelationshipName }
            );
            dedupedClonedUsersByOriginalId.add(clonedUsersByOriginalId);
            placeholderUoW.registerNew(clonedUsersByOriginalId.values());
            //Clone groups and seperate add to deduped list for next step
            Map<Id, Relationship_Group__c> clonedGroupsByOriginalId = (Map<Id, Relationship_Group__c>) CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedGroups,
                clonedMapsByOriginalId,
                new Set<String>{ groupMapRelationshipName },
                Map<Id, Relationship_Group__c>.class
            );
            dedupedClonedGroupsByOriginalId.add(clonedGroupsByOriginalId);
            Map<Id, SObject> mixed = new Map<Id, SObject>(clonedPlaceholdersByOriginalId);
            mixed.putAll(clonedGroupsByOriginalId);
            mixed.putAll(clonedUsersByOriginalId);
            mixed.putAll(clonedMapsByOriginalId);
            dedupedClonedMixedObjectsByOriginalId.add(mixed);
            placeholderUoW.registerNew(clonedGroupsByOriginalId.values());
        }
        new SystemContext().commitWork(placeholderUoW);
        Set<Id> originalPlaceholderIdSet = new Map<Id, Map_Member_Placeholder__c>(relatedPlaceholders).keySet();
        Set<Id> originalGroupIdSet = new Map<Id, Relationship_Group__c>(relatedGroups).keySet();
        Set<Id> originalMixedObjectIdSet = new Set<Id>(originalPlaceholderIdSet);
        originalMixedObjectIdSet.addAll(originalGroupIdSet);
        originalMixedObjectIdSet.addAll(mapIdset);

        //Placeholder Relationships
        List<SObject> clonedObjectsNotInserted = new List<SObject>();
        String fromPlaceholderRelName = Map_Member_Placeholder_Relationship__c.From__c.getDescribe().getName();
        String toPlaceholderRelName = Map_Member_Placeholder_Relationship__c.To__c.getDescribe().getName();
        String mapPlaceholderRelName = Map_Member_Placeholder_Relationship__c.Relationship_Map__c.getDescribe()
            .getName();
        Set<String> parentFields = new Set<String>{
            fromPlaceholderRelName,
            toPlaceholderRelName,
            mapPlaceholderRelName
        };
        List<Map_Member_Placeholder_Relationship__c> relatedRelationships = (List<Map_Member_Placeholder_Relationship__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            Map_Member_Placeholder_Relationship__c.getSObjectType(),
            originalMixedObjectIdSet,
            parentFields
        );

        for (Map<Id, SObject> clonedMixedByOriginalId : dedupedClonedMixedObjectsByOriginalId) {
            Map<Id, SObject> clonedPlaceholderRelationshipsMap = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedRelationships,
                clonedMixedByOriginalId,
                parentFields
            );
            clonedObjectsNotInserted.addAll(clonedPlaceholderRelationshipsMap.values());
        }

        //Group Placeholder Associations
        String placeholderRelName = Relationship_Group_Placeholder_Assoc__c.Map_Member_Placeholder__c.getDescribe()
            .getName();
        String groupRelName = Relationship_Group_Placeholder_Assoc__c.Relationship_Group__c.getDescribe().getName();
        Set<String> groupPlaceholderParentFields = new Set<String>{ placeholderRelName, groupRelName };
        List<Relationship_Group_Placeholder_Assoc__c> groupPlaceholderRelationships = (List<Relationship_Group_Placeholder_Assoc__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            Relationship_Group_Placeholder_Assoc__c.getSObjectType(),
            originalMixedObjectIdSet,
            groupPlaceholderParentFields
        );

        for (Map<Id, SObject> clonedMixedByOriginalId : dedupedClonedMixedObjectsByOriginalId) {
            Map<Id, SObject> clonedPlaceholderRelationshipsMap = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                groupPlaceholderRelationships,
                clonedMixedByOriginalId,
                groupPlaceholderParentFields
            );
            clonedObjectsNotInserted.addAll(clonedPlaceholderRelationshipsMap.values());
        }

        //Group Contact Associations
        String groupContactRelName = Relationship_Group_Contact_Association__c.Relationship_Group__c.getDescribe()
            .getName();
        Set<String> groupContactParentFields = new Set<String>{ groupContactRelName };
        List<Relationship_Group_Contact_Association__c> groupContactRelationships = (List<Relationship_Group_Contact_Association__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            Relationship_Group_Contact_Association__c.getSObjectType(),
            originalGroupIdSet,
            groupContactParentFields
        );

        for (Map<Id, Relationship_Group__c> clonedGroupsByOriginalId : dedupedClonedGroupsByOriginalId) {
            Map<Id, SObject> clonedContactRelationshipsMap = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                groupContactRelationships,
                clonedGroupsByOriginalId,
                groupContactParentFields
            );
            clonedObjectsNotInserted.addAll(clonedContactRelationshipsMap.values());
        }

        //Group Lead Associations
        String groupLeadRelName = Relationship_Group_Lead_Association__c.Relationship_Group__c.getDescribe().getName();
        Set<String> groupLeadParentFields = new Set<String>{ groupLeadRelName };
        List<Relationship_Group_Lead_Association__c> groupLeadRelationships = (List<Relationship_Group_Lead_Association__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            Relationship_Group_Lead_Association__c.getSObjectType(),
            originalGroupIdSet,
            groupLeadParentFields
        );

        for (Map<Id, Relationship_Group__c> clonedGroupsByOriginalId : dedupedClonedGroupsByOriginalId) {
            Map<Id, SObject> clonedLeadRelationshipsMap = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                groupLeadRelationships,
                clonedGroupsByOriginalId,
                groupLeadParentFields
            );
            clonedObjectsNotInserted.addAll(clonedLeadRelationshipsMap.values());
        }

        //Group User Associations
        String groupUserRelName = Relationship_Group_User_Association__c.Relationship_Group__c.getDescribe().getName();
        Set<String> groupUserParentFields = new Set<String>{ groupUserRelName };
        List<Relationship_Group_User_Association__c> groupUserRelationships = (List<Relationship_Group_User_Association__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            Relationship_Group_User_Association__c.getSObjectType(),
            originalGroupIdSet,
            groupUserParentFields
        );

        for (Map<Id, Relationship_Group__c> clonedGroupsByOriginalId : dedupedClonedGroupsByOriginalId) {
            Map<Id, SObject> clonedUserRelationshipsMap = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                groupUserRelationships,
                clonedGroupsByOriginalId,
                groupUserParentFields
            );
            clonedObjectsNotInserted.addAll(clonedUserRelationshipsMap.values());
        }

        //Anchors
        String anchorMapRelationshipName = RM_Anchor__c.Relationship_Map__c.getDescribe().getName();
        Set<String> anchorMapParentFields = new Set<String>{ anchorMapRelationshipName };
        List<RM_Anchor__c> anchorRelationships = (List<RM_Anchor__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            RM_Anchor__c.getSObjectType(),
            mapIdset,
            anchorMapParentFields
        );

        String anchorFromRelationshipName = RM_Anchor__c.From__c.getDescribe().getName();
        String anchorToRelationshipName = RM_Anchor__c.To__c.getDescribe().getName();
        Set<String> anchorRelationshipFields = new Set<String>{
            anchorMapRelationshipName,
            anchorFromRelationshipName,
            anchorToRelationshipName
        };
        for (Map<Id, SObject> clonedMixedByOriginalId : dedupedClonedMixedObjectsByOriginalId) {
            Map<Id, SObject> clonedAnchorsMap = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                anchorRelationships,
                clonedMixedByOriginalId,
                anchorRelationshipFields
            );
            clonedObjectsNotInserted.addAll(clonedAnchorsMap.values());
        }

        //Coordinates
        String coordMapRelationshipName = RM_Node_Coordinate__c.Relationship_Map__c.getDescribe().getName();
        Set<String> coordMapParentFields = new Set<String>{ coordMapRelationshipName };
        List<RM_Node_Coordinate__c> coordRelationships = (List<RM_Node_Coordinate__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            RM_Node_Coordinate__c.getSObjectType(),
            mapIdset,
            coordMapParentFields
        );

        String coordKeyRelationshipName = RM_Node_Coordinate__c.Key__c.getDescribe().getName();
        Set<String> coordRelationshipFields = new Set<String>{ coordMapRelationshipName, coordKeyRelationshipName };
        for (Map<Id, SObject> clonedMixedByOriginalId : dedupedClonedMixedObjectsByOriginalId) {
            Map<Id, SObject> clonedAnchorsMap = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                coordRelationships,
                clonedMixedByOriginalId,
                coordRelationshipFields
            );
            clonedObjectsNotInserted.addAll(clonedAnchorsMap.values());
        }

        //Node Badge Association
        String badgeAssocMapRelationshipName = RM_Svg_Node_Association__c.Relationship_Map__c.getDescribe().getName();
        Set<String> badgeAssocMapParentFields = new Set<String>{ badgeAssocMapRelationshipName };
        List<RM_Svg_Node_Association__c> badgeAssocRelationships = (List<RM_Svg_Node_Association__c>) CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            RM_Svg_Node_Association__c.getSObjectType(),
            mapIdSet,
            badgeAssocMapParentFields
        );

        String badgeAssocKeyRelationshipName = RM_Svg_Node_Association__c.Key__c.getDescribe().getName();
        Set<String> badgeAssocRelationshipFields = new Set<String>{
            badgeAssocMapRelationshipName,
            badgeAssocKeyRelationshipName
        };
        for (Map<Id, SObject> clonedMixedByOriginalId : dedupedClonedMixedObjectsByOriginalId) {
            Map<Id, SObject> clonedBadgeAssocMap = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                badgeAssocRelationships,
                clonedMixedByOriginalId,
                badgeAssocRelationshipFields
            );
            clonedObjectsNotInserted.addAll(clonedBadgeAssocMap.values());
        }

        this.updateClonedGroupGroupRelationships(relatedGroups, dedupedClonedGroupsByOriginalId);

        return clonedObjectsNotInserted;
    }

    private Void updateClonedGroupGroupRelationships(
        List<Relationship_Group__c> relatedGroups,
        List<Map<Id, Relationship_Group__c>> dedupedClonedGroupsByOriginalId
    ) {
        //Update Groups With Parent Group Relationships
        List<Relationship_Group__c> updatedInnerGroups = new List<Relationship_Group__c>();
        String parentGroupRelationshipName = Relationship_Group__c.Parent_Relationship_Group__c.getDescribe().getName();
        for (Map<Id, Relationship_Group__c> clonedGroupsByOriginalId : dedupedClonedGroupsByOriginalId) {
            List<Relationship_Group__c> clonedInnerGroupsByOriginalId = CloneSharedService.updateRelatedGroupsWithParentGroups(
                relatedGroups,
                clonedGroupsByOriginalId,
                parentGroupRelationshipName
            );
            updatedInnerGroups.addAll(clonedInnerGroupsByOriginalId);
        }
        if (updatedInnerGroups.size() > 0) {
            fflib_ISObjectUnitOfWork updatedGroupUoW = Application.UnitOfWork.newInstance();
            updatedGroupUoW.registerDirty(updatedInnerGroups);
            new SystemContext().commitWork(updatedGroupUoW);
        }
    }

    private Map<String, Set<Id>> mapIdsByRelationshipForWrappers(List<RelationshipMapCloneWrapper> wrappers) {
        Map<String, Set<Id>> mapIdsByRelationship = new Map<String, Set<Id>>();
        for (RelationshipMapCloneWrapper wrapper : wrappers) {
            if (wrapper.relationships == null) {
                wrapper.relationships = new List<String>();
            }
            for (String relationshipName : wrapper.relationships) {
                Set<Id> idSet = mapIdsByRelationship.get(relationshipName);
                if (idSet == null) {
                    idSet = new Set<Id>();
                }
                idSet.add(wrapper.mapId);
                mapIdsByRelationship.put(relationshipName, idSet);
            }
        }
        return mapIdsByRelationship;
    }

    private List<Map<Id, RelationshipMapCloneWrapper>> dedupedWrapperByMapIdList(
        List<RelationshipMapCloneWrapper> wrappers
    ) {
        List<Map<Id, RelationshipMapCloneWrapper>> wrapperByMapIdNoDupeLists = new List<Map<Id, RelationshipMapCloneWrapper>>();
        for (RelationshipMapCloneWrapper wrapper : wrappers) {
            Map<Id, RelationshipMapCloneWrapper> mapWithoutMap = null;
            for (Integer i = 0; i < wrapperByMapIdNoDupeLists.size(); i++) {
                Map<Id, RelationshipMapCloneWrapper> currentMap = wrapperByMapIdNoDupeLists[i];
                if (currentMap.get(wrapper.mapId) == null) {
                    mapWithoutMap = currentMap;
                    break;
                }
            }
            if (mapWithoutMap == null) {
                mapWithoutMap = new Map<Id, RelationshipMapCloneWrapper>();
                wrapperByMapIdNoDupeLists.add(mapWithoutMap);
            }
            mapWithoutMap.put(wrapper.mapId, wrapper);
        }
        return wrapperByMapIdNoDupeLists;
    }

    private Map<Id, Relationship_Map__c> clonedMapMapForWrapperByRelationshipMap(
        Map<Id, RelationshipMapCloneWrapper> wrapperList,
        String relationshipName
    ) {
        Map<Id, Relationship_Map__c> clonedMaps = new Map<Id, Relationship_Map__c>();
        for (RelationshipMapCloneWrapper wrapper : wrapperList.values()) {
            if (wrapper.relationships != null && wrapper.relationships.contains(relationshipName)) {
                clonedMaps.put(wrapper.mapId, wrapper.clonedMap);
            }
        }
        return clonedMaps;
    }

    private without sharing class SystemContext {
        private void commitWork(fflib_ISObjectUnitOfWork uow) {
            uow.commitWork();
        }
    }
}