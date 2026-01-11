@isTest
private class AccountPlanOpportunitySelectorTest {
    private static final String ACCOUNT_PLAN_NAME = 'Account Plan 1';
    private static final String OPPORTUNITY_NAME = 'Entire Roast';

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

            Opportunity testOpportunity = TestDataFactory.createOpportunity(testAccount, OPPORTUNITY_NAME);
            insert testOpportunity;

            Account_Plan_Opportunity__c testAccountPlanOpportunity = TestDataFactory.createAccountPlanOpportunity(
                testAccountPlan,
                testOpportunity
            );
            insert testAccountPlanOpportunity;
        }
    }

    @isTest
    static void selectByIdTest() {
        // Given
        Account_Plan__c testAccountPlan = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN_NAME];
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name = :OPPORTUNITY_NAME];
        Account_Plan_Opportunity__c testAccountPlanOpportunity = [
            SELECT Id, Account_Plan__c, Opportunity__c
            FROM Account_Plan_Opportunity__c
            WHERE Account_Plan__c = :testAccountPlan.Id AND Opportunity__c = :testOpportunity.Id
        ];

        // When
        Test.startTest();

        List<Account_Plan_Opportunity__c> retrievedAccountPlanOpportunities = AccountPlanOpportunitySelector.newInstance()
            .selectById(new Set<Id>{ testAccountPlanOpportunity.Id });

        Test.stopTest();

        // Then
        System.assertEquals(1, retrievedAccountPlanOpportunities.size());
        System.assertEquals(testAccountPlanOpportunity.Id, retrievedAccountPlanOpportunities.get(0).Id);
        System.assertEquals(
            testAccountPlanOpportunity.Account_Plan__c,
            retrievedAccountPlanOpportunities.get(0).Account_Plan__c
        );
        System.assertEquals(
            testAccountPlanOpportunity.Opportunity__c,
            retrievedAccountPlanOpportunities.get(0).Opportunity__c
        );
    }

    @isTest
    static void selectDuplicatesTest() {
        // Given
        Account_Plan__c testAccountPlan = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN_NAME];
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name = :OPPORTUNITY_NAME];
        Account_Plan_Opportunity__c testAccountPlanOpportunity = [
            SELECT Id, Account_Plan__c, Opportunity__c
            FROM Account_Plan_Opportunity__c
            WHERE Account_Plan__c = :testAccountPlan.Id AND Opportunity__c = :testOpportunity.Id
        ];

        Account_Plan_Opportunity__c duplicateAccountPlanOpportunity = new Account_Plan_Opportunity__c(
            Account_Plan__c = testAccountPlanOpportunity.Account_Plan__c,
            Opportunity__c = testAccountPlanOpportunity.Opportunity__c
        );

        // When
        Test.startTest();

        List<Account_Plan_Opportunity__c> duplicateAccountPlanOpportunities = AccountPlanOpportunitySelector.newInstance()
            .selectDuplicatesAsSystem(new List<Account_Plan_Opportunity__c>{ duplicateAccountPlanOpportunity });

        Test.stopTest();

        // Then
        System.assertEquals(1, duplicateAccountPlanOpportunities.size());
        System.assertEquals(duplicateAccountPlanOpportunity, duplicateAccountPlanOpportunities[0]);
    }
}