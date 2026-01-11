@isTest
private class OpportunityEIBatchServiceTest {
    @isTest
    static void processListTest() {
        TestMockData md = new TestMockData();
        OpportunityEIServiceImpl mockOpportunityEIService = md.mockOpportunityEIService;
        OpportunityContactRoleSelector mockOpportunityContactRoleSelector = md.mockOpportunityContactRoleSelector;
        OpportunityManagerSettingSelector mockOpportunityManagerSettingSelector = md.mockOpportunityManagerSettingSelector;

        List<OpportunityContactRole> ocrs = new List<OpportunityContactRole>();
        List<Opportunity> opps = new List<Opportunity>{ md.mockOpportunity };
        Date d = Date.today();

        Integer numberDaysToRoll = 22;
        pq_Opportunity_Manager_Setting__c setting = new pq_Opportunity_Manager_Setting__c(
            Days_of_Data_Used_In_Analysis__c = numberDaysToRoll
        );

        md.mocks.startStubbing();
        md.mocks.when(mockOpportunityManagerSettingSelector.selectOne()).thenReturn(setting);
        md.mocks.when(mockOpportunityContactRoleSelector.selectByOpportunityIds(new Set<Id>{ md.mockOpportunityId })).thenReturn(ocrs);
        md.mocks.stopStubbing();

        OpportunityEIBatchService.processOpportunity(opps, d);

        ((OpportunityEIServiceImpl) md.mocks.verify(mockOpportunityEIService, 1))
            .processOpportunityForDate(opps, d);
        ((OpportunityEIServiceImpl) md.mocks.verify(mockOpportunityEIService, 1))
            .processRollingData(numberDaysToRoll);

        System.assert(true, 'Assert from mock verify');
    }
}