@RestResource(urlMapping='/rmapi_map_contacts/*')
global with sharing class RMAPI_Map_Contacts {

    // RMAPI_Map_Contacts
    //   -> Associate Contacts with a Relationship Map
    // POST  /services/apexrest/pqcrush/rmapi_map_contacts/

    // ----------------------------------------------------

    @HttpPost
    global static GraphData doPost(Id mapOrAccountPlanId, String graphDataJsonString) {
        return RelationshipMapMemberController.addContactToRelationshipMap(mapOrAccountPlanId, graphDataJsonString);
    }
}