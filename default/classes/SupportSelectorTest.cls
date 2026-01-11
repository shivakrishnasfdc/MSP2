@isTest
private class SupportSelectorTest {
    @isTest
    static void newInstanceTest() {
        SupportSelector selector = SupportSelector.newInstance();
        System.assertNotEquals(null, selector);
    }
}