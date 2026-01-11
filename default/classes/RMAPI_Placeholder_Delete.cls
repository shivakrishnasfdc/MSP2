@RestResource(urlMapping='/rmapi_placeholder_delete/*')
global with sharing class RMAPI_Placeholder_Delete {

    // RMAPI_Placeholder_Delete
    //   -> Delete Placeholder nodes
    // POST   /services/apexrest/pqcrush/rmapi_placeholder_delete/
    // DELETE Cannot include body data with Salesforce REST

    // ----------------------------------------------------

    @HttpPost
    global static Boolean doPost(List<String> placeholderIds) {
        MapMemberPlaceholderService.deletePlaceholders(placeholderIds);
        return true;
    }
}