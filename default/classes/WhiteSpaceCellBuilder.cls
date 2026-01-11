public with sharing class WhiteSpaceCellBuilder extends WhiteSpaceCellBuilderAbstract {
    private List<WhiteSpaceTemplateCellFieldWrapper> amountTypeFields;
    private List<WhiteSpaceTemplateCellFieldWrapper> basicFields;

    private Map<Id, WhiteSpaceCollectionWrapper> rowMap;
    private Map<Id, WhiteSpaceCollectionWrapper> columnMap;
    protected Map<String, List<String>> conversionMap;

    public WhiteSpaceCellBuilder(
        List<WhiteSpaceCollectionWrapper> columns,
        List<WhiteSpaceCollectionWrapper> rows,
        List<White_Space_Cell__c> cells,
        List<WhiteSpaceTemplateCellFieldWrapper> amountTypeFields,
        List<WhiteSpaceTemplateCellFieldWrapper> basicFields,
        List<White_Space_Amount_Type__c> amountTypes,
        List<WS_Data_Type__c> dataTypes,
        List<WhiteSpaceTemplateCellFieldWrapper> relatedFields,
        List<WSRelatedObjectWrapper> relatedObjects,
        Map<String, Map<String, List<SObject>>> fieldDataByRelatedIds
    ) {
        this(
            columns,
            rows,
            cells,
            amountTypeFields,
            basicFields,
            amountTypes,
            dataTypes,
            relatedFields,
            relatedObjects,
            fieldDataByRelatedIds,
            new Map<String, List<String>>()
        );
    }

    public WhiteSpaceCellBuilder(
        List<WhiteSpaceCollectionWrapper> columns,
        List<WhiteSpaceCollectionWrapper> rows,
        List<White_Space_Cell__c> cells,
        List<WhiteSpaceTemplateCellFieldWrapper> amountTypeFields,
        List<WhiteSpaceTemplateCellFieldWrapper> basicFields,
        List<White_Space_Amount_Type__c> amountTypes,
        List<WS_Data_Type__c> dataTypes,
        List<WhiteSpaceTemplateCellFieldWrapper> relatedFields,
        List<WSRelatedObjectWrapper> relatedObjects,
        Map<String, Map<String, List<SObject>>> fieldDataByRelatedIds,
        Map<String, List<String>> conversionMap
    ) {
        super(columns, rows, cells, amountTypes, dataTypes, relatedFields, relatedObjects, fieldDataByRelatedIds);
        this.amountTypeFields = amountTypeFields != null
            ? amountTypeFields
            : new List<WhiteSpaceTemplateCellFieldWrapper>();
        this.basicFields = basicFields != null ? basicFields : new List<WhiteSpaceTemplateCellFieldWrapper>();
        this.rowMap = WhiteSpaceAbstract.mapForCollectionWrapperList(this.rows);
        this.columnMap = WhiteSpaceAbstract.mapForCollectionWrapperList(this.columns);
        this.conversionMap = conversionMap;
    }

    @testVisible
    protected override Map<String, List<WhiteSpaceTileWrapper>> populateDisplayTileMap() {
        Map<String, List<WhiteSpaceTileWrapper>> tilesByRowColumnIds = new Map<String, List<WhiteSpaceTileWrapper>>();
        for (String key : cellMap.keySet()) {
            List<White_Space_Cell__c> cells = cellMap.get(key);
            List<WhiteSpaceTileWrapper> tiles = new List<WhiteSpaceTileWrapper>();
            for (White_Space_Cell__c cell : cells) {
                WhiteSpaceCollectionWrapper rowWrapper = rowMap.get(cell.White_Space_Row__c);
                WhiteSpaceCollectionWrapper columnWrapper = columnMap.get(cell.White_Space_Column__c);
                Set<String> productIdSet = getProductIdSetForRowAndColumn(rowWrapper, columnWrapper);
                WhiteSpaceTileWrapper newTile = WhiteSpaceTileWrapper.createFor(
                    cell,
                    this.amountTypes,
                    this.dataTypes,
                    getDataForCell(cell),
                    this.amountTypeFields,
                    this.basicFields,
                    this.relatedFields,
                    this.relatedObjects,
                    productIdSet
                );
                tiles.add(newTile);
            }
            tilesByRowColumnIds.put(key, tiles);
        }
        return tilesByRowColumnIds;
    }

    private Map<String, List<SObject>> getDataForCell(White_Space_Cell__c cell) {
        WhiteSpaceCollectionWrapper rowWrapper = rowMap.get(cell.White_Space_Row__c);
        WhiteSpaceCollectionWrapper columnWrapper = columnMap.get(cell.White_Space_Column__c);
        String rowColumnKey = rowWrapper?.relatedObjectId + ' - ' + columnWrapper?.relatedObjectId;
        Map<String, List<SObject>> relatedObjectMap = new Map<String, List<SObject>>();
        if (this.fieldDataByRelatedIds.containsKey(rowColumnKey)) {
            relatedObjectMap.putAll(this.fieldDataByRelatedIds.get(rowColumnKey));
        }
        if (this.fieldDataByRelatedIds.containsKey(cell.Id)) {
            relatedObjectMap.putAll(this.fieldDataByRelatedIds.get(cell.Id));
        }
        return relatedObjectMap;
    }

    private Set<String> getProductIdSetForRowAndColumn(
        WhiteSpaceCollectionWrapper rowWrapper,
        WhiteSpaceCollectionWrapper columnWrapper
    ) {
        Set<String> allIdSet = new Set<String>();
        if (rowWrapper?.relatedObjectId != null) {
            allIdSet.add(rowWrapper.relatedObjectId);
        }
        if (rowWrapper?.groupedRelatedRecordIds != null) {
            allIdSet.addAll(rowWrapper.groupedRelatedRecordIds);
        }
        if (columnWrapper?.relatedObjectId != null) {
            allIdSet.add(columnWrapper.relatedObjectId);
        }
        if (columnWrapper?.groupedRelatedRecordIds != null) {
            allIdSet.addAll(columnWrapper.groupedRelatedRecordIds);
        }
        Set<String> productIdSet = new Set<String>();
        for (String idToCheck : allIdSet) {
            if (idToCheck instanceof Id && Id.valueOf(idToCheck).getSobjectType() == Product2.getSObjectType()) {
                productIdSet.add(idToCheck);
            }
        }
        return productIdSet;
    }
}