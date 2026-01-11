@isTest
private with sharing class WhiteSpaceFromLegacyTemplateTest {
    private static final String USER1_FIRST_NAME = 'admin';
    private static final String USER1_LAST_NAME = 'adam';

    private static final String USER2_FIRST_NAME = 'standard';
    private static final String USER2_LAST_NAME = 'suzie';

    private static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';
    private static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    public static final String STANDARD_USER = 'Standard User';

    public static final String WHITE_SPACE_NAME = 'testWs';
    public static final String WHITE_SPACE_TEMPLATE_NAME = 'testTemplate';

    public static final String ACCOUNT_PLAN1_NAME = 'AccountPlan1';
    public static final String ACCOUNT1_NAME = 'zzzzAccount 1';

    @testSetup
    static void testSetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];
        User adminUser = TestDataFactory.createUser(USER1_FIRST_NAME, USER1_LAST_NAME, p.Id);
        User standardUser = TestDataFactory.createUser(USER2_FIRST_NAME, USER2_LAST_NAME, p.Id);

        PermissionSet standardUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_STANDARD_USER];
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = standardUser.Id, PermissionSetId = standardUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = adminUserPermissionSet.Id)
        };

        System.runAs(adminUser) {
            Account testAccount1 = new Account(Name = ACCOUNT1_NAME);
            insert testAccount1;
            Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan(ACCOUNT_PLAN1_NAME, testAccount1);

            White_Space_Template__c template = TestDataFactory.createLegacyWhiteSpaceTemplate(
                WHITE_SPACE_TEMPLATE_NAME,
                'Product2',
                'Name',
                'Account',
                'Name'
            );

            TestDataFactory.createWhiteSpaceFromTemplate(accountPlan1, template, WHITE_SPACE_NAME);
        }
    }

    @isTest
    private static void canInstantiateTest() {
        White_Space__c whiteSpace = getWhiteSpace();
        White_Space_Template__c template = getTemplate();

        WhiteSpaceFromLegacyTemplate result = new WhiteSpaceFromLegacyTemplate(whiteSpace, template);

        system.assertEquals(WhiteSpaceFromLegacyTemplate.type, result.type);
    }

    @isTest
    private static void canBuildTest() {
        White_Space__c whiteSpace = getWhiteSpace();
        White_Space_Template__c template = getTemplate();

        WhiteSpaceAbstract result = new WhiteSpaceFromLegacyTemplate(whiteSpace, template).build();

        system.assertNotEquals(null, result);
    }

    @isTest
    static void legacyNewRowsAndColumnsTest() {
        //The codepath of the method being tested has dynamic queries that cannot be mocked so using actual data
        List<SObject> objectsForTest = new List<SObject>();
        Account acc1 = new Account(Name = 'Test_Account_1');
        Account acc2 = new Account(Name = 'Test_Account_2');
        Account acc3 = new Account(Name = 'Test_Account_3');

        Product2 prod1 = new Product2(Name = 'Test_Product_1');
        Product2 prod2 = new Product2(Name = 'Test_Product_2');
        Product2 prod3 = new Product2(Name = 'Test_Product_3');

        objectsForTest.add(acc3);
        objectsForTest.add(acc1);
        objectsForTest.add(prod3);
        objectsForTest.add(prod1);

        Database.insert(objectsForTest);

        White_Space__c whiteSpace = getWhiteSpace();
        White_Space_Template__c template = getTemplate();

        new WhiteSpaceFromLegacyTemplate(whiteSpace, template).build();

        insert acc2;
        insert prod2;

        White_Space_Row__c newRow = new White_Space_Row__c(
            White_Space__c = whiteSpace.id,
            Related_Object_Id__c = acc1.id
        );
        insert newRow;

        White_Space_Column__c newColumn = new White_Space_Column__c(
            White_Space__c = whiteSpace.id,
            Related_Object_Id__c = prod1.id
        );
        insert newColumn;

        Test.startTest();
        WhiteSpaceAbstract result = new WhiteSpaceFromLegacyTemplate(whiteSpace, template).build();
        Test.stopTest();

        System.assertEquals(1, result.rows.size());
        System.assertEquals(acc1.name, result.rows[0].name, 'Rows should be ordered by name [0]');
        System.assertEquals(1, result.columns.size());
        System.assertEquals(prod1.name, result.columns[0].name, 'Columns should be ordered by name [0]');
    }

    @isTest
    static void deleteLegacyRowsAndColumnsTest() {
        //The codepath of the method being tested has dynamic queries that cannot be mocked so using actual data
        List<SObject> objectsForTest = new List<SObject>();
        Account acc1 = new Account(Name = 'Test_Account_1');
        Account acc2 = new Account(Name = 'Test_Account_2');
        objectsForTest.add(acc1);
        objectsForTest.add(acc2);

        Product2 prod1 = new Product2(Name = 'Test_Product_1');
        Product2 prod2 = new Product2(Name = 'Test_Product_2');

        objectsForTest.add(prod1);
        objectsForTest.add(prod2);

        insert objectsForTest;

        White_Space__c whiteSpace = getWhiteSpace();
        White_Space_Template__c template = getTemplate();

        White_Space_Row__c row1 = new White_Space_Row__c(
            White_Space__c = whiteSpace.id,
            Related_Object_Id__c = acc1.id
        );
        White_Space_Row__c row2 = new White_Space_Row__c(
            White_Space__c = whiteSpace.id,
            Related_Object_Id__c = acc2.id
        );
        White_Space_Column__c col1 = new White_Space_Column__c(
            White_Space__c = whiteSpace.id,
            Related_Object_Id__c = prod1.id
        );
        White_Space_Column__c col2 = new White_Space_Column__c(
            White_Space__c = whiteSpace.id,
            Related_Object_Id__c = prod2.id
        );
        insert row1;
        insert row2;
        insert col1;
        insert col2;

        delete acc2;
        delete prod2;

        Test.startTest();
        WhiteSpaceAbstract result = new WhiteSpaceFromLegacyTemplate(whiteSpace, template).build();
        Test.stopTest();

        System.assertEquals(1, result.rows.size());
        System.assertEquals(1, result.columns.size());
    }

    private static White_Space__c getWhiteSpace() {
        return [
            SELECT
                Id,
                Name,
                Account_Plan__c,
                White_Space_Template__c,
                AreColumnsFiltered__c,
                AreRowsFiltered__c,
                AreCellsFiltered__c,
                AreUnrelatedCellsFiltered__c
            FROM White_Space__c
            WHERE Name = :WHITE_SPACE_NAME
            LIMIT 1
        ];
    }

    private static White_Space_Template__c getTemplate() {
        return [
            SELECT
                Id,
                Name,
                Column_Object_Name__c,
                Column_Label_Field_Name__c,
                ColumnMapping__c,
                Row_Object_Name__c,
                Row_Label_Field_Name__c,
                RowMapping__c,
                hasDependentPicklistColumns__c,
                hasDependentPicklistRows__c,
                isLegacy__c
            FROM White_Space_Template__c
            WHERE Name = :WHITE_SPACE_TEMPLATE_NAME
            LIMIT 1
        ];
    }
}