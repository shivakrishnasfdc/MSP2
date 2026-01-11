@isTest
private class InfluenceSupportMatrixServiceTest {
    // Test Empty Related Items and default matrix from data
    @isTest
    static void getMatrixesForRelationshipMapEmptyTest() {
        testMockData md = new testMockData();
        RelationshipMapSelector mockRelationshipMapSelector = md.mockRelationshipMapSelector;
        RMMatrixAssociationSelector mockRMMatrixAssociationSelector = md.mockRMMatrixAssociationSelector;
        InfluenceSupportMatrixSelector mockInfluenceSupportMatrixSelector = md.mockInfluenceSupportMatrixSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;

        Set<Id> mapIds = new Set<Id>{ md.mockRelationshipMapId };
        RM_Chart_Setting__c setting = md.mockRMChartSettingForRelationshipMap;
        setting.Is_Influence_Support_Global_Scope__c = false;

        Map<Id, RM_Chart_Setting__c> settingsMap = new Map<Id, RM_Chart_Setting__c>();
        settingsMap.put(md.mockRelationshipMapId, md.mockRMChartSettingForRelationshipMap);

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<Relationship_Map__c>());
        md.mocks.when(
                mockRMChartSettingService.getRelationshipMapSettingForObjects(
                    new Set<Id>{ md.mockRelationshipMapId },
                    false
                )
            )
            .thenReturn(settingsMap);
        md.mocks.when(mockRMMatrixAssociationSelector.selectByRelationshipMaps(mapIds))
            .thenReturn(new List<pq_Relationship_Map_Matrix_Association__c>());
        md.mocks.when(mockInfluenceSupportMatrixSelector.selectDefault()).thenReturn(md.mockInfluenceSupportMatrix);
        md.mocks.stopStubbing();

        Map<Id, pq_Influence_And_Support_Matrix__c> result = InfluenceSupportMatrixService.getMatrixesForRelationshipMap(
            new Set<Id>{ md.mockRelationshipMapId }
        );

        pq_Influence_And_Support_Matrix__c matrix = result.get(md.mockRelationshipMapId);

        System.assertEquals(md.mockInfluenceSupportMatrixId, matrix.Id);
    }

    @isTest
    static void getMatrixesForRelationshipMapGlobalTest() {
        testMockData md = new testMockData();
        RelationshipMapSelector mockRelationshipMapSelector = md.mockRelationshipMapSelector;
        RMMatrixAssociationSelector mockRMMatrixAssociationSelector = md.mockRMMatrixAssociationSelector;
        InfluenceSupportMatrixSelector mockInfluenceSupportMatrixSelector = md.mockInfluenceSupportMatrixSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;

        Set<Id> mapIds = new Set<Id>{ md.mockRelationshipMapId };
        RM_Chart_Setting__c setting = md.mockRMChartSettingForRelationshipMap;
        setting.Is_Influence_Support_Global_Scope__c = true;

        Map<Id, RM_Chart_Setting__c> settingsMap = new Map<Id, RM_Chart_Setting__c>();
        settingsMap.put(md.mockRelationshipMapId, md.mockRMChartSettingForRelationshipMap);

        pq_Relationship_Map_Matrix_Association__c relMapMatrix = new pq_Relationship_Map_Matrix_Association__c(
            Relationship_Map__c = md.mockRelationshipMapId,
            Influence_And_Support_Matrix__c = fflib_IDGenerator.generate(pq_Influence_And_Support_Matrix__c.SObjectType)
        );

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<Relationship_Map__c>());
        md.mocks.when(
                mockRMChartSettingService.getRelationshipMapSettingForObjects(
                    new Set<Id>{ md.mockRelationshipMapId },
                    false
                )
            )
            .thenReturn(settingsMap);
        md.mocks.when(mockRMMatrixAssociationSelector.selectByRelationshipMaps(mapIds))
            .thenReturn(new List<pq_Relationship_Map_Matrix_Association__c>{ relMapMatrix });
        md.mocks.when(mockInfluenceSupportMatrixSelector.selectDefault()).thenReturn(md.mockInfluenceSupportMatrix);
        md.mocks.stopStubbing();

        Map<Id, pq_Influence_And_Support_Matrix__c> result = InfluenceSupportMatrixService.getMatrixesForRelationshipMap(
            new Set<Id>{ md.mockRelationshipMapId }
        );

        pq_Influence_And_Support_Matrix__c matrix = result.get(md.mockRelationshipMapId);

        System.assertEquals(md.mockInfluenceSupportMatrixId, matrix.Id);
    }

    @isTest
    static void getMatrixesForRelationshipMapTest() {
        testMockData md = new testMockData();
        RelationshipMapSelector mockRelationshipMapSelector = md.mockRelationshipMapSelector;
        RMMatrixAssociationSelector mockRMMatrixAssociationSelector = md.mockRMMatrixAssociationSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;

        Set<Id> mapIds = new Set<Id>{ md.mockRelationshipMapId };
        RM_Chart_Setting__c setting = md.mockRMChartSettingForRelationshipMap;
        setting.Is_Influence_Support_Global_Scope__c = false;

        pq_Relationship_Map_Matrix_Association__c relMapMatrix = new pq_Relationship_Map_Matrix_Association__c(
            Relationship_Map__c = md.mockRelationshipMapId,
            Influence_And_Support_Matrix__c = fflib_IDGenerator.generate(pq_Influence_And_Support_Matrix__c.SObjectType)
        );

        Map<Id, RM_Chart_Setting__c> settingsMap = new Map<Id, RM_Chart_Setting__c>();
        settingsMap.put(md.mockRelationshipMapId, md.mockRMChartSettingForRelationshipMap);

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<Relationship_Map__c>());
        md.mocks.when(
                mockRMChartSettingService.getRelationshipMapSettingForObjects(
                    new Set<Id>{ md.mockRelationshipMapId },
                    false
                )
            )
            .thenReturn(settingsMap);
        md.mocks.when(mockRMMatrixAssociationSelector.selectByRelationshipMaps(mapIds))
            .thenReturn(new List<pq_Relationship_Map_Matrix_Association__c>{ relMapMatrix });
        md.mocks.stopStubbing();

        Map<Id, pq_Influence_And_Support_Matrix__c> result = InfluenceSupportMatrixService.getMatrixesForRelationshipMap(
            new Set<Id>{ md.mockRelationshipMapId }
        );
        pq_Influence_And_Support_Matrix__c matrix = result.get(md.mockRelationshipMapId);

        System.assertEquals(relMapMatrix.Influence_And_Support_Matrix__c, matrix.Id);
    }

    @isTest
    static void getMatrixesForRelationshipMapAccountPlanTest() {
        testMockData md = new testMockData();
        RelationshipMapSelector mockRelationshipMapSelector = md.mockRelationshipMapSelector;
        AccountPlanMatrixAssociationSelector mockAccountPlanMatrixAssociationSelector = md.mockAccountPlanMatrixAssociationSelector;
        RMMatrixAssociationSelector mockRMMatrixAssociationSelector = md.mockRMMatrixAssociationSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;

        Set<Id> mapIds = new Set<Id>{ md.mockRelationshipMapId };
        RM_Chart_Setting__c setting = md.mockRMChartSettingForRelationshipMap;
        setting.Is_Influence_Support_Global_Scope__c = false;

        pq_Account_Plan_Matrix_Association__c acctPlanMapMatrix = new pq_Account_Plan_Matrix_Association__c(
            Account_Plan__c = md.mockAccountPlanId,
            Influence_And_Support_Matrix__c = fflib_IDGenerator.generate(pq_Influence_And_Support_Matrix__c.SObjectType)
        );

        pq_Relationship_Map_Matrix_Association__c relMapMatrix = new pq_Relationship_Map_Matrix_Association__c(
            Relationship_Map__c = md.mockRelationshipMapId,
            Influence_And_Support_Matrix__c = fflib_IDGenerator.generate(pq_Influence_And_Support_Matrix__c.SObjectType)
        );

        Map<Id, RM_Chart_Setting__c> settingsMap = new Map<Id, RM_Chart_Setting__c>();
        settingsMap.put(md.mockRelationshipMapId, md.mockRMChartSettingForRelationshipMap);

        md.mockRelationshipMap.pq_AccountPlanId__c = md.mockAccountPlanId;

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipMapSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.when(
                mockAccountPlanMatrixAssociationSelector.selectByAccountPlans(new Set<Id>{ md.mockAccountPlanId })
            )
            .thenReturn(new List<pq_Account_Plan_Matrix_Association__c>{ acctPlanMapMatrix });
        md.mocks.when(
                mockRMChartSettingService.getRelationshipMapSettingForObjects(
                    new Set<Id>{ md.mockRelationshipMapId },
                    false
                )
            )
            .thenReturn(settingsMap);
        md.mocks.when(mockRMMatrixAssociationSelector.selectByRelationshipMaps(mapIds))
            .thenReturn(new List<pq_Relationship_Map_Matrix_Association__c>{ relMapMatrix });
        md.mocks.stopStubbing();

        Map<Id, pq_Influence_And_Support_Matrix__c> result = InfluenceSupportMatrixService.getMatrixesForRelationshipMap(
            new Set<Id>{ md.mockRelationshipMapId }
        );
        pq_Influence_And_Support_Matrix__c matrix = result.get(md.mockRelationshipMapId);

        System.assertEquals(acctPlanMapMatrix.Influence_And_Support_Matrix__c, matrix.Id);
    }

    @isTest
    static void getMatrixesForAccountPlanEmptyTest() {
        testMockData md = new testMockData();
        AccountPlanMatrixAssociationSelector mockAccountPlanMatrixAssociationSelector = md.mockAccountPlanMatrixAssociationSelector;
        InfluenceSupportMatrixSelector mockInfluenceSupportMatrixSelector = md.mockInfluenceSupportMatrixSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;

        Set<Id> accountPlanIds = new Set<Id>{ md.mockAccountPlanId };
        RM_Chart_Setting__c setting = md.mockRMChartSettingForAccountPlan;
        setting.Is_Influence_Support_Global_Scope__c = false;

        Map<Id, RM_Chart_Setting__c> settingsMap = new Map<Id, RM_Chart_Setting__c>();
        settingsMap.put(md.mockAccountPlanId, setting);

        md.mocks.startStubbing();
        md.mocks.when(
                mockRMChartSettingService.getRelationshipMapSettingForObjects(
                    new Set<Id>{ md.mockAccountPlanId },
                    false
                )
            )
            .thenReturn(settingsMap);
        md.mocks.when(mockAccountPlanMatrixAssociationSelector.selectByAccountPlans(accountPlanIds))
            .thenReturn(new List<pq_Account_Plan_Matrix_Association__c>());
        md.mocks.when(mockInfluenceSupportMatrixSelector.selectDefault()).thenReturn(md.mockInfluenceSupportMatrix);
        md.mocks.stopStubbing();

        Map<Id, pq_Influence_And_Support_Matrix__c> result = InfluenceSupportMatrixService.getMatrixesForAccountPlan(
            new Set<Id>{ md.mockAccountPlanId }
        );

        pq_Influence_And_Support_Matrix__c matrix = result.get(md.mockAccountPlanId);

        System.assertEquals(md.mockInfluenceSupportMatrixId, matrix.Id);
    }

    @isTest
    static void getMatrixesForAccountPlanGlobalTest() {
        testMockData md = new testMockData();
        AccountPlanMatrixAssociationSelector mockAccountPlanMatrixAssociationSelector = md.mockAccountPlanMatrixAssociationSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;
        InfluenceSupportMatrixSelector mockInfluenceSupportMatrixSelector = md.mockInfluenceSupportMatrixSelector;

        Set<Id> accountPlanIds = new Set<Id>{ md.mockAccountPlanId };
        RM_Chart_Setting__c setting = md.mockRMChartSettingForAccountPlan;
        setting.Is_Influence_Support_Global_Scope__c = true;

        Map<Id, RM_Chart_Setting__c> settingsMap = new Map<Id, RM_Chart_Setting__c>();
        settingsMap.put(md.mockAccountPlanId, setting);

        pq_Account_Plan_Matrix_Association__c accountPlanMatrix = new pq_Account_Plan_Matrix_Association__c(
            Account_Plan__c = md.mockAccountPlanId,
            Influence_And_Support_Matrix__c = fflib_IDGenerator.generate(pq_Influence_And_Support_Matrix__c.SObjectType)
        );

        md.mocks.startStubbing();
        md.mocks.when(
                mockRMChartSettingService.getRelationshipMapSettingForObjects(
                    new Set<Id>{ md.mockAccountPlanId },
                    false
                )
            )
            .thenReturn(settingsMap);
        md.mocks.when(mockAccountPlanMatrixAssociationSelector.selectByAccountPlans(accountPlanIds))
            .thenReturn(new List<pq_Account_Plan_Matrix_Association__c>{ accountPlanMatrix });
        md.mocks.when(mockInfluenceSupportMatrixSelector.selectDefault()).thenReturn(md.mockInfluenceSupportMatrix);
        md.mocks.stopStubbing();

        Map<Id, pq_Influence_And_Support_Matrix__c> result = InfluenceSupportMatrixService.getMatrixesForAccountPlan(
            new Set<Id>{ md.mockAccountPlanId }
        );
        pq_Influence_And_Support_Matrix__c matrix = result.get(md.mockAccountPlanId);

        System.assertEquals(md.mockInfluenceSupportMatrixId, matrix.Id);
    }

    @isTest
    static void getMatrixesForAccountPlanTest() {
        testMockData md = new testMockData();
        AccountPlanMatrixAssociationSelector mockAccountPlanMatrixAssociationSelector = md.mockAccountPlanMatrixAssociationSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;

        Set<Id> accountPlanIds = new Set<Id>{ md.mockAccountPlanId };
        RM_Chart_Setting__c setting = md.mockRMChartSettingForRelationshipMap;
        setting.Is_Influence_Support_Global_Scope__c = false;

        pq_Account_Plan_Matrix_Association__c accountPlanMatrix = new pq_Account_Plan_Matrix_Association__c(
            Account_Plan__c = md.mockAccountPlanId,
            Influence_And_Support_Matrix__c = fflib_IDGenerator.generate(pq_Influence_And_Support_Matrix__c.SObjectType)
        );

        Map<Id, RM_Chart_Setting__c> settingsMap = new Map<Id, RM_Chart_Setting__c>();
        settingsMap.put(md.mockAccountPlanId, setting);

        md.mocks.startStubbing();
        md.mocks.when(
                mockRMChartSettingService.getRelationshipMapSettingForObjects(
                    new Set<Id>{ md.mockAccountPlanId },
                    false
                )
            )
            .thenReturn(settingsMap);
        md.mocks.when(mockAccountPlanMatrixAssociationSelector.selectByAccountPlans(accountPlanIds))
            .thenReturn(new List<pq_Account_Plan_Matrix_Association__c>{ accountPlanMatrix });
        md.mocks.stopStubbing();

        Map<Id, pq_Influence_And_Support_Matrix__c> result = InfluenceSupportMatrixService.getMatrixesForAccountPlan(
            new Set<Id>{ md.mockAccountPlanId }
        );
        pq_Influence_And_Support_Matrix__c matrix = result.get(md.mockAccountPlanId);
        System.assertEquals(accountPlanMatrix.Influence_And_Support_Matrix__c, matrix.Id);
    }

    @isTest
    static void getInfluencesByMatrixesTest() {
        testMockData md = new testMockData();
        InfluenceMatrixAssociationSelector mockInfluenceMatrixAssociationSelector = md.mockInfluenceMatrixAssociationSelector;

        Set<Id> matrixIdSet = new Set<Id>{ md.mockInfluenceSupportMatrixId };

        pq_Influence__c s1 = new pq_Influence__c(Name = 'high', Label__c = 'highlabel');
        insert s1;
        pq_Influence_And_Support_Matrix__c m1 = new pq_Influence_And_Support_Matrix__c(Name = 'one');
        insert m1;
        pq_Influence_Matrix_Association__c input1 = new pq_Influence_Matrix_Association__c(
            Order__c = 1,
            Influence__c = s1.Id,
            Influence_And_Support_Matrix__c = m1.Id
        );
        insert input1;

        List<pq_Influence_Matrix_Association__c> influenceAssocs = [
            SELECT Influence__c, Influence__r.Name, Influence__r.Label__c
            FROM pq_Influence_Matrix_Association__c
        ];

        md.mocks.startStubbing();
        md.mocks.when(mockInfluenceMatrixAssociationSelector.selectByMatrixId(matrixIdSet)).thenReturn(influenceAssocs);
        md.mocks.stopStubbing();

        List<pq_Influence__c> result = InfluenceSupportMatrixService.getInfluencesByMatrixes(matrixIdSet);

        System.assertEquals(1, result.size());
        System.assertEquals('high', result[0].Name);
        System.assertEquals('highlabel', result[0].Label__c);
    }

    @isTest
    static void getSupportByMatrixesTest() {
        testMockData md = new testMockData();
        SupportMatrixAssociationSelector mockSupportMatrixAssociationSelector = md.mockSupportMatrixAssociationSelector;

        Set<Id> matrixIdSet = new Set<Id>{ md.mockInfluenceSupportMatrixId };

        pq_Support__c s1 = new pq_Support__c(Name = 'blocker', Label__c = 'blockerlabel', Color__c = '#ff0011');
        insert s1;
        pq_Influence_And_Support_Matrix__c m1 = new pq_Influence_And_Support_Matrix__c(Name = 'one');
        insert m1;
        pq_Support_Matrix_Association__c input1 = new pq_Support_Matrix_Association__c(
            Order__c = 1,
            Support__c = s1.Id,
            Influence_And_Support_Matrix__c = m1.Id
        );
        insert input1;

        List<pq_Support_Matrix_Association__c> supportAssocs = [
            SELECT Support__c, Support__r.Name, Support__r.Label__c, Support__r.Color__c
            FROM pq_Support_Matrix_Association__c
        ];

        md.mocks.startStubbing();
        md.mocks.when(mockSupportMatrixAssociationSelector.selectByMatrixId(matrixIdSet)).thenReturn(supportAssocs);
        md.mocks.stopStubbing();

        List<pq_Support__c> result = InfluenceSupportMatrixService.getSupportByMatrixes(matrixIdSet);

        System.assertEquals(1, result.size());
        System.assertEquals('blocker', result[0].Name);
        System.assertEquals('blockerlabel', result[0].Label__c);
        System.assertEquals('#ff0011', result[0].Color__c);
    }

    @isTest
    static void buildMatrixMemberForKSTest() {
        Account_Plan__c accountPlan = TestDataFactory.createAccountPlan('planName');
        Contact c2 = new Contact(LastName = 'Test');
        insert c2;
        Contact c1 = new Contact(LastName = 'Test', ReportsToId = c2.Id);
        insert c1;

        Key_Stakeholder__c ks = new Key_Stakeholder__c(Contact__c = c1.Id, Account_Plan__c = accountPlan.Id);
        insert ks;

        String field = 'CreatedDate';
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Key_Stakeholder__c.fields.getMap();
        schema.SobjectField sObjectField = mapFields.get(field);
        Map<String, FieldMetaData> descFieldMap = new Map<String, FieldMetaData>();
        descFieldMap.put(field, new FieldMetaData(Key_Stakeholder__c.SObjectType, sObjectField));

        RM_Chart_Setting__c setting = new RM_Chart_Setting__c(
            Id = fflib_IDGenerator.generate(RM_Chart_Setting__c.SObjectType),
            Is_Reports_To_Global_Scope__c = true
        );
        Map<Id, Id> reportsToMap = new Map<Id, Id>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();

        contactMap.put(c1.Id, c1);
        contactMap.put(c2.Id, c2);
        reportsToMap.put(c1.Id, c2.Id);

        Matrixmember result = InfluenceSupportMatrixService.buildMatrixMemberForKS(
            ks,
            descFieldMap,
            setting,
            reportsToMap,
            contactMap
        );

        System.assertNotEquals(null, result.additionalFields);
        System.assertEquals(true, result.additionalFields.size() == 2);
    }

    @isTest
    static void buildMatrixMemberForMapMemberTest() {
        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('mapName');
        Contact c2 = new Contact(LastName = 'Test');
        insert c2;
        Contact c1 = new Contact(LastName = 'Test', ReportsToId = c2.Id);
        insert c1;

        Relationship_Map_Member__c rmm = new Relationship_Map_Member__c(
            Contact__c = c1.Id,
            Relationship_Map__c = rm.Id
        );
        insert rmm;

        String field = 'CreatedDate';
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Key_Stakeholder__c.fields.getMap();
        schema.SobjectField sObjectField = mapFields.get(field);
        Map<String, FieldMetaData> descFieldMap = new Map<String, FieldMetaData>();
        descFieldMap.put(field, new FieldMetaData(Key_Stakeholder__c.SObjectType, sObjectField));

        RM_Chart_Setting__c setting = new RM_Chart_Setting__c(
            Id = fflib_IDGenerator.generate(RM_Chart_Setting__c.SObjectType),
            Is_Reports_To_Global_Scope__c = true
        );
        Map<Id, Id> reportsToMap = new Map<Id, Id>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();

        contactMap.put(c1.Id, c1);
        contactMap.put(c2.Id, c2);
        reportsToMap.put(c1.Id, c2.Id);

        Matrixmember result = InfluenceSupportMatrixService.buildMatrixMemberForMapMember(
            rmm,
            descFieldMap,
            setting,
            reportsToMap,
            contactMap
        );

        System.assertNotEquals(null, result.additionalFields);
        System.assertEquals(true, result.additionalFields.size() == 2);
    }
}