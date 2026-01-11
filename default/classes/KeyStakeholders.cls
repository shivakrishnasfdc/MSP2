public with sharing class KeyStakeholders extends AccountPlanChildDomain {
    @TestVisible
    static Boolean bypassEmailTrigger = false;

    public KeyStakeholders(List<Key_Stakeholder__c> sObjectList) {
        super(sObjectList);
    }

    /******************************
     *       STATIC METHODS
     ******************************/

    public static KeyStakeholders newInstance(List<Key_Stakeholder__c> sObjectList) {
        return (KeyStakeholders) Application.Domain.newInstance(sObjectList);
    }

    public static String getUniqueKey(Key_Stakeholder__c stakeholder) {
        return String.valueOf(stakeholder.Account_Plan__c) + String.valueOf(stakeholder.Contact__c);
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

    private void checkDuplicates() {
        for (
            Key_Stakeholder__c duplicateStakeholder : KeyStakeholderSelector.newInstance()
                .selectDuplicatesAsSystem(Records)
        ) {
            duplicateStakeholder.addError(System.Label.error_duplicate_account_plan_key_stakeholder);
        }
    }

    private void sendEmails() {
        CRUSH_Settings_Obj__c settings = SettingService.getOrgSettingsAndCreateIfNeeded();

        if (!settings.Enable_Notifications__c || !settings.Key_Stakeholder_Updated__c) {
            return;
        }

        List<SendEmailNotifications.SendEmailRequest> emailRequests = new List<SendEmailNotifications.SendEmailRequest>();

        for (SObject sobj : Records) {
            Key_Stakeholder__c keyStakeholder = (Key_Stakeholder__c) sobj;

            SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();
            request.accountPlanId = keyStakeholder.Account_Plan__c;
            request.eventType = 'Key_Stakeholders_Is_Updated';

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
            return new KeyStakeholders(sObjectList);
        }
    }
}