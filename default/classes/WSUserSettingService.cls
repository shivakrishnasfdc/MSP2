public with sharing class WSUserSettingService {
    public static WS_User_Setting__c getUserSetting(Id whitespaceId) {
        return service().getUserSetting(whitespaceId);
    }

    public static void updateUserSetting(List<WS_User_Setting__c> settings) {
        service().updateUserSetting(settings);
    }

    public static void updateZoomIndex(Id settingId, Integer zoomIndex) {
        service().updateZoomIndex(settingId, zoomIndex);
    }

    private static WSUserSettingServiceImpl service() {
        return (WSUserSettingServiceImpl) Application.Service.newInstance(WSUserSettingServiceImpl.class);
    }
}