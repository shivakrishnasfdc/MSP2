@isTest
private class SWOTMatrixTest {
    private static final String ACCOUNT_PLAN_NAME = 'Account Plan 1';

    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    @testSetup
    static void testSetup() {
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];

        Id systemUserId = UserInfo.getUserId();
        PermissionSetAssignment systemStrategyAdminPermissions = TestDataFactory.createPermissionSetAssignment(
            systemUserId,
            adminUserPermissionSet.Id
        );

        if (systemStrategyAdminPermissions != null) {
            insert systemStrategyAdminPermissions;
        }

        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(systemUser) {
            Account a = new Account(Name = 'Account 1');
            insert a;

            Account_Plan__c ap = new Account_Plan__c(Name = ACCOUNT_PLAN_NAME, Account__c = a.Id);
            insert ap;
        }

    }

    @isTest
    static void emptyConstructorTest() {
        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(systemUser) {
            // Given
            Map<String, Schema.RecordTypeInfo> recordTypesByName = SWOT_Analysis__c.SObjectType.getDescribe()
                .getRecordTypeInfosByDeveloperName();
            Id strengthRTId = recordTypesByName.get('Strength').getRecordTypeId();
            Id weaknessRTId = recordTypesByName.get('Weakness').getRecordTypeId();
            Id opportunityRTId = recordTypesByName.get('Opportunity').getRecordTypeId();
            Id threatRTId = recordTypesByName.get('Threat').getRecordTypeId();

            // When
            SWOTMatrix matrix = new SWOTMatrix();

            // Then
            System.assertNotEquals(null, matrix.items);
            System.assertEquals(0, matrix.items.size());
            System.assertEquals(true, matrix.canCreate);
            System.assertEquals(true, matrix.canUpdate);
            System.assertEquals(true, matrix.canDelete);
            System.assertEquals(strengthRTId, matrix.strengthRecordTypeId);
            System.assertEquals(weaknessRTId, matrix.weaknessRecordTypeId);
            System.assertEquals(opportunityRTId, matrix.opportunityRecordTypeId);
            System.assertEquals(threatRTId, matrix.threatRecordTypeId);
        }
    }

    @isTest
    static void listConstructorTest() {
        // Given
        Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN_NAME];

        List<SWOT_Analysis__c> items = new List<SWOT_Analysis__c>{
            new SWOT_Analysis__c(Name = 'test 1', Account_Plan__c = accountPlan.Id)
        };

        // When
        SWOTMatrix matrix = new SWOTMatrix(items);

        // Then
        System.assertEquals(items, matrix.items);
    }
}