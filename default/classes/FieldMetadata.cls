@SuppressWarnings('PMD.NcssConstructorCount,PMD.TooManyFields,PMD.ExcessivePublicCount')
public with sharing class FieldMetadata implements Comparable {
    @AuraEnabled
    public String apiName { get; private set; }
    @AuraEnabled
    public String displayType { get; private set; }
    @AuraEnabled
    public Boolean isAccessible { get; private set; }
    @AuraEnabled
    public Boolean isCalculated { get; private set; }
    @AuraEnabled
    public Boolean isCreateable { get; private set; }
    @AuraEnabled
    public Boolean isCustom { get; private set; }
    @AuraEnabled
    public Boolean isFilterable { get; private set; }
    @AuraEnabled
    public Boolean isGroupable { get; private set; }
    @AuraEnabled
    public Boolean isNameField { get; private set; }
    @AuraEnabled
    public Boolean isRequired { get; private set; }
    @AuraEnabled
    public Boolean isSortable { get; private set; }
    @AuraEnabled
    public Boolean isUpdateable { get; private set; }
    @AuraEnabled
    public String label { get; private set; }
    @AuraEnabled
    public String referenceObjectApiName { get; private set; }
    @AuraEnabled
    public String relationshipApiName { get; private set; }
    @AuraEnabled
    public Integer relationshipOrder { get; private set; }
    @AuraEnabled
    public String sobjectApiName { get; private set; }
    @AuraEnabled
    public String controllingFieldName { get; private set; }

    public FieldMetadata(String sobjectApiName, String fieldApiName) {
        this(
            Application.getGlobalDescribe().get(sobjectApiName),
            Application.getGlobalDescribe().get(sobjectApiName).getDescribe().fields.getMap().get(fieldApiName)
        );
    }

    public FieldMetadata(Schema.SobjectType sobjectType, Schema.SobjectField sobjectField) {
        Schema.DescribeFieldResult fieldDescribe = sobjectField.getDescribe();

        this.apiName = String.valueOf(sobjectField);
        this.displayType = fieldDescribe.getType().name();
        this.isAccessible = fieldDescribe.isAccessible();
        this.isCalculated = fieldDescribe.isCalculated();
        this.isCreateable = fieldDescribe.isCreateable();
        this.isCustom = fieldDescribe.isCustom();
        this.isFilterable = fieldDescribe.isFilterable();
        this.isGroupable = fieldDescribe.isGroupable();
        this.isNameField = fieldDescribe.isNameField();
        this.isRequired = fieldDescribe.isNillable() == false && fieldDescribe.isCreateable(); // If a field is NOT nillable, then it's required
        this.isSortable = fieldDescribe.isSortable();
        this.isUpdateable = fieldDescribe.isUpdateable();
        this.label = fieldDescribe.getLabel();
        List<SObjectType> referenceObj = fieldDescribe.getReferenceTo();
        this.referenceObjectApiName = (referenceObj != null &&
            referenceObj.size() > 0)
            ? String.valueOf(referenceObj[0])
            : '';
        this.relationshipApiName = fieldDescribe.getRelationshipName();
        this.relationshipOrder = fieldDescribe.getRelationshipOrder();
        this.sobjectApiName = String.valueOf(sobjectType);

        Schema.SObjectField controllingField = fieldDescribe.getController();
        this.controllingFieldName = controllingField?.getDescribe()?.getName();
    }

    public Integer compareTo(Object obj) {
        FieldMetadata fieldMetadata = (FieldMetadata) (obj);
        if (this.label > fieldMetadata.label) {
            return 1;
        }
        if (this.label == fieldMetadata.label) {
            return 0;
        }
        return -1;
    }
}