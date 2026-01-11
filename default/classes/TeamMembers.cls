public with sharing class TeamMembers extends AccountPlanChildDomain {
    public static Boolean bypassEmailTrigger = false;

    public static final String ROLE_READ_WRITE = 'Edit';
    public static final String ROLE_OWNER = 'Edit';

    public TeamMembers(List<Team_Member__c> sObjectList) {
        super(sObjectList);
    }

    /******************************
     *       STATIC METHODS
     ******************************/

    public static TeamMembers newInstance(List<Team_Member__c> sObjectList) {
        return (TeamMembers) Application.Domain.newInstance(sObjectList);
    }

    public static String getUniqueKey(Team_Member__c teamMember) {
        return String.valueOf(TeamMember.Account_Plan__c) + String.valueOf(teamMember.User__c);
    }

    public static String getUniqueKey(Id accountPlanId, Id userId) {
        return String.valueOf(accountPlanId) + String.valueOf(userId);
    }

    /******************************
     *   TRIGGER HANDLER METHODS
     ******************************/

    public override void onValidate() {
        checkDuplicates();
    }

    public override void onValidate(Map<Id, SObject> existingRecords) {
        checkDuplicates();
    }

    public override void onAfterInsert() {
        upsertAccountPlanShares();

        if (!bypassEmailTrigger && !Application.bypassTrigger) {
            sendEmails(new Map<Id, sObject>(), false);
        }
    }

    public override void onAfterUpdate(Map<Id, sObject> oldRecords) {
        upsertAccountPlanShares();

        if (!bypassEmailTrigger && !Application.bypassTrigger) {
            sendEmails(oldRecords, false);
        }
    }

    public override void onBeforeDelete() {
        Map<Id, Account_Plan__c> plansById = getRelatedAccountPlansById();
        Map<Id, User> usersById = getRelatedUsersById();
        for (Team_Member__c teamMember : (List<Team_Member__c>) Records) {
            Account_Plan__c plan = plansById.get(teamMember.Account_Plan__c);
            User userObj = usersById.get(teamMember.User__c);
            if (plan != null && teamMember.User__c == plan.OwnerId && userObj.IsActive) {
                teamMember.addError(System.Label.error_team_member_owner_cannot_be_removed);
            }
        }
    }

    public override void onAfterDelete() {
        List<Account_Plan__Share> shareRecords = AccountPlanSharesSelector.newInstance()
            .selectByTeamMembers((List<Team_Member__c>) Records);
        new UpdateAccountPlanShares().deleteWithoutSharing(shareRecords);

        if (!bypassEmailTrigger && !Application.bypassTrigger) {
            sendEmails(new Map<Id, sObject>(), true);
        }
    }

    /******************************
     *      PRIVATE METHODS
     ******************************/

    private void checkDuplicates() {
        for (Team_Member__c duplicateMember : TeamMemberSelector.newInstance().selectDuplicatesAsSystem(Records)) {
            duplicateMember.addError(System.Label.error_duplicate_account_plan_team_member);
        }
    }

    private void sendEmails(Map<Id, sObject> existingRecords, Boolean deleting) {
        CRUSH_Settings_Obj__c settings = SettingService.getOrgSettingsAndCreateIfNeeded();

        if (!settings.Enable_Notifications__c || !settings.Team_Member_Added_Removed__c) {
            return;
        }

        List<SendEmailNotifications.SendEmailRequest> emailRequests = new List<SendEmailNotifications.SendEmailRequest>();

        for (SObject sobj : Records) {
            Team_Member__c teamMember = (Team_Member__c) sobj;
            Team_Member__c oldMember = (Team_Member__c) existingRecords.get(TeamMember.Id);

            if (oldMember == null) {
                SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();
                request.accountPlanId = teamMember.Account_Plan__c;
                request.teamMemberUserId = teamMember.User__c;

                if (deleting) {
                    request.eventType = 'User_Removed_from_Account_Plan';
                } else {
                    request.eventType = 'User_Added_Removed_from_Account_Plan';
                }

                emailRequests.add(request);
            } else if (oldMember.Role__c != TeamMember.Role__c) {
                SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();
                request.accountPlanId = teamMember.Account_Plan__c;
                request.teamMemberUserId = teamMember.User__c;
                request.eventType = 'User_Permissions_Updated';

                emailRequests.add(request);
            }
        }

        try {
            SendEmailNotifications.sendEmails(emailRequests);
        } catch (Exception e) {
            System.debug('Error thrown sending update Emails: ' + e.getMessage()); //NOPMD
        }
    }

    /**
     * Creates or updates a sharing record for each Team_Member__c record with the following mapping:
     *
     *  Sharing Record  |  Team Member Record
     *  ----------------|----------------------
     *  Parent Id       |  Account Plan Id
     *  User/Group Id   |  User Id
     *  Access Level    |  Role
     */
    private void upsertAccountPlanShares() {
        Map<Id, Account_Plan__c> accountPlansById = getRelatedAccountPlansById();
        Map<Id, User> usersById = getRelatedUsersById();
        List<Account_Plan__Share> shareRecords = new List<Account_Plan__Share>();

        for (Team_Member__c teamMember : (List<Team_Member__c>) Records) {
            Account_Plan__c accountPlan = accountPlansById.get(teamMember.Account_Plan__c);
            User userObj = usersById.get(teamMember.User__c);
            if (userObj == null || userObj.IsActive == false) {
                continue;
            }
            // Sharing records are unique per ParentId/UserOrGroupId/RowCause combination, so we can
            // create a new record with the appropriate access level and it will update the appropriate
            // sharing record if it already exists.
            shareRecords.add(
                new Account_Plan__Share(
                    ParentId = teamMember.Account_Plan__c,
                    UserOrGroupId = teamMember.User__c,
                    AccessLevel = AccountPlanShares.calculateAccessLevel(teamMember, accountPlan),
                    RowCause = Schema.Account_Plan__Share.RowCause.Account_Plan_Team__c
                )
            );
        }

        new UpdateAccountPlanShares().createWithoutSharing(shareRecords);
    }

    private Map<Id, Account_Plan__c> getRelatedAccountPlansById() {
        Set<Id> accountPlanIds = (Set<Id>) Collection.getUniqueValues(Records, Team_Member__c.Account_Plan__c);

        return new Map<Id, Account_Plan__c>(AccountPlanSelector.newInstance().selectByIdAsSystem(accountPlanIds));
    }

    private Map<Id, User> getRelatedUsersById() {
        Set<Id> userIds = (Set<Id>) Collection.getUniqueValues(Records, Team_Member__c.User__c);

        return new Map<Id, User>(UsersSelector.newInstance().selectByIdAsSystem(userIds));
    }

    /******************************
     *       INNER CLASSES
     ******************************/

    private without sharing class UpdateAccountPlanShares {
        private void createWithoutSharing(List<Account_Plan__Share> records) {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
            uow.registerNew(records);
            uow.commitWork();
        }

        private void deleteWithoutSharing(List<Account_Plan__Share> records) {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
            uow.registerDeleted(records);
            uow.commitWork();
        }
    }

    /**
     * This is a workaround for the lack of reflection in Apex.
     */
    public with sharing class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            TeamMembers members = new TeamMembers(sObjectList);
            members.Configuration.disableTriggerCRUDSecurity();

            return members;
        }
    }
}