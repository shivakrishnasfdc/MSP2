public with sharing class PlanOverviewController {
    @AuraEnabled
    public static List<PlanOverviewWrapper> getPlanOverviewByAccountPlan(
        Id accountPlanId,
        String dataKey,
        Boolean isGlobal
    ) {
        List<pq_CRUSH_Plan_Overview__c> overviews = PlanOverviewSelector.newInstance()
            .selectByAccountPlan(new Set<Id>{ accountPlanId }, dataKey, isGlobal);

        Boolean updateable = Schema.sObjectType.pq_CRUSH_Plan_Overview__c.isUpdateable();
        Boolean deleteable = Schema.sObjectType.pq_CRUSH_Plan_Overview__c.isDeletable();

        // TYPICALLY We get the access record info on demand because user record access is an expensive call
        // but this should ok cause it should be a small list
        Map<Id, UserRecordAccess> mapAccessRecord = UserRecordAccessService.recordAccessForRecords(overviews);

        List<PlanOverviewWrapper> wrapperList = new List<PlanOverviewWrapper>();
        for (pq_CRUSH_Plan_Overview__c overview : overviews) {
            UserRecordAccess ura = mapAccessRecord.get(overview.Id);
            Boolean canUpdate = updateable && (ura.HasAllAccess || ura.HasEditAccess);
            Boolean canDelete = deleteable && (ura.HasAllAccess || ura.HasDeleteAccess);
            wrapperList.add(new PlanOverviewWrapper(overview, canUpdate, canDelete));
        }

        return wrapperList;
    }

    @AuraEnabled
    public static void createPlanOverviewForAccountPlan(
        Id accountPlanId,
        String color,
        String title,
        String description,
        String dataKey
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        pq_CRUSH_Plan_Overview__c planOverview = new pq_CRUSH_Plan_Overview__c(
            name = title != null && title.length() > 80 ? title.substring(0, 80) : title,
            Account_Plan__c = accountPlanId,
            Title__c = title,
            Description__c = description,
            Background_Color__c = color,
            Data_Key__c = dataKey
        );

        uow.registerNew(planOverview);
        uow.commitWork();
    }

    @AuraEnabled
    public static void updatePlanOverview(Id planOverviewId, String color, String title, String description) {
        system.debug('planOverviewId>>'+planOverviewId);
        system.debug('color>>'+color);
        system.debug('title>>'+title);
        system.debug('description>>'+description);
        List<pq_CRUSH_Plan_Overview__c> query = PlanOverviewSelector.newInstance()
            .selectById(new Set<Id>{ planOverviewId });

        if (query.isEmpty()) {
            return;
        }

        pq_CRUSH_Plan_Overview__c queryOverview = query[0];

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        queryOverview.name = title != null && title.length() > 80 ? title.substring(0, 80) : title;
        queryOverview.Title__c = title;
        queryOverview.Background_Color__c = color;
        queryOverview.Description__c = description;
        uow.registerDirty(queryOverview);
        uow.commitWork();
        
    }

    @AuraEnabled
    public static Map<String, Boolean> getPermissions() {
        Map<String, Boolean> result = new Map<String, Boolean>();
        result.put('createable', Schema.sObjectType.pq_CRUSH_Plan_Overview__c.isCreateable());
        result.put('updateable', Schema.sObjectType.pq_CRUSH_Plan_Overview__c.isUpdateable());
        result.put('deleteable', Schema.sObjectType.pq_CRUSH_Plan_Overview__c.isDeletable());

        return result;
    }

    @AuraEnabled
    public static void deletePlanOverview(Id planOverviewId) {
        List<pq_CRUSH_Plan_Overview__c> query = PlanOverviewSelector.newInstance()
            .selectById(new Set<Id>{ planOverviewId });

        if (query.isEmpty()) {
            return;
        }

        pq_CRUSH_Plan_Overview__c queryOverview = query[0];

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(queryOverview);
        uow.commitWork();
    }
}