@RestResource(urlMapping='/rmapi_user_search/*')
global with sharing class RMAPI_User_Search {
    // RMAPI_User_Search
    //   -> Get Contact Graph Data for Search Terms
    // POST  /services/apexrest/pqcrush/rmapi_user_search/
    // {"searchTerm":"jeff","excludeIds":[],"accountId":"","mapId":"a0R1D00000195b5UAA"}

    // ----------------------------------------------------

    @HttpPost
    global static GraphData doPost(String searchTerm, List<Id> excludeIds, List<String> queryFields, String mapId) {
        // Set<String> queryFieldSet = new Set<String>(queryFields);

        return GraphDataController.getUserGraphDataForSearchTerm(
            searchTerm,
            excludeIds,
            queryFields,
            UtilityForString.getIdForString(mapId),
            'searchKey'
        );
    }
}