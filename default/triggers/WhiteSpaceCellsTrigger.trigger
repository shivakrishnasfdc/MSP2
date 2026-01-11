trigger WhiteSpaceCellsTrigger on White_Space_Cell__c(before delete, before insert, before update) {
    if (!Application.bypassTrigger) {
        fflib_SObjectDomain.triggerHandler(WhiteSpaceCells.class);
    }
}