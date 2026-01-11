public with sharing class SettingService {
    /**
     * Retrieves the org level settings object for the Strategy app
     * @return The org level Crush settings object or null if it doesn't exist.
     *
     * IMPORTANT:
     * This should only be used by the post install script.
     * Everything else should use getOrgSettingsAndCreateIfNeeded()
     */
    public static Crush_Settings_Obj__c getOrgSettings() {
        return service().getOrgSettings();
    }

    /**
     * Retrieves the org level settings object for the Strategy app and creates it if it does not exist
     * @return The org level Crush settings object.
     */
    public static Crush_Settings_Obj__c getOrgSettingsAndCreateIfNeeded() {
        return service().getOrgSettingsAndCreateIfNeeded();
    }

    /**
     * Retrieves the calling user level settings object for the Crush app and creates it if it does not exist
     * @return The user level Crush settings object.
     */
    public static Crush_Settings_Obj__c getCurrentUserSettings() {
        return service().getCurrentUserSettings();
    }

    /**
     * Retrieves a user level settings object for the Crush app and creates it if it does not exist
     * @return The user level Crush settings object.
     */
    public static CRUSH_Settings_Obj__c getUserSettings(Id userId) {
        return service().getUserSettings(userId);
    }

    public static List<NameValuePair> getPickListValues(String fieldName) {
        return service().getPickListValues(fieldName);
    }

    public static void updateCrossSellCreateObjectSettings(Boolean canCreateObjectsInCrossSell) {
        service().updateCrossSellCreateObjectSettings(canCreateObjectsInCrossSell);
    }

    public static void updateUseDefaultAPScoringSettings(Boolean useDefaultAPScoring) {
        service().updateUseDefaultAPScoringSettings(useDefaultAPScoring);
    }

    public static void updateUsePercentageAPScoringSettings(Boolean usePercentageAPScoring) {
        service().updateUsePercentageAPScoringSettings(usePercentageAPScoring);
    }

    public static void updateAllowAddTaskFromObjectiveComponent(Boolean allowAddTask) {
        service().updateAllowAddTaskFromObjectiveComponent(allowAddTask);
    }

    public static void updateDisableObjectiveComponentSortButton(Boolean disableSortButton) {
        service().updateDisableObjectiveComponentSortButton(disableSortButton);
    }

    public static void updateAllowTasksBasedObjStageFromObjectiveComponent(Boolean allowTasksBasedObjStage) {
        service().updateAllowTasksBasedObjStageFromObjectiveComponent(allowTasksBasedObjStage);
    }
    public static void updateUseSystemTaskModalFromObjectiveComponent(Boolean useSystemModal) {
        service().updateUseSystemTaskModalFromObjectiveComponent(useSystemModal);
    }

    public static void updateWSFilterStringSetting(String filterString) {
        service().updateWSFilterStringSetting(filterString);
    }

    public static List<String> getObjectNameListFromFilterString(String filterString) {
        return service().getObjectNameListFromFilterString(filterString);
    }

    public static String getFilterStringFromObjectNameList(List<String> objectNameList) {
        return service().getFilterStringFromObjectNameList(objectNameList);
    }

    /**
     * Upserts the settings object
     */

    public static CRUSH_Settings_Obj__c upsertSettings(CRUSH_Settings_Obj__c settings) {
        return service().upsertSettings(settings);
    }

    private static SettingServiceImpl service() {
        return (SettingServiceImpl) Application.Service.newInstance(SettingServiceImpl.class);
    }
}