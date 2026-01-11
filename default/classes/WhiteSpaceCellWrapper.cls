@SuppressWarnings('PMD.EmptyStatementBlock')
public with sharing class WhiteSpaceCellWrapper {
    @AuraEnabled
    public List<WhiteSpaceTileWrapper> tiles = new List<WhiteSpaceTileWrapper>();
    @AuraEnabled
    public Id columnId { get; set; }
    @AuraEnabled
    public Id rowId { get; set; }

    public WhiteSpaceCellWrapper() {
    }

    public WhiteSpaceCellWrapper(Id columnId, Id rowId, List<WhiteSpaceTileWrapper> tiles) {
        this.columnId = columnId;
        this.rowId = rowId;
        for (WhiteSpaceTileWrapper tile : tiles) {
            if (tile != null) {
                this.tiles.add(tile);
            }
        }
    }
}