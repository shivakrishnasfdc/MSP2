trigger WhiteSpaceRowsTrigger on White_Space_Row__c(before delete, before insert, before update) {
    if (!Application.bypassTrigger) {
        fflib_SObjectDomain.triggerHandler(WhiteSpaceRows.class);
    }
}