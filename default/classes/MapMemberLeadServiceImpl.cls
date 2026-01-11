public with sharing class MapMemberLeadServiceImpl {
    public GraphData createLeadsForMap(
        GraphData graphData,
        Id relationshipMapId,
        Map<String, String> mapInfluence,
        Map<String, String> mapSupport
    ) {
        if (relationshipMapId == null || graphData == null || graphData.nodeDataArray == null) {
            return new GraphData();
        }

        // ----------------------------------------
        // Create the new records
        Set<Id> leadIdSet = new Set<Id>();
        for (GraphNodeData node : graphData.nodeDataArray) {
            leadIdSet.add(node.key);
        }

        List<Lead> leads = LeadSelector.newInstance().selectById(leadIdSet);

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Map_Member_Lead__c> mapMemberLeads = new List<Map_Member_Lead__c>();
        for (Id leadId : leadIdSet) {
            Map_Member_Lead__c mapMemberLead = new Map_Member_Lead__c(
                Relationship_Map__c = relationshipMapId,
                Lead__c = leadId
            );
            mapMemberLeads.add(mapMemberLead);
            uow.registerNew(mapMemberLead);
        }
        uow.commitWork();

        // ----------------------------------------
        // Store the Node Location data as provided
        RMNodeCoordinateService.updateNodeCoordinates(relationshipMapId, graphData.nodeDataArray);

        Map<Id, IRelationshipMapLeadObject2> mapOfLeadAndMapmembers = new Map<Id, IRelationshipMapLeadObject2>();
        List<MapMemberLeadWrapper> wrapperList = new List<MapMemberLeadWrapper>();
        for (Map_Member_Lead__c mapMemberLead : mapMemberLeads) {
            MapMemberLeadWrapper wrapper = new MapMemberLeadWrapper(mapMemberLead);
            wrapperList.add(wrapper);
            mapOfLeadAndMapmembers.put(mapMemberLead.Lead__c, wrapper);
        }

        List<GraphNodeData> nodes = GraphDataLeadService.createGraphDataNodes(
            leads,
            mapOfLeadAndMapmembers,
            null,
            relationshipMapId
        );

        return new GraphData(nodes, new List<GraphLinkData>());
    }

    public GraphData createLeadsForAccountPlan(
        GraphData graphData,
        Id accountPlanId,
        Map<String, String> mapInfluence,
        Map<String, String> mapSupport
    ) {
        if (accountPlanId == null || graphData == null || graphData.nodeDataArray == null) {
            return new GraphData();
        }

        // ----------------------------------------
        // Create the new records
        Set<Id> leadIdSet = new Set<Id>();
        for (GraphNodeData node : graphData.nodeDataArray) {
            leadIdSet.add(node.key);
        }

        List<Lead> leads = LeadSelector.newInstance().selectById(leadIdSet);

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Key_Stakeholder_Lead__c> ksLeads = new List<Key_Stakeholder_Lead__c>();
        for (Id leadId : leadIdSet) {
            Key_Stakeholder_Lead__c ksLead = new Key_Stakeholder_Lead__c(
                Account_Plan__c = accountPlanId,
                Lead__c = leadId
            );
            ksLeads.add(ksLead);
            uow.registerNew(ksLead);
        }
        uow.commitWork();

        // ----------------------------------------
        // Store the Node Location data as provided
        RMNodeCoordinateService.updateNodeCoordinates(accountPlanId, graphData.nodeDataArray);

        Map<Id, IRelationshipMapLeadObject2> mapOfLeadAndKeyStakeholderLead = new Map<Id, IRelationshipMapLeadObject2>();
        List<StakeholderLeadWrapper> wrapperList = new List<StakeholderLeadWrapper>();
        for (Key_Stakeholder_Lead__c ksLead : ksLeads) {
            StakeholderLeadWrapper wrapper = new StakeholderLeadWrapper(ksLead);
            wrapperList.add(wrapper);
            mapOfLeadAndKeyStakeholderLead.put(ksLead.Lead__c, wrapper);
        }

        List<GraphNodeData> nodes = GraphDataLeadService.createGraphDataNodes(
            leads,
            mapOfLeadAndKeyStakeholderLead,
            null,
            accountPlanId
        );

        return new GraphData(nodes, new List<GraphLinkData>());
    }

    public void deleteMapMemberLeads(List<String> idList) {
        Set<Id> mmLeadIds = new Set<Id>();
        for (String leadId : idList) {
            mmLeadIds.add(leadId);
        }

        List<Map_Member_Lead__c> mapMemberLeads = MapMemberLeadSelector.newInstance().selectByLeadId(mmLeadIds);

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(mapMemberLeads);
        uow.commitWork();
    }

    public void deleteKeyStakeholderLeads(List<String> idList) {
        Set<Id> ksLeadIds = new Set<Id>();
        for (String leadId : idList) {
            ksLeadIds.add(leadId);
        }

        List<Key_Stakeholder_Lead__c> keyStakeholderLeads = KeyStakeholderLeadSelector.newInstance()
            .selectByLeadId(ksLeadIds);

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(keyStakeholderLeads);
        uow.commitWork();
    }

    public GraphData getAndInjectMapMemberLeadNodes(
        GraphData graphData,
        Id relationshipMapId,
        Map<String, String> mapInfluence,
        Map<String, String> mapSupport
    ) {
        if (!hasMapMemberLeadAccess()) {
            return graphData;
        }

        if (graphData == null) {
            return null;
        }

        // Get list of all Map Member Leads registered with the Map
        List<Map_Member_Lead__c> mapMemberLeads = MapMemberLeadSelector.newInstance()
            .selectByRelationshipMaps(new Set<Id>{ relationshipMapId });

        Set<Id> leadIds = new Set<Id>();
        for (Map_Member_Lead__c mml : mapMemberLeads) {
            leadIds.add(mml.Lead__c);
        }

        List<Lead> leads = LeadSelector.newInstance().selectById(leadIds);

        Map<Id, IRelationshipMapLeadObject2> mapLeadMember = new Map<Id, IRelationshipMapLeadObject2>();
        List<MapMemberLeadWrapper> wrapperList = new List<MapMemberLeadWrapper>();
        for (Map_Member_Lead__c mmLead : mapMemberLeads) {
            MapMemberLeadWrapper wrapper = new MapMemberLeadWrapper(mmLead);
            wrapperList.add(wrapper);
            mapLeadMember.put(mmLead.Lead__c, wrapper);
        }

        List<Relationship_Group_Lead_Association__c> groupRels = RelationshipGroupLeadSelector.newInstance()
            .selectWithGroupsByLeadIds(leadIds);

        List<GraphNodeData> nodeDataArray = GraphDataLeadService.createGraphDataNodes(
            leads,
            mapLeadMember,
            groupRels,
            relationshipMapId
        );

        // Inject Map Member Leads if they are unique
        if (nodeDataArray != null) {
            Set<Id> nodeKeys = new Set<Id>();
            for (GraphNodeData gnd : graphData.nodeDataArray) {
                nodeKeys.add(gnd.key);
            }
            for (GraphNodeData gnd : nodeDataArray) {
                if (!nodeKeys.contains(gnd.key)) {
                    graphData.nodeDataArray.add(gnd);
                }
            }
        }

        return graphData;
    }

    public GraphData getAndInjectKeyStakeholderLeadNodes(
        GraphData graphData,
        Id accountPlanId,
        Map<String, String> mapInfluence,
        Map<String, String> mapSupport
    ) {
        if (!hasKeyStakeholderLeadAccess()) {
            return graphData;
        }

        if (graphData == null) {
            return null;
        }

        // Get list of all Map Member Users registered with the Map
        List<Key_Stakeholder_Lead__c> keyStakeholderLeads = KeyStakeholderLeadSelector.newInstance()
            .selectByAccountPlans(new Set<Id>{ accountPlanId });

        Set<Id> leadIds = new Set<Id>();
        for (Key_Stakeholder_Lead__c ksl : keyStakeholderLeads) {
            leadIds.add(ksl.Lead__c);
        }

        List<Lead> leads = LeadSelector.newInstance().selectById(leadIds);

        Map<Id, IRelationshipMapLeadObject2> mapLeadMember = new Map<Id, IRelationshipMapLeadObject2>();
        List<StakeholderLeadWrapper> wrapperList = new List<StakeholderLeadWrapper>();
        for (Key_Stakeholder_Lead__c ksLead : keyStakeholderLeads) {
            StakeholderLeadWrapper wrapper = new StakeholderLeadWrapper(ksLead);
            wrapperList.add(wrapper);
            mapLeadMember.put(ksLead.Lead__c, wrapper);
        }

        List<Relationship_Group_Lead_Association__c> groupRels = RelationshipGroupLeadSelector.newInstance()
            .selectWithGroupsByLeadIds(leadIds);

        List<GraphNodeData> nodeDataArray = GraphDataLeadService.createGraphDataNodes(
            leads,
            mapLeadMember,
            groupRels,
            accountPlanId
        );

        // Inject Map Member Leads if they are unique
        if (nodeDataArray != null) {
            Set<Id> nodeKeys = new Set<Id>();
            for (GraphNodeData gnd : graphData.nodeDataArray) {
                nodeKeys.add(gnd.key);
            }
            for (GraphNodeData gnd : nodeDataArray) {
                if (!nodeKeys.contains(gnd.key)) {
                    graphData.nodeDataArray.add(gnd);
                }
            }
        }

        return graphData;
    }

    public void convertLeadsToKeyStakeholders(Id accountPlanId) {
        if (!hasKeyStakeholderLeadAccess()) {
            return;
        }

        // Find converted leads
        List<Key_Stakeholder_Lead__c> ksLeads = KeyStakeholderLeadSelector.newInstance()
            .selectConvertedLeadsByAccountPlans(new Set<Id>{ accountPlanId });
        Map<Id, Id> leadContactMap = new Map<Id, Id>();
        Set<Id> contactIdSet = new Set<Id>();
        Set<String> leadIds = new Set<String>();
        for (Key_Stakeholder_Lead__c ksl : ksLeads) {
            leadContactMap.put(ksl.Lead__c, ksl.Lead__r.ConvertedContactId);
            contactIdSet.add(ksl.Lead__r.ConvertedContactId);
            leadIds.add(ksl.Lead__c);
        }

        // Create Key stakeholders for contacts
        KeyStakeholderService.addContactAsKeyStakeholder(accountPlanId, contactIdSet);

        // Find all groups for leads and update with contacts
        RelationshipGroupService.convertLeadsToContactGroups(leadIds, leadContactMap);

        // Find all relationships for leads and update to contacts
        MapMemberPlaceholderService.updateRelationshipForLeads(leadIds, leadContactMap);

        // Find all node coordinates
        RMNodeCoordinateService.udpateCoordinatesForLeads(leadIds, leadContactMap);

        // Remove Key Stakeholder Leads
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(ksLeads);
        uow.commitWork();
    }

    public void convertLeadsToMapMembers(Id relationshipMapId) {
        if (!hasMapMemberLeadAccess()) {
            return;
        }

        // Find converted leads
        List<Map_Member_Lead__c> mmLeads = MapMemberLeadSelector.newInstance()
            .selectConvertedLeadsByRelationshipMaps(new Set<Id>{ relationshipMapId });
        Map<Id, Id> leadContactMap = new Map<Id, Id>();
        Set<Id> contactIdSet = new Set<Id>();
        Set<String> leadIds = new Set<String>();
        for (Map_Member_Lead__c mml : mmLeads) {
            leadContactMap.put(mml.Lead__c, mml.Lead__r.ConvertedContactId);
            contactIdSet.add(mml.Lead__r.ConvertedContactId);
            leadIds.add(mml.Lead__c);
        }

        // Create Map Members for contacts
        RelationshipMapService.addContactToRelationshipMap(relationshipMapId, contactIdSet);

        // Find all groups for leads and update with contacts
        RelationshipGroupService.convertLeadsToContactGroups(leadIds, leadContactMap);

        // Find all relationships for leads and update to contacts
        MapMemberPlaceholderService.updateRelationshipForLeads(leadIds, leadContactMap);

        // Find all node coordinates
        RMNodeCoordinateService.udpateCoordinatesForLeads(leadIds, leadContactMap);

        // Remove Key Stakeholder Leads
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(mmLeads);
        uow.commitWork();
    }

    private Boolean hasMapMemberLeadAccess() {
        // Check if users have access to leads
        if (
            Schema.sObjectType.Lead.isAccessible() &&
            Schema.sObjectType.Map_Member_Lead__c.isAccessible() &&
            Schema.sObjectType.Map_Member_Lead__c.fields.Lead__c.isAccessible()
        ) {
            return true;
        }
        return false;
    }

    private Boolean hasKeyStakeholderLeadAccess() {
        // Check if users have access to leads
        if (
            Schema.sObjectType.Lead.isAccessible() &&
            Schema.sObjectType.Key_Stakeholder_Lead__c.isAccessible() &&
            Schema.sObjectType.Key_Stakeholder_Lead__c.fields.Lead__c.isAccessible()
        ) {
            return true;
        }
        return false;
    }
}