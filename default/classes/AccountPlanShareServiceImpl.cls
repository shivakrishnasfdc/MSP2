public with sharing class AccountPlanShareServiceImpl {
    public class AccountPlanShareException extends Exception {
    }

    public void updateAllAccountTeamShares() {
        List<Account_Plan__c> accountPlans = AccountPlanSelector.newInstance().selectAllWithSharesAsSystem();
        updateAllAccountTeamShares(accountPlans);
    }

    public void updateAllAccountTeamShares(List<Id> accountPlanIds) {
        List<Account_Plan__c> accountPlans = AccountPlanSelector.newInstance()
            .selectByIdWithSharesAsSystem(new Set<Id>(accountPlanIds));
        updateAllAccountTeamShares(accountPlans);
    }

    public void updateAllAccountTeamShares(List<Account_Plan__c> accountPlans) {
        // Get Account Plans and existing share records
        // Get Account Team Members for Accounts
        // Create/Update Account Plan share records for each Account Team member
        // Delete pre-existing share records that were created for Account Team members if they no longer have access to the Account
        Map<Id, Account_Plan__c> accountIdToPlanMap = (Map<Id, Account_Plan__c>) Collection.mapBy(
            Id.class,
            accountPlans,
            'Account__c'
        );

        List<AccountTeamService.AccountTeamMemberWrapper> accountTeamMembers = AccountTeamService.getAccountTeamMembersAsSystem(accountIdToPlanMap.keySet());

        Map<Id, List<AccountTeamService.AccountTeamMemberWrapper>> accountIdToTeamMembersMap = new Map<Id, List<AccountTeamService.AccountTeamMemberWrapper>>();
        for (AccountTeamService.AccountTeamMemberWrapper teamMember : accountTeamMembers) {
            if (accountIdToTeamMembersMap.containsKey(teamMember.accountId)) {
                List<AccountTeamService.AccountTeamMemberWrapper> teamMemberList = accountIdToTeamMembersMap.get(teamMember.accountId);
                teamMemberList.add(teamMember);
                accountIdToTeamMembersMap.put(teamMember.accountId, teamMemberList);
            } else {
                accountIdToTeamMembersMap.put(teamMember.accountId, new List<AccountTeamService.AccountTeamMemberWrapper>{ teamMember });
            }
        }

        List<Account_Plan__Share> sharesToUpsert = new List<Account_Plan__Share>();
        List<Account_Plan__Share> sharesToDelete = new List<Account_Plan__Share>();
        for (Account_Plan__c accountPlan : accountPlans) {
            List<AccountTeamService.AccountTeamMemberWrapper> teamMembers = accountIdToTeamMembersMap.get(accountPlan.Account__c);
            Map<Id, SObject> userIdToShareMap = new Map<Id, SObject>();
            if (teamMembers != null && !teamMembers.isEmpty()) {
                for (AccountTeamService.AccountTeamMemberWrapper member : teamMembers) {
                    if (accountPlan.OwnerId != member.userId) {
                        Account_Plan__Share shareRecord = new Account_Plan__Share(
                            ParentId = accountPlan.Id,
                            UserOrGroupId = member.userId,
                            AccessLevel = member.AccountAccessLevel,
                            RowCause = Schema.Account_Plan__Share.RowCause.AccountTeam__c
                        );
                        sharesToUpsert.add(shareRecord);
                        userIdToShareMap.put(member.userId, shareRecord);
                    }
                }
            }
            for (Account_Plan__Share share : accountPlan.Shares) {
                if (
                    share.RowCause == Schema.Account_Plan__Share.RowCause.AccountTeam__c &&
                    !userIdToShareMap.containsKey(share.UserOrGroupId)
                ) {
                    sharesToDelete.add(share);
                }
            }
        }
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerNew(sharesToUpsert);
        uow.registerDeleted(sharesToDelete);
        new SystemContext().commitWork(uow);
    }

    private without sharing class SystemContext {
        private void commitWork(fflib_ISObjectUnitOfWork uow) {
            uow.commitWork();
        }
    }
}