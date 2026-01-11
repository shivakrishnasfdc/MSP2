@isTest
private class SupportWrapperTest {
    @isTest
    static void initializeTest() {

        pq_Support__c s1 = new pq_Support__c(Name = 'Low', Color__c = '#122123', Label__c = 'lowlabel');
        insert s1;

        SupportWrapper sw1 = new SupportWrapper('test1');
        SupportWrapper sw2 = new SupportWrapper(s1);
        System.assertEquals('test1', sw1.value);
        System.assertEquals(s1.Label__c, sw2.value);
        System.assertEquals(s1.Color__c, sw2.color);
    }

}