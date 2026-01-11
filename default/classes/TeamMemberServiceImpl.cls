public with sharing class TeamMemberServiceImpl {
    public Team_Member__c create(Team_Member__c teamMember) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerNew(teamMember);
        uow.commitWork();

        return teamMember;
    }

    public List<Team_Member__c> createOwnersForAccountPlans(List<Account_Plan__c> accountPlans) {
        List<Team_Member__c> members = new List<Team_Member__c>();
        for (Account_Plan__c accountPlan : accountPlans) {
            Team_Member__c teamMember = new Team_Member__c(
                User__c = accountPlan.OwnerId,
                Account_Plan__c = accountPlan.Id,
                Role__c = TeamMembers.ROLE_OWNER
            );

            members.add(teamMember);
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerNew(members);
        uow.commitWork();

        return members;
    }
}