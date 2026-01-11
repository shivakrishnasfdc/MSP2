public with sharing class GraphDataService {
    public static Map<String, String> getSupportColors() {
        return service().getSupportColors();
    }

    public static GraphData getContactGraphDataForSearchTerm(
        String searchTerm,
        List<String> excludeIds,
        String accountId,
        List<Org_Chart_Field__c> orgChartfields,
        Set<String> contactFields,
        Id mapOrAccountPlanId
    ) {
        return service()
            .getContactGraphDataForSearchTerm(
                searchTerm,
                excludeIds,
                accountId,
                orgChartfields,
                contactFields,
                mapOrAccountPlanId
            );
    }
    public static GraphData getAccountGraphDataForSearchTerm(
        String searchTerm,
        List<String> excludeIds,
        String accountId,
        List<Org_Chart_Field__c> orgChartfields,
        Set<String> accountFields,
        Id mapOrAccountPlanId
    ) {
        return service()
            .getAccountGraphDataForSearchTerm(
                searchTerm,
                excludeIds,
                accountId,
                orgChartfields,
                accountFields,
                mapOrAccountPlanId
            );
    }

    public static GraphData getLeadGraphDataForSearchTerm(
        String searchTerm,
        List<String> excludeIds,
        Id mapOrAccountPlanId
    ) {
        return service().getLeadGraphDataForSearchTerm(searchTerm, excludeIds, mapOrAccountPlanId);
    }

    public static GraphData getParentNodesForContactIds(
        List<String> contactIds,
        List<Org_Chart_Field__c> orgChartfields,
        Set<String> contactFields,
        Id mapOrAccountPlanId
    ) {
        return service().getParentNodesForContactIds(contactIds, orgChartfields, contactFields, mapOrAccountPlanId);
    }

    // HIERARCHY LINKS
    public static void updateReportsTo(List<GraphLinkData> gld, Id mapOrAccountPlanId, RM_Chart_Setting__c setting) {
        service().updateReportsTo(gld, mapOrAccountPlanId, setting);
    }
    // HIERARCHY LINKS
    public static void updateParentAccountId(List<GraphLinkData> gld, Id mapOrAccountPlanId, RM_Chart_Setting__c setting) {
        service().updateParentAccountId(gld, mapOrAccountPlanId, setting);
    }

    public static GraphData getAndInjectPlaceholderNodes(GraphData graphData, Id mapOrAccountPlanId) {
        return service().getAndInjectPlaceholderNodes(graphData, mapOrAccountPlanId);
    }

    public static GraphData getAndInjectNodeCoordinates(GraphData graphData, Id mapOrAccountPlanId) {
        return service().getAndInjectNodeCoordinates(graphData, mapOrAccountPlanId);
    }

    public static GraphData getAndInjectLocalHierarchyLinksForContacts(
        Id mapOrAccountPlanId,
        GraphData graphData,
        Set<String> contactIds
    ) {
        return service().getAndInjectLocalHierarchyLinksForContacts(mapOrAccountPlanId, graphData, contactIds);
    }

    // GET MAP MEMBER/KEYSTAKEHOLDER GRAPH DATA
    public static GraphData generateGraphData(
        List<IRelationshipMapObject> hierarchyObjects,
        RM_Chart_Setting__c setting,
        Map<String, String> influenceMap,
        Map<String, String> supportMap,
        Set<String> contactFieldSet,
        List<Org_Chart_Field__c> orgChartfields,
        Id mapOrAccountPlanId
    ) {
        return service()
            .generateGraphData(
                hierarchyObjects,
                setting,
                influenceMap,
                supportMap,
                contactFieldSet,
                orgChartfields,
                mapOrAccountPlanId
            );
    }
    public static GraphData generateAccountGraphData(
        List<AccountMapObject> hierarchyObjects,
        RM_Chart_Setting__c setting,
        Map<String, String> influenceMap,
        Map<String, String> supportMap,
        Set<String> accountFieldSet,
        List<Org_Chart_Field__c> orgChartfields,
        Id mapOrAccountPlanId
    ) {
        return service()
            .generateAccountGraphData(
                hierarchyObjects,
                setting,
                influenceMap,
                supportMap,
                accountFieldSet,
                orgChartfields,
                mapOrAccountPlanId
            );
    }

    public static List<Contact_Relationship_Type__c> getContactRelationshipTypes(Id mapOrAccountPlanId) {
        return service().getContactRelationshipTypes(mapOrAccountPlanId);
    }

    public static GraphData getAndInjectCustomLinks(GraphData gd, Id mapId) {
        return service().getAndInjectCustomLinks(gd, mapId);
    }

    private static GraphDataServiceImpl service() {
        return (GraphDataServiceImpl) Application.Service.newInstance(GraphDataServiceImpl.class);
    }
}