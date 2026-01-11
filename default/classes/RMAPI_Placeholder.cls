@RestResource(urlMapping='/rmapi_placeholder/*')
global with sharing class RMAPI_Placeholder {
    // RMAPI_Placeholder
    //   -> Create and Update Placeholder nodes
    // POST   /services/apexrest/pqcrush/rmapi_placeholder/
    // PUT    /services/apexrest/pqcrush/rmapi_placeholder/

    // ----------------------------------------------------

    @HttpPost
    global static GraphNodeData doPost(String graphDataJsonString, String relationshipMapId) {
        Id mapId = UtilityForString.getIdForString(relationshipMapId);
        GraphNodeData result = GraphDataController.createNewPlaceholder(graphDataJsonString, mapId);
        return result;
    }

    @HttpPut
    global static Boolean doPut(String graphDataJsonString, String newLabel, String newDescription) {
        if (newLabel != null) {
            GraphDataController.updatePlaceholderNameAndLabel(graphDataJsonString, newLabel);
        }
        if (newDescription != null) {
            GraphDataController.updatePlaceholderDescription(graphDataJsonString, newDescription);
        }
        return true;
    }
}