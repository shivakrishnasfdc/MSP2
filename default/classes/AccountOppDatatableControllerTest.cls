@isTest
private class AccountOppDatatableControllerTest {
    public static final String STANDARD_USER_FIRST_NAME = 'Alex';
    public static final String STANDARD_USER_LAST_NAME = 'Allen';

    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User standardUser = TestDataFactory.createUser(
            STANDARD_USER_FIRST_NAME,
            STANDARD_USER_LAST_NAME,
            standardProfile.Id
        );
        PermissionSet standardUserPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = :CRUSH_STANDARD_USER
            LIMIT 1
        ];

        insert new PermissionSetAssignment(
            AssigneeId = standardUser.Id,
            PermissionSetId = standardUserPermissionSet.Id
        );

        System.runAs(standardUser) {
            Account rootAccount = new Account(Name = 'Root');
            insert rootAccount;
            Account child1Level1 = new Account(Name = 'Child1 Level1', ParentId = rootAccount.Id);
            Account child2Level1 = new Account(Name = 'Child2 Level1', ParentId = rootAccount.Id);
            Account child3Level1 = new Account(Name = 'Child3 Level1', ParentId = rootAccount.Id);
            insert new List<Account>{ child1Level1, child2Level1, child3Level1 };
            Account child1Level2 = new Account(Name = 'Child1 Level2', ParentId = child1Level1.Id);
            insert child1Level2;

            Opportunity rootOpp = TestDataFactory.createOpportunity(rootAccount, 'root Opp');
            rootOpp.Amount = 100;
            Opportunity child1Level1Opp = TestDataFactory.createOpportunity(child1Level1, 'child1Level1 Opp');
            child1Level1Opp.IsPrivate = true;
            Opportunity child2Level1Opp = TestDataFactory.createOpportunity(child2Level1, 'child2Level1 Opp');
            Opportunity child3Level1Opp = TestDataFactory.createOpportunity(child3Level1, 'child3Level1 Opp');
            Opportunity child1Level2Opp = TestDataFactory.createOpportunity(child1Level2, 'child1Level2 Opp');
            insert new List<Opportunity>{ rootOpp, child1Level1Opp, child2Level1Opp, child3Level1Opp, child1Level2Opp };
        }
    }

    @isTest
    static void getDatatableDataReturnsExpectedDataForRootAccount() {
        // Given
        Account rootAccount = getAccount('Root');

        Id masterAccountPlanId = null;

        // When
        Map<String, Object> result = AccountOppDataTableController.getDatatableData(
            masterAccountPlanId,
            rootAccount.Id,
            'Amount, StageName',
            null,
            false
        );

        // Then
        List<Opportunity> opps = (List<Opportunity>) result.get(DataTableService.TABLE_DATA_KEY);
        List<Map<String, Object>> columns = (List<Map<String, Object>>) result.get(DataTableService.TABLE_COLUMNS_KEY);
        System.assertEquals(1, opps.size());
        System.assertEquals(3, columns.size());
        System.assertEquals('Name', columns.get(0).get('fieldName'));
    }

    @isTest
    static void getDatatableDataReturnsExpectedDataForRootAccountWithMasterPlan() {
        // Given
        TestMockData md = new TestMockData();
        Account rootAccount = getAccount('Root');
        MasterAccountPlanServiceImpl mockMasterAccountPlanService = md.mockMasterAccountPlanService;

        Id masterAccountPlanId = md.mockMasterAccountPlanId;

        md.mocks.startStubbing();
        md.mocks.when(mockMasterAccountPlanService.getRelatedAccountIdsByMasterAccountPlans(new Set<Id>{ md.mockMasterAccountPlanId }))
            .thenReturn(new Set<Id>{ md.mockAccountId });
        md.mocks.stopStubbing();

        // When
        Map<String, Object> result = AccountOppDataTableController.getDatatableData(
            masterAccountPlanId,
            rootAccount.Id,
            'Amount, StageName',
            null,
            false
        );

        // Then
        List<Opportunity> opps = (List<Opportunity>) result.get(DataTableService.TABLE_DATA_KEY);
        List<Map<String, Object>> columns = (List<Map<String, Object>>) result.get(DataTableService.TABLE_COLUMNS_KEY);
        System.assertEquals(1, opps.size());
        System.assertEquals(3, columns.size());
        System.assertEquals('Name', columns.get(0).get('fieldName'));
    }

    @isTest
    static void getDatatableDataThrowsErrorWhenFieldIsNotValid() {
        // Given
        Account rootAccount = getAccount('Root');
        Id masterAccountPlanId = null;
        // Then
        try {
            AccountOppDataTableController.getDatatableData(masterAccountPlanId, rootAccount.Id, 'Amount, Stage', null, false);
            System.assert(false, 'Expected exception to be thrown.');
        } catch (AuraHandledException e) {
            System.assert(true, 'Exception was thrown.');
        }
    }

    @isTest
    static void getDatatableDataReturnsDescendentOpps() {
        // Given
        Account rootAccount = getAccount('Root');
        Id masterAccountPlanId = null;

        // When
        Map<String, Object> result = AccountOppDataTableController.getDatatableData(
            masterAccountPlanId,
            rootAccount.Id,
            'Amount, StageName',
            null,
            true
        );

        // Then
        List<Opportunity> opps = (List<Opportunity>) result.get(DataTableService.TABLE_DATA_KEY);
        List<Map<String, Object>> columns = (List<Map<String, Object>>) result.get(DataTableService.TABLE_COLUMNS_KEY);
        System.assertEquals(5, opps.size());
        System.assertEquals(4, columns.size());
        System.assertEquals('Account_Name', columns.get(1).get('fieldName'));
    }

    @isTest
    static void getDatatableDataFiltersDataBySingleCondition() {
        // Given
        Account rootAccount = getAccount('Root');
        Id masterAccountPlanId = null;
        String conditionString = 'Amount > 0';

        // When
        Map<String, Object> result = AccountOppDataTableController.getDatatableData(
            masterAccountPlanId,
            rootAccount.Id,
            'Amount, StageName',
            conditionString,
            true
        );

        // Then
        List<Opportunity> opps = (List<Opportunity>) result.get(DataTableService.TABLE_DATA_KEY);
        System.assertEquals(1, opps.size());
    }

    @isTest
    static void getDatatableDataFiltersDataByMoreThanOneCondition() {
        // Given
        Account rootAccount = getAccount('Root');
        String conditionString = 'Amount > 0 OR IsPrivate = true';
        Id masterAccountPlanId = null;

        // When
        Map<String, Object> result = AccountOppDataTableController.getDatatableData(
            masterAccountPlanId,
            rootAccount.Id,
            'Amount, StageName',
            conditionString,
            true
        );

        // Then
        List<Opportunity> opps = (List<Opportunity>) result.get(DataTableService.TABLE_DATA_KEY);
        System.assertEquals(2, opps.size());
    }

    @isTest
    static void getFiltersCreatesFilterRecordIfOneDoesNotExist() {
        //Given
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        OpportunityListUserFilterSelector mockOpportunityListUserFilterSelector = md.mockOpportunityListUserFilterSelector;
        Id userId = UserInfo.getUserId();

        md.mocks.startStubbing();
        md.mocks.when(mockOpportunityListUserFilterSelector.selectByAccountPlanAndUser(md.mockAccountPlanId, userId))
            .thenReturn(null);
        md.mocks.stopStubbing();

        Opportunity_List_User_Filter__c newFilterRecord = (Opportunity_List_User_Filter__c) Opportunity_List_User_Filter__c.SObjectType.newSObject(
            null,
            true
        );
        newFilterRecord.AccountPlan__c = md.mockAccountPlanId;
        newFilterRecord.User__c = userId;

        Map<String, Object> result = AccountOppDataTableController.getFilters(
            md.mockAccountPlanId,
            'Amount, StageName'
        );

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerNew(newFilterRecord);
        List<Map<String, Object>> filters = (List<Map<String, Object>>) result.get('filters');

        system.assertNotEquals(null, filters);
        system.assertEquals('StageName', filters[0].get('name'));
        List<String> selectedValues = (List<String>) filters[0].get('selectedValues');
        system.assertEquals(0, selectedValues.size());
    }

    private static Account getAccount(String accountName) {
        return [SELECT Id, Name, ParentId FROM Account WHERE Name = :accountName LIMIT 1];
    }
}