@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class AccountPlanCloneBatchInput {
    @InvocableVariable(required=true)
    global List<Id> planIds;

    @InvocableVariable
    global Id accountId;

    @InvocableVariable
    global Id ownerId;

    @InvocableVariable
    global Id name;

    @InvocableVariable
    global String commaDelimitedRelationships;

    global List<String> relationships {
        get {
            if (relationships == null || relationships.size() <= 0) {
                if (String.isBlank(commaDelimitedRelationships)) {
                    return new List<String>();
                } else {
                    return commaDelimitedRelationships.trim().remove(' ').split(',');
                }
            } else {
                return relationships;
            }
        }
        set;
    }

    global AccountPlanCloneBatchInput() {
        this(null, null, null, null, null);
    }

    global AccountPlanCloneBatchInput(
        List<Id> planIds,
        Id accountId,
        Id ownerId,
        String name,
        List<String> relationships
    ) {
        this.planIds = planIds;
        this.accountId = accountId;
        this.ownerId = ownerId;
        this.name = name;
        this.relationships = relationships;
    }
}