public with sharing class AccountPlanUserSettingServiceImpl {
    public pq_CRUSH_Account_Plan_User_Setting__c createNewSettings(Id accountPlanId) {
        pq_CRUSH_Account_Plan_User_Setting__c newSetting = new pq_CRUSH_Account_Plan_User_Setting__c(
            Account_Plan__c = accountPlanId,
            Objective_Overview_Chart_Type__c = 'Bar',
            User__c = UserInfo.getUserId()
        );

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        uow.registerNew(newSetting);
        new SystemContext().commitWork(uow);

        return newSetting;
    }

    private without sharing class SystemContext {
        private void commitWork(fflib_ISObjectUnitOfWork uow) {
            uow.commitWork();
        }
    }
}