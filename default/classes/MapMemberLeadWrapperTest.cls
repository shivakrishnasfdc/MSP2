@isTest
private class MapMemberLeadWrapperTest {
    /************************************
     *** Initializer() ***
     ***********************************/

    @isTest
    public static void initializerTest() {
        TestMockData md = new TestMockData();

        MapMemberLeadWrapper wrapper = new MapMemberLeadWrapper(md.mockMapMemberLead);

        System.assertNotEquals(null, wrapper, 'wrapper should exist');
        System.assertEquals(md.mockMapMemberLead.Id, wrapper.id(), 'Id should match wrapped object');
        System.assertEquals(
            md.mockMapMemberLead.pqcrush__Lead__c,
            wrapper.leadId(),
            'leadId should match wrapped object'
        );
        System.assertEquals(
            Map_Member_Lead__c.sObjectType.getDescribe().getName(),
            wrapper.objectName(),
            'objectName should match wrapped object'
        );
        System.assertEquals(
            md.mockMapMemberLead.pqcrush__Lead__c,
            wrapper.get(Map_Member_Lead__c.pqcrush__Lead__c.getDescribe().getName()),
            'get should match wrapped object'
        );
    }
}