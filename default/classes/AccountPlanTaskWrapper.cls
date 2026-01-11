public with sharing class AccountPlanTaskWrapper {
    @AuraEnabled
    public Task taskRecord { get; set; }
    @AuraEnabled
    public List<Account_Plan__c> accountPlanRecords { get; set; }

    public AccountPlanTaskWrapper(Task taskRecord, List<Account_Plan__c> accountPlanRecords) {
        this.taskRecord = taskRecord;
        this.accountPlanRecords = new List<Account_Plan__c>(accountPlanRecords);
    }

    public AccountPlanTaskWrapper(Task taskRecord, Set<Account_Plan__c> accountPlanRecords) {
        this.taskRecord = taskRecord;
        this.accountPlanRecords = new List<Account_Plan__c>(accountPlanRecords);
    }

    public Integer hashCode() {
        return String.valueOf(taskRecord.Id).hashCode();
    }

    public Boolean equals(Object obj) {
        if (obj == null || !(obj instanceof AccountPlanTaskWrapper)) {
            return false;
        }
        AccountPlanTaskWrapper other = (AccountPlanTaskWrapper) obj;
        return String.valueOf(this.taskRecord.Id) == String.valueOf(other.taskRecord.Id);
    }
}