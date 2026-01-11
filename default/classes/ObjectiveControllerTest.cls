@isTest
private class ObjectiveControllerTest {
    @isTest
    static void getObjectivesForAccountPlanTest() {
        TestMockData md = new TestMockData();
        ObjectiveServiceImpl mockObjectiveService = md.mockObjectiveService;

        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');

        md.mocks.startStubbing();
        md.mocks.when(mockObjectiveService.getObjectivesForAccountPlans(new Set<Id>{ ap.Id }))
            .thenReturn(new List<ObjectiveWrapper>());
        md.mocks.stopStubbing();

        ObjectiveController.getObjectivesForAccountPlan(ap.Id);

        ((ObjectiveServiceImpl) md.mocks.verify(mockObjectiveService, 1))
            .getObjectivesForAccountPlans(new Set<Id>{ ap.Id });

        System.Assert(true, 'Test verified by mock assertion');
    }

    @isTest
    static void getObjectivesForAccountUsingMasterAccountPlanIdPlanTest() {
        TestMockData md = new TestMockData();
        ObjectiveServiceImpl mockObjectiveService = md.mockObjectiveService;
        MasterAccountPlanServiceImpl mockMasterAccountPlanService = md.mockMasterAccountPlanService;

        md.mocks.startStubbing();
        md.mocks.when(mockMasterAccountPlanService.getAccountPlansByMasterAccountPlan(md.mockMasterAccountPlanId))
            .thenReturn(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mocks.when(mockObjectiveService.getObjectivesForAccountPlans(new Set<Id>{ md.mockAccountPlanId }))
            .thenReturn(new List<ObjectiveWrapper>());
        md.mocks.stopStubbing();

        ObjectiveController.getObjectivesForAccountPlan(md.mockMasterAccountPlanId);

        ((ObjectiveServiceImpl) md.mocks.verify(mockObjectiveService, 1))
            .getObjectivesForAccountPlans(new Set<Id>{ md.mockAccountPlanId });

        System.Assert(true, 'Test verified by mock assertion');
    }

    @isTest
    static void createNewTaskForObjectiveTest() {
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');
        Objective__c obj1 = TestDataFactory.createObjective(ap, 'test1', 'test2');
        String taskSubject = 'Test Subject';

        Id taskId = ObjectiveController.createNewTaskForObjective(obj1.Id, taskSubject);

        System.AssertNotEquals(null, taskId);
    }

    @isTest
    static void removeTaskFromObjectiveTest() {
        TestMockData md = new TestMockData();
        ObjectiveServiceImpl mockObjectiveService = md.mockObjectiveService;

        Id objectiveId = fflib_IDGenerator.generate(Objective__c.SObjectType);
        Id taskId = fflib_IDGenerator.generate(Task.SObjectType);

        ObjectiveController.removeTaskFromObjective(objectiveId, taskId, false);

        ((ObjectiveServiceImpl) md.mocks.verify(mockObjectiveService, 1))
            .removeTaskFromObjective(objectiveId, taskId, false);
        System.Assert(true, 'Test verified by mock assertion');
    }

    @isTest
    static void deleteObjectiveTest() {
        TestMockData md = new TestMockData();
        ObjectiveServiceImpl mockObjectiveService = md.mockObjectiveService;

        Id objectiveId = fflib_IDGenerator.generate(Objective__c.SObjectType);
        Id taskId = fflib_IDGenerator.generate(Task.SObjectType);

        ObjectiveController.deleteObjective(objectiveId, new List<Id>{ taskId }, false);

        ((ObjectiveServiceImpl) md.mocks.verify(mockObjectiveService, 1))
            .deleteObjective(objectiveId, new List<Id>{ taskId }, false);
        System.Assert(true, 'Test verified by mock assertion');
    }

    @isTest
    static void updateObjectiveRecordsTest() {
        Account_Plan__c accPlanRecord = TestDataFactory.createAccountPlan('account plan A');
        Objective__c objectiveRecord = TestDataFactory.createObjective(accPlanRecord, 'test objective A');

        objectiveRecord.Stage__c = 'Complete';

        ObjectiveController.updateObjectiveRecords(new List<Objective__c>{ objectiveRecord });

        String objectiveStage = [
            SELECT Stage__c
            FROM Objective__c
            WHERE Id = :objectiveRecord.Id
        ]
        .Stage__c;
        Assert.areEqual('Complete', objectiveStage, 'Expected objective stage');
    }

    @isTest
    static void getSettingsTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;

        CRUSH_Settings_Obj__c mockOrgSettings = new CRUSH_Settings_Obj__c(
            Type__c = 'Org',
            Objective_Low_Color__c = '#100000',
            Objective_Middle_Color__c = '#200000',
            Objective_Low_Middle_Boundary__c = .10,
            Objective_High_Color__c = '#300000',
            Objective_Middle_High_Boundary__c = .20,
            Objective_Task_Low_Color__c = '#400000',
            Objective_Task_Middle_Color__c = '#500000',
            Objective_Task_Low_Middle_Boundary__c = .80,
            Objective_Task_High_Color__c = '#600000',
            Objective_Task_Middle_High_Boundary__c = .90
        );

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(mockOrgSettings);
        md.mocks.stopStubbing();

        ObjectiveSettingWrapper wrapper = ObjectiveController.getSettings();

        System.assertEquals('#100000', wrapper.objective.lowColor);
        System.assertEquals('#200000', wrapper.objective.midColor);
        System.assertEquals('#300000', wrapper.objective.highColor);
        System.assertEquals(.10, wrapper.objective.lowMidBoundary);
        System.assertEquals(.20, wrapper.objective.midHighBoundary);
        System.assertEquals('#400000', wrapper.task.lowColor);
        System.assertEquals('#500000', wrapper.task.midColor);
        System.assertEquals('#600000', wrapper.task.highColor);
        System.assertEquals(.80, wrapper.task.lowMidBoundary);
        System.assertEquals(.90, wrapper.task.midHighBoundary);
    }

    @isTest
    static void updateSettingsTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;

        CRUSH_Settings_Obj__c mockOrgSettings = new CRUSH_Settings_Obj__c(
            Type__c = 'Org',
            Objective_Low_Color__c = '#100000',
            Objective_Middle_Color__c = '#200000',
            Objective_Low_Middle_Boundary__c = .10,
            Objective_High_Color__c = '#300000',
            Objective_Middle_High_Boundary__c = .20,
            Objective_Task_Low_Color__c = '#400000',
            Objective_Task_Middle_Color__c = '#500000',
            Objective_Task_Low_Middle_Boundary__c = .80,
            Objective_Task_High_Color__c = '#600000',
            Objective_Task_Middle_High_Boundary__c = .90
        );

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(mockOrgSettings);
        md.mocks.stopStubbing();

        ColorBoundary obj = new ColorBoundary('#a00000', '#b00000', '#c00000', .20, .80);
        ColorBoundary tasks = new ColorBoundary('#d00000', '#e00000', '#f00000', .30, .70);
        ObjectiveSettingWrapper wrapper = new ObjectiveSettingWrapper(obj, tasks, true);

        ObjectiveController.updateSettings(JSON.serialize(wrapper));

        mockOrgSettings.Objective_Low_Color__c = obj.lowColor;
        mockOrgSettings.Objective_Middle_Color__c = obj.midColor;
        mockOrgSettings.Objective_High_Color__c = obj.HighColor;
        mockOrgSettings.Objective_Low_Middle_Boundary__c = obj.lowMidBoundary;
        mockOrgSettings.Objective_Middle_High_Boundary__c = obj.midHighBoundary;
        mockOrgSettings.Objective_Task_Low_Color__c = tasks.lowColor;
        mockOrgSettings.Objective_Task_Middle_Color__c = tasks.midColor;
        mockOrgSettings.Objective_Task_High_Color__c = tasks.HighColor;
        mockOrgSettings.Objective_Task_Low_Middle_Boundary__c = tasks.lowMidBoundary;
        mockOrgSettings.Objective_Task_Middle_High_Boundary__c = tasks.midHighBoundary;

        ((SettingServiceImpl) md.mocks.verify(mockSettingService, 1)).upsertSettings(mockOrgSettings);
        System.Assert(true, 'Assert by mock verify');
    }

    @isTest
    static void getObjectiveTaskSortFieldValuesTest() {
        List<String> listOfValues = ObjectiveController.getObjectiveTaskSortFieldValues();

        System.assert(!listOfValues.isEmpty(), 'Should return some picklist values');
        System.assert(listOfValues.size() >= 3, 'There should be at least 3 picklist values');
        System.assert(listOfValues.contains('Due Date,ActivityDate'), 'Label and API name should be comma separated');
    }

    @isTest
    static void getObjectiveTaskUserSortValuesNullTest() {
        TestMockData md = new TestMockData();
        CrushUserSettingSelector mockCrushUserSettingSelector = md.mockCrushUserSettingSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockCrushUserSettingSelector.selectForCurrentUser())
            .thenReturn(new List<pq_Crush_User_Setting__c>());
        md.mocks.stopStubbing();

        List<String> listOfStringInputs = new List<String>{ 'ActivityDate,Due Date' };

        String userSetting = 'Due Date';
        Boolean userSortAscending = true;
        String values = userSetting + ',' + string.valueOf(userSortAscending);

        String result = ObjectiveController.getObjectiveTaskUserSortValues(listOfStringInputs);
        System.assertEquals(values, result);
    }

    @isTest
    static void getObjectiveTaskUserSortValuesSettingTest() {
        TestMockData md = new TestMockData();
        CrushUserSettingSelector mockCrushUserSettingSelector = md.mockCrushUserSettingSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockCrushUserSettingSelector.selectForCurrentUser())
            .thenReturn(
                new List<pq_Crush_User_Setting__c>{
                    new pq_Crush_User_Setting__c(
                        pqcrush__Objective_Task_Sort_Ascending__c = true,
                        pqcrush__Objective_Task_Sort_Field__c = 'ActivityDate',
                        User__c = UserInfo.getUserId()
                    )
                }
            );
        md.mocks.stopStubbing();

        List<String> listOfStringInputs = new List<String>{ 'Due Date,ActivityDate' };
        List<pq_Crush_User_Setting__c> userSettingsList = new List<pq_Crush_User_Setting__c>{
            new pq_Crush_User_Setting__c(
                pqcrush__Objective_Task_Sort_Ascending__c = true,
                pqcrush__Objective_Task_Sort_Field__c = 'ActivityDate',
                User__c = UserInfo.getUserId()
            )
        };
        insert userSettingsList;

        String userSetting = 'Due Date';
        Boolean userSortAscending = true;
        String values = userSetting + ',' + string.valueOf(userSortAscending);

        String result = ObjectiveController.getObjectiveTaskUserSortValues(listOfStringInputs);
        System.assertEquals(values, result);
    }
}