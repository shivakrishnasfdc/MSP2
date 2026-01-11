public with sharing class RelationshipMapCloneController {
    @AuraEnabled
    public static List<Relationship_Map__c> cloneRelationshipMap(
        Id oldMapId,
        String newMapName,
        Id newMapOwnerId,
        Id newRelatedObjectId
    ) {
        if (oldMapId == null) {
            return new List<Relationship_Map__c>();
        }
        RelationshipMapCloneWrapper wrapper = new RelationshipMapCloneWrapper(
            oldMapId,
            newMapName,
            newMapOwnerId,
            newRelatedObjectId
        );
        List<RelationshipMapCloneWrapper> wrappers = new List<RelationshipMapCloneWrapper>{ wrapper };
        List<Relationship_Map__c> clonedPlans = RelationshipMapCloneService.cloneRelationshipMaps(wrappers);
        return clonedPlans;
    }

    @AuraEnabled(cacheable=true)
    public static List<InputLookupTypeObject> getInputLookupTypeObjectsForRMRelationships() {
        Schema.DescribeSObjectResult objDescribe = Relationship_Map__c.getSObjectType().getDescribe();
        List<InputLookupTypeObject> inputLookupTypeObjects = new List<InputLookupTypeObject>{};
        for (Schema.ChildRelationship cr : objDescribe.childrelationships) {
            if (isFieldGoodForLookup(cr.getField()) && cr.childsobject.getDescribe().isSearchable()) {
                inputLookupTypeObjects.add(new InputLookupTypeObject(cr.childsobject.getDescribe().getName()));
            }
        }
        List<Schema.SObjectField> fieldValues = objDescribe.fields.getMap().values();
        for (Schema.SObjectField field : fieldValues) {
            if (isFieldGoodForLookup(field)) {
                inputLookupTypeObjects.add(
                    new InputLookupTypeObject(field.getDescribe().getReferenceTo()[0].getDescribe().getName())
                );
            }
        }
        return inputLookupTypeObjects;
    }

    private static boolean isFieldGoodForLookup(Schema.SObjectField field) {
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        if (!fieldDescribe.isCustom()) {
            return false;
        }
        if (fieldDescribe.getType().name() != 'REFERENCE') {
            return false;
        }
        List<Schema.sObjectType> references = fieldDescribe.getReferenceTo();
        Schema.SObjectType objType = references.get(0);
        if (objType != Relationship_Map__c.getSObjectType() && !objType.getDescribe().isSearchable()) {
            return false;
        }
        return true;
    }
}