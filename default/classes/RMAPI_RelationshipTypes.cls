@RestResource(urlMapping='/rmapi_relationshiptypes/*')
global with sharing class RMAPI_RelationshipTypes {
    // RMAPI_RelationshipTypes
    //   -> Get the defined Contact Relationshp Types
    // GET   /services/apexrest/pqcrush/rmapi_relationshiptypes/

    // ----------------------------------------------------

    @HttpGet
    global static List<Contact_Relationship_Type__c> doGet() {
        Id objectId = UtilityForUrl.getIdFromRequest(RestContext.request);
        return GraphDataService.getContactRelationshipTypes(objectId);
    }
}