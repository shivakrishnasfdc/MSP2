public with sharing class WhiteSpaceCellBuilderLegacy extends WhiteSpaceCellBuilderAbstract {
    public WhiteSpaceCellBuilderLegacy(
        List<WhiteSpaceCollectionWrapper> columns,
        List<WhiteSpaceCollectionWrapper> rows,
        List<White_Space_Cell__c> cells,
        List<White_Space_Amount_Type__c> amountTypes,
        List<WS_Data_Type__c> dataTypes,
        List<WhiteSpaceTemplateCellFieldWrapper> relatedFields,
        List<WSRelatedObjectWrapper> relatedObjects,
        Map<String, Map<String, List<SObject>>> fieldDataByRelatedIds
    ) {
        super(columns, rows, cells, amountTypes, dataTypes, relatedFields, relatedObjects, fieldDataByRelatedIds);
    }

    @testVisible
    protected override Map<String, List<WhiteSpaceTileWrapper>> populateDisplayTileMap() {
        Map<String, List<WhiteSpaceTileWrapper>> tilesByRowColumnIds = new Map<String, List<WhiteSpaceTileWrapper>>();
        for (String key : cellMap.keySet()) {
            List<White_Space_Cell__c> cells = cellMap.get(key);
            List<WhiteSpaceTileWrapper> tiles = new List<WhiteSpaceTileWrapper>();
            for (White_Space_Cell__c cell : cells) {
                WhiteSpaceTileWrapper newTile = WhiteSpaceTileWrapper.createFor(
                    cell,
                    this.amountTypes,
                    this.dataTypes,
                    this.fieldDataByRelatedIds.get(cell.id),
                    cell.White_Space_Amount_Type_Associations__r,
                    this.relatedFields,
                    this.relatedObjects
                );
                tiles.add(newTile);
            }
            tilesByRowColumnIds.put(key, tiles);
        }
        return tilesByRowColumnIds;
    }
}