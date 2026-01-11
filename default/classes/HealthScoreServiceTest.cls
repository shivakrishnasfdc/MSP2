@IsTest
public with sharing class HealthScoreServiceTest {
    @isTest
    private static void getTotalScoreForAccountPlanJustPlanNullTest() {
        Double result = HealthScoreService.getTotalScoreForAccountPlan(null);
        System.assertEquals(0, result, 'Null plan should return 0 score');
    }

    @isTest
    private static void getTotalScoreForAccountPlanJustPlanTest() {
        TestMockData md = new TestMockData();
        HealthScoreServiceImpl hss = md.mockHealthScoreService;

        List<PQ_AP_Score__mdt> mockScoreData = new List<PQ_AP_Score__mdt>{ md.mockAPScoreData };

        md.mocks.startStubbing();
        md.mocks.when(hss.getValidScoreMetadata()).thenReturn(mockScoreData);
        md.mocks.stopStubbing();

        HealthScoreService.getTotalScoreForAccountPlan(md.mockAccountPlan);
        ((HealthScoreServiceImpl) md.mocks.verify(hss, 1)).getValidScoreMetadata();
        ((HealthScoreServiceImpl) md.mocks.verify(hss, 1))
            .getTotalScoreForAccountPlan(md.mockAccountPlan, mockScoreData);
        System.assert(true, 'Verified by mock verify');
    }

    @isTest
    private static void getTotalScoreForAccountPlanNullPlanTest() {
        TestMockData md = new TestMockData();
        List<PQ_AP_Score__mdt> mockScoreData = new List<PQ_AP_Score__mdt>{ md.mockAPScoreData };

        Double result = HealthScoreService.getTotalScoreForAccountPlan(null, mockScoreData);
        System.assertEquals(0, result, 'Null plan should return 0 score');
    }

    @isTest
    private static void getTotalScoreForAccountPlanNullMetadataTest() {
        TestMockData md = new TestMockData();

        Double result = HealthScoreService.getTotalScoreForAccountPlan(md.mockAccountPlan, null);
        System.assertEquals(0, result, 'Null metadata should return 0 score');
    }

    @isTest
    private static void getTotalScoreForAccountPlanEmptyMetadataTest() {
        TestMockData md = new TestMockData();

        Double result = HealthScoreService.getTotalScoreForAccountPlan(
            md.mockAccountPlan,
            new List<PQ_AP_Score__mdt>()
        );
        System.assertEquals(0, result, 'Empty metadata should return 0 score');
    }

    @isTest
    private static void getTotalScoreForAccountPlanTest() {
        TestMockData md = new TestMockData();

        Double halfScore = 5;

        PQ_AP_Score__mdt score1 = md.mockAPScoreData.clone();
        score1.Score_BP_Low__c = halfScore;
        PQ_AP_Score__mdt score2 = md.mockAPScoreData.clone();
        score2.Score_BP_Low__c = halfScore;
        PQ_AP_Score__mdt invalidScore1 = md.mockAPScoreData.clone();
        invalidScore1.Score_Field_API_Name__c = 'invalid_FieldFor_gtsfapt';
        PQ_AP_Score__mdt invalidScore2 = md.mockAPScoreData.clone();
        invalidScore2.Score_Field_API_Name__c = 'Name';

        md.mockAccountPlan.Intermediate_Score__c = 1;

        Double result = HealthScoreService.getTotalScoreForAccountPlan(
            md.mockAccountPlan,
            new List<PQ_AP_Score__mdt>{ score1, score2, invalidScore1, invalidScore2 }
        );
        System.assertEquals(
            halfScore * 2,
            result,
            'Result should only include scores from the two valid metadata records'
        );
    }

    @isTest
    private static void getMaxTotalScoreNoDataTest() {
        TestMockData md = new TestMockData();
        HealthScoreMetadataSelector hsms = md.mockHealthScoreMetadataSelector;

        md.mocks.startStubbing();
        md.mocks.when(hsms.selectEnabled()).thenReturn(new List<PQ_AP_Score__mdt>());
        md.mocks.stopStubbing();

        Double result = HealthScoreService.getMaxTotalScore();
        System.assertEquals(0, result, 'Empty data should return 0 score');
    }

    @isTest
    private static void getMaxTotalScoreTest() {
        TestMockData md = new TestMockData();
        HealthScoreMetadataSelector hsms = md.mockHealthScoreMetadataSelector;

        Double halfScore = 5;

        PQ_AP_Score__mdt score1 = md.mockAPScoreData.clone();
        score1.Score_BP_High__c = halfScore;
        PQ_AP_Score__mdt score2 = md.mockAPScoreData.clone();
        score2.Score_BP_High__c = halfScore;

        md.mocks.startStubbing();
        md.mocks.when(hsms.selectEnabled()).thenReturn(new List<PQ_AP_Score__mdt>{ score1, score2 });
        md.mocks.stopStubbing();

        Double result = HealthScoreService.getMaxTotalScore();
        System.assertEquals(halfScore * 2, result, 'Should return the sum of the high scores');
    }

    @isTest
    private static void getAccountPlanFieldNamesForScoreMetadataNullTest() {
        Set<String> result = HealthScoreService.getAccountPlanFieldNamesForScoreMetadata(null);
        System.assertEquals(0, result.size(), 'Null metadata should return empty set');
    }

    @isTest
    private static void getAccountPlanFieldNamesForScoreMetadataEmptyTest() {
        Set<String> result = HealthScoreService.getAccountPlanFieldNamesForScoreMetadata(new List<PQ_AP_Score__mdt>());
        System.assertEquals(0, result.size(), 'Empty metadata should return empty set');
    }

    @isTest
    private static void getAccountPlanFieldNamesForScoreMetadataInvalidDateFieldTest() {
        TestMockData md = new TestMockData();

        PQ_AP_Score__mdt invalidScore = md.mockAPScoreData.clone();
        invalidScore.Date_Field_API_Name__c = 'invalid_FieldFor_gapfnfsmidft';

        Set<String> result = HealthScoreService.getAccountPlanFieldNamesForScoreMetadata(
            new List<PQ_AP_Score__mdt>{ invalidScore }
        );
        System.assertEquals(1, result.size(), 'Should return set with just the score field name');
        System.assert(
            result.contains(invalidScore.Score_Field_API_Name__c),
            'Should still return the score field name from the metadata'
        );
    }

    @isTest
    private static void getAccountPlanFieldNamesForScoreMetadataNullDateFieldTest() {
        TestMockData md = new TestMockData();

        PQ_AP_Score__mdt invalidScore = md.mockAPScoreData.clone();
        invalidScore.Date_Field_API_Name__c = null;

        Set<String> result = HealthScoreService.getAccountPlanFieldNamesForScoreMetadata(
            new List<PQ_AP_Score__mdt>{ invalidScore }
        );
        System.assertEquals(1, result.size(), 'Should return set with just the score field name');
        System.assert(
            result.contains(invalidScore.Score_Field_API_Name__c),
            'Should still return the score field name from the metadata'
        );
    }

    @isTest
    private static void getAccountPlanFieldNamesForScoreMetadataInvalidScoreFieldTest() {
        TestMockData md = new TestMockData();

        PQ_AP_Score__mdt invalidScore = md.mockAPScoreData.clone();
        invalidScore.Score_Field_API_Name__c = 'invalid_FieldFor_gapfnfsmisft';

        Set<String> result = HealthScoreService.getAccountPlanFieldNamesForScoreMetadata(
            new List<PQ_AP_Score__mdt>{ invalidScore }
        );
        System.assertEquals(0, result.size(), 'Should return empty set if invalid score field');
    }

    @isTest
    private static void getAccountPlanFieldNamesForScoreMetadataTest() {
        TestMockData md = new TestMockData();

        Set<String> result = HealthScoreService.getAccountPlanFieldNamesForScoreMetadata(
            new List<PQ_AP_Score__mdt>{ md.mockAPScoreData }
        );
        System.assertEquals(2, result.size(), 'Should return two valid field names');
        System.assert(
            result.contains(md.mockAPScoreData.Score_Field_API_Name__c),
            'Should return the score field name from the metadata'
        );
        System.assert(
            result.contains(md.mockAPScoreData.Date_Field_API_Name__c),
            'Should return the date field name from the metadata'
        );
    }

    @isTest
    private static void getValidScoreMetadataTest() {
        TestMockData md = new TestMockData();
        HealthScoreMetadataSelector hsms = md.mockHealthScoreMetadataSelector;

        PQ_AP_Score__mdt invalidScore = md.mockAPScoreData.clone();
        invalidScore.Score_Field_API_Name__c = 'invalid_FieldFor_gvsmt';

        List<PQ_AP_Score__mdt> mockScoreData = new List<PQ_AP_Score__mdt>{ md.mockAPScoreData, invalidScore };

        md.mocks.startStubbing();
        md.mocks.when(hsms.selectEnabled()).thenReturn(mockScoreData);
        md.mocks.stopStubbing();

        List<PQ_AP_Score__mdt> result = HealthScoreService.getValidScoreMetadata();
        System.assertEquals(1, result.size(), 'Should return one record');
        System.assert(result.contains(md.mockAPScoreData), 'Should return the valid score metadata record');
    }

    @isTest
    private static void getColorBoundaryFromSettingsNullRecordTest() {
        ColorBoundary result = HealthScoreService.getColorBoundaryFromSettings(null);

        ColorBoundary expectedBoundary = new ColorBoundary('#E1341E', '#EB8214', '#2DD24A', .25, .75);
        System.assertEquals(expectedBoundary.lowColor, result.lowColor, 'Low color should be the same');
        System.assertEquals(expectedBoundary.midColor, result.midColor, 'Mid color should be the same');
        System.assertEquals(expectedBoundary.highColor, result.highColor, 'High color should be the same');
        System.assertEquals(
            expectedBoundary.lowMidBoundary,
            result.lowMidBoundary,
            'Low mid boundary should be the same'
        );
        System.assertEquals(
            expectedBoundary.midHighBoundary,
            result.midHighBoundary,
            'Mid high boundary should be the same'
        );
    }

    @isTest
    private static void getColorBoundaryFromSettingsEmptyRecordTest() {
        CRUSH_Settings_Obj__c mockSettingObj = new CRUSH_Settings_Obj__c();
        mockSettingObj.Score_Low_Color__c = null;
        mockSettingObj.Score_Mid_Color__c = null;
        mockSettingObj.Score_High_Color__c = null;
        mockSettingObj.Score_Low_Mid_Boundary__c = null;
        mockSettingObj.Score_Mid_High_Boundary__c = null;

        ColorBoundary result = HealthScoreService.getColorBoundaryFromSettings(mockSettingObj);

        ColorBoundary expectedBoundary = new ColorBoundary('#E1341E', '#EB8214', '#2DD24A', .25, .75);
        System.assertEquals(expectedBoundary.lowColor, result.lowColor, 'Low color should be the same');
        System.assertEquals(expectedBoundary.midColor, result.midColor, 'Mid color should be the same');
        System.assertEquals(expectedBoundary.highColor, result.highColor, 'High color should be the same');
        System.assertEquals(
            expectedBoundary.lowMidBoundary,
            result.lowMidBoundary,
            'Low mid boundary should be the same'
        );
        System.assertEquals(
            expectedBoundary.midHighBoundary,
            result.midHighBoundary,
            'Mid high boundary should be the same'
        );
    }

    @isTest
    private static void getColorBoundaryFromSettingsTest() {
        CRUSH_Settings_Obj__c mockSettingObj = new CRUSH_Settings_Obj__c();
        mockSettingObj.Score_Low_Color__c = '#111111';
        mockSettingObj.Score_Mid_Color__c = '#222222';
        mockSettingObj.Score_High_Color__c = '#333333';
        mockSettingObj.Score_Low_Mid_Boundary__c = .1;
        mockSettingObj.Score_Mid_High_Boundary__c = .9;

        ColorBoundary result = HealthScoreService.getColorBoundaryFromSettings(mockSettingObj);

        System.assertEquals(mockSettingObj.Score_Low_Color__c, result.lowColor, 'Low color should be the same');
        System.assertEquals(mockSettingObj.Score_Mid_Color__c, result.midColor, 'Mid color should be the same');
        System.assertEquals(mockSettingObj.Score_High_Color__c, result.highColor, 'High color should be the same');
        System.assertEquals(
            mockSettingObj.Score_Low_Mid_Boundary__c,
            result.lowMidBoundary,
            'Low mid boundary should be the same'
        );
        System.assertEquals(
            mockSettingObj.Score_Mid_High_Boundary__c,
            result.midHighBoundary,
            'Mid high boundary should be the same'
        );
    }

    @isTest
    private static void getScoreFromPlanForMetadataNullPlanTest() {
        TestMockData md = new TestMockData();

        Double result = HealthScoreService.getScoreFromPlanForMetadata(null, md.mockAPScoreData);
        System.assertEquals(-1, result, 'Should return -1 if plan is null');
    }

    @isTest
    private static void getScoreFromPlanForMetadataNullMetadataTest() {
        TestMockData md = new TestMockData();

        Double result = HealthScoreService.getScoreFromPlanForMetadata(md.mockAccountPlan, null);
        System.assertEquals(-1, result, 'Should return -1 if account plan is null');
    }

    @isTest
    private static void getScoreFromPlanForMetadataInvalidScoreFieldTest() {
        TestMockData md = new TestMockData();

        PQ_AP_Score__mdt invalidScore = md.mockAPScoreData.clone();
        invalidScore.Score_Field_API_Name__c = 'invalid_FieldFor_gsfpfmisft';

        Double result = HealthScoreService.getScoreFromPlanForMetadata(md.mockAccountPlan, invalidScore);
        System.assertEquals(-1, result, 'Should return -1 if metadata score field is invalid');
    }

    @isTest
    private static void getScoreFromPlanForMetadataNotDateFieldTest() {
        TestMockData md = new TestMockData();

        PQ_AP_Score__mdt invalidScore = md.mockAPScoreData.clone();
        invalidScore.Score_Field_API_Name__c = 'Name';

        Double result = HealthScoreService.getScoreFromPlanForMetadata(md.mockAccountPlan, invalidScore);
        System.assertEquals(-1, result, 'Should return -1 if metadata score field is not a date field');
    }

    @isTest
    private static void getScoreFromPlanForMetadataBelowLowScoreTest() {
        TestMockData md = new TestMockData();

        md.mockAPScoreData.Use_Time_Decay__c = false;
        md.mockAPScoreData.Count_BP_Low__c = 2;
        md.mockAPScoreData.Count_BP_Mid__c = 7;
        md.mockAPScoreData.Count_BP_High__c = 10;
        md.mockAccountPlan.Intermediate_Score__c = 1;

        Double result = HealthScoreService.getScoreFromPlanForMetadata(md.mockAccountPlan, md.mockAPScoreData);
        System.assertEquals(0, result, 'Should return 0 if score is below low score');
    }

    @isTest
    private static void getScoreFromPlanForMetadataBelowMidScoreTest() {
        TestMockData md = new TestMockData();

        md.mockAPScoreData.Use_Time_Decay__c = false;
        md.mockAPScoreData.Count_BP_Low__c = 2;
        md.mockAPScoreData.Count_BP_Mid__c = 5;
        md.mockAPScoreData.Count_BP_High__c = 10;
        md.mockAccountPlan.Intermediate_Score__c = 3;

        Double result = HealthScoreService.getScoreFromPlanForMetadata(md.mockAccountPlan, md.mockAPScoreData);
        System.assertEquals(
            md.mockAPScoreData.Score_BP_Low__c,
            result,
            'Should return low score if score is below mid score but at/above low score'
        );
    }

    @isTest
    private static void getScoreFromPlanForMetadataBelowHighScoreTest() {
        TestMockData md = new TestMockData();

        md.mockAPScoreData.Use_Time_Decay__c = false;
        md.mockAPScoreData.Count_BP_Low__c = 2;
        md.mockAPScoreData.Count_BP_Mid__c = 5;
        md.mockAPScoreData.Count_BP_High__c = 10;
        md.mockAccountPlan.Intermediate_Score__c = 8;

        Double result = HealthScoreService.getScoreFromPlanForMetadata(md.mockAccountPlan, md.mockAPScoreData);
        System.assertEquals(
            md.mockAPScoreData.Score_BP_Mid__c,
            result,
            'Should return mid score if score is below high score but at/above mid score'
        );
    }

    @isTest
    private static void getScoreFromPlanForMetadataAboveHighScoreTest() {
        TestMockData md = new TestMockData();

        md.mockAPScoreData.Use_Time_Decay__c = false;
        md.mockAPScoreData.Count_BP_Low__c = 2;
        md.mockAPScoreData.Count_BP_Mid__c = 5;
        md.mockAPScoreData.Count_BP_High__c = 10;
        md.mockAccountPlan.Intermediate_Score__c = 10;

        Double result = HealthScoreService.getScoreFromPlanForMetadata(md.mockAccountPlan, md.mockAPScoreData);
        System.assertEquals(
            md.mockAPScoreData.Score_BP_High__c,
            result,
            'Should return high score if score is equal/above high score'
        );
    }

    @isTest
    private static void getScoreFromPlanForMetadataBelowLowTimeDecayTest() {
        TestMockData md = new TestMockData();

        md.mockAPScoreData.Count_BP_Low__c = 2;
        md.mockAPScoreData.Count_BP_Mid__c = 5;
        md.mockAPScoreData.Count_BP_High__c = 10;

        md.mockAPScoreData.Use_Time_Decay__c = true;
        md.mockAPScoreData.Date_Field_API_Name__c = 'CreatedDate';
        md.mockAPScoreData.Time_BP_Low__c = 7;
        md.mockAPScoreData.Time_BP_Mid__c = 30;
        md.mockAPScoreData.Time_BP_High__c = 90;
        Datetime createdDate = Datetime.now().addDays(-3);

        String apJSON = '{ "pqcrush__Intermediate_Score__c": 10, "CreatedDate": ' + JSON.serialize(createdDate) + ' }';
        md.mockAccountPlan = (Account_Plan__c) JSON.deserialize(apJSON, Account_Plan__c.class);

        Double result = HealthScoreService.getScoreFromPlanForMetadata(md.mockAccountPlan, md.mockAPScoreData);
        System.assertEquals(
            md.mockAPScoreData.Score_BP_High__c,
            result,
            'Should return full score if below low time decay breakpoint'
        );
    }

    @isTest
    private static void getScoreFromPlanForMetadataBelowMidTimeDecayTest() {
        TestMockData md = new TestMockData();

        md.mockAPScoreData.Count_BP_Low__c = 2;
        md.mockAPScoreData.Count_BP_Mid__c = 5;
        md.mockAPScoreData.Count_BP_High__c = 10;

        md.mockAPScoreData.Use_Time_Decay__c = true;
        md.mockAPScoreData.Date_Field_API_Name__c = 'CreatedDate';
        md.mockAPScoreData.Time_BP_Low__c = 7;
        md.mockAPScoreData.Time_BP_Mid__c = 30;
        md.mockAPScoreData.Time_BP_High__c = 90;
        Datetime createdDate = Datetime.now().addDays(-15);

        String apJSON = '{ "pqcrush__Intermediate_Score__c": 10, "CreatedDate": ' + JSON.serialize(createdDate) + ' }';
        md.mockAccountPlan = (Account_Plan__c) JSON.deserialize(apJSON, Account_Plan__c.class);

        Double result = HealthScoreService.getScoreFromPlanForMetadata(md.mockAccountPlan, md.mockAPScoreData);
        System.assertEquals(
            md.mockAPScoreData.Score_BP_High__c * md.mockAPScoreData.Time_BP_Mult_Low__c,
            result,
            'Should return score multiplied by low time decay modifier if past low time decay breakpoint'
        );
    }

    @isTest
    private static void getScoreFromPlanForMetadataBelowHighTimeDecayTest() {
        TestMockData md = new TestMockData();

        md.mockAPScoreData.Count_BP_Low__c = 2;
        md.mockAPScoreData.Count_BP_Mid__c = 5;
        md.mockAPScoreData.Count_BP_High__c = 10;

        md.mockAPScoreData.Use_Time_Decay__c = true;
        md.mockAPScoreData.Date_Field_API_Name__c = 'CreatedDate';
        md.mockAPScoreData.Time_BP_Low__c = 7;
        md.mockAPScoreData.Time_BP_Mid__c = 30;
        md.mockAPScoreData.Time_BP_High__c = 90;
        Datetime createdDate = Datetime.now().addDays(-45);

        String apJSON = '{ "pqcrush__Intermediate_Score__c": 10, "CreatedDate": ' + JSON.serialize(createdDate) + ' }';
        md.mockAccountPlan = (Account_Plan__c) JSON.deserialize(apJSON, Account_Plan__c.class);

        Double result = HealthScoreService.getScoreFromPlanForMetadata(md.mockAccountPlan, md.mockAPScoreData);
        System.assertEquals(
            md.mockAPScoreData.Score_BP_High__c * md.mockAPScoreData.Time_BP_Mult_Mid__c,
            result,
            'Should return score multiplied by mid time decay modifier if past mid time decay breakpoint'
        );
    }

    @isTest
    private static void getScoreFromPlanForMetadataAfterHighTimeDecayTest() {
        TestMockData md = new TestMockData();

        md.mockAPScoreData.Count_BP_Low__c = 2;
        md.mockAPScoreData.Count_BP_Mid__c = 5;
        md.mockAPScoreData.Count_BP_High__c = 10;

        md.mockAPScoreData.Use_Time_Decay__c = true;
        md.mockAPScoreData.Date_Field_API_Name__c = 'CreatedDate';
        md.mockAPScoreData.Time_BP_Low__c = 7;
        md.mockAPScoreData.Time_BP_Mid__c = 30;
        md.mockAPScoreData.Time_BP_High__c = 90;
        Datetime createdDate = Datetime.now().addDays(-105);

        String apJSON = '{ "pqcrush__Intermediate_Score__c": 10, "CreatedDate": ' + JSON.serialize(createdDate) + ' }';
        md.mockAccountPlan = (Account_Plan__c) JSON.deserialize(apJSON, Account_Plan__c.class);

        Double result = HealthScoreService.getScoreFromPlanForMetadata(md.mockAccountPlan, md.mockAPScoreData);
        System.assertEquals(
            md.mockAPScoreData.Score_BP_High__c * md.mockAPScoreData.Time_BP_Mult_High__c,
            result,
            'Should return score multiplied by high time decay modifier if past high time decay breakpoint'
        );
    }

    @isTest
    private static void getScoreFromPlanForMetadataInvalidTimeDecayFieldTest() {
        TestMockData md = new TestMockData();

        md.mockAPScoreData.Count_BP_Low__c = 2;
        md.mockAPScoreData.Count_BP_Mid__c = 5;
        md.mockAPScoreData.Count_BP_High__c = 10;

        md.mockAPScoreData.Use_Time_Decay__c = true;
        md.mockAPScoreData.Date_Field_API_Name__c = 'Name';
        md.mockAPScoreData.Time_BP_Low__c = 7;
        md.mockAPScoreData.Time_BP_Mid__c = 30;
        md.mockAPScoreData.Time_BP_High__c = 90;
        Datetime createdDate = Datetime.now().addDays(-105);

        String apJSON =
            '{ "Name": "The plan name", "pqcrush__Intermediate_Score__c": 10, "CreatedDate": ' +
            JSON.serialize(createdDate) +
            ' }';
        md.mockAccountPlan = (Account_Plan__c) JSON.deserialize(apJSON, Account_Plan__c.class);

        Double result = HealthScoreService.getScoreFromPlanForMetadata(md.mockAccountPlan, md.mockAPScoreData);
        System.assertEquals(
            md.mockAPScoreData.Score_BP_High__c,
            result,
            'Should not use time decay and just return score if time decay field is not a valid time/datetime field'
        );
    }

    @isTest
    private static void getScoreFromPlanForMetadataStakeholderInvalidCountTest() {
        TestMockData md = new TestMockData();
        RelationshipMapServiceImpl mockService = md.mockRelationshipMapService;

        md.mockAPScoreData.DeveloperName = 'Stakeholders';
        md.mockAPScoreData.Score_Field_API_Name__c = 'pqcrush__Key_Stakeholder_Count__c';
        md.mockAPScoreData.Date_Field_API_Name__c = 'pqcrush__KS_Max_LMD__c';

        md.mocks.startStubbing();
        md.mocks.when(mockService.getMapMemberCountForAccountPlan(new List<Account_Plan__c>{ md.mockAccountPlan }))
            .thenReturn(-1);
        md.mocks.stopStubbing();

        Double result = HealthScoreService.getScoreFromPlanForMetadata(md.mockAccountPlan, md.mockAPScoreData);
        System.assertEquals(-1, result, 'Should return -1 if stakeholder count is invalid');
    }

    @isTest
    private static void getScoreFromPlanForMetadataStakeholderMidCountTest() {
        TestMockData md = new TestMockData();
        RelationshipMapServiceImpl mockService = md.mockRelationshipMapService;

        md.mockAPScoreData.DeveloperName = 'Stakeholders';
        md.mockAPScoreData.Score_Field_API_Name__c = 'pqcrush__Key_Stakeholder_Count__c';
        md.mockAPScoreData.Date_Field_API_Name__c = 'pqcrush__KS_Max_LMD__c';

        md.mockAPScoreData.Use_Time_Decay__c = false;
        md.mockAPScoreData.Count_BP_Low__c = 2;
        md.mockAPScoreData.Count_BP_Mid__c = 5;
        md.mockAPScoreData.Count_BP_High__c = 10;

        md.mocks.startStubbing();
        md.mocks.when(mockService.getMapMemberCountForAccountPlan(new List<Account_Plan__c>{ md.mockAccountPlan }))
            .thenReturn(8);
        md.mocks.stopStubbing();

        Double result = HealthScoreService.getScoreFromPlanForMetadata(md.mockAccountPlan, md.mockAPScoreData);
        System.assertEquals(
            md.mockAPScoreData.Score_BP_Mid__c,
            result,
            'Should return mid score if count is below high score but at/above mid score'
        );
    }

    @isTest
    private static void getScoreFromPlanForMetadataStakeholderOtherCountTest() {
        TestMockData md = new TestMockData();

        md.mockAPScoreData.DeveloperName = 'Stakeholders';
        md.mockAPScoreData.Score_Field_API_Name__c = 'pqcrush__Intermediate_Score__c';
        md.mockAPScoreData.Date_Field_API_Name__c = 'pqcrush__KS_Max_LMD__c';

        md.mockAPScoreData.Use_Time_Decay__c = false;
        md.mockAPScoreData.Count_BP_Low__c = 2;
        md.mockAPScoreData.Count_BP_Mid__c = 5;
        md.mockAPScoreData.Count_BP_High__c = 10;

        md.mockAccountPlan.Intermediate_Score__c = 8;

        Double result = HealthScoreService.getScoreFromPlanForMetadata(md.mockAccountPlan, md.mockAPScoreData);
        System.assertEquals(
            md.mockAPScoreData.Score_BP_Mid__c,
            result,
            'Should return mid score if field value is below high score but at/above mid score'
        );
    }

    @isTest
    private static void getScoreFromPlanForMetadataStakeholderNullDateTest() {
        TestMockData md = new TestMockData();
        RelationshipMapServiceImpl mockService = md.mockRelationshipMapService;

        md.mockAPScoreData.DeveloperName = 'Stakeholders';
        md.mockAPScoreData.Score_Field_API_Name__c = 'pqcrush__Key_Stakeholder_Count__c';
        md.mockAPScoreData.Date_Field_API_Name__c = 'pqcrush__KS_Max_LMD__c';

        md.mockAPScoreData.Use_Time_Decay__c = true;
        md.mockAPScoreData.Count_BP_Low__c = 2;
        md.mockAPScoreData.Count_BP_Mid__c = 5;
        md.mockAPScoreData.Count_BP_High__c = 10;

        md.mocks.startStubbing();
        md.mocks.when(mockService.getMapMemberCountForAccountPlan(new List<Account_Plan__c>{ md.mockAccountPlan }))
            .thenReturn(8);
        md.mocks.when(
                mockService.getMapMemberLastUpdatedDateForAccountPlan(new List<Account_Plan__c>{ md.mockAccountPlan })
            )
            .thenReturn(null);
        md.mocks.stopStubbing();

        Double result = HealthScoreService.getScoreFromPlanForMetadata(md.mockAccountPlan, md.mockAPScoreData);
        System.assertEquals(
            md.mockAPScoreData.Score_BP_Mid__c,
            result,
            'Should return mid score if count is below high score but at/above mid score and using time decay but null date returned'
        );
    }

    @isTest
    private static void getScoreFromPlanForMetadataStakeholderDateTest() {
        TestMockData md = new TestMockData();
        RelationshipMapServiceImpl mockService = md.mockRelationshipMapService;

        md.mockAPScoreData.DeveloperName = 'Stakeholders';
        md.mockAPScoreData.Score_Field_API_Name__c = 'pqcrush__Key_Stakeholder_Count__c';
        md.mockAPScoreData.Date_Field_API_Name__c = 'pqcrush__KS_Max_LMD__c';

        md.mockAPScoreData.Use_Time_Decay__c = false;
        md.mockAPScoreData.Count_BP_Low__c = 2;
        md.mockAPScoreData.Count_BP_Mid__c = 5;
        md.mockAPScoreData.Count_BP_High__c = 10;

        md.mockAPScoreData.Use_Time_Decay__c = true;
        md.mockAPScoreData.Time_BP_Low__c = 7;
        md.mockAPScoreData.Time_BP_Mid__c = 30;
        md.mockAPScoreData.Time_BP_High__c = 90;
        Date createdDate = Date.today().addDays(-45);

        md.mocks.startStubbing();
        md.mocks.when(mockService.getMapMemberCountForAccountPlan(new List<Account_Plan__c>{ md.mockAccountPlan }))
            .thenReturn(8);
        md.mocks.when(
                mockService.getMapMemberLastUpdatedDateForAccountPlan(new List<Account_Plan__c>{ md.mockAccountPlan })
            )
            .thenReturn(createdDate);
        md.mocks.stopStubbing();

        Double result = HealthScoreService.getScoreFromPlanForMetadata(md.mockAccountPlan, md.mockAPScoreData);
        System.assertEquals(
            md.mockAPScoreData.Score_BP_Mid__c * md.mockAPScoreData.Time_BP_Mult_Mid__c,
            result,
            'Should return mid score times mid time decay for scenario with rm values'
        );
    }

    @isTest
    private static void getScoreFromPlanForMetadataStakeholderCustomDateTest() {
        TestMockData md = new TestMockData();
        RelationshipMapServiceImpl mockService = md.mockRelationshipMapService;

        md.mockAPScoreData.DeveloperName = 'Stakeholders';
        md.mockAPScoreData.Score_Field_API_Name__c = 'pqcrush__Key_Stakeholder_Count__c';
        md.mockAPScoreData.Date_Field_API_Name__c = 'CreatedDate';

        md.mockAPScoreData.Count_BP_Low__c = 2;
        md.mockAPScoreData.Count_BP_Mid__c = 5;
        md.mockAPScoreData.Count_BP_High__c = 10;

        md.mockAPScoreData.Use_Time_Decay__c = true;
        md.mockAPScoreData.Time_BP_Low__c = 7;
        md.mockAPScoreData.Time_BP_Mid__c = 30;
        md.mockAPScoreData.Time_BP_High__c = 90;
        Datetime createdDate = Datetime.now().addDays(-45);

        String apJSON = '{ "CreatedDate": ' + JSON.serialize(createdDate) + ' }';
        md.mockAccountPlan = (Account_Plan__c) JSON.deserialize(apJSON, Account_Plan__c.class);

        md.mocks.startStubbing();
        md.mocks.when(mockService.getMapMemberCountForAccountPlan(new List<Account_Plan__c>{ md.mockAccountPlan }))
            .thenReturn(8);
        md.mocks.stopStubbing();

        Double result = HealthScoreService.getScoreFromPlanForMetadata(md.mockAccountPlan, md.mockAPScoreData);
        System.assertEquals(
            md.mockAPScoreData.Score_BP_Mid__c * md.mockAPScoreData.Time_BP_Mult_Mid__c,
            result,
            'Should return mid score times mid time decay for scenario with custom time value'
        );
    }
}