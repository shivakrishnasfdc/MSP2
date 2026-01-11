@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class WhiteSpaceUtils {
    @AuraEnabled
    public static Integer getTotalCount(WhiteSpaceTemplateMappingWrapper mapping) {
        return service().getTotalCount(mapping);
    }

    @AuraEnabled
    public static Integer getTotalCountWithLookup(WhiteSpaceTemplateMappingWrapper mapping, String lookupRecordId) {
        return service().getTotalCountWithLookup(mapping, lookupRecordId);
    }

    public static List<SObject> getResults(WhiteSpaceTemplateMappingWrapper mapping) {
        return service().getResults(mapping);
    }

    public static List<SObject> getResults(WhiteSpaceTemplateMappingWrapper mapping, Id lookupRecordId) {
        return service().getResults(mapping, lookupRecordId);
    }

    public static Query getQueryFromMapping(WhiteSpaceTemplateMappingWrapper mapping) {
        return service().getQueryFromMapping(mapping);
    }

    public static Query getQueryFromMapping(WhiteSpaceTemplateMappingWrapper mapping, Id lookupRecordId) {
        return service().getQueryFromMapping(mapping, lookupRecordId);
    }

    public static List<String> findChildRelationshipNames(String parentObjectName, String childObjectName) {
        return service().findChildRelationshipNames(parentObjectName, childObjectName);
    }

    public static void registerConditions(Query queryObj, WhiteSpaceTemplateMappingWrapper mapping) {
        service().registerConditions(queryObj, mapping);
    }

    public static void registerLookup(Query queryObj, String objectName, Id lookupRecordId) {
        service().registerLookup(queryObj, objectName, lookupRecordId);
    }

    public static void registerLookup(
        Query queryObj,
        String objectName,
        Id lookupRecordId,
        Boolean shouldfilterUnrelatedCells
    ) {
        service().registerLookup(queryObj, objectName, lookupRecordId, shouldfilterUnrelatedCells);
    }

    public static Query.Condition createQueryCondition(String lh, String operator, Object rh) {
        return service().createQueryCondition(lh, operator, rh);
    }

    public static Object getValueFromType(String objectName, String fieldName, String originalValue) {
        return service().getValueFromType(objectName, fieldName, originalValue);
    }

    public static Boolean isNumberField(String objectName, String fieldName) {
        return service().isNumberField(objectName, fieldName);
    }

    public static Boolean isNumberField(String fieldType) {
        return service().isNumberField(fieldType);
    }

    public static Boolean isDateField(String objectName, String fieldName) {
        return service().isDateField(objectName, fieldName);
    }

    public static Boolean isDateField(String fieldType) {
        return service().isDateField(fieldType);
    }

    public static Boolean isDateTimeField(String objectName, String fieldName) {
        return service().isDateTimeField(objectName, fieldName);
    }

    public static Boolean isDateTimeField(String fieldType) {
        return service().isDateTimeField(fieldType);
    }

    public static Boolean isBooleanField(String objectName, String fieldName) {
        return service().isBooleanField(objectName, fieldName);
    }

    public static Boolean isBooleanField(String fieldType) {
        return service().isBooleanField(fieldType);
    }

    public static Boolean isPicklistMappingType(WhiteSpaceTemplateMappingWrapper headerMapping) {
        return service().isPicklistMappingType(headerMapping);
    }

    public static Boolean isPicklistMappingType(Mapping__c headerMapping) {
        return service().isPicklistMappingType(headerMapping);
    }

    public static Boolean isPicklistMappingType(WhiteSpaceTemplateWrapper.HeaderConfiguration headerConfiguration) {
        return service().isPicklistMappingType(headerConfiguration);
    }

    public static Boolean isMultiPicklistMappingType(WhiteSpaceTemplateMappingWrapper headerMapping) {
        return service().isMultiPicklistMappingType(headerMapping, null);
    }

    public static Boolean isMultiPicklistMappingType(
        WhiteSpaceTemplateMappingWrapper headerMapping,
        String labelField
    ) {
        return service().isMultiPicklistMappingType(headerMapping, labelField);
    }

    public static Boolean isAnyPicklistMappingType(WhiteSpaceTemplateMappingWrapper headerMapping, String labelField) {
        return service().isAnyPicklistMappingType(headerMapping, labelField);
    }

    public static Boolean isGroupMappingType(WhiteSpaceTemplateMappingWrapper headerMapping) {
        return service().isGroupMappingType(headerMapping);
    }

    public static Boolean isGroupMappingType(Mapping__c headerMapping) {
        return service().isGroupMappingType(headerMapping);
    }

    public static Boolean isGroupMappingType(WhiteSpaceTemplateWrapper.HeaderConfiguration headerConfiguration) {
        return service().isGroupMappingType(headerConfiguration);
    }

    @AuraEnabled
    public static List<String> getControllingFieldValuesForPicklistValue(
        String objectApiName,
        String dependFieldApiName,
        String dependValueApiName
    ) {
        return service()
            .getControllingFieldValuesForPicklistValue(objectApiName, dependFieldApiName, dependValueApiName);
    }

    public static Map<String, Map<String, List<SObject>>> getCellDataMap(
        Set<String> cellIds,
        Set<String> rowObjIds,
        Set<String> columnObjIds,
        Id cellFilterLookupId,
        Boolean shouldfilterUnrelatedCells,
        List<WhiteSpaceTemplateCellFieldWrapper> relatedCellFields,
        List<WhiteSpaceTemplateCellFieldWrapper> amountTypeFields,
        List<WhiteSpaceTemplateCellFieldWrapper> basicFields,
        Set<String> selectFields,
        Map<String, List<String>> relationConversionMap
    ) {
        return service()
            .getCellDataMap(
                cellIds,
                rowObjIds,
                columnObjIds,
                cellFilterLookupId,
                shouldfilterUnrelatedCells,
                relatedCellFields,
                amountTypeFields,
                basicFields,
                selectFields,
                relationConversionMap
            );
    }

    public static List<WSRelatedObjectWrapper> getWSRelatedObjectWrappers() {
        return service().getWSRelatedObjectWrappers();
    }

    /******************************
     *      PRIVATE METHODS
     ******************************/

    private static WhiteSpaceUtilsImpl service() {
        return (WhiteSpaceUtilsImpl) Application.Service.newInstance(WhiteSpaceUtilsImpl.class);
    }
}