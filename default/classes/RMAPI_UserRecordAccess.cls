@RestResource(urlMapping='/rmapi_userrecordaccess/*')
global with sharing class RMAPI_UserRecordAccess {
    // RMAPI_UserRecordAccess
    //   -> Get the user's permissions for a given object
    // GET  /services/apexrest/pqcrush/rmapi_userrecordaccess/

    @HttpGet
    global static UserRecordAccess doGet() {
        Id objectId = UtilityForUrl.getIdFromRequest(RestContext.request);
        UserRecordAccess userRecordAccess = UserRecordAccessServiceController.getUserRecordAccess(objectId);
        if (userRecordAccess != null) {
            return userRecordAccess;
        } else {
            return null; 
        }
    }
}