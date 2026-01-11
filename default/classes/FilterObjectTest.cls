@isTest
private class FilterObjectTest {
    public static final String LABEL = 'testFilter';
    public static final String VALUE = 'testValue';
    public static final String FIELD = 'testField';
    public static final boolean ISSELECTED = true;
    public static final boolean ISDEFAULT = true;

    @isTest
    static void itShouldConstructProperlyWithValidParameters() {
        // Given
        FilterObject filter = new FilterObject(LABEL, VALUE, FIELD, ISSELECTED, ISDEFAULT);

        // Then
        System.assertEquals(LABEL, filter.label);
        System.assertEquals(VALUE, filter.value);
        System.assertEquals(FIELD, filter.field);
        System.assertEquals(ISSELECTED, filter.isSelected);
        System.assertEquals(ISDEFAULT, filter.isDefault);
    }
}