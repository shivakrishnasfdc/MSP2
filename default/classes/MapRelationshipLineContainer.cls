public with sharing class MapRelationshipLineContainer {
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public Id relationshipMapId { get; set; }
    @AuraEnabled
    public Id accountPlanId { get; set; }
    @AuraEnabled
    public String containerName { get; set; }
    @AuraEnabled
    public Boolean isGlobalRelationship { get; set; }
    @AuraEnabled
    public Boolean isUsingGlobalRelationship { get; set; }
    @AuraEnabled
    public List<RelationshipLineWrapper> relationshipLines { get; set; }

    public MapRelationshipLineContainer(
        Id id,
        Id relationshipMapId,
        Id accountPlanId,
        String containerName,
        List<RelationshipLineWrapper> relationshipLines,
        Boolean isGlobalRelationship,
        BOolean isUsingGlobalRelationship
    ) {
        this.id = id;
        this.relationshipMapId = relationshipMapId;
        this.accountPlanId = accountPlanId;
        this.containerName = containerName;
        this.relationshipLines = relationshipLines;
        this.isGlobalRelationship = isGlobalRelationship;
        this.isUsingGlobalRelationship = isUsingGlobalRelationship;
    }

    public static List<MapRelationshipLineContainer> convert(
        Id contactId,
        List<Contact_Relationship__c> contactRelationshipList,
        List<Map_Member_Placeholder_Relationship__c> mapMemberList
    ) {
        if (
            (contactRelationshipList == null || contactRelationshipList.size() == 0) &&
            (mapMemberList == null ||
            mapMemberList.size() == 0)
        ) {
            return new List<MapRelationshipLineContainer>();
        }

        Map<String, List<CommonRelationshipLineObject>> mapByContainerId = RelationshipLineWrapperService.organizeMemberList(
            contactId,
            mapMemberList,
            contactRelationshipList
        );

        Map<Id, String> mapNodeName = RelationshipLineWrapperService.getNodeNames(
            contactRelationshipList,
            mapMemberList
        );

        Set<Id> containerIds = new Set<Id>();
        for (String containerId : mapByContainerId.keySet()) {
            if (containerId instanceof Id) {
                containerIds.add(Id.valueOf(containerId));
            }
        }

        Map<Id, RM_Chart_Setting__c> mapSettings = RMChartSettingService.getRelationshipMapSettingForObjects(
            containerIds
        );

        List<MapRelationshipLineContainer> result = new List<MapRelationshipLineContainer>();

        for (String containerId : mapByContainerId.keySet()) {
            List<CommonRelationshipLineObject> commonLineObjectList = mapByContainerId.get(containerId);

            List<RelationshipLineWrapper> lineWrapperList = new List<RelationshipLineWrapper>();
            for (CommonRelationshipLineObject crlo : commonLineObjectList) {
                lineWrapperList.add(
                    new RelationshipLineWrapper(crlo.Id, crlo.lineLabel, crlo.lineColor, mapNodeName.get(crlo.nodeKey))
                );
            }

            Boolean usingGlobal = false;
            if (containerId instanceof Id) {
                RM_Chart_Setting__c chartSetting = mapSettings.get(containerId);
                usingGlobal = chartSetting?.Is_Relationship_Line_Global_Scope__c;
            }

            result.add(
                new MapRelationshipLineContainer(
                    commonLineObjectList[0].id,
                    commonLineObjectList[0].relationshipMapId,
                    commonLineObjectList[0].accountPlanId,
                    commonLineObjectList[0].containerName,
                    lineWrapperList,
                    commonLineObjectList[0].isGlobalRelationship,
                    usingGlobal
                )
            );
        }

        return result;
    }
}