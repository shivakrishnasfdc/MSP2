public with sharing class DynamicObjectQueryService {
    public static SObject querySObjectWithTypeAndId(Schema.sObjectType objType, Id recordId, Set<String> selectFields) {
        return service().querySObjectWithTypeAndId(objType.getDescribe().getName(), recordId, selectFields);
    }

    public static SObject querySObjectWithTypeAndId(
        Schema.DescribeSObjectResult objDescribe,
        Id recordId,
        Set<String> selectFields
    ) {
        return service().querySObjectWithTypeAndId(objDescribe.getName(), recordId, selectFields);
    }

    public static SObject querySObjectWithTypeAndId(String sObjType, Id recordId, Set<String> selectFields) {
        return service().querySObjectWithTypeAndId(sObjType, recordId, selectFields);
    }

    public static List<SObject> querySObjectListWithTypeAndFields(
        String sObjTypeString,
        Set<String> selectFields,
        String sortField
    ) {
        return service().querySObjectListWithTypeAndFields(sObjTypeString, selectFields, sortField);
    }

    public static List<SObject> querySObjectListWithTypeAndFields(
        Schema.SObjectType sObjType,
        Set<String> selectFields,
        String sortField
    ) {
        return service().querySObjectListWithTypeAndFields(sObjType, selectFields, sortField);
    }

    public static List<SObject> querySObjectListWithIdsAndFields(List<Id> idList, Set<String> selectFields) {
        return service().querySObjectListWithIdsAndFields(idList, selectFields);
    }

    public static List<SObject> queryRecentlyViewedExcludingIds(String objectName, List<String> excludedIds) {
        return service().queryRecentlyViewedExcludingIds(objectName, excludedIds);
    }

    public static List<SObject> searchSObjectsWithTypeAndFieldsExcludingIds(
        String objectName,
        String searchTerm,
        String objNameField,
        String displayFieldName,
        List<String> excludedIds
    ) {
        return service()
            .searchSObjectsWithTypeAndFieldsExcludingIds(
                objectName,
                searchTerm,
                objNameField,
                displayFieldName,
                excludedIds
            );
    }

    public static List<RecentlyViewed> queryRecentlyViewedWithLookupTypes(List<InputLookupTypeObject> types) {
        return service().queryRecentlyViewedWithLookupTypes(types);
    }

    public static List<SObject> searchSObjectsWithLookupTypes(List<InputLookupTypeObject> types, String searchTerm) {
        return service().searchSObjectsWithLookupTypes(types, searchTerm);
    }

    public static List<SObject> querySObjectsWithTypeAndIds(
        Schema.SObjectType objType,
        Set<Schema.SObjectField> selectFields,
        Set<Id> recordIds
    ) {
        return service().querySObjectsWithTypeAndIds(objType, selectFields, recordIds);
    }

    public static List<SObject> querySObjectsWithTypeAndIdsMatchingRecords(
        Schema.SObjectType objType,
        Set<Schema.SObjectField> selectFields,
        Set<Id> recordIds
    ) {
        return service().querySObjectsWithTypeAndIdsMatchingRecords(objType, selectFields, recordIds);
    }

    private static DynamicObjectQueryServiceImpl service() {
        return (DynamicObjectQueryServiceImpl) Application.Service.newInstance(DynamicObjectQueryServiceImpl.class);
    }
}