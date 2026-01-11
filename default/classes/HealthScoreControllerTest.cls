@SuppressWarnings('PMD.NcssTypeCount')
@IsTest
public with sharing class HealthScoreControllerTest {
    @isTest
    private static void getColorSettingsNullTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(null);
        md.mocks.stopStubbing();

        ColorBoundary result = HealthScoreController.getColorSettings();
        System.assertNotEquals(null, result, 'Should return a colorBoundary result');
        System.assertEquals('#E1341E', result.lowColor, 'Default low color should be #E1341E');
        System.assertEquals('#EB8214', result.midColor, 'Default mid color should be #EB8214');
        System.assertEquals('#2DD24A', result.highColor, 'Default high color should be #2DD24A');
        System.assertEquals(.25, result.lowMidBoundary, 'Default low-mid boundary should be .25');
        System.assertEquals(.75, result.midHighBoundary, 'Default mid-high boundary should be .75');
    }

    @isTest
    private static void getColorSettingsTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockSettings.Score_Low_Color__c = '#FFFF11';
        md.mockSettings.Score_Mid_Color__c = '#FFFF22';
        md.mockSettings.Score_High_Color__c = '#FFFF33';
        md.mockSettings.Score_Low_Mid_Boundary__c = .1;
        md.mockSettings.Score_Mid_High_Boundary__c = .9;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        ColorBoundary result = HealthScoreController.getColorSettings();
        System.assertNotEquals(null, result, 'Should return a colorBoundary result');
        System.assertEquals(
            md.mockSettings.Score_Low_Color__c,
            result.lowColor,
            'Default low color should match settings'
        );
        System.assertEquals(
            md.mockSettings.Score_Mid_Color__c,
            result.midColor,
            'Default mid color should match settings'
        );
        System.assertEquals(
            md.mockSettings.Score_High_Color__c,
            result.highColor,
            'Default high color should match settings'
        );
        System.assertEquals(
            md.mockSettings.Score_Low_Mid_Boundary__c,
            result.lowMidBoundary,
            'Default low-mid boundary should match settings'
        );
        System.assertEquals(
            md.mockSettings.Score_Mid_High_Boundary__c,
            result.midHighBoundary,
            'Default mid-high boundary should match settings'
        );
    }

    @isTest
    private static void updateColorSettingsNullTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        CRUSH_Settings_Obj__c result = HealthScoreController.updateColorSettings(null);

        ((SettingServiceImpl) md.mocks.verify(mockSettingService, 0))
            .upsertSettings((CRUSH_Settings_Obj__c) fflib_Match.sObjectOfType(CRUSH_Settings_Obj__c.SObjectType));
        System.assertEquals(md.mockSettings, result, 'should return existing settings if null is passed in');
    }

    @isTest
    private static void updateColorSettingsTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockSettings.Score_Low_Color__c = '#FFFF11';
        md.mockSettings.Score_Mid_Color__c = '#FFFF22';
        md.mockSettings.Score_High_Color__c = '#FFFF33';
        md.mockSettings.Score_Low_Mid_Boundary__c = .1;
        md.mockSettings.Score_Mid_High_Boundary__c = .9;

        ColorBoundary cb = new ColorBoundary();

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        CRUSH_Settings_Obj__c result = HealthScoreController.updateColorSettings(cb);

        ((SettingServiceImpl) md.mocks.verify(mockSettingService, 1))
            .upsertSettings((CRUSH_Settings_Obj__c) fflib_Match.sObjectOfType(CRUSH_Settings_Obj__c.SObjectType));
        System.assertEquals(cb.lowColor, result.Score_Low_Color__c, 'updated setting should have new low color');
        System.assertEquals(cb.midColor, result.Score_Mid_Color__c, 'updated setting should have new mid color');
        System.assertEquals(cb.highColor, result.Score_High_Color__c, 'updated setting should have new high color');
        System.assertEquals(
            cb.lowMidBoundary,
            result.Score_Low_Mid_Boundary__c,
            'updated setting should have new low-mid boundary'
        );
        System.assertEquals(
            cb.midHighBoundary,
            result.Score_Mid_High_Boundary__c,
            'updated setting should have new mid-high boundary'
        );
    }

    @isTest
    private static void getTotalHealthScoreForAccountPlanNullIdTest() {
        Decimal mockPoints = 45;
        Decimal mockMaxPoints1 = 100;
        Decimal mockMaxPoints2 = 37;
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockAccountPlan.Intermediate_Score__c = mockPoints;
        Formula.recalculateFormulas(new List<Account_Plan__c>{ md.mockAccountPlan });

        PQ_AP_Score__mdt mockAPScore1 = new PQ_AP_Score__mdt();
        mockAPScore1.Score_BP_High__c = mockMaxPoints1;
        PQ_AP_Score__mdt mockAPScore2 = new PQ_AP_Score__mdt();
        mockAPScore2.Score_BP_High__c = mockMaxPoints2;

        Set<String> fieldNames = new Set<String>{ Account_Plan__c.Account_Plan_Score__c.getDescribe().getName() };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        HealthScoreController.HealthScoreWrapper result = HealthScoreController.getTotalHealthScoreForAccountPlan(null);
        System.AssertEquals(null, result, 'If the account plan id is null, the result should be null');
    }

    @isTest
    private static void getTotalHealthScoreForAccountPlanInvalidIdTest() {
        Decimal mockPoints = 45;
        Decimal mockMaxPoints1 = 100;
        Decimal mockMaxPoints2 = 37;
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockAccountPlan.Intermediate_Score__c = mockPoints;
        Formula.recalculateFormulas(new List<Account_Plan__c>{ md.mockAccountPlan });

        PQ_AP_Score__mdt mockAPScore1 = new PQ_AP_Score__mdt();
        mockAPScore1.Score_BP_High__c = mockMaxPoints1;
        PQ_AP_Score__mdt mockAPScore2 = new PQ_AP_Score__mdt();
        mockAPScore2.Score_BP_High__c = mockMaxPoints2;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockAPScore1, mockAPScore2 };

        Set<String> fieldNames = new Set<String>{ Account_Plan__c.Account_Plan_Score__c.getDescribe().getName() };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(null);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        HealthScoreController.HealthScoreWrapper result = HealthScoreController.getTotalHealthScoreForAccountPlan(
            md.mockAccountPlanId
        );
        System.AssertEquals(null, result, 'If the account plan id is invalid, the result should be null');
    }

    @isTest
    private static void getTotalHealthScoreForAccountPlanNoFieldsTest() {
        Decimal mockPoints = 45;
        Decimal mockMaxPoints1 = 100;
        Decimal mockMaxPoints2 = 37;
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockAccountPlan.Intermediate_Score__c = mockPoints;
        Formula.recalculateFormulas(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mockSettings.Use_Default_Account_Plan_Score__c = false;

        PQ_AP_Score__mdt mockAPScore1 = new PQ_AP_Score__mdt();
        mockAPScore1.Score_BP_High__c = mockMaxPoints1;
        PQ_AP_Score__mdt mockAPScore2 = new PQ_AP_Score__mdt();
        mockAPScore2.Score_BP_High__c = mockMaxPoints2;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockAPScore1, mockAPScore2 };

        Set<String> fieldNames = new Set<String>();

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    (String) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(hss.getMaxTotalScore()).thenReturn(mockMaxPoints1 + mockMaxPoints2);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(new ColorBoundary());
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        HealthScoreController.HealthScoreWrapper result = HealthScoreController.getTotalHealthScoreForAccountPlan(
            md.mockAccountPlanId
        );
        System.AssertEquals(null, result, 'If the score metadata doesn\'t match any fields, the result should be null');
    }

    @isTest
    private static void getTotalHealthScoreForAccountPlanTest() {
        Decimal mockPoints = 45;
        Decimal mockMaxPoints1 = 100;
        Decimal mockMaxPoints2 = 37;
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockAccountPlan.Intermediate_Score__c = mockPoints;
        Formula.recalculateFormulas(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mockSettings.Use_Default_Account_Plan_Score__c = false;

        PQ_AP_Score__mdt mockAPScore1 = new PQ_AP_Score__mdt();
        mockAPScore1.Score_BP_High__c = mockMaxPoints1;
        PQ_AP_Score__mdt mockAPScore2 = new PQ_AP_Score__mdt();
        mockAPScore2.Score_BP_High__c = mockMaxPoints2;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockAPScore1, mockAPScore2 };

        Set<String> fieldNames = new Set<String>{ Account_Plan__c.Account_Plan_Score__c.getDescribe().getName() };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    (String) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(hss.getMaxTotalScore()).thenReturn(mockMaxPoints1 + mockMaxPoints2);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(new ColorBoundary());
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        HealthScoreController.HealthScoreWrapper result = HealthScoreController.getTotalHealthScoreForAccountPlan(
            md.mockAccountPlanId
        );
        System.AssertEquals(mockPoints, result.points, 'Should have expected points');
        System.AssertEquals(mockMaxPoints1 + mockMaxPoints2, result.maxPoints, 'Should have expected maximum points');
    }

    @isTest
    private static void getTotalHealthScoreForAccountPlanUpdateScoreTest() {
        Decimal oldPoints = 12;
        Decimal mockPoints = 45;
        Decimal mockMaxPoints = 100;
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockAccountPlan.Intermediate_Score__c = oldPoints;
        Formula.recalculateFormulas(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mockSettings.Use_Default_Account_Plan_Score__c = true;

        PQ_AP_Score__mdt mockAPScore1 = new PQ_AP_Score__mdt();

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockAPScore1 };

        Set<String> fieldNames = new Set<String>{ Account_Plan__c.Account_Plan_Score__c.getDescribe().getName() };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    (String) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(hss.getMaxTotalScore()).thenReturn(mockMaxPoints);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(new ColorBoundary());
        md.mocks.when(hss.getTotalScoreForAccountPlan(md.mockAccountPlan, mockScoreResults)).thenReturn(mockPoints);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        HealthScoreController.HealthScoreWrapper result = HealthScoreController.getTotalHealthScoreForAccountPlan(
            md.mockAccountPlanId
        );
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(md.mockAccountPlan);
        System.AssertEquals(mockPoints, result.points, 'Result should have updated points');
        System.AssertEquals(mockPoints, md.mockAccountPlan.Intermediate_Score__c, 'Plan should have updated points');
    }

    @isTest
    private static void getTotalHealthScoreLowColorTest() {
        Decimal mockPoints = 10;
        Decimal mockMaxPoints = 100;
        String mockColor = '#BAC';
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockAccountPlan.Intermediate_Score__c = mockPoints;
        Formula.recalculateFormulas(new List<Account_Plan__c>{ md.mockAccountPlan });

        PQ_AP_Score__mdt mockAPScore = new PQ_AP_Score__mdt();

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockAPScore };

        ColorBoundary mockCB = new ColorBoundary();
        mockCB.lowColor = mockColor;
        mockCB.lowMidBoundary = .3;
        mockCB.midHighBoundary = .8;

        Set<String> fieldNames = new Set<String>{ Account_Plan__c.Account_Plan_Score__c.getDescribe().getName() };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    (String) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(hss.getMaxTotalScore()).thenReturn(mockMaxPoints);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(mockCB);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        HealthScoreController.HealthScoreWrapper result = HealthScoreController.getTotalHealthScoreForAccountPlan(
            md.mockAccountPlanId
        );
        System.AssertEquals(mockColor, result.color, 'Should have expected low color');
    }

    @isTest
    private static void getTotalHealthScoreMidColorTest() {
        Decimal mockPoints = 50;
        Decimal mockMaxPoints = 100;
        String mockColor = '#BAC';
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockAccountPlan.Intermediate_Score__c = mockPoints;
        Formula.recalculateFormulas(new List<Account_Plan__c>{ md.mockAccountPlan });

        PQ_AP_Score__mdt mockAPScore = new PQ_AP_Score__mdt();

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockAPScore };

        ColorBoundary mockCB = new ColorBoundary();
        mockCB.midColor = mockColor;
        mockCB.lowMidBoundary = .3;
        mockCB.midHighBoundary = .8;

        Set<String> fieldNames = new Set<String>{ Account_Plan__c.Account_Plan_Score__c.getDescribe().getName() };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    (String) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(hss.getMaxTotalScore()).thenReturn(mockMaxPoints);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(mockCB);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        HealthScoreController.HealthScoreWrapper result = HealthScoreController.getTotalHealthScoreForAccountPlan(
            md.mockAccountPlanId
        );
        System.AssertEquals(mockColor, result.color, 'Should have expected mid color');
    }

    @isTest
    private static void getTotalHealthScoreHighColorTest() {
        Decimal mockPoints = 90;
        Decimal mockMaxPoints = 100;
        String mockColor = '#BAC';
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockAccountPlan.Intermediate_Score__c = mockPoints;
        Formula.recalculateFormulas(new List<Account_Plan__c>{ md.mockAccountPlan });

        PQ_AP_Score__mdt mockAPScore = new PQ_AP_Score__mdt();

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockAPScore };

        ColorBoundary mockCB = new ColorBoundary();
        mockCB.highColor = mockColor;
        mockCB.lowMidBoundary = .3;
        mockCB.midHighBoundary = .8;

        Set<String> fieldNames = new Set<String>{ Account_Plan__c.Account_Plan_Score__c.getDescribe().getName() };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    (String) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(hss.getMaxTotalScore()).thenReturn(mockMaxPoints);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(mockCB);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        HealthScoreController.HealthScoreWrapper result = HealthScoreController.getTotalHealthScoreForAccountPlan(
            md.mockAccountPlanId
        );
        System.AssertEquals(mockColor, result.color, 'Should have expected high color');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanNullIdTest() {
        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlan(
            null
        );
        System.AssertEquals(0, result.size(), 'Should have no scores if null plan Id passed');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanInvalidPlanTest() {
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        List<String> scoreNames = new List<String>{
            'CS_Cells',
            'Key_Dates',
            'Stakeholders',
            'Objective',
            'AP_Opp',
            'SWOT'
        };

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>();
        for (Integer i = 0; i < scoreNames.size(); i++) {
            PQ_AP_Score__mdt mockScore = new PQ_AP_Score__mdt();
            mockScore.Id = fflib_IDGenerator.generate(PQ_AP_Score__mdt.SObjectType);
            mockScore.DeveloperName = scoreNames[i];
            mockScore.Score_BP_High__c = i + 1;
            mockScoreResults.add(mockScore);
        }

        Set<String> fieldNames = new Set<String>{
            Account_Plan__c.Score_CS__c.getDescribe().getName(),
            Account_Plan__c.Score_KD__c.getDescribe().getName(),
            Account_Plan__c.Score_KS__c.getDescribe().getName(),
            Account_Plan__c.Score_Objective__c.getDescribe().getName(),
            Account_Plan__c.Score_Opportunity__c.getDescribe().getName(),
            Account_Plan__c.Score_SWOT__c.getDescribe().getName()
        };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(null);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(
                hss.getScoreFromPlanForMetadata(
                    (Account_Plan__c) fflib_Match.anyObject(),
                    (PQ_AP_Score__mdt) fflib_Match.anyObject()
                )
            )
            .thenReturn(1);
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlan(
            md.mockAccountPlanId
        );
        System.AssertEquals(0, result.size(), 'Should have no scores if invalid plan Id passed');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanNoValuesTest() {
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        String mockAPJSON =
            '{"Id": "' +
            md.mockAccountPlanId +
            '", "pqcrush__Account__c":"' +
            md.mockAccountId +
            '","pqcrush__Score_CS__c":"' +
            5 +
            '","pqcrush__Score_KD__c":"' +
            5 +
            '","pqcrush__Score_KS__c":"' +
            5 +
            '","pqcrush__Score_Objective__c":"' +
            5 +
            '","pqcrush__Score_Opportunity__c":"' +
            2 +
            '","pqcrush__Score_SWOT__c":"' +
            5 +
            '"}';

        Account_Plan__c mockAP = (Account_Plan__c) JSON.deserialize(mockAPJSON, Account_Plan__c.class);

        Set<String> fieldNames = new Set<String>{
            Account_Plan__c.Score_CS__c.getDescribe().getName(),
            Account_Plan__c.Score_KD__c.getDescribe().getName(),
            Account_Plan__c.Score_KS__c.getDescribe().getName(),
            Account_Plan__c.Score_Objective__c.getDescribe().getName(),
            Account_Plan__c.Score_Opportunity__c.getDescribe().getName(),
            Account_Plan__c.Score_SWOT__c.getDescribe().getName()
        };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(mockAP);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(new List<PQ_AP_Score__mdt>());
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlan(
            md.mockAccountPlanId
        );
        System.AssertEquals(0, result.size(), 'Should have no scores if no enabled values');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanNoFieldsTest() {
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        PQ_AP_Score__mdt mockScore = new PQ_AP_Score__mdt();
        mockScore.Id = fflib_IDGenerator.generate(PQ_AP_Score__mdt.SObjectType);
        mockScore.DeveloperName = 'CS_Cells';
        mockScore.Score_BP_High__c = 15;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockScore };

        Set<String> fieldNames = new Set<String>();

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(
                hss.getScoreFromPlanForMetadata(
                    (Account_Plan__c) fflib_Match.anyObject(),
                    (PQ_AP_Score__mdt) fflib_Match.anyObject()
                )
            )
            .thenReturn(12);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(new ColorBoundary());
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlan(
            md.mockAccountPlanId
        );
        System.AssertEquals(0, result.size(), 'Should have no scores if the score metadata doesn\'t match any fields');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanAllValuesTest() {
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        List<String> scoreNames = new List<String>{
            'CS_Cells',
            'Key_Dates',
            'Stakeholders',
            'Objective',
            'AP_Opp',
            'SWOT'
        };

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>();
        for (Integer i = 0; i < scoreNames.size(); i++) {
            PQ_AP_Score__mdt mockScore = new PQ_AP_Score__mdt();
            mockScore.Id = fflib_IDGenerator.generate(PQ_AP_Score__mdt.SObjectType);
            mockScore.DeveloperName = scoreNames[i];
            mockScore.Score_BP_High__c = i + 1;
            mockScoreResults.add(mockScore);
        }

        Set<String> fieldNames = new Set<String>{
            Account_Plan__c.Score_CS__c.getDescribe().getName(),
            Account_Plan__c.Score_KD__c.getDescribe().getName(),
            Account_Plan__c.Score_KS__c.getDescribe().getName(),
            Account_Plan__c.Score_Objective__c.getDescribe().getName(),
            Account_Plan__c.Score_Opportunity__c.getDescribe().getName(),
            Account_Plan__c.Score_SWOT__c.getDescribe().getName()
        };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(
                hss.getScoreFromPlanForMetadata(
                    (Account_Plan__c) fflib_Match.anyObject(),
                    (PQ_AP_Score__mdt) fflib_Match.anyObject()
                )
            )
            .thenReturn(1);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(new ColorBoundary());
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlan(
            md.mockAccountPlanId
        );
        System.AssertEquals(6, result.size(), 'Should have all expected scores');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanDetailTest() {
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        PQ_AP_Score__mdt mockScore = new PQ_AP_Score__mdt();
        mockScore.Id = fflib_IDGenerator.generate(PQ_AP_Score__mdt.SObjectType);
        mockScore.DeveloperName = 'CS_Cells';
        mockScore.Score_BP_High__c = 15;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockScore };

        Set<String> fieldNames = new Set<String>{
            Account_Plan__c.Score_CS__c.getDescribe().getName(),
            Account_Plan__c.Score_KD__c.getDescribe().getName(),
            Account_Plan__c.Score_KS__c.getDescribe().getName(),
            Account_Plan__c.Score_Objective__c.getDescribe().getName(),
            Account_Plan__c.Score_Opportunity__c.getDescribe().getName(),
            Account_Plan__c.Score_SWOT__c.getDescribe().getName()
        };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(
                hss.getScoreFromPlanForMetadata(
                    (Account_Plan__c) fflib_Match.anyObject(),
                    (PQ_AP_Score__mdt) fflib_Match.anyObject()
                )
            )
            .thenReturn(12);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(new ColorBoundary());
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlan(
            md.mockAccountPlanId
        );

        String expectedLabel = String.format(System.label.Score_Label, new List<String>{ System.Label.Cross_Sell_Map });
        System.AssertEquals(1, result.size(), 'Should have one expected score');
        System.AssertEquals(12, result[0].points, 'Should have expected points');
        System.AssertEquals(15, result[0].maxPoints, 'Should have expected maximum points');
        System.assertEquals(expectedLabel, result[0].label, 'Should have expected label');
        System.assertEquals(mockScore.Id, result[0].id, 'Should have expected score id');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanMetadataScoreLabelTest() {
        String expectedLabel = 'This is the label - test gihsfaplfmt';
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        PQ_AP_Score__mdt mockScore = new PQ_AP_Score__mdt();
        mockScore.Id = fflib_IDGenerator.generate(PQ_AP_Score__mdt.SObjectType);
        mockScore.Score_Label__c = expectedLabel;
        mockScore.Score_BP_High__c = 15;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockScore };

        Set<String> fieldNames = new Set<String>{
            Account_Plan__c.Score_CS__c.getDescribe().getName(),
            Account_Plan__c.Score_KD__c.getDescribe().getName(),
            Account_Plan__c.Score_KS__c.getDescribe().getName(),
            Account_Plan__c.Score_Objective__c.getDescribe().getName(),
            Account_Plan__c.Score_Opportunity__c.getDescribe().getName(),
            Account_Plan__c.Score_SWOT__c.getDescribe().getName()
        };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(
                hss.getScoreFromPlanForMetadata(
                    (Account_Plan__c) fflib_Match.anyObject(),
                    (PQ_AP_Score__mdt) fflib_Match.anyObject()
                )
            )
            .thenReturn(12);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(new ColorBoundary());
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlan(
            md.mockAccountPlanId
        );

        System.AssertEquals(1, result.size(), 'Should have one expected score');
        System.assertEquals(expectedLabel, result[0].label, 'Should have expected label');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanMetadataLabelTest() {
        String expectedLabel = 'This is the label - test gihsfaplfmt';
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        PQ_AP_Score__mdt mockScore = new PQ_AP_Score__mdt();
        mockScore.Id = fflib_IDGenerator.generate(PQ_AP_Score__mdt.SObjectType);
        mockScore.DeveloperName = 'no match';
        mockScore.Label = expectedLabel;
        mockScore.Score_BP_High__c = 15;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockScore };

        Set<String> fieldNames = new Set<String>{
            Account_Plan__c.Score_CS__c.getDescribe().getName(),
            Account_Plan__c.Score_KD__c.getDescribe().getName(),
            Account_Plan__c.Score_KS__c.getDescribe().getName(),
            Account_Plan__c.Score_Objective__c.getDescribe().getName(),
            Account_Plan__c.Score_Opportunity__c.getDescribe().getName(),
            Account_Plan__c.Score_SWOT__c.getDescribe().getName()
        };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(
                hss.getScoreFromPlanForMetadata(
                    (Account_Plan__c) fflib_Match.anyObject(),
                    (PQ_AP_Score__mdt) fflib_Match.anyObject()
                )
            )
            .thenReturn(12);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(new ColorBoundary());
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlan(
            md.mockAccountPlanId
        );

        System.AssertEquals(1, result.size(), 'Should have one expected score');
        System.assertEquals(expectedLabel, result[0].label, 'Should have expected label');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanLowColorTest() {
        Decimal mockPoints = 10;
        Decimal mockMaxPoints = 100;
        String mockColor = '#BAC';
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        PQ_AP_Score__mdt mockScore = new PQ_AP_Score__mdt();
        mockScore.Id = fflib_IDGenerator.generate(PQ_AP_Score__mdt.SObjectType);
        mockScore.DeveloperName = 'CS_Cells';
        mockScore.Score_BP_High__c = mockMaxPoints;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockScore };

        ColorBoundary mockCB = new ColorBoundary();
        mockCB.lowColor = mockColor;
        mockCB.lowMidBoundary = .3;
        mockCB.midHighBoundary = .8;

        Set<String> fieldNames = new Set<String>{
            Account_Plan__c.Score_CS__c.getDescribe().getName(),
            Account_Plan__c.Score_KD__c.getDescribe().getName(),
            Account_Plan__c.Score_KS__c.getDescribe().getName(),
            Account_Plan__c.Score_Objective__c.getDescribe().getName(),
            Account_Plan__c.Score_Opportunity__c.getDescribe().getName(),
            Account_Plan__c.Score_SWOT__c.getDescribe().getName()
        };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(
                hss.getScoreFromPlanForMetadata(
                    (Account_Plan__c) fflib_Match.anyObject(),
                    (PQ_AP_Score__mdt) fflib_Match.anyObject()
                )
            )
            .thenReturn(mockPoints);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(mockCB);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlan(
            md.mockAccountPlanId
        );

        System.AssertEquals(1, result.size(), 'Should have one expected score');
        System.AssertEquals(mockColor, result[0].color, 'Should have expected low color');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanMidColorTest() {
        Decimal mockPoints = 50;
        Decimal mockMaxPoints = 100;
        String mockColor = '#BAC';
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        PQ_AP_Score__mdt mockScore = new PQ_AP_Score__mdt();
        mockScore.Id = fflib_IDGenerator.generate(PQ_AP_Score__mdt.SObjectType);
        mockScore.DeveloperName = 'CS_Cells';
        mockScore.Score_BP_High__c = mockMaxPoints;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockScore };

        ColorBoundary mockCB = new ColorBoundary();
        mockCB.midColor = mockColor;
        mockCB.lowMidBoundary = .3;
        mockCB.midHighBoundary = .8;

        Set<String> fieldNames = new Set<String>{
            Account_Plan__c.Score_CS__c.getDescribe().getName(),
            Account_Plan__c.Score_KD__c.getDescribe().getName(),
            Account_Plan__c.Score_KS__c.getDescribe().getName(),
            Account_Plan__c.Score_Objective__c.getDescribe().getName(),
            Account_Plan__c.Score_Opportunity__c.getDescribe().getName(),
            Account_Plan__c.Score_SWOT__c.getDescribe().getName()
        };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(
                hss.getScoreFromPlanForMetadata(
                    (Account_Plan__c) fflib_Match.anyObject(),
                    (PQ_AP_Score__mdt) fflib_Match.anyObject()
                )
            )
            .thenReturn(mockPoints);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(mockCB);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlan(
            md.mockAccountPlanId
        );

        System.AssertEquals(1, result.size(), 'Should have one expected score');
        System.AssertEquals(mockColor, result[0].color, 'Should have expected mid color');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanHighColorTest() {
        Decimal mockPoints = 90;
        Decimal mockMaxPoints = 100;
        String mockColor = '#CBA';
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        PQ_AP_Score__mdt mockScore = new PQ_AP_Score__mdt();
        mockScore.Id = fflib_IDGenerator.generate(PQ_AP_Score__mdt.SObjectType);
        mockScore.DeveloperName = 'CS_Cells';
        mockScore.Score_BP_High__c = mockMaxPoints;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockScore };

        ColorBoundary mockCB = new ColorBoundary();
        mockCB.highColor = mockColor;
        mockCB.lowMidBoundary = .3;
        mockCB.midHighBoundary = .8;

        Set<String> fieldNames = new Set<String>{
            Account_Plan__c.Score_CS__c.getDescribe().getName(),
            Account_Plan__c.Score_KD__c.getDescribe().getName(),
            Account_Plan__c.Score_KS__c.getDescribe().getName(),
            Account_Plan__c.Score_Objective__c.getDescribe().getName(),
            Account_Plan__c.Score_Opportunity__c.getDescribe().getName(),
            Account_Plan__c.Score_SWOT__c.getDescribe().getName()
        };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(
                hss.getScoreFromPlanForMetadata(
                    (Account_Plan__c) fflib_Match.anyObject(),
                    (PQ_AP_Score__mdt) fflib_Match.anyObject()
                )
            )
            .thenReturn(mockPoints);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(mockCB);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlan(
            md.mockAccountPlanId
        );

        System.AssertEquals(1, result.size(), 'Should have one expected score');
        System.AssertEquals(mockColor, result[0].color, 'Should have expected high color');
    }

    @isTest
    private static void getTotalHealthScorePercentForAccountPlanNullIdTest() {
        Decimal mockPoints = 45;
        Decimal mockMaxPoints1 = 100;
        Decimal mockMaxPoints2 = 37;
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockAccountPlan.Intermediate_Score__c = mockPoints;
        Formula.recalculateFormulas(new List<Account_Plan__c>{ md.mockAccountPlan });

        PQ_AP_Score__mdt mockAPScore1 = new PQ_AP_Score__mdt();
        mockAPScore1.Score_BP_High__c = mockMaxPoints1;
        PQ_AP_Score__mdt mockAPScore2 = new PQ_AP_Score__mdt();
        mockAPScore2.Score_BP_High__c = mockMaxPoints2;

        Set<String> fieldNames = new Set<String>{ Account_Plan__c.Account_Plan_Score__c.getDescribe().getName() };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        HealthScoreController.HealthScoreWrapper result = HealthScoreController.getTotalHealthScoreForAccountPlanPercent(
            null
        );
        System.AssertEquals(null, result, 'If the account plan id is null, the result should be null');
    }

    @isTest
    private static void getTotalHealthScorePercentForAccountPlanInvalidIdTest() {
        Decimal mockPoints = 45;
        Decimal mockMaxPoints1 = 100;
        Decimal mockMaxPoints2 = 37;
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockAccountPlan.Intermediate_Score__c = mockPoints;
        Formula.recalculateFormulas(new List<Account_Plan__c>{ md.mockAccountPlan });

        PQ_AP_Score__mdt mockAPScore1 = new PQ_AP_Score__mdt();
        mockAPScore1.Score_BP_High__c = mockMaxPoints1;
        PQ_AP_Score__mdt mockAPScore2 = new PQ_AP_Score__mdt();
        mockAPScore2.Score_BP_High__c = mockMaxPoints2;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockAPScore1, mockAPScore2 };

        Set<String> fieldNames = new Set<String>{ Account_Plan__c.Account_Plan_Score__c.getDescribe().getName() };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(null);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        HealthScoreController.HealthScoreWrapper result = HealthScoreController.getTotalHealthScoreForAccountPlanPercent(
            md.mockAccountPlanId
        );
        System.AssertEquals(null, result, 'If the account plan id is invalid, the result should be null');
    }

    @isTest
    private static void getTotalHealthScorePercentForAccountPlanNoFieldsTest() {
        Decimal mockPoints = 45;
        Decimal mockMaxPoints1 = 100;
        Decimal mockMaxPoints2 = 37;
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockAccountPlan.Intermediate_Score__c = mockPoints;
        Formula.recalculateFormulas(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mockSettings.Use_Default_Account_Plan_Score__c = false;

        PQ_AP_Score__mdt mockAPScore1 = new PQ_AP_Score__mdt();
        mockAPScore1.Score_BP_High__c = mockMaxPoints1;
        PQ_AP_Score__mdt mockAPScore2 = new PQ_AP_Score__mdt();
        mockAPScore2.Score_BP_High__c = mockMaxPoints2;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockAPScore1, mockAPScore2 };

        Set<String> fieldNames = new Set<String>();

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    (String) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(hss.getMaxTotalScorePercent()).thenReturn(mockMaxPoints1 + mockMaxPoints2);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(new ColorBoundary());
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        HealthScoreController.HealthScoreWrapper result = HealthScoreController.getTotalHealthScoreForAccountPlanPercent(
            md.mockAccountPlanId
        );
        System.AssertEquals(null, result, 'If the score metadata doesn\'t match any fields, the result should be null');
    }

    @isTest
    private static void getTotalHealthScorePercentForAccountPlanTest() {
        Decimal mockPoints = 0;
        Decimal mockMaxPoints1 = 100;
        Decimal mockMaxPoints2 = 37;
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockAccountPlan.Intermediate_Score__c = mockPoints;
        Formula.recalculateFormulas(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mockSettings.Use_Default_Account_Plan_Score__c = false;

        PQ_AP_Score__mdt mockAPScore1 = new PQ_AP_Score__mdt();
        mockAPScore1.Score_BP_High__c = mockMaxPoints1;
        PQ_AP_Score__mdt mockAPScore2 = new PQ_AP_Score__mdt();
        mockAPScore2.Score_BP_High__c = mockMaxPoints2;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockAPScore1, mockAPScore2 };

        Set<String> fieldNames = new Set<String>{ Account_Plan__c.Account_Plan_Score__c.getDescribe().getName() };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    (String) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(hss.getMaxTotalScorePercent()).thenReturn(mockMaxPoints1 + mockMaxPoints2);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(new ColorBoundary());
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        HealthScoreController.HealthScoreWrapper result = HealthScoreController.getTotalHealthScoreForAccountPlanPercent(
            md.mockAccountPlanId
        );
        System.AssertEquals(mockPoints, result.points, 'Should have expected points');
        System.AssertEquals(mockMaxPoints1 + mockMaxPoints2, result.maxPoints, 'Should have expected maximum points');
    }

    @isTest
    private static void getTotalHealthScorePercentForAccountPlanUpdateScoreTest() {
        Decimal oldPoints = 12;
        Decimal mockPoints = 0;
        Decimal mockMaxPoints = 100;
        TestMockData md = new TestMockData();
        //fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockAccountPlan.Intermediate_Score__c = oldPoints;
        Formula.recalculateFormulas(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mockSettings.Use_Default_Account_Plan_Score__c = true;

        PQ_AP_Score__mdt mockAPScore1 = new PQ_AP_Score__mdt();

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockAPScore1 };

        Set<String> fieldNames = new Set<String>{ Account_Plan__c.Account_Plan_Score__c.getDescribe().getName() };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    (String) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(hss.getMaxTotalScorePercent()).thenReturn(mockMaxPoints);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(new ColorBoundary());
        md.mocks.when(hss.getTotalScoreForAccountPlan(md.mockAccountPlan, mockScoreResults)).thenReturn(mockPoints);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        HealthScoreController.HealthScoreWrapper result = HealthScoreController.getTotalHealthScoreForAccountPlanPercent(
            md.mockAccountPlanId
        );

        System.AssertEquals(result.points != null, true);
        System.AssertEquals(md.mockAccountPlan.Intermediate_Score__c != null, true);
    }

    @isTest
    private static void getTotalHealthScorePercentLowColorTest() {
        Decimal mockPoints = 10;
        Decimal mockMaxPoints = 100;
        String mockColor = '#BAC';
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockAccountPlan.Intermediate_Score__c = mockPoints;
        Formula.recalculateFormulas(new List<Account_Plan__c>{ md.mockAccountPlan });

        PQ_AP_Score__mdt mockAPScore = new PQ_AP_Score__mdt();

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockAPScore };

        ColorBoundary mockCB = new ColorBoundary();
        mockCB.lowColor = mockColor;
        mockCB.lowMidBoundary = .3;
        mockCB.midHighBoundary = .8;

        Set<String> fieldNames = new Set<String>{ Account_Plan__c.Account_Plan_Score__c.getDescribe().getName() };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    (String) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(hss.getMaxTotalScorePercent()).thenReturn(mockMaxPoints);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(mockCB);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        HealthScoreController.HealthScoreWrapper result = HealthScoreController.getTotalHealthScoreForAccountPlanPercent(
            md.mockAccountPlanId
        );
        System.AssertEquals(mockColor, result.color, 'Should have expected low color');
    }

    @isTest
    private static void getTotalHealthScorePercentMidColorTest() {
        Decimal mockPoints = 50;
        Decimal mockMaxPoints = 100;
        String mockColor = '#E1341E';
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockAccountPlan.Intermediate_Score__c = mockPoints;
        Formula.recalculateFormulas(new List<Account_Plan__c>{ md.mockAccountPlan });

        PQ_AP_Score__mdt mockAPScore = new PQ_AP_Score__mdt();

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockAPScore };

        ColorBoundary mockCB = new ColorBoundary();
        mockCB.midColor = mockColor;
        mockCB.lowMidBoundary = .3;
        mockCB.midHighBoundary = .8;

        Set<String> fieldNames = new Set<String>{ Account_Plan__c.Account_Plan_Score__c.getDescribe().getName() };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    (String) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(hss.getMaxTotalScorePercent()).thenReturn(mockMaxPoints);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(mockCB);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        HealthScoreController.HealthScoreWrapper result = HealthScoreController.getTotalHealthScoreForAccountPlanPercent(
            md.mockAccountPlanId
        );
        System.AssertEquals(mockColor, result.color, 'Should have expected mid color');
    }

    @isTest
    private static void getTotalHealthScorePercentHighColorTest() {
        Decimal mockPoints = 90;
        Decimal mockMaxPoints = 100;
        String mockColor = '#E1341E';
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockAccountPlan.Intermediate_Score__c = mockPoints;
        Formula.recalculateFormulas(new List<Account_Plan__c>{ md.mockAccountPlan });

        PQ_AP_Score__mdt mockAPScore = new PQ_AP_Score__mdt();

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockAPScore };

        ColorBoundary mockCB = new ColorBoundary();
        mockCB.highColor = mockColor;
        mockCB.lowMidBoundary = .3;
        mockCB.midHighBoundary = .8;

        Set<String> fieldNames = new Set<String>{ Account_Plan__c.Account_Plan_Score__c.getDescribe().getName() };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    (String) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(hss.getMaxTotalScorePercent()).thenReturn(mockMaxPoints);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(mockCB);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        HealthScoreController.HealthScoreWrapper result = HealthScoreController.getTotalHealthScoreForAccountPlanPercent(
            md.mockAccountPlanId
        );
        System.AssertEquals(mockColor, result.color, 'Should have expected high color');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanPercentNullIdTest() {
        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlanPercent(
            null
        );
        System.AssertEquals(0, result.size(), 'Should have no scores if null plan Id passed');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanPercentInvalidPlanTest() {
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        List<String> scoreNames = new List<String>{
            'CS_Cells',
            'Key_Dates',
            'Stakeholders',
            'Objective',
            'AP_Opp',
            'SWOT'
        };

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>();
        for (Integer i = 0; i < scoreNames.size(); i++) {
            PQ_AP_Score__mdt mockScore = new PQ_AP_Score__mdt();
            mockScore.Id = fflib_IDGenerator.generate(PQ_AP_Score__mdt.SObjectType);
            mockScore.DeveloperName = scoreNames[i];
            mockScore.Score_BP_High__c = i + 1;
            mockScoreResults.add(mockScore);
        }

        Set<String> fieldNames = new Set<String>{
            Account_Plan__c.Score_CS__c.getDescribe().getName(),
            Account_Plan__c.Score_KD__c.getDescribe().getName(),
            Account_Plan__c.Score_KS__c.getDescribe().getName(),
            Account_Plan__c.Score_Objective__c.getDescribe().getName(),
            Account_Plan__c.Score_Opportunity__c.getDescribe().getName(),
            Account_Plan__c.Score_SWOT__c.getDescribe().getName()
        };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(null);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(
                hss.getScoreFromPlanForMetadataPercent(
                    (Account_Plan__c) fflib_Match.anyObject(),
                    (PQ_AP_Score__mdt) fflib_Match.anyObject()
                )
            )
            .thenReturn(1);
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlanPercent(
            md.mockAccountPlanId
        );
        System.AssertEquals(0, result.size(), 'Should have no scores if invalid plan Id passed');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanPercentNoValuesTest() {
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        String mockAPJSON =
            '{"Id": "' +
            md.mockAccountPlanId +
            '", "pqcrush__Account__c":"' +
            md.mockAccountId +
            '","pqcrush__Score_CS__c":"' +
            5 +
            '","pqcrush__Score_KD__c":"' +
            5 +
            '","pqcrush__Score_KS__c":"' +
            5 +
            '","pqcrush__Score_Objective__c":"' +
            5 +
            '","pqcrush__Score_Opportunity__c":"' +
            2 +
            '","pqcrush__Score_SWOT__c":"' +
            5 +
            '"}';

        Account_Plan__c mockAP = (Account_Plan__c) JSON.deserialize(mockAPJSON, Account_Plan__c.class);

        Set<String> fieldNames = new Set<String>{
            Account_Plan__c.Score_CS__c.getDescribe().getName(),
            Account_Plan__c.Score_KD__c.getDescribe().getName(),
            Account_Plan__c.Score_KS__c.getDescribe().getName(),
            Account_Plan__c.Score_Objective__c.getDescribe().getName(),
            Account_Plan__c.Score_Opportunity__c.getDescribe().getName(),
            Account_Plan__c.Score_SWOT__c.getDescribe().getName()
        };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(mockAP);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(new List<PQ_AP_Score__mdt>());
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlanPercent(
            md.mockAccountPlanId
        );
        System.AssertEquals(0, result.size(), 'Should have no scores if no enabled values');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanPercentNoFieldsTest() {
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        PQ_AP_Score__mdt mockScore = new PQ_AP_Score__mdt();
        mockScore.Id = fflib_IDGenerator.generate(PQ_AP_Score__mdt.SObjectType);
        mockScore.DeveloperName = 'CS_Cells';
        mockScore.Score_BP_High__c = 15;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockScore };

        Set<String> fieldNames = new Set<String>();

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(
                hss.getScoreFromPlanForMetadataPercent(
                    (Account_Plan__c) fflib_Match.anyObject(),
                    (PQ_AP_Score__mdt) fflib_Match.anyObject()
                )
            )
            .thenReturn(12);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(new ColorBoundary());
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlanPercent(
            md.mockAccountPlanId
        );
        System.AssertEquals(0, result.size(), 'Should have no scores if the score metadata doesn\'t match any fields');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanPercentAllValuesTest() {
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        List<String> scoreNames = new List<String>{
            'CS_Cells',
            'Key_Dates',
            'Stakeholders',
            'Objective',
            'AP_Opp',
            'SWOT'
        };

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>();
        for (Integer i = 0; i < scoreNames.size(); i++) {
            PQ_AP_Score__mdt mockScore = new PQ_AP_Score__mdt();
            mockScore.Id = fflib_IDGenerator.generate(PQ_AP_Score__mdt.SObjectType);
            mockScore.DeveloperName = scoreNames[i];
            mockScore.Score_BP_High__c = i + 1;
            mockScoreResults.add(mockScore);
        }

        Set<String> fieldNames = new Set<String>{
            Account_Plan__c.Score_CS__c.getDescribe().getName(),
            Account_Plan__c.Score_KD__c.getDescribe().getName(),
            Account_Plan__c.Score_KS__c.getDescribe().getName(),
            Account_Plan__c.Score_Objective__c.getDescribe().getName(),
            Account_Plan__c.Score_Opportunity__c.getDescribe().getName(),
            Account_Plan__c.Score_SWOT__c.getDescribe().getName()
        };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(
                hss.getScoreFromPlanForMetadataPercent(
                    (Account_Plan__c) fflib_Match.anyObject(),
                    (PQ_AP_Score__mdt) fflib_Match.anyObject()
                )
            )
            .thenReturn(1);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(new ColorBoundary());
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlanPercent(
            md.mockAccountPlanId
        );
        System.AssertEquals(6, result.size(), 'Should have all expected scores');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanPercentDetailTest() {
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        PQ_AP_Score__mdt mockScore = new PQ_AP_Score__mdt();
        mockScore.Id = fflib_IDGenerator.generate(PQ_AP_Score__mdt.SObjectType);
        mockScore.DeveloperName = 'CS_Cells';
        mockScore.Score_BP_High__c = 15;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockScore };

        Set<String> fieldNames = new Set<String>{
            Account_Plan__c.Score_CS__c.getDescribe().getName(),
            Account_Plan__c.Score_KD__c.getDescribe().getName(),
            Account_Plan__c.Score_KS__c.getDescribe().getName(),
            Account_Plan__c.Score_Objective__c.getDescribe().getName(),
            Account_Plan__c.Score_Opportunity__c.getDescribe().getName(),
            Account_Plan__c.Score_SWOT__c.getDescribe().getName()
        };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(
                hss.getScoreFromPlanForMetadataPercent(
                    (Account_Plan__c) fflib_Match.anyObject(),
                    (PQ_AP_Score__mdt) fflib_Match.anyObject()
                )
            )
            .thenReturn(12);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(new ColorBoundary());
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlanPercent(
            md.mockAccountPlanId
        );

        String expectedLabel = String.format(System.label.Score_Label, new List<String>{ System.Label.Cross_Sell_Map });
        System.AssertEquals(1, result.size(), 'Should have one expected score');
        System.AssertEquals(12, result[0].points, 'Should have expected points');
        System.AssertEquals(15, result[0].maxPoints, 'Should have expected maximum points');
        System.assertEquals(expectedLabel, result[0].label, 'Should have expected label');
        System.assertEquals(mockScore.Id, result[0].id, 'Should have expected score id');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanPercentMetadataScoreLabelTest() {
        String expectedLabel = 'This is the label - test gihsfaplfmt';
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        PQ_AP_Score__mdt mockScore = new PQ_AP_Score__mdt();
        mockScore.Id = fflib_IDGenerator.generate(PQ_AP_Score__mdt.SObjectType);
        mockScore.Score_Label__c = expectedLabel;
        mockScore.Score_BP_High__c = 15;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockScore };

        Set<String> fieldNames = new Set<String>{
            Account_Plan__c.Score_CS__c.getDescribe().getName(),
            Account_Plan__c.Score_KD__c.getDescribe().getName(),
            Account_Plan__c.Score_KS__c.getDescribe().getName(),
            Account_Plan__c.Score_Objective__c.getDescribe().getName(),
            Account_Plan__c.Score_Opportunity__c.getDescribe().getName(),
            Account_Plan__c.Score_SWOT__c.getDescribe().getName()
        };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(
                hss.getScoreFromPlanForMetadataPercent(
                    (Account_Plan__c) fflib_Match.anyObject(),
                    (PQ_AP_Score__mdt) fflib_Match.anyObject()
                )
            )
            .thenReturn(12);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(new ColorBoundary());
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlanPercent(
            md.mockAccountPlanId
        );

        System.AssertEquals(1, result.size(), 'Should have one expected score');
        System.assertEquals(expectedLabel, result[0].label, 'Should have expected label');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanPercentMetadataLabelTest() {
        String expectedLabel = 'This is the label - test gihsfaplfmt';
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        PQ_AP_Score__mdt mockScore = new PQ_AP_Score__mdt();
        mockScore.Id = fflib_IDGenerator.generate(PQ_AP_Score__mdt.SObjectType);
        mockScore.DeveloperName = 'no match';
        mockScore.Label = expectedLabel;
        mockScore.Score_BP_High__c = 15;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockScore };

        Set<String> fieldNames = new Set<String>{
            Account_Plan__c.Score_CS__c.getDescribe().getName(),
            Account_Plan__c.Score_KD__c.getDescribe().getName(),
            Account_Plan__c.Score_KS__c.getDescribe().getName(),
            Account_Plan__c.Score_Objective__c.getDescribe().getName(),
            Account_Plan__c.Score_Opportunity__c.getDescribe().getName(),
            Account_Plan__c.Score_SWOT__c.getDescribe().getName()
        };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(
                hss.getScoreFromPlanForMetadataPercent(
                    (Account_Plan__c) fflib_Match.anyObject(),
                    (PQ_AP_Score__mdt) fflib_Match.anyObject()
                )
            )
            .thenReturn(12);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(new ColorBoundary());
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlanPercent(
            md.mockAccountPlanId
        );

        System.AssertEquals(1, result.size(), 'Should have one expected score');
        System.assertEquals(expectedLabel, result[0].label, 'Should have expected label');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanPercentLowColorTest() {
        Decimal mockPoints = 10;
        Decimal mockMaxPoints = 100;
        String mockColor = '#BAC';
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        PQ_AP_Score__mdt mockScore = new PQ_AP_Score__mdt();
        mockScore.Id = fflib_IDGenerator.generate(PQ_AP_Score__mdt.SObjectType);
        mockScore.DeveloperName = 'CS_Cells';
        mockScore.Score_BP_High__c = mockMaxPoints;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockScore };

        ColorBoundary mockCB = new ColorBoundary();
        mockCB.lowColor = mockColor;
        mockCB.lowMidBoundary = .3;
        mockCB.midHighBoundary = .8;

        Set<String> fieldNames = new Set<String>{
            Account_Plan__c.Score_CS__c.getDescribe().getName(),
            Account_Plan__c.Score_KD__c.getDescribe().getName(),
            Account_Plan__c.Score_KS__c.getDescribe().getName(),
            Account_Plan__c.Score_Objective__c.getDescribe().getName(),
            Account_Plan__c.Score_Opportunity__c.getDescribe().getName(),
            Account_Plan__c.Score_SWOT__c.getDescribe().getName()
        };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(
                hss.getScoreFromPlanForMetadataPercent(
                    (Account_Plan__c) fflib_Match.anyObject(),
                    (PQ_AP_Score__mdt) fflib_Match.anyObject()
                )
            )
            .thenReturn(mockPoints);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(mockCB);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlanPercent(
            md.mockAccountPlanId
        );

        System.AssertEquals(1, result.size(), 'Should have one expected score');
        System.AssertEquals(mockColor, result[0].color, 'Should have expected low color');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanPercentMidColorTest() {
        Decimal mockPoints = 50;
        Decimal mockMaxPoints = 100;
        String mockColor = '#BAC';
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        PQ_AP_Score__mdt mockScore = new PQ_AP_Score__mdt();
        mockScore.Id = fflib_IDGenerator.generate(PQ_AP_Score__mdt.SObjectType);
        mockScore.DeveloperName = 'CS_Cells';
        mockScore.Score_BP_High__c = mockMaxPoints;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockScore };

        ColorBoundary mockCB = new ColorBoundary();
        mockCB.midColor = mockColor;
        mockCB.lowMidBoundary = .3;
        mockCB.midHighBoundary = .8;

        Set<String> fieldNames = new Set<String>{
            Account_Plan__c.Score_CS__c.getDescribe().getName(),
            Account_Plan__c.Score_KD__c.getDescribe().getName(),
            Account_Plan__c.Score_KS__c.getDescribe().getName(),
            Account_Plan__c.Score_Objective__c.getDescribe().getName(),
            Account_Plan__c.Score_Opportunity__c.getDescribe().getName(),
            Account_Plan__c.Score_SWOT__c.getDescribe().getName()
        };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(
                hss.getScoreFromPlanForMetadataPercent(
                    (Account_Plan__c) fflib_Match.anyObject(),
                    (PQ_AP_Score__mdt) fflib_Match.anyObject()
                )
            )
            .thenReturn(mockPoints);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(mockCB);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlanPercent(
            md.mockAccountPlanId
        );

        System.AssertEquals(1, result.size(), 'Should have one expected score');
        System.AssertEquals(mockColor, result[0].color, 'Should have expected mid color');
    }

    @isTest
    private static void getIndividualHealthScoresForAccountPlanPercentHighColorTest() {
        Decimal mockPoints = 90;
        Decimal mockMaxPoints = 100;
        String mockColor = '#CBA';
        TestMockData md = new TestMockData();
        DynamicObjectQueryServiceImpl dqs = md.mockDynamicObjectQueryService;
        HealthScoreServiceImpl hss = md.mockHealthScoreService;
        SettingServiceImpl mockSettingService = md.mockSettingService;

        PQ_AP_Score__mdt mockScore = new PQ_AP_Score__mdt();
        mockScore.Id = fflib_IDGenerator.generate(PQ_AP_Score__mdt.SObjectType);
        mockScore.DeveloperName = 'CS_Cells';
        mockScore.Score_BP_High__c = mockMaxPoints;

        List<PQ_AP_Score__mdt> mockScoreResults = new List<PQ_AP_Score__mdt>{ mockScore };

        ColorBoundary mockCB = new ColorBoundary();
        mockCB.highColor = mockColor;
        mockCB.lowMidBoundary = .3;
        mockCB.midHighBoundary = .8;

        Set<String> fieldNames = new Set<String>{
            Account_Plan__c.Score_CS__c.getDescribe().getName(),
            Account_Plan__c.Score_KD__c.getDescribe().getName(),
            Account_Plan__c.Score_KS__c.getDescribe().getName(),
            Account_Plan__c.Score_Objective__c.getDescribe().getName(),
            Account_Plan__c.Score_Opportunity__c.getDescribe().getName(),
            Account_Plan__c.Score_SWOT__c.getDescribe().getName()
        };

        md.mocks.startStubbing();
        md.mocks.when(
                dqs.querySObjectWithTypeAndId(
                    Account_Plan__c.getSObjectType().getDescribe().getName(),
                    md.mockAccountPlanId,
                    fieldNames
                )
            )
            .thenReturn(md.mockAccountPlan);
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreResults);
        md.mocks.when(hss.getAccountPlanFieldNamesForScoreMetadata(mockScoreResults)).thenReturn(fieldNames);
        md.mocks.when(
                hss.getScoreFromPlanForMetadataPercent(
                    (Account_Plan__c) fflib_Match.anyObject(),
                    (PQ_AP_Score__mdt) fflib_Match.anyObject()
                )
            )
            .thenReturn(mockPoints);
        md.mocks.when(hss.getColorBoundaryFromSettings(md.mockSettings)).thenReturn(mockCB);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        List<HealthScoreController.HealthScoreWrapper> result = HealthScoreController.getIndividualHealthScoresForAccountPlanPercent(
            md.mockAccountPlanId
        );

        System.AssertEquals(1, result.size(), 'Should have one expected score');
        System.AssertEquals(mockColor, result[0].color, 'Should have expected high color');
    }
}