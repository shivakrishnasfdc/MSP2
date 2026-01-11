@isTest
private with sharing class UtilityForMapTest {
    @isTest
    static void convertMapTestNull() {

        Map<String, Object> input = new Map<String, Object>();

        Map<String, Decimal> result1 = UtilityForMap.convertMap(input);
        Map<String, Decimal> result2 = UtilityForMap.convertMap(null);

        System.assertEquals(0, result1.size());
        System.assertEquals(0, result2.size());

    }

    @isTest
    static void convertMapTest() {

        Map<String, Object> input = new Map<String, Object>();
        Decimal a = 4;
        Decimal b = 122;
        input.put('a', (Object) a);
        input.put('b', (Object) b);

        Map<String, Decimal> result = UtilityForMap.convertMap(input);

        System.assertEquals(a, result.get('a'));
        System.assertEquals(b, result.get('b'));
    }

    @isTest
    static void mergeDataTestNull() {

        Map<String, Decimal> empty = new Map<String, Decimal>();
        Map<String, Decimal> input = new Map<String, Decimal>();
        Decimal a = 4;
        Decimal b = 122;
        input.put('a', a);
        input.put('b', b);

        Map<String, Decimal> result1 = UtilityForMap.mergeData(null, null);
        Map<String, Decimal> result2 = UtilityForMap.mergeData(empty, empty);
        Map<String, Decimal> result3 = UtilityForMap.mergeData(null, empty);
        Map<String, Decimal> result4 = UtilityForMap.mergeData(empty, null);
        Map<String, Decimal> result5 = UtilityForMap.mergeData(input, empty);
        Map<String, Decimal> result6 = UtilityForMap.mergeData(empty, input);

        System.assertEquals(0, result1.size());
        System.assertEquals(0, result2.size());
        System.assertEquals(0, result3.size());
        System.assertEquals(0, result4.size());
        System.assertEquals(a, result5.get('a'));
        System.assertEquals(b, result5.get('b'));
        System.assertEquals(a, result6.get('a'));
        System.assertEquals(b, result6.get('b'));
    }

    @isTest
    static void mergeDataTest() {

        Map<String, Decimal> input1 = new Map<String, Decimal>();
        Map<String, Decimal> input2 = new Map<String, Decimal>();
        Decimal a = 4;
        Decimal b = 122;
        Decimal c = 104;
        Decimal d = 201;

        input1.put('a', a);
        input1.put('b', b);

        input2.put('c', c);
        input2.put('b', d);

        Map<String, Decimal> result1 = UtilityForMap.mergeData(input1, input2);

        System.assertEquals(a, result1.get('a'));
        System.assertEquals(c, result1.get('c'));
        System.assertEquals(b + d, result1.get('b'));
        System.assertEquals(3, result1.size());
    }
}