@RestResource(urlMapping='/rmapi_map/*')
global with sharing class RMAPI_Map {
    // RMAPI_Map
    //   -> Instance of a Relationship Map
    // GET  /services/apexrest/pqcrush/rmapi_map/a0M1h000003CyGCEA0
    // PUT  /services/apexrest/pqcrush/rmapi_map/a0M1h000003CyGCEA0
    // POST /services/apexrest/pqcrush/rmapi_map/

    @HttpGet
    global static GraphData doGet() {
        // GET /services/apexrest/pqcrush/rmapi_map/a0M1h000003CyGCEA0
        // -> Get instance detail of a map

        Id hierarchyId = UtilityForUrl.getIdFromRequest(RestContext.request);
        GraphData result = RelationshipMapMemberController.getUserGraphDataForHierarchyId(hierarchyId);
        return result;
    }
}