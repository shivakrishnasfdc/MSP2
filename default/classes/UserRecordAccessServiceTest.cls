@isTest
private class UserRecordAccessServiceTest {
    public static final String STANDARD_USER1_FIRST_NAME = 'Manheim';
    public static final String STANDARD_USER1_LAST_NAME = 'Visa';

    public static final String STANDARD_USER2_FIRST_NAME = 'Krabby';
    public static final String STANDARD_USER2_LAST_NAME = 'Patty';

    public static final String CREATOR_USER_FIRST_NAME = 'Shabby';
    public static final String CREATOR_USER_LAST_NAME = 'Break';

    public static final String ADMIN_USER_FIRST_NAME = 'Apple';
    public static final String ADMIN_USER_LAST_NAME = 'AAAAAAA';

    public static final String ACCOUNT_PLAN1_NAME = 'Account Plan 1';
    public static final String ACCOUNT_PLAN2_NAME = 'Account Plan 2';
    public static final String ACCOUNT_PLAN3_NAME = 'Account Plan 3';

    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';
    public static final String CRUSH_ACCOUNT_PLAN_CREATOR = 'CRUSH_Account_Plan_Creator';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User standardUser1 = TestDataFactory.createUser(
            STANDARD_USER1_FIRST_NAME,
            STANDARD_USER1_LAST_NAME,
            standardProfile.Id
        );
        User standardUser2 = TestDataFactory.createUser(
            STANDARD_USER2_FIRST_NAME,
            STANDARD_USER2_LAST_NAME,
            standardProfile.Id
        );
        User creatorUser = TestDataFactory.createUser(
            CREATOR_USER_FIRST_NAME,
            CREATOR_USER_LAST_NAME,
            standardProfile.Id
        );
        User adminUser = TestDataFactory.createUser(ADMIN_USER_FIRST_NAME, ADMIN_USER_LAST_NAME, adminProfile.Id);

        PermissionSet standardUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_STANDARD_USER];
        PermissionSet creatorUserPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = :CRUSH_ACCOUNT_PLAN_CREATOR
        ];
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];

        List<PermissionSetAssignment> permissionSets = new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = standardUser1.Id, PermissionSetId = standardUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = standardUser2.Id, PermissionSetId = standardUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = creatorUser.Id, PermissionSetId = creatorUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = adminUserPermissionSet.Id)
        };

        Id systemUserId = UserInfo.getUserId();
        PermissionSetAssignment systemStrategyAdminPermissions = TestDataFactory.createPermissionSetAssignment(
            systemUserId,
            adminUserPermissionSet.Id
        );

        if (systemStrategyAdminPermissions != null) {
            permissionSets.add(systemStrategyAdminPermissions);
        }

        insert permissionSets;

        System.runAs(creatorUser) {
            Account testAccount = new Account(Name = 'Account 1');
            insert testAccount;

            AccountPlans.bypassEmailTrigger = true;
            Application.bypassTrigger = true;
            TestDataFactory.createAccountPlan(ACCOUNT_PLAN1_NAME, testAccount, 'Open');
            TestDataFactory.createAccountPlan(ACCOUNT_PLAN2_NAME, testAccount, 'Closed');
            TestDataFactory.createAccountPlan(ACCOUNT_PLAN3_NAME, testAccount, 'Open');
        }

        System.runAs(adminUser) {
            Crush_Settings_Obj__c orgSettings = new Crush_Settings_Obj__c(Type__c = 'Org');
            insert orgSettings;
        }
    }

    @isTest
    static void recordAccessForRecordsTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        UserRecordAccessSelector mockSelector = (UserRecordAccessSelector) FFLibHelper.mockSelector(
            UserRecordAccessSelector.class,
            mocks
        );
        Application.Selector.setMock(mockSelector);

        // Given
        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
        Account_Plan__c accountPlan2 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME];
        Set<Id> accountPlanIds = new Set<Id>{ accountPlan1.Id, accountPlan2.Id };

        List<Account_Plan__c> accountPlans = new List<Account_Plan__c>{ accountPlan1, accountPlan2 };

        // When
        Test.startTest();
        UserRecordAccessService.recordAccessForRecords(accountPlans);
        Test.stopTest();

        // Then
        try {
            ((UserRecordAccessSelector) mocks.verify(mockSelector, 1)).selectByRecordId(accountPlanIds);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Did not Call selectByRecordId()');
        }
    }
}