public with sharing class WhiteSpaceObjectAccess {
    @AuraEnabled
    public Boolean canCreate;

    @AuraEnabled
    public Boolean canUpdate;

    @AuraEnabled
    public Boolean canDelete;

    @AuraEnabled
    public Boolean canUpdateRows;

    @AuraEnabled
    public Boolean canAddRows;

    @AuraEnabled
    public Boolean canDeleteRows;

    @AuraEnabled
    public Boolean canUpdateColumns;

    @AuraEnabled
    public Boolean canAddColumns;

    @AuraEnabled
    public Boolean canDeleteColumns;

    @AuraEnabled
    public Boolean canUpdateCells;

    @AuraEnabled
    public Boolean canAddCells;

    @AuraEnabled
    public Boolean canDeleteCells;

    public WhiteSpaceObjectAccess(
        Boolean canCreate,
        Boolean canUpdate,
        Boolean canDelete,
        Boolean canUpdateRows,
        Boolean canAddRows,
        Boolean canDeleteRows,
        Boolean canUpdateColumns,
        Boolean canAddColumns,
        Boolean canDeleteColumns,
        Boolean canUpdateCells,
        Boolean canAddCells,
        Boolean canDeleteCells
    ) {
        this.canCreate = canCreate;
        this.canUpdate = canUpdate;
        this.canDelete = canDelete;
        this.canUpdateRows = canUpdateRows;
        this.canAddRows = canAddRows;
        this.canDeleteRows = canDeleteRows;
        this.canUpdateColumns = canUpdateColumns;
        this.canAddColumns = canAddColumns;
        this.canDeleteColumns = canDeleteColumns;
        this.canUpdateCells = canUpdateCells;
        this.canAddCells = canAddCells;
        this.canDeleteCells = canDeleteCells;
    }
}