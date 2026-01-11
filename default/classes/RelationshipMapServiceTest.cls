@IsTest
private class RelationshipMapServiceTest {
    private static final String MAP_NAME = 'RMST Relationship Map Record';

    private static final String CONTACT_LAST_NAME = 'RMST test contact last Name';

    public static final String RM_USER_FIRST_NAME = 'RMST test admin user first';
    public static final String RM_USER_LAST_NAME = 'RMST test admin user last';

    public static final String NON_RM_USER_FIRST_NAME = 'RMST test no perm user first';
    public static final String NON_RM_USER_LAST_NAME = 'RMST test no perm user last';

    public static final String RM_PERM = 'PROLIFIQ_RELATIONSHIP_MAP';

    public static final String STANDARD_USER = 'Standard User';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];

        User adminUser = TestDataFactory.createUser(RM_USER_FIRST_NAME, RM_USER_LAST_NAME, standardProfile.Id);

        TestDataFactory.createUser(NON_RM_USER_FIRST_NAME, NON_RM_USER_LAST_NAME, standardProfile.Id);
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :RM_PERM LIMIT 1];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = adminUserPermissionSet.Id)
        };

        System.runAs(adminUser) {
            Contact testContact = new Contact(LastName = CONTACT_LAST_NAME);
            insert testContact;

            Relationship_Map__c theMap = TestDataFactory.createRelationshipMap(MAP_NAME);
            TestDataFactory.createRelationshipMapMember(theMap.Id, testContact.Id);
        }
    }

    /**********************************************
     *** createRelationshipMapWithFieldValues() ***
     *********************************************/

    @IsTest
    static void createRelationshipMapWithFieldValuesNullTest() {
        //Given
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        pqcrush__Relationship_Map__c expectedMap = new pqcrush__Relationship_Map__c();

        //Then
        RelationshipMapService.createRelationshipMapWithFieldValues(null);

        //Test
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow)).registerNew(expectedMap);
        System.assert(true, 'Check being done via mocks.verify');
    }

    @IsTest
    static void createRelationshipMapWithFieldValuesEmptyMapTest() {
        //Given
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        Map<String, Object> fieldValues = new Map<String, Object>();
        pqcrush__Relationship_Map__c expectedMap = new pqcrush__Relationship_Map__c();

        //Then
        RelationshipMapService.createRelationshipMapWithFieldValues(fieldValues);

        //Test
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow)).registerNew(expectedMap);
        System.assert(true, 'Check being done via mocks.verify');
    }

    @IsTest
    static void createRelationshipMapWithFieldValuesLongNameTest() {
        //Given
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        String testMapName = 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec qu';
        String expectedName = 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula ';
        Map<String, Object> fieldValues = new Map<String, Object>{ 'Name' => testMapName };
        pqcrush__Relationship_Map__c expectedMap = new pqcrush__Relationship_Map__c(Name = expectedName);

        //Then
        pqcrush__Relationship_Map__c result = RelationshipMapService.createRelationshipMapWithFieldValues(fieldValues);

        //Test
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow)).registerNew(expectedMap);
        System.assertEquals(expectedName, result.Name, 'Name should be trimmed to Name field length (80 characters)');
    }

    @IsTest
    static void createRelationshipMapWithFieldValuesHappyPathTest() {
        //Given
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        String testMapName = 'RelationshipMapServiceTest mock map test';
        Map<String, Object> fieldValues = new Map<String, Object>{ 'Name' => testMapName };
        pqcrush__Relationship_Map__c expectedMap = new pqcrush__Relationship_Map__c(Name = testMapName);

        //Then
        pqcrush__Relationship_Map__c result = RelationshipMapService.createRelationshipMapWithFieldValues(fieldValues);

        //Test
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow)).registerNew(expectedMap);
        System.assertEquals(testMapName, result.Name, 'Name should match the value passed in to the method');
    }

    /**************************
     *** createRelatedMap() ***
     *************************/

    @IsTest
    static void createRelatedMapNullEmptyRelationsTest() {
        List<Schema.SObjectField> emptyList = new List<Schema.SObjectField>();
        Schema.DescribeSObjectResult objDescribe = User.getSObjectType().getDescribe();
        Id recordId = UserInfo.getUserId();
        String expectedError = System.label.error_no_map_relationship;
        try {
            RelationshipMapService.createRelatedMap(null, null, objDescribe, recordId);
            System.assert(false, 'Exception should be thrown');
        } catch (Exception e) {
            System.assertEquals(expectedError, e.getMessage(), 'Expected error should be thrown');
        }

        try {
            RelationshipMapService.createRelatedMap(emptyList, emptyList, objDescribe, recordId);
            System.assert(false, 'Exception should be thrown');
        } catch (Exception e) {
            System.assertEquals(expectedError, e.getMessage(), 'Expected error should be thrown');
        }

        try {
            RelationshipMapService.createRelatedMap(emptyList, null, objDescribe, recordId);
            System.assert(false, 'Exception should be thrown');
        } catch (Exception e) {
            System.assertEquals(expectedError, e.getMessage(), 'Expected error should be thrown');
        }

        try {
            RelationshipMapService.createRelatedMap(null, emptyList, objDescribe, recordId);
            System.assert(false, 'Exception should be thrown');
        } catch (Exception e) {
            System.assertEquals(expectedError, e.getMessage(), 'Expected error should be thrown');
        }
    }

    @IsTest
    static void createRelatedMapNullObjDescribeTest() {
        // Given
        User testUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :RM_USER_FIRST_NAME AND LastName = :RM_USER_LAST_NAME
            LIMIT 1
        ];

        List<Schema.SObjectField> listValue = new List<Schema.SObjectField>{ pqcrush__Relationship_Map__c.Name };
        Schema.DescribeSObjectResult objDescribe = null;
        Id recordId = UserInfo.getUserId();
        String expectedError = String.format(
            System.label.error_insufficient_access,
            new List<String>{ System.label.Unknown_Object }
        );

        System.runAs(testUser) {
            try {
                RelationshipMapService.createRelatedMap(listValue, listValue, objDescribe, recordId);
                System.assert(false, 'Exception should be thrown');
            } catch (Exception e) {
                System.assertEquals(expectedError, e.getMessage(), 'Expected error should be thrown');
            }
        }
    }

    @IsTest
    static void createRelatedMapNullObjRecordIdTest() {
        // Given
        User testUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :RM_USER_FIRST_NAME AND LastName = :RM_USER_LAST_NAME
            LIMIT 1
        ];

        List<Schema.SObjectField> listValue = new List<Schema.SObjectField>{ pqcrush__Relationship_Map__c.Name };
        Schema.DescribeSObjectResult objDescribe = User.getSObjectType().getDescribe();
        Id recordId = null;
        String expectedError = System.label.error_insufficient_access_this_record;

        System.runAs(testUser) {
            try {
                RelationshipMapService.createRelatedMap(listValue, listValue, objDescribe, recordId);
                System.assert(false, 'Exception should be thrown');
            } catch (Exception e) {
                System.assertEquals(expectedError, e.getMessage(), 'Expected error should be thrown');
            }
        }
    }

    @IsTest
    static void createRelatedMapBadObjRecordAccessTest() {
        // Given
        User testUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :RM_USER_FIRST_NAME AND LastName = :RM_USER_LAST_NAME
            LIMIT 1
        ];

        List<Schema.SObjectField> listValue = new List<Schema.SObjectField>{ pqcrush__Relationship_Map__c.Name };
        Schema.DescribeSObjectResult objDescribe = User.getSObjectType().getDescribe();
        Id recordId = fflib_IDGenerator.generate(User.SObjectType);
        String expectedError = String.format(
            System.label.error_insufficient_access,
            new List<String>{ String.valueOf(recordId) }
        );

        System.runAs(testUser) {
            try {
                RelationshipMapService.createRelatedMap(listValue, listValue, objDescribe, recordId);
                System.assert(false, 'Exception should be thrown');
            } catch (Exception e) {
                System.assertEquals(expectedError, e.getMessage(), 'Expected error should be thrown');
            }
        }
    }

    @IsTest
    static void createRelatedMapNoRMPermsTest() {
        // Given
        User testUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :NON_RM_USER_FIRST_NAME AND LastName = :NON_RM_USER_LAST_NAME
            LIMIT 1
        ];

        List<Schema.SObjectField> listValue = new List<Schema.SObjectField>{ pqcrush__Relationship_Map__c.Name };
        Schema.DescribeSObjectResult objDescribe = User.getSObjectType().getDescribe();
        Id recordId = testUser.Id;
        String expectedError = String.format(
            System.label.error_insufficient_access,
            new List<String>{ pqcrush__Relationship_Map__c.sObjectType.getDescribe().getName() }
        );

        System.runAs(testUser) {
            try {
                RelationshipMapService.createRelatedMap(listValue, listValue, objDescribe, recordId);
                System.assert(false, 'Exception should be thrown');
            } catch (Exception e) {
                System.assertEquals(expectedError, e.getMessage(), 'Expected error should be thrown');
            }
        }
    }

    @IsTest
    static void createRelatedMapNoRelFieldsTest() {
        // Given
        User testUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :RM_USER_FIRST_NAME AND LastName = :RM_USER_LAST_NAME
            LIMIT 1
        ];

        List<Schema.SObjectField> listValue = new List<Schema.SObjectField>{ pqcrush__Relationship_Map__c.Name };
        Schema.DescribeSObjectResult objDescribe = User.getSObjectType().getDescribe();
        Id recordId = testUser.Id;
        String expectedError = System.label.error_no_map_relationship_fls;

        System.runAs(testUser) {
            try {
                RelationshipMapService.createRelatedMap(listValue, listValue, objDescribe, recordId);
                System.assert(false, 'Exception should be thrown');
            } catch (Exception e) {
                System.assertEquals(expectedError, e.getMessage(), 'Expected error should be thrown');
            }
        }
    }

    @IsTest
    static void createRelatedMapNoFLSTest() {
        // Given
        User testUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :RM_USER_FIRST_NAME AND LastName = :RM_USER_LAST_NAME
            LIMIT 1
        ];

        List<Schema.SObjectField> listValue = new List<Schema.SObjectField>{ pqcrush__Relationship_Map__c.CreatedById };
        Schema.DescribeSObjectResult objDescribe = User.getSObjectType().getDescribe();
        Id recordId = testUser.Id;
        String expectedError = System.label.error_no_map_relationship_fls;

        System.runAs(testUser) {
            try {
                RelationshipMapService.createRelatedMap(listValue, listValue, objDescribe, recordId);
                System.assert(false, 'Exception should be thrown');
            } catch (Exception e) {
                System.assertEquals(expectedError, e.getMessage(), 'Expected error should be thrown');
            }
        }
    }

    @IsTest
    static void createRelatedMapFakeFLSTest() {
        // Given
        User testUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :RM_USER_FIRST_NAME AND LastName = :RM_USER_LAST_NAME
            LIMIT 1
        ];

        List<Schema.SObjectField> listValue = new List<Schema.SObjectField>{ Account.Site };
        Schema.DescribeSObjectResult objDescribe = User.getSObjectType().getDescribe();
        Id recordId = testUser.Id;
        String expectedError = System.label.error_no_map_relationship_fls;

        System.runAs(testUser) {
            try {
                RelationshipMapService.createRelatedMap(listValue, listValue, objDescribe, recordId);
                System.assert(false, 'Exception should be thrown');
            } catch (Exception e) {
                System.assertEquals(expectedError, e.getMessage(), 'Expected error should be thrown');
            }
        }
    }

    @IsTest
    static void createRelatedMapValidMapTest() {
        // Given
        User testUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :RM_USER_FIRST_NAME AND LastName = :RM_USER_LAST_NAME
            LIMIT 1
        ];

        List<Schema.SObjectField> objList = new List<Schema.SObjectField>();
        List<Schema.SObjectField> mapList = new List<Schema.SObjectField>{
            pqcrush__Relationship_Map__c.CreatedById,
            pqcrush__Relationship_Map__c.LastModifiedById,
            pqcrush__Relationship_Map__c.OwnerId
        };
        Schema.DescribeSObjectResult objDescribe = User.getSObjectType().getDescribe();
        Id recordId = UserInfo.getUserId();

        pqcrush__Relationship_Map__c result;
        System.runAs(testUser) {
            result = RelationshipMapService.createRelatedMap(objList, mapList, objDescribe, recordId);
        }
        System.assertNotEquals(null, result, 'Map should be created');
        System.assertEquals(recordId, result.OwnerId, 'Created map should have specified relationship');
    }

    @IsTest
    static void addContactToRelationshipMapTest() {
        testMockData md = new testMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        RelationshipMapService.addContactToRelationshipMap(md.mockRelationshipMapId, new Set<Id>{ md.mockContactId });

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew((Relationship_Map_Member__c) fflib_Match.anyObject());

        System.assert(true, 'Asserts from mock verify');
    }

    /*****************************************
     *** getMapMemberCountForAccountPlan() ***
     ****************************************/

    @IsTest
    static void getMapMemberCountForAccountPlanNullPlanTest() {
        Double result = RelationshipMapService.getMapMemberCountForAccountPlan(null);
        System.assertEquals(-1, result, 'Null plan should return -1');
    }

    @IsTest
    static void getMapMemberCountForAccountPlanNoMapsTest() {
        TestMockData md = new TestMockData();
        RelationshipMapSelector mockSelector = md.mockRelationshipMapSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockSelector.selectByAccountPlanIds(new Set<Id>{ md.mockAccountPlanId }))
            .thenReturn(new List<pqcrush__Relationship_Map__c>());
        md.mocks.stopStubbing();

        Double result = RelationshipMapService.getMapMemberCountForAccountPlan(
            new List<Account_Plan__c>{ md.mockAccountPlan }
        );

        System.assertEquals(0, result, 'No maps should return 0');
    }

    @IsTest
    static void getMapMemberCountForAccountPlanMapWithoutCountTest() {
        TestMockData md = new TestMockData();
        RelationshipMapSelector mockSelector = md.mockRelationshipMapSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockSelector.selectByAccountPlanIds(new Set<Id>{ md.mockAccountPlanId }))
            .thenReturn(new List<pqcrush__Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.stopStubbing();

        Double result = RelationshipMapService.getMapMemberCountForAccountPlan(
            new List<Account_Plan__c>{ md.mockAccountPlan }
        );

        System.assertEquals(0, result, 'Map without count should return 0');
    }

    @IsTest
    static void getMapMemberCountForAccountPlanMapWithCountTest() {
        TestMockData md = new TestMockData();
        RelationshipMapSelector mockSelector = md.mockRelationshipMapSelector;

        Double memberCount = 5;

        String mapString =
            '{"Id": "' +
            md.mockRelationshipMapId +
            '", "Name": "gmmcfapmwct_test Map", "pqcrush__Map_Member_Count__c": "' +
            memberCount +
            '"}';
        Relationship_Map__c mockRelationshipMap = (Relationship_Map__c) JSON.deserialize(
            mapString,
            Relationship_Map__c.class
        );

        md.mocks.startStubbing();
        md.mocks.when(mockSelector.selectByAccountPlanIds(new Set<Id>{ md.mockAccountPlanId }))
            .thenReturn(new List<pqcrush__Relationship_Map__c>{ mockRelationshipMap });
        md.mocks.stopStubbing();

        Double result = RelationshipMapService.getMapMemberCountForAccountPlan(
            new List<Account_Plan__c>{ md.mockAccountPlan }
        );

        System.assertEquals(memberCount, result, 'Map with count should return expected count');
    }

    @IsTest
    static void getMapMemberCountForAccountPlanMultipleMapTest() {
        TestMockData md = new TestMockData();
        RelationshipMapSelector mockSelector = md.mockRelationshipMapSelector;

        Double memberCount1 = 5;
        String mapString1 =
            '{"Id": "' +
            fflib_IDGenerator.generate(pqcrush__Relationship_Map__c.SObjectType) +
            '", "Name": "gmmcfapmwct_test Map", "pqcrush__Map_Member_Count__c": "' +
            memberCount1 +
            '"}';
        Relationship_Map__c mockRelationshipMap1 = (Relationship_Map__c) JSON.deserialize(
            mapString1,
            Relationship_Map__c.class
        );

        Double memberCount2 = 10;
        String mapString2 =
            '{"Id": "' +
            fflib_IDGenerator.generate(pqcrush__Relationship_Map__c.SObjectType) +
            '", "Name": "gmmcfapmwct_test Map", "pqcrush__Map_Member_Count__c": "' +
            memberCount2 +
            '"}';
        Relationship_Map__c mockRelationshipMap2 = (Relationship_Map__c) JSON.deserialize(
            mapString2,
            Relationship_Map__c.class
        );

        md.mocks.startStubbing();
        md.mocks.when(mockSelector.selectByAccountPlanIds(new Set<Id>{ md.mockAccountPlanId }))
            .thenReturn(new List<pqcrush__Relationship_Map__c>{ mockRelationshipMap1, mockRelationshipMap2 });
        md.mocks.stopStubbing();

        Double result = RelationshipMapService.getMapMemberCountForAccountPlan(
            new List<Account_Plan__c>{ md.mockAccountPlan }
        );

        System.assertEquals(memberCount1 + memberCount2, result, 'Multiple maps should return expected count');
    }

    /***************************************************
     *** getMapMemberLastUpdatedDateForAccountPlan() ***
     **************************************************/

    @IsTest
    static void getMapMemberLastUpdatedDateForAccountPlanNullPlanTest() {
        Date result = RelationshipMapService.getMapMemberLastUpdatedDateForAccountPlan(null);
        System.assertEquals(null, result, 'Null plan should return null');
    }

    @IsTest
    static void getMapMemberLastUpdatedDateForAccountPlanNoMapsTest() {
        TestMockData md = new TestMockData();
        RelationshipMapSelector mockSelector = md.mockRelationshipMapSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockSelector.selectByAccountPlanIds(new Set<Id>{ md.mockAccountPlanId }))
            .thenReturn(new List<pqcrush__Relationship_Map__c>());
        md.mocks.stopStubbing();

        Date result = RelationshipMapService.getMapMemberLastUpdatedDateForAccountPlan(
            new List<Account_Plan__c>{ md.mockAccountPlan }
        );

        System.assertEquals(null, result, 'No maps should return null');
    }

    @IsTest
    static void getMapMemberLastUpdatedDateForAccountPlanMapWithoutDateTest() {
        TestMockData md = new TestMockData();
        RelationshipMapSelector mockSelector = md.mockRelationshipMapSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockSelector.selectByAccountPlanIds(new Set<Id>{ md.mockAccountPlanId }))
            .thenReturn(new List<pqcrush__Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.stopStubbing();

        Date result = RelationshipMapService.getMapMemberLastUpdatedDateForAccountPlan(
            new List<Account_Plan__c>{ md.mockAccountPlan }
        );

        System.assertEquals(null, result, 'Map without date should return null');
    }

    @IsTest
    static void getMapMemberLastUpdatedDateForAccountPlanMapWithDateTest() {
        TestMockData md = new TestMockData();
        RelationshipMapSelector mockSelector = md.mockRelationshipMapSelector;

        Date memberLastUpdatedDate = Date.valueOf(((Datetime) Date.valueOf('2018-01-01')).format('yyyy-MM-dd')); //Done this way to avoid time zone issues

        String mapString = JSON.serialize(
            new Map<String, Object>{
                'Id' => md.mockRelationshipMapId,
                'Name' => 'gmmcfapmwdt_test Map',
                'pqcrush__Map_Member_Max_Modified_Date__c' => '2018-01-01'
            }
        );
        Relationship_Map__c mockRelationshipMap = (Relationship_Map__c) JSON.deserialize(
            mapString,
            Relationship_Map__c.class
        );

        md.mocks.startStubbing();
        md.mocks.when(mockSelector.selectByAccountPlanIds(new Set<Id>{ md.mockAccountPlanId }))
            .thenReturn(new List<pqcrush__Relationship_Map__c>{ mockRelationshipMap });
        md.mocks.stopStubbing();

        Date result = RelationshipMapService.getMapMemberLastUpdatedDateForAccountPlan(
            new List<Account_Plan__c>{ md.mockAccountPlan }
        );

        System.assertEquals(memberLastUpdatedDate, result, 'Map with date should return expected date');
    }

    @IsTest
    static void getMapMemberLastUpdatedDateForAccountPlanMultipleMapTest() {
        TestMockData md = new TestMockData();
        RelationshipMapSelector mockSelector = md.mockRelationshipMapSelector;

        String mapString1 = JSON.serialize(
            new Map<String, Object>{
                'Id' => fflib_IDGenerator.generate(pqcrush__Relationship_Map__c.SObjectType),
                'Name' => 'gmmcfapmwdt_test Map1',
                'pqcrush__Map_Member_Max_Modified_Date__c' => '2018-01-01'
            }
        );
        Relationship_Map__c mockRelationshipMap1 = (Relationship_Map__c) JSON.deserialize(
            mapString1,
            Relationship_Map__c.class
        );

        Date memberLastUpdatedDate2 = Date.valueOf(((Datetime) Date.valueOf('2019-02-02')).format('yyyy-MM-dd')); //Done this way to avoid time zone issues
        String mapString2 = JSON.serialize(
            new Map<String, Object>{
                'Id' => fflib_IDGenerator.generate(pqcrush__Relationship_Map__c.SObjectType),
                'Name' => 'gmmcfapmwdt_test Map2',
                'pqcrush__Map_Member_Max_Modified_Date__c' => '2019-02-02'
            }
        );
        Relationship_Map__c mockRelationshipMap2 = (Relationship_Map__c) JSON.deserialize(
            mapString2,
            Relationship_Map__c.class
        );

        md.mocks.startStubbing();
        md.mocks.when(mockSelector.selectByAccountPlanIds(new Set<Id>{ md.mockAccountPlanId }))
            .thenReturn(new List<pqcrush__Relationship_Map__c>{ mockRelationshipMap1, mockRelationshipMap2 });
        md.mocks.stopStubbing();

        Date result = RelationshipMapService.getMapMemberLastUpdatedDateForAccountPlan(
            new List<Account_Plan__c>{ md.mockAccountPlan }
        );

        System.assertEquals(memberLastUpdatedDate2, result, 'Multiple maps should return latest date');
    }

    @isTest
    private static void getMapsForObjectFromObjectTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :RM_USER_FIRST_NAME AND LastName = :RM_USER_LAST_NAME
            LIMIT 1
        ];

        // When
        Set<Id> result;
        System.runAs(adminUser) {
            Test.startTest();
            result = RelationshipMapService.getMapsForObjectFromObject(null, null);
            Test.stopTest();
        }

        // Then
        System.assertEquals(0, result.size(), 'Should be empty');
    }

    @isTest
    private static void getMapsForObjectFromObjectTest2() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :RM_USER_FIRST_NAME AND LastName = :RM_USER_LAST_NAME
            LIMIT 1
        ];

        Set<Id> recordIds = new Set<Id>{ fflib_IDGenerator.generate(Account.SObjectType) };

        TestMockData md = new TestMockData();
        SObjectServiceImpl mockSObjectService = md.mockSObjectService;
        DynamicObjectQueryServiceImpl mockDynamicObjectQueryService = md.mockDynamicObjectQueryService;

        Schema.SObjectType objType = Account.SObjectType;

        // Given
        md.mocks.startStubbing();
        md.mocks.when(
                mockSObjectService.relationshipsFromDescribeMatchingObjectType(
                    (Schema.DescribeSObjectResult) fflib_Match.anyObject(),
                    (Schema.SObjectType) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Set<Schema.SObjectField>());
        md.mocks.when(
                mockDynamicObjectQueryService.querySObjectsWithTypeAndIds(
                    objType,
                    new Set<Schema.SObjectField>(),
                    recordIds
                )
            )
            .thenReturn(new List<SObject>{ md.mockAccount });
        md.mocks.when(
                mockSObjectService.getFirstIdFromSObjectMatchingFields(
                    (SObject) fflib_Match.anyObject(),
                    (Set<Schema.SObjectField>) fflib_Match.anyObject()
                )
            )
            .thenReturn(md.mockAccount.Id);
        md.mocks.stopStubbing();

        // When
        Set<Id> result;
        System.runAs(adminUser) {
            Test.startTest();
            result = RelationshipMapService.getMapsForObjectFromObject(objType, recordIds);
            Test.stopTest();
        }

        // Then
        System.assertEquals(1, result.size(), 'Should have 1 item');
        System.assertEquals(md.mockAccount.Id, (new List<Id>(result))[0]);
    }

    @isTest
    private static void getMapsForObjectFromRMTest() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :RM_USER_FIRST_NAME AND LastName = :RM_USER_LAST_NAME
            LIMIT 1
        ];

        // When
        Set<Id> result;
        System.runAs(adminUser) {
            Test.startTest();
            result = RelationshipMapService.getMapsForObjectFromRM(null, null);
            Test.stopTest();
        }

        // Then
        System.assertEquals(0, result.size(), 'Should be empty');
    }

    @isTest
    private static void getMapsForObjectFromRMTest2() {
        // Given
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :RM_USER_FIRST_NAME AND LastName = :RM_USER_LAST_NAME
            LIMIT 1
        ];

        Set<Id> recordIds = new Set<Id>{ fflib_IDGenerator.generate(Account.SObjectType) };

        TestMockData md = new TestMockData();
        SObjectServiceImpl mockSObjectService = md.mockSObjectService;
        DynamicObjectQueryServiceImpl mockDynamicObjectQueryService = md.mockDynamicObjectQueryService;

        Schema.SObjectType objType = Account.SObjectType;

        // Given
        md.mocks.startStubbing();
        md.mocks.when(
                mockSObjectService.relationshipsFromDescribeMatchingObjectType(
                    (Schema.DescribeSObjectResult) fflib_Match.anyObject(),
                    (Schema.SObjectType) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Set<Schema.SObjectField>());
        md.mocks.when(
                mockDynamicObjectQueryService.querySObjectsWithTypeAndIdsMatchingRecords(
                    pqcrush__Relationship_Map__c.sObjectType,
                    new Set<Schema.SObjectField>(),
                    recordIds
                )
            )
            .thenReturn(new List<SObject>{ md.mockAccount });
        md.mocks.when(
                mockSObjectService.getFirstIdFromSObjectMatchingFields(
                    (SObject) fflib_Match.anyObject(),
                    (Set<Schema.SObjectField>) fflib_Match.anyObject()
                )
            )
            .thenReturn(md.mockAccount.Id);
        md.mocks.stopStubbing();

        // When
        Set<Id> result;
        System.runAs(adminUser) {
            Test.startTest();
            result = RelationshipMapService.getMapsForObjectFromRM(objType, recordIds);
            Test.stopTest();
        }

        // Then
        System.assertEquals(1, result.size(), 'Should have 1 item');
        System.assertEquals(md.mockAccount.Id, (new List<Id>(result))[0]);
    }

    @IsTest
    static void hasAccountPlanSettingIdNullTest() {
        Boolean result = RelationshipMapService.hasAccountPlanSetting((Id) null);

        System.assertEquals(false, result);
    }

    @IsTest
    static void hasAccountPlanSettingIdFalseTest() {
        TestMockData md = new TestMockData();
        RelationshipMapSelector mockSelector = md.mockRelationshipMapSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<pqcrush__Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.stopStubbing();

        Boolean result = RelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMapId);

        System.assertEquals(false, result);
    }

    @IsTest
    static void hasAccountPlanSettingIdPositiveTest() {
        TestMockData md = new TestMockData();
        RelationshipMapSelector mockSelector = md.mockRelationshipMapSelector;
        md.mockRelationshipMap.Type_Setting__c = 'pqcrush__Account_Plan__c';

        md.mocks.startStubbing();
        md.mocks.when(mockSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<pqcrush__Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.stopStubbing();

        Boolean result = RelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMapId);

        System.assertEquals(true, result);
    }

    @IsTest
    static void hasAccountPlanSettingNullTest() {
        Boolean result = RelationshipMapService.hasAccountPlanSetting((Relationship_Map__c) null);
        System.assertEquals(false, result);
    }

    @IsTest
    static void hasAccountPlanSettingFalseTest() {
        TestMockData md = new TestMockData();
        Boolean result = RelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMap);
        System.assertEquals(false, result);
    }

    @IsTest
    static void hasAccountPlanSettingPositiveTest() {
        TestMockData md = new TestMockData();
        md.mockRelationshipMap.Type_Setting__c = 'pqcrush__Account_Plan__c';
        Boolean result = RelationshipMapService.hasAccountPlanSetting(md.mockRelationshipMap);
        System.assertEquals(true, result);
    }

    @isTest
    static void getParentIdForRelationshipMapNullRecordTest() {
        Id result = RelationshipMapService.getParentIdForRelationshipMap(null);
        System.assertEquals(null, result, 'Passing a Null record should return a null parent Id');
    }

    @isTest
    static void getParentIdForRelationshipMapNullTypeTest() {
        TestMockData md = new TestMockData();
        md.mockRelationshipMap.Type_Setting__c = null;
        md.mockRelationshipMap.pq_AccountPlanId__c = md.mockAccountPlanId;

        Id result = RelationshipMapService.getParentIdForRelationshipMap(md.mockRelationshipMap);

        System.assertEquals(null, result, 'Passing a record with a null type should return a null parent Id');
    }

    @isTest
    static void getParentIdForRelationshipMapNullAccountPlanIdTest() {
        TestMockData md = new TestMockData();
        md.mockRelationshipMap.Type_Setting__c = 'pqcrush__Account_Plan__c';
        md.mockRelationshipMap.pq_AccountPlanId__c = null;

        Id result = RelationshipMapService.getParentIdForRelationshipMap(md.mockRelationshipMap);

        System.assertEquals(
            null,
            result,
            'Passing a record with an Account Plan type setting and a null Account Plan Id should return a null parent Id'
        );
    }

    @isTest
    static void getParentIdForRelationshipMapHappyPathTest() {
        TestMockData md = new TestMockData();
        md.mockRelationshipMap.Type_Setting__c = 'pqcrush__Account_Plan__c';
        md.mockRelationshipMap.pq_AccountPlanId__c = md.mockAccountPlanId;

        Id result = RelationshipMapService.getParentIdForRelationshipMap(md.mockRelationshipMap);

        System.assertEquals(
            md.mockAccountPlanId,
            result,
            'Passing a record with an Account Plan type setting and an Account Plan Id should return the Account Plan Id'
        );
    }

    @isTest
    static void getParentIdForRelationshipMapIdNullIdTest() {
        TestMockData md = new TestMockData();
        RelationshipMapSelector mockSelector = md.mockRelationshipMapSelector;

        Id result = RelationshipMapService.getParentIdForRelationshipMapId(null);

        System.assertEquals(null, result, 'Passing a Null Id should return a null parent Id');
        ((RelationshipMapSelector) md.mocks.verify(mockSelector, 0)).selectByIds((Set<Id>) fflib_Match.anyObject());
    }

    @isTest
    static void getParentIdForRelationshipMapIdWrongObjectIdTest() {
        TestMockData md = new TestMockData();
        RelationshipMapSelector mockSelector = md.mockRelationshipMapSelector;

        Id result = RelationshipMapService.getParentIdForRelationshipMapId(
            fflib_IDGenerator.generate(User.SObjectType)
        );

        System.assertEquals(null, result, 'Passing an Id for the wrong object should return a null parent Id');
        ((RelationshipMapSelector) md.mocks.verify(mockSelector, 0)).selectByIds((Set<Id>) fflib_Match.anyObject());
    }

    @isTest
    static void getParentIdForRelationshipMapIdNoRecordTest() {
        TestMockData md = new TestMockData();
        RelationshipMapSelector mockSelector = md.mockRelationshipMapSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<pqcrush__Relationship_Map__c>());
        md.mocks.stopStubbing();

        Id result = RelationshipMapService.getParentIdForRelationshipMapId(md.mockRelationshipMapId);

        System.assertEquals(
            null,
            result,
            'Passing an Id for a record that does not exist should return a null parent Id'
        );
    }

    @isTest
    static void getParentIdForRelationshipMapIdNullTypeTest() {
        TestMockData md = new TestMockData();
        RelationshipMapSelector mockSelector = md.mockRelationshipMapSelector;
        md.mockRelationshipMap.Type_Setting__c = null;
        md.mockRelationshipMap.pq_AccountPlanId__c = md.mockAccountPlanId;

        md.mocks.startStubbing();
        md.mocks.when(mockSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<pqcrush__Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.stopStubbing();

        Id result = RelationshipMapService.getParentIdForRelationshipMapId(md.mockRelationshipMapId);

        System.assertEquals(null, result, 'Passing an Id for a record with a null type should return a null parent Id');
    }

    @isTest
    static void getParentIdForRelationshipMapIdNullAccountPlanIdTest() {
        TestMockData md = new TestMockData();
        RelationshipMapSelector mockSelector = md.mockRelationshipMapSelector;
        md.mockRelationshipMap.Type_Setting__c = 'pqcrush__Account_Plan__c';
        md.mockRelationshipMap.pq_AccountPlanId__c = null;

        md.mocks.startStubbing();
        md.mocks.when(mockSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<pqcrush__Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.stopStubbing();

        Id result = RelationshipMapService.getParentIdForRelationshipMapId(md.mockRelationshipMapId);

        System.assertEquals(
            null,
            result,
            'Passing an Id for a record with an Account Plan type setting and a null Account Plan Id should return a null parent Id'
        );
    }

    @isTest
    static void getParentIdForRelationshipMapIdHappyPathTest() {
        TestMockData md = new TestMockData();
        RelationshipMapSelector mockSelector = md.mockRelationshipMapSelector;
        md.mockRelationshipMap.Type_Setting__c = 'pqcrush__Account_Plan__c';
        md.mockRelationshipMap.pq_AccountPlanId__c = md.mockAccountPlanId;

        md.mocks.startStubbing();
        md.mocks.when(mockSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<pqcrush__Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.stopStubbing();

        Id result = RelationshipMapService.getParentIdForRelationshipMapId(md.mockRelationshipMapId);

        System.assertEquals(
            md.mockAccountPlanId,
            result,
            'Passing an Id for a record with an Account Plan type setting and an Account Plan Id should return the Account Plan Id'
        );
    }
}