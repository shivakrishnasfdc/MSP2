@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class AccountPlanSharing {
    public class AccountPlanSharingException extends Exception {
    }

    @InvocableMethod(
        label='Share Account Plans associated with an Account and User'
        description='Creates sharing records for the User to Account Plans that have a relationship to the Account'
        category='Account Plan'
    )
    global static void shareAccountPlans(List<AccountPlanSharingInput> shareAccountPlansInput) {
        if (!AccountTeamService.areAccountTeamsEnabled()) {
            throw new AccountPlanSharingException('Account Teams must be enabled to use this method');
        }

        List<Account_Plan__Share> shareRecords = new List<Account_Plan__Share>();
        Map<Id, List<AccountPlanSharingInput>> accountIdToInputMap = new Map<Id, List<AccountPlanSharingInput>>();
        Set<Id> userIds = new Set<Id>();

        for (AccountPlanSharingInput input : shareAccountPlansInput) {
            userIds.add(input.userId);
            if (accountIdToInputMap.containsKey(input.accountId)) {
                List<AccountPlanSharingInput> inputList = accountIdToInputMap.get(input.accountId);
                inputList.add(input);
                accountIdToInputMap.put(input.accountId, inputList);
            } else {
                accountIdToInputMap.put(input.accountId, new List<AccountPlanSharingInput>{ input });
            }
        }

        List<Account_Plan__c> accountPlans = AccountPlanSelector.newInstance()
            .selectByAccountIdsAsSystem(accountIdToInputMap.keySet());
        
        // only keep active users
        userIds = UsersSelector.newInstance().selectActiveUserIdsAsSystem(userIds);

        for (Account_Plan__c accountPlan : accountPlans) {
            List<AccountPlanSharingInput> inputs = accountIdToInputMap.get(accountPlan.Account__c);
            for (AccountPlanSharingInput input : inputs) {
                if (userIds.contains(input.userId) && input.userId != accountPlan.OwnerId) {
                    Account_Plan__Share shareRecord = new Account_Plan__Share(
                        ParentId = accountPlan.Id,
                        UserOrGroupId = input.userId,
                        AccessLevel = input.accessLevel,
                        RowCause = Schema.Account_Plan__Share.RowCause.AccountTeam__c
                    );
                    shareRecords.add(shareRecord);
                }
            }
        }

        if (shareRecords != null && shareRecords.size() > 0) {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
            uow.registerNew(shareRecords);
            new SystemContext().commitWork(uow);
        }
    }

    global class AccountPlanSharingInput {
        @InvocableVariable(label='UserId' description='The Id of the User' required=true)
        global Id userId;

        @InvocableVariable(label='AccountId' description='The Id of the Account' required=true)
        global Id accountId;

        @InvocableVariable(
            label='AccessLevel'
            description='The Access Level for which the user should be assigned for the share record'
            required=true
        )
        global String accessLevel;
    }

    private without sharing class SystemContext {
        private void commitWork(fflib_ISObjectUnitOfWork uow) {
            uow.commitWork();
        }
    }
}