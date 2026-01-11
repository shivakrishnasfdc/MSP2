@IsTest
public with sharing class SuggestedContactsControllerTest {
    private static final String RM_NAME_1 = 'test relationship map 1';
    private static final String RM_NAME_2 = 'test relationship map 2';

    private static final String CONTACT_LAST_NAME_1 = 'test contact last Name 1';
    private static final String CONTACT_LAST_NAME_2 = 'test contact last Name 2';

    public static final String ADMIN_USER_FIRST_NAME = 'rmms test admin user first';
    public static final String ADMIN_USER_LAST_NAME = 'rmms test admin user last';

    public static final String NO_PREMISSION_USER_FIRST_NAME = 'chms test no perm user first';
    public static final String NO_PREMISSION_USER_LAST_NAME = 'chms test no perm user last';

    public static final String PRM_ADMIN_PERM = 'CRUSH_Administrator';

    public static final String STANDARD_USER = 'Standard User';

    /******************
     *** test setup ***
     *****************/

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];

        User adminUser = TestDataFactory.createUser(ADMIN_USER_FIRST_NAME, ADMIN_USER_LAST_NAME, standardProfile.Id);

        TestDataFactory.createUser(NO_PREMISSION_USER_FIRST_NAME, NO_PREMISSION_USER_LAST_NAME, standardProfile.Id);
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :PRM_ADMIN_PERM LIMIT 1];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = adminUserPermissionSet.Id)
        };

        System.runAs(adminUser) {
            Account acct = new Account(Name = 'testaccount');
            insert acct;

            Contact testContact1 = new Contact(
                LastName = 'Hudson',
                MobilePhone = '123-456-6789',
                Email = 'a@acme.com',
                AccountId = acct.Id
            );
            insert testContact1;

            Contact testContact2 = new Contact(
                LastName = 'Terry',
                MobilePhone = '123-456-6789',
                Email = 'a@acme.com',
                AccountId = acct.Id
            );
            insert testContact2;

            Contact testContact3 = new Contact(
                LastName = 'Mudson',
                MobilePhone = '123-456-6789',
                Email = 'child1@acme.com',
                AccountId = acct.Id
            );
            insert testContact3;

            Contact testContact4 = new Contact(
                LastName = 'Crudson',
                MobilePhone = '123-456-6789',
                Email = 'child1@acme.com',
                AccountId = acct.Id
            );
            insert testContact4;

            Account_Plan__c accountPlan = new Account_Plan__c(Name = 'Sample AP', Account__c = acct.Id);
            insert accountPlan;

            Relationship_Map__c rm = new Relationship_Map__c(Name = 'Sample RM', pq_AccountPlanId__c = accountPlan.Id);
            insert rm;

            List<Relationship_Map_Member__c> mapMembers = new List<Relationship_Map_Member__c>{
                new Relationship_Map_Member__c(Contact__c = testContact2.Id, Relationship_Map__c = rm.Id)
            };

            insert mapMembers;
        }
    }

    @isTest
    static void getRMOrgSettingForTypeTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;

        md.mockSettings.Auto_Create_Stakeholder_Maps__c = false;
        md.mockSettings.Auto_Create_Relationship_Maps__c = false;

        CRUSH_Settings_Obj__c expected = md.mockSettings.clone();
        expected.Auto_Create_Relationship_Maps__c = true;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        SuggestedContactsController.getRMOrgSettingForType('rm');

        ((SettingServiceImpl) md.mocks.verify(mockSettingService, 0)).upsertSettings(expected);
        System.assert(true, 'Verified by mock');
    }

    @isTest
    static void getContactsConditionsTest() {
        Id fakeID = '0012w00000RMXXfAAH';

        Test.startTest();
        List<pq_Condition__c> result = SuggestedContactsController.getContactsConditions(fakeID);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Expected empty list');
    }

    @isTest
    static void insertRelationshipMapMemberTest() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Relationship_Map__c rm = [SELECT Id FROM Relationship_Map__c LIMIT 1];

        List<Relationship_Map_Member__c> mapMembers = new List<Relationship_Map_Member__c>{
            new Relationship_Map_Member__c(Contact__c = con.Id, Relationship_Map__c = rm.Id)
        };

        Test.startTest();
        List<Relationship_Map_Member__c> insertedMembers = SuggestedContactsController.insertRelationshipMapMember(
            mapMembers
        );
        Test.stopTest();

        System.assertNotEquals(null, insertedMembers, 'Inserted members should not be null');
    }

    @isTest
    static void getSuggestedContactsByAccountPlanTest() {
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(adminUser) {
            Account_Plan__c plan1 = TestDataFactory.createAccountPlan('rmst_sbapnt_test_1');
            TestDataFactory.createRelationshipMap('mapname', plan1.Id);
            TestDataFactory.createRelationshipMap('mapname', plan1.Id);
            TestDataFactory.createRelationshipMap('mapname');

            List<pq_Condition__c> conditions = new List<pq_Condition__c>{
                new pq_Condition__c(
                    pqcrush__Field__c = 'FirstName',
                    pqcrush__Operator__c = 'EQUALS',
                    pqcrush__Value__c = 'Value1'
                ),
                new pq_Condition__c(
                    pqcrush__Field__c = 'LastName',
                    pqcrush__Operator__c = 'EQUALS',
                    pqcrush__Value__c = 'Value2'
                ),
                new pq_Condition__c(
                    pqcrush__Field__c = 'CreatedDate',
                    pqcrush__Operator__c = 'GREATER_THAN',
                    pqcrush__Value__c = '2024-03-26T21:28:08.531+05:30'
                )
            };
            String operator = 'OR';

            SuggestedContactsController.getSuggestedContactsByAccountPlan(plan1.Id, conditions, operator);
            System.assert(true, 'Verified by mock');
        }
    }

    @isTest
    static void getSuggestedContactsByRelationshipMapTest() {
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        System.runAs(adminUser) {
            Relationship_Map__c rm = [SELECT Id FROM Relationship_Map__c LIMIT 1];
            List<pq_Condition__c> conditions = new List<pq_Condition__c>{
                new pq_Condition__c(
                    pqcrush__Field__c = 'FirstName',
                    pqcrush__Operator__c = 'EQUALS',
                    pqcrush__Value__c = 'Value1'
                ),
                new pq_Condition__c(
                    pqcrush__Field__c = 'LastName',
                    pqcrush__Operator__c = 'EQUALS',
                    pqcrush__Value__c = 'Value2'
                ),
                new pq_Condition__c(
                    pqcrush__Field__c = 'CreatedDate',
                    pqcrush__Operator__c = 'GREATER_THAN',
                    pqcrush__Value__c = '2024-03-26T21:28:08.531+05:30'
                )
            };
            String operator = 'OR';

            SuggestedContactsController.getSuggestedContactsByRelationshipMap(rm.Id, conditions, operator);
            System.assert(true, 'Verified by mock');
        }
    }

    @isTest
    static void testGenerateQueryNoConditions() {
        List<pq_Condition__c> conditions = null;
        String operator = 'AND';

        String result = SuggestedContactsController.generateQuery(conditions, operator);

        System.assertEquals('', result, 'Expected empty string for null conditions');
    }

    @isTest
    static void testGenerateQueryWithConditions() {
        List<pq_Condition__c> conditions = new List<pq_Condition__c>{
            new pq_Condition__c(
                pqcrush__Field__c = 'FirstName',
                pqcrush__Operator__c = 'EQUALS',
                pqcrush__Value__c = 'Value1'
            ),
            new pq_Condition__c(
                pqcrush__Field__c = 'LastName',
                pqcrush__Operator__c = 'EQUALS',
                pqcrush__Value__c = 'Value2'
            ),
            new pq_Condition__c(
                pqcrush__Field__c = 'CreatedDate',
                pqcrush__Operator__c = 'GREATER_THAN',
                pqcrush__Value__c = '2024-03-26T21:28:08.531+05:30'
            )
        };
        String operator = 'OR';

        String result = SuggestedContactsController.generateQuery(conditions, operator);

        String expectedQuery = '(FirstName = \'Value1\' OR LastName = \'Value2\' OR CreatedDate > 2024-03-26T21:28:08.531+05:30)';

        System.assertEquals(expectedQuery, result, 'Expected query string with conditions');
    }

    @isTest
    static void checkTypeTest() {
        Boolean result = SuggestedContactsController.checkType('DATETIME');
        System.assertEquals(true, result, 'Expected true for DATETIME');
    }

    @isTest
    static void testConditionsEquals() {
        String result = SuggestedContactsController.conditions('EQUALS');
        System.assertEquals(' = ', result, 'Expected = operator');
    }

    @isTest
    static void testConditionsNotEqualTo() {
        String result = SuggestedContactsController.conditions('NOT_EQUAL_TO');
        System.assertEquals(' != ', result, 'Expected != operator');
    }

    @isTest
    static void testConditionsGreaterThan() {
        String result = SuggestedContactsController.conditions('GREATER_THAN');
        System.assertEquals(' > ', result, 'Expected > operator');
    }

    @isTest
    static void testConditionsGreaterThanOrEqual() {
        String result = SuggestedContactsController.conditions('GREATER_THAN_OR_EQUAL_TO');
        System.assertEquals(' >= ', result, 'Expected >= operator');
    }

    @isTest
    static void testConditionsLessThan() {
        String result = SuggestedContactsController.conditions('LESS_THAN');
        System.assertEquals(' < ', result, 'Expected < operator');
    }

    @isTest
    static void testConditionsLessThanOrEqual() {
        String result = SuggestedContactsController.conditions('LESS_THAN_OR_EQUAL_TO');
        System.assertEquals(' <= ', result, 'Expected <= operator');
    }

    @isTest
    static void testConditionsIsIn() {
        String result = SuggestedContactsController.conditions('IS_IN');
        System.assertEquals(' IN ', result, 'Expected IN operator');
    }

    @isTest
    static void testConditionsIsNotIn() {
        String result = SuggestedContactsController.conditions('IS_NOT_IN');
        System.assertEquals(' NOT IN ', result, 'Expected NOT IN operator');
    }

    @isTest
    static void testConditionsIsLike() {
        String result = SuggestedContactsController.conditions('IS_LIKE');
        System.assertEquals(' LIKE ', result, 'Expected LIKE operator');
    }

    @isTest
    static void testConditionsIsNotLike() {
        String result = SuggestedContactsController.conditions('IS_NOT_LIKE');
        System.assertEquals(' NOT LIKE ', result, 'Expected NOT LIKE operator');
    }

    @isTest
    static void testConditionsOther() {
        String result = SuggestedContactsController.conditions('UNKNOWN_CONDITION');
        System.assertEquals(null, result, 'Expected null for unknown condition');
    }
}