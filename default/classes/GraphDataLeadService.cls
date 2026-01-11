public with sharing class GraphDataLeadService {
    public static List<GraphNodeData> createGraphDataNodes(
        List<Lead> leads,
        Map<Id, IRelationshipMapLeadObject2> mapRelationshipMapMemberObject,
        List<Relationship_Group_Lead_Association__c> rels,
        Id mapOrAccountPlanId
    ) {
        return service().createGraphDataNodes(leads, mapRelationshipMapMemberObject, rels, mapOrAccountPlanId);
    }

    private static GraphDataLeadServiceImpl service() {
        return (GraphDataLeadServiceImpl) Application.Service.newInstance(GraphDataLeadServiceImpl.class);
    }
}