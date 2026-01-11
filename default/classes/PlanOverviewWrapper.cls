public with sharing class PlanOverviewWrapper {
    @AuraEnabled
    public Id id;

    @AuraEnabled
    public string title;

    @AuraEnabled
    public string backgroundColor;

    @AuraEnabled
    public string description;

    @AuraEnabled
    public Boolean updateable { get; set; }

    @AuraEnabled
    public Boolean deleteable { get; set; }

    public PlanOverviewWrapper(pq_CRUSH_Plan_Overview__c planOverview, Boolean updateable, Boolean deleteable) {
        this.id = planOverview.Id;
        this.title = planOverview.Title__c;
        this.backgroundColor = planOverview.Background_Color__c != null ? planOverview.Background_Color__c : '#cccccc';
        this.description = planOverview.Description__c;
        this.updateable = updateable;
        this.deleteable = deleteable;
    }
}