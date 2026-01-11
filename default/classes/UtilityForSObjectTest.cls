@isTest
private class UtilityForSObjectTest {
    @isTest
    static void getFieldTest() {
        // Given
        Contact c = new Contact(LastName = 'last', Title = 'CEO');

        // When
        Object result = UtilityForSObject.getFieldValue(c, 'Title');

        // Then
        System.assertEquals('CEO', (String) result);
    }

    @isTest
    static void getFieldTest2() {
        // Given
        Contact c = new Contact(LastName = 'last', Title = 'CEO');

        // When
        Object result = UtilityForSObject.getFieldValue(c, 'FirstName');

        // Then
        System.assertEquals(null, result);
    }

    @isTest
    static void getPicklistSelectOptionsNullTest() {
        List<SelectOption> result = UtilityForSObject.getPicklistSelectOptions(null, null);
        System.assertNotEquals(null, result, 'Should return a result');
        System.assertEquals(0, result.size(), 'result should be empty if null values passed');

        result = UtilityForSObject.getPicklistSelectOptions('Account', null);
        System.assertNotEquals(null, result, 'Should return a result');
        System.assertEquals(0, result.size(), 'result should be empty if null values passed');

        result = UtilityForSObject.getPicklistSelectOptions(null, 'Name');
        System.assertNotEquals(null, result, 'Should return a result');
        System.assertEquals(0, result.size(), 'result should be empty if null values passed');
    }

    @isTest
    static void getPicklistSelectOptionsBadValuesTest() {
        List<SelectOption> result = UtilityForSObject.getPicklistSelectOptions(
            'Account',
            'Not_A_Real_Field_pqtesting__c'
        );
        System.assertNotEquals(null, result, 'Should return a result');
        System.assertEquals(0, result.size(), 'result should be empty if bad field passed');

        result = UtilityForSObject.getPicklistSelectOptions('Not_A_Real_Object_pqtesting__c', 'Name');
        System.assertNotEquals(null, result, 'Should return a result');
        System.assertEquals(0, result.size(), 'result should be empty if bad object passed');

        result = UtilityForSObject.getPicklistSelectOptions('Account', 'Name');
        System.assertNotEquals(null, result, 'Should return a result');
        System.assertEquals(0, result.size(), 'result should be empty if not a picklist field');
    }

    @isTest
    static void getPicklistSelectOptionsHappyTest() {
        //Given
        Integer count = 0;
        for (Schema.PicklistEntry entry : Account.Type.getDescribe().getPicklistValues()) {
            if (entry.isActive()) {
                count++;
            }
        }
        List<SelectOption> result = UtilityForSObject.getPicklistSelectOptions('Account', 'Type');
        System.assertNotEquals(null, result, 'Should return a result');
        System.assertEquals(count, result.size(), 'result should match the number of active picklist entries');
    }

    @isTest
    static void getPicklistSelectOptionsMapNullTest() {
        List<Map<String, String>> result = UtilityForSObject.getPicklistSelectOptionsMap(null, null);
        System.assertNotEquals(null, result, 'Should return a result');
        System.assertEquals(0, result.size(), 'result should be empty if null values passed');

        result = UtilityForSObject.getPicklistSelectOptionsMap('Account', null);
        System.assertNotEquals(null, result, 'Should return a result');
        System.assertEquals(0, result.size(), 'result should be empty if null values passed');

        result = UtilityForSObject.getPicklistSelectOptionsMap(null, 'Name');
        System.assertNotEquals(null, result, 'Should return a result');
        System.assertEquals(0, result.size(), 'result should be empty if null values passed');
    }

    @isTest
    static void getPicklistSelectOptionsMapBadValuesTest() {
        List<Map<String, String>> result = UtilityForSObject.getPicklistSelectOptionsMap(
            'Account',
            'Not_A_Real_Field_pqtesting__c'
        );
        System.assertNotEquals(null, result, 'Should return a result');
        System.assertEquals(0, result.size(), 'result should be empty if bad field passed');

        result = UtilityForSObject.getPicklistSelectOptionsMap('Not_A_Real_Object_pqtesting__c', 'Name');
        System.assertNotEquals(null, result, 'Should return a result');
        System.assertEquals(0, result.size(), 'result should be empty if bad object passed');

        result = UtilityForSObject.getPicklistSelectOptionsMap('Account', 'Name');
        System.assertNotEquals(null, result, 'Should return a result');
        System.assertEquals(0, result.size(), 'result should be empty if not a picklist field');
    }

    @isTest
    static void getPicklistSelectOptionsMapHappyTest() {
        //Given
        Integer count = 0;
        for (Schema.PicklistEntry entry : Account.Type.getDescribe().getPicklistValues()) {
            if (entry.isActive()) {
                count++;
            }
        }
        List<Map<String, String>> result = UtilityForSObject.getPicklistSelectOptionsMap('Account', 'Type');
        System.assertNotEquals(null, result, 'Should return a result');
        System.assertEquals(count, result.size(), 'result should match the number of active picklist entries');
    }

    @isTest
    static void getOrderedPicklistValuesTest() {
        List<String> result = UtilityForSObject.getOrderedPicklistValues(null, null);
        System.assertEquals(0, result.size());

        result = UtilityForSObject.getOrderedPicklistValues('Account', null);
        System.assertEquals(0, result.size());

        result = UtilityForSObject.getOrderedPicklistValues(null, 'Name');
        System.assertEquals(0, result.size());

        result = UtilityForSObject.getOrderedPicklistValues('', '');
        System.assertEquals(0, result.size());

        result = UtilityForSObject.getOrderedPicklistValues('Account', '');
        System.assertEquals(0, result.size());

        result = UtilityForSObject.getOrderedPicklistValues('', 'Name');
        System.assertEquals(0, result.size());

        result = UtilityForSObject.getOrderedPicklistValues('pqcrush__test_fake_object_for_tests__c', 'Name');
        System.assertEquals(0, result.size());

        result = UtilityForSObject.getOrderedPicklistValues('Account', 'pqcrush__test_fake_field_for_tests__c');
        System.assertEquals(0, result.size());

        List<Schema.PicklistEntry> entries = Account.Type.getDescribe().getPicklistValues();
        List<String> expected = new List<String>();
        for (Schema.PicklistEntry entry : entries) {
            if (entry.isActive()) {
                expected.add(entry.value);
            }
        }

        result = UtilityForSObject.getOrderedPicklistValues('Account', 'Type');
        System.assertEquals(expected, result);
    }
}