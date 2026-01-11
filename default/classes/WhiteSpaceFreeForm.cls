public with sharing class WhiteSpaceFreeForm extends WhiteSpaceAbstract {
    @testVisible
    private static WhiteSpaceTypeEnum type = WhiteSpaceTypeEnum.FREE_FORM;

    public WhiteSpaceFreeForm(White_Space__c whiteSpaceInfo) {
        super(whiteSpaceInfo, type);
        this.amountTypes = WhiteSpaceAmountTypeSelector.newInstance().selectAll();
    }

    protected override List<WhiteSpaceCollectionWrapper> getColumns() {
        return buildHeaders(this.oColumns);
    }

    protected override List<WhiteSpaceCollectionWrapper> getRows() {
        return buildHeaders(this.oRows);
    }

    protected override List<WhiteSpaceCellWrapper> getCells() {
        List<pqcrush__White_Space_Cell__c> cells = this.getUpdatedCells();
        Set<String> cellIds = new Set<String>(
            (List<String>) new List<Id>(new Map<Id, White_Space_Cell__c>(cells).keySet())
        );
        Map<String, Map<String, List<SObject>>> fieldDataByRelatedIds = WhiteSpaceUtils.getCellDataMap(
            cellIds,
            null,
            null,
            null,
            true,
            this.relatedCellFields,
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

    private List<WhiteSpaceCollectionWrapper> buildHeaders(List<SObject> rowOrColumns) {
        List<WhiteSpaceCollectionWrapper> headers = new List<WhiteSpaceCollectionWrapper>();
        for (SObject header : rowOrColumns) {
            headers.add(new WhiteSpaceCollectionWrapper(header));
        }
        return headers;
    }
}