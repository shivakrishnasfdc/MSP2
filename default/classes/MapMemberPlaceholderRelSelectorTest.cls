@isTest
private class MapMemberPlaceholderRelSelectorTest {
    public static final String ADMIN_USER1_FIRST_NAME = 'SamStandard';
    public static final String ADMIN_USER1_LAST_NAME = 'Sunlock';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    public static final String LABEL1 = 'Boo1';
    public static final String LABEL2 = 'Boo2';
    public static final String LABEL3 = 'Boo3';
    public static final String CONTACT1 = 'Boo4';
    public static final String CONTACT2 = 'Boo5';
    public static final String CONTACT3 = 'Boo6';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User adminUser1 = TestDataFactory.createUser(ADMIN_USER1_FIRST_NAME, ADMIN_USER1_LAST_NAME, standardProfile.Id);

        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];

        // Assigning two users with the admin perm set and one user with the standard perm set
        List<PermissionSetAssignment> permissionSets = new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = adminUser1.Id, PermissionSetId = adminUserPermissionSet.Id)
        };
        insert permissionSets;

        System.runAs(adminUser1) {
            Map_Member_Placeholder__c testmmp1 = TestDataFactory.createMapMemberPlaceholder(LABEL1, LABEL1);
            Map_Member_Placeholder__c testmmp2 = TestDataFactory.createMapMemberPlaceholder(LABEL2, LABEL2);
            Map_Member_Placeholder__c testmmp3 = TestDataFactory.createMapMemberPlaceholder(LABEL3, LABEL3);
            Contact testContact1 = TestDataFactory.createContact(CONTACT1, CONTACT1);
            Contact testContact2 = TestDataFactory.createContact(CONTACT2, CONTACT2);
            Contact testContact3 = TestDataFactory.createContact(CONTACT3, CONTACT3);

            Contact_Relationship_Type__c relType = TestDataFactory.createContactRelationshipType(
                '#aabbcc',
                'label',
                true,
                true
            );

            Contact_Relationship_Type__c relType2 = TestDataFactory.createContactRelationshipType(
                '#aabbcc',
                'label',
                true,
                false
            );

            Relationship_Map__c relMap = TestDataFactory.createRelationshipMap('mapName');

            TestDataFactory.createRelTypeMapAssociation(relMap, relType);
            TestDataFactory.createRelTypeMapAssociation(relMap, relType2);

            TestDataFactory.createMapMemberPlaceholderRelationship(
                testmmp1.Id,
                testmmp2.Id,
                'tempid1',
                relType.Id,
                null,
                relMap.Id
            );
            TestDataFactory.createMapMemberPlaceholderRelationship(
                testContact1.Id,
                testContact2.Id,
                'tempid2',
                relType2.Id,
                null,
                relMap.Id
            );
            TestDataFactory.createMapMemberPlaceholderRelationship(
                testmmp3.Id,
                testContact3.Id,
                'tempid3',
                relType.Id,
                null,
                null
            );
            TestDataFactory.createMapMemberPlaceholderRelationship(
                testmmp3.Id,
                testContact3.Id,
                'tempid3',
                null,
                null,
                null
            );
        }
    }

    @isTest
    static void newInstanceTest() {
        MapMemberPlaceholderRelationshipSelector selector = MapMemberPlaceholderRelationshipSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        List<Map_Member_Placeholder_Relationship__c> rels = [SELECT Id FROM Map_Member_Placeholder_Relationship__c];
        Set<Id> mapMemberPlaceholderRelationshipIds = (new Map<Id, Map_Member_Placeholder_Relationship__c>(rels))
            .keySet();

        List<Map_Member_Placeholder_Relationship__c> mapMemberPlaceholderRelationshipsForadminUser1;

        Test.startTest();
        System.runAs(adminUser1) {
            mapMemberPlaceholderRelationshipsForadminUser1 = new MapMemberPlaceholderRelationshipSelector()
                .selectById(mapMemberPlaceholderRelationshipIds);
        }
        Test.stopTest();

        System.assertEquals(rels.size(), mapMemberPlaceholderRelationshipsForadminUser1.size());
        for (Map_Member_Placeholder_Relationship__c rel : mapMemberPlaceholderRelationshipsForadminUser1) {
            System.assert(mapMemberPlaceholderRelationshipIds.contains(rel.Id));
        }
    }

    @isTest
    static void selectByIdOrTempKeyTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        List<Map_Member_Placeholder_Relationship__c> rels = [
            SELECT Id, TempId__c
            FROM Map_Member_Placeholder_Relationship__c
        ];
        Set<String> mapMemberPlaceholderRelationshipIds = new Set<String>();

        Boolean alternate = true;
        for (Map_Member_Placeholder_Relationship__c mmpr : rels) {
            if (alternate) {
                mapMemberPlaceholderRelationshipIds.add(mmpr.Id);
            } else {
                mapMemberPlaceholderRelationshipIds.add(mmpr.TempId__c);
            }
            alternate = !alternate;
        }

        List<Map_Member_Placeholder_Relationship__c> mapMemberPlaceholderRelationshipsForadminUser1;

        Test.startTest();
        System.runAs(adminUser1) {
            mapMemberPlaceholderRelationshipsForadminUser1 = new MapMemberPlaceholderRelationshipSelector()
                .selectByIdOrTempKey(mapMemberPlaceholderRelationshipIds);
        }
        Test.stopTest();

        System.assertEquals(rels.size(), mapMemberPlaceholderRelationshipsForadminUser1.size());
        for (Map_Member_Placeholder_Relationship__c rel : mapMemberPlaceholderRelationshipsForadminUser1) {
            System.assert(
                mapMemberPlaceholderRelationshipIds.contains(rel.Id) ||
                mapMemberPlaceholderRelationshipIds.contains(rel.TempId__c)
            );
        }
    }

    @isTest
    static void selectByToTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        List<Map_Member_Placeholder_Relationship__c> rels = [
            SELECT Id, To__c, Relationship_Map__c
            FROM Map_Member_Placeholder_Relationship__c
        ];
        Set<String> toIds = new Set<String>();
        Set<Id> mapOrAccountIds = new Set<Id>();
        for (Map_Member_Placeholder_Relationship__c rel : rels) {
            mapOrAccountIds.add(rel.Relationship_Map__c);
            toIds.add(rel.To__c);
        }

        List<Map_Member_Placeholder_Relationship__c> mapMemberPlaceholderRelationshipsForadminUser1;

        Test.startTest();
        System.runAs(adminUser1) {
            mapMemberPlaceholderRelationshipsForadminUser1 = new MapMemberPlaceholderRelationshipSelector()
                .selectByTo(toIds, mapOrAccountIds);
        }
        Test.stopTest();

        System.assertEquals(rels.size(), mapMemberPlaceholderRelationshipsForadminUser1.size());
        for (Map_Member_Placeholder_Relationship__c rel : mapMemberPlaceholderRelationshipsForadminUser1) {
            System.assert(toIds.contains(rel.To__c));
        }
    }

    @isTest
    static void selectLocalRelationshipsByIdTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        List<Map_Member_Placeholder_Relationship__c> rels = [
            SELECT Id, To__c, From__c
            FROM Map_Member_Placeholder_Relationship__c
        ];
        Id relMapId = [SELECT Id FROM Relationship_Map__c LIMIT 1].Id;
        Set<String> keys = new Set<String>();
        for (Map_Member_Placeholder_Relationship__c rel : rels) {
            keys.add(rel.From__c);
            keys.add(rel.To__c);
        }

        List<Map_Member_Placeholder_Relationship__c> mapMemberPlaceholderRelationshipsForadminUser1;

        Test.startTest();
        System.runAs(adminUser1) {
            mapMemberPlaceholderRelationshipsForadminUser1 = new MapMemberPlaceholderRelationshipSelector()
                .selectLocalRelationshipsById(keys, relMapId, false);
        }
        Test.stopTest();

        // Should only return 1 that is active & local
        System.assertEquals(1, mapMemberPlaceholderRelationshipsForadminUser1.size());
    }

    @isTest
    static void selectGlobalRelationshipsByIdTest() {
        Relationship_Map__c rmMap = [SELECT Id FROM Relationship_Map__c WHERE name = 'mapName' LIMIT 1];

        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        List<Map_Member_Placeholder_Relationship__c> rels = [
            SELECT Id, To__c, From__c, Relationship_Map__c
            FROM Map_Member_Placeholder_Relationship__c
        ];
        Set<String> keys = new Set<String>();
        for (Map_Member_Placeholder_Relationship__c rel : rels) {
            keys.add(rel.From__c);
            keys.add(rel.To__c);
        }

        List<Map_Member_Placeholder_Relationship__c> mapMemberPlaceholderRelationshipsForadminUser1;

        Test.startTest();
        System.runAs(adminUser1) {
            mapMemberPlaceholderRelationshipsForadminUser1 = new MapMemberPlaceholderRelationshipSelector()
                .selectGlobalRelationshipsById(keys, rmMap.Id, false);
        }
        Test.stopTest();

        // Should only return 1 that is active & global
        System.assertEquals(1, mapMemberPlaceholderRelationshipsForadminUser1.size());
    }

    @isTest
    static void selectHierarchyLinksByPlaceholderIdTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        List<Map_Member_Placeholder_Relationship__c> rels = [
            SELECT Id, To__c, From__c, Relationship_Map__c
            FROM Map_Member_Placeholder_Relationship__c
            WHERE Contact_Relationship_Type__c = NULL
        ];
        Set<String> keys = new Set<String>();
        Set<Id> rmOrAccountPlan = new Set<Id>();

        for (Map_Member_Placeholder_Relationship__c rel : rels) {
            rmOrAccountPlan.add(rel.Relationship_Map__c);
            keys.add(rel.From__c);
            keys.add(rel.To__c);
        }

        List<Map_Member_Placeholder_Relationship__c> mapMemberPlaceholderRelationshipsForadminUser1;

        Test.startTest();
        System.runAs(adminUser1) {
            mapMemberPlaceholderRelationshipsForadminUser1 = new MapMemberPlaceholderRelationshipSelector()
                .selectHierarchyLinksByPlaceholderId(rmOrAccountPlan, keys);
        }
        Test.stopTest();

        System.assertEquals(1, mapMemberPlaceholderRelationshipsForadminUser1.size());
    }

    @isTest
    static void selectHierarchyLinksByContactIdTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];

        Contact c1 = TestDataFactory.createContact('john', 'smith');
        Contact c2 = TestDataFactory.createContact('jane', 'williams');
        Contact c3 = TestDataFactory.createContact('joe', 'smith');

        Map_Member_Placeholder_Relationship__c mmpr1 = new Map_Member_Placeholder_Relationship__c(
            To__c = c1.Id,
            From__c = c2.Id,
            Is_Hierarchy__c = true,
            Contact_Relationship_Type__c = null
        );

        Map_Member_Placeholder_Relationship__c mmpr2 = new Map_Member_Placeholder_Relationship__c(
            To__c = c3.Id,
            From__c = c1.Id,
            Is_Hierarchy__c = true,
            Contact_Relationship_Type__c = null
        );

        Map_Member_Placeholder_Relationship__c mmpr3 = new Map_Member_Placeholder_Relationship__c(
            To__c = c1.Id,
            From__c = c2.Id,
            Is_Hierarchy__c = false,
            Contact_Relationship_Type__c = null
        );

        insert mmpr1;
        insert mmpr2;
        insert mmpr3;

        List<Map_Member_Placeholder_Relationship__c> result;

        Test.startTest();
        System.runAs(adminUser1) {
            result = new MapMemberPlaceholderRelationshipSelector()
                .selectHierarchyLinksByContactId(new Set<String>{ c1.Id });
        }
        Test.stopTest();

        System.assertEquals(2, result.size());
    }

    @isTest
    static void selectActiveCustomRelsByToOrFromTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];

        Contact c1 = TestDataFactory.createContact('john', 'smith');
        Contact c2 = TestDataFactory.createContact('jane', 'williams');
        Contact c3 = TestDataFactory.createContact('joe', 'smith');

        Contact_Relationship_Type__c relType = TestDataFactory.createContactRelationshipType(
            '#aabbcc',
            'label',
            true,
            true
        );

        Map_Member_Placeholder_Relationship__c mmpr1 = new Map_Member_Placeholder_Relationship__c(
            To__c = c1.Id,
            From__c = c2.Id,
            Is_Hierarchy__c = true,
            Contact_Relationship_Type__c = relType.Id
        );

        Map_Member_Placeholder_Relationship__c mmpr2 = new Map_Member_Placeholder_Relationship__c(
            To__c = c3.Id,
            From__c = c1.Id,
            Is_Hierarchy__c = true,
            Contact_Relationship_Type__c = relType.Id
        );

        Map_Member_Placeholder_Relationship__c mmpr3 = new Map_Member_Placeholder_Relationship__c(
            To__c = c1.Id,
            From__c = c2.Id,
            Is_Hierarchy__c = false,
            Contact_Relationship_Type__c = null
        );

        insert mmpr1;
        insert mmpr2;
        insert mmpr3;

        List<Map_Member_Placeholder_Relationship__c> result;

        Test.startTest();
        System.runAs(adminUser1) {
            result = new MapMemberPlaceholderRelationshipSelector()
                .selectActiveCustomRelsByToOrFrom(new Set<String>{ c1.Id });
        }
        Test.stopTest();

        System.assertEquals(2, result.size());
    }
}