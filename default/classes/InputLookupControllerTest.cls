@isTest
private class InputLookupControllerTest {
    @testSetup
    private static void setup() {
        insert new Contact(LastName = 'Test1', FirstName = 'Name1');
        insert new Contact(LastName = 'Test2', FirstName = 'Name2');
        insert new Contact(LastName = 'Test3', FirstName = 'Name3');
    }

    @isTest
    private static void searchSObjectNullTypeTest() {
        // Given
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl doqs = md.mockDynamicObjectQueryService;
        String type = null;
        String searchString = 'Test';
        String displayFieldName = 'Name';
        List<String> selectedIds = new List<String>();

        // When
        List<LookupSearchResult> result = InputLookupController.searchSObject(
            type,
            searchString,
            displayFieldName,
            selectedIds
        );

        // Then
        System.assertEquals(null, result, 'Should return null if null type passed');
        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .queryRecentlyViewedExcludingIds(fflib_Match.anyString(), (List<String>) fflib_Match.anyList());
        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .searchSObjectsWithTypeAndFieldsExcludingIds(
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                (List<String>) fflib_Match.anyList()
            );
    }

    @isTest
    private static void searchSObjectInvalidTypeTest() {
        // Given
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl doqs = md.mockDynamicObjectQueryService;
        String type = 'fake_Not_Real_aaoitt';
        String searchString = 'Test';
        String displayFieldName = 'Name';
        List<String> selectedIds = new List<String>();

        // When
        List<LookupSearchResult> result = InputLookupController.searchSObject(
            type,
            searchString,
            displayFieldName,
            selectedIds
        );

        // Then
        System.assertEquals(null, result, 'Should return null if invalid type passed');
        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .queryRecentlyViewedExcludingIds(fflib_Match.anyString(), (List<String>) fflib_Match.anyList());
        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .searchSObjectsWithTypeAndFieldsExcludingIds(
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                (List<String>) fflib_Match.anyList()
            );
    }

    @isTest
    private static void searchSObjectNullDisplayFieldTest() {
        // Given
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl doqs = md.mockDynamicObjectQueryService;
        String type = 'Contact';
        String searchString = 'Test';
        String displayFieldName = null;
        List<String> selectedIds = new List<String>();

        // When
        List<LookupSearchResult> result = InputLookupController.searchSObject(
            type,
            searchString,
            displayFieldName,
            selectedIds
        );

        // Then
        System.assertEquals(null, result, 'Should return null if null display passed');
        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .queryRecentlyViewedExcludingIds(fflib_Match.anyString(), (List<String>) fflib_Match.anyList());
        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .searchSObjectsWithTypeAndFieldsExcludingIds(
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                (List<String>) fflib_Match.anyList()
            );
    }

    @isTest
    private static void searchSObjectInvalidDisplayFieldTest() {
        // Given
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl doqs = md.mockDynamicObjectQueryService;
        String type = 'Contact';
        String searchString = 'Test';
        String displayFieldName = 'fake_Not_Real_ssoidft';
        List<String> selectedIds = new List<String>();

        // When
        List<LookupSearchResult> result = InputLookupController.searchSObject(
            type,
            searchString,
            displayFieldName,
            selectedIds
        );

        // Then
        System.assertEquals(null, result, 'Should return null if invalid display field passed');
        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .queryRecentlyViewedExcludingIds(fflib_Match.anyString(), (List<String>) fflib_Match.anyList());
        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .searchSObjectsWithTypeAndFieldsExcludingIds(
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                (List<String>) fflib_Match.anyList()
            );
    }

    @isTest
    private static void searchSObjectWithNullSearchStringTest() {
        // Given
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl doqs = md.mockDynamicObjectQueryService;
        String type = 'Account';
        String searchString = null;
        String displayFieldName = 'Name';
        List<String> selectedIds = new List<String>();

        md.mocks.startStubbing();
        md.mocks.when(doqs.queryRecentlyViewedExcludingIds(type, selectedIds))
            .thenReturn(new List<SObject>{ md.mockRecentlyViewed });
        md.mocks.stopStubbing();

        // When
        List<LookupSearchResult> result = InputLookupController.searchSObject(
            type,
            searchString,
            displayFieldName,
            selectedIds
        );

        // Then
        System.assertEquals(1, result.size(), 'Should return the one object from the mocked result');

        LookupSearchResult returnedSearchResult = result[0];
        System.assertEquals(
            md.mockRecentlyViewed.Id,
            returnedSearchResult.getId(),
            'Should return the Id of the mocked object'
        );
        System.assertEquals(
            md.mockRecentlyViewed.Type,
            returnedSearchResult.getSObjectType(),
            'Should return the type of the mocked object'
        );
        System.assertEquals(
            md.mockRecentlyViewed.Name,
            returnedSearchResult.getTitle(),
            'Should return the name of the mocked object as the title'
        );
        System.assertEquals(null, returnedSearchResult.getSubtitle(), 'Should return null as the subtitle');

        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 1))
            .queryRecentlyViewedExcludingIds(fflib_Match.anyString(), (List<String>) fflib_Match.anyList());
        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .searchSObjectsWithTypeAndFieldsExcludingIds(
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                (List<String>) fflib_Match.anyList()
            );
    }

    @isTest
    private static void searchSObjectWithEmptySearchStringTest() {
        // Given
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl doqs = md.mockDynamicObjectQueryService;
        String type = 'Account';
        String searchString = '';
        String displayFieldName = 'Name';
        List<String> selectedIds = new List<String>();

        md.mocks.startStubbing();
        md.mocks.when(doqs.queryRecentlyViewedExcludingIds(type, selectedIds))
            .thenReturn(new List<SObject>{ md.mockRecentlyViewed });
        md.mocks.stopStubbing();

        // When
        List<LookupSearchResult> result = InputLookupController.searchSObject(
            type,
            searchString,
            displayFieldName,
            selectedIds
        );

        // Then
        System.assertEquals(1, result.size(), 'Should return the one object from the mocked result');

        LookupSearchResult returnedSearchResult = result[0];
        System.assertEquals(
            md.mockRecentlyViewed.Id,
            returnedSearchResult.getId(),
            'Should return the Id of the mocked object'
        );
        System.assertEquals(
            md.mockRecentlyViewed.Type,
            returnedSearchResult.getSObjectType(),
            'Should return the type of the mocked object'
        );
        System.assertEquals(
            md.mockRecentlyViewed.Name,
            returnedSearchResult.getTitle(),
            'Should return the name of the mocked object as the title'
        );
        System.assertEquals(null, returnedSearchResult.getSubtitle(), 'Should return null as the subtitle');

        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 1))
            .queryRecentlyViewedExcludingIds(fflib_Match.anyString(), (List<String>) fflib_Match.anyList());
        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .searchSObjectsWithTypeAndFieldsExcludingIds(
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                (List<String>) fflib_Match.anyList()
            );
    }

    @isTest
    private static void searchSObjectWithBlankSearchStringTest() {
        // Given
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl doqs = md.mockDynamicObjectQueryService;
        String type = 'Account';
        String searchString = '     ';
        String displayFieldName = 'Name';
        List<String> selectedIds = new List<String>();

        md.mocks.startStubbing();
        md.mocks.when(doqs.queryRecentlyViewedExcludingIds(type, selectedIds))
            .thenReturn(new List<RecentlyViewed>{ md.mockRecentlyViewed });
        md.mocks.stopStubbing();

        // When
        List<LookupSearchResult> result = InputLookupController.searchSObject(
            type,
            searchString,
            displayFieldName,
            selectedIds
        );

        // Then
        System.assertEquals(1, result.size(), 'Should return the one object from the mocked result');

        LookupSearchResult returnedSearchResult = result[0];
        System.assertEquals(
            md.mockRecentlyViewed.Id,
            returnedSearchResult.getId(),
            'Should return the Id of the mocked object'
        );
        System.assertEquals(
            md.mockRecentlyViewed.Type,
            returnedSearchResult.getSObjectType(),
            'Should return the type of the mocked object'
        );
        System.assertEquals(
            md.mockRecentlyViewed.Name,
            returnedSearchResult.getTitle(),
            'Should return the name of the mocked object as the title'
        );
        System.assertEquals(null, returnedSearchResult.getSubtitle(), 'Should return null as the subtitle');

        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 1))
            .queryRecentlyViewedExcludingIds(fflib_Match.anyString(), (List<String>) fflib_Match.anyList());
        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .searchSObjectsWithTypeAndFieldsExcludingIds(
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                (List<String>) fflib_Match.anyList()
            );
    }

    @isTest
    private static void searchSObjectNullSelectedIdsWithSearchStringTest() {
        // Given
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl doqs = md.mockDynamicObjectQueryService;
        String type = 'Contact';
        String searchString = 'Test';
        String displayFieldName = 'Name';
        List<String> selectedIds = null;

        String objNameField = UTIL_Describe.getNameField(type);

        md.mocks.startStubbing();
        md.mocks.when(
                doqs.searchSObjectsWithTypeAndFieldsExcludingIds(
                    type,
                    searchString,
                    objNameField,
                    displayFieldName,
                    new List<String>()
                )
            )
            .thenReturn(new List<SObject>{ md.mockContact });
        md.mocks.stopStubbing();

        // When
        List<LookupSearchResult> result = InputLookupController.searchSObject(
            type,
            searchString,
            displayFieldName,
            selectedIds
        );

        // Then
        System.assertEquals(1, result.size(), 'Should return the one object from the mocked result');
        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 1))
            .searchSObjectsWithTypeAndFieldsExcludingIds(
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                fflib_Match.anyString(),
                (List<String>) fflib_Match.listIsEmpty()
            );
        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .queryRecentlyViewedExcludingIds(fflib_Match.anyString(), (List<String>) fflib_Match.anyList());
    }

    @isTest
    private static void searchSObjectWithSearchStringTest() {
        // Given
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl doqs = md.mockDynamicObjectQueryService;
        String type = 'Contact';
        String searchString = 'Test';
        String displayFieldName = 'Name';
        List<String> selectedIds = new List<String>();

        String objNameField = UTIL_Describe.getNameField(type);

        md.mocks.startStubbing();
        md.mocks.when(
                doqs.searchSObjectsWithTypeAndFieldsExcludingIds(
                    type,
                    searchString,
                    objNameField,
                    displayFieldName,
                    selectedIds
                )
            )
            .thenReturn(new List<SObject>{ md.mockContact });
        md.mocks.stopStubbing();

        // When
        List<LookupSearchResult> result = InputLookupController.searchSObject(
            type,
            searchString,
            displayFieldName,
            selectedIds
        );

        // Then
        System.assertEquals(1, result.size(), 'Should return the one object from the mocked result');

        LookupSearchResult returnedSearchResult = result[0];
        System.assertEquals(
            md.mockContact.Id,
            returnedSearchResult.getId(),
            'Should return the Id of the mocked object'
        );
        System.assertEquals(type, returnedSearchResult.getSObjectType(), 'Should return the type of the mocked object');
        System.assertEquals(
            md.mockContact.Name,
            returnedSearchResult.getTitle(),
            'Should return the name of the mocked object as the title'
        );
        System.assertEquals(null, returnedSearchResult.getSubtitle(), 'Should return null as the subtitle');

        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .queryRecentlyViewedExcludingIds(fflib_Match.anyString(), (List<String>) fflib_Match.anyList());
    }

    @isTest
    private static void searchWithInputLookupObjectsNullLookupTest() {
        // Given
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl doqs = md.mockDynamicObjectQueryService;
        String searchString = 'Test';

        // When
        List<LookupSearchResult> result = InputLookupController.searchWithInputLookupObjects(null, searchString);

        // Then
        System.assertEquals(null, result, 'Should return null if null lookups passed');

        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .queryRecentlyViewedWithLookupTypes((List<InputLookupTypeObject>) fflib_Match.anyList());
        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .searchSObjectsWithLookupTypes(
                (List<InputLookupTypeObject>) fflib_Match.anyList(),
                fflib_Match.anyString()
            );
    }

    @isTest
    private static void searchWithInputLookupObjectsEmptyLookupTest() {
        // Given
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl doqs = md.mockDynamicObjectQueryService;
        String searchString = 'Test';
        List<InputLookupTypeObject> lookupTypes = new List<InputLookupTypeObject>();

        // When
        List<LookupSearchResult> result = InputLookupController.searchWithInputLookupObjects(lookupTypes, searchString);

        // Then
        System.assertEquals(null, result, 'Should return null if empty lookups passed');

        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .queryRecentlyViewedWithLookupTypes((List<InputLookupTypeObject>) fflib_Match.anyList());
        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .searchSObjectsWithLookupTypes(
                (List<InputLookupTypeObject>) fflib_Match.anyList(),
                fflib_Match.anyString()
            );
    }

    @isTest
    private static void searchWithInputLookupObjectsWithoutSearchStringTest() {
        // Given
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl doqs = md.mockDynamicObjectQueryService;
        String searchString = null;
        InputLookupTypeObject lookup = new InputLookupTypeObject('Account');
        List<InputLookupTypeObject> lookupTypes = new List<InputLookupTypeObject>{ lookup };

        md.mocks.startStubbing();
        md.mocks.when(doqs.queryRecentlyViewedWithLookupTypes(lookupTypes))
            .thenReturn(new List<RecentlyViewed>{ md.mockRecentlyViewed });
        md.mocks.stopStubbing();

        // When
        List<LookupSearchResult> result = InputLookupController.searchWithInputLookupObjects(lookupTypes, searchString);

        // Then
        System.assertEquals(1, result.size(), 'Should return the one object from the mocked result');

        LookupSearchResult returnedSearchResult = result[0];
        System.assertEquals(
            md.mockRecentlyViewed.Id,
            returnedSearchResult.getId(),
            'Should return the Id of the mocked object'
        );
        System.assertEquals(
            md.mockRecentlyViewed.Type,
            returnedSearchResult.getSObjectType(),
            'Should return the type of the mocked object'
        );
        System.assertEquals(
            md.mockRecentlyViewed.Name,
            returnedSearchResult.getTitle(),
            'Should return the name of the mocked object as the title'
        );
        System.assertEquals(null, returnedSearchResult.getSubtitle(), 'Should return null as the subtitle');

        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 1))
            .queryRecentlyViewedWithLookupTypes((List<InputLookupTypeObject>) fflib_Match.anyList());
        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .searchSObjectsWithLookupTypes(
                (List<InputLookupTypeObject>) fflib_Match.anyList(),
                fflib_Match.anyString()
            );
    }

    @isTest
    private static void searchWithInputLookupObjectsWithSearchStringTest() {
        // Given
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl doqs = md.mockDynamicObjectQueryService;
        String searchString = 'Test';
        InputLookupTypeObject lookup = new InputLookupTypeObject('Account');
        List<InputLookupTypeObject> lookupTypes = new List<InputLookupTypeObject>{ lookup };

        md.mocks.startStubbing();
        md.mocks.when(doqs.searchSObjectsWithLookupTypes(lookupTypes, searchString))
            .thenReturn(new List<SObject>{ md.mockAccount });
        md.mocks.stopStubbing();

        // When
        List<LookupSearchResult> result = InputLookupController.searchWithInputLookupObjects(lookupTypes, searchString);

        // Then
        System.assertEquals(1, result.size(), 'Should return the one object from the mocked result');

        LookupSearchResult returnedSearchResult = result[0];
        System.assertEquals(
            md.mockAccount.Id,
            returnedSearchResult.getId(),
            'Should return the Id of the mocked object'
        );
        System.assertEquals(
            lookup.objType,
            returnedSearchResult.getSObjectType(),
            'Should return the type of the mocked object'
        );
        System.assertEquals(
            md.mockAccount.Name,
            returnedSearchResult.getTitle(),
            'Should return the name of the mocked object as the title'
        );
        System.assertEquals(null, returnedSearchResult.getSubtitle(), 'Should return null as the subtitle');

        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .queryRecentlyViewedWithLookupTypes((List<InputLookupTypeObject>) fflib_Match.anyList());
        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 1))
            .searchSObjectsWithLookupTypes(
                (List<InputLookupTypeObject>) fflib_Match.anyList(),
                fflib_Match.anyString()
            );
    }

    @isTest
    private static void searchWithInputLookupObjectsWithMultipleTypesTest() {
        // Given
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl doqs = md.mockDynamicObjectQueryService;
        String searchString = 'Test';
        InputLookupTypeObject contactLookup = new InputLookupTypeObject('Contact');
        InputLookupTypeObject accountLookup = new InputLookupTypeObject('Account');
        List<InputLookupTypeObject> lookupTypes = new List<InputLookupTypeObject>{ contactLookup, accountLookup };

        md.mocks.startStubbing();
        md.mocks.when(doqs.searchSObjectsWithLookupTypes(lookupTypes, searchString))
            .thenReturn(new List<SObject>{ md.mockContact, md.mockAccount });
        md.mocks.stopStubbing();

        // When
        List<LookupSearchResult> result = InputLookupController.searchWithInputLookupObjects(lookupTypes, searchString);

        // Then
        System.assertEquals(2, result.size(), 'Should return the two objects from the mocked result');
        Boolean foundContact = false;
        Boolean foundAccount = false;
        for (LookupSearchResult lookupResult : result) {
            if (lookupResult.getId() == md.mockContactId) {
                System.assertEquals(
                    contactLookup.objType,
                    lookupResult.getSObjectType(),
                    'Should return the contact object type'
                );
                foundContact = true;
            } else {
                System.assertEquals(
                    accountLookup.objType,
                    lookupResult.getSObjectType(),
                    'Should return the account object type'
                );
                foundAccount = true;
            }
        }
        System.assert(foundContact && foundAccount, 'Should find both the contact and the account in the results');

        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 0))
            .queryRecentlyViewedWithLookupTypes((List<InputLookupTypeObject>) fflib_Match.anyList());
        ((DynamicObjectQueryServiceImpl) md.mocks.verify(doqs, 1))
            .searchSObjectsWithLookupTypes(
                (List<InputLookupTypeObject>) fflib_Match.anyList(),
                fflib_Match.anyString()
            );
    }

    @isTest
    private static void getCurrentSelectionResultObjTest() {
        // Given
        List<Contact> contacts = [SELECT Id, LastName, FirstName, Name FROM Contact];

        // When
        Test.startTest();

        LookupSearchResult nullIdResult = InputLookupController.getCurrentSelectionResultObj(null, 'Name');
        LookupSearchResult validIdResult = InputLookupController.getCurrentSelectionResultObj(contacts[0].Id, 'Name');

        Test.stopTest();

        // Then
        System.assertEquals(true, nullIdResult == null, 'Should return null string');
        System.assertEquals(
            true,
            validIdResult.getTitle() == contacts[0].Name,
            'Should return title of ' + contacts[0].Name
        );
        System.assertEquals(
            true,
            validIdResult.getIcon() == 'standard:contact',
            'Should return string standard:contact'
        );
    }

    @isTest
    private static void getLookupListForIdsNullEmptyTest() {
        List<Map<String, String>> result = InputLookupController.getLookupListForIds(null);
        System.assertEquals(0, result.size(), 'Should return an empty list if null passed');

        result = InputLookupController.getLookupListForIds(new List<Id>());
        System.assertEquals(0, result.size(), 'Should return an empty list if empty list passed');
    }

    @isTest
    private static void getLookupListForIdsHappyPathTest() {
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl doqs = md.mockDynamicObjectQueryService;

        List<Id> idList = new List<Id>{ md.mockAccountId };

        md.mocks.startStubbing();
        md.mocks.when(doqs.querySObjectListWithIdsAndFields(idList, new Set<String>{ 'Name' }))
            .thenReturn(new List<SObject>{ md.mockAccount });
        md.mocks.stopStubbing();

        List<Map<String, String>> result = InputLookupController.getLookupListForIds(idList);
        System.assertEquals(1, result.size(), 'Should return one matching map');
        System.assertEquals(md.mockAccount.Name, result[0].get('label'), 'Should return the correct label');
        System.assertEquals(md.mockAccount.Id, result[0].get('value'), 'Should return the correct value');
    }

    @isTest
    private static void getLookupListForIdsPartialMatchTest() {
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl doqs = md.mockDynamicObjectQueryService;

        List<Id> idList = new List<Id>{ md.mockAccountId, md.mockContactId };

        md.mocks.startStubbing();
        md.mocks.when(doqs.querySObjectListWithIdsAndFields(idList, new Set<String>{ 'Name' }))
            .thenReturn(new List<SObject>{ md.mockAccount });
        md.mocks.stopStubbing();

        List<Map<String, String>> result = InputLookupController.getLookupListForIds(idList);
        System.assertEquals(1, result.size(), 'Should return one matching map since only one record matches');
    }
}