public with sharing class WSUserSettingServiceImpl {
    /******************************
     *      PUBLIC METHODS
     ******************************/

    public WS_User_Setting__c getUserSetting(Id whitespaceId) {
        List<WS_User_Setting__c> settings = WSUserSettingSelector.newInstance().selectByWhitespaceId(whitespaceId);

        if (settings != null && settings.size() > 0) {
            return settings[0];
        }

        WS_User_Setting__c setting = (WS_User_Setting__c) WS_User_Setting__c.sObjectType.newSObject(null, true);
        setting.White_Space__c = whitespaceId;
        setting.User__c = UserInfo.getUserId();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerNew(setting);
        uow.commitWork();

        // refetching to pull in changes a customer may have made via flow/trigger/etc on the user settings
        settings = WSUserSettingSelector.newInstance().selectByWhitespaceId(whitespaceId);
        if (settings != null && settings.size() > 0) {
            return settings[0];
        }

        return setting;
    }

    public void updateUserSetting(List<WS_User_Setting__c> settings) {
        // There should only be 1 setting
        if (settings == null || settings.size() != 1) {
            return;
        }

        WS_User_Setting__c setting = settings[0];

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        if (setting.Id != null) {
            uow.registerDirty(setting);
        } else {
            uow.registerNew(setting);
        }

        uow.commitWork();
    }

    public void updateZoomIndex(Id settingId, Integer zoomIndex) {
        List<WS_User_Setting__c> settings = WSUserSettingSelector.newInstance().selectById(new Set<Id>{ settingId });
        // There should only be 1 setting
        if (settings == null || settings.size() != 1) {
            return;
        }

        WS_User_Setting__c setting = settings[0];
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        setting.Zoom_Index__c = zoomIndex;
        uow.registerDirty(setting);
        uow.commitWork();
    }
}