@isTest
private class RelationshipGroupPlaceholderSelectorTest {
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

    public static final String LABEL1 = 'Label1';
    public static final String LABEL2 = 'Label2';

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

            Map_Member_Placeholder__c mmp1 = TestDataFactory.createMapMemberPlaceholder(LABEL1, 'desc1');
            Map_Member_Placeholder__c mmp2 = TestDataFactory.createMapMemberPlaceholder(LABEL2, 'desc2');

            TestDataFactory.createRelationshipGroupPlaceholderAssoc(mmp1.Id, group1.Id);
            TestDataFactory.createRelationshipGroupPlaceholderAssoc(mmp2.Id, group2.Id);
        }

    }

    @isTest
    static void newInstanceTest() {
        RelationshipGroupPlaceholderSelector selector = RelationshipGroupPlaceholderSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        Map_Member_Placeholder__c mmp1 = [SELECT Id FROM Map_Member_Placeholder__c WHERE Label__c = :LABEL1 LIMIT 1];
        Map_Member_Placeholder__c mmp2 = [SELECT Id FROM Map_Member_Placeholder__c WHERE Label__c = :LABEL2 LIMIT 1];

        Relationship_Group_Placeholder_Assoc__c assoc1 = [
            SELECT Id
            FROM Relationship_Group_Placeholder_Assoc__c
            WHERE Map_Member_Placeholder__c = :mmp1.Id
        ];
        Relationship_Group_Placeholder_Assoc__c assoc2 = [
            SELECT Id
            FROM Relationship_Group_Placeholder_Assoc__c
            WHERE Map_Member_Placeholder__c = :mmp2.Id
        ];
        Set<Id> assocIds = new Set<Id>{ assoc1.Id, assoc2.Id };

        Test.startTest();
        List<Relationship_Group_Placeholder_Assoc__c> queriedAssoc = new RelationshipGroupPlaceholderSelector()
            .selectById(assocIds);
        Test.stopTest();

        // Then the admin user should get back all two assoc plans
        System.assertEquals(2, queriedAssoc.size());
        for (Relationship_Group_Placeholder_Assoc__c assoc : queriedAssoc) {
            System.assert(assocIds.contains(assoc.Id));
        }
    }

    @isTest
    static void selectByPlaceholderIdsTest() {
        Map_Member_Placeholder__c mmp1 = [SELECT Id FROM Map_Member_Placeholder__c WHERE Label__c = :LABEL1 LIMIT 1];
        Map_Member_Placeholder__c mmp2 = [SELECT Id FROM Map_Member_Placeholder__c WHERE Label__c = :LABEL2 LIMIT 1];

        Relationship_Group_Placeholder_Assoc__c assoc1 = [
            SELECT Id
            FROM Relationship_Group_Placeholder_Assoc__c
            WHERE Map_Member_Placeholder__c = :mmp1.Id
        ];
        Relationship_Group_Placeholder_Assoc__c assoc2 = [
            SELECT Id
            FROM Relationship_Group_Placeholder_Assoc__c
            WHERE Map_Member_Placeholder__c = :mmp2.Id
        ];
        Set<String> mapMemberPlaceholderIds = new Set<String>{ mmp1.Id, mmp2.Id };
        Set<Id> assocIds = new Set<Id>{ assoc1.Id, assoc2.Id };

        Test.startTest();
        List<Relationship_Group_Placeholder_Assoc__c> queriedAssoc = new RelationshipGroupPlaceholderSelector()
            .selectByPlaceholderIds(mapMemberPlaceholderIds);
        Test.stopTest();

        // Then the admin user should get back all three account plans
        System.assertEquals(2, queriedAssoc.size());
        for (Relationship_Group_Placeholder_Assoc__c assoc : queriedAssoc) {
            System.assert(assocIds.contains(assoc.Id));
        }
    }

    @isTest
    static void selectWithGroupsByPlaceholderIdsTest() {
        Map_Member_Placeholder__c mmp1 = [SELECT Id FROM Map_Member_Placeholder__c WHERE Label__c = :LABEL1 LIMIT 1];
        Map_Member_Placeholder__c mmp2 = [SELECT Id FROM Map_Member_Placeholder__c WHERE Label__c = :LABEL2 LIMIT 1];

        Relationship_Group_Placeholder_Assoc__c assoc1 = [
            SELECT Id
            FROM Relationship_Group_Placeholder_Assoc__c
            WHERE Map_Member_Placeholder__c = :mmp1.Id
        ];
        Relationship_Group_Placeholder_Assoc__c assoc2 = [
            SELECT Id
            FROM Relationship_Group_Placeholder_Assoc__c
            WHERE Map_Member_Placeholder__c = :mmp2.Id
        ];
        Set<String> mapMemberPlaceholderIds = new Set<String>{ mmp1.Id, mmp2.Id };
        Set<Id> assocIds = new Set<Id>{ assoc1.Id, assoc2.Id };

        Test.startTest();
        List<Relationship_Group_Placeholder_Assoc__c> queriedAssoc = new RelationshipGroupPlaceholderSelector()
            .selectWithGroupsByPlaceholderIds(mapMemberPlaceholderIds);
        Test.stopTest();

        // Then the admin user should get back all two assocs
        System.assertEquals(2, queriedAssoc.size());
        for (Relationship_Group_Placeholder_Assoc__c assoc : queriedAssoc) {
            System.assert(assocIds.contains(assoc.Id));
            System.assert(assoc.Relationship_Group__r.Id != null);
            System.assert(assoc.Relationship_Group__r.Label__c != null);
        }
    }
}