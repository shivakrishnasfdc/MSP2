public with sharing class GetChildRecordsWithFieldSet {
    /***********************************
     * Get Child Records with FieldSet *
     ***********************************/
    @AuraEnabled(cacheable=true)
    public static String childRecordsWithFieldSet(String objectApiName, Id parentId) {
        String fieldSetName = System.Label.FieldSetName;
        String queryString = GetChildRecordsWithFieldSet.buildDynamicQuery(objectApiName, fieldSetName, parentId);
        if(!fflib_SecurityUtils.checkObjectValidAndIsAccessable(objectApiName)) {
            return null;
    }
        List<sObject> sobjList = Database.query(queryString);
        return JSON.serialize(sobjList);
    }

    /**************************
     * To build Dynamic Query *
     **************************/
    private static String buildDynamicQuery(String objectApiName, String fieldSetName, id parentId) {
        String parentObjectApiName = 'pqcrush__Account_Plan__c';
        List<String> fieldList = getFieldSetFields(objectApiName, fieldSetName);
        String parentObjectLookUpApiName = GetChildRecordsWithFieldSet.getLookupFieldApiName(
            objectApiName,
            parentObjectApiName
        );
        String selectPart = 'SELECT ' + String.join(fieldList, ', ');

        // Build the FROM part of the query
        String fromPart = 'FROM ' + objectApiName;
        String condition = 'Where' + ' ' + parentObjectLookUpApiName + '= :parentId WITH SECURITY_ENFORCED Limit 25';

        // Combine SELECT and FROM parts
        String soqlQuery = selectPart + ' ' + fromPart + ' ' + condition;
        return soqlQuery;
    }

    /***********************
     * Get FieldSet Fields *
     ***********************/
    private static List<String> getFieldSetFields(String objectApiName, String fieldSetName) {
        List<String> fieldList = new List<String>();
        list<string> objectNameList = new List<string>();
        try {
            // Get the SObjectType dynamically
            SObjectType objectType = Schema.getGlobalDescribe().get(objectApiName);

            // Get the field set dynamically
            Schema.FieldSet fieldSet = objectType.getDescribe().fieldSets.getMap().get(fieldSetName);

            // Get the list of fields in the field set
            if (fieldSet != null) {
                for (Schema.FieldSetMember field : fieldSet.getFields()) {
                    if (field.getType() == Schema.DisplayType.REFERENCE) {
                        //fieldList.add(field.getFieldPath());
                        string typeobj = field.getFieldPath();
                        objectNameList.add(typeobj);
                    } else {
                        fieldList.add(field.getFieldPath());
                    }
                }
            }
            for (String objectName : objectNameList) {
                String typeobj = objectName;
                if (typeobj == 'RecordTypeId') {
                    typeobj = 'RecordType.Name';
                } else if (typeobj == 'LastModifiedById') {
                    typeobj = 'LastModifiedBy.Name';
                } else if (typeobj == 'CreatedById') {
                    typeobj = 'CreatedBy.Name';
                } else if (typeobj == 'OwnerId') {
                    typeobj = 'Owner.Name';
                } else {
                    typeobj = typeobj.removeEnd('c');
                    typeobj = typeobj + 'r.Name';
                }
                // query += typeobj+'.Name'+', ';
                fieldList.add(typeobj);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return fieldList;
    }

    /*****************************
     * Get LookUp Field Api Name *
     *****************************/
    public static String getLookupFieldApiName(String childObjectApiName, String parentObjectApiName) {
        try {
            // Get the SObjectType for the child object
            SObjectType childObjectType = Schema.getGlobalDescribe().get(childObjectApiName);

            // Get the field describe result
            Schema.DescribeSObjectResult childDescribeResult = childObjectType.getDescribe();

            // Get the fields on the child object
            Map<String, Schema.SObjectField> fieldsMap = childDescribeResult.fields.getMap();

            // Iterate through the fields to find the lookup field to the parent object
            for (Schema.SObjectField field : fieldsMap.values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

                // Check if the field is a reference field (lookup or master-detail)
                if (fieldDescribe.getType() == Schema.DisplayType.REFERENCE) {
                    // Check if the reference is to the specified parent object
                    if (fieldDescribe.getReferenceTo()[0].getDescribe().getName() == parentObjectApiName) {
                        // Return the API name of the lookup field
                        return fieldDescribe.getName();
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        // Return null if the lookup field is not found
        return null;
    }

    /**********************************************
     * Returning object Name for Data tabel Label *
     **********************************************/
    @AuraEnabled(cacheable=true)
    public static string getObjectName(string objectApiName) {
        SObjectType childObjectType = Schema.getGlobalDescribe().get(objectApiName);
        Schema.DescribeSObjectResult childDescribeResult = childObjectType.getDescribe();
        return childDescribeResult.getLabel();
    }
}