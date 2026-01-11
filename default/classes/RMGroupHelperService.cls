public with sharing class RMGroupHelperService {
    private static RMGroupHelperServiceImpl instance = null;

    public static void addObjectsToGroup(Id groupId, List<String> objectIds, Id mapOrAccountPlanId) {
        service().addObjectsToGroup(groupId, objectIds, mapOrAccountPlanId);
    }

    public static void removeGroupRelationships(Set<String> objectIds, Id mapOrAccountPlanId) {
        service().removeGroupRelationships(objectIds, mapOrAccountPlanId);
    }

    public static void removeContactsFromGroup(Map<String, String> mapObjectGroup) {
        service().removeContactsFromGroup(mapObjectGroup);
    }

    public static void removePlaceholdersFromGroup(Map<String, String> mapObjectGroup) {
        service().removePlaceholdersFromGroup(mapObjectGroup);
    }

    public static void removeUsersFromGroup(Map<String, String> mapObjectGroup) {
        service().removeUsersFromGroup(mapObjectGroup);
    }

    public static void removeLeadsFromGroup(Map<String, String> mapObjectGroup) {
        service().removeLeadsFromGroup(mapObjectGroup);
    }

    public static void removeGroupsFromGroup(Map<String, String> mapObjectGroup) {
        service().removeGroupsFromGroup(mapObjectGroup);
    }

    public static Relationship_Group__c createGroup(
        String newName,
        String newLabel,
        String tempId,
        String parentKey,
        Id mapOrAccountPlanId,
        String groupLayout
    ) {
        return service().createGroup(newName, newLabel, tempId, parentKey, mapOrAccountPlanId, groupLayout);
    }

    private static RMGroupHelperServiceImpl service() {
        if (instance == null) {
            instance = (RMGroupHelperServiceImpl) Application.Service.newInstance(RMGroupHelperServiceImpl.class);
        }
        return instance;
    }
}