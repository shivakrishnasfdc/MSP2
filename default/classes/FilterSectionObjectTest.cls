@isTest
private class FilterSectionObjectTest {
    public static final String LABEL = 'testFilterSection';
    public static List<FilterObject> filters = new List<FilterObject>();
    public static final Boolean ISSINGLESELECT = true;

    @testSetup
    static void testSetup() {
        filters.add(new FilterObject('All', 'All', 'OwnerId', true, true));
        filters.add(new FilterObject('Mine', 'Mine', 'OwnerId', false, false));
    }

    @isTest
    static void itShouldConstructProperlyWithValidParameters() {
        // Given
        FilterSectionObject filterSection = new FilterSectionObject(LABEL, filters, ISSINGLESELECT);

        // Then
        System.assertEquals(LABEL, filterSection.label);
        System.assertEquals(filters, filterSection.filters);
        System.assertEquals(ISSINGLESELECT, filterSection.isSingleSelect);
    }
}