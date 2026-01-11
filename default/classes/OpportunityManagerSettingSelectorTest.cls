@isTest
public with sharing class OpportunityManagerSettingSelectorTest {
    @isTest
    static void newInstanceTest() {
        Test.startTest();
        OpportunityManagerSettingSelector result = OpportunityManagerSettingSelector.newInstance();
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(
            pq_Opportunity_Manager_Setting__c.SObjectType,
            result.getSObjectType(),
            'Result should be of type pq_Opportunity_Manager_Setting__c'
        );
    }

    @isTest
    static void selectOneTest() {

        pq_Opportunity_Manager_Setting__c newSetting = new pq_Opportunity_Manager_Setting__c(
            Days_of_Data_Used_In_Analysis__c = 45
        );
        insert newSetting;

        pq_Opportunity_Manager_Setting__c result = OpportunityManagerSettingSelector.newInstance().selectOne();


        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(
            45,
            result.Days_of_Data_Used_In_Analysis__c,
            'Result should match object data'
        );
    }
}