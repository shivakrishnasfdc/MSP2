@isTest
private class MapRelationshipLineContainerTest {
    @isTest
    static void instanceTest() {
        Id cId = fflib_IDGenerator.generate(Relationship_Map__c.SObjectType);
        Id relationshipMapId = fflib_IDGenerator.generate(Relationship_Map__c.SObjectType);
        Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        String containerName = 'test';
        Boolean isGlobal = true;
        Boolean usingGlobal = true;
        List<RelationshipLineWrapper> relLines = new List<RelationshipLineWrapper>();

        MapRelationshipLineContainer mrc = new MapRelationshipLineContainer(
            cId,
            relationshipMapId,
            accountPlanId,
            containerName,
            relLines,
            isGlobal,
            usingGlobal
        );

        System.assertEquals(cId, mrc.id);
        System.assertEquals(relationshipMapId, mrc.relationshipMapId);
        System.assertEquals(accountPlanId, mrc.accountPlanId);
        System.assertEquals(containerName, mrc.containerName);
        System.assertEquals(isGlobal, mrc.isGlobalRelationship);
        System.assertEquals(usingGlobal, mrc.isUsingGlobalRelationship);
    }

    @isTest
    static void convertNullTest() {
        TestMockData md = new TestMockData();

        List<MapRelationshipLineContainer> result = MapRelationshipLineContainer.convert(md.mockContactId, null, null);
        System.assertEquals(0, result.size());
    }

    @isTest
    static void convertEmptyTest() {
        TestMockData md = new TestMockData();

        List<MapRelationshipLineContainer> result = MapRelationshipLineContainer.convert(
            md.mockContactId,
            null,
            new List<Map_Member_Placeholder_Relationship__c>()
        );
        System.assertEquals(0, result.size());
    }

    @isTest
    static void convertTest() {
        TestMockData md = new TestMockData();
        RelationshipLineWrapperServiceImpl mockRelationshipLineWrapperService = md.mockRelationshipLineWrapperService;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;

        Id crId1 = fflib_IDGenerator.generate(Contact_Relationship__c.SObjectType);
        Id toId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id fromId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id mmprId1 = fflib_IDGenerator.generate(Map_Member_Placeholder_Relationship__c.SObjectType);
        Id mmprToId = fflib_IDGenerator.generate(Contact.SObjectType);

        List<Contact_Relationship__c> contactRelList = new List<Contact_Relationship__c>{
            new Contact_Relationship__c(Id = crId1, To_Contact__c = toId, From_Contact__c = fromId)
        };
        List<Map_Member_Placeholder_Relationship__c> mapMemberList = new List<Map_Member_Placeholder_Relationship__c>{
            new Map_Member_Placeholder_Relationship__c(Id = mmprId1, From__c = mmprToId, To__c = mmprToId)
        };

        Id croId = fflib_IDGenerator.generate(Relationship_Map__c.SObjectType);
        Id rmId = fflib_IDGenerator.generate(Relationship_Map__c.SObjectType);
        Id apId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        String containerName = 'test';
        Id nodeKey = fflib_IDGenerator.generate(Contact.SObjectType);
        String lineLabel = 'label';
        String lineColor = '#ff00ff';
        Boolean isGlobal = false;

        CommonRelationshipLineObject cro = new CommonRelationshipLineObject(
            croId,
            rmId,
            apId,
            containerName,
            nodeKey,
            lineLabel,
            lineColor,
            isGlobal
        );

        Map<String, List<CommonRelationshipLineObject>> mapByContainerId = new Map<String, List<CommonRelationshipLineObject>>();
        mapByContainerId.put(rmId, new List<CommonRelationshipLineObject>{ cro });

        Map<Id, String> nodeNames = new Map<Id, String>();
        nodeNames.put(nodeKey, 'TestName');

        Map<Id, RM_Chart_Setting__c> mapSettings = new Map<Id, RM_Chart_Setting__c>();
        mapSettings.put(rmId, md.mockRMChartSettingForRelationshipMap);

        md.mocks.startStubbing();
        md.mocks.when(
                mockRelationshipLineWrapperService.organizeMemberList(md.mockContactId, mapMemberList, contactRelList)
            )
            .thenReturn(mapByContainerId);
        md.mocks.when(mockRelationshipLineWrapperService.getNodeNames(contactRelList, mapMemberList))
            .thenReturn(nodeNames);
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObjects(new Set<Id>{ rmId }, false))
            .thenReturn(mapSettings);
        md.mocks.stopStubbing();

        List<MapRelationshipLineContainer> result = MapRelationshipLineContainer.convert(
            md.mockContactId,
            contactRelList,
            mapMemberList
        );
        System.assertEquals(1, result.size());
        System.assertEquals(rmId, result[0].relationshipMapId);
        System.assertEquals(lineLabel, result[0].relationshipLines[0].lineLabel);
        System.assertEquals(lineColor, result[0].relationshipLines[0].lineColor);
        System.assertEquals(containerName, result[0].containerName);
    }
}