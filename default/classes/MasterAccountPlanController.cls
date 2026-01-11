public with sharing class MasterAccountPlanController {
    @AuraEnabled
    public static List<Account_Plan__c> getAccountPlansByMasterAccountPlan(Id masterAccountPlanId) {
        return MasterAccountPlanService.getAccountPlansByMasterAccountPlan(masterAccountPlanId);
    }

    @AuraEnabled
    public static List<Relationship_Map__c> getRelationshipMapsByMasterAccountPlan(Id masterAccountPlanId) {
        List<Account_Plan__c> accountPlans = MasterAccountPlanService.getAccountPlansByMasterAccountPlan(
            masterAccountPlanId
        );

        Set<Id> allAccountIds = new Set<Id>();
        Set<Id> allAccountPlanIds = new Set<Id>();
        for (Account_Plan__c ap : accountPlans) {
            allAccountIds.add(ap.Account__c);
            allAccountPlanIds.add(ap.Id);
        }

        Schema.SObjectType objType = SObjectService.getSObjectType('Account');
        Set<Id> mapIds = RelationshipMapService.getMapsForObjectFromObject(objType, allAccountIds);

        if (mapIds.size() == 0) {
            mapIds = RelationshipMapService.getMapsForObjectFromRM(objType, allAccountIds);
        }

        Set<Id> mapIdsFromAccountPlans = new Set<Id>();
        List<Relationship_Map__c> mapsFromAccountPlans = RelationshipMapSelector.newInstance()
            .selectByAccountPlanIds(allAccountPlanIds);
        for (Relationship_Map__c m : mapsFromAccountPlans) {
            mapIdsFromAccountPlans.add(m.Id);
        }

        mapIds.addAll(mapIdsFromAccountPlans);

        List<Relationship_Map__c> maps = RelationshipMapSelector.newInstance().selectByIds(mapIds);

        return maps;
    }

    @AuraEnabled
    public static AccountPlanScoreHistoryWrapper getScoreHistoryByMasterAccountPlan(Id masterAccountPlanId) {
        List<Account_Plan__c> plans = MasterAccountPlanService.getAccountPlansByMasterAccountPlan(masterAccountPlanId);
        Set<Id> accountPlanIds = new Map<Id, Account_Plan__c>(plans).keySet();

        DateTime todaysDate = DateTime.now();
        DateTime startDate = todaysDate.addMonths(-3);

        List<pq_Account_Plan_Score_History__c> scoreHistoryList = AccountPlanScoreHistorySelector.newInstance()
            .selectByAccountPlansAfterDate(accountPlanIds, startDate);

        AccountPlanScoreHistoryWrapper wrapper = AccountPlanScoreHistoryWrapper.convert(scoreHistoryList);

        return wrapper;
    }

    @AuraEnabled
    public static List<String> getSortOrderValues(){
        List<String> values = new List<String>();
        Schema.DescribeFieldResult fieldResult = pqcrush__pq_CRUSH_User_Setting__c.pqcrush__Account_Plan_Sort__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            values.add(p.getLabel() + ',' + p.getValue());
        }
        return values;
    }

    @AuraEnabled
    public static string getRmSortOrder(){

        String userSetting = 'CreatedDate DESC';
        Schema.DescribeFieldResult fieldResult = pqcrush__pq_CRUSH_User_Setting__c.pqcrush__Account_Plan_Sort__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            if (p.isDefaultValue()) {
                userSetting = p.getValue();
            }
        }
        List<pqcrush__pq_Crush_User_Setting__c> userSettings = CrushUserSettingSelector.newInstance().selectForCurrentUser();
        if (userSettings != NULL && !userSettings.isEmpty()) {
            userSetting = userSettings[0].pqcrush__Account_Plan_Sort__c;
        }
        return userSetting;
    }

    @AuraEnabled
    public static void updateAccountPlanSort(String sortOrder) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<pq_Crush_User_Setting__c> settings = CrushUserSettingSelector.newInstance().selectForCurrentUser();
        pq_Crush_User_Setting__c currentSetting;
        if (sortOrder == null || sortOrder == '') {
            return;
        }
        if (settings.size() >= 1) {
            currentSetting = settings.remove(0);
            currentSetting.pqcrush__Account_Plan_Sort__c = sortOrder;
            if (settings.size() > 0) {
                uow.registerDeleted(settings);
            }
            uow.registerDirty(currentSetting);
        } else {
            // create new one & save
            currentSetting = new pq_Crush_User_Setting__c(
                pqcrush__Account_Plan_Sort__c = sortOrder,
                User__c = UserInfo.getUserId()
            );
            uow.registerNew(currentSetting);
        }
        try {
            uow.commitWork();
            } catch(DMLException e){
            if(e.getMessage().contains('RESTRICTED_PICKLIST')) {
                e.setMessage('Please use a valid Sort Order');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            } 
        }
    }

    @AuraEnabled
    public static boolean getClosedPlanFilter(Id masterAccountPlanId){
        Boolean showClosedPlans = true;
        List<pqcrush__Master_Account_Plan_User_Setting__c> userSettings = MasterAccountPlanUserSettingSelector.newInstance().selectForCurrentUserAndMasterAccountPlan(masterAccountPlanId);
        if (userSettings != NULL && !userSettings.isEmpty()) {
            if (userSettings[0].pqcrush__Show_Closed_Account_Plans__c == false) {
                showClosedPlans = false;
            }    
        }
        return showClosedPlans;
    }
}