@isTest
private class StaticResourcesSelectorTest {
    @isTest
    static void selectByIdTest() {
        // Given
        Set<Id> givenStaticResourceIds = new Map<Id, StaticResource>(
                [SELECT Id FROM StaticResource WHERE Name IN ('gojs', 'lodash')]
            )
            .keySet();

        // When
        Test.startTest();

        List<StaticResource> resources = StaticResourcesSelector.newInstance().selectById(givenStaticResourceIds);

        Test.stopTest();

        // Then
        System.assertEquals(2, resources.size(), 'Expected 2 Static Resource records.');
    }

    @isTest
    static void selectByNameTest() {
        // Given
        Set<String> names = new Set<String>{ 'gojs', 'lodash' };

        // When
        Test.startTest();

        List<StaticResource> resources = StaticResourcesSelector.newInstance().selectByName(names);

        Test.stopTest();

        // Then
        System.assertEquals(2, resources.size(), 'Expected 2 Static Resource records.');
    }
}