@isTest
private class OpportunityEIServiceTest {

    // Testing updating old item
    @isTest
    static void processListForDateTest() {

        // Given
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        OpportunityScoreServiceImpl mockOpportunityScoreService = md.mockOpportunityScoreService;
        OpportunityEffectivenessIndexSelector mockOpportunityEffectivenessIndexSelector = md.mockOpportunityEffectivenessIndexSelector;
        OpportunityEIAssociationSelector mockOpportunityEIAssociationSelector = md.mockOpportunityEIAssociationSelector;
        Date d = Date.today();

        OpportunityEffectivenessData oppEffData = new OpportunityEffectivenessData();

        pq_Opportunity_Effectiveness_Index__c indexItem = new pq_Opportunity_Effectiveness_Index__c(
            Date_of_Data__c = d,
            Serialized_Lost_Data__c = '{"Business User":27,"Decision Maker":10,"Influencer":32}',
            Serialized_Won_Data__c = '{"Decision Maker":43,"Influencer":36,"Business User":31}'
        );
        List<pq_Opportunity_Effectiveness_Index__c> oeiList = new List<pq_Opportunity_Effectiveness_Index__c>{ indexItem };

        List<pq_Opportunity_Effectiveness_Association__c> oppEAssocs = new List<pq_Opportunity_Effectiveness_Association__c>();

        List<Opportunity> opps = new List<Opportunity>{
            md.mockOpportunity
        };

        md.mocks.startStubbing();
        md.mocks.when(mockOpportunityEIAssociationSelector.selectByOpportunities(new Set<Id>{ md.mockOpportunityId }))
            .thenReturn(oppEAssocs);
        md.mocks.when(mockOpportunityScoreService.calculateOpportunityEfficiencyIndex(opps))
            .thenReturn(oppEffData);
        md.mocks.when(mockOpportunityEffectivenessIndexSelector.selectByDate(d))
            .thenReturn(oeiList);
        md.mocks.when(mockOpportunityScoreService.mergeData((OpportunityEffectivenessData)fflib_Match.anyObject(), (OpportunityEffectivenessData)fflib_Match.anyObject()))
            .thenReturn(oppEffData);
        md.mocks.stopStubbing();

        OpportunityEIService.processOpportunityForDate(opps, d);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty((pq_Opportunity_Effectiveness_Index__c)fflib_Match.anyObject());
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew((List<pq_Opportunity_Effectiveness_Association__c>)fflib_Match.anyList());
        System.assert(true, 'Test verified by mock assertion');
    }

    // Testing inserting new item
    @isTest
    static void processListForDateTest2() {

        // Given
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        OpportunityScoreServiceImpl mockOpportunityScoreService = md.mockOpportunityScoreService;
        OpportunityEffectivenessIndexSelector mockOpportunityEffectivenessIndexSelector = md.mockOpportunityEffectivenessIndexSelector;
        OpportunityEIAssociationSelector mockOpportunityEIAssociationSelector = md.mockOpportunityEIAssociationSelector;
        Date d = Date.today();

        OpportunityEffectivenessData oppEffData = new OpportunityEffectivenessData();

        List<pq_Opportunity_Effectiveness_Index__c> oeiList = new List<pq_Opportunity_Effectiveness_Index__c>();

        List<pq_Opportunity_Effectiveness_Association__c> oppEAssocs = new List<pq_Opportunity_Effectiveness_Association__c>();

        List<Opportunity> opps = new List<Opportunity>{
            md.mockOpportunity
        };

        md.mocks.startStubbing();
        md.mocks.when(mockOpportunityEIAssociationSelector.selectByOpportunities(new Set<Id>{ md.mockOpportunityId }))
            .thenReturn(oppEAssocs);
        md.mocks.when(mockOpportunityScoreService.calculateOpportunityEfficiencyIndex(opps))
            .thenReturn(oppEffData);
        md.mocks.when(mockOpportunityEffectivenessIndexSelector.selectByDate(d))
            .thenReturn(oeiList);
        md.mocks.when(mockOpportunityScoreService.mergeData((OpportunityEffectivenessData)fflib_Match.anyObject(), (OpportunityEffectivenessData)fflib_Match.anyObject()))
            .thenReturn(oppEffData);
        md.mocks.stopStubbing();

        OpportunityEIService.processOpportunityForDate(opps, d);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew((pq_Opportunity_Effectiveness_Index__c)fflib_Match.anyObject());
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew((List<pq_Opportunity_Effectiveness_Association__c>)fflib_Match.anyList());
        System.assert(true, 'Test verified by mock assertion');
    }

    // // Test when there are no associations 
    // @isTest
    // static void processRedosForListTest1() {
    //     TestMockData md = new TestMockData();
    //     fflib_ISObjectUnitOfWork mockUow = md.mockUow;
    //     OpportunityEIAssociationSelector mockOpportunityEIAssociationSelector = md.mockOpportunityEIAssociationSelector;


    //     // Input
    //     List<OpportunityContactRole> ocrs = new List<OpportunityContactRole>();
    //     List<pq_Opportunity_Effectiveness_Association__c> assocList = new List<pq_Opportunity_Effectiveness_Association__c>();

    //     md.mocks.startStubbing();
    //     md.mocks.when(mockOpportunityEIAssociationSelector.selectByOpportunities(new Set<Id>()))
    //         .thenReturn(assocList);
    //     md.mocks.stopStubbing();


    //     // Call Method
    //     OpportunityEIService.processRedosForList(ocrs);

    //     ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0)).registerDeleted(assocList);
    //     System.assert(true, 'Test verified by mock assertion');
    // }

    // // Test when there are some associations (remove them) new ones will be created for those
    // @isTest
    // static void processRedosForListTest2() {

    //     TestMockData md = new TestMockData();
    //     fflib_ISObjectUnitOfWork mockUow = md.mockUow;
    //     OpportunityScoreServiceImpl mockOpportunityScoreService = md.mockOpportunityScoreService;
    //     OpportunityEIAssociationSelector mockOpportunityEIAssociationSelector = md.mockOpportunityEIAssociationSelector;
    //     OpportunityEffectivenessIndexSelector mockOpportunityEffectivenessIndexSelector = md.mockOpportunityEffectivenessIndexSelector;
    //     OpportunityContactRoleSelector mockOpportunityContactRoleSelector = md.mockOpportunityContactRoleSelector;

    //     List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();

    //     Id oeiId = fflib_IDGenerator.generate(pq_Opportunity_Effectiveness_Index__c.SObjectType);
    //     Id oeiId2 = fflib_IDGenerator.generate(pq_Opportunity_Effectiveness_Index__c.SObjectType);
    //     Id oeiId3 = fflib_IDGenerator.generate(pq_Opportunity_Effectiveness_Index__c.SObjectType);

    //     Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
    //     Id oppId2 = fflib_IDGenerator.generate(Opportunity.SObjectType);
    //     Id oppId3 = fflib_IDGenerator.generate(Opportunity.SObjectType);

    //     Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);

    //     List<pq_Opportunity_Effectiveness_Association__c> assocList = new List<pq_Opportunity_Effectiveness_Association__c>();
    //     assocList.add(new pq_Opportunity_Effectiveness_Association__c(Opportunity__c = oppId, Opportunity_Effectiveness_Index__c = oeiId));

    //     List<pq_Opportunity_Effectiveness_Association__c> assocList2 = new List<pq_Opportunity_Effectiveness_Association__c>();
    //     assocList2.add(new pq_Opportunity_Effectiveness_Association__c(Opportunity__c = oppId2, Opportunity_Effectiveness_Index__c = oeiId2));
    //     assocList2.add(new pq_Opportunity_Effectiveness_Association__c(Opportunity__c = oppId3, Opportunity_Effectiveness_Index__c = oeiId3));

    //     //Id oeiId4 = fflib_IDGenerator.generate(pq_Opportunity_Effectiveness_Index__c.SObjectType);
    //     //Id oeiId5 = fflib_IDGenerator.generate(pq_Opportunity_Effectiveness_Index__c.SObjectType);
    //     List<pq_Opportunity_Effectiveness_Index__c> oppIndexes = new List<pq_Opportunity_Effectiveness_Index__c>();
    //     pq_Opportunity_Effectiveness_Index__c oppIndex1 = new pq_Opportunity_Effectiveness_Index__c(
    //         Id = oeiId2,
    //         Date_of_Data__c = Date.today(),
    //         Serialized_Won_Data__c = 'test1',
    //         Serialized_Lost_Data__c = 'test2'
    //     );

    //     pq_Opportunity_Effectiveness_Index__c oppIndex2 = new pq_Opportunity_Effectiveness_Index__c(
    //         Id = oeiId3,
    //         Date_of_Data__c = Date.today(),
    //         Serialized_Won_Data__c = 'test3',
    //         Serialized_Lost_Data__c = 'test4'
    //     );

    //     oppIndexes.add(oppIndex1);
    //     oppIndexes.add(oppIndex2);

        
    //     OpportunityContactRole ocr1 = new OpportunityContactRole(OpportunityId = oppId2, ContactId = contactId, Role = 'Business User');
    //     OpportunityContactRole ocr2 = new OpportunityContactRole(OpportunityId = oppId2, ContactId = contactId, Role = 'Decision Maker');
    //     //OpportunityContactRole ocr3 = new OpportunityContactRole(OpportunityId = oppId3, ContactId = contactId, Role = 'Evaluator');
    //     List<OpportunityContactRole> redoOcrs = new List<OpportunityContactRole>{ ocr1, ocr2 };

    //     OpportunityEffectivenessData indexData = new OpportunityEffectivenessData();
    //     indexData.wonMap = new Map<String, Decimal>();
    //     indexData.lostMap = new Map<String, Decimal>();
    //     indexData.wonMap.put('a', 10);
    //     indexData.wonMap.put('b', 7);
        
    //     //System.debug('debug: redoOrs:' + redoOcrs);

    //     md.mocks.startStubbing();
    //     md.mocks.when(mockOpportunityEIAssociationSelector.selectByOpportunities(new Set<Id>()))
    //         .thenReturn(assocList);
    //     md.mocks.when(mockOpportunityEIAssociationSelector.selectByOEI(new Set<Id>{ oeiId }))
    //         .thenReturn(assocList2);
    //     md.mocks.when(mockOpportunityEffectivenessIndexSelector.selectById(new Set<Id>{ oeiId }))
    //         .thenReturn(oppIndexes);
    //     md.mocks.when(mockOpportunityContactRoleSelector.selectByOpportunityIds(new Set<Id>{ oppId2, oppId3 }))
    //         .thenReturn(redoOcrs);
    //     md.mocks.when(mockOpportunityScoreService.calculateOpportunityEfficiencyIndex(redoOcrs))
    //         .thenReturn(indexData);
    //     md.mocks.stopStubbing();


    //     // Call Method
    //     OpportunityEIService.processRedosForList(ocrList);

    //     // Verify
    //     ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty((List<pq_Opportunity_Effectiveness_Index__c>) fflib_Match.anyList());
    //     System.assert(true, 'Test verified by mock assertion');
    // }

}