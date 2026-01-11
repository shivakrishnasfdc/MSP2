@isTest
private class KeyStakeholderServiceTest {
    @IsTest
    static void addContactAsKeyStakeholderTest() {
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        KeyStakeholderService.addContactAsKeyStakeholder(md.mockAccountPlanId, new Set<Id>{ md.mockContactId });

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew((Key_Stakeholder__c) fflib_Match.anyObject());

        System.assert(true, 'Asserts from mock verify');
    }
}