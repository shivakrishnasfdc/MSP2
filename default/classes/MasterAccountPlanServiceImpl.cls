public with sharing class MasterAccountPlanServiceImpl {
    public List<Account_Plan__c> getAccountPlansByMasterAccountPlan(Id masterAccountPlanId) {
        List<pq_Master_Account_Plan__c> masterAccountPlans = MasterAccountPlanSelector.newInstance()
            .selectById(new Set<Id>{ masterAccountPlanId });

        if (masterAccountPlans == null || masterAccountPlans.size() != 1) {
            return new List<Account_Plan__c>();
        }

        pq_Master_Account_Plan__c masterAccountPlan = masterAccountPlans[0];

        List<Master_Account_Plan_Associations__c> masterPlanAssocs = MasterAccountPlanAssociationSelector.newInstance()
            .selectByMasterAccountPlanId(new Set<Id>{ masterAccountPlan.Id });

        Set<Id> accountPlanIds = new Set<Id>();

        for (Master_Account_Plan_Associations__c assoc : masterPlanAssocs) {
            accountPlanIds.add(assoc.Account_Plan__c);
        }

        Set<Id> accountIds = masterAccountPlan.Account__c != null
            ? AccountService.getAccountAndDescendents(masterAccountPlan.Account__c).keySet()
            : new Set<Id>{ masterAccountPlan.Account__c };
        List<Account_Plan__c> plans = AccountPlanSelector.newInstance()
            .selectByAccountIdWithAccountAndOwner(accountIds, masterAccountPlanId);
        List<Account_Plan__c> morePlans = AccountPlanSelector.newInstance()
            .selectByIdWithAccountAndOwnerAndMasterAccountPlan(accountPlanIds, masterAccountPlanId);

        plans.addAll(morePlans);

        return plans;
    }

    public Set<Id> getRelatedAccountIdsByMasterAccountPlans(Set<Id> masterAccountPlanIds) {
        List<Master_Account_Plan_Associations__c> masterPlanAssocs = MasterAccountPlanAssociationSelector.newInstance()
            .selectByMasterAccountPlanId(masterAccountPlanIds);

        Set<Id> accountPlanIds = new Set<Id>();
        List<Id> masterAccountPlanIdsList = new List<Id>(masterAccountPlanIds);

        for (Master_Account_Plan_Associations__c assoc : masterPlanAssocs) {
            accountPlanIds.add(assoc.Account_Plan__c);
        }

        List<Account_Plan__c> plans = AccountPlanSelector.newInstance().selectByIdWithAccountAndOwnerAndMasterAccountPlan(accountPlanIds, masterAccountPlanIdsList[0]);

        Set<Id> accountIds = new Set<Id>();
        for (Account_Plan__c plan : plans) {
            accountIds.add(plan.Account__c);
        }

        return accountIds;
    }

    public boolean updateClosedPlanFilter(Boolean showClosedPlans, Id masterAccountPlanId) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        List<pq_Master_Account_Plan__c> masterAccountPlans = MasterAccountPlanSelector.newInstance().selectById(new Set<Id>{ masterAccountPlanId });

        List<Master_Account_Plan_User_Setting__c> settings = MasterAccountPlanUserSettingSelector.newInstance().selectForCurrentUserAndMasterAccountPlan(masterAccountPlanId);
        Master_Account_Plan_User_Setting__c currentSetting;

        if (settings.size() >= 1) {
            currentSetting = settings.remove(0);
            currentSetting.pqcrush__Show_Closed_Account_Plans__c = showClosedPlans;
            if (settings.size() > 0) {
                uow.registerDeleted(settings);
            }
            uow.registerDirty(currentSetting);
        } else {
            // create new one & save
            currentSetting = new Master_Account_Plan_User_Setting__c(
                pqcrush__Show_Closed_Account_Plans__c = showClosedPlans,
                pqcrush__User__c = UserInfo.getUserId(),
                pqcrush__Master_Account_Plan__c = masterAccountPlans[0].Id
            );
            uow.registerNew(currentSetting);
        }

        uow.commitWork();

        return currentSetting.pqcrush__Show_Closed_Account_Plans__c;
    }
}