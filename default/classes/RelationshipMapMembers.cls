@SuppressWarnings('PMD.ApexDangerousMethods')
public with sharing class RelationshipMapMembers extends PQSObjectDomainExt {
    static Boolean bypassEmailTrigger = false;
    public RelationshipMapMembers(List<Relationship_Map_Member__c> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    /******************************
     *       STATIC METHODS
     ******************************/

    public static RelationshipMapMembers newInstance(List<Relationship_Map_Member__c> sObjectList) {
        return (RelationshipMapMembers) Application.Domain.newInstance(sObjectList);
    }

    public static String getUniqueKey(Relationship_Map_Member__c member) {
        return String.valueOf(member.Relationship_Map__c) + String.valueOf(member.Contact__c);
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
            Relationship_Map_Member__c duplicateMember : RelationshipMapMemberSelector.newInstance()
                .selectDuplicatesAsSystem(Records)
        ) {
            duplicateMember.addError(System.Label.error_duplicate_hierarchy_member);
        }
    }

    private void sendEmails() {
        CRUSH_Settings_Obj__c settings = SettingService.getOrgSettingsAndCreateIfNeeded();

        if (!settings.Enable_Notifications__c || !settings.Key_Stakeholder_Updated__c) {
            return;
        }

        Set<Id> rmIdsSet = new Set<Id>();
        for (SObject sobj : Records) {
            Relationship_Map_Member__c rmmRecord = (Relationship_Map_Member__c) sobj;
            rmIdsSet.add(rmmRecord.pqcrush__Relationship_Map__c);
        }

        List<Relationship_Map__c> listOfRms = RelationshipMapSelector.newInstance().selectByIds(rmIdsSet);

        List<SendEmailNotifications.SendEmailRequest> emailRequests = new List<SendEmailNotifications.SendEmailRequest>();
        for (Relationship_Map__c rmFromList : listOfRms) {
            Id acctPlanId = rmFromList.pq_AccountPlanId__c;
            if (acctPlanId != null) {
                SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();
                request.accountPlanId = acctPlanId;
                request.eventType = 'Key_Stakeholders_Is_Updated';
                emailRequests.add(request);
            }
        }

        if (emailRequests.size() == 0) {
            return;
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
            return new RelationshipMapMembers(sObjectList);
        }
    }
}