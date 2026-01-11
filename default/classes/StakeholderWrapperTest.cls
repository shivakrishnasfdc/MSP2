@IsTest
private class StakeholderWrapperTest {
    /************************************
     *** Initializer() ***
     ***********************************/

    @isTest
    public static void initializerTest() {
        TestMockData md = new TestMockData();

        StakeholderWrapper wrapper = new StakeholderWrapper(md.mockKeyStakeholder);

        System.assertNotEquals(null, wrapper, 'wrapper should exist');
        System.assertEquals(md.mockKeyStakeholder.Id, wrapper.id(), 'Id should match wrapped object');
        System.assertEquals(
            md.mockKeyStakeholder.pqcrush__Contact__c,
            wrapper.contactId(),
            'contactId should match wrapped object'
        );
        System.assertEquals(
            md.mockKeyStakeholder.pqcrush__ContactFirstName__c,
            wrapper.contactFirstName(),
            'contactFirstName should match wrapped object'
        );
        System.assertEquals(
            md.mockKeyStakeholder.pqcrush__ContactLastName__c,
            wrapper.contactLastName(),
            'contactLastName should match wrapped object'
        );
        System.assertEquals(
            md.mockKeyStakeholder.pqcrush__ReportsToId__c,
            wrapper.parentId(),
            'parentId should match wrapped object'
        );
        System.assertEquals(
            Key_Stakeholder__c.sObjectType.getDescribe().getName(),
            wrapper.objectName(),
            'objectName should match wrapped object'
        );
        System.assertEquals(
            md.mockKeyStakeholder.pqcrush__Influence__c,
            wrapper.influence(),
            'influence should match wrapped object'
        );
        System.assertEquals(
            md.mockKeyStakeholder.pqcrush__Support__c,
            wrapper.support(),
            'support should match wrapped object'
        );
        System.assertEquals(
            md.mockKeyStakeholder.pqcrush__Support__c,
            wrapper.get(Key_Stakeholder__c.pqcrush__Support__c.getDescribe().getName()),
            'get support should match wrapped object'
        );
    }
}