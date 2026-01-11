@SuppressWarnings('PMD.ApexDangerousMethods')
public with sharing class AccountPlanOpportunities extends fflib_SObjectDomain {
    public AccountPlanOpportunities(List<Account_Plan_Opportunity__c> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    /******************************
     *       STATIC METHODS
     ******************************/

    public static AccountPlanOpportunities newInstance(List<Account_Plan_Opportunity__c> sObjectList) {
        return (AccountPlanOpportunities) Application.Domain.newInstance(sObjectList);
    }

    public static String getUniqueKey(Account_Plan_Opportunity__c accountPlanOpportunity) {
        return String.valueOf(accountPlanOpportunity.Account_Plan__c) +
            String.valueOf(accountPlanOpportunity.Opportunity__c);
    }

    /******************************
     *   TRIGGER HANDLER METHODS
     ******************************/

    public override void onValidate() {
        checkDuplicates();
    }

    public override void onValidate(Map<Id, SObject> existingRecords) {
        checkDuplicates();
    }

    public override void onAfterInsert() {
        if (!System.Test.isRunningTest() && !Application.bypassTrigger) {
            sendEmails();
        }
    }

    /******************************
     *      PRIVATE METHODS
     ******************************/

    private void checkDuplicates() {
        for (
            Account_Plan_Opportunity__c duplicateAccountPlanOpportunity : AccountPlanOpportunitySelector.newInstance()
                .selectDuplicatesAsSystem(Records)
        ) {
            duplicateAccountPlanOpportunity.addError(System.Label.error_duplicate_account_plan_opportunity);
        }
    }

    private void sendEmails() {
        CRUSH_Settings_Obj__c settings = SettingService.getOrgSettingsAndCreateIfNeeded();

        if (!settings.Enable_Notifications__c || !settings.Opportunities_Added__c) {
            return;
        }

        List<SendEmailNotifications.SendEmailRequest> emailRequests = new List<SendEmailNotifications.SendEmailRequest>();

        for (SObject sobj : Records) {
            Account_Plan_Opportunity__c opp = (Account_Plan_Opportunity__c) sobj;

            SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();
            request.accountPlanId = opp.Account_Plan__c;
            request.eventType = 'Opportunities_Are_Added';

            emailRequests.add(request);
        }

        try {
            SendEmailNotifications.sendEmails(emailRequests);
        } catch (Exception e) {
            System.debug('Error thrown sending update Emails: ' + e.getMessage()); //NOPMD
        }
    }

    /******************************
     *       INNER CLASSES
     ******************************/

    /**
     * This is a workaround for the lack of reflection in Apex.
     */
    public with sharing class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new AccountPlanOpportunities(sObjectList);
        }
    }
}