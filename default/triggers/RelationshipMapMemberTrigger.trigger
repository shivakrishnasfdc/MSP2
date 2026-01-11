trigger RelationshipMapMemberTrigger on Relationship_Map_Member__c(after insert, after update) {
    if (!Application.bypassTrigger) {
        fflib_SObjectDomain.triggerHandler(RelationshipMapMembers.class);
    }
}