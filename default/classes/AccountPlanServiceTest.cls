@isTest
private class AccountPlanServiceTest {
    public static final String STANDARD_USER1_FIRST_NAME = 'Manheim';
    public static final String STANDARD_USER1_LAST_NAME = 'Visa';

    public static final String STANDARD_USER2_FIRST_NAME = 'Krabby';
    public static final String STANDARD_USER2_LAST_NAME = 'Patty';

    public static final String CREATOR_USER_FIRST_NAME = 'Shabby';
    public static final String CREATOR_USER_LAST_NAME = 'Break';

    public static final String ADMIN_USER_FIRST_NAME = 'Apple';
    public static final String ADMIN_USER_LAST_NAME = 'AAAAAAA';

    public static final String ACCOUNT_PLAN1_NAME = 'Account Plan 1';
    public static final String ACCOUNT_PLAN2_NAME = 'Account Plan 2';
    public static final String ACCOUNT_PLAN3_NAME = 'Account Plan 3';

    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';
    public static final String CRUSH_ACCOUNT_PLAN_CREATOR = 'CRUSH_Account_Plan_Creator';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User standardUser1 = TestDataFactory.createUser(
            STANDARD_USER1_FIRST_NAME,
            STANDARD_USER1_LAST_NAME,
            standardProfile.Id
        );
        User standardUser2 = TestDataFactory.createUser(
            STANDARD_USER2_FIRST_NAME,
            STANDARD_USER2_LAST_NAME,
            standardProfile.Id
        );
        User creatorUser = TestDataFactory.createUser(
            CREATOR_USER_FIRST_NAME,
            CREATOR_USER_LAST_NAME,
            standardProfile.Id
        );
        User adminUser = TestDataFactory.createUser(ADMIN_USER_FIRST_NAME, ADMIN_USER_LAST_NAME, adminProfile.Id);

        PermissionSet standardUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_STANDARD_USER];
        PermissionSet creatorUserPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = :CRUSH_ACCOUNT_PLAN_CREATOR
        ];
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];

        List<PermissionSetAssignment> permissionSets = new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = standardUser1.Id, PermissionSetId = standardUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = standardUser2.Id, PermissionSetId = standardUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = creatorUser.Id, PermissionSetId = creatorUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = adminUserPermissionSet.Id)
        };

        Id systemUserId = UserInfo.getUserId();
        PermissionSetAssignment systemStrategyAdminPermissions = TestDataFactory.createPermissionSetAssignment(
            systemUserId,
            adminUserPermissionSet.Id
        );

        if (systemStrategyAdminPermissions != null) {
            permissionSets.add(systemStrategyAdminPermissions);
        }

        insert permissionSets;

        System.runAs(creatorUser) {
            Account testAccount = new Account(Name = 'Account 1');
            insert testAccount;

            AccountPlans.bypassEmailTrigger = true;
            Application.bypassTrigger = true;
            TestDataFactory.createAccountPlan(ACCOUNT_PLAN1_NAME, testAccount, 'Open');
            TestDataFactory.createAccountPlan(ACCOUNT_PLAN2_NAME, testAccount, 'Closed');
            TestDataFactory.createAccountPlan(ACCOUNT_PLAN3_NAME, testAccount, 'Closed');
        }

        System.runAs(adminUser) {
            Crush_Settings_Obj__c orgSettings = new Crush_Settings_Obj__c(Type__c = 'Org');
            insert orgSettings;
        }
    }

    @isTest
    static void openAccountPlansTest() {
        // Given
        User creatorUser = [SELECT Id FROM User WHERE LastName = :CREATOR_USER_LAST_NAME];
        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
        Account_Plan__c accountPlan2 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME];
        Set<Id> accountPlanIds = new Set<Id>{ accountPlan1.Id, accountPlan2.Id };

        // When
        Test.startTest();
        AccountPlanService.openAccountPlans(accountPlanIds);
        Test.stopTest();

        // Then
        Account_Plan__c updatedAccountPlan1 = [
            SELECT Id, Status__c, LastModifiedBy.Id
            FROM Account_Plan__c
            WHERE Name = :ACCOUNT_PLAN1_NAME
        ];
        Account_Plan__c updatedAccountPlan2 = [
            SELECT Id, Status__c, LastModifiedBy.Id
            FROM Account_Plan__c
            WHERE Name = :ACCOUNT_PLAN2_NAME
        ];

        // this plan was already open, so it shouldn't have been updated
        System.assertEquals('Open', updatedAccountPlan1.Status__c);
        System.assertEquals(creatorUser.Id, updatedAccountPlan1.LastModifiedBy.Id);

        // this plan was closed, so it should have been updated
        System.assertEquals('Open', updatedAccountPlan2.Status__c);
        System.assertEquals(UserInfo.getUserId(), updatedAccountPlan2.LastModifiedBy.Id);
    }

    @isTest
    static void maybeOpenAccountPlansTest() {
        Application.bypassTrigger = true;

        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        AccountPlanSelector mockSelector = (AccountPlanSelector) FFLibHelper.mockSelector(
            AccountPlanSelector.class,
            mocks
        );
        UserRecordAccessServiceImpl mockService = (UserRecordAccessServiceImpl) mocks.mock(
            UserRecordAccessServiceImpl.class
        );

        Application.unitOfWork.setMock(mockUow);
        Application.Selector.setMock(mockSelector);
        Application.Service.setMock(UserRecordAccessServiceImpl.class, mockService);

        // Given
        User creatorUser = [SELECT Id FROM User WHERE LastName = :CREATOR_USER_LAST_NAME];
        Account_Plan__c accountPlan2 = [SELECT Id, Status__c FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME];
        Account_Plan__c accountPlan3 = [SELECT Id, Status__c FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN3_NAME];
        Set<Id> accountPlanIds = new Set<Id>{ accountPlan2.Id, accountPlan3.Id };

        List<Account_Plan__c> accountPlans = new List<Account_Plan__c>{ accountPlan2, accountPlan3 };

        List<UserRecordAccess> uraList = [
            SELECT RecordId, HasEditAccess, HasAllAccess
            FROM UserRecordAccess
            WHERE UserId = :creatorUser.id AND RecordId IN :accountPlanIds
        ];

        Map<Id, UserRecordAccess> accessRecordMap = new Map<Id, UserRecordAccess>();
        for (UserRecordAccess ura : uraList) {
            accessRecordMap.put(ura.RecordId, ura);
        }

        mocks.startStubbing();
        mocks.when(mockSelector.selectClosedPlansById(accountPlanIds)).thenReturn(accountPlans);
        mocks.when(mockSelector.selectByIdAsSystem(accountPlanIds)).thenReturn(accountPlans);
        mocks.when(mockService.recordAccessForRecords(accountPlans)).thenReturn(accessRecordMap);
        mocks.stopStubbing();

        Map<Id, List<SObject>> recordsByAccountPlanId = new Map<Id, List<SObject>>();
        recordsByAccountPlanId.put(accountPlan2.Id, new List<SObject>{ accountPlan2 });
        recordsByAccountPlanId.put(accountPlan3.Id, new List<SObject>{ accountPlan3 });

        // When
        Test.startTest();
        AccountPlanService.maybeOpenAccountPlans(recordsByAccountPlanId);
        Test.stopTest();

        // Then
        try {
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerDirty(accountPlan2);
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerDirty(accountPlan3);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Did not Call registerDirty()');
        }
    }

    @isTest
    static void transferAccountPlansToTeamMemberTest() {
        // Given
        User user1 = [SELECT Id FROM User WHERE LastName = :STANDARD_USER1_LAST_NAME];
        User user2 = [SELECT Id FROM User WHERE LastName = :STANDARD_USER2_LAST_NAME];
        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
        Account_Plan__c accountPlan2 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME];

        Crush_Settings_Obj__c orgSettings = [
            SELECT Id, Account_Plan_Transfer__c
            FROM Crush_Settings_Obj__c
            WHERE Type__c = 'Org'
            LIMIT 1
        ];
        orgSettings.Account_Plan_Transfer__c = TransferSetting.TEAM_MEMBER.name();
        update orgSettings;

        TeamMembers.bypassEmailTrigger = true;
        // user1 is added as the first team member, they should end up as the new owner
        TestDataFactory.createTeamMember(user1, accountPlan1, 'Read Only');
        TestDataFactory.createTeamMember(user2, accountPlan1, 'Read Only');

        // user2 is added as the first team member, they should end up as the new owner
        TestDataFactory.createTeamMember(user2, accountPlan2, 'Read Only');
        TestDataFactory.createTeamMember(user1, accountPlan2, 'Read Only');

        // When
        Test.startTest();

        AccountPlanService.transferAccountPlans(new Set<Id>{ accountPlan1.Id, accountPlan2.Id });

        Test.stopTest();

        // Then
        Account_Plan__c updatedAccountPlan1 = [
            SELECT Id, OwnerId
            FROM Account_Plan__c
            WHERE Name = :ACCOUNT_PLAN1_NAME
        ];
        Account_Plan__c updatedAccountPlan2 = [
            SELECT Id, OwnerId
            FROM Account_Plan__c
            WHERE Name = :ACCOUNT_PLAN2_NAME
        ];

        System.assertEquals(
            user1.Id,
            updatedAccountPlan1.OwnerId,
            'Expected the first team member added to the account plan to be the new owner.'
        );
        System.assertEquals(
            user2.Id,
            updatedAccountPlan2.OwnerId,
            'Expected the first team member added to the account plan to be the new owner.'
        );
    }

    @isTest
    static void transferAccountPlansToStrategyAdminTest() {
        // Given
        User strategyAdmin = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
        Account_Plan__c accountPlan2 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME];

        Crush_Settings_Obj__c orgSettings = [
            SELECT Id, Account_Plan_Transfer__c
            FROM Crush_Settings_Obj__c
            WHERE Type__c = 'Org'
            LIMIT 1
        ];
        orgSettings.Account_Plan_Transfer__c = TransferSetting.TEAM_MEMBER.name();
        update orgSettings;

        // no team members on either account plan, should be assigned to the strategy admin
        // When
        Test.startTest();

        AccountPlanService.transferAccountPlans(new Set<Id>{ accountPlan1.Id, accountPlan2.Id });

        Test.stopTest();

        // Then
        Account_Plan__c updatedAccountPlan1 = [
            SELECT Id, OwnerId
            FROM Account_Plan__c
            WHERE Name = :ACCOUNT_PLAN1_NAME
        ];
        Account_Plan__c updatedAccountPlan2 = [
            SELECT Id, OwnerId
            FROM Account_Plan__c
            WHERE Name = :ACCOUNT_PLAN2_NAME
        ];

        System.assertEquals(
            strategyAdmin.Id,
            updatedAccountPlan1.OwnerId,
            'Expected the strategy admin to be the new owner.'
        );
        System.assertEquals(
            strategyAdmin.Id,
            updatedAccountPlan2.OwnerId,
            'Expected the strategy admin to be the new owner.'
        );
    }

    @isTest
    static void transferAccountPlansToSpecificUserTest() {
        // Given
        User user1 = [SELECT Id FROM User WHERE LastName = :STANDARD_USER1_LAST_NAME];
        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
        Account_Plan__c accountPlan2 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME];

        Crush_Settings_Obj__c orgSettings = [
            SELECT Id, Account_Plan_Transfer__c
            FROM Crush_Settings_Obj__c
            WHERE Type__c = 'Org'
            LIMIT 1
        ];
        orgSettings.Account_Plan_Transfer__c = TransferSetting.USER.name();
        orgSettings.Account_Plan_Transfer_User__c = user1.Id;
        update orgSettings;

        // no team members on either account plan, should be assigned to the strategy admin
        TestDataFactory.createTeamMember(user1, accountPlan1, 'Read Only');
        TestDataFactory.createTeamMember(user1, accountPlan2, 'Read Only');

        // When
        Test.startTest();

        AccountPlanService.transferAccountPlans(new Set<Id>{ accountPlan1.Id, accountPlan2.Id });

        Test.stopTest();

        // Then
        Account_Plan__c updatedAccountPlan1 = [
            SELECT Id, OwnerId
            FROM Account_Plan__c
            WHERE Name = :ACCOUNT_PLAN1_NAME
        ];
        Account_Plan__c updatedAccountPlan2 = [
            SELECT Id, OwnerId
            FROM Account_Plan__c
            WHERE Name = :ACCOUNT_PLAN2_NAME
        ];

        System.assertEquals(user1.Id, updatedAccountPlan1.OwnerId, 'Expected user 1 to be the new owner.');
        System.assertEquals(user1.Id, updatedAccountPlan2.OwnerId, 'Expected user 1 to be the new owner.');
    }

    @isTest
    static void transferAccountPlansToStrategyAdminByNoSpecificUserTest() {
        // Given
        User strategyAdmin = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
        Account_Plan__c accountPlan2 = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME];

        Crush_Settings_Obj__c orgSettings = [
            SELECT Id, Account_Plan_Transfer__c
            FROM Crush_Settings_Obj__c
            WHERE Type__c = 'Org'
            LIMIT 1
        ];
        orgSettings.Account_Plan_Transfer__c = TransferSetting.USER.name();
        orgSettings.Account_Plan_Transfer_User__c = null;
        update orgSettings;

        // no team members on either account plan, should be assigned to the strategy admin
        // When
        Test.startTest();

        AccountPlanService.transferAccountPlans(new Set<Id>{ accountPlan1.Id, accountPlan2.Id });

        Test.stopTest();

        // Then
        Account_Plan__c updatedAccountPlan1 = [
            SELECT Id, OwnerId
            FROM Account_Plan__c
            WHERE Name = :ACCOUNT_PLAN1_NAME
        ];
        Account_Plan__c updatedAccountPlan2 = [
            SELECT Id, OwnerId
            FROM Account_Plan__c
            WHERE Name = :ACCOUNT_PLAN2_NAME
        ];

        System.assertEquals(
            strategyAdmin.Id,
            updatedAccountPlan1.OwnerId,
            'Expected the strategy admin to be the new owner.'
        );
        System.assertEquals(
            strategyAdmin.Id,
            updatedAccountPlan2.OwnerId,
            'Expected the strategy admin to be the new owner.'
        );
    }

    @isTest
    static void transferAccountPlansToNoOneTest() {
        // Given
        Account_Plan__c accountPlan1 = [SELECT Id, OwnerId FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN1_NAME];
        Account_Plan__c accountPlan2 = [SELECT Id, OwnerId FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN2_NAME];

        Crush_Settings_Obj__c orgSettings = [
            SELECT Id, Account_Plan_Transfer__c
            FROM Crush_Settings_Obj__c
            WHERE Type__c = 'Org'
            LIMIT 1
        ];
        orgSettings.Account_Plan_Transfer__c = TransferSetting.NONE.name();
        update orgSettings;

        // no team members on either account plan, should be assigned to the strategy admin
        // When
        Test.startTest();

        AccountPlanService.transferAccountPlans(new Set<Id>{ accountPlan1.Id, accountPlan2.Id });

        Test.stopTest();

        // Then
        Account_Plan__c updatedAccountPlan1 = [
            SELECT Id, OwnerId
            FROM Account_Plan__c
            WHERE Name = :ACCOUNT_PLAN1_NAME
        ];
        Account_Plan__c updatedAccountPlan2 = [
            SELECT Id, OwnerId
            FROM Account_Plan__c
            WHERE Name = :ACCOUNT_PLAN2_NAME
        ];

        System.assertEquals(accountPlan1.OwnerId, updatedAccountPlan1.OwnerId, 'Expected the owner to not change.');
        System.assertEquals(accountPlan2.OwnerId, updatedAccountPlan2.OwnerId, 'Expected the owner to not change.');
    }

    @isTest
    static void getIdsForRelatedObjectsToAccountPlanTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockService = md.mockSettingService;
        SObjectServiceImpl mockSObjectService = md.mockSObjectService;

        // Given
        CRUSH_Settings_Obj__c mockOrgSettings = new CRUSH_Settings_Obj__c(
            Type__c = 'Org',
            Task_Objects_Related_To_Account_Plan__c = 'Opportunity,Contact,Account'
        );

        md.mocks.startStubbing();
        md.mocks.when(mockService.getOrgSettingsAndCreateIfNeeded()).thenReturn(mockOrgSettings);
        md.mocks.when(
                mockSObjectService.getIdsForRelatedObjects(
                    md.mockAccountPlanId,
                    new List<Schema.sObjectType>{
                        Opportunity.getSObjectType(),
                        Contact.getSObjectType(),
                        Account.getSObjectType()
                    }
                )
            )
            .thenReturn(new Set<Id>());
        md.mocks.stopStubbing();

        Set<Id> result = AccountPlanService.getIdsForRelatedObjectsToAccountPlan(
            md.mockAccountPlanId,
            md.mockAccountId
        );

        ((SObjectServiceImpl) md.mocks.verify(mockSObjectService, 1))
            .getIdsForRelatedObjects(
                md.mockAccountPlanId,
                new List<Schema.sObjectType>{
                    Opportunity.getSObjectType(),
                    Contact.getSObjectType(),
                    Account.getSObjectType()
                }
            );
        System.assert(result.contains(md.mockAccountId));
    }

    @isTest
    static void getIdsForRelatedObjectsToAccountPlanNullTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockService = md.mockSettingService;
        SObjectServiceImpl mockSObjectService = md.mockSObjectService;

        // Given
        CRUSH_Settings_Obj__c mockOrgSettings = new CRUSH_Settings_Obj__c(
            Type__c = 'Org',
            Task_Objects_Related_To_Account_Plan__c = null
        );

        md.mocks.startStubbing();
        md.mocks.when(mockService.getOrgSettingsAndCreateIfNeeded()).thenReturn(mockOrgSettings);
        md.mocks.stopStubbing();

        Set<Id> result = AccountPlanService.getIdsForRelatedObjectsToAccountPlan(
            md.mockAccountPlanId,
            md.mockAccountId
        );

        ((SObjectServiceImpl) md.mocks.verify(mockSObjectService, 0))
            .getIdsForRelatedObjects(md.mockAccountPlanId, new List<Schema.sObjectType>());
        System.assertEquals(0, result.size());
    }
}