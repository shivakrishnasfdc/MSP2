@isTest
private class UtilityForStringTest {
    @isTest
    static void parseNameValueStringToMapTest() {
        // Given
        String str = 'name1:value1;name2:value2;name3:value3;';

        // When
        Map<String, String> result = UtilityForString.parseNameValueStringToMap(str);

        // Then
        System.assertEquals(3, result.keySet().size());
    }

    @isTest
    static void parseMapToNameValueStringTest() {
        // Given
        Map<String, String> mapToConvert = new Map<String, String>();
        mapToConvert.put('name1', 'value1');
        mapToConvert.put('name2', 'value2');
        mapToConvert.put('name3', 'value3');

        // When
        String result = UtilityForString.parseMapToNameValueString(mapToConvert);

        // Then
        System.assertEquals('name1:value1;name2:value2;name3:value3;', result);
    }

    @isTest
    static void compareObjectStringValueTest() {
        // Given
        Id testId = fflib_IDGenerator.generate(Contact.SObjectType);
        String testString = String.valueOf(testId);

        String a = 'a';
        String b = 'b';

        Id x = null;
        Id y = fflib_IDGenerator.generate(Contact.SObjectType);

        // When
        Boolean result1 = UtilityForString.compareObjectStringValue(testId, testString);
        Boolean result2 = UtilityForString.compareObjectStringValue(a, b);
        Boolean result3 = UtilityForString.compareObjectStringValue(x, y);

        // Then
        System.assertEquals(true, result1);
        System.assertEquals(false, result2);
        System.assertEquals(false, result3);
    }

    @isTest
    static void getIdForString() {
        // Given
        Id testId = fflib_IDGenerator.generate(Contact.SObjectType);

        // When
        Id result = UtilityForString.getIdForString(String.valueOf(testId));

        // Then
        System.assertEquals(testId, result);
    }

    @isTest
    static void buildStringFromMapTest() {
        // Given
        Map<String, Boolean> input = new Map<String, Boolean>();
        input.put('abc', true);
        input.put('def', false);
        input.put('ghi', true);
        input.put('jkl', false);

        // When
        String result = UtilityForString.buildStringFromMap(input);

        // Then
        System.assertEquals('abc,ghi', result);
    }
}