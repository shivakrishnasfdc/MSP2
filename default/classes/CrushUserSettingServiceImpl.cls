public with sharing class CrushUserSettingServiceImpl {
    public pq_Crush_User_Setting__c getSetting() {
        List<pq_Crush_User_Setting__c> setting = CrushUserSettingSelector.newInstance().selectForCurrentUser();
        if (setting != null && setting.size() >= 1) {
            return setting[0];
        }
        return new pq_Crush_User_Setting__c(Account_Plan_Task_Filter__c = '');
    }

    public void updateTaskFilter(String taskFilterJSON) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<pq_Crush_User_Setting__c> settings = CrushUserSettingSelector.newInstance().selectForCurrentUser();
        pq_Crush_User_Setting__c currentSetting;
        if (settings.size() >= 1) {
            currentSetting = settings.remove(0);
            currentSetting.Account_Plan_Task_Filter__c = taskFilterJSON;
            if (settings.size() > 0) {
                uow.registerDeleted(settings);
            }
            uow.registerDirty(currentSetting);
        } else {
            // create new one & save
            currentSetting = new pq_Crush_User_Setting__c(
                Account_Plan_Task_Filter__c = taskFilterJSON,
                User__c = UserInfo.getUserId()
            );
            uow.registerNew(currentSetting);
        }

        uow.commitWork();
    }

    public void updateAccountPlanSort(String sortOrder) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<pq_Crush_User_Setting__c> settings = CrushUserSettingSelector.newInstance().selectForCurrentUser();
        pq_Crush_User_Setting__c currentSetting;
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

        uow.commitWork();
    }

    public void updateObjectiveTaskSortAscending(Boolean taskSortOrder) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<pq_Crush_User_Setting__c> settings = CrushUserSettingSelector.newInstance().selectForCurrentUser();
        pq_Crush_User_Setting__c currentSetting;
        if (settings.size() >= 1) {
            currentSetting = settings.remove(0);
            currentSetting.pqcrush__Objective_Task_Sort_Ascending__c = !taskSortOrder;
            if (settings.size() > 0) {
                uow.registerDeleted(settings);
            }
            uow.registerDirty(currentSetting);
        } else {
            // create new one & save
            currentSetting = new pq_Crush_User_Setting__c(
                pqcrush__Objective_Task_Sort_Ascending__c = taskSortOrder,
                User__c = UserInfo.getUserId()
            );
            uow.registerNew(currentSetting);
        }

        uow.commitWork();
    }

    public void updateObjectiveTaskSortField(String sortField) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<pq_Crush_User_Setting__c> settings = CrushUserSettingSelector.newInstance().selectForCurrentUser();
        pq_Crush_User_Setting__c currentSetting;
        if (settings.size() >= 1) {
            currentSetting = settings.remove(0);
            currentSetting.pqcrush__Objective_Task_Sort_Field__c = sortField;
            if (settings.size() > 0) {
                uow.registerDeleted(settings);
            }
            uow.registerDirty(currentSetting);
        } else {
            // create new one & save
            currentSetting = new pq_Crush_User_Setting__c(
                pqcrush__Objective_Task_Sort_Field__c = sortField,
                User__c = UserInfo.getUserId()
            );
            uow.registerNew(currentSetting);
        }

        uow.commitWork();
    }
}