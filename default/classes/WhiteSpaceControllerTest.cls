@isTest
private class WhiteSpaceControllerTest {
    public static final String USER1_FIRST_NAME = 'admin';
    public static final String USER1_LAST_NAME = 'adam';

    public static final String USER2_FIRST_NAME = 'standard';
    public static final String USER2_LAST_NAME = 'suzie';

    public static final String USER3_FIRST_NAME = 'creator';
    public static final String USER3_LAST_NAME = 'cal';

    public static final String USER4_FIRST_NAME = 'no';
    public static final String USER4_LAST_NAME = 'permission';

    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';
    public static final String CRUSH_ACCOUNT_PLAN_CREATOR = 'CRUSH_Account_Plan_Creator';

    public static final String ACCOUNT1_NAME = 'zzzzAccount 1';
    public static final String OPPORTUNITY_NAME = 'testOpportunity';
    public static final String ACCOUNT_PLAN1_NAME = 'AccountPlan1';
    public static final String WHITE_SPACE1_NAME = 'WhiteSpace1';
    public static final String WHITE_SPACE_ROW1_NAME = 'row1';
    public static final String WHITE_SPACE_ROW2_NAME = 'row2';
    public static final String WHITE_SPACE_COLUMN1_NAME = 'column1';
    public static final String WHITE_SPACE_COLUMN2_NAME = 'column2';
    public static final String WHITE_SPACE_AMOUNT_TYPE_NAME = 'testAmountType';

    public static final String WHITE_SPACE_TEMPLATE_NAME = 'testTemplate';
    public static final String COLUMN_OBJECT_NAME = 'Account';
    public static final String ROW_OBJECT_NAME = 'Opportunity';
    public static final String COLUMN_LABEL_FIELD_NAME = 'Name';
    public static final String ROW_LABEL_FIELD_NAME = 'Name';

    public static final String STANDARD_USER = 'Standard User';

    @testSetup
    static void testSetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];
        User adminAdam = TestDataFactory.createUser(USER1_FIRST_NAME, USER1_LAST_NAME, p.Id);
        User standardSuzie = TestDataFactory.createUser(USER2_FIRST_NAME, USER2_LAST_NAME, p.Id);
        User creatorCal = TestDataFactory.createUser(USER3_FIRST_NAME, USER3_LAST_NAME, p.Id);
        TestDataFactory.createUser(USER4_FIRST_NAME, USER4_LAST_NAME, p.Id);

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
            TestDataFactory.createWhiteSpaceCells(
                ws.id,
                new Set<Id>{ col1.id, col2.id },
                new Set<Id>{ row1.id, row2.id }
            );
            TestDataFactory.createWhiteSpaceAmountType(WHITE_SPACE_AMOUNT_TYPE_NAME);

            Opportunity testOpportunity = TestDataFactory.createOpportunity(testAccount1, OPPORTUNITY_NAME);
            insert testOpportunity;
            TestDataFactory.createWhiteSpaceTemplate(
                WHITE_SPACE_TEMPLATE_NAME,
                COLUMN_OBJECT_NAME,
                COLUMN_LABEL_FIELD_NAME,
                ROW_OBJECT_NAME,
                ROW_LABEL_FIELD_NAME
            );
        }
    }

    @isTest
    static void getWhiteSpaceObjectAccessForAccountPlanAccessPositiveTest() {
        // Given
        User adminAdam = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME];
        Account_Plan__c ap = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME LIMIT 1];

        // When
        Test.startTest();
        WhiteSpaceObjectAccess result;
        System.runAs(adminAdam) {
            result = WhiteSpaceController.getWhiteSpaceObjectAccessForAccountPlan(ap.id);
        }
        Test.stopTest();

        // Then
        System.assertEquals(true, result.canCreate);
        System.assertEquals(true, result.canUpdate);
        System.assertEquals(true, result.canDelete);
        System.assertEquals(true, result.canUpdateRows);
        System.assertEquals(true, result.canAddRows);
        System.assertEquals(true, result.canDeleteRows);
        System.assertEquals(true, result.canUpdateColumns);
        System.assertEquals(true, result.canAddColumns);
        System.assertEquals(true, result.canDeleteColumns);
        System.assertEquals(true, result.canUpdateCells);
        System.assertEquals(true, result.canAddCells);
        System.assertEquals(true, result.canDeleteCells);
    }

    @isTest
    static void getWhiteSpaceForAccountPlanTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WhiteSpaceSelector mockSelector = (WhiteSpaceSelector) FFLibHelper.mockSelector(
            WhiteSpaceSelector.class,
            mocks
        );
        Application.Selector.setMock(mockSelector);

        // When
        Id whiteSpaceId = fflib_IDGenerator.generate(White_Space__c.SObjectType);
        Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);

        White_Space__c ws1 = new White_Space__c(Id = whiteSpaceId, Account_Plan__c = accountPlanId, Name = 'WS1');

        mocks.startStubbing();
        mocks.when(mockSelector.selectFirstWithGridDataByAccountPlanId(accountPlanId)).thenReturn(ws1);
        mocks.stopStubbing();

        WhiteSpaceAbstract result = WhiteSpaceController.getWhiteSpaceForAccountPlan(accountPlanId);

        System.assertEquals(whiteSpaceId, result.Id);
    }

    @isTest
    static void getWhiteSpaceForAccountPlanNullTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WhiteSpaceSelector mockSelector = (WhiteSpaceSelector) FFLibHelper.mockSelector(
            WhiteSpaceSelector.class,
            mocks
        );
        Application.Selector.setMock(mockSelector);

        // When
        Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);

        mocks.startStubbing();
        mocks.when(mockSelector.selectFirstWithGridDataByAccountPlanId(accountPlanId)).thenReturn(null);
        mocks.stopStubbing();

        WhiteSpaceAbstract result = WhiteSpaceController.getWhiteSpaceForAccountPlan(accountPlanId);

        System.assertEquals(null, result);
    }

    @isTest
    static void createWhiteSpaceTest() {
        // Given
        Account_Plan__c ap = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME LIMIT 1];
        List<String> rowNames = new List<String>{ WHITE_SPACE_ROW1_NAME, WHITE_SPACE_ROW2_NAME };
        List<String> colNames = new List<String>{ WHITE_SPACE_COLUMN1_NAME, WHITE_SPACE_COLUMN2_NAME };

        // When
        WhiteSpaceAbstract result = WhiteSpaceController.createWhiteSpace(ap.Id, WHITE_SPACE1_NAME, rowNames, colNames);

        // Then
        System.assertEquals(2, result.columns.size());
        System.assertEquals(2, result.rows.size());
        System.assertEquals(4, result.cells.size());
    }

    @isTest
    static void createWhiteSpaceFromTemplateTest() {
        // Given
        Account_Plan__c ap = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME LIMIT 1];
        White_Space_Template__c template = [
            SELECT Id
            FROM White_Space_Template__c
            WHERE Name = :WHITE_SPACE_TEMPLATE_NAME
            LIMIT 1
        ];
        Account expectedAcc = [SELECT Id FROM Account WHERE Name = :ACCOUNT1_NAME LIMIT 1];
        Opportunity expectedOpp = [SELECT Id FROM Opportunity WHERE Name = :OPPORTUNITY_NAME LIMIT 1];

        // When
        WhiteSpaceAbstract result = WhiteSpaceController.createWhiteSpaceFromTemplate(
            new White_Space__c(Account_Plan__c = ap.Id, White_Space_Template__c = template.id)
        );

        // Then
        // System.assertEquals(template.id, result.template.id);
        System.assertEquals(1, result.columns.size());
        System.assertEquals(expectedAcc.id, result.columns[0].collection.get('pqcrush__Related_Object_Id__c'));
        System.assertEquals(expectedAcc.id, result.columns[0].relatedObjectId);
        System.assertEquals(ACCOUNT1_NAME, result.columns[0].name);
        System.assertEquals(1, result.rows.size());
        System.assertEquals(expectedOpp.id, result.rows[0].collection.get('pqcrush__Related_Object_Id__c'));
        System.assertEquals(expectedOpp.id, result.rows[0].relatedObjectId);
        System.assertEquals(OPPORTUNITY_NAME, result.rows[0].name);
        System.assertEquals(1, result.cells.size());
    }

    @isTest
    static void createWhiteSpaceFromTemplateWithPicklistHeadersTest() {
        // Given
        Mapping__c columnMapping = new Mapping__c(
            Name = 'column',
            ObjectType__c = 'Opportunity',
            ValueField__c = 'Type'
        );

        Mapping__c rowMapping = new Mapping__c(Name = 'row', DisplayLabelField__c = 'Name', ObjectType__c = 'Account');

        White_Space_Template__c template = TestDataFactory.createWhiteSpaceTemplate(
            'picklistTemplate',
            columnMapping,
            rowMapping
        );

        Account_Plan__c ap = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME LIMIT 1];
        Account expectedAcc = [SELECT Id FROM Account WHERE Name = :ACCOUNT1_NAME LIMIT 1];
        Integer expectedColumnSize = UtilityForSObject.getPicklistSelectOptions(
                columnMapping.ObjectType__c,
                columnMapping.ValueField__c
            )
            .size();

        // When
        WhiteSpaceAbstract result = WhiteSpaceController.createWhiteSpaceFromTemplate(
            new White_Space__c(Account_Plan__c = ap.Id, White_Space_Template__c = template.id)
        );

        // Then
        System.assertEquals(expectedColumnSize, result.columns.size());
        System.assertEquals(1, result.rows.size());
        System.assertEquals(expectedAcc.id, result.rows[0].collection.get('pqcrush__Related_Object_Id__c'));
        System.assertEquals(expectedAcc.id, result.rows[0].relatedObjectId);
        System.assertEquals(ACCOUNT1_NAME, result.rows[0].name);
        System.assertEquals(expectedColumnSize * 1, result.cells.size());
    }

    @isTest
    static void updateWhiteSpaceTileWithWSIDTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceServiceImpl mockService = md.mockWhiteSpaceService;
        WhiteSpaceUtilsImpl mockUtils = md.mockWhiteSpaceUtils;
        WhiteSpaceAmountTypeSelector mockATSelector = md.mockWhiteSpaceAmountTypeSelector;
        WhiteSpaceSelector mockWSSelector = md.mockWhiteSpaceSelector;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test

        White_Space_Cell__c unwrappedCell = new White_Space_Cell__c(
            Id = md.mockWhiteSpaceCellId,
            Info__c = null,
            Primary_Amount_Type__c = null
        );

        md.mocks.startStubbing();
        md.mocks.when(mockService.updateWhiteSpaceCell(unwrappedCell)).thenReturn(md.mockWhiteSpaceCell);
        md.mocks.when(mockWSSelector.selectById(md.mockWhiteSpaceId)).thenReturn(md.mockWhiteSpace);
        md.mocks.when(mockUtils.getWSRelatedObjectWrappers()).thenReturn(new List<WSRelatedObjectWrapper>());
        md.mocks.when(mockATSelector.selectAll())
            .thenReturn(new List<pqcrush__White_Space_Amount_Type__c>{ md.mockWhiteSpaceAmountType });
        md.mocks.stopStubbing();

        WhiteSpaceController.updateWhiteSpaceTile(md.mockWhiteSpaceTileWrapper, md.mockWhiteSpaceId);

        ((WhiteSpaceSelector) md.mocks.verify(mockWSSelector, 1)).selectById(md.mockWhiteSpaceId);
        System.assert(true, 'verified by mocks');
    }

    @isTest
    static void updateWhiteSpaceTileNoDisplayFieldsTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceServiceImpl mockService = md.mockWhiteSpaceService;
        WhiteSpaceUtilsImpl mockUtils = md.mockWhiteSpaceUtils;
        WhiteSpaceAmountTypeSelector mockATSelector = md.mockWhiteSpaceAmountTypeSelector;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUow;

        White_Space_Cell__c unwrappedCell = new White_Space_Cell__c(
            Id = md.mockWhiteSpaceCellId,
            Info__c = null,
            Primary_Amount_Type__c = null
        );

        md.mocks.startStubbing();
        md.mocks.when(mockService.updateWhiteSpaceCell(unwrappedCell)).thenReturn(md.mockWhiteSpaceCell);
        md.mocks.when(mockUtils.getWSRelatedObjectWrappers()).thenReturn(new List<WSRelatedObjectWrapper>());
        md.mocks.when(mockATSelector.selectAll())
            .thenReturn(new List<pqcrush__White_Space_Amount_Type__c>{ md.mockWhiteSpaceAmountType });
        md.mocks.stopStubbing();

        WhiteSpaceTileWrapper result = WhiteSpaceController.updateWhiteSpaceTile(md.mockWhiteSpaceTileWrapper, null);

        System.assertEquals(md.mockWhiteSpaceCellId, result.id);
        System.assertEquals(2, result.displayFields.size());
        System.assertEquals(md.mockWhiteSpaceAmountTypeId, result.displayFields[1].id);
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0))
            .registerDirty(fflib_Match.sObjectOfType(White_Space_Amount_Type_Association__c.SObjectType));
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0))
            .registerNew(fflib_Match.sObjectOfType(White_Space_Amount_Type_Association__c.SObjectType));
    }

    @isTest
    static void updateWhiteSpaceTileWithDisplayFieldsNoAssociationsTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceServiceImpl mockService = md.mockWhiteSpaceService;
        WhiteSpaceUtilsImpl mockUtils = md.mockWhiteSpaceUtils;
        WhiteSpaceAmountTypeSelector mockATSelector = md.mockWhiteSpaceAmountTypeSelector;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUow;

        White_Space_Cell__c unwrappedCell = new White_Space_Cell__c(
            Id = md.mockWhiteSpaceCellId,
            Info__c = 'Info Text',
            Primary_Amount_Type__c = md.mockWhiteSpaceAmountTypeId
        );

        WhiteSpaceDisplayFieldWrapper infoWrapper = WhiteSpaceDisplayFieldWrapper.infoFieldWrapper(unwrappedCell);
        WhiteSpaceDisplayFieldWrapper atWrapper = md.mockDisplayFieldWrapper;
        atWrapper.isPrimary = true;
        WhiteSpaceTileWrapper mockWrapper = md.mockWhiteSpaceTileWrapper;
        mockWrapper.displayFields = new List<WhiteSpaceDisplayFieldWrapper>{ infoWrapper, atWrapper };

        md.mocks.startStubbing();
        md.mocks.when(mockService.updateWhiteSpaceCell(unwrappedCell)).thenReturn(md.mockWhiteSpaceCell);
        md.mocks.when(mockUtils.getWSRelatedObjectWrappers()).thenReturn(new List<WSRelatedObjectWrapper>());
        md.mocks.when(mockATSelector.selectAll())
            .thenReturn(new List<pqcrush__White_Space_Amount_Type__c>{ md.mockWhiteSpaceAmountType });
        md.mocks.stopStubbing();

        WhiteSpaceTileWrapper result = WhiteSpaceController.updateWhiteSpaceTile(mockWrapper, null);

        System.assertEquals(md.mockWhiteSpaceCellId, result.id);
        System.assertEquals(2, result.displayFields.size());
        System.assertEquals(md.mockWhiteSpaceAmountTypeId, result.displayFields[1].id);
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0))
            .registerDirty(fflib_Match.sObjectOfType(White_Space_Amount_Type_Association__c.SObjectType));
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0))
            .registerNew(fflib_Match.sObjectOfType(White_Space_Amount_Type_Association__c.SObjectType));
    }

    @isTest
    static void updateWhiteSpaceTileWithDisplayFieldsNewAssociationTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceServiceImpl mockService = md.mockWhiteSpaceService;
        WhiteSpaceAmountTypeSelector mockATSelector = md.mockWhiteSpaceAmountTypeSelector;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUow;

        White_Space_Cell__c unwrappedCell = new White_Space_Cell__c(
            Id = md.mockWhiteSpaceCellId,
            Info__c = 'Info Text',
            Primary_Amount_Type__c = md.mockWhiteSpaceAmountTypeId
        );

        WhiteSpaceDisplayFieldDataWrapper mockNewData = new WhiteSpaceDisplayFieldDataWrapper();
        mockNewData.value = 5;
        mockNewData.objectId = null;
        mockNewData.displayName = md.mockWhiteSpaceAmountType.Name;
        WhiteSpaceDisplayFieldWrapper infoWrapper = WhiteSpaceDisplayFieldWrapper.infoFieldWrapper(unwrappedCell);
        WhiteSpaceDisplayFieldWrapper atWrapper = md.mockDisplayFieldWrapper;
        atWrapper.isPrimary = true;
        atWrapper.data.add(mockNewData);
        WhiteSpaceTileWrapper mockWrapper = md.mockWhiteSpaceTileWrapper;
        mockWrapper.displayFields = new List<WhiteSpaceDisplayFieldWrapper>{ infoWrapper, atWrapper };

        md.mocks.startStubbing();
        md.mocks.when(mockService.updateWhiteSpaceCell(unwrappedCell)).thenReturn(md.mockWhiteSpaceCell);
        md.mocks.when(mockATSelector.selectAll())
            .thenReturn(new List<pqcrush__White_Space_Amount_Type__c>{ md.mockWhiteSpaceAmountType });
        md.mocks.stopStubbing();

        WhiteSpaceTileWrapper result = WhiteSpaceController.updateWhiteSpaceTile(mockWrapper, null);

        System.assertEquals(md.mockWhiteSpaceCellId, result.id, 'returned wrapper should be for expected cell');
        Integer count = 0;
        WhiteSpaceDisplayFieldWrapper foundDf;
        for (WhiteSpaceDisplayFieldWrapper df : result.displayFields) {
            if (df.fieldType == 'amountType') {
                count++;
                foundDf = df;
            }
        }
        System.assertEquals(1, count, 'returned wrapper should have one amount type display field');
        System.assertEquals(
            md.mockWhiteSpaceAmountTypeId,
            foundDf.id,
            'returned wrapper should have expected amount type'
        );
        System.assertEquals(1, foundDf.data.size(), 'returned wrapper should have one amount type association');
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0))
            .registerDirty(fflib_Match.sObjectOfType(White_Space_Amount_Type_Association__c.SObjectType));
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew(fflib_Match.sObjectOfType(White_Space_Amount_Type_Association__c.SObjectType));
    }

    @isTest
    static void updateWhiteSpaceTileWithDisplayFieldsEditAssociationTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceServiceImpl mockService = md.mockWhiteSpaceService;
        WhiteSpaceUtilsImpl mockUtils = md.mockWhiteSpaceUtils;
        WhiteSpaceAmountTypeSelector mockATSelector = md.mockWhiteSpaceAmountTypeSelector;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUow;

        White_Space_Cell__c unwrappedCell = new White_Space_Cell__c(
            Id = md.mockWhiteSpaceCellId,
            Info__c = 'Info Text',
            Primary_Amount_Type__c = md.mockWhiteSpaceAmountTypeId
        );

        WhiteSpaceDisplayFieldDataWrapper mockNewData = new WhiteSpaceDisplayFieldDataWrapper();
        mockNewData.value = 5;
        mockNewData.objectId = md.mockWhiteSpaceAmountTypeAssociationId;
        mockNewData.displayName = md.mockWhiteSpaceAmountType.Name;
        WhiteSpaceDisplayFieldWrapper infoWrapper = WhiteSpaceDisplayFieldWrapper.infoFieldWrapper(unwrappedCell);
        WhiteSpaceDisplayFieldWrapper atWrapper = md.mockDisplayFieldWrapper;
        atWrapper.isPrimary = true;
        atWrapper.data.add(mockNewData);
        WhiteSpaceTileWrapper mockWrapper = md.mockWhiteSpaceTileWrapper;
        mockWrapper.displayFields = new List<WhiteSpaceDisplayFieldWrapper>{ infoWrapper, atWrapper };

        md.mocks.startStubbing();
        md.mocks.when(mockService.updateWhiteSpaceCell(unwrappedCell)).thenReturn(md.mockWhiteSpaceCell);
        md.mocks.when(mockUtils.getWSRelatedObjectWrappers()).thenReturn(new List<WSRelatedObjectWrapper>());
        md.mocks.when(mockATSelector.selectAll())
            .thenReturn(new List<pqcrush__White_Space_Amount_Type__c>{ md.mockWhiteSpaceAmountType });
        md.mocks.stopStubbing();

        WhiteSpaceTileWrapper result = WhiteSpaceController.updateWhiteSpaceTile(mockWrapper, null);

        System.assertEquals(md.mockWhiteSpaceCellId, result.id, 'returned wrapper should be for expected cell');
        System.assertEquals(2, result.displayFields.size(), 'returned wrapper should have two display fields');
        System.assertEquals(
            md.mockWhiteSpaceAmountTypeId,
            result.displayFields[1].id,
            'returned wrapper should have expected amount type'
        );
        System.assertEquals(
            1,
            result.displayFields[1].data.size(),
            'returned wrapper should have one amount type association'
        );
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerDirty(fflib_Match.sObjectOfType(White_Space_Amount_Type_Association__c.SObjectType));
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0))
            .registerNew(fflib_Match.sObjectOfType(White_Space_Amount_Type_Association__c.SObjectType));

        //verify that if a displayField doesn't have an id or is not editable that it doesn't update/create objects
    }

    @isTest
    static void updateWhiteSpaceTileWithDisplayFieldsNotEditableTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceServiceImpl mockService = md.mockWhiteSpaceService;
        WhiteSpaceUtilsImpl mockUtils = md.mockWhiteSpaceUtils;
        WhiteSpaceAmountTypeSelector mockATSelector = md.mockWhiteSpaceAmountTypeSelector;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUow;

        White_Space_Cell__c unwrappedCell = new White_Space_Cell__c(
            Id = md.mockWhiteSpaceCellId,
            Info__c = 'Info Text',
            Primary_Amount_Type__c = md.mockWhiteSpaceAmountTypeId
        );

        WhiteSpaceDisplayFieldDataWrapper mockNewData = new WhiteSpaceDisplayFieldDataWrapper();
        mockNewData.value = 5;
        mockNewData.objectId = md.mockWhiteSpaceAmountTypeAssociationId;
        mockNewData.displayName = md.mockWhiteSpaceAmountType.Name;
        WhiteSpaceDisplayFieldWrapper infoWrapper = WhiteSpaceDisplayFieldWrapper.infoFieldWrapper(unwrappedCell);
        WhiteSpaceDisplayFieldWrapper atWrapper = md.mockDisplayFieldWrapper;
        atWrapper.isPrimary = true;
        atWrapper.isEditable = false;
        atWrapper.data.add(mockNewData);
        WhiteSpaceTileWrapper mockWrapper = md.mockWhiteSpaceTileWrapper;
        mockWrapper.displayFields = new List<WhiteSpaceDisplayFieldWrapper>{ infoWrapper, atWrapper };

        md.mocks.startStubbing();
        md.mocks.when(mockService.updateWhiteSpaceCell(unwrappedCell)).thenReturn(md.mockWhiteSpaceCell);
        md.mocks.when(mockUtils.getWSRelatedObjectWrappers()).thenReturn(new List<WSRelatedObjectWrapper>());
        md.mocks.when(mockATSelector.selectAll())
            .thenReturn(new List<pqcrush__White_Space_Amount_Type__c>{ md.mockWhiteSpaceAmountType });
        md.mocks.stopStubbing();

        WhiteSpaceTileWrapper result = WhiteSpaceController.updateWhiteSpaceTile(mockWrapper, null);

        System.assertEquals(md.mockWhiteSpaceCellId, result.id, 'returned wrapper should be for expected cell');
        System.assertEquals(2, result.displayFields.size(), 'returned wrapper should have two display fields');
        System.assertEquals(
            md.mockWhiteSpaceAmountTypeId,
            result.displayFields[1].id,
            'returned wrapper should have expected amount type'
        );
        System.assertEquals(
            0,
            result.displayFields[1].data.size(),
            'returned wrapper should not have any amount type associations'
        );
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0))
            .registerDirty(fflib_Match.sObjectOfType(White_Space_Amount_Type_Association__c.SObjectType));
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0))
            .registerNew(fflib_Match.sObjectOfType(White_Space_Amount_Type_Association__c.SObjectType));
    }

    @isTest
    static void updateWhiteSpaceTileWithDisplayFieldsNoIdTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceServiceImpl mockService = md.mockWhiteSpaceService;
        WhiteSpaceUtilsImpl mockUtils = md.mockWhiteSpaceUtils;
        WhiteSpaceAmountTypeSelector mockATSelector = md.mockWhiteSpaceAmountTypeSelector;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUow;

        White_Space_Cell__c unwrappedCell = new White_Space_Cell__c(
            Id = md.mockWhiteSpaceCellId,
            Info__c = 'Info Text',
            Primary_Amount_Type__c = md.mockWhiteSpaceAmountTypeId
        );

        WhiteSpaceDisplayFieldDataWrapper mockNewData = new WhiteSpaceDisplayFieldDataWrapper();
        mockNewData.value = 5;
        mockNewData.objectId = null;
        mockNewData.displayName = md.mockWhiteSpaceAmountType.Name;
        WhiteSpaceDisplayFieldWrapper infoWrapper = WhiteSpaceDisplayFieldWrapper.infoFieldWrapper(unwrappedCell);
        WhiteSpaceDisplayFieldWrapper atWrapper = md.mockDisplayFieldWrapper;
        atWrapper.isPrimary = true;

        md.mockDisplayFieldWrapper = null;
        WhiteSpaceDisplayFieldWrapper atWrapperNull = md.mockDisplayFieldWrapper;
        atWrapperNull.id = null;
        atWrapperNull.data.add(mockNewData);
        WhiteSpaceTileWrapper mockWrapper = md.mockWhiteSpaceTileWrapper;
        mockWrapper.displayFields = new List<WhiteSpaceDisplayFieldWrapper>{ infoWrapper, atWrapper };

        md.mocks.startStubbing();
        md.mocks.when(mockService.updateWhiteSpaceCell(unwrappedCell)).thenReturn(md.mockWhiteSpaceCell);
        md.mocks.when(mockUtils.getWSRelatedObjectWrappers()).thenReturn(new List<WSRelatedObjectWrapper>());
        md.mocks.when(mockATSelector.selectAll())
            .thenReturn(new List<pqcrush__White_Space_Amount_Type__c>{ md.mockWhiteSpaceAmountType });
        md.mocks.stopStubbing();

        WhiteSpaceTileWrapper result = WhiteSpaceController.updateWhiteSpaceTile(mockWrapper, null);

        System.assertEquals(md.mockWhiteSpaceCellId, result.id, 'returned wrapper should be for expected cell');
        System.assertEquals(2, result.displayFields.size(), 'returned wrapper should have two display fields');
        System.assertEquals(
            md.mockWhiteSpaceAmountTypeId,
            result.displayFields[1].id,
            'returned wrapper should have expected amount type'
        );
        System.assertEquals(
            0,
            result.displayFields[1].data.size(),
            'returned wrapper should have no matching amount type association'
        );
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0))
            .registerDirty(fflib_Match.sObjectOfType(White_Space_Amount_Type_Association__c.SObjectType));
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0))
            .registerNew(fflib_Match.sObjectOfType(White_Space_Amount_Type_Association__c.SObjectType));
    }

    @isTest
    static void createWhiteSpaceTileTest() {
        // Given
        TestMockData md = new TestMockData();
        WhiteSpaceServiceImpl mockService = md.mockWhiteSpaceService;
        WhiteSpaceAmountTypeSelector mockSelector = md.mockWhiteSpaceAmountTypeSelector;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test

        // When
        md.mocks.startStubbing();
        md.mocks.when(mockSelector.selectAll()).thenReturn(new List<White_Space_Amount_Type__c>());
        md.mocks.when(
                mockService.addNewWhitespaceCell(md.mockWhiteSpaceId, md.mockWhiteSpaceColumnId, md.mockWhiteSpaceRowId)
            )
            .thenReturn(md.mockWhiteSpaceCell);
        md.mocks.stopStubbing();

        Test.startTest();
        WhiteSpaceTileWrapper result = WhiteSpaceController.createWhiteSpaceTile(
            md.mockWhiteSpaceColumnId,
            md.mockWhiteSpaceRowId,
            md.mockWhiteSpaceId
        );
        Test.stopTest();

        // Then
        System.assertEquals(
            md.mockWhiteSpaceCellId,
            result.id,
            'id of result should match id of the cell that was created'
        );
        System.assertEquals(null, result.headerColor, 'header color should be null since no amount types');
        System.assertEquals(null, result.headerText, 'header text should be null since no amount types');
        Integer count = 0;
        for (WhiteSpaceDisplayFieldWrapper df : result.displayFields) {
            if (df.fieldType == 'amountType') {
                count++;
            }
        }
        System.assertEquals(0, count, 'display fields should not have any amount types');
    }

    @isTest
    static void deleteWhiteSpaceTileTest() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);

        Application.unitOfWork.setMock(mockUow);

        Id cellId = fflib_IDGenerator.generate(White_Space_Cell__c.SObjectType);

        White_Space_Cell__c expectedCell = new White_Space_Cell__c(Id = cellId);

        List<White_Space_Cell__c> expectedDeleteCells = new List<White_Space_Cell__c>{ expectedCell };

        // When
        Test.startTest();
        WhiteSpaceController.deleteWhiteSpaceTile(cellId);
        Test.stopTest();

        // Then
        try {
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerDeleted(expectedDeleteCells);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Did not Call registerDeleted()');
        }
    }

    @isTest
    static void deleteWhiteSpaceTest() {
        // Given
        TestMockData md = new TestMockData();
        WhiteSpaceServiceImpl wss = md.mockWhiteSpaceService;

        // When
        Test.startTest();
        WhiteSpaceController.deleteWhiteSpace(md.mockWhiteSpaceId);
        Test.stopTest();

        // Then
        try {
            ((WhiteSpaceServiceImpl) md.mocks.verify(wss, 1)).deleteWhiteSpace(md.mockWhiteSpaceId);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Did not Call deleteWhiteSpace()');
        }
    }

    @isTest
    static void undeleteWhiteSpaceTest() {
        // Given
        TestMockData md = new TestMockData();
        WhiteSpaceServiceImpl wsService = md.mockWhiteSpaceService;
        WhiteSpaceSelector wsSelector = md.mockWhiteSpaceSelector;

        md.mocks.startStubbing();
        md.mocks.when(wsService.undeleteWhiteSpace(md.mockWhiteSpaceId)).thenReturn(md.mockWhiteSpace);
        md.mocks.when(wsSelector.selectById(md.mockWhiteSpaceId)).thenReturn(md.mockWhiteSpace);
        md.mocks.stopStubbing();

        WhiteSpaceAbstract result;
        // When
        Test.startTest();
        result = WhiteSpaceController.undeleteWhiteSpace(md.mockWhiteSpaceId);
        Test.stopTest();

        // Then
        ((WhiteSpaceServiceImpl) md.mocks.verify(wsService, 1)).undeleteWhiteSpace(md.mockWhiteSpaceId);
        System.assertEquals(md.mockWhiteSpaceId, result.id);
    }

    @isTest
    static void getSummaryFormulasTest() {
        // Given
        TestMockData md = new TestMockData();
        WSSummaryFormulaServiceImpl wsService = md.mockWSSummaryFormulaService;

        md.mocks.startStubbing();
        md.mocks.when(wsService.getSummaryFormulas(md.mockWhiteSpaceId)).thenReturn(new List<WS_Summary_Formula__c>());
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        WhiteSpaceController.getSummaryFormulas(md.mockWhiteSpaceId);
        Test.stopTest();

        // Then
        ((WSSummaryFormulaServiceImpl) md.mocks.verify(wsService, 1)).getSummaryFormulas(md.mockWhiteSpaceId);
        System.assert(true, 'Assert from mock verify');
    }

    @isTest
    static void getHighlightsTest() {
        // Given
        TestMockData md = new TestMockData();
        WhiteSpaceHighlightServiceImpl mockWhiteSpaceHighlightService = md.mockWhiteSpaceHighlightService;

        // When
        Test.startTest();
        WhiteSpaceController.getHighlights(md.mockWhiteSpaceId);
        Test.stopTest();

        // Then
        ((WhiteSpaceHighlightServiceImpl) md.mocks.verify(mockWhiteSpaceHighlightService, 1))
            .getHighlightsForWhiteSpace(md.mockWhiteSpaceId);
        System.assert(true, 'Assert from mock verify');
    }

    @isTest
    static void setHighlightTest() {
        // Given
        TestMockData md = new TestMockData();
        WhiteSpaceCellSelector mockCellSelector = md.mockWhiteSpaceCellSelector;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test

        md.mocks.startStubbing();
        md.mocks.when(mockCellSelector.selectById(new Set<Id>{ md.mockWhiteSpaceCellId }))
            .thenReturn(new List<White_Space_Cell__c>());
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        try {
            WhiteSpaceController.setHighlight(md.mockWhiteSpaceCellId, md.mockWSHighlightId);
            System.assert(false, 'Exception should be thrown');
        } catch (Exception e) {
            System.assert(true, 'Exception was thrown.');
        }
        Test.stopTest();
    }

    @isTest
    static void setHighlightTest2() {
        // Given
        TestMockData md = new TestMockData();
        WhiteSpaceCellSelector mockCellSelector = md.mockWhiteSpaceCellSelector;
        WSHighlightSelector mockHighlightSelector = md.mockWSHighlightSelector;
        fflib_ISObjectUnitOfWork mockUoW = md.mockUow;

        md.mocks.startStubbing();
        md.mocks.when(mockCellSelector.selectById(new Set<Id>{ md.mockWhiteSpaceCellId }))
            .thenReturn(new List<White_Space_Cell__c>{ md.mockWhiteSpaceCell });
        md.mocks.when(mockHighlightSelector.selectById(new Set<Id>{ md.mockWSHighlightId }))
            .thenReturn(new List<WS_Highlight__c>{ md.mockWSHighlight });
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        WhiteSpaceController.setHighlight(md.mockWhiteSpaceCellId, md.mockWSHighlightId);
        Test.stopTest();

        // Then
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerDirty(fflib_Match.sObjectOfType(White_Space_Cell__c.SObjectType));
        System.assert(true, 'Assert by mock verify');
    }

    @isTest
    static void getDataTypesTest() {
        // Given
        TestMockData md = new TestMockData();
        WSDataTypeServiceImpl mockDataTypeService = md.mockWSDataTypeService;

        md.mocks.startStubbing();
        md.mocks.when(mockDataTypeService.getDataTypes(md.mockWhiteSpaceId)).thenReturn(new List<WS_Data_Type__c>());
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        WhiteSpaceController.getDataTypes(md.mockWhiteSpaceId);
        Test.stopTest();

        // Then
        ((WSDataTypeServiceImpl) md.mocks.verify(mockDataTypeService, 1)).getDataTypes(md.mockWhiteSpaceId);
        System.assert(true, 'Assert from mock verify');
    }

    @isTest
    static void saveDataForCellTest() {
        // Given
        TestMockData md = new TestMockData();
        WSDataTypeServiceImpl mockDataTypeService = md.mockWSDataTypeService;

        md.mocks.startStubbing();
        md.mocks.when(mockDataTypeService.saveDataForCell(md.mockWhiteSpaceCellId, md.mockWSDataTypeId, 'test'))
            .thenReturn(md.mockWSDataTypeAssociationId);
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        WhiteSpaceController.saveDataForCell(md.mockWhiteSpaceCellId, md.mockWSDataTypeId, 'test');
        Test.stopTest();

        // Then
        ((WSDataTypeServiceImpl) md.mocks.verify(mockDataTypeService, 1))
            .saveDataForCell(md.mockWhiteSpaceCellId, md.mockWSDataTypeId, 'test');
        System.assert(true, 'Assert from mock verify');
    }

    @isTest
    static void getDataTypeDataForCellTest() {
        // Given
        TestMockData md = new TestMockData();
        WSDataTypeServiceImpl mockDataTypeService = md.mockWSDataTypeService;

        md.mocks.startStubbing();
        md.mocks.when(mockDataTypeService.getDataTypeDataForCell(md.mockWhiteSpaceCellId))
            .thenReturn(new List<WS_Data_Type_Association__c>());
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        WhiteSpaceController.getDataTypeDataForCell(md.mockWhiteSpaceCellId);
        Test.stopTest();

        // Then
        ((WSDataTypeServiceImpl) md.mocks.verify(mockDataTypeService, 1))
            .getDataTypeDataForCell(md.mockWhiteSpaceCellId);
        System.assert(true, 'Assert from mock verify');
    }

    @isTest
    static void getUserSettingTest() {
        TestMockData md = new TestMockData();
        WSUserSettingServiceImpl mockWSUserSettingService = md.mockWSUserSettingService;

        // When
        Test.startTest();
        WhiteSpaceController.getUserSetting(md.mockWhiteSpaceId);
        Test.stopTest();

        // Then
        ((WSUserSettingServiceImpl) md.mocks.verify(mockWSUserSettingService, 1)).getUserSetting(md.mockWhiteSpaceId);
        System.assert(true, 'Assert from mock verify');
    }

    @isTest
    static void updateUserSettingTest() {
        TestMockData md = new TestMockData();
        WSUserSettingServiceImpl mockWSUserSettingService = md.mockWSUserSettingService;

        // When
        Test.startTest();
        WhiteSpaceController.updateUserSetting(md.mockWSUserSetting);
        Test.stopTest();

        // Then
        ((WSUserSettingServiceImpl) md.mocks.verify(mockWSUserSettingService, 1))
            .updateUserSetting(new List<WS_User_Setting__c>{ md.mockWSUserSetting });
        System.assert(true, 'Assert from mock verify');
    }

    @isTest
    static void updateZoomIndexTest() {
        TestMockData md = new TestMockData();
        WSUserSettingServiceImpl mockWSUserSettingService = md.mockWSUserSettingService;

        Integer zoomIndex = 4;

        // When
        Test.startTest();
        WhiteSpaceController.updateZoomIndex(md.mockWSUserSettingId, zoomIndex);
        Test.stopTest();

        // Then
        ((WSUserSettingServiceImpl) md.mocks.verify(mockWSUserSettingService, 1))
            .updateZoomIndex(md.mockWSUserSettingId, zoomIndex);
        System.assert(true, 'Assert from mock verify');
    }

    @istest
    static void getFirstWhiteSpaceIdForAccountPlanTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WhiteSpaceSelector mockSelector = (WhiteSpaceSelector) FFLibHelper.mockSelector(
            WhiteSpaceSelector.class,
            mocks
        );
        Application.Selector.setMock(mockSelector);

        // When
        Id whiteSpaceId = fflib_IDGenerator.generate(White_Space__c.SObjectType);
        Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);

        List<White_Space__c> ws1 = new List<White_Space__c>();
        White_Space__c ws2 = new White_Space__c(Id = whiteSpaceId, Account_Plan__c = accountPlanId, Name = 'WS1');
        ws1.add(ws2);

        mocks.startStubbing();
        mocks.when(mockSelector.selectFirstByAccountPlanId(accountPlanId)).thenReturn(ws1);
        mocks.stopStubbing();

        List<Id> result = WhiteSpaceController.getFirstWhiteSpaceIdForAccountPlan(accountPlanId);

        // Then
        System.assertEquals(whiteSpaceId, result[0]);
    }
}