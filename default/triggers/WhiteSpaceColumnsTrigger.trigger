trigger WhiteSpaceColumnsTrigger on White_Space_Column__c(before delete, before insert, before update) {
    if (!Application.bypassTrigger) {
        fflib_SObjectDomain.triggerHandler(WhiteSpaceColumns.class);
    }
}