@RestResource(urlMapping='/rmapi_contact_search/*')
global with sharing class RMAPI_Contact_Search {
    // RMAPI_Contact_Search
    //   -> Get Contact Graph Data for Search Terms
    // POST  /services/apexrest/pqcrush/rmapi_contact_search/

    // ----------------------------------------------------

    @HttpPost
    global static GraphData doPost(String searchTerm, List<String> excludeIds, String accountId, String mapId) {
        return RelationshipMapMemberController.getContactGraphDataForSearchTerm(
            searchTerm,
            excludeIds,
            accountId,
            UtilityForString.getIdForString(mapId),
            'searchKey'
        );
    }
}