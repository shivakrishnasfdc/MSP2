@isTest
private class SWOTMatrixControllerTest {
    private static final String ACCOUNT_PLAN_NAME = 'Account Plan 1';

    @testSetup
    static void testSetup() {
        SWOTAnalysis.bypassEmailTrigger = true;
        AccountPlans.bypassEmailTrigger = true;

        Account a = new Account(Name = 'Account 1');
        insert a;

        Account_Plan__c ap = new Account_Plan__c(Name = ACCOUNT_PLAN_NAME, Account__c = a.Id);
        insert ap;

        Map<String, Schema.RecordTypeInfo> recordTypesByName = SWOT_Analysis__c.SObjectType.getDescribe()
            .getRecordTypeInfosByDeveloperName();
        Id strengthRTId = recordTypesByName.get('Strength').getRecordTypeId();
        Id weaknessRTId = recordTypesByName.get('Weakness').getRecordTypeId();
        Id opportunityRTId = recordTypesByName.get('Opportunity').getRecordTypeId();
        Id threatRTId = recordTypesByName.get('Threat').getRecordTypeId();

        SWOT_Analysis__c strength = new SWOT_Analysis__c(
            Name = 'Strength',
            Account_Plan__c = ap.Id,
            RecordTypeId = strengthRTId
        );
        SWOT_Analysis__c weakness = new SWOT_Analysis__c(
            Name = 'Weakness',
            Account_Plan__c = ap.Id,
            RecordTypeId = weaknessRTId
        );
        SWOT_Analysis__c opportunity = new SWOT_Analysis__c(
            Name = 'Opportunity',
            Account_Plan__c = ap.Id,
            RecordTypeId = opportunityRTId
        );
        SWOT_Analysis__c threat = new SWOT_Analysis__c(
            Name = 'Threat',
            Account_Plan__c = ap.Id,
            RecordTypeId = threatRTId
        );
        insert new List<SWOT_Analysis__c>{ strength, weakness, opportunity, threat };
    }

    @isTest
    static void getSWOTMatrixTest() {
        // Given
        Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN_NAME];

        // When
        SWOTMatrix matrix = SWOTMatrixController.getSWOTMatrix(accountPlan.Id);

        // Then
        System.assertNotEquals(null, matrix);
        System.assertNotEquals(null, matrix.items);
        System.assertEquals(4, matrix.items.size());
    }

    @isTest
    static void createItemTest() {
        SWOTAnalysis.bypassEmailTrigger = true;

        // Given
        Map<String, Schema.RecordTypeInfo> recordTypesByName = SWOT_Analysis__c.SObjectType.getDescribe()
            .getRecordTypeInfosByDeveloperName();
        Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN_NAME];

        // When
        SWOT_Analysis__c analysis = new SWOT_Analysis__c(
            Name = 'New Strength',
            Description_Rich_Text__c = 'super cool description',
            Account_Plan__c = accountPlan.Id,
            RecordTypeId = recordTypesByName.get('Strength').getRecordTypeId()
        );
        SWOT_Analysis__c result = SWOTMatrixController.createItem(analysis);

        // Then
        System.assertNotEquals(null, result.Id);
        System.assertEquals(analysis.Name, result.Name);
        System.assertEquals(analysis.Description_Rich_Text__c, result.Description_Rich_Text__c);
    }

    @isTest
    static void updateItemTest() {
        SWOTAnalysis.bypassEmailTrigger = true;

        // Given
        SWOT_Analysis__c analysis = [SELECT Id, Name, Description_Rich_Text__c FROM SWOT_Analysis__c LIMIT 1];

        // When
        analysis.Name = 'fantastic updated name';
        analysis.Description_Rich_Text__c = 'not the old, lame description';
        SWOT_Analysis__c result = SWOTMatrixController.updateItem(analysis);

        // Then
        System.assertEquals(analysis.Name, result.Name);
        System.assertEquals(analysis.Description_Rich_Text__c, result.Description_Rich_Text__c);
    }

    @isTest
    static void deleteItemTest() {
        // Given
        SWOT_Analysis__c analysis = [SELECT Id FROM SWOT_Analysis__c LIMIT 1];

        // When
        SWOTMatrixController.deleteItem(analysis);

        // Then
        List<SWOT_Analysis__c> queryResults = [SELECT Id FROM SWOT_Analysis__c WHERE Id = :analysis.Id];

        System.assertEquals(0, queryResults.size());
    }
}