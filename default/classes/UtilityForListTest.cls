@isTest
private with sharing class UtilityForListTest {
    @isTest
    private static void sliceTest() {
        List<String> stringData = new List<String>{ 'Banana', 'Orange', 'Lemon', 'Apple', 'Mango' };
        List<String> stringSliced = (List<String>) UtilityForList.slice(stringData, 1, 2);
        System.assertEquals(new List<String>{ 'Orange', 'Lemon' }, stringSliced, 'Sliced Array should match expected');

        List<Integer> integerData = new List<Integer>{ 0, 1, 2, 3 };
        List<Integer> integerSliced = (List<Integer>) UtilityForList.slice(integerData, 0, 7);
        System.assertEquals(
            integerData,
            integerSliced,
            'Sliced Array should not change if starting at zero and length longer than the original array'
        );

        integerSliced = (List<Integer>) UtilityForList.slice(integerData, 7, 7);
        System.assertEquals(
            new List<Integer>(),
            integerSliced,
            'Sliced Array should be empty if start index is beyond bounds'
        );

        integerSliced = (List<Integer>) UtilityForList.slice(integerData, -1, 7);
        System.assertEquals(
            integerData,
            integerSliced,
            'Sliced Array should not change if starting is negative and length longer than the original array'
        );

        integerSliced = (List<Integer>) UtilityForList.slice(integerData, -1, 2);
        System.assertEquals(new List<Integer>{ 0, 1 }, integerSliced, 'Negative start should be treated as zero start');

        integerSliced = (List<Integer>) UtilityForList.slice(integerData, 2, 3);
        System.assertEquals(new List<Integer>{ 2, 3 }, integerSliced, 'Length beyond end of array should be ignored');

        integerSliced = (List<Integer>) UtilityForList.slice(null, 2, 3);
        System.assertEquals(null, integerSliced, 'should return null if null array passed');

        integerSliced = (List<Integer>) UtilityForList.slice(integerData, null, 2);
        System.assertEquals(new List<Integer>{ 0, 1 }, integerSliced, 'Should treat null start index as 0');

        integerSliced = (List<Integer>) UtilityForList.slice(integerData, 1, null);
        System.assertEquals(new List<Integer>(), integerSliced, 'Should treat null length as 0');
    }

    @isTest
    private static void firstTest() {
        TestMockData md = new TestMockData();
        List<String> stringData = new List<String>{ 'Banana', 'Orange', 'Lemon', 'Apple', 'Mango' };
        List<Integer> integerData = new List<Integer>{ 0, 1, 2, 3 };
        List<SObject> objList = new List<SObject>{ md.mockContact, md.mockAccount, md.mockParentContact };

        System.assertEquals(null, UtilityForList.first(null), 'null list should return null');
        System.assertEquals(null, UtilityForList.first(new List<Integer>()), 'empty list should return null');
        System.assertEquals(
            null,
            UtilityForList.first(new List<String>{ null }),
            'null first in list should return null'
        );
        System.assertEquals('Banana', UtilityForList.first(stringData), 'String list should return first string');
        System.assertEquals(0, UtilityForList.first(integerData), 'integer list should return first integer');
        System.assertEquals(md.mockContact, UtilityForList.first(objList), 'SObject list should return first SObject');
    }

    @isTest
    private static void lastTest() {
        TestMockData md = new TestMockData();
        List<String> stringData = new List<String>{ 'Banana', 'Orange', 'Lemon', 'Apple', 'Mango' };
        List<Integer> integerData = new List<Integer>{ 0, 1, 2, 3 };
        List<SObject> objList = new List<SObject>{ md.mockContact, md.mockAccount, md.mockParentContact };

        System.assertEquals(null, UtilityForList.last(null), 'null list should return null');
        System.assertEquals(null, UtilityForList.last(new List<Integer>()), 'empty list should return null');
        System.assertEquals(
            null,
            UtilityForList.last(new List<String>{ null }),
            'null last in list should return null'
        );
        System.assertEquals('Mango', UtilityForList.last(stringData), 'String list should return last string');
        System.assertEquals(3, UtilityForList.last(integerData), 'integer list should return last integer');
        System.assertEquals(
            md.mockParentContact,
            UtilityForList.last(objList),
            'SObject list should return last SObject'
        );
    }
}