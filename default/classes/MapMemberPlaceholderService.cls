public with sharing class MapMemberPlaceholderService {
    public static GraphNodeData createNewPlaceholder(GraphNodeData gnd, Id objectId) {
        return service().createNewPlaceholder(gnd, objectId);
    }

    public static void deletePlaceholders(List<String> placeholderIds) {
        service().deletePlaceholders(placeholderIds);
    }

    public static void updatePlaceholderDescription(GraphNodeData gnd, String newDescription) {
        service().updatePlaceholderDescription(gnd, newDescription);
    }

    public static void updatePlaceholderNameAndLabel(GraphNodeData gnd, String newLabel) {
        service().updatePlaceholderNameAndLabel(gnd, newLabel);
    }

    public static void updatePlaceholderReportToLinks(
        List<GraphLinkData> gldList,
        Id mapOrAccountPlanId,
        RM_Chart_Setting__c setting
    ) {
        service().updatePlaceholderReportToLinks(gldList, mapOrAccountPlanId, setting);
    }

    public static GraphData getPlaceholdersAndLinksByObjectId(Id objectId) {
        return service().getPlaceholdersAndLinksByObjectId(objectId);
    }

    public static GraphData getAndInjectCustomLinks(GraphData gd, Id mapId) {
        return service().getAndInjectCustomLinks(gd, mapId);
    }

    public static void updateRelationshipForLeads(Set<String> leadIds, Map<Id, Id> leadContactMap) {
        service().updateRelationshipForLeads(leadIds, leadContactMap);
    }

    private static MapMemberPlaceholderServiceImpl service() {
        return (MapMemberPlaceholderServiceImpl) Application.Service.newInstance(MapMemberPlaceholderServiceImpl.class);
    }
}