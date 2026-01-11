@RestResource(urlMapping='/rmapi_group_nodes_remove/*')
global with sharing class RMAPI_Group_Nodes_Remove {
    // RMAPI_Group_Nodes_Remove
    // POST  /services/apexrest/pqcrush/rmapi_group_nodes_remove/

    // ----------------------------------------------------

    @HttpPost
    global static Boolean doPost(List<String> idList) {
        //RelationshipGroupService.removeNodesFromGroup(idList);
        //return true;
        throw new AuraHandledException('Deprecated API ...');
        // TODO, create a new API that takes correct parameters for removeNodesFromGroup
    }
}