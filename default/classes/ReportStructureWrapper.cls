@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class ReportStructureWrapper {
    @AuraEnabled
    public Id id { get; set; }
    @AuraEnabled
    public Id contactId { get; set; }
    @AuraEnabled
    public List<String> peopleTheyReportTo { get; set; }
    @AuraEnabled
    public List<String> peopleTheyManage { get; set; }
    @AuraEnabled
    public String containerName { get; set; }
    @AuraEnabled
    public Id accountPlanId { get; set; }
    @AuraEnabled
    public Id relationshipMapId { get; set; }

    public ReportStructureWrapper(
        Id id,
        Id contactId,
        List<String> peopleTheyReportTo,
        List<String> peopleTheyManage,
        String containerName,
        Id accountPlanId,
        Id relationshipMapId
    ) {
        this.id = id;
        this.contactId = contactId;
        this.peopleTheyReportTo = peopleTheyReportTo;
        this.peopleTheyManage = peopleTheyManage;
        this.containerName = containerName;
        this.accountPlanId = accountPlanId;
        this.relationshipMapId = relationshipMapId;
    }

    public static List<ReportStructureWrapper> convert(
        Id contactId,
        List<Map_Member_Placeholder_Relationship__c> mapMemberList
    ) {
        if (mapMemberList == null || mapMemberList.size() == 0) {
            return new List<ReportStructureWrapper>();
        }

        Map<Id, List<Map_Member_Placeholder_Relationship__c>> mapByContainerId = ReportStructureWrapperService.organizeMemberList(
            mapMemberList
        );
        Map<Id, Contact> contactMap = ReportStructureWrapperService.getContactMap(mapMemberList);

        List<ReportStructureWrapper> result = new List<ReportStructureWrapper>();

        for (Id containerId : mapByContainerId.keySet()) {
            List<Map_Member_Placeholder_Relationship__c> mList = mapByContainerId.get(containerId);

            String containerName = mList[0]?.Relationship_Map__r?.Name;
            Id relationshipMapId = mList[0]?.Relationship_Map__c;
            Id accountPlanId = mList[0]?.Account_Plan__c;

            if (containerId.getSObjectType() == Account_Plan__c.getSObjectType()) {
                containerName = mList[0]?.Account_Plan__r?.Name;
            }

            List<String> peopleTheyReportTo = new List<String>();
            List<String> peopleTheyManage = new List<String>();

            for (Map_Member_Placeholder_Relationship__c mmpr : mList) {
                if (mmpr.To__c == contactId && mmpr.From__c != contactId) {
                    Contact reportTo = contactMap.get((Id) mmpr.From__c);
                    if (reportTo != null) {
                        peopleTheyReportTo.add(reportTo.Name);
                    }
                } else if (mmpr.To__c != contactId && mmpr.From__c == contactId) {
                    Contact manage = contactMap.get((Id) mmpr.To__c);
                    if (manage != null) {
                        peopleTheyManage.add(manage.Name);
                    }
                }
            }

            result.add(
                new ReportStructureWrapper(
                    containerId,
                    contactId,
                    peopleTheyReportTo,
                    peopleTheyManage,
                    containerName,
                    accountPlanId,
                    relationshipMapId
                )
            );
        }

        return result;
    }

    public static ReportStructureWrapper convert(Contact thisContact, List<Contact> contactsTheyManage) {
        List<String> peopleTheyReportTo = new List<String>{ thisContact.ReportsTo.Name };
        List<String> peopleTheyManage = new List<String>();
        for (Contact c : contactsTheyManage) {
            peopleTheyManage.add(c.Name);
        }

        return new ReportStructureWrapper(
            thisContact.Id,
            thisContact.Id,
            peopleTheyReportTo,
            peopleTheyManage,
            '__global',
            null,
            null
        );
    }
}