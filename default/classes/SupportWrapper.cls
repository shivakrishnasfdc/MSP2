@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class SupportWrapper {
    @AuraEnabled
    public Id id;

    @AuraEnabled
    public String name;

    @AuraEnabled
    public String value;

    @AuraEnabled
    public String color;

    public SupportWrapper(String value) {
        this.value = value;
        this.color = '#aaaaaa';
    }

    public SupportWrapper(pq_Support__c supp) {
        this.id = supp.Id;
        this.name = supp.Name;
        this.value = supp.Label__c;
        this.color = supp.Color__c;
    }
}