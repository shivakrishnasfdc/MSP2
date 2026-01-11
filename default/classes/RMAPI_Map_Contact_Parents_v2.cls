@RestResource(urlMapping='/rmapi/v2/map_contact_parents/*')
global with sharing class RMAPI_Map_Contact_Parents_v2 {
    // RMAPI_Map_Contact_Parents_v2
    //   -> Get Parent nodes for Contacts
    // POST  /services/apexrest/pqcrush/rmapi/v2/map_contact_parents/

    // ----------------------------------------------------

    @HttpPost
    global static GraphData doPost(List<Id> contactIds, String mapId) {
        return RelationshipMapMemberController.getParentNodesForContactIds(
            contactIds,
            UtilityForString.getIdForString(mapId)
        );
    }
}