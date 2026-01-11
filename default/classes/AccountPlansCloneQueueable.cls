public class AccountPlansCloneQueueable implements Queueable {
    private Map<Id, Account_Plan__c> originalPlans = new Map<Id, Account_Plan__c>();
    private List<AccountPlanCloneWrapper> cloneWrappers = new List<AccountPlanCloneWrapper>();
    
    public AccountPlansCloneQueueable(Map<Id, Account_Plan__c> originalPlansByPlanId,List<AccountPlanCloneWrapper> cloneWrappersList) {
		originalPlans = originalPlansByPlanId;
        cloneWrappers = cloneWrappersList;
    }

    // Execute method where the actual logic will run
    public void execute(QueueableContext context) {
        AccountPlanCloneServiceImpl accPlanServiceImpl = new AccountPlanCloneServiceImpl();
        Application.bypassTrigger=true;
 		accPlanServiceImpl.clonedRelationshipsForPlans(originalPlans,cloneWrappers);
        Application.bypassTrigger=false;
    }
}