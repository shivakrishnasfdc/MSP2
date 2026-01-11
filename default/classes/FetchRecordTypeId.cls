public with sharing class FetchRecordTypeId {
    @AuraEnabled
    public static id getRecordTypeId(Id recordId) {
        Id recordTypeId = [SELECT id, RecordTypeId FROM pqcrush__Account_Plan__c WHERE id = :recordId WITH SECURITY_ENFORCED][0].RecordTypeId;
        return recordTypeId;
    }
}