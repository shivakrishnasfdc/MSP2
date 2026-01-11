@RestResource(urlMapping='/rmapi_influencevalues/*')
global with sharing class RMAPI_InfluenceValues {
    // RMAPI_InfluenceValues
    //   -> Get the defined Influence values
    // GET   /services/apexrest/pqcrush/rmapi_influencevalues/

    // Wraps '@salesforce/apex/RelationshipMapMemberController.getInfluenceValues';
    // public static List<NameValuePair> getInfluenceValues()

    // ----------------------------------------------------

    @HttpGet
    global static List<NameValuePair> doGet() {
        // Id hierarchyId = UtilityForUrl.getIdFromRequest(RestContext.request);
        // List<InfluenceWrapper> result = RelationshipMapMemberController.getInfluenceByRelationshipMap(
        //     hierarchyId,
        //     null
        // );
        return new List<NameValuePair>();
    }
}