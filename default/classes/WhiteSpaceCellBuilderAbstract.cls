public with sharing abstract class WhiteSpaceCellBuilderAbstract {
    protected List<WhiteSpaceCollectionWrapper> columns = new List<WhiteSpaceCollectionWrapper>();
    protected List<WhiteSpaceCollectionWrapper> rows = new List<WhiteSpaceCollectionWrapper>();
    protected List<White_Space_Cell__c> cells = new List<White_Space_Cell__c>();
    protected List<White_Space_Amount_Type__c> amountTypes = new List<White_Space_Amount_Type__c>();
    protected List<WS_Data_Type__c> dataTypes = new List<WS_Data_Type__c>();
    protected List<WhiteSpaceTemplateCellFieldWrapper> relatedFields = new List<WhiteSpaceTemplateCellFieldWrapper>();
    protected List<WSRelatedObjectWrapper> relatedObjects = new List<WSRelatedObjectWrapper>();
    protected Map<String, Map<String, List<SObject>>> fieldDataByRelatedIds = new Map<String, Map<String, List<SObject>>>();
    @testVisible
    protected Map<String, List<White_Space_Cell__c>> cellMap;

    protected WhiteSpaceCellBuilderAbstract(
        List<WhiteSpaceCollectionWrapper> columns,
        List<WhiteSpaceCollectionWrapper> rows,
        List<White_Space_Cell__c> cells,
        List<White_Space_Amount_Type__c> amountTypes,
        List<WS_Data_Type__c> dataTypes,
        List<WhiteSpaceTemplateCellFieldWrapper> relatedFields,
        List<WSRelatedObjectWrapper> relatedObjects,
        Map<String, Map<String, List<SObject>>> fieldDataByRelatedIds
    ) {
        this.columns = columns;
        this.rows = rows;
        this.cells = cells;
        this.cellMap = mapCellsByRowAndColumnId(cells);
        this.amountTypes = amountTypes;
        this.dataTypes = dataTypes;
        this.relatedFields = relatedFields;
        this.relatedObjects = relatedObjects;
        this.fieldDataByRelatedIds = fieldDataByRelatedIds;
    }

    protected abstract Map<String, List<WhiteSpaceTileWrapper>> populateDisplayTileMap();

    public List<WhiteSpaceCellWrapper> build() {
        List<WhiteSpaceCellWrapper> populatedCells = new List<WhiteSpaceCellWrapper>();

        Map<String, List<WhiteSpaceTileWrapper>> tilesByRowColumnIds = populateDisplayTileMap();

        for (WhiteSpaceCollectionWrapper column : this.columns) {
            for (WhiteSpaceCollectionWrapper row : this.rows) {
                String key = getKey(row.id, column.id);
                List<WhiteSpaceTileWrapper> tiles = new List<WhiteSpaceTileWrapper>();
                if (tilesByRowColumnIds.containsKey(key)) {
                    tiles = tilesByRowColumnIds.get(key);
                }
                WhiteSpaceCellWrapper cellWrapper = new WhiteSpaceCellWrapper(column.id, row.id, tiles);
                populatedCells.add(cellWrapper);
            }
        }
        return populatedCells;
    }

    private String getKey(String rowId, String colId) {
        return rowId + ' - ' + colId;
    }

    private Map<String, List<White_Space_Cell__c>> mapCellsByRowAndColumnId(List<White_Space_Cell__c> cells) {
        Map<String, List<White_Space_Cell__c>> cellMap = new Map<String, List<White_Space_Cell__c>>();
        for (White_Space_Cell__c cell : cells) {
            String cellKey = cell.White_Space_Row__c + ' - ' + cell.White_Space_Column__c;
            List<White_Space_Cell__c> cellList = cellMap.get(cellKey);
            if (cellList == null) {
                cellList = new List<SObject>();
            }
            cellList.add(cell);
            cellMap.put(cellKey, cellList);
        }
        return cellMap;
    }
}