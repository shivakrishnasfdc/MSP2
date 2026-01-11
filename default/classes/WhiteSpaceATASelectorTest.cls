@isTest
private class WhiteSpaceATASelectorTest {
    public static final String STANDARD_FIRST_NAME = 'standard';
    public static final String STANDARD_LAST_NAME = 'suzie';

    public static final String USER3_FIRST_NAME = 'creator';
    public static final String USER3_LAST_NAME = 'cal';

    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';
    public static final String CRUSH_ACCOUNT_PLAN_CREATOR = 'CRUSH_Account_Plan_Creator';

    public static final String STANDARD_USER = 'Standard User';

    public static final String ACCOUNT_PLAN1_NAME = 'AccountPlan1';
    public static final String WHITE_SPACE1_NAME = 'WhiteSpace1';
    public static final String WHITE_SPACE_ROW1_NAME = 'row1';
    public static final String WHITE_SPACE_ROW2_NAME = 'row2';
    public static final String WHITE_SPACE_COLUMN1_NAME = 'column1';
    public static final String WHITE_SPACE_COLUMN2_NAME = 'column2';
    public static final String WHITE_SPACE_AMOUNT_TYPE_NAME = 'testAmountType';

    @testSetup
    static void testSetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];
        User standardSuzie = TestDataFactory.createUser(STANDARD_FIRST_NAME, STANDARD_LAST_NAME, p.Id);
        User creatorCal = TestDataFactory.createUser(USER3_FIRST_NAME, USER3_LAST_NAME, p.Id);

        PermissionSet standardUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_STANDARD_USER];
        PermissionSet creatorUserPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = :CRUSH_ACCOUNT_PLAN_CREATOR
        ];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = standardSuzie.Id, PermissionSetId = standardUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = creatorCal.Id, PermissionSetId = creatorUserPermissionSet.Id)
        };

        System.runAs(creatorCal) {
            Account testAccount1 = new Account(Name = 'Account 1');
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
            White_Space_Amount_Type__c amountType = TestDataFactory.createWhiteSpaceAmountType(
                WHITE_SPACE_AMOUNT_TYPE_NAME
            );
            TestDataFactory.createWhiteSpaceAmountTypeAssociation(amountType.id, cells[0].id);
        }
    }

    @isTest
    static void newInstanceTest() {
        WhiteSpaceAmountTypeAssociationSelector selector = WhiteSpaceAmountTypeAssociationSelector.newInstance();

        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByAmountTypeAndCellIdTest() {
        White_Space_Amount_Type_Association__c ata = [
            SELECT Id, White_Space_Amount_Type__c, White_Space_Cell__c
            FROM White_Space_Amount_Type_Association__c
        ];

        List<White_Space_Amount_Type_Association__c> result = WhiteSpaceAmountTypeAssociationSelector.newInstance()
            .selectByAmountTypeAndCellId(ata.White_Space_Amount_Type__c, ata.White_Space_Cell__c);

        System.assertEquals(1, result.size());
        System.assertEquals(ata.Id, result[0].Id);
    }
}