@isTest
private class WhiteSpaceSelectorTest {
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
    public static final String WHITE_SPACE_COLUMN2_NAME = 'column2';

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
            White_Space_Row__c row1 = TestDataFactory.createWhiteSpaceRow(ws, WHITE_SPACE_ROW1_NAME);
            White_Space_Row__c row2 = TestDataFactory.createWhiteSpaceRow(ws, WHITE_SPACE_ROW2_NAME);
            White_Space_Column__c col1 = TestDataFactory.createWhiteSpaceColumn(ws, WHITE_SPACE_COLUMN1_NAME);
            White_Space_Column__c col2 = TestDataFactory.createWhiteSpaceColumn(ws, WHITE_SPACE_COLUMN2_NAME);
            TestDataFactory.createWhiteSpaceCells(
                ws.id,
                new Set<Id>{ col1.id, col2.id },
                new Set<Id>{ row1.id, row2.id }
            );
        }
    }

    @isTest
    static void selectByIdTest() {
        // Given
        User creatorCal = [SELECT Id FROM User WHERE FirstName = :USER3_FIRST_NAME LIMIT 1];

        White_Space__c ws = [SELECT Id FROM White_Space__c WHERE Name = :WHITE_SPACE1_NAME LIMIT 1];

        System.runAs(creatorCal) {
            // When
            List<White_Space__c> whiteSpaces = new WhiteSpaceSelector().selectById(new Set<Id>{ ws.Id });

            // Then
            System.assertEquals(1, whiteSpaces.size());
        }
    }

    @isTest
    static void selectByTemplateIdTest() {
        // Given
        User creatorCal = [SELECT Id FROM User WHERE FirstName = :USER3_FIRST_NAME LIMIT 1];

        White_Space__c ws = [SELECT Id FROM White_Space__c WHERE Name = :WHITE_SPACE1_NAME LIMIT 1];
        White_Space_Template__c template = TestDataFactory.createWhiteSpaceTemplate(
            'test',
            'Account',
            'Name',
            'Product2',
            'Name'
        );
        ws.White_Space_Template__c = template.id;
        update ws;

        System.runAs(creatorCal) {
            // When
            List<White_Space__c> whiteSpaces = new WhiteSpaceSelector().selectByTemplateId(template.id);

            // Then
            System.assertEquals(1, whiteSpaces.size());
        }
    }

    @isTest
    static void selectWithGridDataByIdTest() {
        // Given
        User creatorCal = [SELECT Id FROM User WHERE FirstName = :USER3_FIRST_NAME LIMIT 1];

        White_Space__c ws = [SELECT Id FROM White_Space__c WHERE Name = :WHITE_SPACE1_NAME LIMIT 1];

        System.runAs(creatorCal) {
            // When
            List<White_Space__c> whiteSpaces = new WhiteSpaceSelector().selectWithGridDataById(new Set<Id>{ ws.Id });

            // Then
            System.assertEquals(1, whiteSpaces.size());
            System.assertEquals(2, whiteSpaces[0].White_Space_Rows__r.size());
            System.assertEquals(2, whiteSpaces[0].White_Space_Columns__r.size());
        }
    }

    @isTest
    static void selectWithGridDataByAccountPlanIdTest() {
        // Given
        User creatorCal = [SELECT Id FROM User WHERE FirstName = :USER3_FIRST_NAME LIMIT 1];

        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME LIMIT 1];

        System.runAs(creatorCal) {
            // When
            List<White_Space__c> whiteSpaces = new WhiteSpaceSelector()
                .selectWithGridDataByAccountPlanId(new Set<Id>{ accountPlan1.Id });

            // Then
            System.assertEquals(1, whiteSpaces.size());
            System.assertEquals(2, whiteSpaces[0].White_Space_Rows__r.size());
            System.assertEquals(2, whiteSpaces[0].White_Space_Columns__r.size());
        }
    }

    @isTest
    static void selectFirstByAccountPlanIdTest() {
        // Given
        User creatorCal = [SELECT Id FROM User WHERE FirstName = :USER3_FIRST_NAME LIMIT 1];

        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME LIMIT 1];

        System.runAs(creatorCal) {
            // When
            List<White_Space__c> whiteSpaces = new WhiteSpaceSelector().selectFirstByAccountPlanId(accountPlan1.Id);

            // Then
            System.assertEquals(1, whiteSpaces.size());
        }
    }
}