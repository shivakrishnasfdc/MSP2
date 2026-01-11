public with sharing class AccountPlanServiceImpl {
    private static final String PERMISSION_SET_STRATEGY_ADMIN = 'CRUSH_Administrator';

    /******************************
     *      PUBLIC METHODS
     ******************************/

    public void maybeOpenAccountPlans(Map<Id, List<SObject>> recordsByAccountPlanId) {
        if (!Schema.sObjectType.Account_Plan__c.isAccessible()) {
            return;
        }

        Set<Id> accountPlanIds = recordsByAccountPlanId.keySet();

        if (accountPlanIds.isEmpty()) {
            return;
        }

        List<Account_Plan__c> accountPlans = AccountPlanSelector.newInstance().selectClosedPlansById(accountPlanIds);

        if (accountPlans == null || accountPlans.size() == 0) {
            return;
        }

        Map<Id, UserRecordAccess> accessRecordMap = UserRecordAccessService.recordAccessForRecords(accountPlans);
        Set<Id> accountPlanIdsToUpdate = new Set<Id>();

        for (Account_Plan__c accountPlan : accountPlans) {
            UserRecordAccess recordAccess = accessRecordMap.get(accountPlan.Id);
            Boolean hasAppropriateAccess = recordAccess.HasAllAccess || recordAccess.HasEditAccess;
            if (hasAppropriateAccess) {
                accountPlanIdsToUpdate.add(accountPlan.Id);
            } else {
                for (SObject record : recordsByAccountPlanId.get(accountPlan.Id)) {
                    record.addError(System.Label.error_closed_account_plan_related_items);
                }
            }
        }
        openAccountPlans(accountPlanIdsToUpdate);
    }

    public List<Account_Plan__c> openAccountPlans(Set<Id> accountPlanIds) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        List<Account_Plan__c> accountPlans = AccountPlanSelector.newInstance().selectByIdAsSystem(accountPlanIds);

        for (Account_Plan__c accountPlan : accountPlans) {
            if (accountPlan.Status__c == 'Closed') {
                accountPlan.Status__c = 'Open';
                uow.registerDirty(accountPlan);
            }
        }

        new SystemContext().commitWork(uow);

        return AccountPlanSelector.newInstance().selectByIdAsSystem(accountPlanIds);
    }

    public void transferAccountPlans(Set<Id> accountPlanIds) {
        AccountPlanServiceImpl.transferAccountPlansFuture(accountPlanIds);
    }

    public Map<Id, Set<Id>> getTaskWhatIdsByAccountPlanIdForMap(Map<Id, Account_plan__c> accountPlanMaps) {
        CRUSH_Settings_Obj__c orgSettings = SettingService.getOrgSettingsAndCreateIfNeeded();

        String savedObjects = orgSettings.Task_Objects_Related_To_Account_Plan__c;

        if (String.isBlank(savedObjects)) {
            return new Map<Id, Set<Id>>();
        }

        List<String> saveObjectsSplit = savedObjects.split(',');

        if (saveObjectsSplit.size() <= 0) {
            return new Map<Id, Set<Id>>();
        }

        List<Schema.sObjectType> relatedObjectTypes = new List<Schema.sObjectType>();
        for (String sobjectApiName : saveObjectsSplit) {
            if (String.isBlank(sobjectApiName)) {
                continue;
            }
            relatedObjectTypes.add(Application.getGlobalDescribe().get(sobjectApiName));
        }
        Set<Id> accountPlanIds = accountPlanMaps.keySet();
        Map<Id, Set<Id>> relatedObjectMap = SObjectService.getMapOfObjectIdsRelatedToIdSet(
            accountPlanIds,
            Account_plan__c.sObjectType,
            relatedObjectTypes
        );
        if (saveObjectsSplit.contains('Account')) {
            for (Account_plan__c plan : accountPlanMaps.values()) {
                if (!relatedObjectMap.containsKey(plan.Id)) {
                    relatedObjectMap.put(plan.Id, new Set<Id>());
                }
                relatedObjectMap.get(plan.Id).add(plan.Account__c);
            }
        }
        return relatedObjectMap;
    }

    public Set<Id> getIdsForRelatedObjectsToAccountPlan(Id accountPlanId, Id accountId) {
        CRUSH_Settings_Obj__c orgSettings = SettingService.getOrgSettingsAndCreateIfNeeded();

        String savedObjects = orgSettings.Task_Objects_Related_To_Account_Plan__c;

        if (String.isBlank(savedObjects)) {
            return new Set<Id>();
        }

        List<String> saveObjectsSplit = savedObjects.split(',');

        if (saveObjectsSplit.size() <= 0) {
            return new Set<Id>();
        }

        List<Schema.sObjectType> relatedObjectTypes = new List<Schema.sObjectType>();
        for (String sobjectApiName : saveObjectsSplit) {
            if (String.isBlank(sobjectApiName)) {
                continue;
            }
            relatedObjectTypes.add(Application.getGlobalDescribe().get(sobjectApiName));
        }

        Set<Id> relatedObjectIds = SObjectService.getIdsForRelatedObjects(accountPlanId, relatedObjectTypes);

        if (saveObjectsSplit.contains('Account')) {
            relatedObjectIds.add(accountId);
        }

        return relatedObjectIds;
    }

    /******************************
     *      PRIVATE METHODS
     ******************************/

    /**
     * Transfers ownership of Account Plan records according to the following rules:
     *
     *  1. If the Account Plan has any Team Members, the Team Member that was added
     *     to the Account Plan the EARLIEST becomes the owner.
     *
     *  2. If the Account Plan does not have any Team Members and a User exists in
     *     the system with the Strategy Admin permission set, the Strategy Admin user
     *     becomse the new owner.
     *
     *  3. If neither of the above conditions are true, ownership is NOT transferred
     *     to another user.
     * @param accountPlanIds    Record IDs of the Account Plans to transfer.
     */
    @future
    private static void transferAccountPlansFuture(Set<Id> accountPlanIds) {
        Crush_Settings_Obj__c orgSettings = SettingService.getOrgSettingsAndCreateIfNeeded();
        List<Account_Plan__c> accountPlansToTransfer = new AccountPlanSelector()
            .selectByIdWithTeamMembersAdmin(accountPlanIds);
        List<Account_Plan__c> transferredAccountPlans = new List<Account_Plan__c>();
        List<User> strategyAdmins = new UsersSelector().selectByPermissionSetNameAdmin(PERMISSION_SET_STRATEGY_ADMIN);

        for (Account_Plan__c accountPlan : accountPlansToTransfer) {
            Id newOwnerId = getNewOwnerId(accountPlan, orgSettings, strategyAdmins);
            if (newOwnerId != null) {
                transferredAccountPlans.add(new Account_Plan__c(Id = accountPlan.Id, OwnerId = newOwnerId));
            }
        }

        Database.SaveResult[] saveResults = Database.update(transferredAccountPlans, false);

        Integer successCount = 0;
        Integer failureCount = 0;

        for (Database.SaveResult result : saveResults) {
            if (result.isSuccess()) {
                successCount += 1;
            } else {
                failureCount += 1;

                for (Database.Error error : result.getErrors()) {
                    System.debug(error.getStatusCode() + ': ' + error.getMessage()); //NOPMD
                }
            }
        }
        System.debug('Number of failed account plan transfers: ' + failureCount); //NOPMD
    }

    private static Id getNewOwnerId(
        Account_Plan__c accountPlan,
        Crush_Settings_Obj__c orgSettings,
        List<User> strategyAdmins
    ) {
        Id newOwnerId = null;

        if (orgSettings.Account_Plan_Transfer__c == TransferSetting.TEAM_MEMBER.name()) {
            if (accountPlan.Team_Members__r.size() > 0) {
                newOwnerId = accountPlan.Team_Members__r[0].User__c;
            } else if (strategyAdmins.size() > 0) {
                newOwnerId = strategyAdmins[0].Id;
            }
        } else if (orgSettings.Account_Plan_Transfer__c == TransferSetting.USER.name()) {
            if (orgSettings.Account_Plan_Transfer_User__c != null) {
                newOwnerId = orgSettings.Account_Plan_Transfer_User__c;
            } else if (strategyAdmins.size() > 0) {
                newOwnerId = strategyAdmins[0].Id;
            }
        } else if (orgSettings.Account_Plan_Transfer__c == TransferSetting.NONE.name()) {
            newOwnerId = null; //no new owner
        }

        return newOwnerId;
    }

    private without sharing class SystemContext {
        private void commitWork(fflib_ISObjectUnitOfWork uow) {
            uow.commitWork();
        }
    }
}