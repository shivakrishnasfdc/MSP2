@SuppressWarnings('PMD.ApexSuggestUsingNamedCred,PMD.FieldNamingConventions')
public with sharing class RemoteImageToolsController {
    public class RemoteProxyQueryResultModel {
        Integer size;
        Integer totalSize;
        Boolean done;
        String entityTypeName;
        RemoteProxyModel[] records;
    }

    public class RemoteProxyModel {
        AttributesModel attributes;
        Boolean IsActive;
        String SiteName;
        String EndpointUrl;
    }

    public class CSPTrustedSitesQueryResultModel {
        Integer size;
        Integer totalSize;
        Boolean done;
        String entityTypeName;
        CSPTrustedSitesModel[] records;
    }

    public class CSPTrustedSitesModel {
        AttributesModel attributes;
        Boolean IsActive;
        String MasterLabel;
        String EndpointUrl;
    }

    public class AttributesModel {
        String type;
        String url;
    }

    public class RemoteImageToolSettings {
        String apiEndpointUrl;
        String cspTrustedSiteUrl;
        String remoteSiteSettingUrl;
        Boolean isConfiguredProperly = false;
        Boolean remoteSiteSettingConfigured = false;
        Boolean cspTrustedSiteConfigured = false;
    }

    public class ToolingAPIClient {
        String SessionId;
        String DomainUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String RemoteSettingsName = 'Prolifiq_Image_Tools';
        String RemoteSiteSettingsAPIQuery =
            DomainUrl +
            '/services/data/v58.0/tooling/query/?q=Select+SiteName,EndpointUrl,IsActive+from+RemoteProxy+where+SiteName=\'' +
            RemoteSettingsName +
            '\'';
        String CSPTrustedSitesAPIQuery =
            DomainUrl +
            '/services/data/v58.0/tooling/query/?q=Select+MasterLabel,EndpointUrl,IsActive+from+CspTrustedSite+where+MasterLabel=\'' +
            RemoteSettingsName +
            '\'';

        public ToolingAPIClient() {
            this.SessionId = '';
        }

        private String getAPIData(String url) {
            HttpRequest req = new HttpRequest();
            Http h = new Http();
            req.setHeader('Authorization', 'Bearer ' + this.SessionId);
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(url);
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

        private RemoteImageToolSettings getCSPTrustedSiteSettings(RemoteImageToolSettings settings) {
            try {
                String result = getAPIData(CSPTrustedSitesAPIQuery);
                CSPTrustedSitesQueryResultModel queryResult = (CSPTrustedSitesQueryResultModel) JSON.deserialize(
                    result,
                    CSPTrustedSitesQueryResultModel.class
                );
                if (queryResult.size == 1 && queryResult.entityTypeName == 'CspTrustedSite') {
                    if (queryResult.records[0].IsActive) {
                        settings.cspTrustedSiteUrl = queryResult.records[0].EndpointUrl;
                        settings.cspTrustedSiteConfigured = true;
                    }
                }
            } catch (Exception e) {
                return settings;
            }

            return settings;
        }

        private RemoteImageToolSettings getRemoteSiteSettings(RemoteImageToolSettings settings) {
            try {
                String result = getAPIData(RemoteSiteSettingsAPIQuery);
                RemoteProxyQueryResultModel queryResult = (RemoteProxyQueryResultModel) JSON.deserialize(
                    result,
                    RemoteProxyQueryResultModel.class
                );
                if (queryResult.size == 1 && queryResult.entityTypeName == 'RemoteProxy') {
                    if (queryResult.records[0].IsActive) {
                        settings.remoteSiteSettingUrl = queryResult.records[0].EndpointUrl;
                        settings.remoteSiteSettingConfigured = true;
                    }
                }
            } catch (Exception e) {
                return settings;
            }

            return settings;
        }
    }

    @AuraEnabled
    public static String getRemoteImageToolSettings() {
        RemoteImageToolSettings settings = new RemoteImageToolSettings();
        ToolingAPIClient tlc = new ToolingAPIClient();

        settings = tlc.getRemoteSiteSettings(settings);

        // Validate
        if (settings.remoteSiteSettingConfigured) {
            settings.apiEndpointUrl = settings.remoteSiteSettingUrl;
            settings.isConfiguredProperly = true;
        }

        return JSON.serialize(settings);
    }
}