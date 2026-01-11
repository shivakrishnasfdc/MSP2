public with sharing class MapMemberPlaceholderServiceImpl {
    public GraphNodeData createNewPlaceholder(GraphNodeData gnd, Id objectId) {
        String name = UtilityForString.trimByMaxLength(
            gnd.name,
            SObjectType.Map_Member_Placeholder__c.Fields.Name.Length
        );
        String label = UtilityForString.trimByMaxLength(
            gnd.name,
            SObjectType.Map_Member_Placeholder__c.Fields.Label__c.Length
        );
        String description = UtilityForString.trimByMaxLength(
            gnd.title,
            SObjectType.Map_Member_Placeholder__c.Fields.Description__c.Length
        );

        Id relationshipMapId = null;
        Id accountPlanId = null;
        if (objectId.getSobjectType() == Relationship_Map__c.getSObjectType()) {
            relationshipMapId = objectId;
        } else if (objectId.getSobjectType() == Account_Plan__c.getSObjectType()) {
            accountPlanId = objectId;
        }

        Map_Member_Placeholder__c mmp = new Map_Member_Placeholder__c(
            Name = name,
            Label__c = label,
            Description__c = description,
            TempId__c = gnd.tempId,
            Account_Plan__c = accountPlanId,
            Relationship_Map__c = relationshipMapId
        );

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerNew(mmp);
        uow.commitWork();

        gnd.key = mmp.Id;

        return gnd;
    }

    public void deletePlaceholders(List<String> placeholderIds) {
        List<Map_Member_Placeholder__c> placeholders = new List<Map_Member_Placeholder__c>();
        for (String placeholderId : placeholderIds) {
            placeholders.add(new Map_Member_Placeholder__c(Id = placeholderId));
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(placeholders);
        uow.commitWork();
    }

    public void updatePlaceholderDescription(GraphNodeData gnd, String newDescription) {
        List<Map_Member_Placeholder__c> placeholders = MapMemberPlaceholderSelector.newInstance()
            .selectByIdORTempKey(new Set<String>{ gnd.key });

        String description = UtilityForString.trimByMaxLength(
            newDescription,
            SObjectType.Map_Member_Placeholder__c.Fields.Description__c.Length
        );

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for (Map_Member_Placeholder__c placeholder : placeholders) {
            placeholder.Description__c = description;
            // Register One at a time instead of full list after loop so we can test it better
            uow.registerDirty(placeholder);
        }
        uow.commitWork();
    }

    public void updatePlaceholderNameAndLabel(GraphNodeData gnd, String newLabel) {
        List<Map_Member_Placeholder__c> placeholders = MapMemberPlaceholderSelector.newInstance()
            .selectByIdORTempKey(new Set<String>{ gnd.key });

        String name = UtilityForString.trimByMaxLength(
            newLabel,
            SObjectType.Map_Member_Placeholder__c.Fields.Name.Length
        );

        String label = UtilityForString.trimByMaxLength(
            newLabel,
            SObjectType.Map_Member_Placeholder__c.Fields.Label__c.Length
        );

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Map_Member_Placeholder__c placeholder : placeholders) {
            placeholder.Name = name;
            placeholder.Label__c = label;
            // Register One at a time instead of full list after loop so we can test it better
            uow.registerDirty(placeholder);
        }
        uow.commitWork();
    }

    public void updatePlaceholderReportToLinks(
        List<GraphLinkData> gldList,
        Id mapOrAccountPlanId,
        RM_Chart_Setting__c setting
    ) {
        Set<String> toKeys = new Set<String>();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for (GraphLinkData gld : gldList) {
            if (String.isBlank(gld.toKey)) {
                continue;
            }

            toKeys.add(gld.toKey);

            if (String.isBlank(gld.fromKey)) {
                continue;
            }

            // Check Object Type
            Id toObjectId = Id.valueOf(gld.toKey);
            Id fromObjectId = Id.valueOf(gld.fromKey);

            // Only process placeholderlinks not contact reports to
            // Unless org chart is using local reports to links
            if (
                fromObjectId.getSobjectType() == Contact.sObjectType &&
                toObjectId.getSobjectType() == Contact.sObjectType &&
                setting.Is_Reports_To_Global_Scope__c
            ) {
                continue;
            }

            Map_Member_Placeholder_Relationship__c newRel = new Map_Member_Placeholder_Relationship__c(
                To__c = gld.toKey,
                From__c = gld.fromKey,
                Is_Hierarchy__c = true
            );
            newRel.put(String.valueOf(mapOrAccountPlanId.getSobjectType()), mapOrAccountPlanId);

            uow.registerNew(newRel);
        }

        // Remove old relationships (that are report to, aka not type Custom)
        List<Map_Member_Placeholder_Relationship__c> oldRelationships = MapMemberPlaceholderRelationshipSelector.newInstance()
            .selectByTo(toKeys, new Set<Id>{ mapOrAccountPlanId });

        for (Map_Member_Placeholder_Relationship__c oldRel : oldRelationships) {
            if (oldRel.Type__c == null || oldRel.Type__c == '') {
                uow.registerDeleted(oldRel);
            }
        }

        uow.commitWork();
    }

    public GraphData getPlaceholdersAndLinksByObjectId(Id objectId) {
        List<Map_Member_Placeholder__c> placeholders = MapMemberPlaceholderSelector.newInstance()
            .selectByObjectId(new Set<Id>{ objectId });

        return generateGraphDataForMapMemberPlaceholders(placeholders, objectId);
    }

    private GraphData generateGraphDataForMapMemberPlaceholders(
        List<Map_Member_Placeholder__c> placeholders,
        ID mapOrAccountPlanId
    ) {
        Id mapId = mapOrAccountPlanId;
        Boolean hasAccountPlanSetting = RelationshipMapService.hasAccountPlanSetting(mapId);

        Set<String> mapMemberPlaceholderIds = new Set<String>();
        List<GraphNodeData> gndList = new List<GraphNodeData>();

        for (Map_Member_Placeholder__c placeholder : placeholders) {
            mapMemberPlaceholderIds.add(placeholder.Id);
        }

        Map<Id, Id> placeholderGroupMap = new Map<Id, Id>();
        List<Relationship_Group_Placeholder_Assoc__c> groupPlaceholderAssoc = RelationshipGroupPlaceholderSelector.newInstance()
            .selectWithGroupsByPlaceholderIds(mapMemberPlaceholderIds);

        Map<Id, Relationship_Group__c> relGroups = new Map<Id, Relationship_Group__c>();

        if (groupPlaceholderAssoc != null) {
            for (Relationship_Group_Placeholder_Assoc__c rel : groupPlaceholderAssoc) {
                placeholderGroupMap.put(rel.Map_Member_Placeholder__c, rel.Relationship_Group__c);
                relGroups.put(rel.Relationship_Group__r.Id, rel.Relationship_Group__r);
            }
        }

        for (Map_Member_Placeholder__c placeholder : placeholders) {
            GraphNodeData gnd = new GraphNodeData(
                placeholder.Id, // key
                null, // secondaryKey, key stakeholder id
                'placeholder', // secondaryKey
                placeholder.Label__c, // name
                placeholder.Description__c, // title
                null, // profileImageUrlOrData
                null, // influence
                null, // influenceImageUrl
                null, // support
                null, // supportColor
                null, // supportImageUrl
                null, // accountName
                null
            ); // additionalFields
            gnd.groupKey = placeholderGroupMap.get(placeholder.Id);
            gndList.add(gnd);
        }

        // Get Placeholder Relationship Links
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapOrAccountPlanId);

        List<Map_Member_Placeholder_Relationship__c> rels;

        // Get Relationship Links for Placeholder & Their Groups
        if (setting.Is_Relationship_Line_Global_Scope__c) {
            rels = MapMemberPlaceholderRelationshipSelector.newInstance()
                .selectGlobalRelationshipsById(mapMemberPlaceholderIds, mapOrAccountPlanId, hasAccountPlanSetting);
        } else {
            rels = MapMemberPlaceholderRelationshipSelector.newInstance()
                .selectLocalRelationshipsById(mapMemberPlaceholderIds, mapOrAccountPlanId, hasAccountPlanSetting);
        }

        // Retrieve Hierarchy Links
        List<Map_Member_Placeholder_Relationship__c> hierarchyRels = MapMemberPlaceholderRelationshipSelector.newInstance()
            .selectHierarchyLinksByPlaceholderId(new Set<Id>{ mapOrAccountPlanId }, mapMemberPlaceholderIds);
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
                    rel.Type__c,
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
                        rel.Type__c,
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

    public GraphData getAndInjectCustomLinks(GraphData gd, Id mapId) {
        Boolean hasAccountPlanSetting = RelationshipMapService.hasAccountPlanSetting(mapId);

        Set<String> nodeIds = new Set<String>();
        for (GraphNodeData gnd : gd.nodeDataArray) {
            if (gnd.category != 'contact' && gnd.category != 'keystakeholder') {
                nodeIds.add(gnd.key);
            }
        }

        // Get Custom RM Settings
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapId);

        List<Map_Member_Placeholder_Relationship__c> rels;

        // Get Relationship Links for non Contact/KS
        if (setting.Is_Relationship_Line_Global_Scope__c) {
            rels = MapMemberPlaceholderRelationshipSelector.newInstance()
                .selectGlobalRelationshipsById(nodeIds, mapId, hasAccountPlanSetting);
        } else {
            rels = MapMemberPlaceholderRelationshipSelector.newInstance()
                .selectLocalRelationshipsById(nodeIds, mapId, hasAccountPlanSetting);
        }

        List<GraphLinkData> gldList = new List<GraphLinkData>();
        for (Map_Member_Placeholder_Relationship__c rel : rels) {
            gldList.add(
                new GraphLinkData(
                    rel.Id,
                    null,
                    rel.From__c,
                    true,
                    rel.To__c,
                    rel.Type__c,
                    HierarchyHelperService.getLabelForRelationship(rel)
                )
            );
        }

        gd.linkDataArray.addAll(gldList);

        // Deduped Linked Data, make sure they are all unique
        List<GraphLinkData> cleanLinkData = new List<GraphLinkData>();
        Set<String> cleanLinkDataIds = new Set<String>();
        for (GraphLinkData gld : gd.linkDataArray) {
            if (!cleanLinkDataIds.contains(gld.id)) {
                cleanLinkData.add(gld);
            }
            cleanLinkDataIds.add(gld.id);
        }

        gd.linkDataArray = cleanLinkData;

        return gd;
    }

    public void updateRelationshipForLeads(Set<String> leadIds, Map<Id, Id> leadContactMap) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Map_Member_Placeholder_Relationship__c> mmprs = MapMemberPlaceholderRelationshipSelector.newInstance()
            .selectByToOrFrom(leadIds);
        for (Map_Member_Placeholder_Relationship__c mmpr : mmprs) {
            Id contactId1 = leadContactMap.get(mmpr.To__c);
            Id contactId2 = leadContactMap.get(mmpr.From__c);

            Boolean fromIsContact = false;
            Boolean toIsContact = false;

            if (contactId1 != null) {
                mmpr.To__c = contactId1;
                toIsContact = true;
            } else if (Id.valueOf(mmpr.To__c).getSObjectType() == Contact.getSObjectType()) {
                toIsContact = true;
            }

            if (contactId2 != null) {
                mmpr.From__c = contactId2;
                fromIsContact = true;
            } else if (Id.valueOf(mmpr.From__c).getSObjectType() == Contact.getSObjectType()) {
                fromIsContact = true;
            }

            if (contactId1 != null || contactId2 != null) {
                if (fromIsContact && toIsContact) {
                    uow.registerNew(
                        new Contact_Relationship__c(
                            From_Contact__c = mmpr.From__c,
                            To_Contact__c = mmpr.To__c,
                            Label__c = mmpr.Label__c,
                            Contact_Relationship_Type__c = mmpr.Contact_Relationship_Type__c,
                            Account_Plan__c = mmpr.Account_Plan__c,
                            pqcrush__Relationship_Map__c = mmpr.Relationship_Map__c
                        )
                    );
                    uow.registerDeleted(mmpr);
                } else {
                    uow.registerDirty(mmpr);
                }
            }
        }

        uow.commitWork();
    }
}