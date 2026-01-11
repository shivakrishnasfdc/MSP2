public with sharing class UtilityForString {
    public static Map<String, String> parseNameValueStringToMap(String str) {
        // INPUT name1:value1;name2:value2;name3:value3;
        // OUTPUT Map<String, String>
        if (str == null) {
            return new Map<String, String>();
        }

        Map<String, String> result = new Map<String, String>();
        List<String> stringList = str.split(';');
        for (String s : stringList) {
            List<String> parts = s.split(':');
            if (parts.size() > 1) {
                result.put(parts[0], parts[1]);
            }
        }

        return result;
    }

    public static String parseMapToNameValueString(Map<String, String> mapToConvert) {
        String result = '';
        for (String key : mapToConvert.keySet()) {
            result = result + key + ':' + mapToConvert.get(key) + ';';
        }
        return result;
    }

    // COMPARES TYPE STRINGS OR OBJECTS THAT HAVE STRING VALUES
    public static Boolean compareObjectStringValue(Object obj1, Object obj2) {
        String item1 = '';
        String item2 = '';
        if (obj1 != null) {
            item1 = String.valueOf(obj1);
        }
        if (obj2 != null) {
            item2 = String.valueOf(obj2);
        }

        return item1.compareTo(item2) == 0;
    }

    public static String trimByMaxLength(String stringToTrim, Integer maxLength) {
        stringToTrim = String.isBlank(stringToTrim) ? '' : stringToTrim;
        return stringToTrim.length() > maxLength ? stringToTrim.substring(0, maxLength) : stringToTrim;
    }

    public static Id getIdForString(String stringId) {
        if (!String.isBlank(stringId)) {
            return Id.valueOf(stringId);
        }
        return null;
    }

    // Builds a comma delimited string from a map of String & boolean.  Builds only the true values
    public static String buildStringFromMap(Map<String, Boolean> input) {
        Boolean first = true;
        String result = '';
        for (String key : input.keySet()) {
            Boolean val = input.get(key);
            if (val) {
                if (!first) {
                    result += ',';
                }
                first = false;
                result += key;
            }
        }

        return result;
    }
}