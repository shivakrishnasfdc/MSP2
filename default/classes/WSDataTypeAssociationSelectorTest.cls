@isTest
private class WSDataTypeAssociationSelectorTest {
    public static final String WHITE_SPACE_ROW1_NAME = 'row1';
    public static final String WHITE_SPACE_ROW2_NAME = 'row2';
    public static final String WHITE_SPACE_COLUMN1_NAME = 'column1';
    public static final String WHITE_SPACE_COLUMN2_NAME = 'column2';

    @isTest
    static void selectByIdTest() {
        // Given
        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;
        Account_Plan__c ap = TestDataFactory.createAccountPlan('PlanA', testAccount);
        White_Space__c ws = TestDataFactory.createWhiteSpace(ap, 'WS Name');

        White_Space_Row__c row1 = TestDataFactory.createWhiteSpaceRow(ws, WHITE_SPACE_ROW1_NAME);
        White_Space_Row__c row2 = TestDataFactory.createWhiteSpaceRow(ws, WHITE_SPACE_ROW2_NAME);
        White_Space_Column__c col1 = TestDataFactory.createWhiteSpaceColumn(ws, WHITE_SPACE_COLUMN1_NAME);
        White_Space_Column__c col2 = TestDataFactory.createWhiteSpaceColumn(ws, WHITE_SPACE_COLUMN2_NAME);
        List<White_Space_Cell__c> cells = TestDataFactory.createWhiteSpaceCells(
            ws.id,
            new Set<Id>{ col1.id, col2.id },
            new Set<Id>{ row1.id, row2.id }
        );

        WS_Data_Type__c dt = new WS_Data_Type__c(
            Data_Type__c = 'Picklist',
            Picklist_Values__c = 'one',
            White_Space__c = ws.Id,
            Label__c = 'label1',
            Color__c = '#FFF'
        );
        insert dt;

        WS_Data_Type_Association__c wsDataAssoc = new WS_Data_Type_Association__c(
            White_Space_Cell__c = cells[0].Id,
            WS_Data_Type__c = dt.Id,
            WS_Data_Value__c = 'one'
        );
        insert wsDataAssoc;

        List<WS_Data_Type_Association__c> result = new WSDataTypeAssociationSelector()
            .selectById(new Set<Id>{ wsDataAssoc.Id });

        // Then
        System.assertEquals(1, result.size());
        System.assertEquals(dt.Id, result[0].WS_Data_Type__c);
        System.assertEquals('one', result[0].WS_Data_Value__c);
    }

    @isTest
    static void selectByCellAndDataTypeTest() {
        // Given
        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;
        Account_Plan__c ap = TestDataFactory.createAccountPlan('PlanA', testAccount);
        White_Space__c ws = TestDataFactory.createWhiteSpace(ap, 'WS Name');

        White_Space_Row__c row1 = TestDataFactory.createWhiteSpaceRow(ws, WHITE_SPACE_ROW1_NAME);
        White_Space_Row__c row2 = TestDataFactory.createWhiteSpaceRow(ws, WHITE_SPACE_ROW2_NAME);
        White_Space_Column__c col1 = TestDataFactory.createWhiteSpaceColumn(ws, WHITE_SPACE_COLUMN1_NAME);
        White_Space_Column__c col2 = TestDataFactory.createWhiteSpaceColumn(ws, WHITE_SPACE_COLUMN2_NAME);
        List<White_Space_Cell__c> cells = TestDataFactory.createWhiteSpaceCells(
            ws.id,
            new Set<Id>{ col1.id, col2.id },
            new Set<Id>{ row1.id, row2.id }
        );

        WS_Data_Type__c dt = new WS_Data_Type__c(
            Data_Type__c = 'Picklist',
            Picklist_Values__c = 'one',
            White_Space__c = ws.Id,
            Label__c = 'label1',
            Color__c = '#FFF'
        );
        insert dt;

        WS_Data_Type_Association__c wsDataAssoc = new WS_Data_Type_Association__c(
            White_Space_Cell__c = cells[0].Id,
            WS_Data_Type__c = dt.Id,
            WS_Data_Value__c = 'one'
        );
        insert wsDataAssoc;

        List<WS_Data_Type_Association__c> result = new WSDataTypeAssociationSelector()
            .selectByCellAndDataType(cells[0].Id, dt.Id);

        // Then
        System.assertEquals(1, result.size());
        System.assertEquals(dt.Id, result[0].WS_Data_Type__c);
        System.assertEquals('one', result[0].WS_Data_Value__c);
    }

    @isTest
    static void selectByCellIdTest() {
        // Given
        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;
        Account_Plan__c ap = TestDataFactory.createAccountPlan('PlanA', testAccount);
        White_Space__c ws = TestDataFactory.createWhiteSpace(ap, 'WS Name');

        White_Space_Row__c row1 = TestDataFactory.createWhiteSpaceRow(ws, WHITE_SPACE_ROW1_NAME);
        White_Space_Row__c row2 = TestDataFactory.createWhiteSpaceRow(ws, WHITE_SPACE_ROW2_NAME);
        White_Space_Column__c col1 = TestDataFactory.createWhiteSpaceColumn(ws, WHITE_SPACE_COLUMN1_NAME);
        White_Space_Column__c col2 = TestDataFactory.createWhiteSpaceColumn(ws, WHITE_SPACE_COLUMN2_NAME);
        List<White_Space_Cell__c> cells = TestDataFactory.createWhiteSpaceCells(
            ws.id,
            new Set<Id>{ col1.id, col2.id },
            new Set<Id>{ row1.id, row2.id }
        );

        WS_Data_Type__c dt = new WS_Data_Type__c(
            Data_Type__c = 'Picklist',
            Picklist_Values__c = 'one',
            White_Space__c = ws.Id,
            Label__c = 'label1',
            Color__c = '#FFF'
        );
        insert dt;

        WS_Data_Type_Association__c wsDataAssoc = new WS_Data_Type_Association__c(
            White_Space_Cell__c = cells[0].Id,
            WS_Data_Type__c = dt.Id,
            WS_Data_Value__c = 'one'
        );
        insert wsDataAssoc;

        List<WS_Data_Type_Association__c> result = new WSDataTypeAssociationSelector().selectByCellId(cells[0].Id);

        // Then
        System.assertEquals(1, result.size());
        System.assertEquals(dt.Id, result[0].WS_Data_Type__c);
        System.assertEquals('one', result[0].WS_Data_Value__c);
    }
}