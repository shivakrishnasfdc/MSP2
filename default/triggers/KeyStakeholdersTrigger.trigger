trigger KeyStakeholdersTrigger on Key_Stakeholder__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    if (!Application.bypassTrigger) {
        fflib_SObjectDomain.triggerHandler(KeyStakeholders.class);
    }
}