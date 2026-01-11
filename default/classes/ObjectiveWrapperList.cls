public with sharing class ObjectiveWrapperList {
    @AuraEnabled
    public List<ObjectiveWrapper> objectives { get; set; }
    @AuraEnabled
    public Boolean creatable { get; set; }
    @AuraEnabled
    public Boolean taskCreatable { get; set; }

    public ObjectiveWrapperList(List<ObjectiveWrapper> objectives) {
        this.objectives = objectives;
        this.creatable = Schema.sObjectType.Objective__c.isCreateable();
        this.taskCreatable = Schema.sObjectType.Task.isCreateable();
    }
}