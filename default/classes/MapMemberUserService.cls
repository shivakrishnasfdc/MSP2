public with sharing class MapMemberUserService {
    public static GraphData createMapMemberUsers(GraphData graphData, Id mapOrAccountPlanId) {
        return service().createMapMemberUsers(graphData, mapOrAccountPlanId);
    }

    public static void deleteMapMemberUsers(List<Id> mapMemberUserIds) {
        service().deleteMapMemberUsers(mapMemberUserIds);
    }

    public static GraphData getMapMemberUsersAndLinksByObjectId(Id objectId) {
        return service().getMapMemberUsersAndLinksByObjectId(objectId);
    }

    public static GraphData getAndInjectMapMemberUserNodes(GraphData graphData, Id mapOrAccountPlanId) {
        return service().getAndInjectMapMemberUserNodes(graphData, mapOrAccountPlanId);
    }

    public static GraphData getUserGraphDataForSearchTerm(
        String searchTerm,
        List<Id> excludeIds,
        List<Org_Chart_Field__c> orgChartfields,
        Set<String> userFields,
        Id mapOrAccountPlanId
    ) {
        return service()
            .getUserGraphDataForSearchTerm(
                searchTerm,
                excludeIds,
                orgChartfields,
                userFields,
                mapOrAccountPlanId
            );
    }

    public static GraphData getParentNodesForUserIds(
        List<Id> userIds,
        List<Org_Chart_Field__c> orgChartfields,
        Set<String> userFields,
        Id mapOrAccountPlanId
    ) {
        return service().getParentNodesForUserIds(userIds, orgChartfields, userFields, mapOrAccountPlanId);
    }

    public static GraphData generateMapMemberUserGraphData(
        List<IRelationshipMapUserObject> hierarchyObjects,
        Boolean showParentNodes,
        Boolean showEmptyFields,
        Set<String> userFieldSet,
        List<Org_Chart_Field__c> orgChartfields,
        Id mapOrAccountPlanId
    ) {
        return service()
            .generateMapMemberUserGraphData(
                hierarchyObjects,
                showParentNodes,
                showEmptyFields,
                userFieldSet,
                orgChartfields,
                mapOrAccountPlanId
            );
    }

    // -----------------------------------------------------------------

    private static MapMemberUserServiceImpl service() {
        return (MapMemberUserServiceImpl) Application.Service.newInstance(MapMemberUserServiceImpl.class);
    }
}