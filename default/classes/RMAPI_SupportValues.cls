@RestResource(urlMapping='/rmapi_supportvalues/*')
global with sharing class RMAPI_SupportValues {
    // RMAPI_SupportValues
    //   -> Get the defined Support values
    // GET   /services/apexrest/pqcrush/rmapi_supportvalues/

    // Wraps '@salesforce/apex/RelationshipMapMemberController.getSupportValues';
    // public static List<NameValuePair> getInfluenceValues()

    // ----------------------------------------------------

    @HttpGet
    global static List<NameValuePair> doGet() {
        // Id hierarchyId = UtilityForUrl.getIdFromRequest(RestContext.request);
        // List<SupportWrapper> result = RelationshipMapMemberController.getSupportByRelationshipMap(hierarchyId, null);
        return new List<NameValuePair>();
    }
}