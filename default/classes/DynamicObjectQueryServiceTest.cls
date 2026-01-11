@IsTest
public with sharing class DynamicObjectQueryServiceTest {
    public static final String ACCOUNT1_NAME = 'DOQST Account Test1';
    public static final String ACCOUNT2_NAME = 'DOQST Account Test2';
    public static final String ACCOUNT3_NAME = 'aaaDOQST Account Test3';

    @testSetup
    static void testSetup() {
        List<Account> accountsList = new List<Account>{
            new Account(Name = ACCOUNT1_NAME),
            new Account(Name = ACCOUNT2_NAME),
            new Account(Name = ACCOUNT3_NAME)
        };
        insert accountsList;
    }

    @IsTest
    public static void querySObjectWithTypeAndIdSObjTypeTest() {
        Account account1 = [SELECT Id FROM Account WHERE Name = :ACCOUNT1_NAME];

        SObject result = DynamicObjectQueryService.querySObjectWithTypeAndId(Account.sObjectType, account1.Id, null);

        System.assertNotEquals(null, result, 'Should find the account if user created it');
        System.assertEquals(account1.Id, result.Id, 'Account should be the correct account');

        result = DynamicObjectQueryService.querySObjectWithTypeAndId(
            Account.sObjectType,
            account1.Id,
            new Set<String>{ 'Name' }
        );

        System.assertNotEquals(null, result, 'Should find the account if user created it');
        System.assertEquals(account1.Id, result.Id, 'Account should be the correct account');
        System.assertEquals(ACCOUNT1_NAME, result.get('Name'), 'Name should match since it was queried');

        result = DynamicObjectQueryService.querySObjectWithTypeAndId(Account.sObjectType, null, null);

        System.assertEquals(null, result, 'Should not find an account if null passed');

        result = DynamicObjectQueryService.querySObjectWithTypeAndId(
            Account.sObjectType,
            fflib_IDGenerator.generate(Account.SObjectType),
            null
        );

        System.assertEquals(null, result, 'Should not find an account if fake Id passed');
    }

    @IsTest
    public static void querySObjectWithTypeAndIdDescribeSObjectResultTest() {
        Account account1 = [SELECT Id FROM Account WHERE Name = :ACCOUNT1_NAME];

        SObject result = DynamicObjectQueryService.querySObjectWithTypeAndId(
            Account.sObjectType.getDescribe(),
            account1.Id,
            null
        );

        System.assertNotEquals(null, result, 'Should find the account if user created it');
        System.assertEquals(account1.Id, result.Id, 'Account should be the correct account');

        result = DynamicObjectQueryService.querySObjectWithTypeAndId(
            Account.sObjectType.getDescribe(),
            account1.Id,
            new Set<String>{ 'Name' }
        );

        System.assertNotEquals(null, result, 'Should find the account if user created it');
        System.assertEquals(account1.Id, result.Id, 'Account should be the correct account');
        System.assertEquals(ACCOUNT1_NAME, result.get('Name'), 'Name should match since it was queried');

        result = DynamicObjectQueryService.querySObjectWithTypeAndId(Account.sObjectType.getDescribe(), null, null);

        System.assertEquals(null, result, 'Should not find an account if null passed');

        result = DynamicObjectQueryService.querySObjectWithTypeAndId(
            Account.sObjectType.getDescribe(),
            fflib_IDGenerator.generate(Account.SObjectType),
            null
        );

        System.assertEquals(null, result, 'Should not find an account if fake Id passed');
    }

    @IsTest
    public static void querySObjectWithTypeAndIdObjectNameStringTest() {
        Account account1 = [SELECT Id FROM Account WHERE Name = :ACCOUNT1_NAME];

        SObject result = DynamicObjectQueryService.querySObjectWithTypeAndId('Account', account1.Id, null);

        System.assertNotEquals(null, result, 'Should find the account if user created it');
        System.assertEquals(account1.Id, result.Id, 'Account should be the correct account');

        result = DynamicObjectQueryService.querySObjectWithTypeAndId('Account', account1.Id, new Set<String>{ 'Name' });

        System.assertNotEquals(null, result, 'Should find the account if user created it');
        System.assertEquals(account1.Id, result.Id, 'Account should be the correct account');
        System.assertEquals(ACCOUNT1_NAME, result.get('Name'), 'Name should match since it was queried');

        result = DynamicObjectQueryService.querySObjectWithTypeAndId('Account', null, null);

        System.assertEquals(null, result, 'Should not find an account if null passed');

        result = DynamicObjectQueryService.querySObjectWithTypeAndId(
            'Account',
            fflib_IDGenerator.generate(Account.SObjectType),
            null
        );

        System.assertEquals(null, result, 'Should not find an account if fake Id passed');
    }

    @IsTest
    public static void querySObjectListWithTypeAndFieldsObjectNameStringTest() {
        List<SObject> result = DynamicObjectQueryService.querySObjectListWithTypeAndFields('Account', null, null);

        System.assertNotEquals(
            null,
            result,
            'Should find the account list if user created it even without select fields or sorting'
        );
        System.assertEquals(3, result.size(), 'Should have the correct number of accounts');

        result = DynamicObjectQueryService.querySObjectListWithTypeAndFields(
            'Account',
            new Set<String>{ 'Name' },
            null
        );

        System.assertNotEquals(
            null,
            result,
            'Should find the account list if user created it even without select fields or sorting'
        );
        System.assertEquals(3, result.size(), 'Should have the correct number of accounts');
        System.assertNotEquals(null, result[0].get('Name'), 'Name should be returned since it was queried');

        result = DynamicObjectQueryService.querySObjectListWithTypeAndFields(
            'Account',
            new Set<String>{ 'Name' },
            'Name'
        );

        System.assertNotEquals(
            null,
            result,
            'Should find the account list if user created it even without select fields or sorting'
        );
        System.assertEquals(3, result.size(), 'Should have the correct number of accounts');
        System.assertEquals(
            ACCOUNT3_NAME,
            result[0].get('Name'),
            'Name should match since sort order was passed since it was queried'
        );
    }

    @IsTest
    public static void querySObjectListWithTypeAndFieldsObjectTest() {
        List<SObject> result = DynamicObjectQueryService.querySObjectListWithTypeAndFields(
            Account.sObjectType,
            null,
            null
        );

        System.assertNotEquals(
            null,
            result,
            'Should find the account list if user created it even without select fields or sorting'
        );
        System.assertEquals(3, result.size(), 'Should have the correct number of accounts');

        result = DynamicObjectQueryService.querySObjectListWithTypeAndFields(
            Account.sObjectType,
            new Set<String>{ 'Name' },
            null
        );

        System.assertNotEquals(
            null,
            result,
            'Should find the account list if user created it even without select fields or sorting'
        );
        System.assertEquals(3, result.size(), 'Should have the correct number of accounts');
        System.assertNotEquals(null, result[0].get('Name'), 'Name should be returned since it was queried');

        result = DynamicObjectQueryService.querySObjectListWithTypeAndFields(
            Account.sObjectType,
            new Set<String>{ 'Name' },
            'Name'
        );

        System.assertNotEquals(
            null,
            result,
            'Should find the account list if user created it even without select fields or sorting'
        );
        System.assertEquals(3, result.size(), 'Should have the correct number of accounts');
        System.assertEquals(
            ACCOUNT3_NAME,
            result[0].get('Name'),
            'Name should match since sort order was passed since it was queried'
        );
    }

    @IsTest
    public static void querySObjectListWithIdsAndFieldsNullEmptyIdsTest() {
        List<SObject> result = DynamicObjectQueryService.querySObjectListWithIdsAndFields(
            null,
            new Set<String>{ 'Name', 'Id' }
        );

        System.assertEquals(0, result.size(), 'Should not find an account list if null passed');

        result = DynamicObjectQueryService.querySObjectListWithIdsAndFields(
            new List<Id>(),
            new Set<String>{ 'Name', 'Id' }
        );

        System.assertEquals(0, result.size(), 'Should not find an account list if empty passed');
    }

    @IsTest
    public static void querySObjectListWithIdsAndFieldsNoFieldsTest() {
        Account account1 = [SELECT Id FROM Account WHERE Name = :ACCOUNT1_NAME];

        List<SObject> result = DynamicObjectQueryService.querySObjectListWithIdsAndFields(
            new List<Id>{ account1.Id },
            null
        );

        System.assertNotEquals(
            null,
            result,
            'Should find the account list if user created it even without select fields'
        );
        System.assertEquals(1, result.size(), 'Should have the correct number of accounts');
        System.assertEquals(account1.Id, result[0].Id, 'Account should be the correct account');
    }

    @IsTest
    public static void querySObjectListWithIdsAndFieldsHappyPathTest() {
        Account account1 = [SELECT Id FROM Account WHERE Name = :ACCOUNT1_NAME];

        List<SObject> result = DynamicObjectQueryService.querySObjectListWithIdsAndFields(
            new List<Id>{ account1.Id },
            new Set<String>{ 'Name' }
        );

        System.assertEquals(1, result.size(), 'Should have the correct number of accounts');
        System.assertEquals(account1.Id, result[0].Id, 'Account should be the correct account');
        System.assertEquals(ACCOUNT1_NAME, result[0].get('Name'), 'Name should match since it was queried');
    }

    @IsTest
    public static void querySObjectListWithIdsAndFieldsMultipleTest() {
        Account account1 = [SELECT Id FROM Account WHERE Name = :ACCOUNT1_NAME];
        Account account2 = [SELECT Id FROM Account WHERE Name = :ACCOUNT2_NAME];
        Account account3 = [SELECT Id FROM Account WHERE Name = :ACCOUNT3_NAME];

        List<SObject> result = DynamicObjectQueryService.querySObjectListWithIdsAndFields(
            new List<Id>{ account1.Id, account2.Id, account3.Id },
            new Set<String>{ 'Name' }
        );

        System.assertEquals(3, result.size(), 'Should have the correct number of accounts');
    }

    @IsTest
    public static void querySObjectListWithIdsAndFieldsPartialMatchTest() {
        Account account1 = [SELECT Id FROM Account WHERE Name = :ACCOUNT1_NAME];
        Id fakeId = fflib_IDGenerator.generate(Account.SObjectType);

        List<SObject> result = DynamicObjectQueryService.querySObjectListWithIdsAndFields(
            new List<Id>{ account1.Id, fakeId },
            new Set<String>{ 'Name' }
        );

        System.assertEquals(1, result.size(), 'Should have the correct number of accounts');
    }
}