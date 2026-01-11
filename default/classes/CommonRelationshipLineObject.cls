// This class is to store common fields between Contact_Relationship__c & Map_Member_Placeholder_Relationship__c
public with sharing class CommonRelationshipLineObject {
    @AuraEnabled
    public Id id { get; set; }
    @AuraEnabled
    public String relationshipMapId { get; set; }
    @AuraEnabled
    public String accountPlanId { get; set; }
    @AuraEnabled
    public String containerName { get; set; }
    @AuraEnabled
    public Id nodeKey { get; set; }
    @AuraEnabled
    public String lineLabel { get; set; }
    @AuraEnabled
    public String lineColor { get; set; }
    @AuraEnabled
    public Boolean isGlobalRelationship { get; set; }

    public CommonRelationshipLineObject(
        Id id,
        Id relationshipMapId,
        Id accountPlanId,
        String containerName,
        Id nodeKey,
        String lineLabel,
        String lineColor,
        Boolean isGlobalRelationship
    ) {
        this.id = id;
        this.relationshipMapId = relationshipMapId;
        this.accountPlanId = accountPlanId;
        this.containerName = containerName;
        this.nodeKey = nodeKey;
        this.lineLabel = lineLabel;
        this.lineColor = lineColor;
        this.isGlobalRelationship = isGlobalRelationship;
    }
}