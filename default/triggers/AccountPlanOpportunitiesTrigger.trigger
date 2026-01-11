trigger AccountPlanOpportunitiesTrigger on Account_Plan_Opportunity__c(
    after delete,
    after insert,
    after update,
    after undelete,
    before delete,
    before insert,
    before update
) {
    if (!Application.bypassTrigger) {
        fflib_SObjectDomain.triggerHandler(AccountPlanOpportunities.class);
    }
}