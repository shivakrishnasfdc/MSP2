@isTest
public class AccountPlanCloneBatchServiceTest {
    @isTest
    static void cloneAccountPlansTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AccountPlanSelector mockSelector = (AccountPlanSelector) FFLibHelper.mockSelector(
            AccountPlanSelector.class,
            mocks
        );
        AccountPlanCloneServiceImpl mockService = (AccountPlanCloneServiceImpl) mocks.mock(
            AccountPlanCloneServiceImpl.class
        );

        Application.Selector.setMock(mockSelector);
        Application.Service.setMock(AccountPlanCloneServiceImpl.class, mockService);

        Account_Plan__c plan1 = new Account_Plan__c(
            Id = fflib_IDGenerator.generate(Account_Plan__c.SObjectType),
            Account__c = fflib_IDGenerator.generate(Account.SObjectType)
        );
        Account_Plan__c plan2 = new Account_Plan__c(
            Id = fflib_IDGenerator.generate(Account_Plan__c.SObjectType),
            Account__c = fflib_IDGenerator.generate(Account.SObjectType)
        );
        Account_Plan__c plan3 = new Account_Plan__c(
            Id = fflib_IDGenerator.generate(Account_Plan__c.SObjectType),
            Account__c = fflib_IDGenerator.generate(Account.SObjectType)
        );

        List<Id> planIds = new List<Id>{ plan1.Id, plan2.Id, plan3.Id };
        List<String> relationships = new List<String>{ 'rel1', 'rel2', 'rel3', 'rel4' };
        List<Account_Plan__c> plans = new List<Account_Plan__c>{ plan1, plan2, plan3 };

        List<AccountPlanCloneBatchInput> inputs = new List<AccountPlanCloneBatchInput>();
        inputs.add(new AccountPlanCloneBatchInput(planIds, null, null, null, relationships));

        mocks.startStubbing();
        mocks.when(mockSelector.selectByIdAsSystem(new Set<Id>(planIds))).thenReturn(plans);
        mocks.stopStubbing();

        AccountPlanCloneBatchService.cloneAccountPlans(inputs);

        List<AccountPlanCloneWrapper> wrappers = new List<AccountPlanCloneWrapper>();
        wrappers.add(new AccountPlanCloneWrapper(plan1.Id, null, null, plan1.Account__c, relationships));
        wrappers.add(new AccountPlanCloneWrapper(plan2.Id, null, null, plan2.Account__c, relationships));
        wrappers.add(new AccountPlanCloneWrapper(plan3.Id, null, null, plan3.Account__c, relationships));

        try {
            ((AccountPlanCloneServiceImpl) mocks.verify(mockService, 1)).cloneAccountPlans(wrappers);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }
}