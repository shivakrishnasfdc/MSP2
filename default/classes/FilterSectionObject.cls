public with sharing class FilterSectionObject {
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public List<FilterObject> filters { get; set; }
    @AuraEnabled
    public Boolean isSingleSelect { get; set; }

    public FilterSectionObject(String label, List<FilterObject> filters, Boolean isSingleSelect) {
        this.label = label;
        this.filters = filters;
        this.isSingleSelect = isSingleSelect;
    }
}