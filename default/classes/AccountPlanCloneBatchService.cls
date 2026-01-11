@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class AccountPlanCloneBatchService {
    @InvocableMethod(
        label='Batch Clone Account Plans'
        description='Batch Clones a list of account plans based on the data passed in'
    )
    global static void cloneAccountPlans(List<AccountPlanCloneBatchInput> inputs) {
        Set<Id> allPlanIds = new Set<Id>();
        for (AccountPlanCloneBatchInput input : inputs) {
            allPlanIds.addAll(input.planIds);
        }

        Map<Id, Account_Plan__c> accountPlansById = new Map<Id, Account_Plan__c>();
        List<Account_Plan__c> accountPlans = AccountPlanSelector.newInstance().selectByIdAsSystem(allPlanIds);
        for (Account_Plan__c ap : accountPlans) {
            accountPlansById.put(ap.Id, ap);
        }

        List<AccountPlanCloneWrapper> wrappers = new List<AccountPlanCloneWrapper>();
        for (AccountPlanCloneBatchInput input : inputs) {
            for (String planId : input.planIds) {
                Id accountId = input.accountId;
                if (String.isBlank(input.accountId)) {
                    Account_Plan__c ap = accountPlansById.get(planId);
                    accountId = ap.Account__c;
                }
                wrappers.add(
                    new AccountPlanCloneWrapper(planId, input.name, input.ownerId, accountId, input.relationships)
                );
            }
        }
        AccountPlanCloneService.cloneAccountPlans(wrappers);
    }
}