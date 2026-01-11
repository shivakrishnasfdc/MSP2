public with sharing class AccountPlanController {
    @AuraEnabled
    public static List<Relationship_Map__c> getRelationshipMapsByAccountPlan(Id accountPlanId) {
        List<Relationship_Map__c> mapsFromAccountPlans = RelationshipMapSelector.newInstance()
            .selectByAccountPlanIdsData(new Set<Id>{ accountPlanId });

        if (mapsFromAccountPlans.size() == 0) {
            id mapId = RelationshipMapMemberController.getMapIdForSObjectId(accountPlanId);
            if (mapId != null) {
                mapsFromAccountPlans = RelationshipMapSelector.newInstance().selectByIds(new Set<Id>{ mapId });
            }
        }
        return mapsFromAccountPlans;
    }

    @AuraEnabled
    public static Boolean checkPlanOverviewUpdateAccessibility() {
        try {
            fflib_SecurityUtils.checkUpdate(
                Account_Plan__c.SObjectType,
                new List<SObjectField>{
                    Account_Plan__c.Plan_Overview_Title__c.getDescribe().getSObjectField(),
                    Account_Plan__c.Plan_Overview__c.getDescribe().getSObjectField()
                }
            );

            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static Boolean checkReadAccessibility(String fieldName) {
        try {
            fflib_SecurityUtils.checkFieldIsReadable(Account_Plan__c.SObjectType, fieldName);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static List<String> getSortOrderValues() {
        List<String> values = new List<String>();
        Schema.DescribeFieldResult fieldResult = pq_CRUSH_Account_Plan_User_Setting__c.Account_Plan_RM_Sort__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p : pList) {
            values.add(p.getLabel() + ',' + p.getValue());
        }
        return values;
    }

    @AuraEnabled
    public static string getRmSortOrder(Id accPlanId) {
        String accountPlanSetting = 'CreatedDate ASC';
        Schema.DescribeFieldResult fieldResult = pq_CRUSH_Account_Plan_User_Setting__c.Account_Plan_RM_Sort__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p : pList) {
            if (p.isDefaultValue()) {
                accountPlanSetting = p.getValue();
            }
        }
        List<pq_CRUSH_Account_Plan_User_Setting__c> accPlanSettings = AccountPlanUserSettingSelector.newInstance()
            .selectByAccPlanID(new Set<Id>{ accPlanId });
        if (accPlanSettings != null && accPlanSettings.size() > 0) {
            accountPlanSetting = accPlanSettings[0].Account_Plan_RM_Sort__c;
        }
        return accountPlanSetting;
    }

    @AuraEnabled
    public static void updateAccountPlanRelationShipSort(String sortOrder, Id accPlanId) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<pq_CRUSH_Account_Plan_User_Setting__c> settings = AccountPlanUserSettingSelector.newInstance()
            .selectByAccPlanID(new Set<Id>{ accPlanId });
        pq_CRUSH_Account_Plan_User_Setting__c accPlanSetting;
        if (sortOrder == null || sortOrder == '') {
            return;
        }
        if (settings.size() >= 1) {
            accPlanSetting = settings.remove(0);
            accPlanSetting.Account_Plan_RM_Sort__c = sortOrder;
            if (settings.size() > 0) {
                uow.registerDeleted(settings);
            }
            uow.registerDirty(accPlanSetting);
        } else {
            // create new one & save
            accPlanSetting = new pq_CRUSH_Account_Plan_User_Setting__c(
                Account_Plan_RM_Sort__c = sortOrder,
                Account_Plan__c = accPlanId,
                User__c = UserInfo.getUserId()
            );
            uow.registerNew(accPlanSetting);
        }
        try {
            uow.commitWork();
        } catch (DMLException e) {
            if (e.getMessage().contains('RESTRICTED_PICKLIST')) {
                e.setMessage('Please use a valid Sort Order');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static UserRecordAccess getUserRecordAccess(Id accountPlanId) {
        List<UserRecordAccess> accessRecords = UserRecordAccessSelector.newInstance()
            .selectByRecordId(new Set<Id>{ accountPlanId });

        return accessRecords.isEmpty() ? null : accessRecords[0];
    }

    @AuraEnabled
    public static List<Account_Plan__c> getAccountPlansForAccountIds(List<Id> accountIds) {
        List<Account_Plan__c> accountPlans = AccountPlanSelector.newInstance()
            .selectByAccountIds(new Set<Id>(accountIds));
        return accountPlans;
    }

    @AuraEnabled
    public static Account_Plan__c getAccountPlanById(Id accountPlanId) {
        List<Account_Plan__c> accountPlans = new AccountPlanSelector().selectById(new Set<Id>{ accountPlanId });

        if (accountPlans.isEmpty()) {
            return null;
        }

        return accountPlans.get(0);
    }

    @AuraEnabled
    public static Account_Plan__c upsertAccountPlan(Id accountPlanId, String planOverviewTitle, String planOverview) {
        fflib_SObjectUnitOfWork unitOfWork = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ Account_Plan__c.SObjectType }
        );

        Account_Plan__c accountPlan = getAccountPlanById(accountPlanId);
        AccountPlans accountPlanRecords = AccountPlans.newInstance(new List<Account_Plan__c>{ accountPlan });

        accountPlanRecords.updateField(Schema.Account_Plan__c.Plan_Overview_Title__c, planOverviewTitle, unitOfWork);
        accountPlanRecords.updateField(Schema.Account_Plan__c.Plan_Overview__c, planOverview, unitOfWork);

        unitOfWork.commitWork();
        return getAccountPlanById(accountPlan.Id);
    }

    public static Map<Id, UserRecordAccess> recordAccessForAccountPlans(List<Account_Plan__c> plans) {
        return UserRecordAccessService.recordAccessForRecords(plans);
    }
}