@SuppressWarnings('PMD.ApexSuggestUsingNamedCred,PMD.FieldNamingConventions')
public with sharing class ToolingAPIClient {
    String SessionId;
    String DomainUrl = URL.getSalesforceBaseUrl().toExternalForm();

    private String getAPIData(String serviceUrl) {
        HttpRequest req = new HttpRequest();
        Http h = new Http();
        req.setHeader('Authorization', 'Bearer ' + this.SessionId);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(DomainUrl + serviceUrl);
        req.setMethod('GET');
        try {
            HttpResponse res = h.send(req);
            if (res.getStatusCode() == 200) {
                return res.getBody();
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    private ToolingAPIDataModels.DescribeLayoutResult getContactDescribeLayouts() {
        try {
            String reqUrl = '/services/data/v58.0/sobjects/Contact/describe/layouts/';
            String result = this.getAPIData(reqUrl);

            ToolingAPIDataModels.DescribeLayoutResult queryResult = (ToolingAPIDataModels.DescribeLayoutResult) JSON.deserialize(
                result,
                ToolingAPIDataModels.DescribeLayoutResult.class
            );

            return queryResult;
        } catch (Exception e) {
            return null;
        }
    }

    private String getContactProfileLayoutByRecordTypeId(Id recordTypeId) {
        try {
            String reqUrl = '/services/data/v58.0/sobjects/Contact/describe/layouts/' + recordTypeId;
            String result = this.getAPIData(reqUrl);

            return result;
        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static String getContactDescribe() {
        try {
            ToolingAPIClient tlc = new ToolingAPIClient();

            String reqUrl = '/services/data/v58.0/sobjects/Contact/describe';
            String result = tlc.getAPIData(reqUrl);

            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}