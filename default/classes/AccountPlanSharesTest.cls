@isTest
private class AccountPlanSharesTest {
    private static final String USER_LAST_NAME = '1';

    @testSetup
    static void setup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User admin = TestDataFactory.createUser('a', USER_LAST_NAME, standardProfile.Id);

        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'CRUSH_Administrator'];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = admin.Id, PermissionSetId = adminUserPermissionSet.Id)
        };

        System.runAs(admin) {
            Account a = new Account(Name = 'Account 1');
            insert a;

            AccountPlans.bypassEmailTrigger = true;
            TestDataFactory.createAccountPlan('account plan 1', a);
        }
    }

    @isTest
    static void constructorTest() {
        System.assertNotEquals(null, new AccountPlanShares(new List<Account_Plan__Share>()));
        System.assertEquals(
            false,
            new AccountPlanShares(new List<Account_Plan__Share>()).Configuration.EnforcingTriggerCRUDSecurity,
            'Should not be enforcing Trigger CRUD Security due to complications with automation in customer orgs'
        );
    }

    @isTest
    static void getUniqueKeyTest() {
        // Given
        User user = [SELECT Id FROM User][0];
        Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c][0];
        Account_Plan__Share accountPlanShare = new Account_Plan__Share(
            ParentId = accountPlan.Id,
            UserOrGroupId = user.Id,
            accessLevel = 'Read'
        );

        // When
        String uniqueKey = AccountPlanShares.getUniqueKey(accountPlanShare);

        // Then
        String expectedValue =
            String.valueOf(accountPlanShare.ParentId) + String.valueOf(accountPlanShare.UserOrGroupId);
        System.assertEquals(expectedValue, uniqueKey);
    }

    @isTest
    static void calculateAccessLevelTest() {
        // Given
        Team_Member__c readOnlyMember = new Team_Member__c(Role__c = 'Read Only');
        Team_Member__c readWriteMember = new Team_Member__c(Role__c = 'Edit');

        // When
        String readOnlyAccessLevel = AccountPlanShares.calculateAccessLevel(readOnlyMember);
        String readWriteAccessLevel = AccountPlanShares.calculateAccessLevel(readWriteMember);

        // Then
        System.assertEquals('Read', readOnlyAccessLevel);
        System.assertEquals('Edit', readWriteAccessLevel);
    }

    @isTest
    static void setReadOnly() {
        // Given
        User user = [SELECT Id FROM User WHERE LastName = :USER_LAST_NAME][0];
        Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c][0];
        Account_Plan__Share accountPlanShare = new Account_Plan__Share(
            ParentId = accountPlan.Id,
            UserOrGroupId = user.Id,
            AccessLevel = 'Edit',
            RowCause = Schema.Account_Plan__Share.RowCause.Account_Plan_Team__c
        );
        insert accountPlanShare;

        // When
        Test.startTest();

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        AccountPlanShares.newInstance(new List<Account_Plan__Share>{ accountPlanShare }).setReadOnly(uow);
        uow.commitWork();

        Test.stopTest();

        // Then
        List<Account_Plan__Share> queriedRecords = [
            SELECT ParentId, UserOrGroupId, RowCause, AccessLevel
            FROM Account_Plan__Share
            WHERE RowCause = :Schema.Account_Plan__Share.RowCause.Account_Plan_Team__c
        ];

        System.assertEquals(1, queriedRecords.size(), 'Expected only 1 record.');
        System.assertEquals(user.Id, queriedRecords[0].UserOrGroupId, 'Expected UserOrGroupId to be the same.');
        System.assertEquals(accountPlan.Id, queriedRecords[0].ParentId, 'Expected ParentId to be the same.');
        System.assertEquals('Read', queriedRecords[0].AccessLevel, 'Expected AccessLevel to be updated.');
    }
}