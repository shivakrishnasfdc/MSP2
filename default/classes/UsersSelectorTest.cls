@isTest
private class UsersSelectorTest {
    public static final String USER1_FIRST_NAME = 'gandalf';
    public static final String USER1_LAST_NAME = 'grey';

    public static final String USER2_FIRST_NAME = 'saruman';
    public static final String USER2_LAST_NAME = 'white';

    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    public static final String STANDARD_USER = 'Standard User';

    @testSetup
    static void testSetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];
        User gandalf = TestDataFactory.createUser(USER1_FIRST_NAME, USER1_LAST_NAME, p.Id);
        User saruman = TestDataFactory.createUser(USER2_FIRST_NAME, USER2_LAST_NAME, p.Id);

        PermissionSet standardUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_STANDARD_USER];
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = saruman.Id, PermissionSetId = standardUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = gandalf.Id, PermissionSetId = adminUserPermissionSet.Id)
        };
    }

    @isTest
    static void selectByIdTest() {
        // Given
        List<User> users = [SELECT Id FROM User WHERE FirstName IN (:USER1_FIRST_NAME, :USER2_FIRST_NAME)];

        Set<Id> userIds = new Set<Id>();
        for (User user : users) {
            userIds.add(user.Id);
        }

        // When
        List<User> queriedUsers = new UsersSelector().selectById(userIds);

        // Then
        System.assertEquals(2, queriedUsers.size());
    }

    // @isTest
    // static void selectNotById() {
    //     // Given
    //     User myUser = [SELECT Id FROM User WHERE LastName = 'grey' LIMIT 1];

    //     // When
    //     List<User> users = new UsersSelector().selectNotById(new Set<Id>{ myUser.Id });

    //     // Then
    //     for (User u : users) {
    //         System.assertNotEquals(myUser.Id, u.Id);
    //     }
    // }

    @isTest
    static void selectByPermissionSetNameTest() {
        // Given
        User gandalf = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME];
        User saruman = [SELECT Id FROM User WHERE LastName = :USER2_LAST_NAME];

        // When
        List<User> standardUsers = new UsersSelector().selectByPermissionSetName('CRUSH_Standard_User');
        List<User> adminUsers = new UsersSelector().selectByPermissionSetName('CRUSH_Administrator');

        Set<Id> standardUserIds = new Map<Id, User>(standardUsers).keyset();
        Set<Id> adminUserIds = new Map<Id, User>(adminUsers).keyset();

        // Then
        System.assertEquals(true, standardUserIds.contains(saruman.Id));
        System.assertEquals(false, standardUserIds.contains(gandalf.Id));

        System.assertEquals(true, adminuserIds.contains(gandalf.Id));
        System.assertEquals(false, adminuserIds.contains(saruman.Id));
    }

    @isTest
    static void  selectActiveUserIdsAsSystem() {
        // Given
        User gandalf = [SELECT Id from User WHERE LastName = :USER1_LAST_NAME];
        User saruman = [SELECT Id from User WHERE LastName = :USER2_LAST_NAME];

        gandalf.isActive = false;
        update gandalf;

        Set<Id> userIds = new Set<Id> { gandalf.id, saruman.id };

        // When
        Set<Id> results = UsersSelector.newInstance().selectActiveUserIdsAsSystem(userIds);
        
        //Then
        System.assertEquals(1, results.size());
        System.assertEquals(true, results.contains(saruman.id));
    }
}