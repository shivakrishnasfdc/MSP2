@isTest
private class RelationshipGroupContactSelectorTest {
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

    public static final String CONTACTA = 'Contact A';
    public static final String CONTACTB = 'Contact B';

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
            Relationship_Group__c group1 = TestDataFactory.createRelationshipGroup(GROUPA);
            Relationship_Group__c group2 = TestDataFactory.createRelationshipGroup(GROUPB);
            TestDataFactory.createRelationshipGroup(GROUPC);

            Relationship_Map__c map1 = TestDataFactory.createRelationshipMap('TestMap');
            group1.Relationship_Map__c = map1.Id;
            update group1;

            Contact c1 = TestDataFactory.createContact(CONTACTA, CONTACTA);
            Contact c2 = TestDataFactory.createContact(CONTACTB, CONTACTB);

            TestDataFactory.createRelationshipGroupContactAssoc(c1.Id, group1.Id);
            TestDataFactory.createRelationshipGroupContactAssoc(c2.Id, group2.Id);
        }

    }

    @isTest
    static void newInstanceTest() {
        RelationshipGroupContactSelector selector = RelationshipGroupContactSelector.newInstance();

        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        Contact c1 = [SELECT Id FROM Contact WHERE LastName = :CONTACTA LIMIT 1];
        Contact c2 = [SELECT Id FROM Contact WHERE LastName = :CONTACTB LIMIT 1];

        Relationship_Group_Contact_Association__c assoc1 = [
            SELECT Id
            FROM Relationship_Group_Contact_Association__c
            WHERE Contact__c = :c1.Id
        ];
        Relationship_Group_Contact_Association__c assoc2 = [
            SELECT Id
            FROM Relationship_Group_Contact_Association__c
            WHERE Contact__c = :c2.Id
        ];
        Set<Id> assocIds = new Set<Id>{ assoc1.Id, assoc2.Id };

        Test.startTest();
        List<Relationship_Group_Contact_Association__c> queriedAssoc = new RelationshipGroupContactSelector()
            .selectById(assocIds);
        Test.stopTest();

        // Then the admin user should get back all three account plans
        System.assertEquals(2, queriedAssoc.size());
        for (Relationship_Group_Contact_Association__c assoc : queriedAssoc) {
            System.assert(assocIds.contains(assoc.Id));
        }
    }

    @isTest
    static void selectByContactIdsTest() {
        Contact c1 = [SELECT Id FROM Contact WHERE LastName = :CONTACTA LIMIT 1];
        Contact c2 = [SELECT Id FROM Contact WHERE LastName = :CONTACTB LIMIT 1];

        Relationship_Group_Contact_Association__c assoc1 = [
            SELECT Id
            FROM Relationship_Group_Contact_Association__c
            WHERE Contact__c = :c1.Id
        ];
        Relationship_Group_Contact_Association__c assoc2 = [
            SELECT Id
            FROM Relationship_Group_Contact_Association__c
            WHERE Contact__c = :c2.Id
        ];
        Set<String> contactIds = new Set<String>{ c1.Id, c2.Id };
        Set<Id> assocIds = new Set<Id>{ assoc1.Id, assoc2.Id };

        Test.startTest();
        List<Relationship_Group_Contact_Association__c> queriedAssoc = new RelationshipGroupContactSelector()
            .selectByContactIds(contactIds);
        Test.stopTest();

        // Then the admin user should get back all three account plans
        System.assertEquals(2, queriedAssoc.size());
        for (Relationship_Group_Contact_Association__c assoc : queriedAssoc) {
            System.assert(assocIds.contains(assoc.Id));
        }
    }

    @isTest
    static void selectWithGroupsByContactIdsTest() {
        Contact c1 = [SELECT Id FROM Contact WHERE LastName = :CONTACTA LIMIT 1];
        Contact c2 = [SELECT Id FROM Contact WHERE LastName = :CONTACTB LIMIT 1];

        Relationship_Group_Contact_Association__c assoc1 = [
            SELECT Id
            FROM Relationship_Group_Contact_Association__c
            WHERE Contact__c = :c1.Id
        ];
        Relationship_Group_Contact_Association__c assoc2 = [
            SELECT Id
            FROM Relationship_Group_Contact_Association__c
            WHERE Contact__c = :c2.Id
        ];
        Set<Id> contactIds = new Set<Id>{ c1.Id, c2.Id };
        Set<Id> assocIds = new Set<Id>{ assoc1.Id, assoc2.Id };

        Test.startTest();
        List<Relationship_Group_Contact_Association__c> queriedAssoc = new RelationshipGroupContactSelector()
            .selectWithGroupsByContactIds(contactIds);
        Test.stopTest();

        System.assertEquals(2, queriedAssoc.size());
        for (Relationship_Group_Contact_Association__c assoc : queriedAssoc) {
            System.assert(assocIds.contains(assoc.Id));
            System.assert(assoc.Relationship_Group__r.Id != null);
            System.assert(assoc.Relationship_Group__r.Label__c != null);
        }
    }

    @isTest
    static void selectByContactIdsForGlobalGroupTest() {
        Contact c1 = [SELECT Id FROM Contact WHERE LastName = :CONTACTA LIMIT 1];
        Contact c2 = [SELECT Id FROM Contact WHERE LastName = :CONTACTB LIMIT 1];

        Set<String> contactIds = new Set<String>{ c1.Id, c2.Id };

        Test.startTest();
        List<Relationship_Group_Contact_Association__c> queriedAssoc = new RelationshipGroupContactSelector()
            .selectByContactIdsForGlobalGroup(contactIds);
        Test.stopTest();

        // Should only retrieve 1 group that is global (ie no mapping to rel map or account plan)
        System.assertEquals(1, queriedAssoc.size());
    }

    @isTest
    static void selectByContactIdsForLocalGroupNullTest() {
        Contact c1 = [SELECT Id FROM Contact WHERE LastName = :CONTACTA LIMIT 1];
        Contact c2 = [SELECT Id FROM Contact WHERE LastName = :CONTACTB LIMIT 1];

        Set<String> contactIds = new Set<String>{ c1.Id, c2.Id };

        Test.startTest();
        List<Relationship_Group_Contact_Association__c> queriedAssoc = new RelationshipGroupContactSelector()
            .selectByContactIdsForLocalGroup(contactIds, null);
        Test.stopTest();

        // Should only retrieve 1 group that is global (ie no mapping to rel map or account plan)
        System.assertEquals(0, queriedAssoc.size());
    }

    @isTest
    static void selectByContactIdsForLocalGroupTest() {
        Contact c1 = [SELECT Id FROM Contact WHERE LastName = :CONTACTA LIMIT 1];
        Contact c2 = [SELECT Id FROM Contact WHERE LastName = :CONTACTB LIMIT 1];

        Relationship_Group__c group2 = [SELECT Id FROM Relationship_Group__c WHERE Name = :GROUPB LIMIT 1];
        Relationship_Map__c map2 = TestDataFactory.createRelationshipMap('TestMap');
        group2.Relationship_Map__c = map2.Id;
        update group2;

        Set<String> contactIds = new Set<String>{ c1.Id, c2.Id };

        Test.startTest();
        List<Relationship_Group_Contact_Association__c> queriedAssoc = new RelationshipGroupContactSelector()
            .selectByContactIdsForLocalGroup(contactIds, map2.Id);
        Test.stopTest();

        System.assertEquals(1, queriedAssoc.size());
    }
}