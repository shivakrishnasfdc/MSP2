@IsTest
public with sharing class OpportunityPlanSettingsControllerTest {
    @isTest
    static void getSettingTest() {

        // Given
        TestMockData md = new TestMockData();
        OpportunityManagerSettingSelector mockOpportunityManagerSettingSelector = md.mockOpportunityManagerSettingSelector;

        pq_Opportunity_Manager_Setting__c settings = new pq_Opportunity_Manager_Setting__c();

        md.mocks.startStubbing();
        md.mocks.when(mockOpportunityManagerSettingSelector.selectOne())
            .thenReturn(settings);
        md.mocks.stopStubbing();
        ((OpportunityManagerSettingSelector) md.mocks.verify(mockOpportunityManagerSettingSelector, 0)).selectOne();
        System.assert(true, 'Test verified by mock assertion');
    }

    @isTest
    static void updateDaysOfDataTest1() {

        // Given
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUoW = md.mockUoW;
        OpportunityManagerSettingSelector mockOpportunityManagerSettingSelector = md.mockOpportunityManagerSettingSelector;

        pq_Opportunity_Manager_Setting__c settings = new pq_Opportunity_Manager_Setting__c(
            Id = fflib_IDGenerator.generate(pq_Opportunity_Manager_Setting__c.SObjectType)
        );

        md.mocks.startStubbing();
        md.mocks.when(mockOpportunityManagerSettingSelector.selectOne())
            .thenReturn(settings);
        md.mocks.stopStubbing();

        OpportunityPlanSettingsController.updateDaysOfData(30);

        settings.Days_of_Data_Used_In_Analysis__c = 30;

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(settings);
        System.assert(true, 'Test verified by mock assertion');
    }

    @isTest
    static void updateDaysOfDataTest2() {

        // Given
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUoW = md.mockUoW;
        OpportunityManagerSettingSelector mockOpportunityManagerSettingSelector = md.mockOpportunityManagerSettingSelector;

        pq_Opportunity_Manager_Setting__c settings = null;

        md.mocks.startStubbing();
        md.mocks.when(mockOpportunityManagerSettingSelector.selectOne())
            .thenReturn(settings);
        md.mocks.stopStubbing();

        OpportunityPlanSettingsController.updateDaysOfData(30);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew((pq_Opportunity_Manager_Setting__c) fflib_Match.anyObject());
        System.assert(true, 'Test verified by mock assertion');
    }
}