@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class NameValuePair {
    @AuraEnabled
    public String name;

    @AuraEnabled
    public String value;

    public NameValuePair(String name, String value) {
        this.name = name;
        this.value = value;
    }
}