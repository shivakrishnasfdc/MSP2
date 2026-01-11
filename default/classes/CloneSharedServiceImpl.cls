public without sharing class CloneSharedServiceImpl {
    public List<SObject> cloneWrappedObjectsReplacingParents(
        List<CloneSharedService.CloneObjectsWrapper> wrappers,
        Map<Id, SObject> clonedParentsByOriginalId
    ) {
        if (
            wrappers == null ||
            wrappers.size() == 0 ||
            clonedParentsByOriginalId == null ||
            clonedParentsByOriginalId.size() == 0
        ) {
            return new List<SObject>();
        }
        List<SObject> clonedObjects = new List<SObject>();
        for (CloneSharedService.CloneObjectsWrapper wrapper : wrappers) {
            Map<Id, SObject> clonedObjectsByOriginalId = mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
                wrapper.relatedObjects,
                clonedParentsByOriginalId,
                wrapper.parentRelationshipNames
            );
            clonedObjects.addAll(clonedObjectsByOriginalId.values());
        }
        return clonedObjects;
    }

    public Map<Id, SObject> mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
        List<SObject> relatedObjects,
        Map<Id, SObject> clonedParentsByOriginalId,
        Set<String> parentRelationshipNames
    ) {
        return mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
            relatedObjects,
            clonedParentsByOriginalId,
            parentRelationshipNames,
            Map<Id, SObject>.class
        );
    }

    public Map<Id, SObject> mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
        List<SObject> relatedObjects,
        Map<Id, SObject> clonedParentsByOriginalId,
        Set<String> parentRelationshipNames,
        Type mapType
    ) {
        // If no original object, or no parents, or no parent relationships, then no reason to clone anything
        // since we only care about cloning objects that have a new parent relationship
        if (
            relatedObjects == null ||
            relatedObjects.size() == 0 ||
            clonedParentsByOriginalId == null ||
            clonedParentsByOriginalId.size() == 0 ||
            parentRelationshipNames == null ||
            parentRelationshipNames.size() == 0
        ) {
            return (Map<Id, SObject>) mapType.newInstance();
        }
        Map<Id, SObject> clonedRelatedObjs = (Map<Id, SObject>) mapType.newInstance();
        for (SObject relatedObj : relatedObjects) {
            SObject clonedRObj = relatedObj.clone(false, true, false, false); //deep clone, does not preserve Id, timestamps, or autonumber
            Boolean parentFound = false;

            Set<String> validatedParentRelationshipNames = new Set<String>();
            validatedParentRelationshipNames.addAll(this.validateParentRelationshipNames(parentRelationshipNames, relatedObj));

            for (String parentRelationshipName : validatedParentRelationshipNames) {
                Id originalParentId = (Id) relatedObj.get(parentRelationshipName);
                SObject clonedParent = clonedParentsByOriginalId.get(originalParentId);
                if (clonedParent != null) {
                    clonedRObj.put(parentRelationshipName, clonedParent.Id);
                    parentFound = true;
                }
            }
            if (parentFound) {
                //Only return objects that have a difference from the original, if exactly the same then no reason to clone it
                clonedRelatedObjs.put(relatedObj.Id, clonedRObj);
            }
        }
        return clonedRelatedObjs;
    }

    public List<Relationship_Group__c> updateRelatedGroupsWithParentGroups(
        List<Relationship_Group__c> originalGroups,
        Map<Id, Relationship_Group__c> clonedGroupsByOriginalId,
        String parentGroupRelationshipName
    ) {
        // If no original object, or no parents, or no parent relationships, then no reason to clone anything
        // since we only care about cloning objects that have a new parent relationship
        if (
            originalGroups == null ||
            originalGroups.size() == 0 ||
            clonedGroupsByOriginalId == null ||
            clonedGroupsByOriginalId.size() == 0 ||
            parentGroupRelationshipName == null
        ) {
            return new List<Relationship_Group__c>();
        }
        List<Relationship_Group__c> updatedGroups = new List<Relationship_Group__c>();
        for (Relationship_Group__c originalGroupRecord : originalGroups) {
            // Check for any Groups with no Parent Relationship Groups
            if (originalGroupRecord.Parent_Relationship_Group__c == null) {
                continue;
            }
            Relationship_Group__c clonedOuterGroupRecord = clonedGroupsByOriginalId.get(
                originalGroupRecord.Parent_Relationship_Group__c
            );
            Relationship_Group__c clonedInnerGroupRecord = clonedGroupsByOriginalId.get(originalGroupRecord.Id);

            if (clonedInnerGroupRecord != null && clonedOuterGroupRecord != null) {
                clonedInnerGroupRecord.Parent_Relationship_Group__c = clonedOuterGroupRecord.Id;

                //Only return objects that have a difference from the original, if exactly the same then no reason to clone it
                updatedGroups.add(clonedInnerGroupRecord);
            }
        }
        return updatedGroups;
    }

    public List<SObject> fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
        Schema.SObjectType objectType,
        Set<Id> matchIds,
        Set<String> queryKeys
    ) {
        if (matchIds == null || matchIds.size() == 0) {
            return new List<SObject>();
        }
        if (queryKeys == null) {
            queryKeys = new Set<String>{ 'Id' };
        }
        String fieldSetName = 'clone_fields';
        String crushFS = 'pqcrush__clone_fields';
        List<String> fields = UTIL_Describe.listStrFromFieldSet(objectType.getDescribe().getName(), crushFS);
        if (fields == null || fields.isEmpty()) {
            fields = UTIL_Describe.listStrFromFieldSet(objectType.getDescribe().getName(), fieldSetName);
        }
        if (fields == null || fields.isEmpty()) {
            Set<String> fieldSet = new Set<String>(queryKeys);
            fieldSet.add('Id');
            fields = new List<String>(fieldSet);
        }
        Query objQuery = new Query(objectType, null);
        objQuery.selectFields(fields);
        objQuery.orderBy('Id');
        objQuery.switchToDisjunction();
        for (String queryKey : queryKeys) {
            objQuery.lookup(String.escapeSingleQuotes(queryKey), matchIds);
        }
        List<SObject> objects = objQuery.toSObjectList();
        return objects;
    }

    public Set<String> validateParentRelationshipNames(
        Set<String> parentRelationshipNames,
        SObject relatedObj
    ){
        Set<String> validatedParentRelationshipNames = new Set<String>();
        for (String parentRelationshipName : parentRelationshipNames) {
            if ((String) relatedObj.get(parentRelationshipName) instanceof Id) {
                validatedParentRelationshipNames.add(parentRelationshipName);
            }
        }
        return validatedParentRelationshipNames;
    }
}