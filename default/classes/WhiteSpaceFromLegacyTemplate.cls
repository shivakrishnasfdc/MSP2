public with sharing class WhiteSpaceFromLegacyTemplate extends WhiteSpaceFromTemplate {
    @testVisible
    private static WhiteSpaceTypeEnum type = WhiteSpaceTypeEnum.LEGACY_TEMPLATE;

    public WhiteSpaceFromLegacyTemplate(White_Space__c whiteSpaceInfo, White_Space_Template__c template) {
        super(whiteSpaceInfo, template, type, WhiteSpaceAmountTypeSelector.newInstance().selectAll());
    }

    protected override List<WhiteSpaceCollectionWrapper> getColumns() {
        return buildHeaderComponents(this.oColumns, this.privateTemplateWrapper.columnConfiguration.mapping);
    }

    protected override List<WhiteSpaceCollectionWrapper> getRows() {
        return buildHeaderComponents(this.oRows, this.privateTemplateWrapper.rowConfiguration.mapping);
    }

    protected override List<WhiteSpaceCellWrapper> getCells() {
        List<pqcrush__White_Space_Cell__c> cells = this.getUpdatedCells();
        Map<String, Map<String, List<SObject>>> fieldDataByRelatedIds = this.getCellDataMap(
            cells,
            null,
            null,
            null,
            null
        );
        return new WhiteSpaceCellBuilderLegacy(
                this.columns,
                this.rows,
                cells,
                this.amountTypes,
                this.dataTypes,
                this.relatedCellFields,
                this.relatedObjects,
                fieldDataByRelatedIds
            )
            .build();
    }

    private static List<WhiteSpaceCollectionWrapper> buildHeaderComponents(
        List<SObject> rowOrColumns,
        WhiteSpaceTemplateMappingWrapper mapping
    ) {
        Map<Id, SObject> dataMap = getDataMap(rowOrColumns, mapping);
        List<SObject> finalHeaderList = updateHeaders(rowOrColumns, dataMap);

        List<WhiteSpaceCollectionWrapper> wrappers = new List<WhiteSpaceCollectionWrapper>();

        for (SObject header : finalHeaderList) {
            Id recordId = (Id) header.get('Related_Object_Id__c');
            wrappers.add(new WhiteSpaceCollectionWrapper(header, mapping, dataMap.get(recordId)));
        }
        return wrappers;
    }

    private static List<SObject> updateHeaders(List<SObject> rowOrColumns, Map<Id, SObject> allMatchingRecordsMap) {
        List<SObject> finalHeaderList = new List<SObject>();
        for (SObject header : rowOrColumns) {
            Id recordId = (Id) header.get('Related_Object_Id__c');
            if (allMatchingRecordsMap.containsKey(recordId)) {
                finalHeaderList.add(header);
            }
        }
        return finalHeaderList;
    }

    private static Map<Id, SObject> getDataMap(List<SObject> rowOrColumns, WhiteSpaceTemplateMappingWrapper mapping) {
        Set<Id> relatedObjectIdSet = getIdsToQuery(rowOrColumns);
        return getRelatedRecords(relatedObjectIdSet, mapping);
    }

    private static Set<Id> getIdsToQuery(List<SObject> rowOrColumns) {
        Set<Id> relatedObjectIdSet = new Set<Id>();
        for (SObject header : rowOrColumns) {
            Id recordId = (Id) header.get('Related_Object_Id__c');
            relatedObjectIdSet.add(recordId);
        }
        return relatedObjectIdSet;
    }

    private static Map<Id, SObject> getRelatedRecords(Set<Id> recordIds, WhiteSpaceTemplateMappingWrapper mapping) {
        if (!mapping.description.isAccessible()) {
            throw Application.createAuraHandledException(System.Label.error_access_template_objects);
        }
        Map<Id, SObject> relatedObjectsMap = new Map<Id, SObject>();
        if (!recordIds.isEmpty()) {
            Query query = WhiteSpaceUtils.getQueryFromMapping(mapping).byId(recordIds);
            relatedObjectsMap.putAll(query.run());
        }
        return relatedObjectsMap;
    }
}