@isTest
private class UtilityForUrlTest {
    @isTest
    static void getIdFromRequest() {
        // Given
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        String testUrl = 'http://test/someting/' + contactId;
        RestRequest req = new RestRequest();
        req.requestURI = testUrl;

        // When
        Id result = UtilityForUrl.getIdFromRequest(req);

        // Then
        System.assertEquals(contactId, result);
    }
}