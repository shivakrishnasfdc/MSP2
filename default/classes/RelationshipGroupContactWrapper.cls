public with sharing class RelationshipGroupContactWrapper {
    @AuraEnabled
    public Id id { get; set; }
    @AuraEnabled
    public Id contactId { get; set; }
    @AuraEnabled
    public Id groupId { get; set; }
    @AuraEnabled
    public String groupLabel { get; set; }
    @AuraEnabled
    public Id relationshipMapId { get; set; }
    @AuraEnabled
    public Id accountPlanId { get; set; }
    @AuraEnabled
    public String containerName { get; set; }
    @AuraEnabled
    public Boolean isGlobalGroup { get; set; }

    public RelationshipGroupContactWrapper(
        Id id,
        Id contactId,
        Id groupId,
        String groupLabel,
        Id relationshipMapId,
        Id accountPlanId,
        String containerName,
        Boolean isGlobalGroup
    ) {
        this.id = id;
        this.contactId = contactId;
        this.groupId = groupId;
        this.groupLabel = groupLabel;
        this.relationshipMapId = relationshipMapId;
        this.accountPlanId = accountPlanId;
        this.containerName = containerName;
        this.isGlobalGroup = isGlobalGroup;
    }

    public static List<RelationshipGroupContactWrapper> convert(
        List<Relationship_Group_Contact_Association__c> relList
    ) {
        if (relList == null || relList.size() == 0) {
            return new List<RelationshipGroupContactWrapper>();
        }

        List<RelationshipGroupContactWrapper> result = new List<RelationshipGroupContactWrapper>();
        for (Relationship_Group_Contact_Association__c rgca : relList) {
            String containerName = '';
            if (rgca.Relationship_Group__r?.Relationship_Map__c != null) {
                containerName = rgca.Relationship_Group__r?.Relationship_Map__r.Name;
            } else if (rgca.Relationship_Group__r?.Account_Plan__c != null) {
                containerName = rgca.Relationship_Group__r?.Account_Plan__r.Name;
            }
            Boolean isGlobal =
                rgca.Relationship_Group__r?.Relationship_Map__c == null &&
                rgca.Relationship_Group__r?.Account_Plan__c == null;
            result.add(
                new RelationshipGroupContactWrapper(
                    rgca.Id,
                    rgca.Contact__c,
                    rgca.Relationship_Group__c,
                    rgca.Relationship_Group__r?.Label__c,
                    rgca.Relationship_Group__r?.Relationship_Map__c,
                    rgca.Relationship_Group__r?.Account_Plan__c,
                    containerName,
                    isGlobal
                )
            );
        }

        return result;
    }
}