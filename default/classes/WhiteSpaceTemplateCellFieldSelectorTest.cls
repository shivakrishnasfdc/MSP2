@isTest
private class WhiteSpaceTemplateCellFieldSelectorTest {
    public static final String ADMIN_USER1_FIRST_NAME = 'AmyAdmin1';
    public static final String ADMIN_USER1_LAST_NAME = 'Arlie';

    public static final String ADMIN_USER2_FIRST_NAME = 'AaronAdmin1';
    public static final String ADMIN_USER2_LAST_NAME = 'Alejandro';

    public static final String STANDARD_USER1_FIRST_NAME = 'SamStandard';
    public static final String STANDARD_USER1_LAST_NAME = 'Sunlock';

    public static final String TEMPLATE_NAME = 'The test template name';

    public static final String CELL_FIELD_NAME1 = 'The test field name 1';
    public static final String CELL_FIELD_NAME2 = 'The test field name 2';

    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';
    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User adminUser1 = TestDataFactory.createUser(ADMIN_USER1_FIRST_NAME, ADMIN_USER1_LAST_NAME, standardProfile.Id);
        User adminUser2 = TestDataFactory.createUser(ADMIN_USER2_FIRST_NAME, ADMIN_USER2_LAST_NAME, standardProfile.Id);
        User standardUser1 = TestDataFactory.createUser(
            STANDARD_USER1_FIRST_NAME,
            STANDARD_USER1_LAST_NAME,
            standardProfile.Id
        );

        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];
        PermissionSet standardUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_STANDARD_USER];

        // Assigning two users with the admin perm set and one user with the standard perm set
        List<PermissionSetAssignment> permissionSets = new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = adminUser1.Id, PermissionSetId = adminUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = adminUser2.Id, PermissionSetId = adminUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = standardUser1.Id, PermissionSetId = standardUserPermissionSet.Id)
        };

        Id systemUserId = UserInfo.getUserId();
        PermissionSetAssignment systemCrushAdminPermissions = TestDataFactory.createPermissionSetAssignment(
            systemUserId,
            adminUserPermissionSet.Id
        );

        if (systemCrushAdminPermissions != null) {
            permissionSets.add(systemCrushAdminPermissions);
        }
        insert permissionSets;

        White_Space_Template__c theTemplate;

        // Creating one account plan with adminUser1 and sharing it to standardUser1
        System.runAs(adminUser1) {
            theTemplate = TestDataFactory.createWhiteSpaceTemplate(TEMPLATE_NAME, 'Account', 'Name', 'Account', 'Name');
            TestDataFactory.createWhiteSpaceTemplateCellField(CELL_FIELD_NAME1, null, null, theTemplate.Id);
        }

        // Creating two additional account plans with adminUser2 without sharing them to any other users
        System.runAs(adminUser2) {
            TestDataFactory.createWhiteSpaceTemplateCellField(CELL_FIELD_NAME2, null, null, theTemplate.Id);
        }

    }

    @isTest
    static void newInstanceTest() {
        WhiteSpaceTemplateCellFieldSelector selector = WhiteSpaceTemplateCellFieldSelector.newInstance();

        System.assertNotEquals(null, selector);
        System.assertEquals(White_Space_Template_Cell_Field__c.sObjectType, selector.getSObjectType());
    }

    @isTest
    static void selectByIdTest() {
        // Given a user with the admin perm set and a user with the standard perm set
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        User standardUser1 = [SELECT Id FROM User WHERE LastName = :STANDARD_USER1_LAST_NAME];
        List<White_Space_Template_Cell_Field__c> cellFields = [SELECT Id FROM White_Space_Template_Cell_Field__c];

        Set<Id> cellFieldIds = new Map<Id, White_Space_Template_Cell_Field__c>(cellFields).keySet();

        // When each user requests all three account plans
        Test.startTest();

        List<White_Space_Template_Cell_Field__c> cellFieldsForAdminUser;
        List<White_Space_Template_Cell_Field__c> cellFieldsForStandardUser;

        System.runAs(adminUser1) {
            cellFieldsForAdminUser = new WhiteSpaceTemplateCellFieldSelector().selectById(cellFieldIds);
        }

        System.runAs(standardUser1) {
            cellFieldsForStandardUser = new WhiteSpaceTemplateCellFieldSelector().selectById(cellFieldIds);
        }

        Test.stopTest();

        Set<Id> adminCFIds = new Map<Id, White_Space_Template_Cell_Field__c>(cellFieldsForAdminUser).keySet();
        Set<Id> stanCFIds = new Map<Id, White_Space_Template_Cell_Field__c>(cellFieldsForStandardUser).keySet();

        // Then the admin user should get back all three account plans
        System.assertEquals(cellFieldIds, adminCFIds);
        System.assertEquals(cellFieldIds, stanCFIds);
    }

    @isTest
    static void selectByIdErrorCaseTest() {
        //Given
        Set<Id> emptyCellFieldIds = new Set<Id>{};

        // When each user requests all three account plans
        Test.startTest();
        List<White_Space_Template_Cell_Field__c> cellFieldsForEmpty = new WhiteSpaceTemplateCellFieldSelector()
            .selectById(emptyCellFieldIds);
        List<White_Space_Template_Cell_Field__c> cellFieldsForNull = new WhiteSpaceTemplateCellFieldSelector()
            .selectById(null);
        Test.stopTest();

        // Then the admin user should get back all three account plans
        System.assertEquals(0, cellFieldsForEmpty.size());
        System.assertEquals(0, cellFieldsForNull.size());
    }

    @isTest
    static void selectByTemplateIdTest() {
        // Given a user with the admin perm set and a user with the standard perm set
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        User standardUser1 = [SELECT Id FROM User WHERE LastName = :STANDARD_USER1_LAST_NAME];
        White_Space_Template__c template = [SELECT Id FROM White_Space_Template__c WHERE Name = :TEMPLATE_NAME];

        Set<Id> templateIds = new Set<Id>{ template.Id };

        // When each user requests all three account plans
        Test.startTest();

        List<White_Space_Template_Cell_Field__c> cellFieldsForAdminUser;
        List<White_Space_Template_Cell_Field__c> cellFieldsForStandardUser;

        System.runAs(adminUser1) {
            cellFieldsForAdminUser = new WhiteSpaceTemplateCellFieldSelector()
                .selectByWhiteSpaceTemplateId(templateIds);
        }

        System.runAs(standardUser1) {
            cellFieldsForStandardUser = new WhiteSpaceTemplateCellFieldSelector()
                .selectByWhiteSpaceTemplateId(templateIds);
        }

        Test.stopTest();
        List<White_Space_Template_Cell_Field__c> expectedCellFields = [
            SELECT Id
            FROM White_Space_Template_Cell_Field__c
        ];
        Set<Id> expectedCellFieldIds = new Map<Id, White_Space_Template_Cell_Field__c>(expectedCellFields).keySet();

        Set<Id> adminCFIds = new Map<Id, White_Space_Template_Cell_Field__c>(cellFieldsForAdminUser).keySet();
        Set<Id> stanCFIds = new Map<Id, White_Space_Template_Cell_Field__c>(cellFieldsForStandardUser).keySet();

        // Then the admin user should get back all three account plans
        System.assertEquals(expectedCellFieldIds, adminCFIds);
        System.assertEquals(expectedCellFieldIds, stanCFIds);
    }

    @isTest
    static void selectByTemplateIdErrorCaseTest() {
        //Given
        Set<Id> emptyTemplateIds = new Set<Id>{};

        // When each user requests all three account plans
        Test.startTest();
        List<White_Space_Template_Cell_Field__c> cellFieldsForEmpty = new WhiteSpaceTemplateCellFieldSelector()
            .selectByWhiteSpaceTemplateId(emptyTemplateIds);
        List<White_Space_Template_Cell_Field__c> cellFieldsForNull = new WhiteSpaceTemplateCellFieldSelector()
            .selectByWhiteSpaceTemplateId(null);
        Test.stopTest();

        // Then the admin user should get back all three account plans
        System.assertEquals(0, cellFieldsForEmpty.size());
        System.assertEquals(0, cellFieldsForNull.size());
    }

    @isTest
    static void selectByTemplateIdAndDisplayFieldIdsTest() {
        White_Space_Template__c template = [SELECT Id FROM White_Space_Template__c WHERE Name = :TEMPLATE_NAME];

        Set<Id> templateIds = new Set<Id>{ template.Id };

        Id testDF1Id1 = fflib_IDGenerator.generate(White_Space_Amount_Type__c.SObjectType);
        Id testDF1Id2 = fflib_IDGenerator.generate(White_Space_Amount_Type__c.SObjectType);

        White_Space_Template_Cell_Field__c cellField1 = TestDataFactory.createWhiteSpaceTemplateCellField(
            'testCellField1',
            testDF1Id1,
            null,
            template.Id
        );
        TestDataFactory.createWhiteSpaceTemplateCellField('testCellField2', testDF1Id2, null, template.Id);

        List<White_Space_Template_Cell_Field__c> results = new WhiteSpaceTemplateCellFieldSelector()
            .selectByWhiteSpaceTemplateIdAndDisplayFieldIds(templateIds, new Set<Id>{ cellField1.DisplayFieldId__c });

        system.assertEquals(1, results.size());
        system.assertEquals(cellField1.id, results[0].id);
    }

    @isTest
    static void selectByTemplateIdExcludingDisplayFieldIdsTest() {
        White_Space_Template__c template = [SELECT Id FROM White_Space_Template__c WHERE Name = :TEMPLATE_NAME];
        Id testDF1Id1 = fflib_IDGenerator.generate(White_Space_Amount_Type__c.SObjectType);
        White_Space_Template_Cell_Field__c cellField1 = TestDataFactory.createWhiteSpaceTemplateCellField(
            'testCellField1',
            testDF1Id1,
            null,
            template.Id
        );

        Set<Id> templateIds = new Set<Id>{ template.Id };

        List<White_Space_Template_Cell_Field__c> results = new WhiteSpaceTemplateCellFieldSelector()
            .selectByWhiteSpaceTemplateIdExcludingDisplayFieldIds(
                templateIds,
                new Set<Id>{ cellField1.DisplayFieldId__c }
            );

        system.assertEquals(2, results.size());
    }
}