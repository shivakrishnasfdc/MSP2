@RestResource(urlMapping='/rmapi_map_contact_parents/*')
global with sharing class RMAPI_Map_Contact_Parents {
    // RMAPI_Map_Contact_Parents
    //   -> Get Parent nodes for Contacts
    // POST  /services/apexrest/pqcrush/rmapi_map_contact_parents/

    // ----------------------------------------------------

    @HttpPost
    global static GraphData doPost(List<String> contactIds, String mapId) {
        return RelationshipMapMemberController.getParentNodesForContactIds(
            contactIds,
            UtilityForString.getIdForString(mapId)
        );
    }
}