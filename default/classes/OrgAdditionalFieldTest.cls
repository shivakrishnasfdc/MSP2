@isTest
private class OrgAdditionalFieldTest {
    @isTest
    static void constructorTest() {
        String title = 'title A';
        String value = 'value A';
        Boolean isMainSection = true;
        String type = 'facebook';
        String apiName = 'test';

        OrgAdditionalField result = new OrgAdditionalField(apiName, title, value, isMainSection, type);

        System.assertEquals(title, result.title);
        System.assertEquals(value, result.value);
        System.assertEquals(isMainSection, result.isMainSection);
        System.assertEquals(type, result.type);
        System.assertEquals(apiName, result.apiName);
    }
}