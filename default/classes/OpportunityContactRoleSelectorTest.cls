@isTest
private class OpportunityContactRoleSelectorTest {
    @isTest
    static void newInstanceTest() {
        OpportunityContactRoleSelector selector = OpportunityContactRoleSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByContactIdTest() {
        String oppName = 'opp Name';
        Contact c = TestDataFactory.createContact('john', 'smith');
        Opportunity op = TestDataFactory.createOpportunity(oppName);
        insert op;
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = op.Id, ContactId = c.Id);
        insert ocr;

        List<OpportunityContactRole> result = OpportunityContactRoleSelector.newInstance()
            .selectByContactId(new Set<Id>{ c.Id });
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(oppName, result[0].Opportunity.Name);
    }

    @isTest
    static void selectByOpportunityIdsNullTest() {
        List<OpportunityContactRole> result = OpportunityContactRoleSelector.newInstance().selectByOpportunityIds(null);
        System.assertEquals(0, result.size(), 'Should return empty list when null is passed');
    }

    @isTest
    static void selectByOpportunityIdsEmptyTest() {
        List<OpportunityContactRole> result = OpportunityContactRoleSelector.newInstance()
            .selectByOpportunityIds(new Set<Id>());
        System.assertEquals(0, result.size(), 'Should return empty list when empty set is passed');
    }

    @isTest
    static void selectByOpportunityIdsTest() {
        String oppName = 'opp Name';
        Contact c1 = TestDataFactory.createContact('john', 'smith');
        Contact c2 = TestDataFactory.createContact('jane', 'doe');
        Opportunity op1 = TestDataFactory.createOpportunity(oppName);
        Opportunity op2 = TestDataFactory.createOpportunity(oppName);
        insert new List<SObject>{ op1, op2 };
        OpportunityContactRole ocr11 = new OpportunityContactRole(OpportunityId = op1.Id, ContactId = c1.Id);
        OpportunityContactRole ocr12 = new OpportunityContactRole(OpportunityId = op1.Id, ContactId = c2.Id);
        OpportunityContactRole ocr21 = new OpportunityContactRole(OpportunityId = op2.Id, ContactId = c1.Id);
        insert new List<SObject>{ ocr11, ocr12, ocr21 };

        List<OpportunityContactRole> result = OpportunityContactRoleSelector.newInstance()
            .selectByOpportunityIds(new Set<Id>{ op1.Id });
        System.assertNotEquals(null, result, 'Should not return null when valid set is passed that has OCRs');
        System.assertEquals(2, result.size(), 'Should return 2 OCRs for op1');
        Set<Id> expectedOCRs = new Set<Id>{ ocr11.Id, ocr12.Id };
        Set<Id> actualOCRs = new Map<Id, OpportunityContactRole>(result).keySet();
        System.assertEquals(expectedOCRs, actualOCRs, 'OCRs returned should be the expected ones for op1');
    }


    @isTest
    static void selectByClosedOpportunitiesSinceTest() {

        DateTime dt = DateTime.now();
        dt = dt.addDays(-1);

        String oppName1 = 'opp Name';
        String oppName2 = 'opp Name 2';
        String oppName3 = 'opp Name 3';
        Contact c1 = TestDataFactory.createContact('john', 'smith');
        Contact c2 = TestDataFactory.createContact('jane', 'doe');
        Opportunity op1 = TestDataFactory.createOpportunity(oppName1);
        Opportunity op2 = TestDataFactory.createOpportunity(oppName2);
        Opportunity op3 = TestDataFactory.createOpportunity(oppName3);
        op1.StageName = 'Closed Won';
        op2.StageName = 'Closed Lost';
        insert op1;
        insert op2;
        insert op3; 
    
        OpportunityContactRole ocr11 = new OpportunityContactRole(OpportunityId = op1.Id, ContactId = c1.Id);
        OpportunityContactRole ocr12 = new OpportunityContactRole(OpportunityId = op1.Id, ContactId = c2.Id);
        OpportunityContactRole ocr21 = new OpportunityContactRole(OpportunityId = op2.Id, ContactId = c1.Id);
        OpportunityContactRole ocr31 = new OpportunityContactRole(OpportunityId = op3.Id, ContactId = c1.Id);

        insert ocr11;
        insert ocr12;
        insert ocr21;
        insert ocr31;

        List<OpportunityContactRole> result = OpportunityContactRoleSelector.newInstance()
            .selectByClosedOpportunitiesSince(dt);

        System.assertNotEquals(null, result, 'Should not return null when valid set is passed that has OCRs');
        System.assertEquals(3, result.size(), 'Should return 3 OCRs for op1 & op2');
        Set<Id> expectedOCRs = new Set<Id>{ ocr11.Id, ocr12.Id, ocr21.Id };
        Set<Id> actualOCRs = new Map<Id, OpportunityContactRole>(result).keySet();
        System.assertEquals(expectedOCRs, actualOCRs, 'OCRs returned should be the expected ones for op1 & op2');
    }
}