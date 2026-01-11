@isTest
private class OpportunityScoreServiceTest {

    @isTest
    static void calculateOpportunityEfficiencyIndexTestNull() {
        OpportunityEffectivenessData result = OpportunityScoreService.calculateOpportunityEfficiencyIndex(new List<Opportunity>());
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.lostMap);
        System.assertNotEquals(null, result.wonMap);
    }

    @isTest
    static void calculateOpportunityEfficiencyIndexTest() {

        Contact c1 = TestDataFactory.createContact('John1', 'Smith');
        Contact c2 = TestDataFactory.createContact('John2', 'Smith');
        Contact c3 = TestDataFactory.createContact('John3', 'Smith');
        Contact c4 = TestDataFactory.createContact('John4', 'Smith');
        // Contact c5 = TestDataFactory.createContact('John5', 'Smith');
        // Contact c6 = TestDataFactory.createContact('John6', 'Smith');
        Contact c7 = TestDataFactory.createContact('John7', 'Smith');
        Contact c8 = TestDataFactory.createContact('John8', 'Smith');

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1');
        opp1.StageName = 'Closed Won';
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2');
        opp2.StageName = 'Closed Won';
        Opportunity opp3 = TestDataFactory.createOpportunity('opp3');
        opp3.StageName = 'Closed Won';
        Opportunity opp4 = TestDataFactory.createOpportunity('opp4');
        opp4.StageName = 'Closed Lost';
        Opportunity opp5 = TestDataFactory.createOpportunity('opp5');
        opp5.StageName = 'Closed Lost';
        Opportunity opp6 = TestDataFactory.createOpportunity('opp6');
        opp6.StageName = 'Prospecting';

        insert opp1;
        insert opp2;
        insert opp3;
        insert opp4;
        insert opp5;
        insert opp6;

        List<Opportunity> opps = new List<Opportunity> { opp1, opp2, opp3, opp4, opp5, opp6 };


        OpportunityContactRole ocr1 = new OpportunityContactRole(OpportunityId = opp1.Id, ContactId = c1.Id, Role = 'Business User');
        OpportunityContactRole ocr2 = new OpportunityContactRole(OpportunityId = opp1.Id, ContactId = c2.Id, Role = 'Decision Maker');
        OpportunityContactRole ocr3 = new OpportunityContactRole(OpportunityId = opp1.Id, ContactId = c3.Id, Role = 'Evaluator');
        OpportunityContactRole ocr4 = new OpportunityContactRole(OpportunityId = opp1.Id, ContactId = c4.Id, Role = 'Influencer');

        OpportunityContactRole ocr5 = new OpportunityContactRole(OpportunityId = opp2.Id, ContactId = c2.Id, Role = 'Business User');
        OpportunityContactRole ocr6 = new OpportunityContactRole(OpportunityId = opp2.Id, ContactId = c3.Id, Role = 'Decision Maker');
        OpportunityContactRole ocr7 = new OpportunityContactRole(OpportunityId = opp2.Id, ContactId = c4.Id, Role = 'Influencer');

        OpportunityContactRole ocr8 = new OpportunityContactRole(OpportunityId = opp3.Id, ContactId = c2.Id, Role = 'Decision Maker');
        OpportunityContactRole ocr9 = new OpportunityContactRole(OpportunityId = opp3.Id, ContactId = c3.Id, Role = 'Technical Buyer');

        OpportunityContactRole ocr10 = new OpportunityContactRole(OpportunityId = opp4.Id, ContactId = c1.Id, Role = 'Business User');
        OpportunityContactRole ocr11 = new OpportunityContactRole(OpportunityId = opp4.Id, ContactId = c3.Id, Role = 'Influencer');
        
        OpportunityContactRole ocr14 = new OpportunityContactRole(OpportunityId = opp6.Id, ContactId = c7.Id, Role = 'Decision Maker');
        OpportunityContactRole ocr15 = new OpportunityContactRole(OpportunityId = opp6.Id, ContactId = c8.Id, Role = 'Evaluator');

        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>{ ocr1, ocr2, ocr3, ocr4, ocr5, ocr6, ocr7, ocr8, ocr9, ocr10, ocr11, ocr14, ocr15 };

        insert ocrList;

        //List<OpportunityContactRole> newOcrList = [SELECT Id, Role, OpportunityId, Opportunity.IsClosed, Opportunity.IsWon FROM OpportunityContactRole];


        // {"Won": {
        //     "Business User": 2,
        //     "Evaluator": 1,
        //     "Decision Maker": 3
        //     "Influencer": 2
        //     "Technical Buyer": 1
        // }}, 
        // {"Lost": {
        //     "Total" : 2,
        //     "HastContact": 1
        //     "Business User": 1,
        //     "Influencer": 1,
        // }}

        OpportunityEffectivenessData result = OpportunityScoreService.calculateOpportunityEfficiencyIndex(opps);

        Map<String, Decimal> wonMap = result.wonMap;
        Map<String, Decimal> lostMap = result.lostMap;

        System.assertEquals(5, wonMap.size());
        System.assertEquals(2, lostMap.size());
        System.assertEquals(2, wonMap.get('Business User'));
        System.assertEquals(1, wonMap.get('Evaluator'));
        System.assertEquals(3, wonMap.get('Decision Maker'));
        System.assertEquals(2, wonMap.get('Influencer'));
        System.assertEquals(1, wonMap.get('Technical Buyer'));
        System.assertEquals(1, lostMap.get('Business User'));
        System.assertEquals(1, lostMap.get('Influencer'));
    }

    @isTest
    static void mergeDataTest() {

        OpportunityEffectivenessData newData = new OpportunityEffectivenessData();
        newData.totalLost = 1;
        newData.totalWon = 2;
        newData.wonWithContact = 3;
        newData.lostWithContact = 4;
        OpportunityEffectivenessData oldData = new OpportunityEffectivenessData();
        oldData.totalLost = 11;
        oldData.totalWon = 12;
        oldData.wonWithContact = 13;
        oldData.lostWithContact = 14;

        OpportunityEffectivenessData result = OpportunityScoreService.mergeData(newData, oldData);
        System.assertNotEquals(null, result);
        System.assertEquals(12, result.totalLost);
        System.assertEquals(14, result.totalWon);
        System.assertEquals(16, result.wonWithContact);
        System.assertEquals(18, result.lostWithContact);
    }

    @isTest
    static void calculateOpportunityScoreTest() {

        // Given
        TestMockData md = new TestMockData();
        OpportunityEffectivenessIndexSelector mockOpportunityEffectivenessIndexSelector = md.mockOpportunityEffectivenessIndexSelector;
        OpportunityScoreHelperServiceImpl mockOpportunityScoreHelperService = md.mockOpportunityScoreHelperService;

        pq_Opportunity_Effectiveness_Index__c oeiData = new pq_Opportunity_Effectiveness_Index__c();
        Map<Id, List<OpportunityContactRole>> oppXcontactRoles = new Map<Id, List<OpportunityContactRole>>();
        
        List<OpportunityContactRole> ocrForPlan = new List<OpportunityContactRole>();
        oppXcontactRoles.put(md.mockOpportunityId, ocrForPlan);

        md.mocks.startStubbing();
        md.mocks.when(mockOpportunityScoreHelperService.getMapOppsContactRole(new Set<Id>{ md.mockOpportunityId }))
            .thenReturn(oppXcontactRoles);
        md.mocks.when(mockOpportunityEffectivenessIndexSelector.selectOne())
        .thenReturn(oeiData);
        md.mocks.stopStubbing();

        Map<Id, OpportunityScoreData> result = OpportunityScoreService.calculateOpportunityScore(new Set<Id>{ md.mockOpportunityId });
        System.assertNotEquals(null, result);
        ((OpportunityScoreHelperServiceImpl) md.mocks.verify(mockOpportunityScoreHelperService, 1))
            .calculateOpportunityScoreData((List<OpportunityContactRole>)fflib_Match.anyList(), (OpportunityEffectivenessData)fflib_Match.anyObject());

    }

}