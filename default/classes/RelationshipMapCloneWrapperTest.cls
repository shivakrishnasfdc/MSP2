@isTest
private with sharing class RelationshipMapCloneWrapperTest {
    @isTest
    private static void initializationTest() {
        RelationshipMapCloneWrapper basic = new RelationshipMapCloneWrapper();
        System.assertNotEquals(null, basic, 'A wrapper was successfully created');

        Id mapId = fflib_IDGenerator.generate(Relationship_Map__c.SObjectType);
        String name = 'The Map Name';
        Id ownerId = fflib_IDGenerator.generate(User.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        RelationshipMapCloneWrapper full = new RelationshipMapCloneWrapper(mapId, name, ownerId, accountId);
        System.assertNotEquals(null, full, 'A detailed wrapper was successfully created');
        System.assertEquals(mapId, full.mapId, 'The map Id was assigned');
        System.assertEquals(name, full.newName, 'The new name was assigned');
        System.assertEquals(ownerId, full.newOwnerId, 'The new owner was assigned');
        System.assertEquals(accountId, full.newRelatedObjId, 'The new related object Id was assigned');

        List<String> expectedRelationsips = new List<String>{
            RelationshipMapCloneService.MAP_MEMBER_RELATIONSHIP_NAME,
            RelationshipMapCloneService.MAP_MEMBER_LEADS_RELATIONSHIP_NAME,
            RelationshipMapCloneService.CUSTOM_RELATIONSHIP_LINE_RELATIONSHIP_NAME,
            RelationshipMapCloneService.MATRIX_RELATIONSHIP_NAME,
            RelationshipMapCloneService.PLACEHOLDER_RELATIONSHIP_NAME,
            RelationshipMapCloneService.RM_SETTINGS_RELATIONSHIP_NAME,
            RelationshipMapCloneService.RM_BADGE_ACCOUNT_PLAN_ASSOC_NAME,
            RelationshipMapCloneService.RELATIONSHIP_TYPE_MAP_ASSOC_NAME
        };
        System.assertEquals(expectedRelationsips, full.relationships, 'The relationships to clone are correct');
    }

    @isTest
    private static void relatedFieldNoRelatedIdTest() {
        Id mapId = fflib_IDGenerator.generate(Relationship_Map__c.SObjectType);
        String name = 'The Map Name';
        Id ownerId = fflib_IDGenerator.generate(User.SObjectType);

        RelationshipMapCloneWrapper noRelationship = new RelationshipMapCloneWrapper(mapId, name, ownerId, null);
        System.assertEquals(
            null,
            noRelationship.relatedField,
            'Wrapper without relatedId should not have a relatedField'
        );
        System.assertEquals(
            null,
            noRelationship.relatedFieldObjType,
            'Wrapper without relatedId should not have a relatedFieldObjType'
        );
    }

    @isTest
    private static void relatedFieldNoRelationsTest() {
        TestMockData md = new TestMockData();
        SObjectServiceImpl sobjService = md.mockSObjectService; //NOPMD - Needs to be called in order for it to be mocked in the test

        Id mapId = fflib_IDGenerator.generate(Relationship_Map__c.SObjectType);
        String name = 'The Map Name';
        Id ownerId = fflib_IDGenerator.generate(User.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        RelationshipMapCloneWrapper withRelationship = new RelationshipMapCloneWrapper(mapId, name, ownerId, accountId);
        System.assertEquals(
            null,
            withRelationship.relatedField,
            'Wrapper with relatedId but no object relationships should have null relatedField'
        );
        System.assertEquals(
            null,
            withRelationship.relatedFieldObjType,
            'Wrapper with relatedId but no object relationships should have null relatedFieldObjType'
        );
    }

    @isTest
    private static void relatedFieldRelatedRMTest() {
        TestMockData md = new TestMockData();
        SObjectServiceImpl sobjService = md.mockSObjectService;

        md.mocks.startStubbing();
        md.mocks.when(
                sobjService.relationshipsFromDescribeMatchingObjectType(
                    pqcrush__Relationship_Map__c.sObjectType.getDescribe(),
                    User.SObjectType
                )
            )
            .thenReturn(new Set<Schema.SObjectField>{ Relationship_Map__c.OwnerId });
        md.mocks.stopStubbing();

        Id mapId = fflib_IDGenerator.generate(Relationship_Map__c.SObjectType);
        String name = 'The Map Name';
        Id ownerId = fflib_IDGenerator.generate(User.SObjectType);
        Id userId = fflib_IDGenerator.generate(User.SObjectType);
        RelationshipMapCloneWrapper withRelationship = new RelationshipMapCloneWrapper(mapId, name, ownerId, userId);
        System.assertNotEquals(
            null,
            withRelationship.relatedField,
            'Wrapper with relatedId should have a relatedField'
        );
        System.assertEquals(
            Relationship_Map__c.OwnerId,
            withRelationship.relatedField,
            'RelatedField should be the expected one'
        );
        System.assertNotEquals(
            null,
            withRelationship.relatedFieldObjType,
            'Wrapper with relatedId should have a relatedFieldObjType'
        );
        System.assertEquals(
            Relationship_Map__c.SObjectType,
            withRelationship.relatedFieldObjType,
            'RelatedField should be a RM Field'
        );
    }

    @isTest
    private static void relatedFieldRelatedAccountTest() {
        TestMockData md = new TestMockData();
        SObjectServiceImpl sobjService = md.mockSObjectService;

        md.mocks.startStubbing();
        md.mocks.when(
                sobjService.relationshipsFromDescribeMatchingObjectType(
                    Account.SObjectType.getDescribe(),
                    pqcrush__Relationship_Map__c.sObjectType
                )
            )
            .thenReturn(new Set<Schema.SObjectField>{ Account.OwnerId });
        md.mocks.stopStubbing();

        Id mapId = fflib_IDGenerator.generate(Relationship_Map__c.SObjectType);
        String name = 'The Map Name';
        Id ownerId = fflib_IDGenerator.generate(User.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        RelationshipMapCloneWrapper withRelationship = new RelationshipMapCloneWrapper(mapId, name, ownerId, accountId);
        System.assertNotEquals(
            null,
            withRelationship.relatedField,
            'Wrapper with relatedId should have a relatedField'
        );
        System.assertEquals(Account.OwnerId, withRelationship.relatedField, 'RelatedField should be the expected one');
        System.assertNotEquals(
            null,
            withRelationship.relatedFieldObjType,
            'Wrapper with relatedId should have a relatedFieldObjType'
        );
        System.assertEquals(
            Account.SObjectType,
            withRelationship.relatedFieldObjType,
            'RelatedField should be an Account Field'
        );
    }

    @isTest
    private static void validationCheckTest() {
        String name = 'The Map Name';
        Id ownerId = fflib_IDGenerator.generate(User.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        RelationshipMapCloneWrapper wrapper = new RelationshipMapCloneWrapper(null, name, ownerId, accountId);
        try {
            wrapper.validationCheck();
            System.assert(false, 'Expected no map id exception');
        } catch (Exception e) {
            System.assertEquals('No map information passed when trying to clone a Relationship Map', e.getMessage());
        }
    }

    @isTest
    private static void equalityTest() {
        Id mapId = fflib_IDGenerator.generate(Relationship_Map__c.SObjectType);
        String name = 'The Map Name';
        Id ownerId = fflib_IDGenerator.generate(User.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        RelationshipMapCloneWrapper one = new RelationshipMapCloneWrapper(mapId, name, ownerId, accountId);
        RelationshipMapCloneWrapper two = new RelationshipMapCloneWrapper(mapId, name, ownerId, accountId);
        RelationshipMapCloneWrapper three = new RelationshipMapCloneWrapper(null, null, null, null);
        System.assertEquals(one, two, 'Wrappers should be equal');
        System.assert(one.equals(two), 'Wrappers should have equals function');
        System.assert(two.equals(one), 'equals function should be transitive');
        System.assertNotEquals(one, three, 'Wrappers with different data should not be equal');
        System.assert(!one.equals(mapId), 'Wrapper should not be equal to other object types');
    }
}