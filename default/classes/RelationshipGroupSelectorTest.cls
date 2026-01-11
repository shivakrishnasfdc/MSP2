@isTest
private class RelationshipGroupSelectorTest {
    public static final String ADMIN_USER1_FIRST_NAME = 'AmyAdmin1';
    public static final String ADMIN_USER1_LAST_NAME = 'Arlie';

    public static final String STANDARD_USER1_FIRST_NAME = 'SamStandard';
    public static final String STANDARD_USER1_LAST_NAME = 'Sunlock';

    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';
    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';

    public static final String GROUPA = 'Group A';
    public static final String GROUPB = 'Group B';
    public static final String GROUPC = 'Group C';
    public static final String TEMPID = 'abcdefghijklmnop';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User adminUser1 = TestDataFactory.createUser(ADMIN_USER1_FIRST_NAME, ADMIN_USER1_LAST_NAME, standardProfile.Id);
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

        System.runAs(adminUser1) {
            TestDataFactory.createRelationshipGroup(GROUPA);
            TestDataFactory.createRelationshipGroup(GROUPB);
            TestDataFactory.createRelationshipGroup(GROUPC, TEMPID);
        }

    }

    @isTest
    static void newInstanceTest() {
        RelationshipGroupSelector selector = RelationshipGroupSelector.newInstance();

        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        // Given a user with the admin perm set and a user with the standard perm set
        Relationship_Group__c group1 = [SELECT Id FROM Relationship_Group__c WHERE Name = :GROUPA];
        Relationship_Group__c group2 = [SELECT Id FROM Relationship_Group__c WHERE Name = :GROUPB];
        Set<Id> relGroupIds = new Set<Id>{ group1.Id, group2.Id };

        Test.startTest();
        List<Relationship_Group__c> queriedGroups = new RelationshipGroupSelector().selectById(relGroupIds);
        Test.stopTest();

        // Then the admin user should get back all three account plans
        System.assertEquals(2, queriedGroups.size());
        for (Relationship_Group__c relGroup : queriedGroups) {
            System.assert(relGroupIds.contains(relGroup.Id));
        }
    }

    @isTest
    static void selectByIdORTempKeyTest() {
        // Given a user with the admin perm set and a user with the standard perm set
        Relationship_Group__c group1 = [SELECT Id FROM Relationship_Group__c WHERE Name = :GROUPA];
        Relationship_Group__c group2 = [SELECT Id FROM Relationship_Group__c WHERE Name = :GROUPB];
        Relationship_Group__c group3 = [SELECT Id, TempId__c FROM Relationship_Group__c WHERE TempId__c = :TEMPID];
        Set<String> relGroupIds = new Set<String>{ group1.Id, group2.Id };
        Set<String> tempIds = new Set<String>{ group3.TempId__c };

        Set<String> nodeIdsAndTempIds = new Set<String>(relGroupIds);
        nodeIdsAndTempIds.addAll(tempIds);

        Test.startTest();
        List<Relationship_Group__c> queriedGroups = new RelationshipGroupSelector()
            .selectByIdORTempKey(nodeIdsAndTempIds);
        Test.stopTest();

        // Then the admin user should get back all three account plans
        System.assertEquals(3, queriedGroups.size());
        for (Relationship_Group__c relGroup : queriedGroups) {
            System.assert(nodeIdsAndTempIds.contains(relGroup.Id) || nodeIdsAndTempIds.contains(relGroup.TempId__c));
        }
    }

    @isTest
    static void selectAllGlobalGroupsTest() {
        Test.startTest();
        List<Relationship_Group__c> queriedGroups = new RelationshipGroupSelector().selectAllGlobalGroups();
        Test.stopTest();

        System.assertEquals(3, queriedGroups.size());
    }

    @isTest
    static void selectLocalAllGroupsTest() {
        // Given a user with the admin perm set and a user with the standard perm set
        Relationship_Group__c group1 = [SELECT Id FROM Relationship_Group__c WHERE Name = :GROUPA];
        Relationship_Map__c map1 = TestDataFactory.createRelationshipMap('testmap');
        group1.Relationship_Map__c = map1.Id;
        update group1;

        Test.startTest();
        List<Relationship_Group__c> queriedGroups = new RelationshipGroupSelector().selectAllLocalGroups(map1.Id);
        Test.stopTest();

        System.assertEquals(1, queriedGroups.size());
    }

    @isTest
    static void selectAllLocalGroupsNullTest() {
        // Given a user with the admin perm set and a user with the standard perm set
        Relationship_Group__c group1 = [SELECT Id FROM Relationship_Group__c WHERE Name = :GROUPA];
        Relationship_Map__c map1 = TestDataFactory.createRelationshipMap('testmap');
        group1.Relationship_Map__c = map1.Id;
        update group1;

        Test.startTest();
        List<Relationship_Group__c> queriedGroups = new RelationshipGroupSelector().selectAllLocalGroups(null);
        Test.stopTest();

        System.assertEquals(0, queriedGroups.size());
    }
}