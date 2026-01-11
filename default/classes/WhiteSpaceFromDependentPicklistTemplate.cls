@SuppressWarnings('PMD.NcssMethodCount,PMD.CyclomaticComplexity')
public with sharing class WhiteSpaceFromDependentPicklistTemplate extends WhiteSpaceFromTemplate {
    private List<pqcrush__White_Space_Cell__c> updatedCells = new List<pqcrush__White_Space_Cell__c>();
    private Map<String, Map<String, List<SObject>>> fieldDataByRowAndColumnRelatedIds = new Map<String, Map<String, List<SObject>>>();
    private Map<String, Map<Object, List<PicklistService.PicklistWrapper>>> controllingFieldToDependentPicklistMap = new Map<String, Map<Object, List<PicklistService.PicklistWrapper>>>();
    private Map<String, Set<PicklistService.PicklistWrapper>> finalControllingFieldToPicklistEntriesMap = new Map<String, Set<PicklistService.PicklistWrapper>>();

    public WhiteSpaceFromDependentPicklistTemplate(White_Space__c whiteSpaceInfo, White_Space_Template__c template) {
        super(whiteSpaceInfo, template, WhiteSpaceTypeEnum.TEMPLATE, null);
        this.populateData();
    }

    protected override List<WhiteSpaceCollectionWrapper> getColumns() {
        List<WhiteSpaceCollectionWrapper> wrappers = new List<WhiteSpaceCollectionWrapper>();
        List<SObject> finalColumns = this.getUpdatedRowOrColumnObjects(
            'columns',
            this.oColumns,
            this.privateTemplateWrapper.columnConfiguration.mapping
        );
        wrappers = this.buildHeaderComponents(
            'columns',
            finalColumns,
            this.privateTemplateWrapper.columnConfiguration.mapping
        );
        return wrappers;
    }

    protected override List<WhiteSpaceCollectionWrapper> getRows() {
        List<WhiteSpaceCollectionWrapper> wrappers = new List<WhiteSpaceCollectionWrapper>();
        List<SObject> finalRows = this.getUpdatedRowOrColumnObjects(
            'rows',
            this.oRows,
            this.privateTemplateWrapper.rowConfiguration.mapping
        );
        wrappers = this.buildHeaderComponents('rows', finalRows, this.privateTemplateWrapper.rowConfiguration.mapping);
        return wrappers;
    }

    protected override List<WhiteSpaceCellWrapper> getCells() {
        this.updatedCells = this.getUpdatedCells();
        Map<String, List<String>> conversionMap = this.cellRelationConversionMap();
        return new WhiteSpaceCellBuilder(
                this.columns,
                this.rows,
                this.updatedCells,
                this.privateTemplateWrapper.amountTypeFields.values(),
                this.privateTemplateWrapper.basicFields,
                this.amountTypes,
                this.dataTypes,
                this.relatedCellFields,
                this.relatedObjects,
                this.fieldDataByRowAndColumnRelatedIds,
                conversionMap
            )
            .build();
    }

    private static String getControllingFieldName(WhiteSpaceTemplateWrapper.HeaderConfiguration configuration) {
        return getControllingFieldName(configuration.mapping.objectName, configuration.mapping.valueFieldName);
    }

    private static String getControllingFieldName(String objectName, String valueFieldName) {
        return getControllingFieldName(getFieldToken(objectName, valueFieldName));
    }

    private static String getControllingFieldName(Schema.SObjectField fieldToken) {
        return fieldToken.getDescribe()?.getController()?.getDescribe()?.getName();
    }

    private static Schema.SObjectField getFieldToken(String objectName, String fieldName) {
        return UTIL_Describe.getFieldDescribe(objectName, fieldName).getSObjectField();
    }

    private static Set<String> toStringSet(List<SObject> records) {
        Set<String> idStringSet = new Set<String>();
        for (SObject record : records) {
            idStringSet.add((record.Id));
        }
        return idStringSet;
    }

    private List<SObject> getUpdatedRowOrColumnObjects(
        String key,
        List<SObject> rowOrColumns,
        WhiteSpaceTemplateMappingWrapper mapping
    ) {
        List<SObject> finalHeaderList = new List<SObject>();
        if (WhiteSpaceUtils.isPicklistMappingType(mapping)) {
            Map<String, Object> dataMap = this.relatedPicklistValuesMap.get(key);
            finalHeaderList = this.updatePicklistHeaders(rowOrColumns, dataMap);
        } else if (WhiteSpaceUtils.isGroupMappingType(mapping)) {
            Map<String, List<SObject>> dataMap = this.relatedGroupedRecordsMap.get(key);
            finalHeaderList = updateGroupedHeaders(rowOrColumns, dataMap);
        } else {
            Map<Id, SObject> dataMap = new Map<Id, SObject>(this.relatedRecordsMap.get(key));
            finalHeaderList = this.updateHeaders(rowOrColumns, dataMap);
            finalHeaderList = this.orderRowColumnsByObjects(
                finalHeaderList,
                dataMap.values(),
                this.privateTemplateWrapper.columnConfiguration.mapping
            );
        }
        return finalHeaderList;
    }

    private void fillControllingFieldToDependendPicklistMapForConfiguration(WhiteSpaceTemplateMappingWrapper mapping) {
        Schema.SObjectField dependentField = getFieldToken(mapping.objectName, mapping.valueFieldName);
        String controllingFieldName = getControllingFieldName(dependentField);
        Map<Object, List<PicklistService.PicklistWrapper>> dependentPicklistValues = PicklistService.getDependentPicklistValues(
            dependentField
        );
        this.controllingFieldToDependentPicklistMap.put(controllingFieldName, dependentPicklistValues);
    }

    private void fillDataForHeaderType(
        String key,
        Boolean hasDependentPicklist,
        WhiteSpaceTemplateMappingWrapper mapping,
        Boolean filterByAccountId
    ) {
        if (WhiteSpaceUtils.isPicklistMappingType(mapping)) {
            if (hasDependentPicklist) {
                this.fillControllingFieldToDependendPicklistMapForConfiguration(mapping);
            } else {
                this.fillRelatedPicklistValuesMapForHeaderType(key, mapping);
            }
        } else if (WhiteSpaceUtils.isGroupMappingType(mapping)) {
            this.fillRelatedRecordsListMapForGroupedHeaderType(key, mapping, filterByAccountId);
        } else {
            this.fillRelatedRecordsMapForHeaderType(key, mapping, filterByAccountId);
        }
    }

    private void populateData() {
        this.fillDataForHeaderType(
            'columns',
            this.privateTemplateWrapper.hasDependentPicklistColumns,
            this.privateTemplateWrapper.columnConfiguration.mapping,
            this.privateWhiteSpaceInfo.AreColumnsFiltered__c
        );

        this.fillDataForHeaderType(
            'rows',
            this.privateTemplateWrapper.hasDependentPicklistRows,
            this.privateTemplateWrapper.rowConfiguration.mapping,
            this.privateWhiteSpaceInfo.AreRowsFiltered__c
        );

        Set<String> rowObjIds = getRelatedRecordIdSetForKey('rows');
        Set<String> columnObjIds = getRelatedRecordIdSetForKey('columns');
        Set<String> controllingFields = this.controllingFieldToDependentPicklistMap.keySet();
        this.updatedCells = this.getUpdatedCells();

        Map<String, List<String>> conversionMap = this.cellRelationConversionMap();
        Map<String, Map<String, List<SObject>>> fieldDataByRowAndColumnRelatedIds = this.getCellDataMap(
            this.updatedCells,
            rowObjIds,
            columnObjIds,
            controllingFields,
            conversionMap
        );
        this.fieldDataByRowAndColumnRelatedIds = fieldDataByRowAndColumnRelatedIds;

        Map<String, Set<PicklistService.PicklistWrapper>> finalControllingFieldToPicklistEntriesMap = new Map<String, Set<PicklistService.PicklistWrapper>>();

        for (Map<String, List<SObject>> item : this.fieldDataByRowAndColumnRelatedIds.values()) {
            for (List<SObject> records : item.values()) {
                for (SObject record : records) {
                    for (String controllingFieldName : this.controllingFieldToDependentPicklistMap.keySet()) {
                        String controllingFieldValue = (String) record.get(controllingFieldName);
                        Set<PicklistService.PicklistWrapper> picklistEntriesToAdd = new Set<PicklistService.PicklistWrapper>(
                            this.controllingFieldToDependentPicklistMap.get(controllingFieldName)
                                ?.get(controllingFieldValue)
                        );

                        if (finalControllingFieldToPicklistEntriesMap.containsKey(controllingFieldName)) {
                            Set<PicklistService.PicklistWrapper> existingPicklistValues = finalControllingFieldToPicklistEntriesMap.get(
                                controllingFieldName
                            );
                            existingPicklistValues.addAll(picklistEntriesToAdd);
                            finalControllingFieldToPicklistEntriesMap.put(controllingFieldName, existingPicklistValues);
                        } else {
                            finalControllingFieldToPicklistEntriesMap.put(controllingFieldName, picklistEntriesToAdd);
                        }
                    }
                }
            }
        }

        this.finalControllingFieldToPicklistEntriesMap = finalControllingFieldToPicklistEntriesMap;

        if (this.privateTemplateWrapper.hasDependentPicklistColumns) {
            Set<PicklistService.PicklistWrapper> picklistValues = this.finalControllingFieldToPicklistEntriesMap.get(
                getControllingFieldName(this.privateTemplateWrapper.columnConfiguration)
            );
            Map<String, Object> dataMap = new Map<String, Object>();
            if (picklistValues != null && !picklistValues.isEmpty()) {
                for (PicklistService.PicklistWrapper picklistEntry : picklistValues) {
                    dataMap.put(picklistEntry.value, picklistEntry.label);
                }
            }
            this.relatedPicklistValuesMap.put('columns', dataMap);
        }

        if (this.privateTemplateWrapper.hasDependentPicklistRows) {
            Set<PicklistService.PicklistWrapper> picklistValues = this.finalControllingFieldToPicklistEntriesMap.get(
                getControllingFieldName(this.privateTemplateWrapper.rowConfiguration)
            );
            Map<String, Object> dataMap = new Map<String, Object>();
            if (picklistValues != null && !picklistValues.isEmpty()) {
                for (PicklistService.PicklistWrapper picklistEntry : picklistValues) {
                    dataMap.put(picklistEntry.value, picklistEntry.label);
                }
            }
            this.relatedPicklistValuesMap.put('rows', dataMap);
        }
    }

    private Set<String> getRelatedRecordIdSetForKey(String key) {
        List<SObject> objList = new List<SObject>();
        if (this.relatedRecordsMap?.get(key) != null) {
            objList.addAll(this.relatedRecordsMap.get(key));
        }
        if (this.relatedGroupedRecordsMap?.get(key) != null) {
            Map<String, List<SObject>> groupedRecords = this.relatedGroupedRecordsMap.get(key);
            for (String groupName : groupedRecords.keySet()) {
                objList.addAll(groupedRecords.get(groupName));
            }
        }
        return toStringSet(objList);
    }
}