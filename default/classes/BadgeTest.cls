@isTest
private class BadgeTest {
    @isTest
    static void newInstanceTest() {
        Badge result = new Badge(null, null, null, null);
        System.assertNotEquals(null, result);
        System.assertEquals(null, result.id);
        System.assertEquals(null, result.geometryString);
        System.assertEquals(null, result.fill);
        System.assertEquals(null, result.bounded);
    }

    @isTest
    static void newInstanceTest2() {
        String id = 'a';
        String geometryString = 'b';
        String fill = 'c';
        Boolean bounded = true;

        Badge result = new Badge(id, geometryString, fill, bounded);

        System.assertNotEquals(null, result);
        System.assertEquals(id, result.id);
        System.assertEquals(geometryString, result.geometryString);
        System.assertEquals(fill, result.fill);
        System.assertEquals(bounded, result.bounded);
    }

    @isTest
    static void compareTest() {
        String geometryString = 'c';
        String fill = 'd';

        Badge result = new Badge('a', geometryString, fill, true);
        Badge result2 = new Badge('a', geometryString, fill, true);
        Badge result3 = new Badge('z', geometryString, fill, true);

        System.assert(result.equals(result2));
        System.assert(!result.equals(result3));
    }
}