public with sharing class RMSvgServiceImpl {
    // This method gets the badges for each node and adds the data to the graph node data
    public GraphData injectBadges(Id mapId, GraphData gd, RM_Chart_Setting__C setting) {
        List<Relationship_Map__c> maps = RelationshipMapSelector.newInstance().selectByIds(new Set<Id>{ mapId });
        Boolean hasAccountPlanSetting = false;
        Id accountPlanId = null;
        if (maps != null && maps.size() > 0) {
            Relationship_Map__c rmMap = maps[0];
            if (rmMap?.Type_Setting__c == 'pqcrush__Account_Plan__c') {
                hasAccountPlanSetting = true;
            }

            accountPlanId = rmMap.pq_AccountPlanId__c;
        }

        List<RM_Svg__c> svgs = RMSvgSelector.newInstance()
            .selectByRelationshipMaps(new Set<Id>{ mapId }, hasAccountPlanSetting, accountPlanId);

        // Add badges that are data binds
        RMSvgHelperService.injectBoundBadges(svgs, gd.nodeDataArray);

        // Map Badges
        Map<String, GraphNodeData> mapNodes = new Map<String, GraphNodeData>();
        for (GraphNodeData node : gd.nodeDataArray) {
            mapNodes.put(node.key, node);
        }

        List<RM_Svg_Node_Association__c> nodeSvgs;
        if (setting.Is_Badge_Global_Scope__c) {
            nodeSvgs = RMSvgNodeAssociationSelector.newInstance().selectByKeysGlobalForSvgs(svgs, mapNodes.keySet());
        } else {
            nodeSvgs = RMSvgNodeAssociationSelector.newInstance()
                .selectByKeysLocalForSvgs(mapId, svgs, mapNodes.keySet());
        }

        for (RM_Svg_Node_Association__c nodeSvg : nodeSvgs) {
            GraphNodeData nData = mapNodes.get(nodeSvg.Key__c);
            if (nData == null) {
                continue;
            }
            if (nData.badges == null) {
                nData.badges = new List<Badge>{ new Badge(nodeSvg.RM_Svg__c, '', '', false) };
            } else {
                if (!containsBadge(nData.badges, nodeSvg.RM_Svg__c)) {
                    nData.badges.add(new Badge(nodeSvg.RM_Svg__c, '', '', false));
                }
            }

            mapNodes.put(nodeSvg.Key__c, nData);
        }

        gd.nodeDataArray = mapNodes.values();

        return gd;
    }

    private Boolean containsBadge(List<Badge> badgeList, String badgeId) {
        for (Badge b : badgeList) {
            if (b.Id == badgeId) {
                return true;
            }
        }
        return false;
    }

    public void associateBadge(Id mapOrAccountPlanId, String badgeId, List<String> nodeIds) {
        if (mapOrAccountPlanId == null) {
            return;
        }

        Set<String> idSet = new Set<String>(nodeIds);

        RM_Chart_Setting__C setting = RMChartSettingService.getRelationshipMapSettingForObject(mapOrAccountPlanId);

        // Look up current associations
        List<RM_Svg_Node_Association__c> nodeSvgs;
        if (setting.Is_Badge_Global_Scope__c) {
            nodeSvgs = RMSvgNodeAssociationSelector.newInstance().selectByKeysGlobal(idSet);
        } else {
            nodeSvgs = RMSvgNodeAssociationSelector.newInstance().selectByKeysLocal(mapOrAccountPlanId, idSet);
        }

        Set<String> keyBadgeSet = new Set<String>();
        for (RM_Svg_Node_Association__c nodeAssoc : nodeSvgs) {
            keyBadgeSet.add(nodeAssoc.Key__c + nodeAssoc.RM_Svg__c);
        }

        Id relationshipMapId = null;
        Id accountPlanId = null;
        if (mapOrAccountPlanId.getSobjectType() == Relationship_Map__c.getSObjectType()) {
            relationshipMapId = mapOrAccountPlanId;
        } else if (mapOrAccountPlanId.getSobjectType() == Account_Plan__c.getSObjectType()) {
            accountPlanId = mapOrAccountPlanId;
        }

        // Insert new associations
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (String nodeId : nodeIds) {
            if (keyBadgeSet.contains(nodeId + badgeId)) {
                // Already exists in database
                continue;
            }
            RM_Svg_Node_Association__c nodeAssoc = new RM_Svg_Node_Association__c(Key__c = nodeId, RM_Svg__c = badgeId);
            if (!setting.Is_Badge_Global_Scope__c) {
                nodeAssoc.Relationship_Map__c = relationshipMapId;
                nodeAssoc.Account_Plan__c = accountPlanId;
            }
            uow.registerNew(nodeAssoc);
        }
        uow.commitWork();
    }

    public void removeBadge(Id mapOrAccountPlanId, List<String> nodeIds) {
        if (mapOrAccountPlanId == null) {
            return;
        }

        Set<String> idSet = new Set<String>(nodeIds);

        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapOrAccountPlanId);

        // Remove old associations
        fflib_ISObjectUnitOfWork uow1 = Application.UnitOfWork.newInstance();
        List<RM_Svg_Node_Association__c> nodeSvgs;
        if (setting.Is_Badge_Global_Scope__c) {
            nodeSvgs = RMSvgNodeAssociationSelector.newInstance().selectByKeysGlobalWithAutomation(idSet, false);
        } else {
            nodeSvgs = RMSvgNodeAssociationSelector.newInstance()
                .selectByKeysLocalWithAutomation(mapOrAccountPlanId, idSet, false);
        }
        uow1.registerDeleted(nodeSvgs);
        uow1.commitWork();
    }
}