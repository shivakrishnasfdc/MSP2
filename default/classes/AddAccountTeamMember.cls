public with sharing class AddAccountTeamMember {
    @AuraEnabled
    public static Team_Member__c addTeamMember(Id accountPlanId, Id userId, String role) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        Team_Member__c member = new Team_Member__c(Account_Plan__c = accountPlanId, User__c = userId, Role__c = role);

        uow.registerNew(member);
        uow.commitWork();

        return new TeamMemberSelector().selectById(new Set<Id>{ member.Id }).get(0);
    }
}