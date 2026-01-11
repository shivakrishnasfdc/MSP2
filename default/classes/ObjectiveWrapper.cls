public with sharing class ObjectiveWrapper {
    @AuraEnabled
    public String accountPlanName { get; set; }
    @AuraEnabled
    public Objective__c objective { get; set; }
    @AuraEnabled
    public List<TaskWrapper> tasks { get; set; }
    @AuraEnabled
    public Boolean updateable { get; set; }
    @AuraEnabled
    public Boolean deleteable { get; set; }

    public ObjectiveWrapper(Objective__c objective, Boolean updateable, Boolean deleteable) {
        this.accountPlanName = objective.Account_Plan__r.Name;
        this.objective = objective;
        this.tasks = new List<TaskWrapper>();
        this.updateable = updateable;
        this.deleteable = deleteable;
    }

    public ObjectiveWrapper(Objective__c objective, List<Task> tasks, Boolean updateable, Boolean deleteable) {
        this.accountPlanName = objective.Account_Plan__r.Name;
        this.objective = objective;
        this.tasks = TaskWrapper.convert(tasks);
        this.updateable = updateable;
        this.deleteable = deleteable;
    }
}