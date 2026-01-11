@isTest
private class WhiteSpaceRowSelectorTest {
    public static final String USER1_FIRST_NAME = 'admin';
    public static final String USER1_LAST_NAME = 'adam';

    public static final String USER2_FIRST_NAME = 'standard';
    public static final String USER2_LAST_NAME = 'suzie';

    public static final String USER3_FIRST_NAME = 'creator';
    public static final String USER3_LAST_NAME = 'cal';

    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';
    public static final String CRUSH_ACCOUNT_PLAN_CREATOR = 'CRUSH_Account_Plan_Creator';

    public static final String ACCOUNT_PLAN1_NAME = 'AccountPlan1';
    public static final String WHITE_SPACE1_NAME = 'WhiteSpace1';
    public static final String WHITE_SPACE_ROW1_NAME = 'row1';
    public static final String WHITE_SPACE_ROW2_NAME = 'row2';
    public static final String WHITE_SPACE_COLUMN1_NAME = 'column1';
    public static final String WHITE_SPACE1_COLUMN3_NAME = 'column2';

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
            Account testAccount1 = new Account(Name = 'Account 1');
            insert testAccount1;
            Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan(ACCOUNT_PLAN1_NAME, testAccount1);

            White_Space__c ws = TestDataFactory.createWhiteSpace(accountPlan1, WHITE_SPACE1_NAME);
            TestDataFactory.createWhiteSpaceRow(ws, WHITE_SPACE_ROW1_NAME);
            TestDataFactory.createWhiteSpaceRow(ws, WHITE_SPACE_ROW2_NAME);
            TestDataFactory.createWhiteSpaceColumn(ws, WHITE_SPACE_COLUMN1_NAME);
            TestDataFactory.createWhiteSpaceColumn(ws, WHITE_SPACE_COLUMN1_NAME);
        }
    }

    @isTest
    static void selectByIdTest() {
        // Given
        User creatorCal = [SELECT Id FROM User WHERE FirstName = :USER3_FIRST_NAME LIMIT 1];

        List<White_Space_Row__c> wsRows = [SELECT Id FROM White_Space_Row__c];

        Set<Id> idSet = new Set<Id>();
        for (White_Space_Row__c wsRow : wsRows) {
            idSet.add(wsRow.Id);
        }

        System.runAs(creatorCal) {
            // When
            List<White_Space_Row__c> rows = new WhiteSpaceRowSelector().selectById(idSet);

            // Then
            System.assertEquals(2, rows.size());
        }
    }
}