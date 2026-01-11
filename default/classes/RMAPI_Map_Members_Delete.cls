@RestResource(urlMapping='/rmapi_map_members_delete/*')
global with sharing class RMAPI_Map_Members_Delete {

    // RMAPI_Map_Members_Delete
    //   -> Delete a Relationship Map Member
    // POST  /services/apexrest/pqcrush/rmapi_map_members_delete/

    // ----------------------------------------------------

    @HttpPost
    global static Boolean doPost(List<Id> memberIds) {
        RelationshipMapMemberController.deleteMembers(memberIds);
        return true;
    }
}