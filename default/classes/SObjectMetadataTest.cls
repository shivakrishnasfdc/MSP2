@isTest
private class SObjectMetadataTest {
    @isTest
    static void newInstanceStringTest() {
        DescribeSobjectResult accountMeta = Account.sObjectType.getDescribe();
        SObjectMetadata result = new SObjectMetadata('Account');
        System.assertNotEquals(null, result, 'Should return an object');
        System.assertEquals(accountMeta.getName(), result.apiName);
        System.assertEquals(accountMeta.getLabel(), result.label);
    }

    @isTest
    static void newInstanceSObjTypeTest() {
        DescribeSobjectResult accountMeta = Account.sObjectType.getDescribe();
        SObjectMetadata result = new SObjectMetadata(Account.sObjectType);
        System.assertNotEquals(null, result, 'Should return an object');
        System.assertEquals(accountMeta.getName(), result.apiName);
        System.assertEquals(accountMeta.getLabel(), result.label);
    }

    @isTest
    static void newInstanceDesceribeTest() {
        DescribeSobjectResult accountMeta = Account.sObjectType.getDescribe();
        SObjectMetadata result = new SObjectMetadata(accountMeta);
        System.assertNotEquals(null, result, 'Should return an object');
        System.assertEquals(accountMeta.getName(), result.apiName);
        System.assertEquals(accountMeta.getLabel(), result.label);
    }

    @isTest
    static void compareToTest() {
        SObjectMetadata result1 = new SObjectMetadata('Account');
        SObjectMetadata result2 = new SObjectMetadata('Account');

        System.assertEquals(0, result1.compareTo(result2), 'should be the same');
        System.assertEquals(0, result2.compareTo(result1), 'should be the same');

        result1.label = 'aaa';
        result2.label = 'aab';

        System.assertEquals(-1, result1.compareTo(result2), 'should return -1 since result2 is greater');
        System.assertEquals(1, result2.compareTo(result1), 'should return 1 since result2 is greater');

        result1.label = 'zzz';
        result2.label = 'aaa';

        System.assertEquals(1, result1.compareTo(result2), 'should return 1 since result1 is greater');
        System.assertEquals(-1, result2.compareTo(result1), 'should return -1 since result1 is greater');
    }

    @isTest
    static void equalsTest() {
        SObjectMetadata result1 = new SObjectMetadata('Account');
        SObjectMetadata result2 = new SObjectMetadata('Account');

        System.assert(result1.equals(result2), 'should be the same');
        System.assert(result2.equals(result1), 'should be the same');

        result1.apiName = 'aaa';
        result2.apiName = 'zzz';

        System.assert(!result1.equals(result2), 'should not be the same');
        System.assert(!result2.equals(result1), 'should not be the same');

        System.assert(!result1.equals(null), 'should not equal null');
        System.assert(!result1.equals('Test'), 'should not equal a different type of object');
    }

    @isTest
    static void hashCodeTest() {
        SObjectMetadata result1 = new SObjectMetadata('Account');

        System.assertEquals(
            System.hashCode('Account'),
            result1.hashCode(),
            'should return the hash code of the api name'
        );

        result1.apiName = 'aaa';

        System.assertEquals(System.hashCode('aaa'), result1.hashCode(), 'should return the hash code of the api name');
    }
}