public with sharing class InputLookupTypeObject {
    @AuraEnabled
    public String objType { get; set; }
    @AuraEnabled
    public String displayFieldName { get; set; }

    public String objNameField {
        get {
            if (objNameField == null && objType != null) {
                objNameField = UTIL_Describe.getNameField(objType);
            }
            return objNameField;
        }
        set;
    }
    private String soslStatement = null; //NOPMD - false positive

    public InputLookupTypeObject() {
        objType = null;
        displayFieldName = null;
    }

    public InputLookupTypeObject(String type) {
        this.objType = type;
    }

    public String getSoslReturningStatement() {
        if (soslStatement == null && objType != null) {
            String returnFields = 'Id, ' + objNameField;
            String orderByField = objNameField;
            if (String.isNotBlank(displayFieldName) && displayFieldName.toLowerCase() != objNameField.toLowerCase()) {
                returnFields += ', ' + displayFieldName;
                orderByField = displayFieldName;
            }
            if(fflib_SecurityUtils.checkObjectValidAndIsAccessable(objType) && fflib_SecurityUtils.checkFieldValidAndIsAccessable(objType, displayFieldName)
            && fflib_SecurityUtils.checkFieldValidAndIsAccessable(objType, objNameField)) {
            soslStatement = objType + '(' + returnFields + ' ORDER BY ' + orderByField + ')';
            }
        }
        return soslStatement;
    }
}