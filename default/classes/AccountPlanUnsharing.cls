@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class AccountPlanUnsharing {
    public class AccountPlanUnsharingException extends Exception {
    }

    @InvocableMethod(
        label='Unshare Account Plans by User and Account'
        description='Removes sharing records for the User to Account Plans that have a relationship to the Account'
        category='Account Plan'
    )
    global static void unshareAccountPlans(List<AccountPlanUnsharingInput> inputs) {
        if (!AccountTeamService.areAccountTeamsEnabled()) {
            throw new AccountPlanUnsharingException('Account Teams must be enabled to use this method');
        }

        Set<Id> userIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        for (AccountPlanUnsharingInput input : inputs) {
            userIds.add(input.userId);
            accountIds.add(input.accountId);
        }

        // only keep active users
        userIds = UsersSelector.newInstance().selectActiveUserIdsAsSystem(userIds);

        List<Account_Plan__c> accountPlans = AccountPlanSelector.newInstance().selectByAccountIdsAsSystem(accountIds);
        Set<Id> accountPlanIds = new Map<Id, Account_Plan__c>(accountPlans).keyset();

        List<Account_Plan__Share> sharesToDelete = AccountPlanSharesSelector.newInstance()
            .selectByAccoundPlanIdsAndUserIdsAsSystem(
                accountPlanIds,
                userIds,
                Schema.Account_Plan__Share.RowCause.AccountTeam__c
            );

        if (sharesToDelete != null && sharesToDelete.size() > 0) {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
            uow.registerDeleted(sharesToDelete);
            new SystemContext().commitWork(uow);
        }
    }

    global class AccountPlanUnsharingInput {
        @InvocableVariable(label='UserId' description='The Id of the User' required=true)
        global Id userId;

        @InvocableVariable(label='AccountId' description='The Id of the Account' required=true)
        global Id accountId;
    }

    private without sharing class SystemContext {
        private void commitWork(fflib_ISObjectUnitOfWork uow) {
            uow.commitWork();
        }
    }
}