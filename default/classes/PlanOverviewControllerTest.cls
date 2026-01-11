@isTest
private class PlanOverviewControllerTest {
    public static final String ADMIN_USER1_FIRST_NAME = 'AmyAdmin1';
    public static final String ADMIN_USER1_LAST_NAME = 'Arlie';

    public static final String STANDARD_USER1_FIRST_NAME = 'SamStandard';
    public static final String STANDARD_USER1_LAST_NAME = 'Sunlock';

    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';
    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User adminUser1 = TestDataFactory.createUser(ADMIN_USER1_FIRST_NAME, ADMIN_USER1_LAST_NAME, standardProfile.Id);
        User standardUser1 = TestDataFactory.createUser(
            STANDARD_USER1_FIRST_NAME,
            STANDARD_USER1_LAST_NAME,
            standardProfile.Id
        );

        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];
        PermissionSet standardUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_STANDARD_USER];

        // Assigning two users with the admin perm set and one user with the standard perm set
        List<PermissionSetAssignment> permissionSets = new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = adminUser1.Id, PermissionSetId = adminUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = standardUser1.Id, PermissionSetId = standardUserPermissionSet.Id)
        };

        Id systemUserId = UserInfo.getUserId();
        PermissionSetAssignment systemCrushAdminPermissions = TestDataFactory.createPermissionSetAssignment(
            systemUserId,
            adminUserPermissionSet.Id
        );

        if (systemCrushAdminPermissions != null) {
            permissionSets.add(systemCrushAdminPermissions);
        }
        insert permissionSets;
    }

    @isTest
    static void getPlanOverviewByAccountPlanTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];

        TestMockData md = new TestMockData();

        PlanOverviewSelector mockPlanOverviewSelector = md.mockPlanOverviewSelector;

        String title = 'abc';
        String color = '#ff0011';
        String overview = 'hey';

        Id planOverviewId = fflib_IDGenerator.generate(pq_CRUSH_Plan_Overview__c.SObjectType);

        pq_CRUSH_Plan_Overview__c planOverview = new pq_CRUSH_Plan_Overview__c(
            Id = planOverviewId,
            Account_Plan__c = md.mockAccountPlanId,
            Title__c = title,
            Description__c = overview,
            Background_Color__c = color
        );

        md.mocks.startStubbing();
        md.mocks.when(mockPlanOverviewSelector.selectByAccountPlan(new Set<Id>{ md.mockAccountPlanId }, 'key', false))
            .thenReturn(new List<pq_CRUSH_Plan_Overview__c>{ planOverview });
        md.mocks.stopStubbing();

        List<PlanOverviewWrapper> result;
        Test.startTest();
        System.runAs(adminUser1) {
            result = PlanOverviewController.getPlanOverviewByAccountPlan(md.mockAccountPlanId, 'key', false);
        }
        Test.stopTest();

        ((PlanOverviewSelector) md.mocks.verify(mockPlanOverviewSelector, 1))
            .selectByAccountPlan(new Set<Id>{ md.mockAccountPlanId }, 'key', false);
        System.assertEquals(1, result.size());
    }

    @isTest
    static void createPlanOverviewForAccountPlanTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        String title = 'abc';
        String color = '#ff0011';
        String overview = 'hey';
        String dataKey = 'key';

        pq_CRUSH_Plan_Overview__c planOverview = new pq_CRUSH_Plan_Overview__c(
            name = title,
            Account_Plan__c = md.mockAccountPlanId,
            Title__c = title,
            Description__c = overview,
            Background_Color__c = color,
            Data_Key__c = dataKey
        );

        PlanOverviewController.createPlanOverviewForAccountPlan(md.mockAccountPlanId, color, title, overview, dataKey);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew(planOverview);
        System.assert(true, 'Assert  by mock verify');
    }

    @isTest
    static void createPlanOverviewForAccountPlanLongTitleTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        String title = 'this is a long title that is greater than eighty characters to test that the name field propperly trims to eighty characters';
        String color = '#ff0011';
        String overview = 'hey';
        String dataKey = 'key';

        pq_CRUSH_Plan_Overview__c planOverview = new pq_CRUSH_Plan_Overview__c(
            name = title.substring(0, 80),
            Account_Plan__c = md.mockAccountPlanId,
            Title__c = title,
            Description__c = overview,
            Background_Color__c = color,
            Data_Key__c = dataKey
        );

        PlanOverviewController.createPlanOverviewForAccountPlan(md.mockAccountPlanId, color, title, overview, dataKey);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew(planOverview);
        System.assert(true, 'Assert  by mock verify');
    }

    @isTest
    static void updatePlanOverviewTest1() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        PlanOverviewSelector mockPlanOverviewSelector = md.mockPlanOverviewSelector;

        Id planOverviewId = fflib_IDGenerator.generate(pq_CRUSH_Plan_Overview__c.SObjectType);

        String title = 'abc';
        String color = '#ff0011';
        String overview = 'hey';
        String dataKey = 'key';

        pq_CRUSH_Plan_Overview__c planOverview = new pq_CRUSH_Plan_Overview__c(
            Id = planOverviewId,
            Name = title,
            Account_Plan__c = md.mockAccountPlanId,
            Title__c = title,
            Description__c = overview,
            Background_Color__c = color,
            Data_Key__c = dataKey
        );

        md.mocks.startStubbing();
        md.mocks.when(mockPlanOverviewSelector.selectById(new Set<Id>{ planOverviewId }))
            .thenReturn(new List<pq_CRUSH_Plan_Overview__c>());
        md.mocks.stopStubbing();

        PlanOverviewController.updatePlanOverview(planOverviewId, color, title, overview);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0)).registerDirty(planOverview);
        System.assert(true, 'Assert  by mock verify');
    }

    @isTest
    static void updatePlanOverviewTest2() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        PlanOverviewSelector mockPlanOverviewSelector = md.mockPlanOverviewSelector;

        Id planOverviewId = fflib_IDGenerator.generate(pq_CRUSH_Plan_Overview__c.SObjectType);

        String title = 'abc';
        String color = '#ff0011';
        String overview = 'hey';

        pq_CRUSH_Plan_Overview__c planOverview = new pq_CRUSH_Plan_Overview__c(
            Id = planOverviewId,
            Name = title,
            Account_Plan__c = md.mockAccountPlanId,
            Title__c = title,
            Description__c = overview,
            Background_Color__c = color
        );

        pq_CRUSH_Plan_Overview__c returnedOverview = new pq_CRUSH_Plan_Overview__c(
            Id = planOverviewId,
            Name = 'oldabc',
            Account_Plan__c = md.mockAccountPlanId,
            Title__c = 'oldabc',
            Description__c = 'oldhey',
            Background_Color__c = '#cccccc'
        );

        md.mocks.startStubbing();
        md.mocks.when(mockPlanOverviewSelector.selectById(new Set<Id>{ planOverviewId }))
            .thenReturn(new List<pq_CRUSH_Plan_Overview__c>{ returnedOverview });
        md.mocks.stopStubbing();

        PlanOverviewController.updatePlanOverview(planOverviewId, color, title, overview);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(planOverview);
        System.assert(true, 'Assert  by mock verify');
    }

    @isTest
    static void updatePlanOverviewLongTitleTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        PlanOverviewSelector mockPlanOverviewSelector = md.mockPlanOverviewSelector;

        Id planOverviewId = fflib_IDGenerator.generate(pq_CRUSH_Plan_Overview__c.SObjectType);

        String title = 'this is a long title that is greater than eighty characters to test that the name field propperly trims to eighty characters';
        String color = '#ff0011';
        String overview = 'hey';

        pq_CRUSH_Plan_Overview__c planOverview = new pq_CRUSH_Plan_Overview__c(
            Id = planOverviewId,
            Name = title.substring(0, 80),
            Account_Plan__c = md.mockAccountPlanId,
            Title__c = title,
            Description__c = overview,
            Background_Color__c = color
        );

        md.mocks.startStubbing();
        md.mocks.when(mockPlanOverviewSelector.selectById(new Set<Id>{ planOverviewId }))
            .thenReturn(new List<pq_CRUSH_Plan_Overview__c>{ planOverview });
        md.mocks.stopStubbing();

        PlanOverviewController.updatePlanOverview(planOverviewId, color, title, overview);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(planOverview);
        System.assert(true, 'Assert  by mock verify');
    }

    @isTest
    static void getPermissionsTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];

        Map<String, Boolean> result;
        Test.startTest();
        System.runAs(adminUser1) {
            result = PlanOverviewController.getPermissions();
        }
        Test.stopTest();

        // Then the user should get back the mapping record along with its condition groups
        System.assertEquals(true, result.get('createable'));
        System.assertEquals(true, result.get('updateable'));
        System.assertEquals(true, result.get('deleteable'));
    }

    @isTest
    static void deletePlanOverviewTest() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        PlanOverviewSelector mockPlanOverviewSelector = md.mockPlanOverviewSelector;

        Id planOverviewId = fflib_IDGenerator.generate(pq_CRUSH_Plan_Overview__c.SObjectType);

        pq_CRUSH_Plan_Overview__c planOverview = new pq_CRUSH_Plan_Overview__c(
            Id = planOverviewId,
            Account_Plan__c = md.mockAccountPlanId
        );

        md.mocks.startStubbing();
        md.mocks.when(mockPlanOverviewSelector.selectById(new Set<Id>{ planOverviewId }))
            .thenReturn(new List<pq_CRUSH_Plan_Overview__c>());
        md.mocks.stopStubbing();

        PlanOverviewController.deletePlanOverview(planOverviewId);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0)).registerDeleted(planOverview);
        System.assert(true, 'Assert  by mock verify');
    }

    @isTest
    static void deletePlanOverviewTest2() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        PlanOverviewSelector mockPlanOverviewSelector = md.mockPlanOverviewSelector;

        Id planOverviewId = fflib_IDGenerator.generate(pq_CRUSH_Plan_Overview__c.SObjectType);

        pq_CRUSH_Plan_Overview__c planOverview = new pq_CRUSH_Plan_Overview__c(
            Id = planOverviewId,
            Account_Plan__c = md.mockAccountPlanId
        );

        md.mocks.startStubbing();
        md.mocks.when(mockPlanOverviewSelector.selectById(new Set<Id>{ planOverviewId }))
            .thenReturn(new List<pq_CRUSH_Plan_Overview__c>{ planOverview });
        md.mocks.stopStubbing();

        PlanOverviewController.deletePlanOverview(planOverviewId);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDeleted(planOverview);
        System.assert(true, 'Assert  by mock verify');
    }
}