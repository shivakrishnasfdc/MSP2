@isTest
private class MatrixMemberAdditionalFieldTest {
    @isTest
    static void initializedTest() {
        String name = 'name1';
        String label = 'label1';
        String type = 'type1';
        Object value = null;

        MatrixMemberAdditionalField result = new MatrixMemberAdditionalField(name, label, type, value);
        System.assertEquals(name, result.name);
        System.assertEquals(label, result.label);
        System.assertEquals(type, result.type);
        System.assertEquals(value, result.value);
    }

    @isTest
    static void initializedTest2() {
        String name = 'name1';
        String label = 'label1';
        String type = 'type1';
        Object value = null;
        String valueDisplay = 'hey';

        MatrixMemberAdditionalField result = new MatrixMemberAdditionalField(name, label, type, value, valueDisplay);
        System.assertEquals(name, result.name);
        System.assertEquals(label, result.label);
        System.assertEquals(type, result.type);
        System.assertEquals(value, result.value);
        System.assertEquals(valueDisplay, result.valueDisplay);
    }
}