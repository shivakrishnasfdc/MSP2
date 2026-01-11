public class RequiredPageLayoutFields {
    public static List<String> getRequiredFieldsFromLayout() {
        List<String> requiredFields  = new List<String>();
        String sessionId = UserInfo.getSessionId();
        // Use the current Salesforce instance URL
        String instanceUrl = URL.getOrgDomainURL().toExternalForm();
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        //SELECT Layout.Name,Layout.FullName,  Layout.TableEnumOrId, ProfileId, Profile.Name, RecordTypeId,
        //RecordType.Name FROM ProfileLayout where Layout.name ='Contact (Sales) Layout' and Layout.TableEnumOrId='contact'
        // Formulate the Tooling API query endpoint
        String tName = 'Contact';
        String RecordTypeId1 ='012O10000022ZLVIA2';
        String query = 'SELECT RecordTypeId,Layout.TableEnumOrId,Layout.Metadata, RecordType.Name,Layout.Name FROM ProfileLayout where RecordTypeId = \'' + RecordTypeId1 + '\'AND Layout.TableEnumOrId = \'' + tName + '\'And ProfileId = \'' + UserInfo.getProfileId() + '\'AND LayoutId!=null';
        request.setEndpoint(instanceUrl + '/services/data/v59.0/tooling/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8'));
        request.setMethod('GET');
        
        // Set the Authorization header with the session ID
        request.setHeader('Authorization', 'Bearer ' + sessionId);
        
        // Send the request and handle the response
        HttpResponse res = http.send(request);
        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) responseMap.get('records');
            System.debug(records);
            for(Object obj : records){
				Map<String, Object> layoutMetadata = (Map<String, Object>) obj;
                System.debug('layoutMetadata'+layoutMetadata.get('Layout.Metadata'));
              // List<Object> layoutSections = (List<Object>) layoutMetadata.get('Layout');
               // System.debug('layoutSections'+layoutSections);
            }
            //if (!records.isEmpty()) {
               
               // System.debug('layoutMetadata'+layoutMetadata);
              // List<Object> layoutSections = (List<Object>) layoutMetadata.get('layout');
                
               /* for (Object sectionObj : layoutSections) {
                    Map<String, Object> section = (Map<String, Object>) sectionObj;
                    List<Object> layoutItems = (List<Object>) section.get('layoutItems');
                    
                    for (Object itemObj : layoutItems) {
                        Map<String, Object> item = (Map<String, Object>) itemObj;
                        if (Boolean.valueOf(item.get('required').toString())) {
                            requiredFields.add(item.get('field').toString());
                        }
                    }
                }*/
            //}
        }
        
        return requiredFields;
    }
}