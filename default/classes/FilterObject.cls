public with sharing class FilterObject {
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String value { get; set; }
    @AuraEnabled
    public String field { get; set; }
    @AuraEnabled
    public Boolean isSelected { get; set; }
    @AuraEnabled
    public Boolean isDefault { get; set; }

    public FilterObject(String label, String value, String field, Boolean isSelected, Boolean isDefault) {
        this.label = label;
        this.value = value;
        this.field = field;
        this.isSelected = isSelected;
        this.isDefault = isDefault;
    }
}