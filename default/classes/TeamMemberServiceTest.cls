@isTest
private class TeamMemberServiceTest {
    @isTest
    static void createTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        Application.unitOfWork.setMock(mockUow);

        // given
        Team_Member__c member = new Team_Member__c(
            User__c = fflib_IDGenerator.generate(User.SObjectType),
            Account_Plan__c = fflib_IDGenerator.generate(Account_Plan__c.SObjectType),
            Role__c = TeamMembers.ROLE_READ_WRITE
        );

        Test.startTest();
        TeamMemberService.create(member);
        Test.stopTest();

        // Then
        try {
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerNew(member);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Did not call registerNew()');
        }
    }

    @isTest
    static void createOwnersForAccountPlansTest() {
        // mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        Application.unitOfWork.setMock(mockUow);

        // given
        Id userId = fflib_IDGenerator.generate(User.SObjectType);
        Account_Plan__c planA = new Account_Plan__c(
            Id = fflib_IDGenerator.generate(Account_Plan__c.SObjectType),
            OwnerId = userId
        );
        Account_Plan__c planB = new Account_Plan__c(
            Id = fflib_IDGenerator.generate(Account_Plan__c.SObjectType),
            OwnerId = userId
        );

        List<Team_Member__c> members = new List<Team_Member__c>{
            new Team_Member__c(User__c = planA.OwnerId, Account_Plan__c = planA.Id, Role__c = TeamMembers.ROLE_OWNER),
            new Team_Member__c(User__c = planB.OwnerId, Account_Plan__c = planB.Id, Role__c = TeamMembers.ROLE_OWNER)
        };

        Test.startTest();
        TeamMemberService.createOwnersForAccountPlans(new List<Account_Plan__c>{ planA, planB });
        Test.stopTest();

        // Then
        try {
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1)).registerNew(members);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Did not call registerNew()');
        }
    }
}