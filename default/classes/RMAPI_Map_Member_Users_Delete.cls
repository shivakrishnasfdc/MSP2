@RestResource(urlMapping='/rmapi_map_member_users_delete/*')
global with sharing class RMAPI_Map_Member_Users_Delete {

    // RMAPI_Map_Member_Users_Delete
    //   -> Delete a Relationship Map Member User
    // POST  /services/apexrest/pqcrush/rmapi_map_member_users_delete/

    // ----------------------------------------------------

    @HttpPost
    global static Boolean doPost(List<Id> mapMemberUserIds) {
        GraphDataController.deleteMapMemberUsers(mapMemberUserIds);
        return true;
    }
}