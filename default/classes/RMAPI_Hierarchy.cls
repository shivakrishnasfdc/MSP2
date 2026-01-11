@RestResource(urlMapping='/rmapi_hierarchy/*')
global with sharing class RMAPI_Hierarchy {
    // RMAPI_Hierarchy
    //   -> Updates ReportsTo hierarchy data
    // POST  /services/apexrest/pqcrush/rmapi_hierarchy/

    // @HttpGet
    // @HttpDelete
    // @HttpPut

    @HttpPost
    global static Boolean doPost(String graphDataJsonString, String mapId) {
        GraphDataController.updateReportsTo(graphDataJsonString, UtilityForString.getIdForString(mapId));
        return true;
    }
}