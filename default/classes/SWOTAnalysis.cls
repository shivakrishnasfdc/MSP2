public with sharing class SWOTAnalysis extends AccountPlanChildDomain {
    @TestVisible
    static Boolean bypassEmailTrigger = false;

    private SWOTAnalysis(List<SWOT_Analysis__c> sObjectList) {
        super(sObjectList);
    }

    /******************************
     *       STATIC METHODS
     ******************************/

    public static SWOTAnalysis newInstance(List<SWOT_Analysis__c> sObjectList) {
        return (SWOTAnalysis) Application.Domain.newInstance(sObjectList);
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

        if (!settings.Enable_Notifications__c || !settings.SWOT_Analysis_Updated__c) {
            return;
        }

        List<SendEmailNotifications.SendEmailRequest> emailRequests = new List<SendEmailNotifications.SendEmailRequest>();

        for (SObject sobj : Records) {
            SWOT_Analysis__c swot = (SWOT_Analysis__c) sobj;

            SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();
            request.accountPlanId = swot.Account_Plan__c;
            request.eventType = 'SWOT_Is_Updated';

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
            return new SWOTAnalysis(sObjectList);
        }
    }
}