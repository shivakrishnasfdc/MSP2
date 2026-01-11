@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class EventWrapper {
    @AuraEnabled
    public Id id { get; set; }
    @AuraEnabled
    public Id ownerId { get; set; }
    @AuraEnabled
    public String ownerName { get; set; }
    @AuraEnabled
    public Id whatId { get; set; }
    @AuraEnabled
    public Id whoId { get; set; }
    @AuraEnabled
    public String whoName { get; set; }
    @AuraEnabled
    public String subject { get; set; }
    @AuraEnabled
    public String description { get; set; }
    @AuraEnabled
    public Datetime activityDateTime { get; set; }
    @AuraEnabled
    public Datetime startDateTime { get; set; }
    @AuraEnabled
    public Datetime endDateTime { get; set; }
    @AuraEnabled
    public String type { get; set; }
    @AuraEnabled
    public String eventSubType { get; set; }

    public EventWrapper(
        Id id,
        String type,
        String eventSubType,
        String subject,
        String description,
        Datetime activityDateTime,
        Datetime startDateTime,
        Datetime endDateTime,
        Id ownerId,
        String ownerName,
        Id whatId,
        Id whoId,
        String whoName
    ) {
        this.id = id;
        this.type = type;
        this.eventSubType = eventSubType;
        this.subject = subject;
        this.description = description;
        this.activityDateTime = activityDateTime;
        this.startDateTime = startDateTime;
        this.endDateTime = endDateTime;
        this.ownerId = ownerId;
        this.ownerName = ownerName;
        this.whatId = whatId;
        this.whoId = whoId;
        this.whoName = whoName;
    }

    public static List<EventWrapper> convert(List<Event> eventList) {
        if (eventList == null || eventList.size() == 0) {
            return new List<EventWrapper>();
        }

        // Get Picklist values for Type, EventSubType
        Schema.DescribeFieldResult subTypeFieldResult = SObjectType.Event.fields.EventSubType;
        Schema.DescribeFieldResult typeFieldResult = SObjectType.Event.fields.Type;

        Map<String, String> subTypeMap = new Map<String, String>();
        Map<String, String> typeMap = new Map<String, String>();

        for (Schema.PicklistEntry entry : subTypeFieldResult.getPicklistValues()) {
            subTypeMap.put(entry.getValue(), entry.getLabel());
        }

        for (Schema.PicklistEntry entry : typeFieldResult.getPicklistValues()) {
            typeMap.put(entry.getValue(), entry.getLabel());
        }

        List<EventWrapper> result = new List<EventWrapper>();
        for (Event e : eventList) {
            result.add(
                new EventWrapper(
                    e.Id,
                    (typeMap != null && typeMap.get(e.Type) != null) ? typeMap.get(e.Type) : '',
                    (subTypeMap != null &&
                        subTypeMap.get(e.EventSubType) != null)
                        ? subTypeMap.get(e.EventSubType)
                        : '',
                    e.Subject,
                    e.Description,
                    e.ActivityDateTime,
                    e.StartDateTime,
                    e.EndDateTime,
                    e.OwnerId,
                    e.Owner.Name,
                    e.WhatId,
                    e.WhoId,
                    e.Who.Name
                )
            );
        }

        return result;
    }
}