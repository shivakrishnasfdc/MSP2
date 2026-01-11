@isTest
private class LightningSelectOptionTest {
    public static final String VALUE = 'value';
    public static final String LABEL = 'label';

    @isTest
    static void itShouldConstructWithStringAndLabelProperly() {
        // Given
        LightningSelectOption option = new LightningSelectOption(VALUE, LABEL);

        // Then
        System.assertEquals(VALUE, option.value);
        System.assertEquals(LABEL, option.label);
        System.assertEquals(false, option.disabled);
        System.assertEquals(false, option.escapeItem);
    }

    @isTest
    static void itShouldConstructWithStringLabelAndIsDisabledProperly() {
        // Given
        LightningSelectOption option = new LightningSelectOption(VALUE, LABEL, true);

        // Then
        System.assertEquals(VALUE, option.value);
        System.assertEquals(LABEL, option.label);
        System.assertEquals(true, option.disabled);
        System.assertEquals(false, option.escapeItem);
    }
}