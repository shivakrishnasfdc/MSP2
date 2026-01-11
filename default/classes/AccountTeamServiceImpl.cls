public with sharing class AccountTeamServiceImpl {
    public class AccountTeamException extends Exception {
    }

    public List<AccountTeamService.AccountTeamMemberWrapper> getAccountTeamMembersAsSystem(Set<Id> accountIds) {
        if (!areAccountTeamsEnabled()) {
            throw new AccountTeamException('Account Teams must be enabled');
        }
        return new SystemContext().getAccountTeamMembers(accountIds);
    }

    /**
     * checks for the existense of the Account Team object type in the org
     */
    public Boolean areAccountTeamsEnabled() {
        Boolean accountTeamsEnabled = false;
        Schema.SObjectType accountTeamMemberObjectType = Application.getGlobalDescribe().get('AccountTeamMember');
        if (accountTeamMemberObjectType != null) {
            accountTeamsEnabled = true;
        }
        return accountTeamsEnabled;
    }

    /**
     * checks to see if the crush org setting for enabling account teams is on
     */
    public Boolean isAccountTeamSettingEnabled() {
        Boolean settingEnabled = false;
        if (areAccountTeamsEnabled()) {
            CrushSettings orgSettings = new CrushSettings(SettingService.getOrgSettingsAndCreateIfNeeded());
            if (orgSettings.useAccountTeamPermissions != null && orgSettings.useAccountTeamPermissions) {
                settingEnabled = true;
            }
        }
        return settingEnabled;
    }

    private without sharing class SystemContext {
        private List<AccountTeamService.AccountTeamMemberWrapper> getAccountTeamMembers(Set<Id> accountIds) {
            List<AccountTeamService.AccountTeamMemberWrapper> results = new List<AccountTeamService.AccountTeamMemberWrapper>();
            Query query = new Query('AccountTeamMember', null)
                .setLimit(Limits.getLimitQueryRows())
                .selectFields(new Set<String>{ 'Id', 'AccountId', 'UserId', 'AccountAccessLevel' })
                .lookup('AccountId', accountIds)
                .addConditionEq('User.IsActive', true);
            List<SObject> teamMembers = query.toSObjectList();
            for (SObject teamMember : teamMembers) {
                results.add(new AccountTeamService.AccountTeamMemberWrapper(teamMember));
            }
            return results;
        }
    }
}