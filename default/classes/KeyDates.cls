public with sharing class KeyDates extends AccountPlanChildDomain {
    @TestVisible
    static Boolean bypassEmailTrigger = false;

    private KeyDates(List<Key_Date__c> sObjectList) {
        super(sObjectList);
    }

    /******************************
     *       STATIC METHODS
     ******************************/

    public static KeyDates newInstance(List<Key_Date__c> sObjectList) {
        return (KeyDates) Application.Domain.newInstance(sObjectList);
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

        if (!settings.Enable_Notifications__c || !settings.Key_Date_Updated__c) {
            return;
        }

        List<SendEmailNotifications.SendEmailRequest> emailRequests = new List<SendEmailNotifications.SendEmailRequest>();

        for (SObject sobj : Records) {
            Key_Date__c keyDate = (Key_Date__c) sobj;

            SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();
            request.accountPlanId = keyDate.Account_Plan__c;
            request.eventType = 'Key_Dates_Is_Updated';

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
            return new KeyDates(sObjectList);
        }
    }
}