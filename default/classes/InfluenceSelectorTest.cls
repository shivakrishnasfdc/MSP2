@isTest
private class InfluenceSelectorTest {
    @isTest
    static void newInstanceTest() {
        InfluenceSelector selector = InfluenceSelector.newInstance();
        System.assertNotEquals(null, selector);
    }
}