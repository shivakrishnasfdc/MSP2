@isTest
private class AccountPlanOpportunitiesTest {
    private static final String ACCOUNT_PLAN_NAME = 'Account Plan 1';
    private static final String FIRST_OPPORTUNITY_NAME = 'Entire Roast';
    private static final String SECOND_OPPORTUNITY_NAME = 'Round here';

    private static final String USER_LAST_NAME = 'Smith';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User admin = TestDataFactory.createUser('user', USER_LAST_NAME, standardProfile.Id);

        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'CRUSH_Administrator'];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = admin.Id, PermissionSetId = adminUserPermissionSet.Id)
        };

        System.runAs(admin) {
            Account testAccount = new Account(Name = 'Account 1');
            insert testAccount;

            AccountPlans.bypassEmailTrigger = true;

            Account_Plan__c testAccountPlan = TestDataFactory.createAccountPlan(ACCOUNT_PLAN_NAME, testAccount);

            Opportunity testOpportunity1 = TestDataFactory.createOpportunity(testAccount, FIRST_OPPORTUNITY_NAME);
            Opportunity testOpportunity2 = TestDataFactory.createOpportunity(testAccount, SECOND_OPPORTUNITY_NAME);
            insert new List<Opportunity>{ testOpportunity1, testOpportunity2 };

            Account_Plan_Opportunity__c testAccountPlanOpportunity1 = TestDataFactory.createAccountPlanOpportunity(
                testAccountPlan,
                testOpportunity1
            );
            Account_Plan_Opportunity__c testAccountPlanOpportunity2 = TestDataFactory.createAccountPlanOpportunity(
                testAccountPlan,
                testOpportunity2
            );
            insert new List<Account_Plan_Opportunity__c>{ testAccountPlanOpportunity1, testAccountPlanOpportunity2 };
        }
    }

    @isTest
    static void constructorTest() {
        System.assertNotEquals(null, new AccountPlanOpportunities(new List<Account_Plan_Opportunity__c>()));
        System.assertEquals(
            false,
            new AccountPlanOpportunities(new List<Account_Plan_Opportunity__c>())
                .Configuration.EnforcingTriggerCRUDSecurity,
            'Should not be enforcing Trigger CRUD Security due to complications with automation in customer orgs'
        );
    }

    @isTest
    static void getUniqueKeyTest() {
        // Given
        Account_Plan_Opportunity__c testAccountPlanOpportunity = [
            SELECT Id, Account_Plan__c, Opportunity__c
            FROM Account_Plan_Opportunity__c
        ][0];

        // When
        Test.startTest();

        String uniqueKey = AccountPlanOpportunities.getUniqueKey(testAccountPlanOpportunity);

        Test.stopTest();

        // Then
        String expectedValue =
            String.valueOf(testAccountPlanOpportunity.Account_Plan__c) +
            String.valueOf(testAccountPlanOpportunity.Opportunity__c);
        System.assertEquals(expectedValue, uniqueKey);
    }

    @isTest
    static void onValidateInsertTest() {
        // Given
        Account_Plan__c testAccountPlan = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN_NAME];
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name = :FIRST_OPPORTUNITY_NAME];

        Account_Plan_Opportunity__c duplicateObjectiveOpportunity = new Account_Plan_Opportunity__c(
            Account_Plan__c = testAccountPlan.Id,
            Opportunity__c = testOpportunity.Id
        );

        // When
        Test.startTest();

        AccountPlanOpportunities accountPlanOpportunityRecords = AccountPlanOpportunities.newInstance(
            new List<Account_Plan_Opportunity__c>{ duplicateObjectiveOpportunity }
        );
        accountPlanOpportunityRecords.onValidate();
        Database.saveResult saveResult = Database.insert(accountPlanOpportunityRecords.getRecords(), false)[0];

        Test.stopTest();

        // Then
        List<Database.Error> errors = saveResult.getErrors();

        System.assertEquals(false, saveResult.isSuccess());
        System.assertEquals(1, errors.size());
        System.assertEquals(System.Label.error_duplicate_account_plan_opportunity, errors[0].getMessage());
    }
}