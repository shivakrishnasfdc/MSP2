@RestResource(urlMapping='/rmapi_mapsettings/*')
global with sharing class RMAPI_MapSettings {
    // RMAPI_MapSettings
    //   -> Get the Settings info for RM in this Org
    // GET  /services/apexrest/pqcrush/rmapi_mapsettings/

    @HttpGet
    global static pqcrush__RM_Chart_Setting__c doGet() {
        Id objectId = UtilityForUrl.getIdFromRequest(RestContext.request);
        return RMChartSettingController.getRelationshipMapSettingForObject(objectId).toChartSettings();
    }
}