@RestResource(urlMapping='/rmapi_group_groups_add/*')
global with sharing class RMAPI_Group_Groups_Add {
    // RMAPI_Group_Groups_Add
    // POST  /services/apexrest/pqcrush/rmapi_group_groups_add/

    // ----------------------------------------------------

    @HttpPost
    global static Boolean doPost(String graphDataJsonString, List<String> groupIds) {
        GraphDataController.addGroupsToGroup(graphDataJsonString, groupIds);
        return true;
    }
}