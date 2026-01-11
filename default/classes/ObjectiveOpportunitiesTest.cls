@isTest
private class ObjectiveOpportunitiesTest {
    private static final String ACCOUNT_PLAN_NAME = 'Account Plan 1';
    private static final String OBJECTIVE_NAME = 'Sonic';
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
            ObjectiveOpportunities.bypassEmailTrigger = true;
            AccountPlans.bypassEmailTrigger = true;
            Objectives.bypassEmailTrigger = true;

            Account testAccount = new Account(Name = 'Account 1');
            insert testAccount;

            Account_Plan__c accountPlan = TestDataFactory.createAccountPlan(ACCOUNT_PLAN_NAME, testAccount);
            Objective__c testObjective = TestDataFactory.createObjective(accountPlan, OBJECTIVE_NAME);

            Opportunity testOpportunity1 = TestDataFactory.createOpportunity(testAccount, FIRST_OPPORTUNITY_NAME);
            Opportunity testOpportunity2 = TestDataFactory.createOpportunity(testAccount, SECOND_OPPORTUNITY_NAME);
            insert new List<Opportunity>{ testOpportunity1, testOpportunity2 };

            Objective_Opportunity__c testObjectiveOpportunity1 = TestDataFactory.createObjectiveOpportunity(
                testObjective,
                testOpportunity1
            );
            Objective_Opportunity__c testObjectiveOpportunity2 = TestDataFactory.createObjectiveOpportunity(
                testObjective,
                testOpportunity2
            );
            insert new List<Objective_Opportunity__c>{ testObjectiveOpportunity1, testObjectiveOpportunity2 };
        }
    }

    @isTest
    static void constructorTest() {
        System.assertNotEquals(null, new ObjectiveOpportunities(new List<Objective_Opportunity__c>()));
        System.assertEquals(
            false,
            new ObjectiveOpportunities(new List<Objective_Opportunity__c>()).Configuration.EnforcingTriggerCRUDSecurity,
            'Should not be enforcing Trigger CRUD Security due to complications with automation in customer orgs'
        );
    }

    @isTest
    static void getUniqueKeyTest() {
        // Given
        Objective_Opportunity__c testObjectiveOpportunity = [
            SELECT Id, Objective__c, Opportunity__c
            FROM Objective_Opportunity__c
        ][0];

        // When
        Test.startTest();

        String uniqueKey = ObjectiveOpportunities.getUniqueKey(testObjectiveOpportunity);

        Test.stopTest();

        // Then
        String expectedValue =
            String.valueOf(testObjectiveOpportunity.Objective__c) +
            String.valueOf(testObjectiveOpportunity.Opportunity__c);
        System.assertEquals(expectedValue, uniqueKey);
    }

    @isTest
    static void onValidateInsertTest() {
        // Given
        Objective__c testObjective = [SELECT Id FROM Objective__c WHERE Name = :OBJECTIVE_NAME];
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name = :FIRST_OPPORTUNITY_NAME];

        Objective_Opportunity__c duplicateObjectiveOpportunity = new Objective_Opportunity__c(
            Objective__c = testObjective.Id,
            Opportunity__c = testOpportunity.Id
        );

        // When
        Test.startTest();

        ObjectiveOpportunities.bypassEmailTrigger = true;

        ObjectiveOpportunities objectiveOpportunityRecords = ObjectiveOpportunities.newInstance(
            new List<Objective_Opportunity__c>{ duplicateObjectiveOpportunity }
        );
        objectiveOpportunityRecords.onValidate();
        Database.saveResult saveResult = Database.insert(objectiveOpportunityRecords.getRecords(), false)[0];

        Test.stopTest();

        // Then
        List<Database.Error> errors = saveResult.getErrors();

        System.assertEquals(false, saveResult.isSuccess());
        System.assertEquals(1, errors.size());
        System.assertEquals(System.Label.error_duplicate_objective_opportunity, errors[0].getMessage());
    }
}