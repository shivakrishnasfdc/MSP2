@RestResource(urlMapping='/rmapi_customlinks/*')
global with sharing class RMAPI_CustomLinks {
    // RMAPI_CustomLinks
    // POST   /services/apexrest/pqcrush/rmapi_customlinks/
    // PUT    /services/apexrest/pqcrush/rmapi_customlinks/
    // DELETE /services/apexrest/pqcrush/rmapi_customlinks/

    // ----------------------------------------------------

    @HttpPost
    global static Boolean doPost(String graphDataJsonString, String mapOrAccountPlanId) {
        GraphDataController.newCustomLinks(graphDataJsonString, UtilityForString.getIdForString(mapOrAccountPlanId));
        return true;
    }

    @HttpPut
    global static Boolean doPut(String graphDataJsonString) {
        GraphDataController.updateCustomLinks(graphDataJsonString);
        return true;
    }

    // @HttpDelete
    // global static Boolean doDelete(String graphDataJsonString) {
    //     GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);
    //     ContactRelationshipService.deleteCustomLinks(gd.linkDataArray);
    //     return true;
    // }
}