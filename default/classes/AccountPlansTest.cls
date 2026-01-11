@isTest
private class AccountPlansTest {
    public static final String STANDARD_USER_FIRST_NAME = 'Manheim';
    public static final String STANDARD_USER_LAST_NAME = 'Visa';

    public static final String CREATOR_USER_FIRST_NAME = 'Shabby';
    public static final String CREATOR_USER_LAST_NAME = 'Break';

    public static final String ADMIN_USER_FIRST_NAME = 'Apple';
    public static final String ADMIN_USER_LAST_NAME = 'Create';

    public static final String NON_TEAM_USER_FIRST_NAME = 'Spongebob';
    public static final String NON_TEAM_USER_LAST_NAME = 'SquarePants';

    public static final String TRANSFER_USER_FIRST_NAME = 'Samurai';
    public static final String TRANSFER_USER_LAST_NAME = 'Jack';

    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';
    public static final String CRUSH_ACCOUNT_PLAN_CREATOR = 'CRUSH_Account_Plan_Creator';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User standardUser = TestDataFactory.createUser(
            STANDARD_USER_FIRST_NAME,
            STANDARD_USER_LAST_NAME,
            standardProfile.Id
        );
        User creatorUser = TestDataFactory.createUser(
            CREATOR_USER_FIRST_NAME,
            CREATOR_USER_LAST_NAME,
            standardProfile.Id
        );
        User adminUser = TestDataFactory.createUser(ADMIN_USER_FIRST_NAME, ADMIN_USER_LAST_NAME, standardProfile.Id);
        User nonTeamUser = TestDataFactory.createUser(
            NON_TEAM_USER_FIRST_NAME,
            NON_TEAM_USER_LAST_NAME,
            standardProfile.Id
        );
        User transferUser = TestDataFactory.createUser(
            TRANSFER_USER_FIRST_NAME,
            TRANSFER_USER_LAST_NAME,
            standardProfile.Id
        );

        PermissionSet standardUserPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = :CRUSH_STANDARD_USER
            LIMIT 1
        ];

        PermissionSet creatorUserPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = :CRUSH_ACCOUNT_PLAN_CREATOR
            LIMIT 1
        ];

        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR LIMIT 1];

        List<PermissionSetAssignment> permissionSets = new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = standardUser.Id, PermissionSetId = standardUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = creatorUser.Id, PermissionSetId = creatorUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = adminUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = nonTeamUser.Id, PermissionSetId = standardUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = transferUser.Id, PermissionSetId = standardUserPermissionSet.Id)
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
            TestDataFactory.createAccountPlan('account plan 1', testAccount, 'Open');
            TestDataFactory.createAccountPlan('account plan 2', testAccount, 'Open');
            TestDataFactory.createAccountPlan('account plan 3', testAccount, 'Open');
            TestDataFactory.createAccountPlan('account plan 4', testAccount, 'Open');
            TestDataFactory.createAccountPlan('account plan 5', testAccount, 'Closed');
        }

        System.runAs(adminUser) {
            AccountPlans.bypassEmailTrigger = true;
            TeamMembers.bypassEmailTrigger = true;

            Account testAccount = new Account(Name = 'Account 2');
            insert testAccount;

            TestDataFactory.createAccountPlan('account plan A', testAccount, 'Open');
            TestDataFactory.createAccountPlan('account plan B', testAccount, 'Open');
            insert new List<Account_Plan__c>{
                new Account_Plan__c(
                    Name = 'account plan C',
                    Account__c = testAccount.Id,
                    Status__c = 'Open',
                    OwnerId = standardUser.Id
                ),
                new Account_Plan__c(
                    Name = 'account plan D',
                    Account__c = testAccount.Id,
                    Status__c = 'Open',
                    OwnerId = standardUser.Id
                )
            };
        }
    }

    @isTest
    static void constructorTest() {
        System.assertNotEquals(null, new AccountPlans(new List<Account_Plan__c>()));
        System.assertEquals(
            false,
            new AccountPlans(new List<Account_Plan__c>()).Configuration.EnforcingTriggerCRUDSecurity,
            'Should not be enforcing Trigger CRUD Security due to complications with automation in customer orgs'
        );
        System.assertEquals(
            false,
            AccountPlans.newInstance(new List<Account_Plan__c>()).Configuration.EnforcingTriggerCRUDSecurity,
            'Should not be enforcing Trigger CRUD Security due to complications with automation in customer orgs'
        );
    }

    @isTest
    static void onValidateTest() {
        // Given
        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User creatorUser = [SELECT Id FROM User WHERE LastName = :CREATOR_USER_LAST_NAME];
        User standardUser = [SELECT Id FROM User WHERE LastName = :STANDARD_USER_LAST_NAME];
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        User nonTeamUser = [SELECT Id FROM User WHERE LastName = :NON_TEAM_USER_LAST_NAME];
        User transferUser = [SELECT Id FROM User WHERE LastName = :TRANSFER_USER_LAST_NAME];
        List<Account_Plan__c> accountPlanRecords = [
            SELECT Id, OwnerId, Status__c
            FROM Account_Plan__c
            WHERE OwnerId = :creatorUser.Id AND Status__c = 'Open'
        ];

        System.runAs(systemUser) {
            Team_Member__c standardTeamMember = new Team_Member__c(
                User__c = standardUser.Id,
                Account_Plan__c = accountPlanRecords[0].Id,
                Role__c = 'Read Only'
            );
            insert standardTeamMember;

            CRUSH_Settings_Obj__c orgSettings = new CRUSH_Settings_Obj__c(
                Type__c = 'Org',
                Account_Plan_Transfer__c = TransferSetting.USER.name(),
                Account_Plan_Transfer_User__c = transferUser.Id
            );
            List<CRUSH_Settings_Obj__c> orgSettingsList = [SELECT Id FROM CRUSH_Settings_Obj__c WHERE Type__c = 'Org'];
            if (orgSettingsList.size() > 0) {
                orgSettings.Id = orgSettingsList[0].Id;
            }
            upsert orgSettings;

            // When
            Test.startTest();

            List<Account_Plan__c> updatedRecords = accountPlanRecords.deepClone(true); // preserve IDs
            updatedRecords[0].OwnerId = standardUser.Id;
            updatedRecords[1].OwnerId = adminUser.Id;
            updatedRecords[2].OwnerId = nonTeamUser.Id;
            updatedRecords[3].OwnerId = transferUser.Id;

            List<Database.saveResult> saveResults = Database.update(updatedRecords, false);

            Test.stopTest();

            // Then
            System.assertEquals(true, saveResults[0].isSuccess());
            System.assertEquals(true, saveResults[1].isSuccess());
            System.assertEquals(false, saveResults[2].isSuccess());
            // The current owner is not being deactivated, so a transfer to the configured transfer user
            // is not valid (since they're not a team member).
            System.assertEquals(false, saveResults[3].isSuccess());
            System.assertEquals(1, saveResults[2].getErrors().size());
            System.assertEquals(1, saveResults[3].getErrors().size());
            System.assertEquals(
                System.Label.error_account_plan_owner_must_be_team_member,
                saveResults[2].getErrors()[0].getMessage()
            );
            System.assertEquals(
                System.Label.error_account_plan_owner_must_be_team_member,
                saveResults[3].getErrors()[0].getMessage()
            );
        }
    }

    @isTest
    static void onValidateDeactivatedOwnerTest() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        UsersSelector mockUsersSelector = (UsersSelector) FFLibHelper.mockSelector(UsersSelector.class, mocks);

        Application.Selector.setMock(mockUsersSelector);

        // Given
        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User creatorUser = [SELECT Id, Name, isActive FROM User WHERE LastName = :CREATOR_USER_LAST_NAME];
        User transferUser = [SELECT Id, Name, isActive FROM User WHERE LastName = :TRANSFER_USER_LAST_NAME];
        Account_Plan__c accountPlan = [
            SELECT Id, OwnerId, Status__c
            FROM Account_Plan__c
            WHERE OwnerId = :creatorUser.Id AND Status__c = 'Open'
            LIMIT 1
        ];
        User deactivatedCreatorUser = creatorUser.clone(true);
        deactivatedCreatorUser.isActive = false;

        mocks.startStubbing();
        mocks.when(mockUsersSelector.selectByIdAsSystem(new Set<Id>{ creatorUser.Id }))
            .thenReturn(new List<User>{ deactivatedCreatorUser });
        mocks.when(mockUsersSelector.selectByIdAsSystem(new Set<Id>{ transferUser.Id }))
            .thenReturn(new List<User>{ transferUser });
        mocks.stopStubbing();

        System.runAs(systemUser) {
            CRUSH_Settings_Obj__c orgSettings = new CRUSH_Settings_Obj__c(
                Type__c = 'Org',
                Account_Plan_Transfer__c = TransferSetting.USER.name(),
                Account_Plan_Transfer_User__c = transferUser.Id
            );
            List<CRUSH_Settings_Obj__c> orgSettingsList = [SELECT Id FROM CRUSH_Settings_Obj__c WHERE Type__c = 'Org'];
            if (orgSettingsList.size() > 0) {
                orgSettings.Id = orgSettingsList[0].Id;
            }
            upsert orgSettings;

            // When
            Test.startTest();

            Account_Plan__c updatedRecord = accountPlan.clone(true); // preserve IDs
            updatedRecord.OwnerId = transferUser.Id;

            Database.SaveResult saveResult = Database.update(updatedRecord, false);

            Test.stopTest();

            // Then

            // Because the original owner was deactivated, the transfer user is a valid
            // owner despite not being on the account team.
            System.assertEquals(true, saveResult.isSuccess());
        }
    }

    @isTest
    static void standardUserLockAccountPlansTest() {
        // Given
        User creatorUser = [SELECT Id FROM User WHERE LastName = :CREATOR_USER_LAST_NAME];
        User standardUser = [SELECT Id FROM User WHERE LastName = :STANDARD_USER_LAST_NAME];
        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        List<Account_Plan__c> accountPlans = [
            SELECT Id, Status__c, OwnerId
            FROM Account_Plan__c
            WHERE OwnerId = :standardUser.Id AND Status__c = 'Open'
        ];

        Map<Id, Id> ownersByAccountPlanId = new Map<Id, Id>();
        Map<Id, Account_Plan__c> accountPlansMap = new Map<Id, Account_Plan__c>(accountPlans);

        System.runAs(systemUser) {
            List<Team_Member__c> teamMembers = new List<Team_Member__c>();

            for (Account_Plan__c accountPlan : accountPlans) {
                teamMembers.add(
                    new Team_Member__c(User__c = creatorUser.Id, Account_Plan__c = accountPlan.Id, Role__c = 'Edit')
                );
                accountPlan.Status__c = 'Closed';
                ownersByAccountPlanId.put(accountPlan.OwnerId, accountPlan.Id);
            }
            insert teamMembers;
        }

        // When
        Test.startTest();

        System.runAs(standardUser) {
            update accountPlans;
        }

        Test.stopTest();

        // Then
        List<Account_Plan__Share> shareRecords = [
            SELECT Id, AccessLevel, UserOrGroupId, ParentId
            FROM Account_Plan__Share
            WHERE
                RowCause = :Schema.Account_Plan__Share.RowCause.Account_Plan_Team__c
                AND ParentId IN :accountPlansMap.keySet()
        ];

        System.assertEquals(4, shareRecords.size());
        for (Account_Plan__Share shareRecord : shareRecords) {
            Id accountPlanId = shareRecord.ParentId;
            Id ownerId = ownersByAccountPlanId.get(accountPlanId);
            if (ownerId == shareRecord.UserOrGroupId) {
                System.assertEquals('Edit', shareRecord.AccessLevel);
            } else {
                System.assertEquals('Read', shareRecord.AccessLevel);
            }
        }
    }

    @isTest
    static void creatorUserLockAccountPlansTest() {
        AccountPlans.bypassCreateOwnersTrigger = true;

        // Given
        User creatorUser = [SELECT Id FROM User WHERE LastName = :CREATOR_USER_LAST_NAME];
        User standardUser = [SELECT Id FROM User WHERE LastName = :STANDARD_USER_LAST_NAME];
        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        List<Account_Plan__c> accountPlans = [
            SELECT Id, Status__c, OwnerId
            FROM Account_Plan__c
            WHERE OwnerId = :creatorUser.Id AND Status__c = 'Open'
        ];

        Map<Id, Id> ownersByAccountPlanId = new Map<Id, Id>();
        Map<Id, Account_Plan__c> accountPlansMap = new Map<Id, Account_Plan__c>(accountPlans);

        System.runAs(systemUser) {
            List<Team_Member__c> teamMembers = new List<Team_Member__c>();

            for (Account_Plan__c accountPlan : accountPlans) {
                teamMembers.add(
                    new Team_Member__c(User__c = standardUser.Id, Account_Plan__c = accountPlan.Id, Role__c = 'Edit')
                );
                accountPlan.Status__c = 'Closed';
                ownersByAccountPlanId.put(accountPlan.OwnerId, accountPlan.Id);
            }
            insert teamMembers;
        }

        // When
        Test.startTest();

        System.runAs(creatorUser) {
            update accountPlans;
        }

        Test.stopTest();

        // Then
        List<Account_Plan__Share> shareRecords = [
            SELECT Id, AccessLevel, UserOrGroupId, ParentId
            FROM Account_Plan__Share
            WHERE
                RowCause IN (
                    :Schema.Account_Plan__Share.RowCause.Account_Plan_Team__c,
                    :Schema.Account_Plan__Share.RowCause.AccountTeam__c
                )
                AND ParentId IN :accountPlansMap.keySet()
        ];

        System.assertEquals(8, shareRecords.size());
        for (Account_Plan__Share shareRecord : shareRecords) {
            Id accountPlanId = shareRecord.ParentId;
            Id ownerId = ownersByAccountPlanId.get(accountPlanId);
            if (ownerId == shareRecord.UserOrGroupId) {
                System.assertEquals('Edit', shareRecord.AccessLevel);
            } else {
                System.assertEquals('Read', shareRecord.AccessLevel);
            }
        }
    }

    @isTest
    static void adminUserLockAccountPlansTest() {
        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        User standardUser = [SELECT Id FROM User WHERE LastName = :STANDARD_USER_LAST_NAME];
        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        List<Account_Plan__c> accountPlans = [
            SELECT Id, Status__c, OwnerId
            FROM Account_Plan__c
            WHERE OwnerId = :adminUser.Id AND Status__c = 'Open'
        ];

        Map<Id, Id> ownersByAccountPlanId = new Map<Id, Id>();
        Map<Id, Account_Plan__c> accountPlansMap = new Map<Id, Account_Plan__c>(accountPlans);

        System.runAs(systemUser) {
            List<Team_Member__c> teamMembers = new List<Team_Member__c>();

            for (Account_Plan__c accountPlan : accountPlans) {
                teamMembers.add(
                    new Team_Member__c(User__c = standardUser.Id, Account_Plan__c = accountPlan.Id, Role__c = 'Edit')
                );
                accountPlan.Status__c = 'Closed';
                ownersByAccountPlanId.put(accountPlan.OwnerId, accountPlan.Id);
            }
            insert teamMembers;
        }

        // When
        Test.startTest();

        System.runAs(adminUser) {
            update accountPlans;
        }

        Test.stopTest();

        // Then
        List<Account_Plan__Share> shareRecords = [
            SELECT Id, AccessLevel, UserOrGroupId, ParentId
            FROM Account_Plan__Share
            WHERE
                RowCause IN (
                    :Schema.Account_Plan__Share.RowCause.Account_Plan_Team__c,
                    :Schema.Account_Plan__Share.RowCause.AccountTeam__c
                )
                AND ParentId IN :accountPlansMap.keySet()
        ];

        System.assertEquals(4, shareRecords.size());
        for (Account_Plan__Share shareRecord : shareRecords) {
            Id accountPlanId = shareRecord.ParentId;
            Id ownerId = ownersByAccountPlanId.get(accountPlanId);
            if (ownerId == shareRecord.UserOrGroupId) {
                System.assertEquals('Edit', shareRecord.AccessLevel);
            } else {
                System.assertEquals('Read', shareRecord.AccessLevel);
            }
        }
    }

    @isTest
    static void onBeforeUpdateLockAccountPlans() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        AccountPlanShares mockAccountPlanShares = md.mockAccountPlanSharesDomain;
        AccountPlanSharesSelector mockAccountPlanSharesSelector = md.mockAccountPlanSharesSelector;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockSettings.Use_Default_Account_Plan_Score__c = false;

        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        Account_Plan__c openAccountPlan = [
            SELECT Id, Status__c, OwnerId
            FROM Account_Plan__c
            WHERE Status__c = 'Open'
            LIMIT 1
        ];
        Set<Id> accountPlanIds = new Set<Id>{ openAccountPlan.Id };

        List<Account_Plan__Share> shareRecords = new List<Account_Plan__Share>{
            new Account_Plan__Share(UserOrGroupId = adminUser.Id, ParentId = openAccountPlan.Id, AccessLevel = 'Edit')
        };

        // Mock behavior
        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanSharesSelector.selectByAccountPlanIdsAsSystem(accountPlanIds))
            .thenReturn(shareRecords);
        md.mocks.when(mockSettingService.getOrgSettings()).thenReturn(md.mockSettings);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        // When
        Account_Plan__c updatedAccountPlan = openAccountPlan.clone(true, false, false, false); // preserve Id
        updatedAccountPlan.Status__c = 'Closed';

        Map<Id, Account_Plan__c> existingRecords = new Map<Id, Account_Plan__c>(
            new List<Account_Plan__c>{ openAccountPlan }
        );
        List<Account_Plan__c> updatedRecords = new List<Account_Plan__c>{ updatedAccountPlan };

        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(systemUser) {
            AccountPlans.newInstance(updatedRecords).onBeforeUpdate(existingRecords);

            // Then
            try {
                ((AccountPlanSharesSelector) md.mocks.verify(mockAccountPlanSharesSelector, 1))
                    .selectByAccountPlanIdsAsSystem(accountPlanIds);
                ((AccountPlanShares) md.mocks.verify(mockAccountPlanShares, 1)).setReadOnly(mockUow);
                System.assert(true);
            } catch (fflib_ApexMocks.ApexMocksException e) {
                System.assert(false);
            }
        }
    }

    @isTest
    static void onBeforeUpdateUnLockAccountPlans() {
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        AccountPlanShares mockAccountPlanShares = md.mockAccountPlanSharesDomain; //NOPMD - Needs to be called in order for it to be mocked in the test
        AccountPlanSharesSelector mockAccountPlanSharesSelector = md.mockAccountPlanSharesSelector;
        TeamMemberSelector mockTeamMemberSelector = md.mockTeamMemberSelector;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        md.mockSettings.Use_Default_Account_Plan_Score__c = false;
        md.mockSettings.Enable_Notifications__c = false;

        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        Account_Plan__c closedAccountPlan = md.mockAccountPlan;
        closedAccountPlan.pqcrush__Status__c = 'Closed';
        Set<Id> accountPlanIds = new Set<Id>{ closedAccountPlan.Id };

        List<Account_Plan__Share> shareRecords = new List<Account_Plan__Share>{
            new Account_Plan__Share(UserOrGroupId = adminUser.Id, ParentId = closedAccountPlan.Id, AccessLevel = 'Edit')
        };
        List<Team_Member__c> teamMembers = new List<Team_Member__c>{
            new Team_Member__c(User__c = adminUser.Id, Account_Plan__c = closedAccountPlan.Id, Role__c = 'Edit')
        };

        // Mock behavior
        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanSharesSelector.selectByAccountPlanIdsAsSystem(accountPlanIds))
            .thenReturn(shareRecords);
        md.mocks.when(mockTeamMemberSelector.selectByAccountPlanIdsAsSystem(accountPlanIds)).thenReturn(teamMembers);
        md.mocks.when(mockTeamMemberSelector.selectByAccountPlanIdAndUserIdAsSystem(new Set<Id>(), new Set<Id>()))
            .thenReturn(new List<Team_Member__c>());
        md.mocks.when(mockSettingService.getOrgSettings()).thenReturn(md.mockSettings);
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        // When
        Account_Plan__c updatedAccountPlan = closedAccountPlan.clone(true, false, false, false); // preserve Id
        updatedAccountPlan.Status__c = 'Open';

        Map<Id, Account_Plan__c> existingRecords = new Map<Id, Account_Plan__c>(
            new List<Account_Plan__c>{ closedAccountPlan }
        );
        List<Account_Plan__c> updatedRecords = new List<Account_Plan__c>{ updatedAccountPlan };

        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs(systemUser) {
            AccountPlans.newInstance(updatedRecords).onBeforeUpdate(existingRecords);

            // Then
            try {
                ((TeamMemberSelector) md.mocks.verify(mockTeamMemberSelector, 1))
                    .selectByAccountPlanIdsAsSystem(accountPlanIds);
                ((AccountPlanSharesSelector) md.mocks.verify(mockAccountPlanSharesSelector, 1))
                    .selectByAccountPlanIdsAsSystem(accountPlanIds);
                ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(shareRecords);
                System.assert(true);
            } catch (fflib_ApexMocks.ApexMocksException e) {
                System.assert(false);
            }
        }
    }

    @isTest
    static void onBeforeUpdateReopenAccountPlanTest() {
        // Given
        User standardUser = [SELECT Id FROM User WHERE LastName = :STANDARD_USER_LAST_NAME];
        AccountPlans.bypassEmailTrigger = true;
        TeamMembers.bypassEmailTrigger = true;

        System.runAs(standardUser) {
            List<Account_Plan__c> accountPlans = [
                SELECT Id, Name, Status__c
                FROM Account_Plan__c
                WHERE OwnerId = :standardUser.Id
            ];

            for (Account_Plan__c accountPlan : accountPlans) {
                accountPlan.Status__c = 'Closed';
            }

            update accountPlans;

            // When
            Test.startTest();
            for (Account_Plan__c accountPlan : accountPlans) {
                accountPlan.Name += ' updated';
            }

            update accountPlans;
            Test.stopTest();

            // Then
            List<Account_Plan__c> updatedAccountPlans = [
                SELECT Id, Status__c
                FROM Account_Plan__c
                WHERE OwnerId = :standardUser.Id
            ];

            System.assertEquals(2, updatedAccountPlans.size());
            System.assertEquals('Open', updatedAccountPlans[0].Status__c);
            System.assertEquals('Open', updatedAccountPlans[1].Status__c);
        }
    }

    @isTest
    static void standardUserTransferOwnership() {
        // Given
        User creatorUser = [SELECT Id FROM User WHERE LastName = :CREATOR_USER_LAST_NAME];
        User standardUser = [SELECT Id FROM User WHERE LastName = :STANDARD_USER_LAST_NAME];
        List<Account_Plan__c> accountPlans = [
            SELECT Id, Status__c
            FROM Account_Plan__c
            WHERE OwnerId = :standardUser.Id
            ORDER BY Id
        ];

        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs(systemUser) {
            List<Team_Member__c> teamMembers = new List<Team_Member__c>();
            for (Account_Plan__c accountPlan : accountPlans) {
                teamMembers.add(
                    new Team_Member__c(User__c = creatorUser.Id, Account_Plan__c = accountPlan.Id, Role__c = 'Edit')
                );
            }
            insert teamMembers;
        }

        Test.startTest();

        System.runAs(standardUser) {
            // When
            for (Account_Plan__c accountPlan : accountPlans) {
                accountPlan.OwnerId = creatorUser.Id;
            }

            update accountPlans;
        }

        Test.stopTest();

        // Then
        Map<Id, Account_Plan__c> accountPlanMap = new Map<Id, Account_Plan__c>(accountPlans);
        Set<Id> accountPlanIds = accountPlanMap.keySet();

        // Then
        List<Team_Member__c> updatedTeamMembers = [
            SELECT User__c, Account_Plan__c, Role__c
            FROM Team_Member__c
            WHERE Account_Plan__c IN :accountPlanIds
            ORDER BY Account_Plan__c
        ];

        System.assertEquals(4, updatedTeamMembers.size());
        for (Team_Member__c member : updatedTeamMembers) {
            if (member.User__c == creatorUser.Id) {
                System.assertEquals('Edit', member.Role__c);
            } else if (member.User__c == standardUser.Id) {
                System.assertEquals('Edit', member.Role__c);
            }
        }
    }

    @isTest
    static void creatorUserTransferOwnership() {
        // Given
        User standardUser = [SELECT Id FROM User WHERE LastName = :STANDARD_USER_LAST_NAME];
        User creatorUser = [SELECT Id FROM User WHERE LastName = :CREATOR_USER_LAST_NAME];
        List<Account_Plan__c> accountPlans = [
            SELECT Id, Status__c
            FROM Account_Plan__c
            WHERE OwnerId = :creatorUser.Id AND Status__c = 'Open'
            ORDER BY Id
        ];

        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs(systemUser) {
            List<Team_Member__c> teamMembers = new List<Team_Member__c>();
            for (Account_Plan__c accountPlan : accountPlans) {
                teamMembers.add(
                    new Team_Member__c(User__c = standardUser.Id, Account_Plan__c = accountPlan.Id, Role__c = 'Edit')
                );
            }
            insert teamMembers;
        }

        Test.startTest();

        System.runAs(creatorUser) {
            // When
            for (Account_Plan__c accountPlan : accountPlans) {
                accountPlan.OwnerId = standardUser.Id;
            }

            update accountPlans;
        }

        Test.stopTest();

        // Then
        Map<Id, Account_Plan__c> accountPlanMap = new Map<Id, Account_Plan__c>(accountPlans);
        Set<Id> accountPlanIds = accountPlanMap.keySet();

        List<Team_Member__c> updatedTeamMembers = [
            SELECT User__c, Account_Plan__c, Role__c
            FROM Team_Member__c
            WHERE Account_Plan__c IN :accountPlanIds
            ORDER BY Account_Plan__c
        ];

        System.assertEquals(8, updatedTeamMembers.size());
        for (Team_Member__c member : updatedTeamMembers) {
            if (member.User__c == creatorUser.Id) {
                System.assertEquals('Edit', member.Role__c);
            } else if (member.User__c == standardUser.Id) {
                System.assertEquals('Edit', member.Role__c);
            }
        }
    }

    @isTest
    static void adminUserTransferOwnership() {
        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        User standardUser = [SELECT Id FROM User WHERE LastName = :STANDARD_USER_LAST_NAME];

        List<Team_Member__c> teamMembers = new List<Team_Member__c>();
        List<Account_Plan__c> accountPlans = new List<Account_Plan__c>();

        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs(systemUser) {
            accountPlans = [SELECT Id, Status__c FROM Account_Plan__c WHERE OwnerId = :adminUser.Id ORDER BY Id];

            for (Account_Plan__c accountPlan : accountPlans) {
                teamMembers.add(
                    new Team_Member__c(User__c = standardUser.Id, Account_Plan__c = accountPlan.Id, Role__c = 'Edit')
                );
            }
            insert teamMembers;
        }

        Test.startTest();

        System.runAs(adminUser) {
            // When
            for (Account_Plan__c accountPlan : accountPlans) {
                accountPlan.OwnerId = standardUser.Id;
            }

            update accountPlans;
        }

        Test.stopTest();

        // Then
        Map<Id, Account_Plan__c> accountPlanMap = new Map<Id, Account_Plan__c>(accountPlans);
        Set<Id> accountPlanIds = accountPlanMap.keySet();

        System.runAs(systemUser) {
            List<Team_Member__c> updatedTeamMembers = [
                SELECT User__c, Account_Plan__c, Role__c
                FROM Team_Member__c
                WHERE Account_Plan__c IN :accountPlanIds
                ORDER BY Account_Plan__c
            ];

            System.assertEquals(4, updatedTeamMembers.size());
            for (Team_Member__c member : updatedTeamMembers) {
                if (member.User__c == adminUser.Id) {
                    System.assertEquals('Edit', member.Role__c);
                } else if (member.User__c == standardUser.Id) {
                    System.assertEquals('Edit', member.Role__c);
                }
            }
        }
    }
}