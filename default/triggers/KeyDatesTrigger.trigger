trigger KeyDatesTrigger on Key_Date__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    if (!Application.bypassTrigger) {
        fflib_SObjectDomain.triggerHandler(KeyDates.class);
    }
}