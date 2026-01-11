@isTest
private class MapMemberLeadSelectorTest {
    public static final String ADMIN_USER1_FIRST_NAME = 'AmyAdmin1';
    public static final String ADMIN_USER1_LAST_NAME = 'Arlie';

    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';
    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User adminUser1 = TestDataFactory.createUser(ADMIN_USER1_FIRST_NAME, ADMIN_USER1_LAST_NAME, standardProfile.Id);

        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];

        // Assigning two users with the admin perm set and one user with the standard perm set
        List<PermissionSetAssignment> permissionSets = new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = adminUser1.Id, PermissionSetId = adminUserPermissionSet.Id)
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

        // Disabling triggers as this class should not be testing them
        Application.bypassTrigger = true;
    }

    @isTest
    static void newInstanceTest() {
        MapMemberLeadSelector selector = MapMemberLeadSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];

        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('My Map');
        Lead l1 = TestDataFactory.createLead('john', 'smith', 'ACME');
        Lead l2 = TestDataFactory.createLead('john2', 'smith2', 'ACME');

        Map_Member_Lead__c mml1 = TestDataFactory.createMapMemberLead(rm, l1);
        TestDataFactory.createMapMemberLead(rm, l2);

        System.runAs(adminUser1) {
            List<Map_Member_Lead__c> result = MapMemberLeadSelector.newInstance().selectById(new Set<Id>{ mml1.Id });
            System.assertEquals(1, result.size());
            System.assertEquals(mml1.Id, result[0].Id);
        }
    }

    @isTest
    static void selectByLeadIdTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];

        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('My Map');
        Lead l1 = TestDataFactory.createLead('john', 'smith', 'ACME');
        Lead l2 = TestDataFactory.createLead('john2', 'smith2', 'ACME');

        Map_Member_Lead__c mml1 = TestDataFactory.createMapMemberLead(rm, l1);
        TestDataFactory.createMapMemberLead(rm, l2);

        System.runAs(adminUser1) {
            List<Map_Member_Lead__c> result = MapMemberLeadSelector.newInstance().selectByLeadId(new Set<Id>{ l1.Id });

            System.assertEquals(1, result.size());
            System.assertEquals(mml1.Id, result[0].Id);
        }
    }

    @isTest
    static void selectByRelationshipMapsTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];

        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('My Map');
        Lead l1 = TestDataFactory.createLead('john', 'smith', 'ACME');
        Lead l2 = TestDataFactory.createLead('john2', 'smith2', 'ACME');

        Relationship_Map__c rm2 = TestDataFactory.createRelationshipMap('My Map 2');
        Lead l3 = TestDataFactory.createLead('john2', 'smith2', 'ACME');

        TestDataFactory.createMapMemberLead(rm, l1);
        TestDataFactory.createMapMemberLead(rm, l2);
        TestDataFactory.createMapMemberLead(rm2, l3);

        System.runAs(adminUser1) {
            List<Map_Member_Lead__c> result = MapMemberLeadSelector.newInstance()
                .selectByRelationshipMaps(new Set<Id>{ rm.Id });

            System.assertEquals(2, result.size());
        }
    }

    @isTest
    static void selectConvertedLeadsByRelationshipMapsTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];

        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('My Map');
        Lead l1 = TestDataFactory.createLead('john', 'smith', 'ACME');
        Lead l2 = TestDataFactory.createLead('john2', 'smith2', 'ACME');

        Relationship_Map__c rm2 = TestDataFactory.createRelationshipMap('My Map 2');
        Lead l3 = TestDataFactory.createLead('john2', 'smith2', 'ACME');

        Map_Member_Lead__c mml1 = TestDataFactory.createMapMemberLead(rm, l1);
        TestDataFactory.createMapMemberLead(rm, l2);
        TestDataFactory.createMapMemberLead(rm2, l3);

        // Convert Lead
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(l1.id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Closed - Converted');

        Database.LeadConvertResult l1Converted = Database.convertLead(lc);
        System.assert(l1Converted.isSuccess());

        System.runAs(adminUser1) {
            List<Map_Member_Lead__c> result = MapMemberLeadSelector.newInstance()
                .selectConvertedLeadsByRelationshipMaps(new Set<Id>{ rm.Id });

            System.assertEquals(1, result.size());
            System.assertEquals(mml1.Id, result[0].Id);
        }
    }
}