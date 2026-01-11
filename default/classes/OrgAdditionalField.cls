public with sharing class OrgAdditionalField {
    @AuraEnabled
    public String title;

    @AuraEnabled
    public String value;

    @AuraEnabled
    public Boolean isMainSection;

    @AuraEnabled
    public String type;

    @AuraEnabled
    public String apiName;

    public OrgAdditionalField(String apiName, String title, String value, Boolean isMainSection, String type) {
        this.title = title;
        this.value = value != null ? value.stripHtmlTags() : '';
        this.isMainSection = isMainSection;
        this.type = type;
        this.apiName = apiName;
    }
}