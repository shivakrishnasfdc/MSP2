@SuppressWarnings('PMD.PropertyNamingConventions,PMD.EmptyStatementBlock')
public with sharing class AccountTeamService {
    public static List<AccountTeamService.AccountTeamMemberWrapper> getAccountTeamMembersAsSystem(Set<Id> accountIds) {
        return service().getAccountTeamMembersAsSystem(accountIds);
    }

    /**
     * checks for the existense of the Account Team object type in the org
     */
    public static Boolean areAccountTeamsEnabled() {
        return service().areAccountTeamsEnabled();
    }

    /**
     * checks to see if the crush org setting for enabling account teams is on
     */
    public static Boolean isAccountTeamSettingEnabled() {
        return service().isAccountTeamSettingEnabled();
    }

    public class AccountTeamMemberWrapper {
        public Id Id { get; set; }
        public Id AccountId { get; set; }
        public Id UserId { get; set; }
        public String AccountAccessLevel { get; set; }

        public AccountTeamMemberWrapper() {
        }

        public AccountTeamMemberWrapper(Sobject accountTeamMember) {
            this.Id = (Id) accountTeamMember.get('Id');
            this.AccountId = (Id) accountTeamMember.get('AccountId');
            this.UserId = (Id) accountTeamMember.get('UserId');
            this.AccountAccessLevel = (String) accountTeamMember.get('AccountAccessLevel');
        }
    }

    private static AccountTeamServiceImpl service() {
        return (AccountTeamServiceImpl) Application.Service.newInstance(AccountTeamServiceImpl.class);
    }
}