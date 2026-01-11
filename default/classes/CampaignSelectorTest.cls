@isTest
private class CampaignSelectorTest {
    @isTest
    static void newInstanceTest() {
        CampaignSelector selector = CampaignSelector.newInstance();
        System.assertNotEquals(null, selector);
    }
}