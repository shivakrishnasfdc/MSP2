@isTest
private class ContactRelationshipSelectorTest {
    public static final String ADMIN_USER1_FIRST_NAME = 'SamStandard';
    public static final String ADMIN_USER1_LAST_NAME = 'Sunlock';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    public static final String CONTACT1_NAME = 'Boo1';
    public static final String CONTACT2_NAME = 'Boo2';
    public static final String CONTACT3_NAME = 'Boo3';
    public static final String CONTACT4_NAME = 'Boo4';
    public static final String CONTACT5_NAME = 'Boo5';
    public static final String CONTACT6_NAME = 'Boo6';

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
            Contact testContact1 = TestDataFactory.createContact(CONTACT1_NAME, CONTACT1_NAME);
            Contact testContact2 = TestDataFactory.createContact(CONTACT2_NAME, CONTACT2_NAME);
            Contact testContact3 = TestDataFactory.createContact(CONTACT3_NAME, CONTACT3_NAME);
            Contact testContact4 = TestDataFactory.createContact(CONTACT4_NAME, CONTACT4_NAME);
            Contact testContact5 = TestDataFactory.createContact(CONTACT5_NAME, CONTACT5_NAME);
            Contact testContact6 = TestDataFactory.createContact(CONTACT6_NAME, CONTACT6_NAME);

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

            TestDataFactory.createContactRelationship(testContact1, testContact2, 'one', relType.Id, null, relMap.Id);
            TestDataFactory.createContactRelationship(testContact3, testContact4, 'two', relType.Id, null, relMap.Id);
            TestDataFactory.createContactRelationship(
                testContact5,
                testContact6,
                'dfjadlfjadlfajdf',
                relType.Id,
                null,
                null
            );
            TestDataFactory.createContactRelationship(
                testContact1,
                testContact6,
                'dfjadlfjadlfajdf',
                relType2.Id,
                null,
                null
            );
        }
    }

    @isTest
    static void newInstanceTest() {
        ContactRelationshipSelector selector = ContactRelationshipSelector.newInstance();

        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        List<Contact_Relationship__c> rels = [SELECT Id FROM Contact_Relationship__c];
        Set<Id> contactRelationshipIds = (new Map<Id, Contact_Relationship__c>(rels)).keySet();

        List<Contact_Relationship__c> contactRelationshipsForadminUser1;

        Test.startTest();
        System.runAs(adminUser1) {
            contactRelationshipsForadminUser1 = new ContactRelationshipSelector().selectById(contactRelationshipIds);
        }
        Test.stopTest();

        System.assertEquals(rels.size(), contactRelationshipsForadminUser1.size());
        for (Contact_Relationship__c rel : contactRelationshipsForadminUser1) {
            System.assert(contactRelationshipIds.contains(rel.Id));
        }
    }

    @isTest
    static void selectByIdOrTempKeyTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        List<Contact_Relationship__c> rels = [
            SELECT Id, TempId__c, From_Contact__c, To_Contact__c
            FROM Contact_Relationship__c
        ];
        Set<String> keys = new Set<String>();
        Boolean first = true;
        for (Contact_Relationship__c rel : rels) {
            if (first) {
                keys.add(rel.Id);
                first = false;
            }
            keys.add(rel.TempId__c);
        }

        List<Contact_Relationship__c> contactRelationshipsForadminUser1;

        Test.startTest();
        System.runAs(adminUser1) {
            contactRelationshipsForadminUser1 = new ContactRelationshipSelector().selectByIdOrTempKey(keys);
        }
        Test.stopTest();

        System.assertEquals(rels.size(), contactRelationshipsForadminUser1.size());
    }

    @isTest
    static void selectLocalRelationshipsByIdTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        List<Contact_Relationship__c> rels = [SELECT Id, From_Contact__c, To_Contact__c FROM Contact_Relationship__c];
        Set<Id> contactIds = new Set<Id>();
        for (Contact_Relationship__c rel : rels) {
            contactIds.add(rel.From_Contact__c);
            contactIds.add(rel.To_Contact__c);
        }

        Id relMapId = [SELECT Id FROM Relationship_Map__c LIMIT 1].Id;

        List<Contact_Relationship__c> contactRelationshipsForadminUser1;

        Test.startTest();
        System.runAs(adminUser1) {
            contactRelationshipsForadminUser1 = new ContactRelationshipSelector()
                .selectLocalRelationshipsById(contactIds, relMapId, false);
        }
        Test.stopTest();

        // 2 Active & Local
        System.assertEquals(2, contactRelationshipsForadminUser1.size());
    }

    @isTest
    static void selectGlobalRelationshipsByIdTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        List<Contact_Relationship__c> rels = [SELECT Id, From_Contact__c, To_Contact__c FROM Contact_Relationship__c];
        Relationship_Map__c relMap = [SELECT Id FROM Relationship_Map__c WHERE Name = 'mapName' LIMIT 1];

        Set<Id> contactIds = new Set<Id>();
        for (Contact_Relationship__c rel : rels) {
            contactIds.add(rel.From_Contact__c);
            contactIds.add(rel.To_Contact__c);
        }

        List<Contact_Relationship__c> contactRelationshipsForadminUser1;

        Test.startTest();
        System.runAs(adminUser1) {
            contactRelationshipsForadminUser1 = new ContactRelationshipSelector()
                .selectGlobalRelationshipsById(contactIds, relMap.Id, false);
        }
        Test.stopTest();

        // 1 Active & Global
        System.assertEquals(1, contactRelationshipsForadminUser1.size());
    }

    @isTest
    static void selectActiveCustomRelsByToOrFromTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        List<Contact_Relationship__c> rels = [SELECT Id, From_Contact__c, To_Contact__c FROM Contact_Relationship__c];

        Set<String> contactIds = new Set<String>();
        for (Contact_Relationship__c rel : rels) {
            contactIds.add(rel.From_Contact__c);
            contactIds.add(rel.To_Contact__c);
        }

        List<Contact_Relationship__c> result;

        Test.startTest();
        System.runAs(adminUser1) {
            result = new ContactRelationshipSelector().selectActiveCustomRelsByToOrFrom(contactIds);
        }
        Test.stopTest();

        System.assertEquals(3, result.size());
    }
}