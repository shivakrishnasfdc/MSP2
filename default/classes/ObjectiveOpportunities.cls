@SuppressWarnings('PMD.ApexDangerousMethods')
public with sharing class ObjectiveOpportunities extends fflib_SObjectDomain {
    @TestVisible
    static Boolean bypassEmailTrigger = false;

    public ObjectiveOpportunities(List<Objective_Opportunity__c> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    /******************************
     *       STATIC METHODS
     ******************************/

    public static ObjectiveOpportunities newInstance(List<Objective_Opportunity__c> sObjectList) {
        return (ObjectiveOpportunities) Application.Domain.newInstance(sObjectList);
    }

    public static String getUniqueKey(Objective_Opportunity__c objectiveOpportunity) {
        return String.valueOf(objectiveOpportunity.Objective__c) + String.valueOf(objectiveOpportunity.Opportunity__c);
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

    /******************************
     *      PRIVATE METHODS
     ******************************/

    private void checkDuplicates() {
        for (
            Objective_Opportunity__c duplicateObjectiveOpportunity : ObjectiveOpportunitySelector.newInstance()
                .selectDuplicatesAsSystem(Records)
        ) {
            duplicateObjectiveOpportunity.addError(System.Label.error_duplicate_objective_opportunity);
        }
    }

    private void sendEmails() {
        CRUSH_Settings_Obj__c settings = SettingService.getOrgSettingsAndCreateIfNeeded();

        if (
            settings == null ||
            !settings.Enable_Notifications__c ||
            !settings.Objectives_Updated__c ||
            !settings.Opportunities_Added__c
        ) {
            return;
        }

        List<SendEmailNotifications.SendEmailRequest> emailRequests = new List<SendEmailNotifications.SendEmailRequest>();

        Set<Id> objectiveIds = new Set<Id>();
        for (SObject sobj : Records) {
            Objective_Opportunity__c objOpp = (Objective_Opportunity__c) sobj;
            objectiveIds.add(objOpp.Objective__c);
        }

        Map<id, Objective__c> objectivesMap = new Map<id, Objective__c>(
            ObjectiveSelector.newInstance().selectByIdAsSystem(objectiveIds)
        );

        for (SObject sobj : Records) {
            Objective_Opportunity__c objOpp = (Objective_Opportunity__c) sobj;

            SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();
            request.accountPlanId = objectivesMap.get(objOpp.Objective__c).Account_Plan__c;
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
            return new ObjectiveOpportunities(sObjectList);
        }
    }
}