@isTest
private class CrushSettingsObjSelectorTest {
    public static final String USER1_FIRST_NAME = 'standard';
    public static final String USER1_LAST_NAME = 'suzie';

    public static final String USER2_FIRST_NAME = 'admin';
    public static final String USER2_LAST_NAME = 'adam';

    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    public static final String STANDARD_USER_PROFILE = 'Standard User';

    @testSetup
    static void testSetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER_PROFILE];
        User standardSuzie = TestDataFactory.createUser(USER1_FIRST_NAME, USER1_LAST_NAME, p.Id);
        User adminAdam = TestDataFactory.createUser(USER2_FIRST_NAME, USER2_LAST_NAME, p.Id);

        PermissionSet standardUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_STANDARD_USER];
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = standardSuzie.Id, PermissionSetId = standardUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = adminAdam.Id, PermissionSetId = adminUserPermissionSet.Id)
        };

        System.runAs(adminAdam) {
            insert new CRUSH_Settings_Obj__c(Type__c = 'Org');
            insert new CRUSH_Settings_Obj__c(Type__c = 'User', User__c = standardSuzie.Id);
        }
    }

    @isTest
    static void selectOrgSettingsObjTest() {
        // Given
        User adminAdam = [SELECT Id FROM User WHERE FirstName = :USER2_FIRST_NAME LIMIT 1];

        // When
        List<CRUSH_Settings_Obj__c> result = new List<CRUSH_Settings_Obj__c>();
        System.runAs(adminAdam) {
            result = new CrushSettingsObjSelector().selectOrgSettingsObj();
        }

        // Then
        System.assertEquals(1, result.size());
        System.assertEquals('Org', result[0].Type__c);
    }

    @isTest
    static void selectUserSettingsObjTest() {
        // Given
        User standardSuzie = [SELECT Id FROM User WHERE FirstName = :USER1_FIRST_NAME LIMIT 1];

        // When
        List<CRUSH_Settings_Obj__c> result = new List<CRUSH_Settings_Obj__c>();
        System.runAs(standardSuzie) {
            result = new CrushSettingsObjSelector().selectUserSettingsObj(standardSuzie.Id);
        }

        // Then
        System.assertEquals(0, result.size());
        //System.assertEquals('User', result[0].Type__c);
        //System.assertEquals(standardSuzie.Id, result[0].User__c);
    }
}