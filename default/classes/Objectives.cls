public with sharing class Objectives extends AccountPlanChildDomain {
    @TestVisible
    static Boolean bypassEmailTrigger = false;

    private Objectives(List<Objective__c> sObjectList) {
        super(sObjectList);
    }

    /******************************
     *       STATIC METHODS
     ******************************/

    public static Objectives newInstance(List<Objective__c> sObjectList) {
        return (Objectives) Application.Domain.newInstance(sObjectList);
    }

    /******************************
     *   TRIGGER HANDLER METHODS
     ******************************/

    public override void onAfterInsert() {
        if (!bypassEmailTrigger && !Application.bypassTrigger) {
            sendEmails();
        }
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        if (!bypassEmailTrigger && !Application.bypassTrigger) {
            sendEmails();
        }
    }

    /******************************
     *      PRIVATE METHODS
     ******************************/

    private void sendEmails() {
        CRUSH_Settings_Obj__c settings = SettingService.getOrgSettingsAndCreateIfNeeded();

        if (!settings.Enable_Notifications__c || !settings.Objectives_Updated__c) {
            return;
        }

        List<SendEmailNotifications.SendEmailRequest> emailRequests = new List<SendEmailNotifications.SendEmailRequest>();

        for (SObject sobj : Records) {
            Objective__c objective = (Objective__c) sobj;

            SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();
            request.accountPlanId = objective.Account_Plan__c;
            request.eventType = 'Objectives_Are_Updated';

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
            return new Objectives(sObjectList);
        }
    }
}