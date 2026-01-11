@IsTest
private class StakeholderLeadWrapperTest {
    /************************************
     *** Initializer() ***
     ***********************************/

    @isTest
    public static void initializerTest() {
        TestMockData md = new TestMockData();

        StakeholderLeadWrapper wrapper = new StakeholderLeadWrapper(md.mockKeyStakeholderLead);

        System.assertNotEquals(null, wrapper, 'wrapper should exist');
        System.assertEquals(md.mockKeyStakeholderLead.Id, wrapper.id(), 'Id should match wrapped object');
        System.assertEquals(
            md.mockKeyStakeholderLead.pqcrush__Lead__c,
            wrapper.leadId(),
            'leadId should match wrapped object'
        );
        System.assertEquals(
            Key_Stakeholder_Lead__c.sObjectType.getDescribe().getName(),
            wrapper.objectName(),
            'objectName should match wrapped object'
        );
        System.assertEquals(
            md.mockKeyStakeholderLead.pqcrush__Lead__c,
            wrapper.get(Key_Stakeholder_Lead__c.pqcrush__Lead__c.getDescribe().getName()),
            'get should match wrapped object'
        );
    }
}