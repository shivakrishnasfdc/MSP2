public with sharing class RelationshipGroupService {
    public static GraphNodeData createNewGroup(GraphNodeData graphData, List<String> idList, Id objectId) {
        return service().createNewGroup(graphData, idList, objectId);
    }

    public static void updateGroupName(GraphNodeData graphData, String newName) {
        service().updateGroupName(graphData, newName);
    }

    public static void addContactsToGroup(GraphNodeData graphData, List<String> objectIds, Id mapOrAccountPlanId) {
        service().addContactsToGroup(graphData, objectIds, mapOrAccountPlanId);
    }

    public static void addGroupsToGroup(GraphNodeData graphData, List<String> groupIds) {
        service().addGroupsToGroup(graphData, groupIds);
    }

    public static void removeNodesFromGroup(List<GraphNodeData> graphNodeDataList) {
        service().removeNodesFromGroup(graphNodeDataList);
    }

    public static Map<Id, Relationship_Group__c> getAllGroups(
        Map<Id, Relationship_Group__c> relGroups,
        Id mapOrAccountPlanId
    ) {
        return service().getAllGroups(relGroups, mapOrAccountPlanId);
    }

    public static List<GraphNodeData> createNodeDataForGroups(List<Relationship_Group__c> relGroups) {
        return service().createNodeDataForGroups(relGroups);
    }

    public static Map<Id, Relationship_Group_Contact_Association__c> getGroupContactAssocMap(
        List<Relationship_Group_Contact_Association__c> rels,
        Id mapOrAccountPlanId
    ) {
        return service().getGroupContactAssocMap(rels, mapOrAccountPlanId);
    }

    public static Map<Id, Relationship_Group_User_Association__c> getGroupUserAssocMap(
        List<Relationship_Group_User_Association__c> rels,
        Id mapOrAccountPlanId
    ) {
        return service().getGroupUserAssocMap(rels, mapOrAccountPlanId);
    }

    public static Map<Id, Relationship_Group_Lead_Association__c> getGroupLeadAssocMap(
        List<Relationship_Group_Lead_Association__c> rels,
        Id mapOrAccountPlanId
    ) {
        return service().getGroupLeadAssocMap(rels, mapOrAccountPlanId);
    }

    public static void convertLeadsToContactGroups(Set<String> leadIds, Map<Id, Id> leadContactMap) {
        service().convertLeadsToContactGroups(leadIds, leadContactMap);
    }

    public static void updateGroupLayout(String groupId, String type) {
        service().updateGroupLayout(groupId, type);
    }

    public static List<RelationshipGroupContactWrapper> getGroupsForContactId(Id contactId) {
        return service().getGroupsForContactId(contactId);
    }

    private static RelationshipGroupServiceImpl service() {
        return (RelationshipGroupServiceImpl) Application.Service.newInstance(RelationshipGroupServiceImpl.class);
    }
}