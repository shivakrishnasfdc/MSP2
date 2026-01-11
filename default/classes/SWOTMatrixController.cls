public with sharing class SWOTMatrixController {
    @AuraEnabled
    public static SWOTMatrix getSWOTMatrix(Id accountPlanId) {
        return new SWOTMatrix(new SWOTAnalysisSelector().selectByAccountPlanId(accountPlanId));
    }

    @AuraEnabled
    public static SWOT_Analysis__c createItem(SWOT_Analysis__c item) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerNew(item);
        uow.commitWork();

        return new SWOTAnalysisSelector().selectById(new Set<Id>{ item.Id }).get(0);
    }

    @AuraEnabled
    public static SWOT_Analysis__c updateItem(SWOT_Analysis__c item) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(item);
        uow.commitWork();

        return new SWOTAnalysisSelector().selectById(new Set<Id>{ item.Id }).get(0);
    }

    @AuraEnabled
    public static void deleteItem(SWOT_Analysis__c item) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(item);
        uow.commitWork();
    }
}