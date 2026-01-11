@RestResource(urlMapping='/rmapi_map_member_user_parents/*')
global with sharing class RMAPI_Map_Member_User_Parents {
    // RMAPI_Map_Member_User_Parents
    //   -> Get Parent nodes for Map Member Users
    // GET  /services/apexrest/pqcrush/rmapi_map_member_user_parents/

    // ----------------------------------------------------

    @HttpPost
    global static GraphData doPost(List<Id> userIds, String mapId) {
        return GraphDataController.getParentNodesForUserIds(
            userIds,
            UtilityForString.getIdForString(mapId)
        );
    }
}