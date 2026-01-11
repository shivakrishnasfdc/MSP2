@isTest
private class InfluenceWrapperTest {
    @isTest
    static void initializeTest() {

        pq_Influence__c i1 = new pq_Influence__c(Name = 'Low', Label__c = 'lowlabel');
        insert i1;

        InfluenceWrapper iw1 = new InfluenceWrapper('test1');
        InfluenceWrapper iw2 = new InfluenceWrapper(i1);
        System.assertEquals('test1', iw1.value);
        System.assertEquals(i1.Label__c, iw2.value);
    }

}