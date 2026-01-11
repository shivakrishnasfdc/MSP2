@RestResource(urlMapping='/rmapi_supportcolors/*')
global with sharing class RMAPI_SupportColors {
    // RMAPI_SupportColors
    //   -> Get the configured support colors for this org
    // GET   /services/apexrest/pqcrush/rmapi_supportcolors/

    // ----------------------------------------------------

    @HttpGet
    global static Map<String, String> doGet() {
        // Colors are part of the call to get the support values
        //Map<String, String> result = GraphDataService.getSupportColors();
        return new Map<String, String>();
    }
}