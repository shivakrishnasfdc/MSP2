@isTest
private class OpportunitySelectorTest {

    @isTest
    static void newInstanceTest() {
        OpportunitySelector selector = OpportunitySelector.newInstance();
        System.assertNotEquals(null, selector);
    }
}