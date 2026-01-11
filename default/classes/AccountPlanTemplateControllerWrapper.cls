public with sharing class AccountPlanTemplateControllerWrapper {
    public class WrapperTemplate {
        public Integer componentIndex;
        public String componentName;
        public String componentApiName;
        public Boolean isRelatedObject;
    }

    /********************************
     * Get all account plan records *
     ********************************/
    @AuraEnabled
    public static List<pqcrush__Account_Plan__c> getAllAccountPlans() {
        List<pqcrush__Account_Plan__c> accountPlanList = new AccountPlanSelector().selectByLimit();
        if (accountPlanList.isEmpty()) {
            return null;
        }
        return accountPlanList;
    }
}