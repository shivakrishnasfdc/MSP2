@isTest
private class CustomPermissionsReaderTest {
    private static final String PERMISSION_SET_NAME = 'test';
    public static final String STANDARD_USER_FIRST_NAME = 'Stan';
    public static final String STANDARD_USER_LAST_NAME = 'Standard';

    public static final String NON_USER_FIRST_NAME = 'Nancy';
    public static final String NON_USER_LAST_NAME = 'NonUser';

    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';

    @testSetup
    static void testSetup() {
        PermissionSet permissionSet = new PermissionSet();
        permissionSet.Name = PERMISSION_SET_NAME;
        permissionSet.Label = PERMISSION_SET_NAME;
        insert permissionSet;

        // Add the custom permission to the permission set
        SetupEntityAccess access = new SetupEntityAccess();
        access.ParentId = permissionSet.Id;
        access.SetupEntityId = [SELECT Id FROM CustomPermission WHERE DeveloperName = 'Crush_Settings_Permission'][0]
        .Id;
        insert access;

        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        TestDataFactory.createUser(Non_USER_FIRST_NAME, Non_USER_LAST_NAME, standardProfile.Id);

        User standardUser = TestDataFactory.createUser(
            STANDARD_USER_FIRST_NAME,
            STANDARD_USER_LAST_NAME,
            standardProfile.Id
        );
        PermissionSet standardUserPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = :CRUSH_STANDARD_USER
            LIMIT 1
        ];

        insert new PermissionSetAssignment(
            AssigneeId = standardUser.Id,
            PermissionSetId = standardUserPermissionSet.Id
        );
    }

    @isTest
    private static void testInvalidCustomPermission() {
        CustomPermissionsReader cpr = new CustomPermissionsReader();

        try {
            cpr.hasPermission('invalid giberish $%#)!*#');
            System.assert(false, 'Expected exception to be thrown.');
        } catch (CustomPermissionsReader.CustomPermissionsException e) {
            System.assert(true, 'Exception was thrown.');
        }
    }

    @isTest
    private static void testCustomPermissionNotAssigned() {
        // Given
        User standardUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :Non_USER_FIRST_NAME AND LastName = :Non_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(standardUser) {
            CustomPermissionsReader cpr = new CustomPermissionsReader(Account_Plan__c.SObjectType);
            System.assertEquals(false, cpr.hasPermission('Crush_Settings_Permission'));
        }
    }

    @isTest
    private static void testCustomPermissionAssigned() {
        // Given
        PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = :PERMISSION_SET_NAME];

        User standardUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :STANDARD_USER_FIRST_NAME AND LastName = :STANDARD_USER_LAST_NAME
            LIMIT 1
        ];

        // When
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
        permissionSetAssignment.AssigneeId = standardUser.Id;
        permissionSetAssignment.PermissionSetId = permissionSet.Id;
        insert permissionSetAssignment;

        System.runAs(standardUser) {
            CustomPermissionsReader cpr = new CustomPermissionsReader(Account_Plan__c.SObjectType);

            // Then
            System.assertEquals(true, cpr.hasPermission('Crush_Settings_Permission'));
        }
    }
}