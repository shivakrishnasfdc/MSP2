@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class WhiteSpaceService {
    public static White_Space__c createWhiteSpaceForAccountPlanId(Id accountPlanId, String name) {
        return service().createWhiteSpaceForAccountPlanId(accountPlanId, name);
    }

    public static White_Space__c createWhiteSpaceForAccountPlanId(Id accountPlanId, Id templateId) {
        return service().createWhiteSpaceForAccountPlanId(accountPlanId, templateId);
    }

    public static White_Space__c createWhiteSpace(White_Space__c whiteSpace) {
        return service().createWhiteSpace(whiteSpace);
    }

    public static List<White_Space_Row__c> createWhiteSpaceRows(Id whiteSpaceId, List<String> rowNames) {
        return service().createWhiteSpaceRows(whiteSpaceId, rowNames);
    }

    public static List<White_Space_Row__c> createWhiteSpaceRows(List<White_Space_Row__c> rows) {
        return service().createWhiteSpaceRows(rows);
    }

    public static List<White_Space_Column__c> createWhiteSpaceColumns(Id whiteSpaceId, List<String> columnNames) {
        return service().createWhiteSpaceColumns(whiteSpaceId, columnNames);
    }

    public static List<White_Space_Column__c> createWhiteSpaceColumns(List<White_Space_Column__c> columns) {
        return service().createWhiteSpaceColumns(columns);
    }

    public static White_Space_Cell__c updateWhiteSpaceCell(White_Space_Cell__c record) {
        return service().updateWhiteSpaceCell(record);
    }

    public static List<White_Space_Amount_Type_Association__c> upsertWhiteSpaceAmountTypeAssociations(
        List<White_Space_Amount_Type_Association__c> records
    ) {
        return service().upsertWhiteSpaceAmountTypeAssociations(records);
    }

    public static List<White_Space_Row__c> updateWhiteSpaceRows(Id whiteSpaceId, List<White_Space_Row__c> rows) {
        return service().updateWhiteSpaceRows(whiteSpaceId, rows);
    }

    public static List<White_Space_Column__c> updateWhiteSpaceColumns(
        Id whiteSpaceId,
        List<White_Space_Column__c> columns
    ) {
        return service().updateWhiteSpaceColumns(whiteSpaceId, columns);
    }

    public static List<White_Space_Cell__c> createWhiteSpaceCells(
        Id whiteSpaceId,
        Set<Id> whiteSpaceColumnIds,
        Set<Id> whiteSpaceRowIds,
        List<White_Space_Cell__c> cells
    ) {
        return service().createWhiteSpaceCells(whiteSpaceId, whiteSpaceColumnIds, whiteSpaceRowIds, cells);
    }

    public static White_Space_Cell__c addNewWhitespaceCell(Id whiteSpaceId, Id whiteSpaceColumnId, Id whiteSpaceRowId) {
        return service().addNewWhitespaceCell(whiteSpaceId, whiteSpaceColumnId, whiteSpaceRowId);
    }

    public static void deleteWhiteSpace(Id whiteSpaceId) {
        service().deleteWhiteSpace(whiteSpaceId);
    }

    public static void deleteWhiteSpaceColumns(List<White_Space_Column__c> columns) {
        service().deleteWhiteSpaceColumns(columns);
    }

    public static void deleteWhiteSpaceColumnsAsSystem(List<White_Space_Column__c> columns) {
        service().deleteWhiteSpaceColumnsAsSystem(columns);
    }

    public static void deleteWhiteSpaceRows(List<White_Space_Row__c> rows) {
        service().deleteWhiteSpaceRows(rows);
    }

    public static void deleteWhiteSpaceRowsAsSystem(List<White_Space_Row__c> rows) {
        service().deleteWhiteSpaceRowsAsSystem(rows);
    }

    public static void deleteWhitespaceCells(List<White_Space_Cell__c> wsCells) {
        service().deleteWhitespaceCells(wsCells);
    }

    public static White_Space__c undeleteWhiteSpace(Id whiteSpaceId) {
        return service().undeleteWhiteSpace(whiteSpaceId);
    }

    /******************************
     *      PRIVATE METHODS
     ******************************/

    private static WhiteSpaceServiceImpl service() {
        return (WhiteSpaceServiceImpl) Application.Service.newInstance(WhiteSpaceServiceImpl.class);
    }
}