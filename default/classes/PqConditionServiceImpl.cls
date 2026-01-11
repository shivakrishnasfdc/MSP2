public with sharing class PqConditionServiceImpl {
    public List<pq_Condition__c> getPqConditions(Id settingId) {
        return PqConditionSelector.newInstance().selectByParentObjectId(new Set<Id>{ settingId });
    }

    public List<pq_Condition__c> insertPqCondition(List<pq_Condition__c> conditions) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerNew(conditions);
        SystemContext systemContext = new SystemContext();
        systemContext.commitWork(uow);
        return conditions;
    }

    public void deletePqCondition(List<pq_Condition__c> conditions) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(conditions);
        SystemContext systemContext = new SystemContext();
        systemContext.commitWork(uow);
    }

    public List<pq_Condition__c> updatePqCondition(List<pq_Condition__c> conditions) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerDirty(conditions);
        SystemContext systemContext = new SystemContext();
        systemContext.commitWork(uow);
        return conditions;
    }

    private without sharing class SystemContext {
        private void commitWork(fflib_ISObjectUnitOfWork uow) {
            uow.commitWork();
        }
    }
}