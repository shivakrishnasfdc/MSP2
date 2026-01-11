public with sharing abstract class WhiteSpaceAbstract {
    protected White_Space__c privateWhiteSpaceInfo;
    @testVisible
    protected WhiteSpaceTypeEnum type;

    protected List<White_Space_Column__c> oColumns = null;
    protected List<White_Space_Row__c> oRows = null;

    @AuraEnabled
    public List<WhiteSpaceCollectionWrapper> columns = new List<WhiteSpaceCollectionWrapper>();

    @AuraEnabled
    public List<WhiteSpaceCollectionWrapper> rows = new List<WhiteSpaceCollectionWrapper>();

    @AuraEnabled
    public List<WhiteSpaceCellWrapper> cells = new List<WhiteSpaceCellWrapper>();

    @AuraEnabled
    public List<White_Space_Amount_Type__c> amountTypes = new List<White_Space_Amount_Type__c>();

    @AuraEnabled
    public List<WS_Data_Type__c> dataTypes = new List<WS_Data_Type__c>();

    @AuraEnabled
    public List<WhiteSpaceTemplateCellFieldWrapper> relatedCellFields = new List<WhiteSpaceTemplateCellFieldWrapper>();

    @AuraEnabled
    public List<WSRelatedObjectWrapper> relatedObjects = new List<WSRelatedObjectWrapper>();

    @AuraEnabled
    public Account_Plan__c accountPlan {
        get {
            return this.privateWhiteSpaceInfo.Account_Plan__r;
        }
    }

    @AuraEnabled
    public Id id {
        get {
            return this.privateWhiteSpaceInfo.id;
        }
    }

    @AuraEnabled
    public Boolean cellsFiltered {
        get {
            return this.privateWhiteSpaceInfo.AreCellsFiltered__c;
        }
    }

    @AuraEnabled
    public Boolean templatedCells {
        get {
            return this.type == WhiteSpaceTypeEnum.TEMPLATE;
        }
    }

    @AuraEnabled
    public String cellDisplayType {
        get {
            switch on this.type {
                when FREE_FORM, LEGACY_TEMPLATE {
                    return 'tiles';
                }
                when TEMPLATE {
                    return 'summary';
                }
            }
            return '';
        }
    }

    protected WhiteSpaceAbstract(White_Space__c whiteSpaceInfo, WhiteSpaceTypeEnum type) {
        this.privateWhiteSpaceInfo = whiteSpaceInfo;
        this.type = type;
        this.oColumns = WhiteSpaceColumnSelector.newInstance().selectByWhiteSpaceId(new Set<Id>{ whiteSpaceInfo.id });
        this.oRows = WhiteSpaceRowSelector.newInstance().selectByWhiteSpaceId(new Set<Id>{ whiteSpaceInfo.id });
        this.dataTypes = WSDataTypeSelector.newInstance().selectByWhiteSpaceId(whiteSpaceInfo.id);
        setupChildRelationships();
    }

    public WhiteSpaceAbstract build() {
        this.columns.addAll(this.getColumns());
        this.rows.addAll(this.getRows());
        this.cells.addAll(this.getCells());
        return this;
    }

    protected abstract List<WhiteSpaceCollectionWrapper> getColumns();

    protected abstract List<WhiteSpaceCollectionWrapper> getRows();

    protected abstract List<WhiteSpaceCellWrapper> getCells();

    protected List<White_Space_Cell__c> getUpdatedCells() {
        List<White_Space_Cell__c> existingCells = WhiteSpaceCellSelector.newInstance()
            .selectByWhiteSpaceIdWithAmountTypeAssociations(this.privateWhiteSpaceInfo.id);

        List<White_Space_Cell__c> newCells = WhiteSpaceService.createWhiteSpaceCells(
            this.privateWhiteSpaceInfo.id,
            new Set<Id>(mapForCollectionWrapperList(this.columns).keySet()),
            new Set<Id>(mapForCollectionWrapperList(this.rows).keySet()),
            existingCells
        );
        if (newCells != null) {
            existingCells.addAll(newCells);
        }
        return existingCells;
    }

    public static Map<Id, WhiteSpaceCollectionWrapper> mapForCollectionWrapperList(
        List<WhiteSpaceCollectionWrapper> wrappers
    ) {
        Map<Id, WhiteSpaceCollectionWrapper> mappedWrappers = new Map<Id, WhiteSpaceCollectionWrapper>();
        if (wrappers == null) {
            return mappedWrappers;
        }
        for (WhiteSpaceCollectionWrapper wrapper : wrappers) {
            mappedWrappers.put(wrapper.id, wrapper);
        }
        return mappedWrappers;
    }

    private void setupChildRelationships() {
        this.relatedObjects = WhiteSpaceUtils.getWSRelatedObjectWrappers();
        this.relatedCellFields = new List<WhiteSpaceTemplateCellFieldWrapper>();
        for (WSRelatedObjectWrapper wrapper : this.relatedObjects) {
            WhiteSpaceTemplateCellFieldWrapper cellFieldWrapper = new WhiteSpaceTemplateCellFieldWrapper(wrapper, true);
            this.relatedCellFields.add(cellFieldWrapper);
        }
    }
}