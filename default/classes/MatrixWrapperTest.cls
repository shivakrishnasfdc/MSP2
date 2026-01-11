@isTest
private class MatrixWrapperTest {
    @isTest
    static void initializeTest() {

        pq_Influence_And_Support_Matrix__c ism = new pq_Influence_And_Support_Matrix__c();
        ism.Name = 'Test Matrix For crmmt';
        ism.Is_Default__c = false;
        insert ism;

        InfluenceWrapper iw1 = new InfluenceWrapper('test1');
        InfluenceWrapper iw2 = new InfluenceWrapper('test2');

        List<InfluenceWrapper> influenceList = new List<InfluenceWrapper>{ iw1, iw2 };

        SupportWrapper sw1 = new SupportWrapper('test1');
        SupportWrapper sw2 = new SupportWrapper('test2');

        List<SupportWrapper> supportList = new List<SupportWrapper>{ sw1, sw2 };

        MatrixWrapper result = new MatrixWrapper(ism, influenceList, supportList);
        System.assertEquals(ism.Id, result.id);
        System.assertEquals(iw1.value, result.influenceList[0].value);
        System.assertEquals(iw2.value, result.influenceList[1].value);
        System.assertEquals(sw1.value, result.supportList[0].value);
        System.assertEquals(sw2.value, result.supportList[1].value);
    }

}