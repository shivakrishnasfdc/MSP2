trigger TeamMembersTrigger on Team_Member__c(
    after delete,
    after insert,
    after update,
    after undelete,
    before delete,
    before insert,
    before update
) {
    if (!Application.bypassTrigger) {
        fflib_SObjectDomain.triggerHandler(TeamMembers.class);
    }
}