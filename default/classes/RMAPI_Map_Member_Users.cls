@RestResource(urlMapping='/rmapi_map_member_users/*')
global with sharing class RMAPI_Map_Member_Users {
    // RMAPI_Map_Member_Users
    //   -> Create and Update User map nodes
    // POST   /services/apexrest/pqcrush/rmapi_map_member_users/
    // PUT    /services/apexrest/pqcrush/rmapi_map_member_users/

    // ----------------------------------------------------

    @HttpPost
    global static GraphData doPost(String graphDataJsonString, String mapOrAccountPlanId) {
        Id mapId = UtilityForString.getIdForString(mapOrAccountPlanId);
        GraphData result = GraphDataController.createMapMemberUsers(graphDataJsonString, mapId);
        return result;
    }

    // @HttpPut
    // global static Boolean doPut(String graphDataJsonString, String newLabel, String newDescription) {
    //     if (newLabel != null) {
    //         GraphDataController.updatePlaceholderNameAndLabel(graphDataJsonString, newLabel);
    //     }
    //     if (newDescription != null) {
    //         GraphDataController.updatePlaceholderDescription(graphDataJsonString, newDescription);
    //     }
    //     return true;
    // }
}