@IsTest
public with sharing class HealthScoreMetadataSelectorTest {
    @isTest
    static void newInstanceTest() {
        HealthScoreMetadataSelector selector = HealthScoreMetadataSelector.newInstance();
        System.assertNotEquals(null, selector);
        System.assertEquals(PQ_AP_Score__mdt.sObjectType, selector.getSObjectType());
    }

    // Null String test
    @isTest
    private static void selectEnabledTest() {
        List<PQ_AP_Score__mdt> expected = [SELECT Id FROM PQ_AP_Score__mdt WHERE Score_Object__c = TRUE];
        List<PQ_AP_Score__mdt> result = HealthScoreMetadataSelector.newInstance().selectEnabled();
        System.AssertEquals(expected.size(), result.size(), 'Should return expected number of results');
    }
}