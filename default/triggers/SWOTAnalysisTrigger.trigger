trigger SWOTAnalysisTrigger on SWOT_Analysis__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    if (!Application.bypassTrigger) {
        fflib_SObjectDomain.triggerHandler(SWOTAnalysis.class);
    }
}