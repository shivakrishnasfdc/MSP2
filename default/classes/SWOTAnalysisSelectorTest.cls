@isTest
private class SWOTAnalysisSelectorTest {
    private static final String ACCOUNT_PLAN1_NAME = 'Account Plan 1';
    private static final String ACCOUNT_PLAN2_NAME = 'Account Plan 2';
    private static final String STRENGTH_NAME = 'Strength 1';
    private static final String WEAKNESS_NAME = 'Weakness 1';
    private static final String OPPORTUNITY_NAME = 'Opportunity 1';
    private static final String THREAT_NAME = 'Threat 1';

    @testSetup
    static void testSetup() {
        SWOTAnalysis.bypassEmailTrigger = true;
        AccountPlans.bypassEmailTrigger = true;

        Account a = new Account(Name = 'Account 1');
        insert a;

        Account_Plan__c ap1 = new Account_Plan__c(Name = ACCOUNT_PLAN1_NAME, Account__c = a.Id);
        Account_Plan__c ap2 = new Account_Plan__c(Name = ACCOUNT_PLAN2_NAME, Account__c = a.Id);
        insert new List<Account_Plan__c>{ ap1, ap2 };

        Map<String, Schema.RecordTypeInfo> recordTypesByName = SWOT_Analysis__c.SObjectType.getDescribe()
            .getRecordTypeInfosByDeveloperName();
        Id strengthRTId = recordTypesByName.get('Strength').getRecordTypeId();
        Id weaknessRTId = recordTypesByName.get('Weakness').getRecordTypeId();
        Id opportunityRTId = recordTypesByName.get('Opportunity').getRecordTypeId();
        Id threatRTId = recordTypesByName.get('Threat').getRecordTypeId();

        SWOT_Analysis__c strength = new SWOT_Analysis__c(
            Name = STRENGTH_NAME,
            Account_Plan__c = ap1.Id,
            RecordTypeId = strengthRTId
        );
        SWOT_Analysis__c weakness = new SWOT_Analysis__c(
            Name = WEAKNESS_NAME,
            Account_Plan__c = ap1.Id,
            RecordTypeId = weaknessRTId
        );
        SWOT_Analysis__c opportunity = new SWOT_Analysis__c(
            Name = OPPORTUNITY_NAME,
            Account_Plan__c = ap2.Id,
            RecordTypeId = opportunityRTId
        );
        SWOT_Analysis__c threat = new SWOT_Analysis__c(
            Name = THREAT_NAME,
            Account_Plan__c = ap2.Id,
            RecordTypeId = threatRTId
        );
        insert new List<SWOT_Analysis__c>{ strength, weakness, opportunity, threat };
    }

    @isTest
    static void selectByIdTest() {
        // Given
        SWOT_Analysis__c strength = [
            SELECT Id, Name, Description_Rich_Text__c
            FROM SWOT_Analysis__c
            WHERE Name = :STRENGTH_NAME
        ];

        // When
        List<SWOT_Analysis__c> queryResults = new SWOTAnalysisSelector().selectById(new Set<Id>{ strength.Id });

        // Then
        System.assertEquals(1, queryResults.size());
        System.assertEquals(strength.Id, queryResults[0].Id);
        System.assertEquals(strength.Name, queryResults[0].Name);
        System.assertEquals(strength.Description_Rich_Text__c, queryResults[0].Description_Rich_Text__c);
    }

    @isTest
    static void selectByAccountPlanIdTest() {
        // Given
        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
        Account_Plan__c accountPlan2 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME];

        // When
        SWOTAnalysisSelector selector = new SWOTAnalysisSelector();

        List<SWOT_Analysis__c> accountPlan1Items = selector.selectByAccountPlanId(accountPlan1.Id);
        List<SWOT_Analysis__c> accountPlan2Items = selector.selectByAccountPlanId(accountPlan2.Id);

        // Then
        System.assertEquals(2, accountPlan1Items.size());
        System.assertEquals(STRENGTH_NAME, accountPlan1Items[0].Name);
        System.assertEquals(WEAKNESS_NAME, accountPlan1Items[1].Name);

        System.assertEquals(2, accountPlan2Items.size());
        System.assertEquals(OPPORTUNITY_NAME, accountPlan2Items[0].Name);
        System.assertEquals(THREAT_NAME, accountPlan2Items[1].Name);
    }
}