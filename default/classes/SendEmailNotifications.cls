public with sharing class SendEmailNotifications {
    public static final Map<String, SObjectField> SETTINGS_FIELDS_BY_EVENT_TYPE = new Map<String, SObjectField>{
        'Opportunities_Are_Added' => CRUSH_Settings_Obj__c.Opportunities_Added__c,
        'Objectives_Are_Updated' => CRUSH_Settings_Obj__c.Objectives_Updated__c,
        'Key_Dates_Is_Updated' => CRUSH_Settings_Obj__c.Key_Date_Updated__c,
        'Key_Stakeholders_Is_Updated' => CRUSH_Settings_Obj__c.Key_Stakeholder_Updated__c,
        'Plan_Overview_Is_Updated' => CRUSH_Settings_Obj__c.Plan_Overview_Updated__c,
        'Goal_Is_Updated' => CRUSH_Settings_Obj__c.Goal_Updated__c,
        'Status_Is_Updated' => CRUSH_Settings_Obj__c.Status_Updated__c,
        'SWOT_Is_Updated' => CRUSH_Settings_Obj__c.SWOT_Analysis_Updated__c,
        'User_Added_Removed_from_Account_Plan' => CRUSH_Settings_Obj__c.Team_Member_Added_Removed__c,
        'User_Removed_from_Account_Plan' => CRUSH_Settings_Obj__c.Team_Member_Added_Removed__c,
        'User_Permissions_Updated' => CRUSH_Settings_Obj__c.Team_Member_Permission_Updated__c
    };

    @InvocableMethod(label='Send Email')
    public static void sendEmails(List<SendEmailRequest> requests) {
        emailNotificationsImp().sendEmails(requests);
    }

    public static void sendReminderEmails(List<Key_Date__c> keyDates, String template) {
        emailNotificationsImp().sendReminderEmails(keyDates, template);
    }

    public with sharing class SendEmailRequest {
        @InvocableVariable
        public Id accountPlanId;

        @InvocableVariable
        public Id teamMemberUserId;

        /*
            Contains the email template developer name (without prefix)
        */
        @InvocableVariable
        public String eventType;
    }

    private static SendEmailNotificationsImpl emailNotificationsImp() {
        return (SendEmailNotificationsImpl) Application.Service.newInstance(SendEmailNotificationsImpl.class);
    }
}