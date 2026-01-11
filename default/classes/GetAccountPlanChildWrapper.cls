public with sharing class GetAccountPlanChildWrapper {
    @AuraEnabled
    public String label { get; set; }

    @AuraEnabled
    public String value { get; set; }

    public GetAccountPlanChildWrapper(String label, String value) {
        this.label = label;
        this.value = value;
    }
}