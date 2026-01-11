@SuppressWarnings('PMD.ApexDangerousMethods')
public with sharing class AccountPlans extends PQSObjectDomainExt {
    public static final String STATUS_CLOSED = 'Closed';
    public static final String STATUS_OPEN = 'Open';
    private static final String PERMISSION_SET_STRATEGY_ADMIN = 'CRUSH_Administrator';

    public static Boolean bypassEmailTrigger = false;
    public static Boolean bypassCreateOwnersTrigger = false;

    private Boolean accountTeamSettingEnabled {
        get {
            if (accountTeamSettingEnabled == null) {
                accountTeamSettingEnabled = AccountTeamService.isAccountTeamSettingEnabled();
            }
            return accountTeamSettingEnabled;
        }
        set;
    }

    public AccountPlans(List<Account_Plan__c> records) {
        super(records);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    /******************************
     *       STATIC METHODS
     ******************************/

    public static AccountPlans newInstance(List<Account_Plan__c> sObjectList) {
        return (AccountPlans) Application.Domain.newInstance(sObjectList);
    }

    /******************************
     *   TRIGGER HANDLER METHODS
     ******************************/

    public override void onValidate(Map<Id, SObject> existingRecords) {
        validateOwners(existingRecords);
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        Set<Id> closedAccountPlanIds = new Set<Id>();
        Set<Id> openedAccountPlanIds = new Set<Id>();
        Map<Id, Account_Plan__c> closedAccountPlanMap = new Map<Id, Account_Plan__c>();
        Map<Id, Account_Plan__c> openedAccountPlanMap = new Map<Id, Account_Plan__c>();
        //CrushSettings settings = StrategySettingsController.getOrgSettings();

        for (Account_Plan__c accountPlan : (List<Account_Plan__c>) Records) {
            Account_Plan__c oldAccountPlan = (Account_Plan__c) existingRecords.get(accountPlan.Id);

            if (accountPlan.Status__c == STATUS_CLOSED) {
                if (oldAccountPlan.Status__c != STATUS_CLOSED) {
                    closedAccountPlanIds.add(accountPlan.Id);
                    closedAccountPlanMap.put(accountPlan.Id, accountPlan);
                } else if (oldAccountPlan.Status__c == STATUS_CLOSED) {
                    accountPlan.Status__c = STATUS_OPEN;
                    openedAccountPlanIds.add(accountPlan.Id);
                    openedAccountPlanMap.put(accountPlan.Id, accountPlan);
                }
            } else if (accountPlan.Status__c != STATUS_CLOSED && oldAccountPlan.Status__c == STATUS_CLOSED) {
                openedAccountPlanIds.add(accountPlan.Id);
                openedAccountPlanMap.put(accountPlan.Id, accountPlan);
            }
        }
		
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
		if(!closedAccountPlanIds.isEmpty()){
        	lockAccountPlans(closedAccountPlanIds, uow);
        }

        if (accountTeamSettingEnabled) {
            if(!openedAccountPlanMap.isEmpty()){
            	unlockAccountPlansForAccountTeams(openedAccountPlanMap, uow);
            }
        } else {
            if(!openedAccountPlanIds.isEmpty()){
            	unlockAccountPlans(openedAccountPlanIds, uow);
            }
        }

        new SystemContext().commitWork(uow);
    }

    public override void onAfterInsert() {
        if (!bypassEmailTrigger) {
            sendEmails(new Map<Id, SObject>());
        }
		
        if (accountTeamSettingEnabled) {
            AccountPlanShareService.updateAllAccountTeamShares(Records);
        } else {
            if (!bypassCreateOwnersTrigger) {
                TeamMembers.bypassEmailTrigger = true;
                bypassEmailTrigger = true;
                Application.bypassPlanReopen = true;
                TeamMemberService.createOwnersForAccountPlans((List<Account_Plan__c>) Records);
                TeamMembers.bypassEmailTrigger = false;
                bypassEmailTrigger = false;
                Application.bypassPlanReopen = false;
            }
        }
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        List<Account_Plan__c> transferredAccountPlans = new List<Account_Plan__c>();
        for (Account_Plan__c accountPlan : (List<Account_Plan__c>) Records) {
            Account_Plan__c oldAccountPlan = (Account_Plan__c) existingRecords.get(accountPlan.Id);

            if (accountPlan.OwnerId != oldAccountPlan.OwnerId) {
                transferredAccountPlans.add(accountPlan);
            }
        }
        new OwnershipTransfer(transferredAccountPlans, existingRecords).handleTransfer();

        if (!bypassEmailTrigger && !Application.bypassTrigger) {
            sendEmails(existingRecords);
        }
    }

    /******************************
     *      PRIVATE METHODS
     ******************************/

    /**
     * Check if the owner of each record is valid. A User is considered a valid owner
     * for an Account Plan if they meet any of the following criteria:
     *
     *  1. The User is a team member on the Account Plan.
     *  2. The User has the Strategy Administrator permission set.
     *  3. The previous owner has been deactivated and the User
     *     has been configured to be the new owner in these scenarios.
     *
     * Any records whose owners do not meet the above criteria will be marked with an
     * error to prevent them from being updated.
     * @param accountPlans Account Plan records to validate.
     */
    private void validateOwners(Map<Id, SObject> existingRecords) {
        List<Account_Plan__c> accountPlans = (List<Account_Plan__c>) Records;
        Set<Id> accountPlanIds = new Set<Id>();
        Set<Id> newOwnerIds = new Set<Id>();
        Set<Id> oldOwnerIds = new Set<Id>();

        for (Account_Plan__c accountPlan : accountPlans) {
            Account_Plan__c oldAccountPlan = (Account_Plan__c) existingRecords.get(accountPlan.Id);
            accountPlanIds.add(accountPlan.Id);
            newOwnerIds.add(accountPlan.OwnerId);
            oldOwnerIds.add(oldAccountPlan.OwnerId);
        }

        Crush_Settings_Obj__c orgSettings = SettingService.getOrgSettingsAndCreateIfNeeded();
        List<Account_Plan__Share> currentShareRecords = AccountPlanSharesSelector.newInstance()
            .selectByAccountPlanIdsAsSystem(accountPlanIds);
        Set<Id> strategyAdminIds = new Map<Id, User>(
                new UsersSelector().selectByPermissionSetNameAdmin(PERMISSION_SET_STRATEGY_ADMIN)
            )
            .keyset();
        Map<Id, User> oldOwnersByid = new Map<Id, User>(UsersSelector.newInstance().selectByIdAsSystem(oldOwnerIds));
        Map<Id, Set<Id>> userIdsByAccountPlanId = new Map<Id, Set<Id>>();

        for (Account_Plan__Share share : currentShareRecords) {
            if (userIdsByAccountPlanId.get(share.ParentId) == null) {
                userIdsByAccountPlanId.put(share.ParentId, new Set<Id>());
            }
            userIdsByAccountPlanId.get(share.ParentId).add(share.UserOrGroupId);
        }

        for (Account_Plan__c accountPlan : accountPlans) {
            Account_Plan__c oldAccountPlan = (Account_Plan__c) existingRecords.get(accountPlan.Id);
            User oldOwner = oldOwnersById.get(oldAccountPlan.OwnerId);
            Set<Id> shareRecordUserIds = userIdsByAccountPlanId.get(accountPlan.Id);
            Boolean hasNewOwner = oldAccountPlan.OwnerId != accountPlan.OwnerId;
            Boolean hasAccess = shareRecordUserIds != null && shareRecordUserIds.contains(accountPlan.OwnerId);
            Boolean isAdmin = strategyAdminIds.contains(accountPlan.OwnerId);
            Boolean isTransferUser =
                !oldOwner.isActive &&
                orgSettings.Account_Plan_Transfer__c == TransferSetting.USER.name() &&
                orgSettings.Account_Plan_Transfer_User__c == accountPlan.OwnerId;

            if (hasNewOwner && !hasAccess && !isAdmin && !isTransferUser) {
                accountPlan.addError(System.Label.error_account_plan_owner_must_be_team_member);
            }
        }
    }

    private void updateScoreForPlan(Account_Plan__c accountPlan) {
        Double updatedScore = HealthScoreService.getTotalScoreForAccountPlan(accountPlan);
        accountPlan.Intermediate_Score__c = updatedScore;
    }

    private void updateScoreForPlanPercent(Account_Plan__c accountPlan) {
        Double updatedScore = HealthScoreService.getTotalScoreForAccountPlanPercent(accountPlan);
        accountPlan.Intermediate_Score__c = updatedScore;
    }

    /**
     * "Locks" an account plan by setting all team members' record access to Read Only for the given account plans.
     * @param accountPlanIds Record IDs of the account plans to lock.
     * @param uow            Unit of work that the changes should be added to.
     */
    private void lockAccountPlans(Set<Id> accountPlanIds, fflib_ISObjectUnitOfWork uow) {
        List<Account_Plan__Share> shareRecords = AccountPlanSharesSelector.newInstance()
            .selectByAccountPlanIdsAsSystem(accountPlanIds);

        if (shareRecords != null && !shareRecords.isEmpty()) {
            AccountPlanShares.newInstance(shareRecords).setReadOnly(uow);
        }
    }

    /**
     * "Unlocks" an account plan by restoring team members' record access for the given account plan based on
     * the roles defined for each team member.
     * @param accountPlanIds Record IDs of the account plans to lock.
     * @param uow            Unit of work that the changes should be added to.
     */
    private void unlockAccountPlans(Set<Id> accountPlanIds, fflib_ISObjectUnitOfWork uow) {
        List<Account_Plan__Share> shareRecords = AccountPlanSharesSelector.newInstance()
            .selectByAccountPlanIdsAsSystem(accountPlanIds);
        List<Team_Member__c> teamMemberRecords = TeamMemberSelector.newInstance()
            .selectByAccountPlanIdsAsSystem(accountPlanIds);

        if (shareRecords != null && !shareRecords.isEmpty()) {
            Map<String, Team_Member__c> teamMemberRecordsByUniqueKey = new Map<String, Team_Member__c>();

            for (Team_Member__c teamMember : teamMemberRecords) {
                teamMemberRecordsByUniqueKey.put(TeamMembers.getUniqueKey(teamMember), teamMember);
            }

            for (Account_Plan__Share shareRecord : shareRecords) {
                Team_Member__c teamMember = teamMemberRecordsByUniqueKey.get(
                    AccountPlanShares.getUniqueKey(shareRecord)
                );

                if (teamMember != null) {
                    shareRecord.AccessLevel = AccountPlanShares.calculateAccessLevel(teamMember);
                }
            }

            uow.registerDirty(shareRecords);
        }
    }

    /**
     * "Unlocks" an account plan by restoring team members' record access for the given account plan based on
     * the roles defined for each team member.
     * @param accountPlanIds Record IDs of the account plans to lock.
     * @param uow            Unit of work that the changes should be added to.
     */
    private void unlockAccountPlansForAccountTeams(
        Map<Id, Account_Plan__c> accountPlanMap,
        fflib_ISObjectUnitOfWork uow
    ) {
        Map<Id, Account_Plan__c> accountIdToPlanMap = (Map<Id, Account_Plan__c>) Collection.mapBy(
            Id.class,
            accountPlanMap.values(),
            'Account__c'
        );

        List<Account_Plan__Share> shareRecords = AccountPlanSharesSelector.newInstance()
            .selectByAccountPlanIdsAsSystem(accountPlanMap.keySet());
        List<AccountTeamService.AccountTeamMemberWrapper> teamMemberRecords = AccountTeamService.getAccountTeamMembersAsSystem(
            accountIdToPlanMap.keySet()
        );

        if (shareRecords != null && !shareRecords.isEmpty()) {
            Map<String, AccountTeamService.AccountTeamMemberWrapper> teamMemberRecordsByUniqueKey = new Map<String, AccountTeamService.AccountTeamMemberWrapper>();

            for (AccountTeamService.AccountTeamMemberWrapper teamMember : teamMemberRecords) {
                Id accountPlanId = accountIdToPlanMap.get(teamMember.accountId).Id;
                String key = String.valueOf(accountPlanId) + String.valueOf(teamMember.userId);
                teamMemberRecordsByUniqueKey.put(key, teamMember);
            }

            for (Account_Plan__Share shareRecord : shareRecords) {
                AccountTeamService.AccountTeamMemberWrapper teamMember = teamMemberRecordsByUniqueKey.get(
                    AccountPlanShares.getUniqueKey(shareRecord)
                );

                if (teamMember != null) {
                    shareRecord.AccessLevel = teamMember.AccountAccessLevel;
                }
            }
            uow.registerDirty(shareRecords);
        }
    }

    private void sendEmails(Map<Id, SObject> existingRecords) {
        CRUSH_Settings_Obj__c settings = SettingService.getOrgSettingsAndCreateIfNeeded();

        if (!settings.Enable_Notifications__c) {
            return;
        }

        List<SendEmailNotifications.SendEmailRequest> emailRequests = new List<SendEmailNotifications.SendEmailRequest>();

        for (SObject sobj : Records) {
            Account_Plan__c accountPlan = (Account_Plan__c) sobj;
            Account_Plan__c existingPlan = (Account_Plan__c) existingRecords.get(accountPlan.Id);

            if (planOverviewIsUpdated(accountPlan, existingPlan, settings)) {
                SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();
                request.accountPlanId = accountPlan.Id;
                request.eventType = 'Plan_Overview_Is_Updated';
                emailRequests.add(request);
            }

            if (goalIsUpdated(accountPlan, existingPlan, settings)) {
                SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();
                request.accountPlanId = accountPlan.Id;
                request.eventType = 'Goal_Is_Updated';
                emailRequests.add(request);
            }

            if (statusIsUpdated(accountPlan, existingPlan, settings)) {
                SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();
                request.accountPlanId = accountPlan.Id;
                request.eventType = 'Status_Is_Updated';
                emailRequests.add(request);
            }
        }

        try {
            SendEmailNotifications.sendEmails(emailRequests);
        } catch (Exception e) {
            System.debug('Error thrown sending update Emails: ' + e.getMessage()); //NOPMD
        }
    }

    private Boolean planOverviewIsUpdated(
        Account_Plan__c accountPlan,
        Account_Plan__c existingPlan,
        CRUSH_Settings_Obj__c settings
    ) {
        return !String.isBlank(accountPlan.Plan_Overview__c) &&
            (existingPlan != null &&
            accountPlan.Plan_Overview__c != existingPlan.Plan_Overview__c) &&
            settings.Plan_Overview_Updated__c;
    }

    private Boolean goalIsUpdated(
        Account_Plan__c accountPlan,
        Account_Plan__c existingPlan,
        CRUSH_Settings_Obj__c settings
    ) {
        return !String.isBlank(accountPlan.Goal__c) &&
            (existingPlan != null &&
            accountPlan.Goal__c != existingPlan.Goal__c) &&
            settings.Goal_Updated__c;
    }

    private Boolean statusIsUpdated(
        Account_Plan__c accountPlan,
        Account_Plan__c existingPlan,
        CRUSH_Settings_Obj__c settings
    ) {
        return !String.isBlank(accountPlan.Status__c) &&
            (existingPlan != null &&
            accountPlan.Status__c != existingPlan.Status__c) &&
            settings.Status_Updated__c;
    }

    /******************************
     *       INNER CLASSES
     ******************************/

    /**
     * This is a workaround for the lack of reflection in Apex.
     */
    public with sharing class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new AccountPlans(sObjectList);
        }
    }

    private without sharing class OwnershipTransfer {
        private List<Account_Plan__c> accountPlans;
        private Map<Id, SObject> existingRecords;

        private OwnershipTransfer(List<Account_Plan__c> accountPlans, Map<Id, SObject> existingRecords) {
            this.accountPlans = accountPlans;
            this.existingRecords = existingRecords;
        }

        /**
         * Handles post-transfer logic for an Account Plan.
         * Make sure the new and old owners are set up correctly in the team members list.
         */
        private void handleTransfer() {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());

            List<Account_Plan__c> accountPlansThatHaveOwnerChanges = new List<Account_Plan__c>();
            Set<Id> accountPlanIds = new Set<Id>();
            Set<Id> ownerIds = new Set<Id>();
            Set<Id> oldOwnerIds = new Set<Id>();

            for (Account_Plan__c accountPlan : accountPlans) {
                Account_Plan__c existingAccountPlan = (Account_Plan__c) existingRecords.get(accountPlan.Id);
                if (existingAccountPlan.OwnerId != accountPlan.OwnerId) {
                    accountPlansThatHaveOwnerChanges.add(accountPlan);
                    accountPlanIds.add(accountPlan.Id);
                    ownerIds.add(accountPlan.OwnerId);
                    ownerIds.add(existingAccountPlan.OwnerId);
                    oldOwnerIds.add(existingAccountPlan.OwnerId);
                }
            }

            if (accountPlansThatHaveOwnerChanges.size() <= 0) {
                return;
            }

            // lookup and store team members by user/account plan combination
            List<Team_Member__c> teamMemberRecords = TeamMemberSelector.newInstance()
                .selectByAccountPlanIdAndUserIdAsSystem(accountPlanIds, ownerIds);
            Map<String, Team_Member__c> teamMembersByUniqueKey = getTeamMembersByUniqueKey(teamMemberRecords);

            Map<Id, User> oldOwnersById = new Map<Id, User>(
                UsersSelector.newInstance().selectByIdAsSystem(oldOwnerIds)
            );
            // Update team membership for each account plan
            for (Account_Plan__c accountPlan : accountPlansThatHaveOwnerChanges) {
                // update or create new owner team member object
                Team_Member__c ownerTeamMember = teamMembersByUniqueKey.get(
                    TeamMembers.getUniqueKey(accountPlan.Id, accountPlan.OwnerId)
                );

                if (ownerTeamMember != null) {
                    ownerTeamMember.Role__c = TeamMembers.ROLE_OWNER;
                    uow.registerDirty(ownerTeamMember);
                } else {
                    uow.registerNew(
                        new Team_Member__c(
                            Role__c = TeamMembers.ROLE_OWNER,
                            Account_Plan__c = accountPlan.Id,
                            User__c = accountPlan.OwnerId
                        )
                    );
                }

                // update team member record for old owner
                Account_Plan__c oldRecord = (Account_Plan__c) existingRecords.get(accountPlan.Id);
                User oldOwner = oldOwnersById.get(oldRecord.OwnerId);

                Team_Member__c oldOwnerTeamMember = teamMembersByUniqueKey.get(
                    TeamMembers.getUniqueKey(oldRecord.Id, oldRecord.OwnerId)
                );

                // deactivated users can't be team members
                if (oldOwnerTeamMember != null && oldOwner.IsActive == false) {
                    //if old owner is disabled then remove the team member
                    uow.registerDeleted(oldOwnerTeamMember);
                }
            }

            uow.commitWork();
        }

        private Map<String, Team_Member__c> getTeamMembersByUniqueKey(List<Team_Member__c> teamMemberRecords) {
            Map<String, Team_Member__c> teamMembersByUniqueKey = new Map<String, Team_Member__c>();
            for (Team_Member__c teamMember : teamMemberRecords) {
                teamMembersByUniqueKey.put(TeamMembers.getUniqueKey(teamMember), teamMember);
            }
            return teamMembersByUniqueKey;
        }
    }

    private without sharing class SystemContext {
        private void commitWork(fflib_ISObjectUnitOfWork uow) {
            uow.commitWork();
        }
    }
}