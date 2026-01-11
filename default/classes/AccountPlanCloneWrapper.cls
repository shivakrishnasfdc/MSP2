@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class AccountPlanCloneWrapper {
    @InvocableVariable(required=true)
    global Id planId;

    @InvocableVariable(required=true)
    global Id newAccountId;

    @InvocableVariable
    global String newName;

    @InvocableVariable
    global Id newOwnerId;

    @InvocableVariable
    global String commaDelimitedRelationships;

    public Account_Plan__c clonedPlan;

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

    global AccountPlanCloneWrapper() {
        this(null, null, null, null, null);
    }

    global AccountPlanCloneWrapper(
        Id planId,
        String name,
        Id ownerId,
        Id accountId,
        List<String> relationshipsToClone
    ) {
        this.planId = planId;
        this.newName = name;
        this.newOwnerId = ownerId;
        this.newAccountId = accountId;
        this.relationships = relationshipsToClone;
    }

    public void validationCheck() {
        if (planId == null) {
            throw Application.genericException(
                'No account plan information passed when trying to clone an account plan'
            );
        }

        if (newAccountId == null) {
            throw Application.genericException('No account information passed when trying to clone an account plan');
        }
    }

    global Boolean equals(Object obj) {
        if (obj == null || !(obj instanceof AccountPlanCloneWrapper)) {
            return false;
        }

        AccountPlanCloneWrapper other = (AccountPlanCloneWrapper) obj;

        return other.planId == this.planId &&
            other.newAccountId == this.newAccountId &&
            other.newOwnerId == this.newOwnerId &&
            other.newName == this.newName &&
            other.relationships.equals(this.relationships);
    }

    global Integer hashCode() {
        Integer relHashCode = 1;
        for (String rel : this.relationships) {
            relHashCode *= rel.hashCode();
        }
        String planString = String.valueOf(planId);
        Integer planHash = planString == null ? 1 : planString.hashCode();

        String accountString = String.valueOf(newAccountId);
        Integer accountHash = accountString == null ? 1 : accountString.hashCode();

        String ownerString = String.valueOf(newOwnerId);
        Integer ownerHash = ownerString == null ? 1 : ownerString.hashCode();

        Integer nameHash = newName == null ? 1 : newName.hashCode();

        return ((planHash * accountHash * ownerHash * nameHash) ^ relHashCode);
    }
}