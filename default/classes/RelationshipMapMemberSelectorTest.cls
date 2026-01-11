@isTest
private class RelationshipMapMemberSelectorTest {
    private static final String RM_NAME_1 = 'test relationship map 1';
    private static final String RM_NAME_2 = 'test relationship map 2';

    private static final String CONTACT_LAST_NAME_1 = 'test contact last Name 1';
    private static final String CONTACT_LAST_NAME_2 = 'test contact last Name 2';

    public static final String ADMIN_USER_FIRST_NAME = 'rmms test admin user first';
    public static final String ADMIN_USER_LAST_NAME = 'rmms test admin user last';

    public static final String NO_PREMISSION_USER_FIRST_NAME = 'chms test no perm user first';
    public static final String NO_PREMISSION_USER_LAST_NAME = 'chms test no perm user last';

    public static final String PRM_ADMIN_PERM = 'PROLIFIQ_RELATIONSHIP_MAP';

    public static final String STANDARD_USER = 'Standard User';

    /******************
     *** test setup ***
     *****************/

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];

        User adminUser = TestDataFactory.createUser(ADMIN_USER_FIRST_NAME, ADMIN_USER_LAST_NAME, standardProfile.Id);

        TestDataFactory.createUser(NO_PREMISSION_USER_FIRST_NAME, NO_PREMISSION_USER_LAST_NAME, standardProfile.Id);
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :PRM_ADMIN_PERM LIMIT 1];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = adminUserPermissionSet.Id)
        };

        System.runAs(adminUser) {
            Contact testContact1 = new Contact(LastName = CONTACT_LAST_NAME_1, Title = 'Title1');
            Contact testContact2 = new Contact(LastName = CONTACT_LAST_NAME_2);
            insert new List<Contact>{ testContact1, testContact2 };

            Relationship_Map__c map1 = TestDataFactory.createRelationshipMap(RM_NAME_1);
            TestDataFactory.createRelationshipMapMember(map1.Id, testContact1.Id);

            Relationship_Map__c map2 = TestDataFactory.createRelationshipMap(RM_NAME_2);
            TestDataFactory.createRelationshipMapMember(map2.Id, testContact1.Id);
            TestDataFactory.createRelationshipMapMember(map2.Id, testContact2.Id);
        }
    }

    /********************
     *** selectById() ***
     *******************/

    @isTest
    static void selectByIdNullTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(adminUser) {
            // When
            Test.startTest();

            List<Relationship_Map_Member__c> retrievedMembers = RelationshipMapMemberSelector.newInstance()
                .selectById(null);

            Test.stopTest();

            // Then
            System.assertEquals(0, retrievedMembers.size());
        }
    }

    @isTest
    static void selectByIdEmptyTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(adminUser) {
            // When
            Test.startTest();

            List<Relationship_Map_Member__c> retrievedMembers = RelationshipMapMemberSelector.newInstance()
                .selectById(new Set<Id>());

            Test.stopTest();

            // Then
            System.assertEquals(0, retrievedMembers.size());
        }
    }

    @isTest
    static void selectByIdValidNoPermTest() {
        // Given
        User noPermUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :NO_PREMISSION_USER_FIRST_NAME AND LastName = :NO_PREMISSION_USER_LAST_NAME
            LIMIT 1
        ];

        // Given
        Relationship_Map__c relationshipMap = [SELECT Id FROM Relationship_Map__c WHERE Name = :RM_NAME_1];
        Contact contact = [SELECT Id FROM Contact WHERE LastName = :CONTACT_LAST_NAME_1];
        Relationship_Map_Member__c member = [
            SELECT Id, Relationship_Map__c, Contact__c
            FROM Relationship_Map_Member__c
            WHERE Relationship_Map__c = :relationshipMap.Id AND Contact__c = :contact.Id
            LIMIT 1
        ];

        System.runAs(noPermUser) {
            // When
            Test.startTest();
            try {
                RelationshipMapMemberSelector.newInstance().selectById(new Set<Id>{ member.Id });
                System.assert(false, 'Should throw a access denied error');
            } catch (Exception e) {
                System.assert(true, 'Should throw a access denied error');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void selectByIdValidTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];
        Relationship_Map__c relationshipMap = [SELECT Id FROM Relationship_Map__c WHERE Name = :RM_NAME_1];
        Contact contact = [SELECT Id FROM Contact WHERE LastName = :CONTACT_LAST_NAME_1];
        Relationship_Map_Member__c member = [
            SELECT
                Id,
                Relationship_Map__c,
                Contact__c,
                InfluenceId__c,
                SupportId__c,
                Contact__r.Id,
                Contact__r.Email,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Name,
                Contact__r.Phone,
                Contact__r.Title
            FROM Relationship_Map_Member__c
            WHERE Relationship_Map__c = :relationshipMap.Id AND Contact__c = :contact.Id
            LIMIT 1
        ];

        System.runAs(adminUser) {
            // When
            Test.startTest();

            List<Relationship_Map_Member__c> retrievedMembers = RelationshipMapMemberSelector.newInstance()
                .selectById(new Set<Id>{ member.Id });

            Test.stopTest();

            // Then
            System.assertEquals(1, retrievedMembers.size());
            System.assertEquals(member.Id, retrievedMembers.get(0).Id);
        }
    }

    /********************
     *** selectByContactId() ***
     *******************/

    @isTest
    static void selectByContactIdNullTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(adminUser) {
            // When
            Test.startTest();

            List<Relationship_Map_Member__c> result = RelationshipMapMemberSelector.newInstance()
                .selectByContactId(null);

            Test.stopTest();

            // Then
            System.assertEquals(0, result.size());
        }
    }

    @isTest
    static void selectByContactIdEmptyTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(adminUser) {
            // When
            Test.startTest();

            List<Relationship_Map_Member__c> result = RelationshipMapMemberSelector.newInstance()
                .selectByContactId(new Set<Id>());

            Test.stopTest();

            // Then
            System.assertEquals(0, result.size());
        }
    }

    @isTest
    static void selectByContactIdValidNoPermTest() {
        // Given
        User noPermUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :NO_PREMISSION_USER_FIRST_NAME AND LastName = :NO_PREMISSION_USER_LAST_NAME
            LIMIT 1
        ];

        // Given
        Contact contact = [SELECT Id FROM Contact WHERE LastName = :CONTACT_LAST_NAME_1];

        System.runAs(noPermUser) {
            // When
            Test.startTest();
            try {
                RelationshipMapMemberSelector.newInstance().selectByContactId(new Set<Id>{ contact.Id });
                System.assert(false, 'Should throw a access denied error');
            } catch (Exception e) {
                System.assert(true, 'Should throw a access denied error');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void selectByContactIdValidTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        Contact contact = [SELECT Id FROM Contact WHERE LastName = :CONTACT_LAST_NAME_1];

        System.runAs(adminUser) {
            // When
            Test.startTest();

            List<Relationship_Map_Member__c> retrievedMembers = RelationshipMapMemberSelector.newInstance()
                .selectByContactId(new Set<Id>{ contact.Id });

            Test.stopTest();

            // Then
            System.assertEquals(2, retrievedMembers.size());
        }
    }

    /*******************************
     *** selectByIdOrContactIdAndMapId() ***
     ******************************/

    @isTest
    static void selectByIdOrContactIdAndMapIdNullTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];
        Relationship_Map__c relationshipMap = [SELECT Id FROM Relationship_Map__c WHERE Name = :RM_NAME_1];

        System.runAs(adminUser) {
            // When
            Test.startTest();

            List<Relationship_Map_Member__c> retrievedMembers = RelationshipMapMemberSelector.newInstance()
                .selectByIdOrContactIdAndMapId(null, relationshipMap.Id, new Set<String>(), new Set<String>());

            Test.stopTest();

            // Then
            System.assertEquals(0, retrievedMembers.size());
        }
    }

    @isTest
    static void selectByIdOrContactIdAndMapIdEmptyTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];
        Relationship_Map__c relationshipMap = [SELECT Id FROM Relationship_Map__c WHERE Name = :RM_NAME_1];

        System.runAs(adminUser) {
            // When
            Test.startTest();

            List<Relationship_Map_Member__c> retrievedMembers = RelationshipMapMemberSelector.newInstance()
                .selectByIdOrContactIdAndMapId(new Set<Id>(), relationshipMap.Id, new Set<String>(), new Set<String>());

            Test.stopTest();

            // Then
            System.assertEquals(0, retrievedMembers.size());
        }
    }

    @isTest
    static void selectByIdOrContactIdAndMapIdValidNoPermTest() {
        // Given
        User noPermUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :NO_PREMISSION_USER_FIRST_NAME AND LastName = :NO_PREMISSION_USER_LAST_NAME
            LIMIT 1
        ];

        // Given
        Relationship_Map__c relationshipMap = [SELECT Id FROM Relationship_Map__c WHERE Name = :RM_NAME_1];
        Contact contact = [SELECT Id, Title FROM Contact WHERE LastName = :CONTACT_LAST_NAME_1];
        Relationship_Map_Member__c member = [
            SELECT Id, Relationship_Map__c, Contact__c
            FROM Relationship_Map_Member__c
            WHERE Relationship_Map__c = :relationshipMap.Id AND Contact__c = :contact.Id
            LIMIT 1
        ];

        System.runAs(noPermUser) {
            // When
            Test.startTest();
            try {
                RelationshipMapMemberSelector.newInstance()
                    .selectByIdOrContactIdAndMapId(
                        new Set<Id>{ member.Id },
                        relationshipMap.Id,
                        new Set<String>(),
                        new Set<String>()
                    );
                System.assert(false, 'Should throw an access denied error');
            } catch (Exception e) {
                System.assert(true, 'Should throw an access denied error');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void selectByIdOrContactIdAndMapIdValidMapIdTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];
        Relationship_Map__c relationshipMap = [SELECT Id FROM Relationship_Map__c WHERE Name = :RM_NAME_1];
        Contact contact = [SELECT Id, Title FROM Contact WHERE LastName = :CONTACT_LAST_NAME_1];
        Relationship_Map_Member__c member = [
            SELECT
                Id,
                Relationship_Map__c,
                Contact__c,
                InfluenceId__c,
                SupportId__c,
                Contact__r.Id,
                Contact__r.Email,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Name,
                Contact__r.Phone,
                Contact__r.Title
            FROM Relationship_Map_Member__c
            WHERE Relationship_Map__c = :relationshipMap.Id AND Contact__c = :contact.Id
            LIMIT 1
        ];

        System.runAs(adminUser) {
            // When
            Test.startTest();

            List<Relationship_Map_Member__c> retrievedMembers = RelationshipMapMemberSelector.newInstance()
                .selectByIdOrContactIdAndMapId(
                    new Set<Id>{ member.Id },
                    relationshipMap.Id,
                    new Set<String>(),
                    new Set<String>{ 'Title' }
                );

            Test.stopTest();

            // Then
            System.assertEquals(1, retrievedMembers.size());
            System.assertEquals(member.Id, retrievedMembers.get(0).Id);
            System.assertEquals(contact.Title, retrievedMembers.get(0).Contact__r.Title);
        }
    }

    @isTest
    static void selectByIdOrContactIdAndMapIdValidContactIdTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];
        Relationship_Map__c relationshipMap = [SELECT Id FROM Relationship_Map__c WHERE Name = :RM_NAME_2];
        Contact contact = [SELECT Id, Title FROM Contact WHERE LastName = :CONTACT_LAST_NAME_1];
        Relationship_Map_Member__c member = [
            SELECT
                Id,
                Relationship_Map__c,
                Contact__c,
                InfluenceId__c,
                SupportId__c,
                Contact__r.Id,
                Contact__r.Email,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Name,
                Contact__r.Phone,
                Contact__r.Title
            FROM Relationship_Map_Member__c
            WHERE Relationship_Map__c = :relationshipMap.Id AND Contact__c = :contact.Id
            LIMIT 1
        ];

        System.runAs(adminUser) {
            // When
            Test.startTest();

            List<Relationship_Map_Member__c> retrievedMembers = RelationshipMapMemberSelector.newInstance()
                .selectByIdOrContactIdAndMapId(
                    new Set<Id>{ contact.Id },
                    relationshipMap.Id,
                    new Set<String>(),
                    new Set<String>{ 'Title' }
                );

            Test.stopTest();

            // Then
            System.assertEquals(1, retrievedMembers.size());
            System.assertEquals(member.Id, retrievedMembers.get(0).Id);
            System.assertEquals(contact.Title, retrievedMembers.get(0).Contact__r.Title);
        }
    }

    /*******************************************************************
     *** selectByRelationshipMapIdsAndSelectFieldsWithYourContacts() ***
     ******************************************************************/

    @isTest
    static void selectByRelationshipMapIdsAndSelectFieldsWithYourContactsNullIdValidFieldsTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(adminUser) {
            // When
            Test.startTest();

            List<Relationship_Map_Member__c> retrievedMembers = RelationshipMapMemberSelector.newInstance()
                .selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
                    null,
                    new Set<String>{ Relationship_Map_Member__c.SupportId__c.getDescribe().getName() },
                    new Set<String>()
                );

            Test.stopTest();

            // Then
            System.assertEquals(0, retrievedMembers.size());
        }
    }

    @isTest
    static void selectByRelationshipMapIdsAndSelectFieldsWithYourContactsEmptyIdValidFieldsTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(adminUser) {
            // When
            Test.startTest();

            List<Relationship_Map_Member__c> retrievedMembers = RelationshipMapMemberSelector.newInstance()
                .selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
                    new Set<Id>(),
                    new Set<String>{ Relationship_Map_Member__c.SupportId__c.getDescribe().getName() },
                    new Set<String>()
                );

            Test.stopTest();

            // Then
            System.assertEquals(0, retrievedMembers.size());
        }
    }

    @isTest
    static void selectByRelationshipMapIdsAndSelectFieldsWithYourContactsValidIdNullFieldsTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];
        Relationship_Map__c relationshipMap = [SELECT Id FROM Relationship_Map__c WHERE Name = :RM_NAME_1];
        Contact contact = [SELECT Id FROM Contact WHERE LastName = :CONTACT_LAST_NAME_1];
        Relationship_Map_Member__c member = [
            SELECT Id, Relationship_Map__c, Contact__c
            FROM Relationship_Map_Member__c
            WHERE Relationship_Map__c = :relationshipMap.Id AND Contact__c = :contact.Id
            LIMIT 1
        ];

        System.runAs(adminUser) {
            // When
            Test.startTest();

            List<Relationship_Map_Member__c> retrievedMembers = RelationshipMapMemberSelector.newInstance()
                .selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
                    new Set<Id>{ relationshipMap.Id },
                    null,
                    null
                );

            Test.stopTest();

            // Then
            System.assertEquals(1, retrievedMembers.size());
            System.assertEquals(member.Id, retrievedMembers.get(0).Id);
        }
    }

    @isTest
    static void selectByRelationshipMapIdsAndSelectFieldsWithYourContactsValidIdEmptyFieldsTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];
        Relationship_Map__c relationshipMap = [SELECT Id FROM Relationship_Map__c WHERE Name = :RM_NAME_1];
        Contact contact = [SELECT Id FROM Contact WHERE LastName = :CONTACT_LAST_NAME_1];
        Relationship_Map_Member__c member = [
            SELECT Id, Relationship_Map__c, Contact__c
            FROM Relationship_Map_Member__c
            WHERE Relationship_Map__c = :relationshipMap.Id AND Contact__c = :contact.Id
            LIMIT 1
        ];

        System.runAs(adminUser) {
            // When
            Test.startTest();

            List<Relationship_Map_Member__c> retrievedMembers = RelationshipMapMemberSelector.newInstance()
                .selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
                    new Set<Id>{ relationshipMap.Id },
                    new Set<String>(),
                    new Set<String>()
                );

            Test.stopTest();

            // Then
            System.assertEquals(1, retrievedMembers.size());
            System.assertEquals(member.Id, retrievedMembers.get(0).Id);
        }
    }

    @isTest
    static void selectByRelationshipMapIdsAndSelectFieldsWithYourContactsNoPermTest() {
        // Given
        User noPermUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :NO_PREMISSION_USER_FIRST_NAME AND LastName = :NO_PREMISSION_USER_LAST_NAME
            LIMIT 1
        ];
        List<String> mapNames = new List<String>{ RM_NAME_1, RM_NAME_2 };
        List<Relationship_Map__c> relationshipMaps = [SELECT Id FROM Relationship_Map__c WHERE Name IN :mapNames];
        Set<Id> mapIds = new Map<Id, Relationship_Map__c>(relationshipMaps).keySet();

        System.runAs(noPermUser) {
            // When
            Test.startTest();

            try {
                RelationshipMapMemberSelector.newInstance()
                    .selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
                        mapIds,
                        new Set<String>{ Relationship_Map_Member__c.SupportId__c.getDescribe().getName() },
                        new Set<String>()
                    );
                System.assert(false, 'Should throw a access denied error');
            } catch (Exception e) {
                System.assert(true, 'Should throw a access denied error');
            }

            Test.stopTest();

            // Then
        }
    }

    @isTest
    static void selectByRelationshipMapIdsAndSelectFieldsWithYourContactsValidIdValidFieldsTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];
        Relationship_Map__c relationshipMap = [SELECT Id FROM Relationship_Map__c WHERE Name = :RM_NAME_1];
        Contact contact = [SELECT Id, Title FROM Contact WHERE LastName = :CONTACT_LAST_NAME_1];
        Relationship_Map_Member__c member = [
            SELECT Id, Relationship_Map__c, Contact__c, Contact__r.Title, SupportId__c
            FROM Relationship_Map_Member__c
            WHERE Relationship_Map__c = :relationshipMap.Id AND Contact__c = :contact.Id
            LIMIT 1
        ];

        Set<String> contactFields = new Set<String>{ 'Title' };

        System.runAs(adminUser) {
            // When
            Test.startTest();

            List<Relationship_Map_Member__c> retrievedMembers = RelationshipMapMemberSelector.newInstance()
                .selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
                    new Set<Id>{ relationshipMap.Id },
                    new Set<String>{ Relationship_Map_Member__c.SupportId__c.getDescribe().getName() },
                    contactFields
                );

            Test.stopTest();

            // Then
            System.assertEquals(1, retrievedMembers.size());
            System.assertEquals(member.Id, retrievedMembers.get(0).Id);
            System.assertEquals(contact.Title, retrievedMembers.get(0).Contact__r.Title);
        }
    }

    @isTest
    static void selectByRelationshipMapIdsAndSelectFieldsWithYourContactsValidIdValidFieldsMultiTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];
        List<String> mapNames = new List<String>{ RM_NAME_1, RM_NAME_2 };
        List<Relationship_Map__c> relationshipMaps = [SELECT Id FROM Relationship_Map__c WHERE Name IN :mapNames];
        Set<Id> mapIds = new Map<Id, Relationship_Map__c>(relationshipMaps).keySet();

        System.runAs(adminUser) {
            // When
            Test.startTest();

            List<Relationship_Map_Member__c> retrievedMembers = RelationshipMapMemberSelector.newInstance()
                .selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
                    mapIds,
                    new Set<String>{ Relationship_Map_Member__c.SupportId__c.getDescribe().getName() },
                    new Set<String>()
                );

            Test.stopTest();

            // Then
            System.assertEquals(3, retrievedMembers.size());
        }
    }

    /**************************
     *** selectDuplicates() ***
     *************************/

    @isTest
    static void selectDuplicatesTest() {
        // Given
        Relationship_Map__c relationshipMap = [SELECT Id FROM Relationship_Map__c WHERE Name = :RM_NAME_1];
        Contact contact = [SELECT Id FROM Contact WHERE LastName = :CONTACT_LAST_NAME_1];
        Relationship_Map_Member__c member = [
            SELECT Id, Relationship_Map__c, Contact__c, SupportId__c
            FROM Relationship_Map_Member__c
            WHERE Relationship_Map__c = :relationshipMap.Id AND Contact__c = :contact.Id
            LIMIT 1
        ];
        Contact testContact = new Contact(LastName = 'onValidateInsertInvalidTest new contact');
        insert testContact;

        Relationship_Map_Member__c duplicateMember = new Relationship_Map_Member__c(
            Relationship_Map__c = member.Relationship_Map__c,
            Contact__c = member.Contact__c,
            InfluenceId__c = null,
            SupportId__c = null
        );

        Relationship_Map_Member__c nonDuplicateMember = new Relationship_Map_Member__c(
            Relationship_Map__c = relationshipMap.Id,
            Contact__c = testContact.Id,
            InfluenceId__c = null,
            SupportId__c = null
        );

        // When
        Test.startTest();

        List<Relationship_Map_Member__c> returnedMembers = RelationshipMapMemberSelector.newInstance()
            .selectDuplicatesAsSystem(new List<Relationship_Map_Member__c>{ duplicateMember, nonDuplicateMember });

        Test.stopTest();

        // Then
        System.assertEquals(1, returnedMembers.size());
        System.assertEquals(duplicateMember, returnedMembers[0]);
    }

    /*******************************************
     *** selectByAccountPlanIdsWithHistory() ***
     ******************************************/

    @isTest
    static void selectByAccountPlanIdsWithHistoryTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];
        Account_Plan__c accountPlan = TestDataFactory.createAccountPlan('A random plan');
        Relationship_Map__c relationshipMap = TestDataFactory.createRelationshipMap('Some Map', accountPlan.Id);
        Contact contact = [SELECT Id FROM Contact WHERE LastName = :CONTACT_LAST_NAME_1];
        Relationship_Map_Member__c member = TestDataFactory.createRelationshipMapMember(relationshipMap.Id, contact.Id);

        System.runAs(adminUser) {
            // When
            Test.startTest();

            List<Relationship_Map_Member__c> retrievedMembers = RelationshipMapMemberSelector.newInstance()
                .selectByAccountPlanIdsWithHistory(
                    new Set<Id>{ accountPlan.Id },
                    RelationshipMapMemberSelector.HISTORY_FIELDS
                );

            Test.stopTest();

            // Then
            System.assertEquals(1, retrievedMembers.size());
            System.assertEquals(member.Id, retrievedMembers.get(0).Id);
            System.assertNotEquals(null, retrievedMembers.get(0).Histories);
        }
    }
}