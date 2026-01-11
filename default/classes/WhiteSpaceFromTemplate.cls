@SuppressWarnings('PMD.OperationWithLimitsInLoop')
public with sharing virtual class WhiteSpaceFromTemplate extends WhiteSpaceAbstract {
    protected WhiteSpaceTemplateWrapper privateTemplateWrapper;

    @testVisible
    private static WhiteSpaceTypeEnum type = WhiteSpaceTypeEnum.TEMPLATE;

    @testVisible
    protected Map<String, List<SObject>> relatedRecordsMap = new Map<String, List<SObject>>{
        'columns' => new List<SObject>(),
        'rows' => new List<SObject>()
    };

    @testVisible
    protected Map<String, Map<String, Object>> relatedPicklistValuesMap = new Map<String, Map<String, Object>>{
        'columns' => new Map<String, Object>(),
        'rows' => new Map<String, Object>()
    };

    @testVisible
    protected Map<String, Map<String, List<SObject>>> relatedGroupedRecordsMap = new Map<String, Map<String, List<SObject>>>{
        'columns' => new Map<String, List<SObject>>(),
        'rows' => new Map<String, List<SObject>>()
    };

    @AuraEnabled
    public WhiteSpaceTemplateWrapper template {
        get {
            return this.privateTemplateWrapper;
        }
    }

    public WhiteSpaceFromTemplate(White_Space__c whiteSpaceInfo, White_Space_Template__c template) {
        this(whiteSpaceInfo, template, type, null);
    }

    protected WhiteSpaceFromTemplate(
        White_Space__c whiteSpaceInfo,
        White_Space_Template__c template,
        WhiteSpaceTypeEnum type,
        List<White_Space_Amount_Type__c> amountTypes
    ) {
        super(whiteSpaceInfo, type);
        this.privateTemplateWrapper = new WhiteSpaceTemplateWrapper(template);
        if (amountTypes == null) {
            amountTypes = WhiteSpaceAmountTypeSelector.newInstance()
                .selectById(this.privateTemplateWrapper.amountTypeFields.keySet());
        }
        this.amountTypes = amountTypes;
    }

    protected virtual override List<WhiteSpaceCollectionWrapper> getColumns() {
        List<SObject> finalColumns = this.getUpdatedRowOrColumnObjects(
            'columns',
            this.oColumns,
            this.privateTemplateWrapper.columnConfiguration.mapping,
            this.privateWhiteSpaceInfo.AreColumnsFiltered__c
        );
        return this.buildHeaderComponents(
            'columns',
            finalColumns,
            this.privateTemplateWrapper.columnConfiguration.mapping
        );
    }

    protected virtual override List<WhiteSpaceCollectionWrapper> getRows() {
        List<SObject> finalRows = this.getUpdatedRowOrColumnObjects(
            'rows',
            this.oRows,
            this.privateTemplateWrapper.rowConfiguration.mapping,
            this.privateWhiteSpaceInfo.AreRowsFiltered__c
        );
        return this.buildHeaderComponents('rows', finalRows, this.privateTemplateWrapper.rowConfiguration.mapping);
    }

    protected virtual override List<WhiteSpaceCellWrapper> getCells() {
        Set<String> rowObjIds = this.getRelatedObjectIds(this.rows);
        Set<String> columnObjIds = this.getRelatedObjectIds(this.columns);
        List<pqcrush__White_Space_Cell__c> cells = this.getUpdatedCells();
        Map<String, List<String>> conversionMap = this.cellRelationConversionMap();
        Map<String, Map<String, List<SObject>>> fieldDataByRelatedIds = this.getCellDataMap(
            cells,
            rowObjIds,
            columnObjIds,
            null,
            conversionMap
        );

        return new WhiteSpaceCellBuilder(
                this.columns,
                this.rows,
                cells,
                this.privateTemplateWrapper.amountTypeFields.values(),
                this.privateTemplateWrapper.basicFields,
                this.amountTypes,
                this.dataTypes,
                this.relatedCellFields,
                this.relatedObjects,
                fieldDataByRelatedIds,
                conversionMap
            )
            .build();
    }

    protected Map<String, Object> fillRelatedPicklistValuesMapForHeaderType(
        String key,
        WhiteSpaceTemplateMappingWrapper mapping
    ) {
        Map<String, Object> picklistValues = this.getPicklistValues(mapping);
        this.relatedPicklistValuesMap.put(key, picklistValues);
        return picklistValues;
    }

    protected List<SObject> fillRelatedRecordsMapForHeaderType(
        String key,
        WhiteSpaceTemplateMappingWrapper mapping,
        Boolean filterByAccountId
    ) {
        String queryString = WhiteSpaceUtils.getQueryFromMapping(
                mapping,
                filterByAccountId ? this.privateWhiteSpaceInfo.Account_Plan__r.Account__c : null
            )
            .toQueryString();
        List<SObject> records = Database.query(queryString);
        this.relatedRecordsMap.put(key, records);
        return records;
    }

    @testVisible
    protected Map<String, List<SObject>> fillRelatedRecordsListMapForGroupedHeaderType(
        String key,
        WhiteSpaceTemplateMappingWrapper mapping,
        Boolean filterByAccountId
    ) {
        // Query object list from mapping and group results by label field
        List<SObject> records = WhiteSpaceUtils.getResults(
            mapping,
            filterByAccountId ? this.privateWhiteSpaceInfo.Account_Plan__r.Account__c : null
        );
        String fieldName = mapping.labelFieldName;
        Boolean isMultiPicklist = WhiteSpaceUtils.isMultiPicklistMappingType(mapping, fieldName);
        Map<String, List<SObject>> relatedObjectsListMap = new Map<String, List<SObject>>();
        for (SObject rec : records) {
            String fullKey = String.valueOf(rec.get(fieldName));
            List<String> keyList;
            if (isMultiPicklist && fullKey != null) {
                keyList = fullKey.split(';');
            } else {
                keyList = new List<String>{ fullKey };
            }
            for (String relatedKey : keyList) {
                List<SObject> relatedList = relatedObjectsListMap.get(relatedKey);
                if (relatedList == null) {
                    relatedList = new List<SObject>();
                }
                relatedList.add(rec);
                relatedObjectsListMap.put(relatedKey, relatedList);
            }
        }
        this.relatedGroupedRecordsMap.put(key, relatedObjectsListMap);
        return relatedObjectsListMap;
    }

    @testVisible
    protected List<WhiteSpaceCollectionWrapper> buildHeaderComponents(
        String key,
        List<SObject> rowOrColumns,
        WhiteSpaceTemplateMappingWrapper mapping
    ) {
        List<WhiteSpaceCollectionWrapper> wrappers = new List<WhiteSpaceCollectionWrapper>();
        if (WhiteSpaceUtils.isPicklistMappingType(mapping)) {
            Map<String, Object> relatedPicklistValuesMap = this.relatedPicklistValuesMap.get(key);
            for (SObject header : rowOrColumns) {
                String picklistValue = (String) header.get('Related_Object_Id__c');
                String picklistLabel = (String) relatedPicklistValuesMap.get(picklistValue);
                wrappers.add(new WhiteSpaceCollectionWrapper(header, picklistValue, picklistLabel));
            }
        } else if (WhiteSpaceUtils.isGroupMappingType(mapping)) {
            Map<String, List<SObject>> dataMap = this.relatedGroupedRecordsMap.get(key);
            for (SObject header : rowOrColumns) {
                String label = (String) header.get('Related_Object_Id__c');
                List<SObject> objects = dataMap.containsKey(label) ? dataMap.get(label) : new List<SObject>();
                Set<Id> idSet = new Map<Id, SObject>(objects).keySet();
                List<String> objectIdsList = (List<String>) new List<Id>(idSet);
                wrappers.add(new WhiteSpaceCollectionWrapper(header, label, label, objectIdsList));
            }
        } else {
            Map<Id, SObject> relatedRecordsMap = new Map<Id, SObject>(this.relatedRecordsMap.get(key));
            for (SObject header : rowOrColumns) {
                Id recordId = (Id) header.get('Related_Object_Id__c');
                wrappers.add(new WhiteSpaceCollectionWrapper(header, mapping, relatedRecordsMap.get(recordId)));
            }
        }
        return wrappers;
    }

    protected Map<String, String> getPicklistValues(WhiteSpaceTemplateMappingWrapper mapping) {
        if (!mapping.description.isAccessible()) {
            throw Application.createAuraHandledException(System.Label.error_access_template_objects);
        }

        Map<String, String> dataMap = new Map<String, String>();
        List<SelectOption> picklistOptions = UtilityForSObject.getPicklistSelectOptions(
            mapping.objectName,
            mapping.valueFieldName
        );
        for (SelectOption option : picklistOptions) {
            dataMap.put(option.getValue(), option.getLabel());
        }
        return dataMap;
    }

    protected Map<String, Map<String, List<SObject>>> getCellDataMap(
        List<pqcrush__White_Space_Cell__c> cells,
        Set<String> rowObjIds,
        Set<String> columnObjIds,
        Set<String> selectFields,
        Map<String, List<String>> relationConversionMap
    ) {
        if (relationConversionMap == null) {
            relationConversionMap = new Map<String, List<String>>();
        }
        Set<String> cellIds = new Set<String>(
            (List<String>) new List<Id>(new Map<Id, White_Space_Cell__c>(cells).keySet())
        );
        Id cellFilterLookupId = this.privateWhiteSpaceInfo.AreCellsFiltered__c
            ? this.privateWhiteSpaceInfo.Account_Plan__r.Account__c
            : null;
        Boolean filterUnrelatedCells = this.privateWhiteSpaceInfo.AreUnrelatedCellsFiltered__c;
        return WhiteSpaceUtils.getCellDataMap(
            cellIds,
            rowObjIds,
            columnObjIds,
            cellFilterLookupId,
            filterUnrelatedCells,
            this.relatedCellFields,
            this.privateTemplateWrapper.amountTypeFields.values(),
            this.privateTemplateWrapper.basicFields,
            selectFields,
            relationConversionMap
        );
    }

    protected List<SObject> updatePicklistHeaders(
        List<SObject> rowOrColumns,
        Map<String, Object> allMatchingRecordsMap
    ) {
        Set<String> recordsToCreateIdSet = new Set<String>(allMatchingRecordsMap.keySet());
        List<SObject> finalHeaderList = new List<SObject>();
        List<SObject> headersToCreate = new List<SObject>();

        for (SObject header : rowOrColumns) {
            String key = (String) header.get('Related_Object_Id__c');
            if (allMatchingRecordsMap.containsKey(key)) {
                recordsToCreateIdSet.remove(key);
                finalHeaderList.add(header);
            }
        }

        Schema.SObjectType targetType = rowOrColumns.getSObjectType();
        // loop through records and identify columns that need to be created or removed
        for (String key : recordsToCreateIdSet) {
            Object label = allMatchingRecordsMap.get(key);
            SObject newHeader = targetType.newSObject();
            newHeader.put('White_Space__c', this.privateWhiteSpaceInfo.id);
            newHeader.put('Related_Object_Id__c', key);
            newHeader.put('Name', String.valueOf(label));
            headersToCreate.add(newHeader);
        }

        if (targetType == White_Space_Row__c.getSObjectType()) {
            WhiteSpaceService.createWhiteSpaceRows(headersToCreate);
        } else if (targetType == White_Space_Column__c.getSObjectType()) {
            WhiteSpaceService.createWhiteSpaceColumns(headersToCreate);
        }
        finalHeaderList.addAll(headersToCreate);
        return finalHeaderList;
    }

    protected List<SObject> updateHeaders(List<SObject> rowOrColumns, Map<Id, SObject> allMatchingRecordsMap) {
        Set<Id> recordsToCreateIdSet = new Set<Id>(allMatchingRecordsMap.keySet());
        List<SObject> finalHeaderList = new List<SObject>();
        List<SObject> headersToCreate = new List<SObject>();

        for (SObject header : rowOrColumns) {
            Id recordId = header.get('Related_Object_Id__c') instanceof Id
                ? (Id) header.get('Related_Object_Id__c')
                : null;
            if (allMatchingRecordsMap.containsKey(recordId)) {
                recordsToCreateIdSet.remove(recordId);
                finalHeaderList.add(header);
            }
        }

        Schema.SObjectType targetType = rowOrColumns.getSObjectType();
        // loop through records and identify columns that need to be created or removed
        for (Id recordId : recordsToCreateIdSet) {
            SObject newHeader = targetType.newSObject();
            newHeader.put('White_Space__c', this.privateWhiteSpaceInfo.id);
            newHeader.put('Related_Object_Id__c', String.valueOf(recordId));
            headersToCreate.add(newHeader);
        }

        if (targetType == White_Space_Row__c.getSObjectType()) {
            WhiteSpaceService.createWhiteSpaceRows(headersToCreate);
        } else if (targetType == White_Space_Column__c.getSObjectType()) {
            WhiteSpaceService.createWhiteSpaceColumns(headersToCreate);
        }
        finalHeaderList.addAll(headersToCreate);
        return finalHeaderList;
    }

    @testVisible
    protected List<SObject> updateGroupedHeaders(
        List<SObject> rowOrColumns,
        Map<String, List<SObject>> allMatchingRecordsMap
    ) {
        Set<String> recordsToCreateIdSet = new Set<String>(allMatchingRecordsMap.keySet());
        List<SObject> finalHeaderList = new List<SObject>();
        List<SObject> headersToCreate = new List<SObject>();

        for (SObject header : rowOrColumns) {
            String key = (String) header.get('Related_Object_Id__c');
            if (allMatchingRecordsMap.containsKey(key)) {
                recordsToCreateIdSet.remove(key);
                finalHeaderList.add(header);
            }
        }

        Schema.SObjectType targetType = rowOrColumns.getSObjectType();
        // loop through records and identify columns that need to be created or removed
        for (String key : recordsToCreateIdSet) {
            SObject newHeader = targetType.newSObject();
            newHeader.put('White_Space__c', this.privateWhiteSpaceInfo.id);
            newHeader.put('Related_Object_Id__c', key);
            newHeader.put('Name', key);
            headersToCreate.add(newHeader);
        }

        if (targetType == White_Space_Row__c.getSObjectType()) {
            WhiteSpaceService.createWhiteSpaceRows(headersToCreate);
        } else if (targetType == White_Space_Column__c.getSObjectType()) {
            WhiteSpaceService.createWhiteSpaceColumns(headersToCreate);
        }
        finalHeaderList.addAll(headersToCreate);
        return finalHeaderList;
    }

    protected List<SObject> orderRowColumnsByObjects(
        List<SObject> rowsOrColumnsToOrder,
        List<SObject> objsForOrder,
        WhiteSpaceTemplateMappingWrapper mapping
    ) {
        Map<String, SObject> rowsOrColumnsToSortByObjId = (Map<String, SObject>) Collection.mapBy(
            String.class,
            rowsOrColumnsToOrder,
            'pqcrush__Related_Object_Id__c'
        );
        List<SObject> rowsOrColumns = new List<SObject>();
        Integer index = 0;
        objsForOrder = orderObjectsForMapping(objsForOrder, mapping);
        for (SObject obj : objsForOrder) {
            String key = obj.Id;
            SObject rowOrColumn = rowsOrColumnsToSortByObjId.get(key);
            if (rowOrColumn != null) {
                rowOrColumn.put('pqcrush__Order__c', index);
                index++;
                rowsOrColumns.add(rowOrColumn);
            }
        }
        return rowsOrColumns;
    }

    protected List<SObject> orderGroupedHeaders(
        List<SObject> rowsOrColumnsToOrder,
        WhiteSpaceTemplateMappingWrapper mapping,
        Set<String> values
    ) {
        if (rowsOrColumnsToOrder == null || rowsOrColumnsToOrder.size() == 0) {
            return new List<SObject>();
        }
        Map<String, SObject> rowsOrColumnsToSortByGroupedName = (Map<String, SObject>) Collection.mapBy(
            String.class,
            rowsOrColumnsToOrder,
            'pqcrush__Related_Object_Id__c'
        );
        List<String> orderedValues = UtilityForSObject.getOrderedPicklistValues(
            mapping.objectName,
            mapping.labelFieldName
        );
        if (orderedValues == null || orderedValues.size() == 0) {
            orderedValues = new List<String>(values);
            orderedValues.sort();
        }
        List<SObject> rowsOrColumns = new List<SObject>();
        if (rowsOrColumnsToSortByGroupedName.containsKey(null)) {
            SObject rowOrColumn = rowsOrColumnsToSortByGroupedName.get(null);
            rowOrColumn.put('pqcrush__Order__c', -1);
            rowsOrColumns.add(rowOrColumn);
        }
        Integer index = 0;
        for (String key : orderedValues) {
            if (key == null) {
                continue;
            }
            SObject rowOrColumn = rowsOrColumnsToSortByGroupedName.get(key);
            if (rowOrColumn != null) {
                rowOrColumn.put('pqcrush__Order__c', index);
                index++;
                rowsOrColumns.add(rowOrColumn);
            }
        }
        return rowsOrColumns;
    }

    protected Map<String, List<String>> cellRelationConversionMap() {
        Map<String, List<String>> cellRelationConversionMap = new Map<String, List<String>>();
        Map<String, List<SObject>> recordMap = new Map<String, List<SObject>>(
            this.relatedGroupedRecordsMap.get('columns')
        );
        recordMap.putAll(this.relatedGroupedRecordsMap.get('rows'));
        for (String key : recordMap.keySet()) {
            List<SObject> records = recordMap.get(key);
            for (SObject record : records) {
                //For a given recordId the map gives the corresponding row/column value
                List<String> keyList = cellRelationConversionMap.containsKey(record.Id)
                    ? cellRelationConversionMap.get(record.Id)
                    : new List<String>();
                keyList.add(key);
                cellRelationConversionMap.put(record.Id, keyList);
            }
        }
        return cellRelationConversionMap;
    }

    private static List<SObject> orderObjectsForMapping(
        List<SObject> objsForOrder,
        WhiteSpaceTemplateMappingWrapper mapping
    ) {
        if (String.isEmpty(mapping.parentIdFieldName)) {
            //They were ordered when queried and no further ordering is needed
            return objsForOrder;
        }
        Map<Id, List<SObject>> groupedObjects = new Map<Id, List<SObject>>();
        Set<Id> idSet = new Map<Id, SObject>(objsForOrder).keySet();
        for (SObject obj : objsForOrder) {
            Object parentIdValue = obj.get(mapping.parentIdFieldName);
            Id parentId = null;
            if (parentIdValue != null) {
                if (parentIdValue instanceof Id) {
                    parentId = (Id) parentIdValue;
                } else if (parentIdValue instanceof String) {
                    parentId = Id.valueOf((String) parentIdValue);
                }
                if (!idSet.contains(parentId)) {
                    parentId = null;
                }
            }
            if (groupedObjects.get(parentId) == null) {
                groupedObjects.put(parentId, new List<SObject>());
            }
            List<Object> objGroup = groupedObjects.get(parentId);
            objGroup.add(obj);
        }
        List<SObject> sortedList = new List<SObject>();
        sortParentChildRecursively(groupedObjects.get(null), groupedObjects, new Set<Id>(), sortedList);
        return sortedList;
    }

    private static void sortParentChildRecursively(
        List<SObject> currentGroup,
        Map<Id, List<SObject>> groupedObjects,
        Set<Id> currentPathIds,
        List<SObject> sortedList
    ) {
        if (currentGroup == null || currentGroup.size() == 0) {
            return;
        }
        for (SObject currentObj : currentGroup) {
            if (currentPathIds.contains(currentObj.Id)) {
                continue;
            }
            Set<Id> thisPath = new Set<Id>(currentPathIds);
            thisPath.add(currentObj.Id);
            sortedList.add(currentObj);
            sortParentChildRecursively(groupedObjects.get(currentObj.Id), groupedObjects, thisPath, sortedList);
        }
    }

    private List<SObject> getUpdatedRowOrColumnObjects(
        String key,
        List<SObject> rowOrColumns,
        WhiteSpaceTemplateMappingWrapper mapping,
        Boolean filterByAccountId
    ) {
        List<SObject> finalHeaderList = new List<SObject>();
        if (WhiteSpaceUtils.isPicklistMappingType(mapping)) {
            Map<String, Object> dataMap = this.fillRelatedPicklistValuesMapForHeaderType(key, mapping);
            finalHeaderList = updatePicklistHeaders(rowOrColumns, dataMap);
        } else if (WhiteSpaceUtils.isGroupMappingType(mapping)) {
            Map<String, List<SObject>> dataMap = this.fillRelatedRecordsListMapForGroupedHeaderType(
                key,
                mapping,
                filterByAccountId
            );
            finalHeaderList = updateGroupedHeaders(rowOrColumns, dataMap);
            finalHeaderList = orderGroupedHeaders(finalHeaderList, mapping, dataMap.keySet());
        } else {
            Map<Id, SObject> dataMap = new Map<Id, SObject>(
                this.fillRelatedRecordsMapForHeaderType(key, mapping, filterByAccountId)
            );
            finalHeaderList = updateHeaders(rowOrColumns, dataMap);
            finalHeaderList = this.orderRowColumnsByObjects(finalHeaderList, dataMap.values(), mapping);
        }
        return finalHeaderList;
    }

    private Map<Id, SObject> getDataMap(WhiteSpaceTemplateMappingWrapper mapping, Id lookupId) {
        if (!mapping.description.isAccessible()) {
            throw Application.createAuraHandledException(System.Label.error_access_template_objects);
        }
        return new Map<Id, SObject>(WhiteSpaceUtils.getResults(mapping, lookupId));
    }

    private Set<String> getRelatedObjectIds(List<WhiteSpaceCollectionWrapper> collectionWrappers) {
        Set<String> relatedObjIds = new Set<String>();
        for (WhiteSpaceCollectionWrapper wrapper : collectionWrappers) {
            if (wrapper.groupedRelatedRecordIds != null && wrapper.groupedRelatedRecordIds.size() > 0) {
                relatedObjIds.addAll(wrapper.groupedRelatedRecordIds);
            } else {
                relatedObjIds.add(wrapper.relatedObjectId);
            }
        }
        return relatedObjIds;
    }

    private Map<String, String> cellProductConversionMap() {
        Map<String, String> cellProductConversionMap = new Map<String, String>();
        Map<String, List<SObject>> recordMap = new Map<String, List<SObject>>(
            this.relatedGroupedRecordsMap.get('columns')
        );
        recordMap.putAll(this.relatedGroupedRecordsMap.get('rows'));
        for (String key : recordMap.keySet()) {
            List<SObject> records = recordMap.get(key);
            for (SObject record : records) {
                cellProductConversionMap.put(key, record.Id);
            }
        }
        return cellProductConversionMap;
    }
}