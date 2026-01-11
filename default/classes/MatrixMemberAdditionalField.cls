public with sharing class MatrixMemberAdditionalField {
    @AuraEnabled
    public String name;

    @AuraEnabled
    public String label;

    @AuraEnabled
    public String type;

    @AuraEnabled
    public Object value;

    @AuraEnabled
    public String valueDisplay;

    public MatrixMemberAdditionalField(String name, String label, String type, Object value) {
        this.name = name;
        this.label = label;
        this.type = type;
        this.value = value;
    }

    public MatrixMemberAdditionalField(String name, String label, String type, Object value, String valueDisplay) {
        this(name, label, type, value);
        this.valueDisplay = valueDisplay;
    }
}