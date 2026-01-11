public with sharing class MappingConditionWrapper {
    @AuraEnabled
    public Boolean isFieldCreateable { get; set; }

    @AuraEnabled
    public Mapping_Condition__c singleCondition { get; set; }

    public MappingConditionWrapper() {
        this.isFieldCreateable = false;
        this.singleCondition = null;
    }

    public MappingConditionWrapper(Mapping_Condition__c singleCondition, String parentObject) {
        this.singleCondition = singleCondition;
        FieldMetadata fmd = new FieldMetadata(parentObject, singleCondition.Field__c);
        this.isFieldCreateable = fmd.isCreateable;
    }
}