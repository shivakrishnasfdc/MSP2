public with sharing class CloneSharedService {
    public static List<SObject> cloneWrappedObjectsReplacingParents(
        List<CloneObjectsWrapper> wrappers,
        Map<Id, SObject> clonedParentsByOriginalId
    ) {
        return service().cloneWrappedObjectsReplacingParents(wrappers, clonedParentsByOriginalId);
    }

    public static Map<Id, SObject> mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
        List<SObject> relatedObjects,
        Map<Id, SObject> clonedParentsByOriginalId,
        Set<String> parentRelationshipNames
    ) {
        return service()
            .mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedObjects,
                clonedParentsByOriginalId,
                parentRelationshipNames
            );
    }

    public static Map<Id, SObject> mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
        List<SObject> relatedObjects,
        Map<Id, SObject> clonedParentsByOriginalId,
        Set<String> parentRelationshipNames,
        Type returnedMapType
    ) {
        return service()
            .mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                relatedObjects,
                clonedParentsByOriginalId,
                parentRelationshipNames,
                returnedMapType
            );
    }

    public static List<Relationship_Group__c> updateRelatedGroupsWithParentGroups(
        List<Relationship_Group__c> originalGroups,
        Map<Id, Relationship_Group__c> clonedGroupsByOriginalId,
        String parentGroupRelationshipName
    ) {
        return service()
            .updateRelatedGroupsWithParentGroups(originalGroups, clonedGroupsByOriginalId, parentGroupRelationshipName);
    }

    public static List<SObject> fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
        Schema.SObjectType objectType,
        Set<Id> matchIds,
        Set<String> queryKeys
    ) {
        return service().fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(objectType, matchIds, queryKeys);
    }

    private static CloneSharedServiceImpl service() {
        return (CloneSharedServiceImpl) Application.Service.newInstance(CloneSharedServiceImpl.class);
    }

    public class CloneObjectsWrapper {
        public List<SObject> relatedObjects;
        public Set<String> parentRelationshipNames;
    }
}