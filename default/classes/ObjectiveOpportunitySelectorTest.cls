@isTest
private class ObjectiveOpportunitySelectorTest {
    private static final String ACCOUNT_PLAN_NAME = 'Account Plan 1';
    private static final String OBJECTIVE_NAME = 'Sonic';
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
            ObjectiveOpportunities.bypassEmailTrigger = true;

            Account testAccount = new Account(Name = 'Account 1');
            insert testAccount;

            Account_Plan__c testAccountPlan = TestDataFactory.createAccountPlan(ACCOUNT_PLAN_NAME, testAccount);
            Objective__c testObjective = TestDataFactory.createObjective(testAccountPlan, OBJECTIVE_NAME);

            Opportunity testOpportunity = TestDataFactory.createOpportunity(testAccount, OPPORTUNITY_NAME);
            insert testOpportunity;

            Objective_Opportunity__c testObjectiveOpportunity = TestDataFactory.createObjectiveOpportunity(
                testObjective,
                testOpportunity
            );
            insert testObjectiveOpportunity;
        }
    }

    @isTest
    static void selectByIdTest() {
        // Given
        Objective__c testObjective = [SELECT Id FROM Objective__c WHERE Name = :OBJECTIVE_NAME];
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name = :OPPORTUNITY_NAME];
        Objective_Opportunity__c testObjectiveOpportunity = [
            SELECT Id, Objective__c, Opportunity__c
            FROM Objective_Opportunity__c
            WHERE Objective__c = :testObjective.Id AND Opportunity__c = :testOpportunity.Id
        ];

        // When
        Test.startTest();

        List<Objective_Opportunity__c> retrievedObjectiveOpportunities = ObjectiveOpportunitySelector.newInstance()
            .selectById(new Set<Id>{ testObjectiveOpportunity.Id });

        Test.stopTest();

        // Then
        System.assertEquals(1, retrievedObjectiveOpportunities.size());
        System.assertEquals(testObjectiveOpportunity.Id, retrievedObjectiveOpportunities.get(0).Id);
        System.assertEquals(testObjectiveOpportunity.Objective__c, retrievedObjectiveOpportunities.get(0).Objective__c);
        System.assertEquals(
            testObjectiveOpportunity.Opportunity__c,
            retrievedObjectiveOpportunities.get(0).Opportunity__c
        );
    }

    @isTest
    static void selectDuplicatesTest() {
        // Given
        Objective__c testObjective = [SELECT Id FROM Objective__c WHERE Name = :OBJECTIVE_NAME];
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name = :OPPORTUNITY_NAME];
        Objective_Opportunity__c testObjectiveOpportunity = [
            SELECT Id, Objective__c, Opportunity__c
            FROM Objective_Opportunity__c
            WHERE Objective__c = :testObjective.Id AND Opportunity__c = :testOpportunity.Id
        ];

        Objective_Opportunity__c duplicateObjectiveOpportunity = new Objective_Opportunity__c(
            Objective__c = testObjectiveOpportunity.Objective__c,
            Opportunity__c = testObjectiveOpportunity.Opportunity__c
        );

        // When
        Test.startTest();

        List<Objective_Opportunity__c> duplicateObjectiveOpportunities = ObjectiveOpportunitySelector.newInstance()
            .selectDuplicatesAsSystem(new List<Objective_Opportunity__c>{ duplicateObjectiveOpportunity });

        Test.stopTest();

        // Then
        System.assertEquals(1, duplicateObjectiveOpportunities.size());
        System.assertEquals(duplicateObjectiveOpportunity, duplicateObjectiveOpportunities[0]);
    }
}