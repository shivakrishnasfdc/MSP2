@RestResource(urlMapping='/rmapi_maps/*')
global with sharing class RMAPI_Maps {
    // RMAPI_Maps
    //   -> Listing of available Relationship Maps for the caller
    // GET  /services/apexrest/pqcrush/rmapi_maps/

    @HttpGet
    global static List<pqcrush__Relationship_Map__c> doGet() {
        // Return listing of available maps for the caller
        // /services/apexrest/pqcrush/graphapi_rmlist
        // "SELECT Id,Name FROM pqcrush__Relationship_Map__c"

        return RelationshipMapSelector.newInstance().selectAll();
    }
}