@isTest
private class ObjectUpdatibilityTest {
    @isTest
    static void constructorTest() {
        String name = 'Third Time';
        Map<String, Boolean> fields = new Map<String, Boolean>();

        fields.put('LOL', true);
        fields.put('Honey', false);

        ObjectUpdatibility result = new ObjectUpdatibility(name, fields);

        System.assertEquals(name, result.name);
        System.assertEquals(fields.keySet().size(), result.fields.keySet().size());

        for (String key : fields.keySet()) {
            System.assert(result.fields.containsKey(key));
            System.assertEquals(fields.get(key), result.fields.get(key));
        }
    }
}