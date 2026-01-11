@isTest
private class TasksControllerTest {
    public static final String CREATOR_USER_FIRST_NAME = 'Shabby';
    public static final String CREATOR_USER_LAST_NAME = 'Break';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User creatorUser = TestDataFactory.createUser(
            CREATOR_USER_FIRST_NAME,
            CREATOR_USER_LAST_NAME,
            standardProfile.Id
        );

        PermissionSet creatorUserPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'CRUSH_Account_Plan_Creator'
            LIMIT 1
        ];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = creatorUser.Id, PermissionSetId = creatorUserPermissionSet.Id)
        };

        System.runAs(creatorUser) {
            Account testAccount = new Account(Name = 'Account 1');
            insert testAccount;

            Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan('account plan 1', testAccount);

            Task task = new Task(WhatId = accountPlan1.Id);
            insert task;
        }
    }

    @isTest
    static void getTasksForAccountPlanNullPlansTest() {
        List<AccountPlanTaskWrapper> returnedWrappers = TasksController.getTasksForAccountPlan(null, 1, 5, null);
        System.assertEquals(
            0,
            returnedWrappers.size(),
            'Should return an empty list of wrappers if null account plan ids are passed'
        );
    }

    @isTest
    static void getTasksForAccountPlanNoIdsTest() {
        List<AccountPlanTaskWrapper> returnedWrappers = TasksController.getTasksForAccountPlan(
            new List<Id>(),
            1,
            5,
            null
        );
        System.assertEquals(
            0,
            returnedWrappers.size(),
            'Should return an empty list of wrappers if no account plan ids are passed'
        );
    }

    @isTest
    static void getTasksForAccountPlanNoPlansFoundTest() {
        TestMockData md = new TestMockData();
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;

        // Given
        List<Id> accountPlanIds = new List<Id>{ md.mockAccountPlanId };
        Set<Id> mockAccountPlanIdsSet = new Set<Id>(accountPlanIds);

        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanSelector.selectById(mockAccountPlanIdsSet))
            .thenReturn(new List<Account_Plan__c>());
        md.mocks.stopStubbing();

        // When
        List<AccountPlanTaskWrapper> returnedWrappers = TasksController.getTasksForAccountPlan(
            accountPlanIds,
            1,
            5,
            null
        );

        // Then
        System.assertEquals(
            0,
            returnedWrappers.size(),
            'Should return an empty list of wrappers if no account plans are found'
        );
    }

    @isTest
    static void getTasksForAccountPlanNoTasksTest() {
        TestMockData md = new TestMockData();
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;
        AccountServiceImpl mockAccountService = md.mockAccountService;
        AccountPlanServiceImpl mockAccountPlanService = md.mockAccountPlanService;
        TasksSelector mockTaskSelector = md.mockTasksSelector;

        // Given
        List<FilterObject> emptyFilters = new List<FilterObject>();
        List<Id> accountPlanIds = new List<Id>{ md.mockAccountPlanId };
        Set<Id> mockAccountPlanIdsSet = new Set<Id>(accountPlanIds);
        md.mockAccountPlan.Account__c = md.mockAccountId;
        Integer pageNumber = 1;
        Integer pageSize = 5;

        Set<Id> mockWhatIds = new Set<Id>{
            md.mockAccountId,
            md.mockOpportunityId,
            md.mockObjectiveId,
            md.mockAccountPlanId,
            md.mockContactId
        };

        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanSelector.selectById(mockAccountPlanIdsSet))
            .thenReturn(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mocks.when(mockAccountService.getTaskWhatIdsByAccountId(new Set<Id>{ md.mockAccountId }))
            .thenReturn(
                new Map<Id, Set<Id>>{ md.mockAccountId => new Set<Id>{ md.mockOpportunityId, md.mockContactId } }
            );
        md.mocks.when(
                mockAccountPlanService.getTaskWhatIdsByAccountPlanIdForMap(
                    new Map<Id, Account_Plan__c>{ md.mockAccountPlanId => md.mockAccountPlan }
                )
            )
            .thenReturn(
                new Map<Id, Set<Id>>{ md.mockAccountPlanId => new Set<Id>{ md.mockAccountId, md.mockObjectiveId } }
            );
        md.mocks.when(
                mockTaskSelector.selectByRelatedIdsWithFiltersPaged(mockWhatIds, pageNumber, pageSize, emptyFilters)
            )
            .thenReturn(new List<Task>());
        md.mocks.stopStubbing();

        // When
        List<AccountPlanTaskWrapper> returnedWrappers = TasksController.getTasksForAccountPlan(
            accountPlanIds,
            pageNumber,
            pageSize,
            null
        );

        // Then
        System.assertEquals(
            0,
            returnedWrappers.size(),
            'Should return an empty list of wrappers if no tasks are found'
        );
    }

    @isTest
    static void getTasksForAccountPlanHappyPathViaWhatIdTest() {
        TestMockData md = new TestMockData();
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;
        AccountServiceImpl mockAccountService = md.mockAccountService;
        AccountPlanServiceImpl mockAccountPlanService = md.mockAccountPlanService;
        TasksSelector mockTaskSelector = md.mockTasksSelector;

        // Given
        List<FilterObject> emptyFilters = new List<FilterObject>();
        List<Id> accountPlanIds = new List<Id>{ md.mockAccountPlanId };
        Set<Id> mockAccountPlanIdsSet = new Set<Id>(accountPlanIds);
        md.mockAccountPlan.Account__c = md.mockAccountId;
        Integer pageNumber = 1;
        Integer pageSize = 5;

        Set<Id> mockWhatIds = new Set<Id>{
            md.mockAccountId,
            md.mockOpportunityId,
            md.mockObjectiveId,
            md.mockAccountPlanId
        };

        List<AccountPlanTaskWrapper> mockWrappers = new List<AccountPlanTaskWrapper>{
            new AccountPlanTaskWrapper(md.mockTask, new List<Account_plan__c>{ md.mockAccountPlan })
        };

        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanSelector.selectById(mockAccountPlanIdsSet))
            .thenReturn(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mocks.when(mockAccountService.getTaskWhatIdsByAccountId(new Set<Id>{ md.mockAccountId }))
            .thenReturn(new Map<Id, Set<Id>>{ md.mockAccountId => new Set<Id>{ md.mockOpportunityId } });
        md.mocks.when(
                mockAccountPlanService.getTaskWhatIdsByAccountPlanIdForMap(
                    new Map<Id, Account_Plan__c>{ md.mockAccountPlanId => md.mockAccountPlan }
                )
            )
            .thenReturn(
                new Map<Id, Set<Id>>{ md.mockAccountPlanId => new Set<Id>{ md.mockAccountId, md.mockObjectiveId } }
            );
        md.mocks.when(
                mockTaskSelector.selectByRelatedIdsWithFiltersPaged(mockWhatIds, pageNumber, pageSize, emptyFilters)
            )
            .thenReturn(new List<Task>{ md.mockTask });
        md.mocks.stopStubbing();

        // When
        List<AccountPlanTaskWrapper> returnedWrappers = TasksController.getTasksForAccountPlan(
            accountPlanIds,
            pageNumber,
            pageSize,
            null
        );

        // Then
        System.assertEquals(
            returnedWrappers,
            mockWrappers,
            'Should return the expected list of wrappers and associate them with the correct account plan via the what id'
        );
    }

    @isTest
    static void getTasksForAccountPlanHappyPathViaWhoIdTest() {
        TestMockData md = new TestMockData();
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;
        AccountServiceImpl mockAccountService = md.mockAccountService;
        AccountPlanServiceImpl mockAccountPlanService = md.mockAccountPlanService;
        TasksSelector mockTaskSelector = md.mockTasksSelector;

        // Given
        List<FilterObject> emptyFilters = new List<FilterObject>();
        List<Id> accountPlanIds = new List<Id>{ md.mockAccountPlanId };
        Set<Id> mockAccountPlanIdsSet = new Set<Id>(accountPlanIds);
        md.mockAccountPlan.Account__c = md.mockAccountId;
        Integer pageNumber = 1;
        Integer pageSize = 5;

        Set<Id> mockWhatIds = new Set<Id>{
            md.mockContactId,
            md.mockOpportunityId,
            md.mockObjectiveId,
            md.mockAccountPlanId
        };

        List<AccountPlanTaskWrapper> mockWrappers = new List<AccountPlanTaskWrapper>{
            new AccountPlanTaskWrapper(md.mockTask, new List<Account_plan__c>{ md.mockAccountPlan })
        };

        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanSelector.selectById(mockAccountPlanIdsSet))
            .thenReturn(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mocks.when(mockAccountService.getTaskWhatIdsByAccountId(new Set<Id>{ md.mockAccountId }))
            .thenReturn(new Map<Id, Set<Id>>{ md.mockAccountId => new Set<Id>{ md.mockOpportunityId } });
        md.mocks.when(
                mockAccountPlanService.getTaskWhatIdsByAccountPlanIdForMap(
                    new Map<Id, Account_Plan__c>{ md.mockAccountPlanId => md.mockAccountPlan }
                )
            )
            .thenReturn(
                new Map<Id, Set<Id>>{ md.mockAccountPlanId => new Set<Id>{ md.mockContactId, md.mockObjectiveId } }
            );
        md.mocks.when(
                mockTaskSelector.selectByRelatedIdsWithFiltersPaged(mockWhatIds, pageNumber, pageSize, emptyFilters)
            )
            .thenReturn(new List<Task>{ md.mockTask });
        md.mocks.stopStubbing();

        // When
        List<AccountPlanTaskWrapper> returnedWrappers = TasksController.getTasksForAccountPlan(
            accountPlanIds,
            pageNumber,
            pageSize,
            null
        );

        // Then
        System.assertEquals(
            returnedWrappers,
            mockWrappers,
            'Should return the expected list of wrappers and associate them with the correct account plan via the who id'
        );
    }

    @isTest
    static void getTasksForAccountPlanHappyPathMultiplePlansTest() {
        TestMockData md = new TestMockData();
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;
        AccountServiceImpl mockAccountService = md.mockAccountService;
        AccountPlanServiceImpl mockAccountPlanService = md.mockAccountPlanService;
        TasksSelector mockTaskSelector = md.mockTasksSelector;

        // Given
        Account_Plan__c plan2 = new Account_Plan__c(
            Name = 'Account Plan 2',
            Account__c = md.mockAccountId,
            Id = fflib_IDGenerator.generate(Account_Plan__c.SObjectType)
        );
        List<FilterObject> emptyFilters = new List<FilterObject>();
        List<Id> accountPlanIds = new List<Id>{ md.mockAccountPlanId, plan2.Id };
        Set<Id> mockAccountPlanIdsSet = new Set<Id>(accountPlanIds);
        List<Account_plan__c> accountPlans = new List<Account_plan__c>{ md.mockAccountPlan, plan2 };
        md.mockAccountPlan.Account__c = md.mockAccountId;
        Integer pageNumber = 1;
        Integer pageSize = 5;

        Set<Id> mockWhatIds = new Set<Id>{
            md.mockAccountId,
            md.mockOpportunityId,
            md.mockObjectiveId,
            md.mockAccountPlanId,
            plan2.Id
        };

        List<AccountPlanTaskWrapper> mockWrappers = new List<AccountPlanTaskWrapper>{
            new AccountPlanTaskWrapper(md.mockTask, new List<Account_plan__c>{ md.mockAccountPlan, plan2 })
        };

        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanSelector.selectById(mockAccountPlanIdsSet)).thenReturn(accountPlans);
        md.mocks.when(mockAccountService.getTaskWhatIdsByAccountId(new Set<Id>{ md.mockAccountId }))
            .thenReturn(new Map<Id, Set<Id>>{ md.mockAccountId => new Set<Id>{ md.mockOpportunityId } });
        md.mocks.when(
                mockAccountPlanService.getTaskWhatIdsByAccountPlanIdForMap(
                    new Map<Id, Account_Plan__c>{ md.mockAccountPlanId => md.mockAccountPlan, plan2.Id => plan2 }
                )
            )
            .thenReturn(
                new Map<Id, Set<Id>>{
                    md.mockAccountPlanId => new Set<Id>{ md.mockAccountId, md.mockObjectiveId },
                    plan2.Id => new Set<Id>{ md.mockAccountId }
                }
            );
        md.mocks.when(
                mockTaskSelector.selectByRelatedIdsWithFiltersPaged(mockWhatIds, pageNumber, pageSize, emptyFilters)
            )
            .thenReturn(new List<Task>{ md.mockTask });
        md.mocks.stopStubbing();

        // When
        List<AccountPlanTaskWrapper> returnedWrappers = TasksController.getTasksForAccountPlan(
            accountPlanIds,
            pageNumber,
            pageSize,
            null
        );

        // Then
        System.assertEquals(
            mockWrappers,
            returnedWrappers,
            'Should return the expected list of wrappers and associate them with the correct account plan via the who id'
        );
        System.assertEquals(
            2,
            returnedWrappers[0].accountPlanRecords.size(),
            'Should return the expected list of account plans'
        );
    }

    @isTest
    static void getTasksForAllAccountPlansNonePlansFoundTest() {
        TestMockData md = new TestMockData();
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;

        // Given
        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanSelector.selectAll()).thenReturn(new List<Account_Plan__c>());
        md.mocks.stopStubbing();

        // When
        List<AccountPlanTaskWrapper> returnedWrappers = TasksController.getTasksForAllAccountPlans(1, 5, null);

        // Then
        System.assertEquals(
            0,
            returnedWrappers.size(),
            'Should return an empty list of wrappers if no account plans are found'
        );
    }

    @isTest
    static void getTasksForAllAccountPlansNoTasksFoundTest() {
        TestMockData md = new TestMockData();
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;
        TasksSelector mockTaskSelector = md.mockTasksSelector;

        // Given
        List<FilterObject> emptyFilters = new List<FilterObject>();
        md.mockAccountPlan.Account__c = md.mockAccountId;
        Integer pageNumber = 1;
        Integer pageSize = 5;

        Set<Id> mockWhatIds = new Set<Id>{ md.mockAccountPlanId };

        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanSelector.selectAll()).thenReturn(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mocks.when(
                mockTaskSelector.selectByRelatedIdsWithFiltersPaged(mockWhatIds, pageNumber, pageSize, emptyFilters)
            )
            .thenReturn(new List<Task>());
        md.mocks.stopStubbing();

        // When
        List<AccountPlanTaskWrapper> returnedWrappers = TasksController.getTasksForAllAccountPlans(
            pageNumber,
            pageSize,
            null
        );

        // Then
        System.assertEquals(
            0,
            returnedWrappers.size(),
            'Should return an empty list of wrappers if no tasks are found'
        );
    }

    @isTest
    static void getTasksForAllAccountPlansHappyPathViaWhatIdTest() {
        TestMockData md = new TestMockData();
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;
        TasksSelector mockTaskSelector = md.mockTasksSelector;

        // Given
        List<FilterObject> emptyFilters = new List<FilterObject>();
        md.mockAccountPlan.Account__c = md.mockAccountId;
        Integer pageNumber = 1;
        Integer pageSize = 5;

        Set<Id> mockWhatIds = new Set<Id>{ md.mockAccountPlanId };

        List<AccountPlanTaskWrapper> mockWrappers = new List<AccountPlanTaskWrapper>{
            new AccountPlanTaskWrapper(md.mockTask, new List<Account_plan__c>{ md.mockAccountPlan })
        };

        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanSelector.selectAll()).thenReturn(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mocks.when(
                mockTaskSelector.selectByRelatedIdsWithFiltersPaged(mockWhatIds, pageNumber, pageSize, emptyFilters)
            )
            .thenReturn(new List<Task>{ md.mockTask });
        md.mocks.stopStubbing();

        // When
        List<AccountPlanTaskWrapper> returnedWrappers = TasksController.getTasksForAllAccountPlans(
            pageNumber,
            pageSize,
            null
        );

        // Then
        System.assertEquals(
            returnedWrappers,
            mockWrappers,
            'Should return the expected list of wrappers and associate them with the correct account plan via the what id'
        );
    }

    @isTest
    static void getTasksForAllAccountPlansHappyPathViaWhoIdTest() {
        TestMockData md = new TestMockData();
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;
        TasksSelector mockTaskSelector = md.mockTasksSelector;

        // Given
        List<FilterObject> emptyFilters = new List<FilterObject>();
        md.mockAccountPlan.Account__c = md.mockAccountId;
        Integer pageNumber = 1;
        Integer pageSize = 5;

        Set<Id> mockWhatIds = new Set<Id>{ md.mockAccountPlanId };

        List<AccountPlanTaskWrapper> mockWrappers = new List<AccountPlanTaskWrapper>{
            new AccountPlanTaskWrapper(md.mockTask, new List<Account_plan__c>{ md.mockAccountPlan })
        };

        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanSelector.selectAll()).thenReturn(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mocks.when(
                mockTaskSelector.selectByRelatedIdsWithFiltersPaged(mockWhatIds, pageNumber, pageSize, emptyFilters)
            )
            .thenReturn(new List<Task>{ md.mockTask });
        md.mocks.stopStubbing();

        // When
        List<AccountPlanTaskWrapper> returnedWrappers = TasksController.getTasksForAllAccountPlans(
            pageNumber,
            pageSize,
            null
        );

        // Then
        System.assertEquals(
            returnedWrappers,
            mockWrappers,
            'Should return the expected list of wrappers and associate them with the correct account plan via the who id'
        );
    }

    @isTest
    static void getTaskCountForAccountPlanNullPlanIdTest() {
        Integer result = TasksController.getTaskCountForAccountPlan(null, '[]');
        System.assertEquals(0, result, 'Should return 0 when no account plan ids are passed');
    }

    @isTest
    static void getTaskCountForAccountPlanNoPlanIdTest() {
        Integer result = TasksController.getTaskCountForAccountPlan(new List<Id>(), '[]');
        System.assertEquals(0, result, 'Should return 0 when no account plan ids are passed');
    }

    @isTest
    static void getTaskCountForAccountPlanHappyPathTest() {
        TestMockData md = new TestMockData();
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;
        AccountServiceImpl mockAccountService = md.mockAccountService;
        AccountPlanServiceImpl mockAccountPlanService = md.mockAccountPlanService;
        TasksSelector mockTaskSelector = md.mockTasksSelector;

        // Given
        List<FilterObject> emptyFilters = new List<FilterObject>();
        List<Id> accountPlanIds = new List<Id>{ md.mockAccountPlanId };
        Set<Id> mockAccountPlanIdsSet = new Set<Id>(accountPlanIds);
        md.mockAccountPlan.Account__c = md.mockAccountId;
        Integer expectedCount = 4;

        Set<Id> mockWhatIds = new Set<Id>{
            md.mockAccountId,
            md.mockOpportunityId,
            md.mockObjectiveId,
            md.mockAccountPlanId
        };

        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanSelector.selectById(mockAccountPlanIdsSet))
            .thenReturn(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mocks.when(mockAccountService.getTaskWhatIdsByAccountId(new Set<Id>{ md.mockAccountId }))
            .thenReturn(new Map<Id, Set<Id>>{ md.mockAccountId => new Set<Id>{ md.mockOpportunityId } });
        md.mocks.when(
                mockAccountPlanService.getTaskWhatIdsByAccountPlanIdForMap(
                    new Map<Id, Account_Plan__c>{ md.mockAccountPlanId => md.mockAccountPlan }
                )
            )
            .thenReturn(
                new Map<Id, Set<Id>>{ md.mockAccountPlanId => new Set<Id>{ md.mockAccountId, md.mockObjectiveId } }
            );
        md.mocks.when(mockTaskSelector.selectCountByRelatedIdsWithFilters(mockWhatIds, emptyFilters))
            .thenReturn(expectedCount);
        md.mocks.stopStubbing();

        // When
        Integer result = TasksController.getTaskCountForAccountPlan(accountPlanIds, null);

        // Then
        System.assertEquals(expectedCount, result, 'Should return the expected count of tasks');
    }

    @isTest
    static void getTaskCountForAllAccountPlansNoneFoundTest() {
        TestMockData md = new TestMockData();
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;

        // Given
        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanSelector.selectAll()).thenReturn(new List<Account_Plan__c>());
        md.mocks.stopStubbing();

        // When
        Integer returnedCount = TasksController.getTaskCountForAllAccountPlans('[]');

        // Then
        System.assertEquals(0, returnedCount, 'Should return 0 when no account plans are found');
    }

    @isTest
    static void getTaskCountForAllAccountPlansHappyPathTest() {
        TestMockData md = new TestMockData();
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;
        TasksSelector mockTaskSelector = md.mockTasksSelector;

        // Given
        List<FilterObject> emptyFilters = new List<FilterObject>();
        md.mockAccountPlan.Account__c = md.mockAccountId;
        Integer expectedCount = 4;

        Set<Id> mockWhatIds = new Set<Id>{ md.mockAccountPlanId };

        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanSelector.selectAll()).thenReturn(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mocks.when(mockTaskSelector.selectCountByRelatedIdsWithFilters(mockWhatIds, emptyFilters))
            .thenReturn(expectedCount);
        md.mocks.stopStubbing();

        // When
        Integer returnedCount = TasksController.getTaskCountForAllAccountPlans('[]');

        // Then
        System.assertEquals(expectedCount, returnedCount, 'Should return the expected count of tasks');
    }

    @isTest
    static void getUserRecordAccessForTasksTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        UserRecordAccessSelector mockSelector = (UserRecordAccessSelector) FFLibHelper.mockSelector(
            UserRecordAccessSelector.class,
            mocks
        );

        Application.Selector.setMock(mockSelector);

        // Given
        User creatorUser = [SELECT Id FROM User WHERE LastName = :CREATOR_USER_LAST_NAME];
        Task task = [SELECT Id FROM Task];
        Set<Id> recordIds = new Set<Id>{ task.Id };

        UserRecordAccess mockRecordAcces = [
            SELECT RecordId, HasAllAccess, HasDeleteAccess, HasEditAccess, HasReadAccess
            FROM UserRecordAccess
            WHERE RecordId = :task.Id AND UserId = :creatorUser.Id
        ];
        List<UserRecordAccess> mockRecordAccesList = new List<UserRecordAccess>{ mockRecordAcces };

        mocks.startStubbing();
        mocks.when(mockSelector.selectByRecordId(recordIds)).thenReturn(mockRecordAccesList);
        mocks.stopStubbing();

        Map<Id, UserRecordAccess> expectedResponse = new Map<Id, UserRecordAccess>();
        expectedResponse.put(task.Id, mockRecordAcces);

        // When
        Map<Id, UserRecordAccess> returnedAccess = TasksController.getUserRecordAccessForTasks(new List<Id>{ task.Id });

        // Then
        ((UserRecordAccessSelector) mocks.verify(mockSelector, 1)).selectByRecordId(recordIds);
        System.assertEquals(returnedAccess, expectedResponse);
    }

    @isTest
    static void getTaskByIdTasksReturnedTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        TasksSelector mockSelector = (TasksSelector) FFLibHelper.mockSelector(TasksSelector.class, mocks);

        Application.Selector.setMock(mockSelector);

        // Given
        Task task = [SELECT Id FROM Task];
        Set<Id> taskIdSet = new Set<Id>{ task.Id };

        mocks.startStubbing();
        mocks.when(mockSelector.selectById(taskIdSet)).thenReturn(new List<Task>{ task });
        mocks.stopStubbing();

        // When
        Task returnedTask = TasksController.getTaskById(task.Id);

        // Then
        ((TasksSelector) mocks.verify(mockSelector, 1)).selectById(taskIdSet);
        System.assertEquals(returnedTask, task);
    }

    @isTest
    static void getTaskByIdNullReturnedTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        TasksSelector mockSelector = (TasksSelector) FFLibHelper.mockSelector(TasksSelector.class, mocks);

        Application.Selector.setMock(mockSelector);

        // Given
        Task task = [SELECT Id FROM Task];
        Set<Id> taskIdSet = new Set<Id>{ task.Id };

        mocks.startStubbing();
        mocks.when(mockSelector.selectById(taskIdSet)).thenReturn(new List<Task>());
        mocks.stopStubbing();

        // When
        Task returnedTask = TasksController.getTaskById(task.Id);

        // Then
        ((TasksSelector) mocks.verify(mockSelector, 1)).selectById(taskIdSet);
        System.assertEquals(returnedTask, null);
    }

    @isTest
    static void getUpdateStatusPicklistValuesTest() {
        // Given
        List<TaskStatus> closedStatuses = [SELECT ApiName FROM TaskStatus WHERE IsClosed = TRUE];
        List<TaskStatus> openStatuses = [SELECT ApiName FROM TaskStatus WHERE IsClosed = FALSE];

        // When
        Map<String, List<FilterObject>> returnedMap = TasksController.getUpdateStatusPicklistValues();

        System.assertEquals(returnedMap.size(), 2);
        List<FilterObject> returnedOpen = returnedMap.get('open');
        System.assertEquals(returnedOpen.size(), openStatuses.size());
        List<FilterObject> returnedClosed = returnedMap.get('closed');
        System.assertEquals(returnedClosed.size(), closedStatuses.size());
    }

    @isTest
    static void getTasksForContactTest() {
        TestMockData md = new TestMockData();
        TasksSelector mockTasksSelector = md.mockTasksSelector;

        Task t1 = new Task(Subject = 'task1');
        Task t2 = new Task(Subject = 'task2');

        md.mocks.startStubbing();
        md.mocks.when(mockTasksSelector.selectByWhoId(new Set<Id>{ md.mockContactId }, true, 20, false))
            .thenReturn(new List<Task>{ t1 });
        md.mocks.when(mockTasksSelector.selectByWhoId(new Set<Id>{ md.mockContactId }, false, 20, true))
            .thenReturn(new List<Task>{ t2 });
        md.mocks.stopStubbing();

        // When
        List<TaskWrapper> result = TasksController.getTasksForContact(md.mockContactId);

        ((TasksSelector) md.mocks.verify(mockTasksSelector, 1))
            .selectByWhoId(new Set<Id>{ md.mockContactId }, true, 20, false);
        ((TasksSelector) md.mocks.verify(mockTasksSelector, 1))
            .selectByWhoId(new Set<Id>{ md.mockContactId }, false, 20, true);
        System.assertEquals(2, result.size());
    }

    @isTest
    static void getAccountPlanFiltersTest() {
        TestMockData md = new TestMockData();
        AccountPlanSelector mockAccountPlanSelector = md.mockAccountPlanSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockAccountPlanSelector.selectAll()).thenReturn(new List<Account_Plan__c>{ md.mockAccountPlan });
        md.mocks.stopStubbing();

        // When
        List<FilterSectionObject> result = TasksController.getAccountPlanFilters();

        System.assertEquals(1, result.size());
    }

    @isTest
    static void getRecordTypeInfoTest() {
        // When
        List<RecordTypeInfoWrapper> result = TasksController.getRecordTypeInfo();

        System.assertEquals(1, result.size());
    }

    @isTest
    static void getFilterValuesTest() {
        List<FilterSectionObject> result = TasksController.getFilterValues();
        System.assertEquals(3, result.size());
    }

    // Test when filters have saved values
    @isTest
    static void getFilterValuesTest2() {
        TestMockData md = new TestMockData();
        CrushUserSettingServiceImpl mockCrushUserSettingService = md.mockCrushUserSettingService;

        String taskfilterjson = '[{"field":"OwnerId","isDefault":true,"isSelected":true,"label":"My Tasks","value":"OwnerMine"},{"field":"ActivityDate","isDefault":false,"isSelected":false,"label":"Last 7 Days","value":"LAST_N_DAYS:7"},{"field":"Status","isDefault":false,"isSelected":false,"label":"In Progress","value":"In Progress"},{"field":"Status","isDefault":false,"isSelected":false,"label":"Completed","value":"Completed"}]';
        pq_Crush_User_Setting__c setting = new pq_Crush_User_Setting__c(Account_Plan_Task_Filter__c = taskfilterjson);

        md.mocks.startStubbing();
        md.mocks.when(mockCrushUserSettingService.getSetting()).thenReturn(setting);
        md.mocks.stopStubbing();

        List<FilterSectionObject> result = TasksController.getFilterValues();
        System.assertEquals(3, result.size());
        for (FilterSectionObject fso : result) {
            for (FilterObject fo : fso.filters) {
                if (fo.field == 'OwnerId' && fo.value == 'OwnerMine') {
                    if (fo.value == 'OwnerMine') {
                        System.assertEquals(true, fo.isSelected);
                    } else {
                        System.assertEquals(false, fo.isSelected);
                    }
                } else if (fo.field == 'ActivityDate') {
                    if (fo.value == 'LAST_N_DAYS:7') {
                        System.assertEquals(true, fo.isSelected);
                    } else {
                        System.assertEquals(false, fo.isSelected);
                    }
                } else if (fo.field == 'Status') {
                    if (fo.value == 'In Progress' || fo.value == 'Completed') {
                        System.assertEquals(true, fo.isSelected);
                    } else {
                        System.assertEquals(false, fo.isSelected);
                    }
                }
            }
        }
    }

    @isTest
    static void deleteTaskTest() {
        Task t1 = new Task(Subject = 'test1');
        Task t2 = new Task(Subject = 'test2');
        insert t1;
        insert t2;

        TasksController.deleteTask(t2.Id);

        List<Task> queried = [SELECT Id FROM Task];

        for (Task t : queried) {
            System.assertNotEquals(t2.Id, t.Id);
        }
    }

    @isTest
    static void upsertStatusTest() {
        Task t1 = new Task(Subject = 'test1');
        Task t2 = new Task(Subject = 'test2', Status = 'In Progress');
        insert t1;
        insert t2;

        TasksController.upsertStatus(t2.Id, 'Completed');

        Task queried = [SELECT Id, Status FROM Task WHERE Id = :t2.Id];

        System.assertEquals('Completed', queried.Status);
    }
}