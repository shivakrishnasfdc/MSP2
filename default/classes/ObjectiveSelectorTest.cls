@isTest
private class ObjectiveSelectorTest {
    private static final String ACCOUNT_PLAN_NAME = 'Account Plan 1';
    private static final String USER_LAST_NAME = 'Smith';
    private static final String OBJECTIVE_NAME = 'Objective 1';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User admin = TestDataFactory.createUser('user', USER_LAST_NAME, standardProfile.Id);

        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'CRUSH_Administrator'];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = admin.Id, PermissionSetId = adminUserPermissionSet.Id)
        };

        System.runAs(admin) {
            AccountPlans.bypassEmailTrigger = true;
            Objectives.bypassEmailTrigger = true;

            Account testAccount = new Account(Name = 'Account 1');
            insert testAccount;

            Account_Plan__c accountPlan = TestDataFactory.createAccountPlan(ACCOUNT_PLAN_NAME, testAccount);
            TestDataFactory.createObjective(accountPlan, OBJECTIVE_NAME, 'description');
        }
    }

    @isTest
    static void selectByIdTest() {
        // Given
        Objective__c testObjective = [
            SELECT Id, Account_Plan__c, Name, Description__c
            FROM Objective__c
            WHERE Name = :OBJECTIVE_NAME
        ];

        // When
        Test.startTest();

        List<Objective__c> retrievedObjectives = ObjectiveSelector.newInstance()
            .selectById(new Set<Id>{ testObjective.Id });

        Test.stopTest();

        // Then
        System.assertEquals(1, retrievedObjectives.size());
        System.assertEquals(testObjective.Id, retrievedObjectives.get(0).Id);
        System.assertEquals(testObjective.Account_Plan__c, retrievedObjectives.get(0).Account_Plan__c);
        System.assertEquals(testObjective.Name, retrievedObjectives.get(0).Name);
        System.assertEquals(testObjective.Description__c, retrievedObjectives.get(0).Description__c);
    }

    @isTest
    static void selectByAccountPlanIdTest() {
        // Given
        Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN_NAME];
        Objective__c testObjective = [
            SELECT Id, Name, Account_Plan__c, Description__c
            FROM Objective__c
            WHERE Account_Plan__c = :accountPlan.Id
        ];

        // When
        Test.startTest();

        List<Objective__c> retrievedObjectives = ObjectiveSelector.newInstance()
            .selectByAccountPlanId(new Set<Id>{ accountPlan.Id });

        Test.stopTest();

        // Then
        System.assertEquals(1, retrievedObjectives.size());
        System.assertEquals(testObjective.Id, retrievedObjectives.get(0).Id);
        System.assertEquals(testObjective.Account_Plan__c, retrievedObjectives.get(0).Account_Plan__c);
        System.assertEquals(testObjective.Name, retrievedObjectives.get(0).Name);
        System.assertEquals(testObjective.Description__c, retrievedObjectives.get(0).Description__c);
    }
}