public with sharing class ObjectDescriptionWrapper {
    @AuraEnabled
    public String objectName { get; set; }
    @AuraEnabled
    public String objectLabel { get; set; }
    @AuraEnabled
    public List<FieldWrapper> fields { get; set; }

    public ObjectDescriptionWrapper(String objectName, String objectLabel, List<FieldWrapper> fields) {
        this.objectName = objectName;
        this.objectLabel = objectLabel;
        this.fields = fields;
    }
}