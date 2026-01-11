public with sharing class UtilityForSObject {
    public static Object getFieldValue(SObject o, String fieldName) {
        if (isFieldReadable(o.getSObjectType(), fieldName) && o.isSet(fieldName)) {
            return o.get(fieldName);
        }
        return null;
    }

    /**
     * Checks read CRUD for the specified object type.
     * Return True or False
     **/
    public static Boolean isObjectReadable(SObjectType objType) {
        if (!objType.getDescribe().isAccessible()) {
            return false;
        }
        return true;
    }

    /** ----------------------------------------------------------------------------- **/
    /**  Check Field is Readable and Return True or False                             **/
    /** ----------------------------------------------------------------------------- **/
    public static Boolean isFieldReadable(SObjectType objType, String fieldName) {
        SObjectField fieldToken = fflib_SObjectDescribe.getDescribe(objType).getField(fieldName);
        if (fieldToken != null) {
            return isFieldReadable(objType, fieldToken);
        }
        return false;
    }

    public static Boolean isFieldReadable(SObjectType objType, SObjectField fieldToken) {
        return isFieldReadable(objType, fieldToken.getDescribe());
    }

    public static Boolean isFieldReadable(SObjectType objType, DescribeFieldResult fieldDescribe) {
        if (!fieldDescribe.isAccessible()) {
            return false;
        }
        return true;
    }
    /** ----------------------------------------------------------------------------- **/

    /**
     * Checks update FLS for the specified object fields
     * @return Map<String, Boolean> map of update FLS by each field
     **/
    public static Map<String, Boolean> getFieldUpdatibility(SObjectType objType, List<SObjectField> fieldTokens) {
        Map<String, Boolean> result = new Map<String, Boolean>();

        try {
            fflib_SecurityUtils.checkObjectIsUpdateable(objType);
        } catch (fflib_SecurityUtils.CrudException e) {
            for (SObjectField fieldToken : fieldTokens) {
                result.put(fieldToken.getDescribe().getName(), false);
            }
        }

        for (SObjectField fieldToken : fieldTokens) {
            try {
                fflib_SecurityUtils.checkFieldIsUpdateable(objType, fieldToken);
                result.put(fieldToken.getDescribe().getName(), true);
            } catch (fflib_SecurityUtils.FlsException e) {
                result.put(fieldToken.getDescribe().getName(), false);
            }
        }

        return result;
    }

    /** @description Returns a list of SelectOptions for a given object and picklist field name.
     * @param objectName The name of the object.
     * @param fieldName The name of the field. -- LOWERCASE
     * @return List<SelectOption> The select options for this picklist field.
     */

    public static List<SelectOption> getPicklistSelectOptions(String objectName, String fieldName) {
        List<SelectOption> result = new List<SelectOption>();
        if (String.isEmpty(objectName) || String.isEmpty(fieldName)) {
            return result;
        }
        Schema.DescribeFieldResult describeField;
        try {
            describeField = UTIL_Describe.getFieldDescribe(objectName, fieldName);
        } catch (Exception e) {
            return result;
        }
        if (
            describeField.getType() == Schema.DisplayType.PICKLIST ||
            describeField.getType() == Schema.DisplayType.MULTIPICKLIST
        ) {
            for (Schema.PicklistEntry entry : describeField.getPicklistValues()) {
                if (entry.isActive()) {
                    result.add(new SelectOption(entry.getValue(), entry.getLabel()));
                }
            }
        }
        return result;
    }

    public static List<Map<String, String>> getPicklistSelectOptionsMap(String objectName, String fieldName) {
        List<Map<String, String>> result = new List<Map<String, String>>();
        if (String.isEmpty(objectName) || String.isEmpty(fieldName)) {
            return result;
        }
        Schema.DescribeFieldResult describeField;
        try {
            describeField = UTIL_Describe.getFieldDescribe(objectName, fieldName);
        } catch (Exception e) {
            return result;
        }
        if (
            describeField.getType() == Schema.DisplayType.PICKLIST ||
            describeField.getType() == Schema.DisplayType.MULTIPICKLIST
        ) {
            for (Schema.PicklistEntry entry : describeField.getPicklistValues()) {
                if (entry.isActive()) {
                    Map<String, String> labeledOption = new Map<String, String>();
                    labeledOption.put('value', entry.getValue());
                    labeledOption.put('label', entry.getLabel());
                    result.add(labeledOption);
                }
            }
        }
        return result;
    }

    public static List<String> getOrderedPicklistValues(String objectName, String fieldName) {
        List<String> result = new List<String>();
        if (String.isEmpty(objectName) || String.isEmpty(fieldName)) {
            return result;
        }
        Schema.DescribeFieldResult describeField;
        try {
            describeField = UTIL_Describe.getFieldDescribe(objectName, fieldName);
        } catch (Exception e) {
            return result;
        }
        if (
            describeField.getType() == Schema.DisplayType.PICKLIST ||
            describeField.getType() == Schema.DisplayType.MULTIPICKLIST
        ) {
            for (Schema.PicklistEntry entry : describeField.getPicklistValues()) {
                if (entry.isActive()) {
                    result.add(entry.getValue());
                }
            }
        }
        return result;
    }
}