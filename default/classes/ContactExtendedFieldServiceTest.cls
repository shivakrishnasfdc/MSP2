@isTest
private class ContactExtendedFieldServiceTest {
    @isTest
    static void updateProfileImageDataUpdateTest() {
        testMockData md = new testMockData();
        ContactExtendedFieldSelector mockContactExtendedFieldSelector = md.mockContactExtendedFieldSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        md.mocks.startStubbing();
        md.mocks.when(mockContactExtendedFieldSelector.selectByContactId(new Set<Id>{ md.mockContactId }))
            .thenReturn(new List<Contact_Extended_Field__c>{ md.mockContactExtendedField });
        md.mocks.stopStubbing();

        ContactExtendedFieldService.updateProfileImageData(md.mockContactId, 'update');

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerDirty(fflib_Match.sObjectOfType(Contact_Extended_Field__c.SObjectType));

        System.assert(true, 'verified by mocks');
    }

    @isTest
    static void updateProfileImageDataNewTest() {
        testMockData md = new testMockData();
        ContactExtendedFieldSelector mockContactExtendedFieldSelector = md.mockContactExtendedFieldSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        md.mocks.startStubbing();
        md.mocks.when(mockContactExtendedFieldSelector.selectByContactId(new Set<Id>{ md.mockContactId }))
            .thenReturn(new List<Contact_Extended_Field__c>{});
        md.mocks.stopStubbing();

        ContactExtendedFieldService.updateProfileImageData(md.mockContactId, 'update');

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew(fflib_Match.sObjectOfType(Contact_Extended_Field__c.SObjectType));

        System.assert(true, 'verified by mocks');
    }
}