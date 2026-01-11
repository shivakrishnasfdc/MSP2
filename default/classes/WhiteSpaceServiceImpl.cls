@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class WhiteSpaceServiceImpl {
    public White_Space__c createWhiteSpaceForAccountPlanId(Id accountPlanId, String name) {
        // CREATE WHITE SPACE
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        White_Space__c ws = new White_Space__c(Account_Plan__c = accountPlanId, Name = name);
        uow.registerNew(ws);
        uow.commitWork();

        return ws;
    }

    public White_Space__c createWhiteSpaceForAccountPlanId(Id accountPlanId, Id templateId) {
        // CREATE WHITE SPACE
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        White_Space__c ws = new White_Space__c(Account_Plan__c = accountPlanId, White_Space_Template__c = templateId);
        uow.registerNew(ws);
        uow.commitWork();

        return ws;
    }

    public White_Space__c createWhiteSpace(White_Space__c whiteSpace) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerNew(whiteSpace);
        uow.commitWork();
        return whiteSpace;
    }

    public List<White_Space_Row__c> createWhiteSpaceRows(Id whiteSpaceId, List<String> rowNames) {
        // APPENDING ROWS TO THE END OF THE LIST
        Integer startingOrder = 0;

        List<White_Space_Row__c> wsRows = WhiteSpaceRowSelector.newInstance()
            .selectByWhiteSpaceId(new Set<Id>{ whiteSpaceId });
        if (wsRows != null && wsRows.size() > 0) {
            startingOrder = (wsRows[wsRows.size() - 1].Order__c != null)
                ? Integer.valueOf(wsRows[wsRows.size() - 1].Order__c)
                : wsRows.size();
        }

        List<White_Space_Row__c> newRows = new List<White_Space_Row__c>();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Integer i = 0; i < rowNames.size(); i++) {
            startingOrder = startingOrder + 1;
            String rowName = rowNames[i];
            rowName = rowName.length() > 80 ? rowName.substring(0, 80) : rowName;
            White_Space_Row__c wsRow = new White_Space_Row__c(
                White_Space__c = whiteSpaceId,
                Name = rowName,
                Order__c = startingOrder
            );
            newRows.add(wsRow);
            uow.registerNew(wsRow);
        }
        uow.commitWork();

        return newRows;
    }

    // For creation from template so running as system
    public List<White_Space_Row__c> createWhiteSpaceRows(List<White_Space_Row__c> rows) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerNew(rows);
        new SystemContext().commitWork(uow);
        return rows;
    }

    public List<White_Space_Column__c> createWhiteSpaceColumns(Id whiteSpaceId, List<String> columnNames) {
        // APPENDING ROWS TO THE END OF THE LIST
        Integer startingOrder = 0;

        List<White_Space_Column__c> wsColumns = WhiteSpaceColumnSelector.newInstance()
            .selectByWhiteSpaceId(new Set<Id>{ whiteSpaceId });
        if (wsColumns != null && wsColumns.size() > 0) {
            startingOrder = (wsColumns[wsColumns.size() - 1].Order__c != null)
                ? Integer.valueOf(wsColumns[wsColumns.size() - 1].Order__c)
                : wsColumns.size();
        }

        List<White_Space_Column__c> newColumns = new List<White_Space_Column__c>();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Integer i = 0; i < columnNames.size(); i++) {
            startingOrder = startingOrder + 1;
            String colName = columnNames[i];
            colName = colName.length() > 80 ? colName.substring(0, 80) : colName;
            White_Space_Column__c wsColumn = new White_Space_Column__c(
                White_Space__c = whiteSpaceId,
                Name = colName,
                Order__c = startingOrder
            );
            newColumns.add(wsColumn);
            uow.registerNew(wsColumn);
        }
        uow.commitWork();

        return newColumns;
    }

    // For creation from template so running as system
    public List<White_Space_Column__c> createWhiteSpaceColumns(List<White_Space_Column__c> columns) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerNew(columns);
        new SystemContext().commitWork(uow);
        return columns;
    }

    public White_Space_Cell__c updateWhiteSpaceCell(White_Space_Cell__c record) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(record);
        uow.commitWork();

        return record;
    }

    public List<White_Space_Amount_Type_Association__c> upsertWhiteSpaceAmountTypeAssociations(
        List<White_Space_Amount_Type_Association__c> records
    ) {
        if (
            !Schema.sObjectType.White_Space_Amount_Type_Association__c.isUpdateable() ||
            !Schema.sObjectType.White_Space_Amount_Type_Association__c.isCreateable()
        ) {
            throw new AuraHandledException('Unable to save amounts: You do not have the necessary permissions');
        }
        try {
            upsert records;
        } catch (DMLException e) {
            throw new AuraHandledException('Unable to save amounts: ' + e.getMessage());
        }
        return records;
    }

    public List<White_Space_Row__c> updateWhiteSpaceRows(Id whiteSpaceId, List<White_Space_Row__c> rows) {
        // GET EXISTING ROWS
        List<White_Space_Row__c> wsRows = WhiteSpaceRowSelector.newInstance()
            .selectByWhiteSpaceId(new Set<Id>{ whiteSpaceId });

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Set<Id> rowIds = new Set<Id>();
        List<White_Space_Row__c> newRows = new List<White_Space_Row__c>();
        // UPSERT THE ROWS
        for (White_Space_Row__c row : rows) {
            if (row.Id == null) {
                uow.registerNew(row);
                newRows.add(row);
            } else {
                rowIds.add(row.Id);
                uow.registerDirty(row);
            }
        }

        // CREATE SET OF ROWS TO DELETE
        Set<Id> deletedRowIds = new Set<Id>();
        for (White_Space_Row__c row : wsRows) {
            if (!rowIds.contains(row.Id)) {
                deletedRowIds.add(row.Id);
                uow.registerDeleted(row);
            }
        }

        // DELETE CELLS FOR ROWS
        deleteCellsForRowIds(deletedRowIds);

        // COMMIT WORK
        uow.commitWork();

        // CREATE NEW CELLS FOR THE COLUMNS
        List<White_Space_Column__c> wsColumns = WhiteSpaceColumnSelector.newInstance()
            .selectByWhiteSpaceId(new Set<Id>{ whiteSpaceId });
        createWhiteSpaceCells(whiteSpaceId, getIdSetFromList(wsColumns), getIdSetFromList(newRows), null);

        return rows;
    }

    public List<White_Space_Column__c> updateWhiteSpaceColumns(Id whiteSpaceId, List<White_Space_Column__c> columns) {
        // GET EXISTING COLUMNS
        List<White_Space_Column__c> wsColumns = WhiteSpaceColumnSelector.newInstance()
            .selectByWhiteSpaceId(new Set<Id>{ whiteSpaceId });

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Set<Id> columnIds = new Set<Id>();
        List<White_Space_Column__c> newColumns = new List<White_Space_Column__c>();
        // UPSERT THE COLUMNS
        for (White_Space_Column__c column : columns) {
            if (column.Id == null) {
                uow.registerNew(column);
                newColumns.add(column);
            } else {
                columnIds.add(column.Id);
                uow.registerDirty(column);
            }
        }

        // CREATE SET OF COLUMNS TO DELETE
        Set<Id> deletedColumnIds = new Set<Id>();
        for (White_Space_Column__c column : wsColumns) {
            if (!columnIds.contains(column.Id)) {
                deletedColumnIds.add(column.Id);
                uow.registerDeleted(column);
            }
        }

        // DELETE CELLS FOR COLUMNS
        deleteCellsForColumnIds(deletedColumnIds);

        // COMMIT WORK
        uow.commitWork();

        // CREATE NEW CELLS FOR THE COLUMNS
        List<White_Space_Row__c> wsRows = WhiteSpaceRowSelector.newInstance()
            .selectByWhiteSpaceId(new Set<Id>{ whiteSpaceId });
        createWhiteSpaceCells(whiteSpaceId, getIdSetFromList(newColumns), getIdSetFromList(wsRows), null);

        return columns;
    }

    public List<White_Space_Cell__c> createWhiteSpaceCells(
        Id whiteSpaceId,
        Set<Id> whiteSpaceColumnIds,
        Set<Id> whiteSpaceRowIds,
        List<White_Space_Cell__c> cells
    ) {
        return createWhiteSpaceCells(whiteSpaceId, whiteSpaceColumnIds, whiteSpaceRowIds, cells, false);
    }

    public White_Space_Cell__c addNewWhitespaceCell(Id whiteSpaceId, Id whiteSpaceColumnId, Id whiteSpaceRowId) {
        List<White_Space_Cell__c> newCells = createWhiteSpaceCells(
            whiteSpaceId,
            new Set<Id>{ whiteSpaceColumnId },
            new Set<Id>{ whiteSpaceRowId },
            null,
            true
        );
        return newCells.size() > 0 ? newCells[0] : null;
    }

    public void deleteWhiteSpace(Id whiteSpaceId) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<White_Space__c> whiteSpaceList = WhiteSpaceSelector.newInstance().selectById(new Set<Id>{ whiteSpaceId });
        uow.registerDeleted(whiteSpaceList);
        uow.commitWork();
    }

    public void deleteWhiteSpaceColumns(List<White_Space_Column__c> columns) {
        Set<Id> columnIds = new Map<Id, White_Space_Column__c>(columns).keySet();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(columns);
        List<White_Space_Cell__c> cells = WhiteSpaceCellSelector.newInstance().selectByColumnId(columnIds);
        uow.registerDeleted(cells);
        uow.commitWork();
    }

    public void deleteWhiteSpaceColumnsAsSystem(List<White_Space_Column__c> columns) {
        Set<Id> columnIds = new Map<Id, White_Space_Column__c>(columns).keySet();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerDeleted(columns);
        List<White_Space_Cell__c> cells = WhiteSpaceCellSelector.newInstance().selectByColumnId(columnIds);
        uow.registerDeleted(cells);
        new SystemContext().commitWork(uow);
    }

    public void deleteWhiteSpaceRows(List<White_Space_Row__c> rows) {
        Set<Id> rowIds = new Map<Id, White_Space_Row__c>(rows).keySet();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(rows);
        List<White_Space_Cell__c> cells = WhiteSpaceCellSelector.newInstance().selectByRowId(rowIds);
        uow.registerDeleted(cells);
        uow.commitWork();
    }

    public void deleteWhiteSpaceRowsAsSystem(List<White_Space_Row__c> rows) {
        Set<Id> rowIds = new Map<Id, White_Space_Row__c>(rows).keySet();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerDeleted(rows);
        List<White_Space_Cell__c> cells = WhiteSpaceCellSelector.newInstance().selectByRowId(rowIds);
        uow.registerDeleted(cells);
        new SystemContext().commitWork(uow);
    }

    public void deleteWhitespaceCells(List<White_Space_Cell__c> wsCells) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(wsCells);
        uow.commitWork();
    }

    public White_Space__c undeleteWhiteSpace(Id whiteSpaceId) {
        if (!Schema.sObjectType.White_Space__c.isCreateable() || !Schema.sObjectType.White_Space__c.isUndeletable()) {
            throw Application.genericException('Unable to restore due to lack of permissions');
        }
        White_Space__c savedWs = [SELECT Id FROM White_Space__c WHERE Id = :whiteSpaceId ALL ROWS];
        try {
            undelete savedWs;
            return savedWs;
        } catch (DmlException e) {
            throw Application.genericException('Unable to restore: ' + e.getMessage());
        }
    }

    /*******************
     *     private
     *******************/

    private List<White_Space_Cell__c> createWhiteSpaceCells(
        Id whiteSpaceId,
        Set<Id> whiteSpaceColumnIds,
        Set<Id> whiteSpaceRowIds,
        List<White_Space_Cell__c> cells,
        Boolean createDuplicates
    ) {
        Map<String, White_Space_Cell__c> rowColumnMap = createRowsColumnsCellsMap(cells);
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        List<White_Space_Cell__c> newCells = new List<White_Space_Cell__c>();
        for (Id colId : whiteSpaceColumnIds) {
            for (Id rowId : whiteSpaceRowIds) {
                if (createDuplicates || !rowColumnMap.containsKey(rowId + '_' + colId)) {
                    White_Space_Cell__c cell = new White_Space_Cell__c(
                        White_Space__c = whiteSpaceId,
                        White_Space_Column__c = colId,
                        White_Space_Row__c = rowId
                    );
                    uow.registerNew(cell);
                    newCells.add(cell);
                }
            }
        }
        new SystemContext().commitWork(uow);
        return newCells;
    }

    private Map<String, White_Space_Cell__c> createRowsColumnsCellsMap(List<White_Space_Cell__c> cells) {
        if (cells == null) {
            return new Map<String, White_Space_Cell__c>();
        }
        Map<String, White_Space_Cell__c> rowColumnMap = new Map<String, White_Space_Cell__c>();
        for (White_Space_Cell__c cell : cells) {
            rowColumnMap.put(cell.White_Space_Row__c + '_' + cell.White_Space_Column__c, cell);
        }
        return rowColumnMap;
    }

    private Set<Id> getIdSetFromList(List<SObject> objList) {
        Set<Id> ids = new Set<Id>();
        for (SObject o : objList) {
            ids.add(o.Id);
        }
        return ids;
    }

    private void deleteCellsForColumnIds(Set<Id> columnIds) {
        // GET CELLS FOR COLUMN IDS
        List<White_Space_Cell__c> wsCells = WhiteSpaceCellSelector.newInstance().selectByColumnId(columnIds);
        deleteWhitespaceCells(wsCells);
    }

    private void deleteCellsForRowIds(Set<Id> rowIds) {
        // GET CELLS FOR ROW IDS
        List<White_Space_Cell__c> wsCells = WhiteSpaceCellSelector.newInstance().selectByRowId(rowIds);
        deleteWhitespaceCells(wsCells);
    }

    private without sharing class SystemContext {
        private void commitWork(fflib_ISObjectUnitOfWork uow) {
            uow.commitWork();
        }
    }
}