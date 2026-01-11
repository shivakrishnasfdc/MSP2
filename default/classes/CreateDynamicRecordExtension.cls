@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class CreateDynamicRecordExtension {
    @RemoteAction
    global static String getCreateURL(String objectName, Map<String, String> fieldValues) {
        String prefix = UTIL_Describe.getObjectDescribe(objectName).getKeyPrefix();
        String urlString = '/' + prefix + '/e';
        if (fieldValues != null && fieldValues.size() > 0) {
            urlString += '?';
            Boolean first = true;
            for (String key : fieldValues.keySet()) {
                String value = fieldValues.get(key);
                urlString +=
                    (first ? '' : '&') +
                    EncodingUtil.urlEncode(key, 'UTF-8') +
                    '=' +
                    EncodingUtil.urlEncode(value, 'UTF-8');
                first = false;
            }
        }
        return urlString;
    }
}