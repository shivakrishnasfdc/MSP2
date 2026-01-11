@isTest
private with sharing class RelationshipMapCloneControllerTest {
    /*** cloneRelationshipMap() tests ***/
    @isTest
    private static void cloneRelationshipMapNoMapIdTest() {
        TestMockData md = new TestMockData();
        RelationshipMapCloneServiceImpl cloneService = md.mockRelationshipMapCloneService;
        Id oldMapId = null;
        String newMapName = 'crmnmit_Test';
        Id newMapOwnerId = md.mockUserId;
        Id newRelatedObjectId = md.mockAccountId;
        List<Relationship_Map__c> result = RelationshipMapCloneController.cloneRelationshipMap(
            oldMapId,
            newMapName,
            newMapOwnerId,
            newRelatedObjectId
        );
        ((RelationshipMapCloneServiceImpl) md.mocks.verify(cloneService, 0))
            .cloneRelationshipMaps(
                (List<RelationshipMapCloneWrapper>) fflib_Match.anyList(),
                (List<SObject>) fflib_Match.isNull(),
                (Set<Schema.SObjectType>) fflib_Match.isNull(),
                fflib_Match.eqBoolean(true)
            );
        System.assertEquals(0, result.size(), 'Passing a null map Id should result in no maps being returned.');
    }

    @isTest
    private static void cloneRelationshipMapTest() {
        TestMockData md = new TestMockData();
        RelationshipMapCloneServiceImpl cloneService = md.mockRelationshipMapCloneService;
        Id oldMapId = md.mockRelationshipMapId;
        String newMapName = 'crmnmit_Test';
        Id newMapOwnerId = md.mockUserId;
        Id newRelatedObjectId = md.mockAccountId;

        RelationshipMapCloneWrapper expectedWrapper = new RelationshipMapCloneWrapper(
            oldMapId,
            newMapName,
            newMapOwnerId,
            newRelatedObjectId
        );
        List<RelationshipMapCloneWrapper> expectedWrapperList = new List<RelationshipMapCloneWrapper>{
            expectedWrapper
        };

        md.mocks.startStubbing();
        md.mocks.when(cloneService.cloneRelationshipMaps(expectedWrapperList, null, null, true))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.stopStubbing();

        List<Relationship_Map__c> result = RelationshipMapCloneController.cloneRelationshipMap(
            oldMapId,
            newMapName,
            newMapOwnerId,
            newRelatedObjectId
        );
        ((RelationshipMapCloneServiceImpl) md.mocks.verify(cloneService, 1))
            .cloneRelationshipMaps(expectedWrapperList, null, null, true);
        System.assertEquals(
            1,
            result.size(),
            'Should return one result since that\'s what we said the mock should return'
        );
        System.assertEquals(md.mockRelationshipMap, result[0], 'Should return the mock relationship map');
    }

    /*** getInputLookupTypeObjectsForRMRelationships() tests ***/

    @isTest
    private static void getInputLookupTypeObjectsForRMRelationshipsTest() {
        List<InputLookupTypeObject> result = RelationshipMapCloneController.getInputLookupTypeObjectsForRMRelationships();
        System.assertNotEquals(
            null,
            result,
            'Should return a list of InputLookupTypeObjects, but no way for the unit test to acurately determine which ones are returned.'
        );
    }
}