@isTest
private class OpportunityContactWrapperTest {
    @isTest
    static void instanceTest() {
        Id ocrId = fflib_IDGenerator.generate(OpportunityContactRole.SObjectType);
        Id oId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        String name = 'me';
        Decimal amount = 299.99;
        String role = 'Other';
        Boolean isClosed = false;

        OpportunityContactWrapper wrapper = new OpportunityContactWrapper(ocrId, oId, name, amount, role, isClosed);

        System.assertEquals(ocrId, wrapper.id);
        System.assertEquals(oId, wrapper.opportunityId);
        System.assertEquals(name, wrapper.opportunityName);
        System.assertEquals(amount, wrapper.opportunityAmount);
        System.assertEquals(role, wrapper.contactRole);
        System.assertEquals(isClosed, wrapper.isClosed);
    }

    @isTest
    static void convertTest() {
        // Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        // User someUser = TestDataFactory.createUser('FirstName', 'LastName', standardProfile.Id);

        String oppName = 'opp Name';
        Contact c = TestDataFactory.createContact('john', 'smith');
        Opportunity op = TestDataFactory.createOpportunity(oppName);
        op.Amount = 299;
        insert op;
        OpportunityContactRole ocr = new OpportunityContactRole(
            OpportunityId = op.Id,
            ContactId = c.Id,
            Role = 'Other'
        );
        insert ocr;

        OpportunityContactRole queryOcr = [
            SELECT Id, Opportunity.Id, Opportunity.Name, Opportunity.Amount, Role, Opportunity.IsClosed
            FROM OpportunityContactRole
            WHERE Id = :ocr.Id
        ];

        List<OpportunityContactWrapper> result = OpportunityContactWrapper.convert(
            new List<OpportunityContactRole>{ queryOcr }
        );
        System.assertEquals(1, result.size());
        System.assertEquals(queryOcr.Id, result[0].id);
        System.assertEquals(op.Id, result[0].opportunityId);
        System.assertEquals(oppName, result[0].opportunityName);
        System.assertEquals(299, result[0].opportunityAmount);
        System.assertEquals('Other', result[0].contactRole);
        System.assertEquals(false, result[0].isClosed);
    }

    @isTest
    static void convertNullTest() {
        List<OpportunityContactWrapper> result = OpportunityContactWrapper.convert(null);
        System.assertEquals(0, result.size());
    }
}