public with sharing class AccountPlanTemplateData {
    /*******************************************
     * Get specific Account plan template data *
     *******************************************/
    @AuraEnabled
    public static List<pqcrush__Account_Plan_Template__c> getData(String accTempName) {
        List<pqcrush__Account_Plan_Template__c> accountPlanTemplateList = new AccountPlanTemplateSelector()
            .selectBySearch(accTempName);
        return accountPlanTemplateList;
    }

    /************************
     * Get all account plan *
     ************************/
    @AuraEnabled
    public static List<pqcrush__Account_Plan_Template__c> getAllAccountPlan() {
        List<pqcrush__Account_Plan_Template__c> accountPlanTemplateList = new AccountPlanTemplateSelector()
            .selectByLimit(5);
        return accountPlanTemplateList;
    }

    /****************************************************************************
     * Get account plan template which has pqcrush__Default__c field is checked *
     ****************************************************************************/
    @AuraEnabled
    public static Id showDefaultPlan() {
        List<pqcrush__Account_Plan_Template__c> accPlanRecord = new AccountPlanTemplateSelector().defaultCheck();
        Id accPlanId;
        if (accPlanRecord.size() > 0) {
            accPlanId = accPlanRecord[0].Id;
        }
        return accPlanId;
    }
}