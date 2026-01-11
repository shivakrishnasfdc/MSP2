/**
* @File Name : LayoutUtility.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : October 28, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | October 28, 2024 |   | Initial Version
**/

public with sharing class LayoutUtility {

    /**
     * Retrieves required fields for a specific page layout using the Tooling API.
     * @param layoutName Name of the page layout (e.g., 'Account-Account Layout').
     * @return List<String> List of required field API names.
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getRequiredFields(String recordTypeId) {
        List<String> requiredFields = new List<String>();
        Id profileId = userinfo.getProfileId();
       
        Profile pro = Database.query('Select Name from Profile where Id = \'profileId\' limit 1') ;
        String profileName = pro.Name;
        System.debug('pro   ** ' + pro);
        System.debug('profileName   ** ' + profileName);
         String qry = 'SELECT Layout.Name FROM ProfileLayout where recordtypeid = \'recordTypeId\' and Profile.Name = \'profileName\' limit 1';
        //ProfileLayout proLayout = Database.query(qry);
        //String layoutName = proLayout.Layout.Name;
        System.debug('qry   ** ' + qry);
        //System.debug('proLayout   ** ' + proLayout );
        //System.debug('layoutName   ** ' + layoutName );
        /*ProfileLayout pfl = [SELECT Layout.Name FROM ProfileLayout 
                                where recordtypeid='012O10000022ZVBIA2' 
                                and Profile.Name ='System Administrator' limit 1];
        //String layoutName = pfl.Layout.Name; */
        // Tooling API endpoint to retrieve layout metadata
        String endpoint = '/services/data/v57.0/tooling/query?q='+ (qry.replace(' ', '+'));
		//endpoint += layoutName;
        
        // HTTP request setup
        //String endpoint = /services/data/v57.0/tooling/query?q=select+LayoutId,+RecordTypeId,+TableEnumOrId+from+ProfileLayout+where+ProfileId+=+'00e0p000000WhKwAAK'

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Tooling_API_Credential' + endpoint);
        req.setMethod('GET');
        
        // Send request and handle response
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            // Parse JSON response to extract required fields
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) responseMap.get('records');
            if (!records.isEmpty()) {
                Map<String, Object> layoutMetadata = (Map<String, Object>) records[0];
                Map<String, Object> metadata = (Map<String, Object>) layoutMetadata.get('Metadata');
                List<Object> layoutSections = (List<Object>) metadata.get('layoutSections');
                
                for (Object section : layoutSections) {
                    Map<String, Object> sectionMap = (Map<String, Object>) section;
                    List<Object> layoutRows = (List<Object>) sectionMap.get('layoutRows');
                    
                    for (Object row : layoutRows) {
                        Map<String, Object> rowMap = (Map<String, Object>) row;
                        List<Object> layoutItems = (List<Object>) rowMap.get('layoutItems');
                        
                        for (Object item : layoutItems) {
                            Map<String, Object> itemMap = (Map<String, Object>) item;
                            if (Boolean.valueOf(String.valueOf(itemMap.get('required')))) {
                                List<Object> layoutComponents = (List<Object>) itemMap.get('layoutComponents');
                                for (Object component : layoutComponents) {
                                    Map<String, Object> componentMap = (Map<String, Object>) component;
                                    String fieldName = (String) componentMap.get('value');
                                    requiredFields.add(fieldName);
                                }
                            }
                        }
                    }
                }
            }
        } else {
            System.debug('Error retrieving layout: ' + res.getBody());
        }
        System.System.debug('requiredFields *** ' +  requiredFields);
        return requiredFields;
    }
}