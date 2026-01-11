@isTest
private class OpportunityScoreHelperServiceTest {
    @isTest
    static void getMapOppsContactRoleTest() {

        // Given
        TestMockData md = new TestMockData();
        OpportunityContactRoleSelector mockOpportunityContactRoleSelector = md.mockOpportunityContactRoleSelector;

        Contact c1 = TestDataFactory.createContact('John1', 'Smith');
        Contact c2 = TestDataFactory.createContact('John2', 'Smith');
        Contact c3 = TestDataFactory.createContact('John3', 'Smith');
        Contact c4 = TestDataFactory.createContact('John4', 'Smith');
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

        Set<Id> ocrs1 = new Set<Id>{ ocr1.Id, ocr2.Id, ocr3.Id, ocr4.Id };

        md.mocks.startStubbing();
        md.mocks.when(mockOpportunityContactRoleSelector.selectByOpportunityIds(new Set<Id>{ md.mockOpportunityId }))
            .thenReturn(ocrList);
        md.mocks.stopStubbing();


        Map<Id, List<OpportunityContactRole>> result = OpportunityScoreHelperService.getMapOppsContactRole(new Set<Id>{ md.mockOpportunityId });
        System.assertNotEquals(null, result);
        System.assertEquals(5, result.keySet().size());
        for (Id oppId : result.keySet()) {
            if (oppId == opp1.Id) {
                List<OpportunityContactRole> ocrs = result.get(oppId);
                System.assertEquals(4, ocrs.size());

                for (OpportunityContactRole ocr : ocrs) {
                    System.assert(ocrs1.contains(ocr.Id));
                }

            }
        }
    }


    @isTest
    static void calculateOpportunityScoreDataTest() {

        // Given
        Contact c1 = TestDataFactory.createContact('John1', 'Smith');
        Contact c2 = TestDataFactory.createContact('John2', 'Smith');
        Contact c3 = TestDataFactory.createContact('John3', 'Smith');
        Contact c4 = TestDataFactory.createContact('John4', 'Smith');
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
        
        OpportunityContactRole ocr14 = new OpportunityContactRole(OpportunityId = opp6.Id, ContactId = c7.Id, Role = 'Decision Maker');
        OpportunityContactRole ocr15 = new OpportunityContactRole(OpportunityId = opp6.Id, ContactId = c8.Id, Role = 'Evaluator');

        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>{ ocr1, ocr2, ocr3, ocr4, ocr5, ocr6, ocr7, ocr8, ocr9, ocr10, ocr14, ocr15 };

        insert ocrList;

        List<OpportunityContactRole> ocrListForOpp1 = new List<OpportunityContactRole>{ ocr1, ocr2, ocr3, ocr4 };
        List<OpportunityContactRole> ocrListForOpp2 = new List<OpportunityContactRole>{ ocr5, ocr6, ocr7 };
        List<OpportunityContactRole> ocrListForOpp3 = new List<OpportunityContactRole>{ ocr8, ocr9 };
        List<OpportunityContactRole> ocrListForOpp4 = new List<OpportunityContactRole>{ ocr10 };
        List<OpportunityContactRole> ocrListForOpp5 = new List<OpportunityContactRole>();
        
        OpportunityEffectivenessData oeData = new OpportunityEffectivenessData();
        oeData.lostmap = new Map<String, Decimal>();
        oeData.wonmap = new Map<String, Decimal>();
        oeData.totalLost = 0;
        oeData.totalWon = 0;

        oeData.lostMap = new Map<String, Decimal>();
        oeData.lostMap.put('Decision Maker', 5);
        oeData.lostMap.put('Evaluator', 15);
        oeData.lostMap.put('Influencer', 10);
        oeData.lostMap.put('Business User', 20);

        oeData.wonMap =  new Map<String, Decimal>();
        oeData.wonMap.put('Decision Maker', 30);
        oeData.wonMap.put('Evaluator', 15);
        oeData.wonMap.put('Influencer', 20);
        oeData.wonMap.put('Business User', 25);

        oeData.totalLost = 80;
        oeData.totalWon = 40;
        oeData.wonWithContact = 20;
        oeData.lostWithContact = 5;

        OpportunityScoreData result1 = OpportunityScoreHelperService.calculateOpportunityScoreData(ocrListForOpp1, oeData);
        System.assertNotEquals(null, result1);
        System.assertEquals(0, result1.dataList.size());

        OpportunityScoreData result2 = OpportunityScoreHelperService.calculateOpportunityScoreData(ocrListForOpp2, oeData);
        System.assertNotEquals(null, result2);
        System.assertEquals(1, result2.dataList.size());

        OpportunityScoreData result3 = OpportunityScoreHelperService.calculateOpportunityScoreData(ocrListForOpp3, oeData);
        System.assertNotEquals(null, result3);
        System.assertEquals(3, result3.dataList.size());

        OpportunityScoreData result4 = OpportunityScoreHelperService.calculateOpportunityScoreData(ocrListForOpp4, oeData);
        System.assertNotEquals(null, result4);
        System.assertEquals(3, result4.dataList.size());

        OpportunityScoreData result5 = OpportunityScoreHelperService.calculateOpportunityScoreData(ocrListForOpp5, oeData);
        System.assertNotEquals(null, result5);
        System.assertEquals(4, result5.dataList.size());
        System.assert(result5.withOpportunityContact > 0);
    }
    
}