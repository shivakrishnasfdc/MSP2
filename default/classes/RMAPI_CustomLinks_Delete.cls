@RestResource(urlMapping='/rmapi_customlinks_delete/*')
global with sharing class RMAPI_CustomLinks_Delete {
    // RMAPI_CustomLinks_Delete
    //   -> Delete Custom Links
    // POST   /services/apexrest/pqcrush/rmapi_customlinks_delete/

    // ----------------------------------------------------

    @HttpPost
    global static Boolean doPost(String graphDataJsonString) {
        GraphDataController.deleteCustomLinks(graphDataJsonString);
        return true;
    }
}