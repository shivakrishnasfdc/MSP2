public with sharing class SObjectService {
    public static Schema.SobjectType getSObjectType(String sobjectApiName) {
        return service().getSObjectType(sobjectApiName);
    }

    public static Set<Schema.SObjectField> relationshipsFromDescribeMatchingObjectType(
        Schema.DescribeSObjectResult describe,
        Schema.sObjectType objectType
    ) {
        return service().relationshipsFromDescribeMatchingObjectType(describe, objectType);
    }

    public static Set<Schema.SObjectType> getObjectsRelatedTo(Schema.sObjectType objectType) {
        return service().getObjectsRelatedTo(objectType);
    }

    public static Map<Id, Set<Id>> getMapOfObjectIdsRelatedToIdSet(
        Set<Id> recordIds,
        Schema.sObjectType ofType,
        List<Schema.sObjectType> relatedObjectTypes
    ) {
        return service().getMapOfObjectIdsRelatedToIdSet(recordIds, ofType, relatedObjectTypes);
    }

    public static Set<Id> getIdsForRelatedObjects(Id recordId, List<Schema.sObjectType> relatedObjectTypes) {
        return service().getIdsForRelatedObjects(recordId, relatedObjectTypes);
    }

    public static Boolean hasRecordTypeEnabled(SObjectType objType) {
        return service().hasRecordTypeEnabled(objType);
    }

    public static Map<String, FieldMetaData> getDescribeFieldMapsForFields(
        Schema.SObjectType descSObjectResult,
        List<String> fields
    ) {
        return service().getDescribeFieldMapsForFields(descSObjectResult, fields);
    }

    public static Id getFirstIdFromSObjectMatchingFields(SObject obj, Set<SObjectField> matchingFields) {
        return service().getFirstIdFromSObjectMatchingFields(obj, matchingFields);
    }

    public static List<String> getCustomFields(Schema.SObjectType objType, Boolean getOnlyUpdateableFields) {
        return service().getCustomFields(objType, getOnlyUpdateableFields);
    }

    private static SObjectServiceImpl service() {
        return (SObjectServiceImpl) Application.Service.newInstance(SObjectServiceImpl.class);
    }
}