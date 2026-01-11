public with sharing class WSRelatedObjectWrapper {
    public Schema.DescribeSObjectResult objDesc;
    public Schema.DescribeFieldResult relationshipField;
    public Schema.DescribeFieldResult labelFieldDesc;
    public String labelFieldName;
    public List<String> fieldList;
    public String color = '#556677';

    public WSRelatedObjectWrapper() {
        this.objDesc = null;
        this.relationshipField = null;
        this.labelFieldName = null;
        this.fieldList = null;
    }

    public WSRelatedObjectWrapper(Schema.DescribeSObjectResult obj, Schema.DescribeFieldResult rel) {
        this(obj, rel, null);
    }

    public WSRelatedObjectWrapper(
        Schema.DescribeSObjectResult obj,
        Schema.DescribeFieldResult rel,
        Cell_Relationship_Configuration__c config
    ) {
        if (config?.Object_API_Name__c != obj.getName()) {
            config = null;
        }
        this.objDesc = obj;
        this.relationshipField = rel;
        setupDisplayFieldsFromConfig(config);
        if (!String.isBlank(config?.Color__c)) {
            this.color = config.Color__c;
        }
    }

    private void setupDisplayFieldsFromConfig(Cell_Relationship_Configuration__c config) {
        if (String.isBlank(config?.Display_Field__c)) {
            findAndSetDisplayFields();
            return;
        }
        List<String> parts = config.Display_Field__c.split('\\.');
        String fieldName = (String) UtilityForList.last(parts);
        String idName = config.Display_Field__c.replace(fieldName, 'Id');
        Schema.DescribeSObjectResult currentObj = this.objDesc;
        //verify that displayField path fully exists, if not use Name field via findAndSetDisplayFields method
        for (String part : parts) {
            Boolean found = false;
            for (Schema.SObjectField sof : currentObj.fields.getMap().values()) {
                try {
                    Schema.DescribeFieldResult field = sof.getDescribe();
                    if (field.getRelationshipName() == part || field.getName() == part) {
                        found = true;
                        if (field.getReferenceTo().size() > 0) {
                            currentObj = field.getReferenceTo()[0].getDescribe();
                        }
                        this.labelFieldDesc = field;
                        break;
                    }
                } catch (Exception e) {
                    continue;
                }
            }
            if (!found) {
                findAndSetDisplayFields();
                return;
            }
        }
        this.labelFieldName = config.Display_Field__c;
        this.fieldList = new List<String>{ config.Display_Field__c, idName };
    }

    private void findAndSetDisplayFields() {
        for (Schema.SObjectField childField : this.objDesc.fields.getMap().values()) {
            try {
                if (childField.getDescribe().isNameField()) {
                    this.labelFieldDesc = childField.getDescribe();
                    String name = this.labelFieldDesc.getName();
                    this.labelFieldName = name;
                    this.fieldList = new List<String>{ name, 'Id' };
                }
            } catch (Exception e) {
                continue;
            }
        }
    }
}