@isTest
private class StaticResourceServiceTest {
    public static final String ADMIN_USER_FIRST_NAME = 'Apple';
    public static final String ADMIN_USER_LAST_NAME = 'Create';

    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User adminUser = TestDataFactory.createUser(ADMIN_USER_FIRST_NAME, ADMIN_USER_LAST_NAME, standardProfile.Id);
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR LIMIT 1];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = adminUserPermissionSet.Id)
        };
    }

    @isTest
    static void getResourceUrlsForResourceNamesTest() {
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        System.runAs(adminUser) {
            // Create mocks
            fflib_ApexMocks mocks = new fflib_ApexMocks();
            StaticResourcesSelector mockSelector = (StaticResourcesSelector) FFLibHelper.mockSelector(
                StaticResourcesSelector.class,
                mocks
            );
            Application.Selector.setMock(mockSelector);

            // Given
            Set<String> resourceNames = new Set<String>{ 'sample1', 'sample2' };
            Set<String> overrideResourceNames = new Set<String>{ 'pqcrush__sample1', 'pqcrush__sample2' };

            mocks.startStubbing();
            mocks.when(mockSelector.selectByName(resourceNames))
                .thenReturn(
                    new List<StaticResource>{
                        new StaticResource(Name = 'sample1'),
                        new StaticResource(Name = 'sample2')
                    }
                );
            mocks.when(mockSelector.selectByName(overrideResourceNames)).thenReturn(new List<StaticResource>());
            mocks.stopStubbing();

            Map<String, String> result = StaticResourceService.getResourceUrlsForResourceNames(resourceNames);

            // Then
            ((StaticResourcesSelector) mocks.verify(mockSelector, 1)).selectByName(overrideResourceNames);
            System.assertEquals(2, result.size());
            System.assert(result.get('sample1').length() > 0);
            System.assert(result.get('sample2').length() > 0);
        }
    }
}