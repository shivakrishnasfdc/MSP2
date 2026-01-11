trigger OpportunitiesTrigger on Opportunity(
    after delete,
    after insert,
    after update,
    after undelete,
    before delete,
    before insert,
    before update
) {
    if (!Application.bypassTrigger) {
        fflib_SObjectDomain.triggerHandler(Opportunities.class);
    }
}