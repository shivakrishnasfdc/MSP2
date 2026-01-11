@isTest
private class WhiteSpaceServiceTest {
    public static final String USER1_FIRST_NAME = 'admin';
    public static final String USER1_LAST_NAME = 'adam';

    public static final String USER2_FIRST_NAME = 'standard';
    public static final String USER2_LAST_NAME = 'suzie';

    public static final String USER3_FIRST_NAME = 'creator';
    public static final String USER3_LAST_NAME = 'cal';

    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';
    public static final String CRUSH_ACCOUNT_PLAN_CREATOR = 'CRUSH_Account_Plan_Creator';

    public static final String ACCOUNT1_NAME = 'Account 1';
    public static final String ACCOUNT_PLAN1_NAME = 'AccountPlan1';
    public static final String WHITE_SPACE1_NAME = 'WhiteSpace1';
    public static final String WHITE_SPACE_ROW1_NAME = 'row1';
    public static final String WHITE_SPACE_ROW2_NAME = 'row2';
    public static final String WHITE_SPACE_COLUMN1_NAME = 'column1';
    public static final String WHITE_SPACE_COLUMN2_NAME = 'column2';
    public static final String WHITE_SPACE_AMOUNT_TYPE1_NAME = 'testAmountType1';
    public static final String WHITE_SPACE_AMOUNT_TYPE2_NAME = 'testAmountType2';

    public static final String STANDARD_USER = 'Standard User';

    @testSetup
    static void testSetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];
        User adminAdam = TestDataFactory.createUser(USER1_FIRST_NAME, USER1_LAST_NAME, p.Id);
        User standardSuzie = TestDataFactory.createUser(USER2_FIRST_NAME, USER2_LAST_NAME, p.Id);
        User creatorCal = TestDataFactory.createUser(USER3_FIRST_NAME, USER3_LAST_NAME, p.Id);

        PermissionSet standardUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_STANDARD_USER];
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];
        PermissionSet creatorUserPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = :CRUSH_ACCOUNT_PLAN_CREATOR
        ];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = standardSuzie.Id, PermissionSetId = standardUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = adminAdam.Id, PermissionSetId = adminUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = creatorCal.Id, PermissionSetId = creatorUserPermissionSet.Id)
        };

        System.runAs(creatorCal) {
            Account testAccount1 = new Account(Name = ACCOUNT1_NAME);
            insert testAccount1;
            Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan(ACCOUNT_PLAN1_NAME, testAccount1);

            White_Space__c ws = TestDataFactory.createWhiteSpace(accountPlan1, WHITE_SPACE1_NAME);
            White_Space_Row__c row1 = TestDataFactory.createWhiteSpaceRow(ws, WHITE_SPACE_ROW1_NAME);
            White_Space_Row__c row2 = TestDataFactory.createWhiteSpaceRow(ws, WHITE_SPACE_ROW2_NAME);
            White_Space_Column__c col1 = TestDataFactory.createWhiteSpaceColumn(ws, WHITE_SPACE_COLUMN1_NAME);
            White_Space_Column__c col2 = TestDataFactory.createWhiteSpaceColumn(ws, WHITE_SPACE_COLUMN2_NAME);
            List<White_Space_Cell__c> cells = TestDataFactory.createWhiteSpaceCells(
                ws.id,
                new Set<Id>{ col1.id, col2.id },
                new Set<Id>{ row1.id, row2.id }
            );
            White_Space_Amount_Type__c amountType1 = TestDataFactory.createWhiteSpaceAmountType(
                WHITE_SPACE_AMOUNT_TYPE1_NAME
            );
            TestDataFactory.createWhiteSpaceAmountType(WHITE_SPACE_AMOUNT_TYPE2_NAME);
            TestDataFactory.createWhiteSpaceAmountTypeAssociation(amountType1.id, cells[0].id);
        }
    }

    @isTest
    static void createWhiteSpaceForAccountPlanIdTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        Application.UnitOfWork.setMock(mockUow);

        // When
        String whiteSpaceName = 'my white space';
        Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);

        WhiteSpaceService.createWhiteSpaceForAccountPlanId(accountPlanId, whiteSpaceName);

        // Then
        try {
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1))
                .registerNew(new White_Space__c(Account_Plan__c = accountPlanId, Name = whiteSpaceName));
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void createWhiteSpaceForAccountPlanIdTemplateTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        Application.UnitOfWork.setMock(mockUow);

        // When
        Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        Id templateId = fflib_IDGenerator.generate(White_Space_Template__c.SObjectType);

        WhiteSpaceService.createWhiteSpaceForAccountPlanId(accountPlanId, templateId);

        // Then
        try {
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1))
                .registerNew(new White_Space__c(Account_Plan__c = accountPlanId, White_Space_Template__c = templateId));
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void createWhiteSpaceTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        Application.UnitOfWork.setMock(mockUow);

        // When
        Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        Id templateId = fflib_IDGenerator.generate(White_Space_Template__c.SObjectType);
        White_Space__c testWS = new White_Space__c(
            Account_Plan__c = accountPlanId,
            White_Space_Template__c = templateId
        );

        WhiteSpaceService.createWhiteSpace(testWS);

        // Then
        try {
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1))
                .registerNew(new White_Space__c(Account_Plan__c = accountPlanId, White_Space_Template__c = templateId));
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void createWhiteSpaceRowsTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WhiteSpaceRowSelector mockSelector = (WhiteSpaceRowSelector) FFLibHelper.mockSelector(
            WhiteSpaceRowSelector.class,
            mocks
        );
        fflib_ISObjectUnitOfWork mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        Application.UnitOfWork.setMock(mockUow);
        Application.Selector.setMock(mockSelector);

        // When
        Id whiteSpaceId = fflib_IDGenerator.generate(White_Space__c.SObjectType);
        White_Space__c whiteSpace = new White_Space__c(Id = whiteSpaceId);

        White_Space_Row__c row1 = new White_Space_Row__c(Order__c = 1);
        White_Space_Row__c row2 = new White_Space_Row__c(Order__c = 2);

        List<String> newRows = new List<String>{
            'row3',
            '01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789'
        };

        mocks.startStubbing();
        mocks.when(mockSelector.selectByWhiteSpaceId(new Set<Id>{ whiteSpaceId }))
            .thenReturn(new List<White_Space_Row__c>{ row1, row2 });
        mocks.stopStubbing();

        WhiteSpaceService.createWhiteSpaceRows(whiteSpace.Id, newRows);

        // Then
        try {
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1))
                .registerNew(new White_Space_Row__c(White_Space__c = whiteSpaceId, Name = newRows[0], Order__c = 3));
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1))
                .registerNew(
                    new White_Space_Row__c(
                        White_Space__c = whiteSpaceId,
                        Name = newRows[1].substring(0, 80),
                        Order__c = 4
                    )
                );
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void createWhiteSpaceRowsFromRowListTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        Application.UnitOfWork.setMock(mockUow);

        // When
        Id whiteSpaceId = fflib_IDGenerator.generate(White_Space__c.SObjectType);
        White_Space__c whiteSpace = new White_Space__c(Id = whiteSpaceId);

        White_Space_Row__c row1 = new White_Space_Row__c(White_Space__c = whiteSpace.id, Order__c = 1);
        White_Space_Row__c row2 = new White_Space_Row__c(White_Space__c = whiteSpace.id, Order__c = 2);

        List<White_Space_Row__c> rows = new List<White_Space_Row__c>{ row1, row2 };

        WhiteSpaceService.createWhiteSpaceRows(rows);

        // Then
        try {
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerNew(rows);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void createWhiteSpaceColumnsTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WhiteSpaceColumnSelector mockSelector = (WhiteSpaceColumnSelector) FFLibHelper.mockSelector(
            WhiteSpaceColumnSelector.class,
            mocks
        );
        fflib_ISObjectUnitOfWork mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        Application.UnitOfWork.setMock(mockUow);
        Application.Selector.setMock(mockSelector);

        // When
        Id whiteSpaceId = fflib_IDGenerator.generate(White_Space__c.SObjectType);
        White_Space__c whiteSpace = new White_Space__c(Id = whiteSpaceId);

        White_Space_Column__c column1 = new White_Space_Column__c(Order__c = 1);
        White_Space_Column__c column2 = new White_Space_Column__c(Order__c = 2);

        List<String> newColumns = new List<String>{
            'column3',
            '01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789'
        };

        mocks.startStubbing();
        mocks.when(mockSelector.selectByWhiteSpaceId(new Set<Id>{ whiteSpaceId }))
            .thenReturn(new List<White_Space_Column__c>{ column1, column2 });
        mocks.stopStubbing();

        WhiteSpaceService.createWhiteSpaceColumns(whiteSpace.Id, newColumns);

        // Then
        try {
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1))
                .registerNew(
                    new White_Space_Column__c(White_Space__c = whiteSpaceId, Name = newColumns[0], Order__c = 3)
                );
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1))
                .registerNew(
                    new White_Space_Column__c(
                        White_Space__c = whiteSpaceId,
                        Name = newColumns[1].substring(0, 80),
                        Order__c = 4
                    )
                );
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void createWhiteSpaceColumnsFromColumnListTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        Application.UnitOfWork.setMock(mockUow);

        // When
        Id whiteSpaceId = fflib_IDGenerator.generate(White_Space__c.SObjectType);
        White_Space__c whiteSpace = new White_Space__c(Id = whiteSpaceId);

        White_Space_Column__c column1 = new White_Space_Column__c(White_Space__c = whiteSpace.id, Order__c = 1);
        White_Space_Column__c column2 = new White_Space_Column__c(White_Space__c = whiteSpace.id, Order__c = 2);

        List<White_Space_Column__c> columns = new List<White_Space_Column__c>{ column1, column2 };

        WhiteSpaceService.createWhiteSpaceColumns(columns);

        // Then
        try {
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerNew(columns);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void updateWhiteSpaceCellTest() {
        // Mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        Application.UnitOfWork.setMock(mockUow);

        // Given
        White_Space__c ws = [SELECT Id FROM White_Space__c WHERE Name = :WHITE_SPACE1_NAME LIMIT 1];
        List<White_Space_Cell__c> wsCells = [
            SELECT Id, Name, Info__c, White_Space__c, White_Space_Column__c, White_Space_Row__c
            FROM White_Space_Cell__c
            WHERE White_Space__c = :ws.Id
        ];
        wsCells[0].Info__c = 'test';

        // When
        White_Space_Cell__c result = WhiteSpaceService.updateWhiteSpaceCell(wsCells[0]);

        // Then
        try {
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerDirty(wsCells[0]);
            System.assertEquals('test', result.Info__c);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void upsertWhiteSpaceAmountTypeAssociationsTest() {
        // Given
        White_Space_Amount_Type__c unassociatedType = [
            SELECT Id, Name
            FROM White_Space_Amount_Type__c
            WHERE Name = :WHITE_SPACE_AMOUNT_TYPE2_NAME
            LIMIT 1
        ];
        White_Space_Amount_Type_Association__c existingAssociation = [
            SELECT Id, Amount__c, White_Space_Amount_Type__c, White_Space_Cell__c
            FROM White_Space_Amount_Type_Association__c
            LIMIT 1
        ];
        existingAssociation.Amount__c = 400;

        White_Space_Amount_Type_Association__c newAssoc = new White_Space_Amount_Type_Association__c(
            White_Space_Cell__c = existingAssociation.White_Space_Cell__c,
            White_Space_Amount_Type__c = unassociatedType.id,
            Amount__c = 100
        );

        // When
        List<White_Space_Amount_Type_Association__c> result = WhiteSpaceService.upsertWhiteSpaceAmountTypeAssociations(
            new List<White_Space_Amount_Type_Association__c>{ existingAssociation, newAssoc }
        );

        // Then
        try {
            System.assertEquals(2, result.size());
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void updateWhiteSpaceRowsTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WhiteSpaceRowSelector mockSelector = (WhiteSpaceRowSelector) FFLibHelper.mockSelector(
            WhiteSpaceRowSelector.class,
            mocks
        );
        WhiteSpaceColumnSelector mockColumnSelector = (WhiteSpaceColumnSelector) FFLibHelper.mockSelector(
            WhiteSpaceColumnSelector.class,
            mocks
        );
        WhiteSpaceCellSelector mockCellSelector = (WhiteSpaceCellSelector) FFLibHelper.mockSelector(
            WhiteSpaceCellSelector.class,
            mocks
        );
        fflib_ISObjectUnitOfWork mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        Application.UnitOfWork.setMock(mockUow);
        Application.Selector.setMock(mockSelector);
        Application.Selector.setMock(mockColumnSelector);
        Application.Selector.setMock(mockCellSelector);

        Id whiteSpaceId = fflib_IDGenerator.generate(White_Space__c.SObjectType);
        Id row1Id = fflib_IDGenerator.generate(White_Space_Row__c.SObjectType);
        Id row2Id = fflib_IDGenerator.generate(White_Space_Row__c.SObjectType);
        Id row3Id = fflib_IDGenerator.generate(White_Space_Row__c.SObjectType);
        Id col1Id = fflib_IDGenerator.generate(White_Space_Column__c.SObjectType);
        Id col2Id = fflib_IDGenerator.generate(White_Space_Column__c.SObjectType);
        String row1Name = 'row1';
        String row2Name = 'row2';
        String row3Name = 'row3';
        String row4Name = 'row4';
        String col1Name = 'row4';
        String col2Name = 'row4';
        String cell1Name = 'cell1';

        String row1NameUpdated = 'row1updatedName';
        String row3NameUpdated = 'row3updateName';

        White_Space_Row__c row1 = new White_Space_Row__c(
            Id = row1Id,
            Name = row1Name,
            Order__c = 1,
            White_Space__c = whiteSpaceId
        );
        White_Space_Row__c row2 = new White_Space_Row__c(
            Id = row2Id,
            Name = row2Name,
            Order__c = 2,
            White_Space__c = whiteSpaceId
        );
        White_Space_Row__c row3 = new White_Space_Row__c(
            Id = row3Id,
            Name = row3Name,
            Order__c = 3,
            White_Space__c = whiteSpaceId
        );

        White_Space_Row__c updatedRow1 = new White_Space_Row__c(
            Id = row1Id,
            Name = row1NameUpdated,
            Order__c = 1,
            White_Space__c = whiteSpaceId
        );
        White_Space_Row__c updatedRow3 = new White_Space_Row__c(
            Id = row3Id,
            Name = row3NameUpdated,
            Order__c = 2,
            White_Space__c = whiteSpaceId
        );
        White_Space_Row__c updatedRow4 = new White_Space_Row__c(
            Name = row4Name,
            Order__c = 3,
            White_Space__c = whiteSpaceId
        );

        White_Space_Column__c col1 = new White_Space_Column__c(
            Id = col1Id,
            Name = col1Name,
            Order__c = 1,
            White_Space__c = whiteSpaceId
        );
        White_Space_Column__c col2 = new White_Space_Column__c(
            Id = col2Id,
            Name = col2Name,
            Order__c = 2,
            White_Space__c = whiteSpaceId
        );

        White_Space_Cell__c cell1 = new White_Space_Cell__c(Name = cell1Name);

        mocks.startStubbing();
        mocks.when(mockSelector.selectByWhiteSpaceId(new Set<Id>{ whiteSpaceId }))
            .thenReturn(new List<White_Space_Row__c>{ row1, row2, row3 });
        mocks.when(mockColumnSelector.selectByWhiteSpaceId(new Set<Id>{ whiteSpaceId }))
            .thenReturn(new List<White_Space_Column__c>{ col1, col2 });
        mocks.when(mockCellSelector.selectByRowId(new Set<Id>{ row2Id }))
            .thenReturn(new List<White_Space_Cell__c>{ cell1 });
        mocks.stopStubbing();

        // When
        WhiteSpaceService.updateWhiteSpaceRows(
            whiteSpaceId,
            new List<White_Space_Row__c>{ updatedRow1, updatedRow3, updatedRow4 }
        );

        // Then
        try {
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerDeleted(row2);
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerDirty(updatedRow1);
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerDirty(updatedRow3);
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerNew(updatedRow4);
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1))
                .registerDeleted(new List<White_Space_Cell__c>{ cell1 });
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void updateWhiteSpaceColumnsTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WhiteSpaceColumnSelector mockSelector = (WhiteSpaceColumnSelector) FFLibHelper.mockSelector(
            WhiteSpaceColumnSelector.class,
            mocks
        );
        WhiteSpaceRowSelector mockRowSelector = (WhiteSpaceRowSelector) FFLibHelper.mockSelector(
            WhiteSpaceRowSelector.class,
            mocks
        );
        WhiteSpaceCellSelector mockCellSelector = (WhiteSpaceCellSelector) FFLibHelper.mockSelector(
            WhiteSpaceCellSelector.class,
            mocks
        );
        fflib_ISObjectUnitOfWork mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        Application.UnitOfWork.setMock(mockUow);
        Application.Selector.setMock(mockSelector);
        Application.Selector.setMock(mockRowSelector);
        Application.Selector.setMock(mockCellSelector);

        Id whiteSpaceId = fflib_IDGenerator.generate(White_Space__c.SObjectType);
        Id column1Id = fflib_IDGenerator.generate(White_Space_Column__c.SObjectType);
        Id column2Id = fflib_IDGenerator.generate(White_Space_Column__c.SObjectType);
        Id column3Id = fflib_IDGenerator.generate(White_Space_Column__c.SObjectType);
        Id row1Id = fflib_IDGenerator.generate(White_Space_Row__c.SObjectType);
        Id row2Id = fflib_IDGenerator.generate(White_Space_Row__c.SObjectType);
        String column1Name = 'column1';
        String column2Name = 'column2';
        String column3Name = 'column3';
        String column4Name = 'column4';
        String row1Name = 'row1';
        String row2Name = 'row2';
        String cell1Name = 'cell1';

        String column1NameUpdated = 'column1updatedName';
        String column3NameUpdated = 'column3updateName';

        White_Space_Column__c column1 = new White_Space_Column__c(
            Id = column1Id,
            Name = column1Name,
            Order__c = 1,
            White_Space__c = whiteSpaceId
        );
        White_Space_Column__c column2 = new White_Space_Column__c(
            Id = column2Id,
            Name = column2Name,
            Order__c = 2,
            White_Space__c = whiteSpaceId
        );
        White_Space_Column__c column3 = new White_Space_Column__c(
            Id = column3Id,
            Name = column3Name,
            Order__c = 3,
            White_Space__c = whiteSpaceId
        );

        White_Space_Column__c updatedcolumn1 = new White_Space_Column__c(
            Id = column1Id,
            Name = column1NameUpdated,
            Order__c = 1,
            White_Space__c = whiteSpaceId
        );
        White_Space_Column__c updatedcolumn3 = new White_Space_Column__c(
            Id = column3Id,
            Name = column3NameUpdated,
            Order__c = 2,
            White_Space__c = whiteSpaceId
        );
        White_Space_Column__c updatedcolumn4 = new White_Space_Column__c(
            Name = column4Name,
            Order__c = 3,
            White_Space__c = whiteSpaceId
        );
        White_Space_Row__c row1 = new White_Space_Row__c(
            Id = row1Id,
            Name = row1Name,
            Order__c = 1,
            White_Space__c = whiteSpaceId
        );
        White_Space_Row__c row2 = new White_Space_Row__c(
            Id = row2Id,
            Name = row2Name,
            Order__c = 2,
            White_Space__c = whiteSpaceId
        );

        White_Space_Cell__c cell1 = new White_Space_Cell__c(Name = cell1Name);

        mocks.startStubbing();
        mocks.when(mockSelector.selectByWhiteSpaceId(new Set<Id>{ whiteSpaceId }))
            .thenReturn(new List<White_Space_Column__c>{ column1, column2, column3 });
        mocks.when(mockRowSelector.selectByWhiteSpaceId(new Set<Id>{ whiteSpaceId }))
            .thenReturn(new List<White_Space_Row__c>{ row1, row2 });
        mocks.when(mockCellSelector.selectByColumnId(new Set<Id>{ column2Id }))
            .thenReturn(new List<White_Space_Cell__c>{ cell1 });
        mocks.stopStubbing();

        // When
        WhiteSpaceService.updateWhiteSpacecolumns(
            whiteSpaceId,
            new List<White_Space_Column__c>{ updatedcolumn1, updatedcolumn3, updatedcolumn4 }
        );

        // Then
        try {
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerDeleted(column2);
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerDirty(updatedcolumn1);
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerDirty(updatedcolumn3);
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerNew(updatedcolumn4);
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1))
                .registerDeleted(new List<White_Space_Cell__c>{ cell1 });
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void createWhiteSpaceCellsTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        Application.UnitOfWork.setMock(mockUow);

        Id whiteSpaceId = fflib_IDGenerator.generate(White_Space__c.SObjectType);
        Id column1Id = fflib_IDGenerator.generate(White_Space_Column__c.SObjectType);
        Id column2Id = fflib_IDGenerator.generate(White_Space_Column__c.SObjectType);
        Id column3Id = fflib_IDGenerator.generate(White_Space_Column__c.SObjectType);
        Id row1Id = fflib_IDGenerator.generate(White_Space_Row__c.SObjectType);
        Id row2Id = fflib_IDGenerator.generate(White_Space_Row__c.SObjectType);
        Set<Id> rowIds = new Set<Id>{ row1Id, row2Id };
        Set<Id> columnIds = new Set<Id>{ column1Id, column2Id, column3Id };

        White_Space_Cell__c cell1 = new White_Space_Cell__c(
            White_Space__c = whiteSpaceId,
            White_Space_Column__c = column1Id,
            White_Space_Row__c = row1Id
        );

        White_Space_Cell__c cell2 = new White_Space_Cell__c(
            White_Space__c = whiteSpaceId,
            White_Space_Column__c = column2Id,
            White_Space_Row__c = row2Id
        );

        List<White_Space_Cell__c> cells = new List<White_Space_Cell__c>{ cell1, cell2 };

        Integer expectedCount = (rowIds.size() * columnIds.size()) - cells.size();

        WhiteSpaceService.createWhiteSpaceCells(whiteSpaceId, columnIds, rowIds, cells);

        try {
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, expectedCount))
                .registerNew(fflib_Match.sObjectOfType(White_Space_Cell__c.SObjectType));
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Did not Call registerNew()');
        }
    }

    @isTest
    static void addNewWhitespaceCellTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        Application.UnitOfWork.setMock(mockUow);

        Id whiteSpaceId = fflib_IDGenerator.generate(White_Space__c.SObjectType);
        Id columnId = fflib_IDGenerator.generate(White_Space_Column__c.SObjectType);
        Id rowId = fflib_IDGenerator.generate(White_Space_Row__c.SObjectType);

        White_Space_Cell__c expectedCell = new White_Space_Cell__c(
            White_Space__c = whiteSpaceId,
            White_Space_Column__c = columnId,
            White_Space_Row__c = rowId
        );

        WhiteSpaceService.addNewWhitespaceCell(whiteSpaceId, columnId, rowId);

        try {
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerNew(expectedCell);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Did not Call registerNew()');
        }
    }

    @isTest
    static void deleteWhitespaceCellsTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        Application.UnitOfWork.setMock(mockUow);

        Id whiteSpaceId = fflib_IDGenerator.generate(White_Space__c.SObjectType);
        Id column1Id = fflib_IDGenerator.generate(White_Space_Column__c.SObjectType);
        Id row1Id = fflib_IDGenerator.generate(White_Space_Row__c.SObjectType);
        Id row2Id = fflib_IDGenerator.generate(White_Space_Row__c.SObjectType);

        White_Space_Cell__c cell1 = new White_Space_Cell__c(
            White_Space__c = whiteSpaceId,
            White_Space_Column__c = column1Id,
            White_Space_Row__c = row1Id
        );

        White_Space_Cell__c cell2 = new White_Space_Cell__c(
            White_Space__c = whiteSpaceId,
            White_Space_Column__c = column1Id,
            White_Space_Row__c = row2Id
        );

        List<White_Space_Cell__c> cells = new List<White_Space_Cell__c>{ cell1, cell2 };

        WhiteSpaceService.deleteWhitespaceCells(cells);

        try {
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerDeleted(cells);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Did not Call registerDeleted()');
        }
    }

    @isTest
    static void deleteWhitespaceTest() {
        // mocks
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork uow = md.mockUow;
        WhiteSpaceSelector wsSelector = md.mockWhiteSpaceSelector;

        List<White_Space__c> whiteSpaceList = new List<White_Space__c>{ md.mockWhiteSpace };
        Set<Id> mockWhitespaceIdSet = new Set<Id>{ md.mockWhiteSpaceId };

        md.mocks.startStubbing();
        md.mocks.when(wsSelector.selectById(mockWhitespaceIdSet)).thenReturn(whiteSpaceList);
        md.mocks.stopStubbing();

        // When
        WhiteSpaceService.deleteWhiteSpace(md.mockWhiteSpaceId);

        // Then
        try {
            ((fflib_ISObjectUnitOfWork) md.mocks.verify(uow, 1)).registerDeleted(whiteSpaceList);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Did not Call registerDeleted()');
        }
    }

    @isTest
    static void undeleteWhitespaceTest() {
        // Given
        User adminAdam = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME];
        White_Space__c ws = [SELECT Id FROM White_Space__c WHERE Name = :WHITE_SPACE1_NAME LIMIT 1];

        // When
        White_Space__c result;
        System.runAs(adminAdam) {
            delete ws;
            Test.startTest();
            result = WhiteSpaceService.undeleteWhiteSpace(ws.id);
            Test.stopTest();
        }

        // Then
        system.assertEquals(ws.id, result.id);
    }

    @isTest
    static void undeleteWhitespaceExceptionTest() {
        // Given
        User adminAdam = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME];
        User noAccessUser = [SELECT Id FROM User WHERE LastName = :USER2_LAST_NAME];
        White_Space__c ws = [SELECT Id FROM White_Space__c WHERE Name = :WHITE_SPACE1_NAME LIMIT 1];

        // When
        White_Space__c result;

        System.runAs(adminAdam) {
            delete ws;
        }

        System.runAs(noAccessUser) {
            Test.startTest();
            try {
                result = WhiteSpaceService.undeleteWhiteSpace(ws.id);
                system.assert(false);
            } catch (Exception e) {
                System.assert(true);
            }
            Test.stopTest();
        }
    }

    @isTest
    static void deleteWhitespaceColumnsTest() {
        // Mocks
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork uow = md.mockUow;
        WhiteSpaceCellSelector wsCellSelector = md.mockWhiteSpaceCellSelector;

        // Given
        White_Space_Column__c col1 = [SELECT Name FROM White_Space_Column__c WHERE Name = :WHITE_SPACE_COLUMN1_NAME];
        White_Space_Column__c col2 = [SELECT Name FROM White_Space_Column__c WHERE Name = :WHITE_SPACE_COLUMN2_NAME];
        White_Space_Cell__c cell1 = new White_Space_Cell__c(Name = 'test');

        List<White_Space_Column__c> columns = new List<White_Space_Column__c>{ col1, col2 };
        List<White_Space_Cell__C> cells = new List<White_Space_Cell__C>{ cell1 };
        Set<Id> columnIds = new Map<Id, White_Space_Column__c>(columns).keySet();

        md.mocks.startStubbing();
        md.mocks.when(wsCellSelector.selectByColumnId(columnIds)).thenReturn(cells);
        md.mocks.stopStubbing();

        // When
        WhiteSpaceService.deleteWhiteSpaceColumns(columns);

        // Then
        try {
            ((fflib_ISObjectUnitOfWork) md.mocks.verify(uow, 1)).registerDeleted(columns);
            ((fflib_ISObjectUnitOfWork) md.mocks.verify(uow, 1)).registerDeleted(cells);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Did not Call registerDeleted()');
        }
    }

    @isTest
    static void deleteWhitespaceColumnsAsSystemTest() {
        // Mocks
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork uow = md.mockUow;
        WhiteSpaceCellSelector wsCellSelector = md.mockWhiteSpaceCellSelector;
        User noAccessUser = [SELECT Id FROM User WHERE LastName = :USER2_LAST_NAME];

        // Given
        White_Space_Column__c col1 = [SELECT Name FROM White_Space_Column__c WHERE Name = :WHITE_SPACE_COLUMN1_NAME];
        White_Space_Column__c col2 = [SELECT Name FROM White_Space_Column__c WHERE Name = :WHITE_SPACE_COLUMN2_NAME];
        White_Space_Cell__c cell1 = new White_Space_Cell__c(Name = 'test');

        List<White_Space_Column__c> columns = new List<White_Space_Column__c>{ col1, col2 };
        List<White_Space_Cell__C> cells = new List<White_Space_Cell__C>{ cell1 };
        Set<Id> columnIds = new Map<Id, White_Space_Column__c>(columns).keySet();

        md.mocks.startStubbing();
        md.mocks.when(wsCellSelector.selectByColumnId(columnIds)).thenReturn(cells);
        md.mocks.stopStubbing();

        // When
        System.runAs(noAccessUser) {
            WhiteSpaceService.deleteWhiteSpaceColumns(columns);
        }

        // Then
        try {
            ((fflib_ISObjectUnitOfWork) md.mocks.verify(uow, 1)).registerDeleted(columns);
            ((fflib_ISObjectUnitOfWork) md.mocks.verify(uow, 1)).registerDeleted(cells);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Did not Call registerDeleted()');
        }
    }

    @isTest
    static void deleteWhitespaceRowsTest() {
        // Mocks
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork uow = md.mockUow;
        WhiteSpaceCellSelector wsCellSelector = md.mockWhiteSpaceCellSelector;

        // Given
        White_Space_Row__c row1 = [SELECT Name FROM White_Space_Row__c WHERE Name = :WHITE_SPACE_ROW1_NAME];
        White_Space_Row__c row2 = [SELECT Name FROM White_Space_Row__c WHERE Name = :WHITE_SPACE_ROW2_NAME];
        White_Space_Cell__c cell1 = new White_Space_Cell__c(Name = 'test');

        List<White_Space_Row__c> rows = new List<White_Space_Row__c>{ row1, row2 };
        List<White_Space_Cell__C> cells = new List<White_Space_Cell__C>{ cell1 };
        Set<Id> rowIds = new Map<Id, White_Space_Row__c>(rows).keySet();

        md.mocks.startStubbing();
        md.mocks.when(wsCellSelector.selectByRowId(rowIds)).thenReturn(cells);
        md.mocks.stopStubbing();

        // When
        WhiteSpaceService.deleteWhiteSpaceRows(rows);

        // Then
        try {
            ((fflib_ISObjectUnitOfWork) md.mocks.verify(uow, 1)).registerDeleted(rows);
            ((fflib_ISObjectUnitOfWork) md.mocks.verify(uow, 1)).registerDeleted(cells);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Did not Call registerDeleted()');
        }
    }

    @isTest
    static void deleteWhitespaceRowsAsSystemTest() {
        // Mocks
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork uow = md.mockUow;
        WhiteSpaceCellSelector wsCellSelector = md.mockWhiteSpaceCellSelector;

        // Given
        User noAccessUser = [SELECT Id FROM User WHERE LastName = :USER2_LAST_NAME];
        White_Space_Row__c row1 = [SELECT Name FROM White_Space_Row__c WHERE Name = :WHITE_SPACE_ROW1_NAME];
        White_Space_Row__c row2 = [SELECT Name FROM White_Space_Row__c WHERE Name = :WHITE_SPACE_ROW2_NAME];
        White_Space_Cell__c cell1 = new White_Space_Cell__c(Name = 'test');

        List<White_Space_Row__c> rows = new List<White_Space_Row__c>{ row1, row2 };
        List<White_Space_Cell__C> cells = new List<White_Space_Cell__C>{ cell1 };
        Set<Id> rowIds = new Map<Id, White_Space_Row__c>(rows).keySet();

        md.mocks.startStubbing();
        md.mocks.when(wsCellSelector.selectByRowId(rowIds)).thenReturn(cells);
        md.mocks.stopStubbing();

        // When
        System.runAs(noAccessUser) {
            WhiteSpaceService.deleteWhiteSpaceRows(rows);
        }

        // Then
        try {
            ((fflib_ISObjectUnitOfWork) md.mocks.verify(uow, 1)).registerDeleted(rows);
            ((fflib_ISObjectUnitOfWork) md.mocks.verify(uow, 1)).registerDeleted(cells);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Did not Call registerDeleted()');
        }
    }
}