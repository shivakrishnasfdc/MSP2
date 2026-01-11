@isTest
private class WhiteSpaceTemplateSelectorTest {
    public static final String USER1_FIRST_NAME = 'admin';
    public static final String USER1_LAST_NAME = 'adam';

    public static final String USER2_FIRST_NAME = 'standard';
    public static final String USER2_LAST_NAME = 'suzie';

    public static final String USER3_FIRST_NAME = 'creator';
    public static final String USER3_LAST_NAME = 'cal';

    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';
    public static final String CRUSH_ACCOUNT_PLAN_CREATOR = 'CRUSH_Account_Plan_Creator';

    public static final String WHITE_SPACE_TEMPLATE1_NAME = 'testTemplate1';
    public static final String WHITE_SPACE_TEMPLATE2_NAME = 'testTemplate2';
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

        System.runAs(adminAdam) {
            TestDataFactory.createWhiteSpaceTemplate(
                WHITE_SPACE_TEMPLATE1_NAME,
                COLUMN_OBJECT_NAME,
                COLUMN_LABEL_FIELD_NAME,
                ROW_OBJECT_NAME,
                ROW_LABEL_FIELD_NAME
            );
            TestDataFactory.createWhiteSpaceTemplate(
                WHITE_SPACE_TEMPLATE2_NAME,
                COLUMN_OBJECT_NAME,
                COLUMN_LABEL_FIELD_NAME,
                ROW_OBJECT_NAME,
                ROW_LABEL_FIELD_NAME
            );
        }
    }

    @isTest
    static void selectByIdTest() {
        // Given
        User creatorCal = [SELECT Id FROM User WHERE FirstName = :USER3_FIRST_NAME LIMIT 1];

        User standardSuzie = [SELECT Id FROM User WHERE FirstName = :USER2_FIRST_NAME LIMIT 1];

        White_Space_Template__c template = [
            SELECT Id
            FROM White_Space_Template__c
            WHERE Name = :WHITE_SPACE_TEMPLATE1_NAME
            LIMIT 1
        ];

        // When
        List<White_Space_Template__c> results = new List<White_Space_Template__c>();
        System.runAs(creatorCal) {
            results = new WhiteSpaceTemplateSelector().selectById(new Set<Id>{ template.Id });
        }
        System.assertEquals(1, results.size());

        System.runAs(standardSuzie) {
            results = new WhiteSpaceTemplateSelector().selectById(new Set<Id>{ template.Id });
        }
        System.assertEquals(1, results.size());
    }

    @isTest
    static void selectAllTest() {
        // Given
        User creatorCal = [SELECT Id FROM User WHERE FirstName = :USER3_FIRST_NAME LIMIT 1];

        User standardSuzie = [SELECT Id FROM User WHERE FirstName = :USER2_FIRST_NAME LIMIT 1];

        // When
        List<White_Space_Template__c> results = new List<White_Space_Template__c>();
        System.runAs(creatorCal) {
            results = new WhiteSpaceTemplateSelector().selectAll();
        }
        System.assertEquals(2, results.size());

        System.runAs(standardSuzie) {
            results = new WhiteSpaceTemplateSelector().selectAll();
        }
        System.assertEquals(2, results.size());
    }
}