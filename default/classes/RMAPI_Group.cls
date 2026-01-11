@RestResource(urlMapping='/rmapi_group/*')
global with sharing class RMAPI_Group {
    // RMAPI_Group
    // POST  /services/apexrest/pqcrush/rmapi_group/

    // ----------------------------------------------------

    @HttpPost
    global static GraphNodeData doPost(String graphDataJsonString, List<String> idList, String mapId) {
        return GraphDataController.createNewGroup(graphDataJsonString, idList, UtilityForString.getIdForString(mapId));
    }

    @HttpPut
    global static Boolean doPut(String graphDataJsonString, String newName) {
        GraphDataController.updateGroupName(graphDataJsonString, newName);
        return true;
    }
}