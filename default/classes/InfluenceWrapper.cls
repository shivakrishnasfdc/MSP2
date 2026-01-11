@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class InfluenceWrapper {
    @AuraEnabled
    public Id id;

    @AuraEnabled
    public String name;

    @AuraEnabled
    public String value;

    public InfluenceWrapper(String value) {
        this.value = value;
    }

    public InfluenceWrapper(pq_Influence__c infl) {
        this.id = infl.Id;
        this.name = infl.Name;
        this.value = infl.Label__c;
    }
}