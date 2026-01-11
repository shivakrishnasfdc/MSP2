@isTest
private class MapMemberUserSelectorTest {
    private static final String RM_NAME_1 = 'test relationship map 1';
    private static final String RM_NAME_2 = 'test relationship map 2';

    private static final String CONTACT_LAST_NAME_1 = 'test contact last Name 1';
    private static final String CONTACT_LAST_NAME_2 = 'test contact last Name 2';

    public static final String ADMIN_USER_FIRST_NAME = 'rmms test admin user first';
    public static final String ADMIN_USER_LAST_NAME = 'rmms test admin user last';

    public static final String USER1_FIRST_NAME = 'user1first';
    public static final String USER1_LAST_NAME = 'user1last';

    public static final String USER2_FIRST_NAME = 'user2first';
    public static final String USER2_LAST_NAME = 'user2last';

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

        User user1 = TestDataFactory.createUser(USER1_FIRST_NAME, USER1_LAST_NAME, standardProfile.Id);
        User user2 = TestDataFactory.createUser(USER2_FIRST_NAME, USER2_LAST_NAME, standardProfile.Id);

        TestDataFactory.createUser(NO_PREMISSION_USER_FIRST_NAME, NO_PREMISSION_USER_LAST_NAME, standardProfile.Id);
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :PRM_ADMIN_PERM LIMIT 1];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = adminUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = user1.Id, PermissionSetId = adminUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = user2.Id, PermissionSetId = adminUserPermissionSet.Id)
        };

        System.runAs(adminUser) {
            Contact testContact1 = new Contact(LastName = CONTACT_LAST_NAME_1, Title = 'Title1');
            Contact testContact2 = new Contact(LastName = CONTACT_LAST_NAME_2);
            insert new List<Contact>{ testContact1, testContact2 };

            Relationship_Map__c map1 = TestDataFactory.createRelationshipMap(RM_NAME_1);
            TestDataFactory.createMapMemberUser(map1, user1);

            Relationship_Map__c map2 = TestDataFactory.createRelationshipMap(RM_NAME_2);
            TestDataFactory.createMapMemberUser(map2, user1);
            TestDataFactory.createMapMemberUser(map2, user2);
        }
    }

    /********************
     *** selectById() ***
     *******************/

    @isTest
    static void newInstanceTest() {
        MapMemberUserSelector selector = MapMemberUserSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

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
            List<Map_Member_User__c> result = MapMemberUserSelector.newInstance().selectById(null);
            Test.stopTest();

            // Then
            System.assertEquals(0, result.size());
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
            List<Map_Member_User__c> result = MapMemberUserSelector.newInstance().selectById(new Set<Id>());
            Test.stopTest();

            // Then
            System.assertEquals(0, result.size());
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
        User user1 = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME];
        Map_Member_User__c member = [
            SELECT Id, Relationship_Map__c, User__c
            FROM Map_Member_User__c
            WHERE Relationship_Map__c = :relationshipMap.Id AND User__c = :user1.Id
            LIMIT 1
        ];

        System.runAs(noPermUser) {
            // When
            Test.startTest();
            try {
                MapMemberUserSelector.newInstance().selectById(new Set<Id>{ member.Id });
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
        User user1 = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME];
        Map_Member_User__c member = [
            SELECT Id, Relationship_Map__c, User__c
            FROM Map_Member_User__c
            WHERE Relationship_Map__c = :relationshipMap.Id AND User__c = :user1.Id
        ];

        System.runAs(adminUser) {
            // When
            Test.startTest();

            List<Map_Member_User__c> result = MapMemberUserSelector.newInstance().selectById(new Set<Id>{ member.Id });

            Test.stopTest();

            // Then
            System.assertEquals(1, result.size());
            System.assertEquals(member.Id, result.get(0).Id);
        }
    }

    /*******************************
     *** selectByObjectIdsWithYourUsersAndFields() ***
     ******************************/

    @isTest
    static void selectByObjectIdsWithYourUsersAndFieldsNullTest() {
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
            List<Map_Member_User__c> result = MapMemberUserSelector.newInstance()
                .selectByObjectIdsWithYourUsersAndFields(null, null, null);
            Test.stopTest();

            // Then
            System.assertEquals(0, result.size());
        }
    }

    @isTest
    static void selectByObjectIdsWithYourUsersAndFieldsTest1() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        Relationship_Map__c rm = [SELECT Id FROM Relationship_Map__c WHERE Name = :RM_NAME_1];

        System.runAs(adminUser) {
            // When
            Test.startTest();
            List<Map_Member_User__c> result = MapMemberUserSelector.newInstance()
                .selectByObjectIdsWithYourUsersAndFields(new Set<Id>{ rm.Id }, null, null);
            Test.stopTest();

            // Then
            System.assertEquals(1, result.size());
        }
    }

    @isTest
    static void selectByObjectIdsWithYourUsersAndFieldsTest2() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        Relationship_Map__c rm = [SELECT Id FROM Relationship_Map__c WHERE Name = :RM_NAME_2];

        System.runAs(adminUser) {
            // When
            Test.startTest();
            List<Map_Member_User__c> result = MapMemberUserSelector.newInstance()
                .selectByObjectIdsWithYourUsersAndFields(new Set<Id>{ rm.Id }, null, new Set<String>{ 'Title' });
            Test.stopTest();

            // Then
            System.assertEquals(2, result.size());
        }
    }

    /**************************
     *** selectDuplicates() ***
     *************************/

    @isTest
    static void selectDuplicatesTest() {
        // Given
        Relationship_Map__c relationshipMap = [SELECT Id FROM Relationship_Map__c WHERE Name = :RM_NAME_1];
        User user1 = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME];

        Map_Member_User__c member = [
            SELECT Id, Relationship_Map__c, User__c
            FROM Map_Member_User__c
            WHERE Relationship_Map__c = :relationshipMap.Id AND User__c = :user1.Id
            LIMIT 1
        ];

        Map_Member_User__c duplicateMember = new Map_Member_User__c(
            Relationship_Map__c = member.Relationship_Map__c,
            User__c = member.User__c
        );

        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];
        User user3 = TestDataFactory.createUser('l3', 'f3', standardProfile.Id);

        Map_Member_User__c nonDuplicateMember = new Map_Member_User__c(
            Relationship_Map__c = relationshipMap.Id,
            User__c = user3.Id
        );

        // When
        Test.startTest();

        List<Map_Member_User__c> returnedMembers = MapMemberUserSelector.newInstance()
            .selectDuplicatesAsSystem(new List<Map_Member_User__c>{ duplicateMember, nonDuplicateMember });

        Test.stopTest();

        // Then
        System.assertEquals(1, returnedMembers.size());
        System.assertEquals(duplicateMember, returnedMembers[0]);
    }
}