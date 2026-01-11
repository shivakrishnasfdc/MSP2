public with sharing class MapMemberLeadService {
    public static GraphData createLeadsForMap(
        GraphData graphData,
        Id relationshipMapId,
        Map<String, String> mapInfluence,
        Map<String, String> mapSupport
    ) {
        return service().createLeadsForMap(graphData, relationshipMapId, mapInfluence, mapSupport);
    }

    public static GraphData createLeadsForAccountPlan(
        GraphData graphData,
        Id accountPlanId,
        Map<String, String> mapInfluence,
        Map<String, String> mapSupport
    ) {
        return service().createLeadsForAccountPlan(graphData, accountPlanId, mapInfluence, mapSupport);
    }

    public static void deleteMapMemberLeads(List<String> idList) {
        service().deleteMapMemberLeads(idList);
    }

    public static void deleteKeyStakeholderLeads(List<String> idList) {
        service().deleteKeyStakeholderLeads(idList);
    }

    public static GraphData getAndInjectMapMemberLeadNodes(
        GraphData graphData,
        Id relationshipMapId,
        Map<String, String> mapInfluence,
        Map<String, String> mapSupport
    ) {
        return service().getAndInjectMapMemberLeadNodes(graphData, relationshipMapId, mapInfluence, mapSupport);
    }

    public static GraphData getAndInjectKeyStakeholderLeadNodes(
        GraphData graphData,
        Id accountPlanId,
        Map<String, String> mapInfluence,
        Map<String, String> mapSupport
    ) {
        return service().getAndInjectKeyStakeholderLeadNodes(graphData, accountPlanId, mapInfluence, mapSupport);
    }

    public static void convertLeadsToKeyStakeholders(Id accountPlanId) {
        service().convertLeadsToKeyStakeholders(accountPlanId);
    }

    public static void convertLeadsToMapMembers(Id relationshipMapId) {
        service().convertLeadsToMapMembers(relationshipMapId);
    }

    private static MapMemberLeadServiceImpl service() {
        return (MapMemberLeadServiceImpl) Application.Service.newInstance(MapMemberLeadServiceImpl.class);
    }
}