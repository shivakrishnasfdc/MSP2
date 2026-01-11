public with sharing class TeamMemberService {
    public static Team_Member__c create(Team_Member__c teamMember) {
        return service().create(teamMember);
    }

    public static List<Team_Member__c> createOwnersForAccountPlans(List<Account_Plan__c> accountPlans) {
        return service().createOwnersForAccountPlans(accountPlans);
    }

    private static TeamMemberServiceImpl service() {
        return (TeamMemberServiceImpl) Application.Service.newInstance(TeamMemberServiceImpl.class);
    }
}