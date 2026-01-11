public with sharing class OpportunityController {
    @AuraEnabled
    public static List<OpportunityContactWrapper> getOpportunityContactsForContactId(Id contactId) {
        List<OpportunityContactRole> ocrList = OpportunityContactRoleSelector.newInstance()
            .selectByContactId(new Set<Id>{ contactId });
        return OpportunityContactWrapper.convert(ocrList);
    }

    @AuraEnabled
    public static List<TaskWrapper> getTasksForOpportunity(Id opptyOrOpptyPlanId) {
        Id recordId = getOpportunityId(opptyOrOpptyPlanId);
        if (recordId == null) {
            return null;
        }
        List<Task> openTaskList = TasksSelector.newInstance().selectByWhatId(new Set<Id>{ recordId }, true, 50, false);
        List<Task> closedTaskList = TasksSelector.newInstance()
            .selectByWhatId(new Set<Id>{ recordId }, false, 50, true);
        openTaskList.addAll(closedTaskList);
        return TaskWrapper.convert(openTaskList);
    }

    @AuraEnabled
    public static List<EventWrapper> getEventsForOpportunity(Id opptyOrOpptyPlanId) {
        Id recordId = getOpportunityId(opptyOrOpptyPlanId);
        if (recordId == null) {
            return null;
        }
        List<Event> eventList = EventSelector.newInstance().selectByWhatId(new Set<Id>{ recordId }, true, 50);
        return EventWrapper.convert(eventList);
    }

    private static Id getOpportunityId(Id opptyOrOpptyPlanId) {
        Schema.SObjectType incomingType = opptyOrOpptyPlanId.getSobjectType();

        if (incomingType == Opportunity.getSObjectType()) {
            return opptyOrOpptyPlanId;
        }

        if (incomingType == PQ_Opportunity_Plan__c.getSObjectType()) {
            PQ_Opportunity_Plan__c plan = Database.query(
                'SELECT Id, Opportunity__c from PQ_Opportunity_Plan__c where Id = :opptyOrOpptyPlanId'
            );

            if (plan != null) {
                return plan.Opportunity__c;
            }
        }
        return null;
    }
}