@isTest
private class MappingSelectorTest {
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

        // Creating one mapping and condition gropu with adminUser1
        System.runAs(adminUser1) {
            Mapping__c mapping1 = TestDataFactory.createMapping(
                MAPPING_NAME_ADMIN,
                MAPPING_OBJECT_ADMIN,
                MAPPING_LABEL_ADMIN,
                MAPPING_VALUE_ADMIN
            );
            TestDataFactory.createConditionGroup(mapping1, null);
        }

        // Creating one additional mapping with a different user
        System.runAs(adminUser2) {
            TestDataFactory.createMapping(
                MAPPING_NAME_STANDARD,
                MAPPING_OBJECT_STANDARD,
                MAPPING_LABEL_STANDARD,
                MAPPING_VALUE_STANDARD
            );
        }

    }

    @isTest
    static void newInstanceTest() {
        MappingSelector selector = MappingSelector.newInstance();

        System.assertNotEquals(null, selector);
        System.assertEquals(Mapping__c.sObjectType, selector.getSObjectType());
    }

    @isTest
    static void selectByIdTest() {
        // Given a user with the admin perm set and a user with the standard perm set
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        List<Mapping__c> maps = [SELECT Id FROM Mapping__c];

        Set<Id> mapIds = new Map<Id, Mapping__c>(maps).keySet();
        List<Mapping__c> results;

        // When the user requests all mappings
        Test.startTest();
        System.runAs(adminUser1) {
            results = new MappingSelector().selectById(mapIds);
        }
        Test.stopTest();

        // Then the user should get back all mappings
        System.assertEquals(2, results.size());
    }

    @isTest
    static void selectByIdWithConditionGroupsTest() {
        // Given a user with the admin perm set and a user with the standard perm set
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        List<Mapping__c> maps = [SELECT Id FROM Mapping__c WHERE Name = :MAPPING_NAME_ADMIN];

        Set<Id> mapIds = new Map<Id, Mapping__c>(maps).keySet();
        List<Mapping__c> results;

        // When the user requests mappings by id
        Test.startTest();
        System.runAs(adminUser1) {
            results = new MappingSelector().selectByIdWithConditionGroups(mapIds);
        }
        Test.stopTest();

        // Then the user should get back the mapping record along with its condition groups
        System.assertEquals(1, results.size());
        System.assertEquals(1, results[0].Condition_Groups__r.size());
    }
}