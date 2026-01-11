@RestResource(urlMapping='/rmapi_group_contacts_add/*')
global with sharing class RMAPI_Group_Contacts_Add {
    // RMAPI_Group_Contacts_Add
    // POST  /services/apexrest/pqcrush/rmapi_group_contacts_add/

    // ----------------------------------------------------

    @HttpPost
    global static Boolean doPost(String graphDataJsonString, List<String> contactIds, String mapId) {
        GraphDataController.addContactsToGroup(graphDataJsonString, contactIds, UtilityForString.getIdForString(mapId));
        return true;
    }
}