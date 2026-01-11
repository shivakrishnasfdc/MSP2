public with sharing class OpportunityEIBatchServiceImpl {

    public void processOpportunity(List<Opportunity> opps, Date d) {
        
        OpportunityEIService.processOpportunityForDate(opps, d);

        pq_Opportunity_Manager_Setting__c setting = OpportunityManagerSettingSelector.newInstance().selectOne();
        Integer numberDaysToRoll = 30;
        if (setting != null && setting.Days_of_Data_Used_In_Analysis__c != null) {
            numberDaysToRoll = (Integer) setting.Days_of_Data_Used_In_Analysis__c;
        }

        OpportunityEIService.processRollingData(numberDaysToRoll);
    }
}