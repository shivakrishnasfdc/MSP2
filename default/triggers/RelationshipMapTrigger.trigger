trigger RelationshipMapTrigger on pqcrush__Relationship_Map__c (
    after delete,
    after insert,
    after update,
    after undelete,
    before delete,
    before insert,
    before update
){
    if (!Application.bypassTrigger) {
        fflib_SObjectDomain.triggerHandler(RelationshipMapTriggerHandler.class);
    }
}