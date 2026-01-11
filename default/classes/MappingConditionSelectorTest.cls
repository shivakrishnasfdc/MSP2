@isTest
private class MappingConditionSelectorTest {
    public static final String ADMIN_USER1_FIRST_NAME = 'AmyAdmin1';
    public static final String ADMIN_USER1_LAST_NAME = 'Arlie';

    public static final String ADMIN_USER2_FIRST_NAME = 'AaronAdmin1';
    public static final String ADMIN_USER2_LAST_NAME = 'Alejandro';

    public static final String STANDARD_USER1_FIRST_NAME = 'SamStandard';
    public static final String STANDARD_USER1_LAST_NAME = 'Sunlock';

    public static final String MAPPING_NAME_ADMIN = 'Admin Mapping test';
    public static final String MAPPING_OBJECT_ADMIN = 'Account';
    public static final String MAPPING_LABEL_ADMIN = 'Name';
    public static final String MAPPING_VALUE_ADMIN = 'Name';

    public static final String MAPPING_NAME_STANDARD = 'Standard Mapping Test';
    public static final String MAPPING_OBJECT_STANDARD = 'Product2';
    public static final String MAPPING_LABEL_STANDARD = 'Name';
    public static final String MAPPING_VALUE_STANDARD = 'Name';

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

        // Creating one mapping condition
        System.runAs(adminUser1) {
            Mapping__c mapping1 = TestDataFactory.createMapping(
                MAPPING_NAME_ADMIN,
                MAPPING_OBJECT_ADMIN,
                MAPPING_LABEL_ADMIN,
                MAPPING_VALUE_ADMIN
            );
            Mapping_Condition_Group__c conditionGroup1 = TestDataFactory.createConditionGroup(mapping1, null);
            TestDataFactory.createCondition(MAPPING_VALUE_ADMIN, 'EQUALS', MAPPING_NAME_ADMIN, conditionGroup1);
        }

        // Creating an additional mapping condition
        System.runAs(adminUser2) {
            Mapping__c mapping2 = TestDataFactory.createMapping(
                MAPPING_NAME_STANDARD,
                MAPPING_OBJECT_STANDARD,
                MAPPING_LABEL_STANDARD,
                MAPPING_VALUE_STANDARD
            );
            Mapping_Condition_Group__c conditionGroup2 = TestDataFactory.createConditionGroup(mapping2, 'AND');
            TestDataFactory.createCondition(MAPPING_VALUE_STANDARD, 'EQUALS', MAPPING_NAME_STANDARD, conditionGroup2);
        }

    }

    @isTest
    static void newInstanceTest() {
        MappingConditionSelector selector = MappingConditionSelector.newInstance();

        System.assertNotEquals(null, selector);
        System.assertEquals(Mapping_Condition__c.sObjectType, selector.getSObjectType());
    }

    @isTest
    static void selectByIdTest() {
        // Given a user with the admin perm set
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        List<Mapping_Condition__c> conditions = [SELECT Id FROM Mapping_Condition__c];

        Set<Id> conditionIds = new Map<Id, Mapping_Condition__c>(conditions).keySet();
        List<Mapping_Condition__c> conditionsForAdminUser;
        // When the user requests all mapping conditions
        Test.startTest();
        System.runAs(adminUser1) {
            conditionsForAdminUser = MappingConditionSelector.newInstance().selectById(conditionIds);
        }
        Test.stopTest();

        // Then the admin user should get back all mapping conditions
        System.assertEquals(2, conditionsForAdminUser.size());
    }

    @isTest
    static void selectByConditionGroupIdTest() {
        // Given a user with the admin perm set
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        Mapping_Condition_Group__c conditionGroup = [SELECT Id FROM Mapping_Condition_Group__c][0];

        List<Mapping_Condition__c> conditionsForAdminUser;
        // When the user requests conditions for a condition group
        Test.startTest();
        System.runAs(adminUser1) {
            conditionsForAdminUser = MappingConditionSelector.newInstance()
                .selectByConditionGroupId(new Set<Id>{ conditionGroup.id });
        }
        Test.stopTest();

        // Then the admin user should get back all mapping conditions for the condition group
        System.assertEquals(1, conditionsForAdminUser.size());
        System.assertEquals(conditionGroup.Id, conditionsForAdminUser[0].Condition_Group__c);
    }
}