@isTest
private class FieldWrapperTest {
    @isTest
    static void newInstanceTest() {
        FieldWrapper result = new FieldWrapper();
        System.assertNotEquals(null, result);
        System.assertEquals(null, result.label);
        System.assertEquals(null, result.name);
        System.assertEquals(null, result.isOrgChartField);
        System.assertEquals(null, result.isRequired);
        System.assertEquals(null, result.isNameField);
        System.assertEquals(null, result.relatedFieldName);
    }

    @isTest
    static void newInstanceTest2() {
        String label = 'a';
        String name = 'b';
        Boolean isOrgChartField = true;
        Boolean isRequired = false;
        Boolean isNameField = true;
        String relatedFieldName = 'c';

        FieldWrapper result = new FieldWrapper(label, name, isOrgChartField, isRequired, isNameField, relatedFieldName);

        System.assertNotEquals(null, result);
        System.assertEquals(label, result.label);
        System.assertEquals(name, result.name);
        System.assertEquals(isOrgChartField, result.isOrgChartField);
        System.assertEquals(isRequired, result.isRequired);
        System.assertEquals(isNameField, result.isNameField);
        System.assertEquals(relatedFieldName, result.relatedFieldName);
    }

    @isTest
    static void compareTest() {
        String name = 'b';
        Boolean isOrgChartField = true;
        Boolean isRequired = false;
        Boolean isNameField = true;
        String relatedFieldName = 'c';

        FieldWrapper result = new FieldWrapper('a', name, isOrgChartField, isRequired, isNameField, relatedFieldName);
        FieldWrapper result2 = new FieldWrapper('a', name, isOrgChartField, isRequired, isNameField, relatedFieldName);
        FieldWrapper result3 = new FieldWrapper('z', name, isOrgChartField, isRequired, isNameField, relatedFieldName);

        if (result.compareTo(result2) == 0) {
            System.assert(true);
        }

        if (result.compareTo(result3) > 0) {
            System.assert(true);
        }

        if (result3.compareTo(result) < 0) {
            System.assert(true);
        }
    }
}