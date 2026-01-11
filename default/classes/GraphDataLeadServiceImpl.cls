public with sharing class GraphDataLeadServiceImpl {
    public List<GraphNodeData> createGraphDataNodes(
        List<Lead> leads,
        Map<Id, IRelationshipMapLeadObject2> mapRelationshipMapMemberObject,
        List<Relationship_Group_Lead_Association__c> rels,
        Id mapOrAccountPlanId
    ) {
        Map<Id, Relationship_Group_Lead_Association__c> groupLeadAssocByLeadId = RelationshipGroupService.getGroupLeadAssocMap(
            rels,
            mapOrAccountPlanId
        );

        List<GraphNodeData> nodeData = new List<GraphNodeData>();

        Map<Id, Relationship_Group__c> relGroups = new Map<Id, Relationship_Group__c>();

        for (Lead l : leads) {
            IRelationshipMapLeadObject2 member = mapRelationshipMapMemberObject != null
                ? mapRelationshipMapMemberObject.get(l.Id)
                : null;

            String influenceImageUrl = null;
            String supportImageUrl = null;
            String influence = null;
            String support = null;
            String supportColor = null;
            Id memberId = null;
            String type = 'lead';

            if (member != null) {
                memberId = member.id();
                type = 'leadmember';
            }

            GraphNodeData gnd = new GraphNodeData(
                l.Id,
                memberId,
                type,
                l.Name,
                member?.title(),
                null,
                influence,
                influenceImageUrl,
                support,
                supportColor,
                supportImageUrl,
                l.company,
                null
            );

            Relationship_Group_Lead_Association__c groupLeadAssoc = groupLeadAssocByLeadId.get(l.Id);
            if (groupLeadAssoc != null) {
                gnd.groupKey = groupLeadAssoc.Relationship_Group__c;
                relGroups.put(groupLeadAssoc.Relationship_Group__r.Id, groupLeadAssoc.Relationship_Group__r);
            }

            nodeData.add(gnd);
        }

        Map<Id, Relationship_Group__c> allGroups = RelationshipGroupService.getAllGroups(relGroups, mapOrAccountPlanId);

        nodeData.addAll(RelationshipGroupService.createNodeDataForGroups(allGroups.values()));

        return nodeData;
    }
}