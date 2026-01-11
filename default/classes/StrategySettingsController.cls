@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class StrategySettingsController {
    public static final String KEY_DATES_REMINDER_JOB_NAME = 'Schedule Key Date Reminder Emails';
    public static final String ACCOUNT_PLAN_SCORE_HISTORY_JOB_NAME = 'Schedule Account Plan Score History';
    public static final Set<String> RELATEDEXCLUSIONS = new Set<String>{
        'Account',
        'OpportunityChangeEvent',
        'AccountChangeEvent',
        'AccountContactRoleChangeEvent',
        'AccountHistory',
        'AccountShare',
        'ActivityHistory',
        'AssetChangeEvent',
        'AttachedContentDocument',
        'AuthorizationFormConsentChangeEvent',
        'CaseChangeEvent',
        'CombinedAttachment',
        'CommSubscriptionConsentChangeEvent',
        'ContactChangeEvent',
        'ContactPointAddressChangeEvent',
        'ContactPointEmailChangeEvent',
        'ContactPointPhoneChangeEvent',
        'ContractChangeEvent',
        'EmailMessageChangeEvent',
        'EntitlementChangeEvent',
        'EventChangeEvent',
        'EventRelationChangeEvent',
        'FinanceBalanceSnapshotChangeEvent',
        'FinanceTransactionChangeEvent',
        'FlowExecutionErrorEvent',
        'LeadChangeEvent',
        'MaintenancePlanChangeEvent',
        'NoteAndAttachment',
        'OpenActivity',
        'OrderChangeEvent',
        'OutgoingEmail',
        'ProcessInstanceHistory',
        'ProductRequestChangeEvent',
        'ProductRequestLineItemChangeEvent',
        'RecordAction',
        'ResourcePreference',
        'ReturnOrderChangeEvent',
        'ServiceAppointmentChangeEvent',
        'ServiceContractChangeEvent',
        'ServiceResourceChangeEvent',
        'TaskChangeEvent',
        'UserChangeEvent',
        'WorkOrderChangeEvent',
        'pqcrush__Account_Plan__c',
        'ActivityRecurrence2',
        'ActivityRecurrence2Exception',
        'ContentDocumentLink',
        'ContentVersion',
        'DuplicateRecordItem',
        'FlowRecordRelation',
        'ProcessException',
        'ProcessExceptionEvent',
        'ProcessInstance',
        'RecordAction',
        'RecordActionHistory',
        'pqcrush__Account_Plan__History',
        'pqcrush__Account_Plan__Share',
        'pqcrush__Contact_Relationship__c',
        'pqcrush__Map_Member_Placeholder_Relationship__c',
        'pqcrush__Opportunity_List_User_Filter__c',
        'pqcrush__RM_Anchor__c',
        'pqcrush__RM_Chart_Setting__c',
        'pqcrush__RM_Node_Coordinate__c',
        'pqcrush__RM_Svg_Account_Plan_Association__c',
        'pqcrush__RM_Svg_Node_Association__c',
        'pqcrush__Relationship_Type_Account_Plan_Assoc__c'
    };

    @AuraEnabled
    public static CrushSettings getOrgSettings() {
        return new CrushSettings(SettingService.getOrgSettingsAndCreateIfNeeded());
    }

    @AuraEnabled
    public static CrushSettings getCurrentUserSettings() {
        return new CrushSettings(SettingService.getCurrentUserSettings());
    }

    @AuraEnabled
    public static void updateCrossSellCreateObjectSettings(Boolean canCreateObjectsInCrossSell) {
        SettingService.updateCrossSellCreateObjectSettings(canCreateObjectsInCrossSell);
    }

    @AuraEnabled
    public static void updateUseDefaultAPScoringSettings(Boolean useDefaultAPScoring) {
        SettingService.updateUseDefaultAPScoringSettings(useDefaultAPScoring);
    }

    @AuraEnabled
    public static void updateUsePercentageAPScoringSettings(Boolean usePercentageAPScoring) {
        SettingService.updateUsePercentageAPScoringSettings(usePercentageAPScoring);
    }

    @AuraEnabled
    public static void updateAllowAddTaskFromObjectiveComponent(Boolean allowAddTask) {
        SettingService.updateAllowAddTaskFromObjectiveComponent(allowAddTask);
    }

    @AuraEnabled
    public static void updateAllowTasksBasedObjStageFromObjectiveComponent(Boolean allowTasksBasedObjStage) {
        SettingService.updateAllowTasksBasedObjStageFromObjectiveComponent(allowTasksBasedObjStage);
    }

    @AuraEnabled
    public static void updateUseSystemTaskModalFromObjectiveComponent(Boolean useSystemModal) {
        SettingService.updateUseSystemTaskModalFromObjectiveComponent(useSystemModal);
    }

    @AuraEnabled
    public static void updateDisableObjectiveComponentSortButton(Boolean disableSortButton) {
        SettingService.updateDisableObjectiveComponentSortButton(disableSortButton);
    }

    @AuraEnabled
    public static void updateWSFilterStringSetting(String filterString) {
        List<String> filterStringList = SettingService.getObjectNameListFromFilterString(filterString);
        Map<String, Schema.SObjectType> gd = Application.getGlobalDescribe();
        for (String s : filterStringList) {
            if (!gd.containsKey(s)) {
                String errorString = String.format(System.label.Invalid_Object_Name, new List<String>{ s });
                throw Application.createAuraHandledException(errorString);
            }
        }
        String filterStringToSave = SettingService.getFilterStringFromObjectNameList(filterStringList);
        SettingService.updateWSFilterStringSetting(filterStringToSave);
    }

    @AuraEnabled
    public static CrushSettings upsertSettings(String settings) {
        CRUSH_Settings_Obj__c settingsObject = ((CrushSettings) JSON.deserialize(settings, CrushSettings.class))
            .toSObject();
        CRUSH_Settings_Obj__c updatedSettings = SettingService.upsertSettings(settingsObject);
        return new CrushSettings(updatedSettings);
    }

    @AuraEnabled
    public static Boolean isKeyDateReminderJobStarted() {
        if (Schema.sObjectType.CronTrigger.isAccessible() == false) {
            throw new AuraHandledException('You do not have permission to schedule jobs');
        }

        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
            FROM CronTrigger
            WHERE CronJobDetail.Name = :KEY_DATES_REMINDER_JOB_NAME
        ];

        return jobs.size() > 0;
    }

    @AuraEnabled
    public static void scheduleCrushJobs() {
        if (Schema.sObjectType.CronTrigger.isAccessible() == false) {
            throw new AuraHandledException('You do not have permission to schedule jobs');
        }

        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
            FROM CronTrigger
            WHERE CronJobDetail.Name = :KEY_DATES_REMINDER_JOB_NAME
        ];
        Set<String> jobNames = new Set<String>();

        for (CronTrigger job : jobs) {
            jobNames.add(job.CronJobDetail.Name);
        }

        scheduleKeyDateReminderEmailJob(jobNames);
    }

    @AuraEnabled
    public static Boolean isAccountPlanScoreHistoryJobStarted() {
        if (Schema.sObjectType.CronTrigger.isAccessible() == false) {
            throw new AuraHandledException('You do not have permission to schedule jobs');
        }

        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
            FROM CronTrigger
            WHERE CronJobDetail.Name = :ACCOUNT_PLAN_SCORE_HISTORY_JOB_NAME
        ];

        return jobs.size() > 0;
    }

    @AuraEnabled
    public static void scheduleAccountPlanScoreHistoryJobs() {
        if (Schema.sObjectType.CronTrigger.isAccessible() == false) {
            throw new AuraHandledException('You do not have permission to schedule jobs');
        }

        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
            FROM CronTrigger
            WHERE CronJobDetail.Name = :ACCOUNT_PLAN_SCORE_HISTORY_JOB_NAME
        ];

        if (jobs.size() > 0) {
            return;
        }

        // Runs 5am every sunday
        System.schedule(ACCOUNT_PLAN_SCORE_HISTORY_JOB_NAME, '0 0 5 ? * SUN', new ScheduleForAccountPlanScoreBatch());
    }

    @AuraEnabled
    public static void updateAccountPlansSharing() {
        try {
            AccountPlanShareService.updateAllAccountTeamShares();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Boolean> getObjectsRelatedToAccount() {
        CRUSH_Settings_Obj__c orgSettings = SettingService.getOrgSettingsAndCreateIfNeeded();

        String exclusionString = orgSettings.Task_Objects_Related_Exclusions__c == null
            ? ''
            : orgSettings.Task_Objects_Related_Exclusions__c;
        Set<String> exclusions = new Set<String>(exclusionString.split(','));

        String savedObjects = orgSettings.Task_Objects_Related_To_Account__c == null
            ? ''
            : orgSettings.Task_Objects_Related_To_Account__c;
        List<String> saveObjectsSplit = savedObjects.split(',');
        Set<String> saveObjectsSet = new Set<String>(saveObjectsSplit);

        Set<Schema.SObjectType> sObjTypes = SObjectService.getObjectsRelatedTo(Schema.Account.SObjectType);
        Map<String, Boolean> result = new Map<String, Boolean>();

        for (Schema.SObjectType sObjType : sObjTypes) {
            Schema.DescribeSObjectResult describeResult = sObjType.getDescribe();
            String name = describeResult.getName();
            if (!RELATEDEXCLUSIONS.contains(name) && !exclusions.contains(name)) {
                result.put(name, saveObjectsSet.contains(name));
            }
        }

        return result;
    }

    @AuraEnabled
    public static pq_Crush_User_Setting__c getUserSetting() {
        return CrushUserSettingService.getSetting();
    }

    @AuraEnabled
    public static Map<String, Boolean> getObjectsRelatedToAccountPlan() {
        CRUSH_Settings_Obj__c orgSettings = SettingService.getOrgSettingsAndCreateIfNeeded();

        String exclusionString = orgSettings.Task_Objects_Related_Exclusions__c == null
            ? ''
            : orgSettings.Task_Objects_Related_Exclusions__c;
        Set<String> exclusions = new Set<String>(exclusionString.split(','));

        String savedObjects = orgSettings.Task_Objects_Related_To_Account_Plan__c == null
            ? ''
            : orgSettings.Task_Objects_Related_To_Account_Plan__c;
        List<String> saveObjectsSplit = savedObjects.split(',');
        Set<String> saveObjectsSet = new Set<String>(saveObjectsSplit);

        Set<Schema.SObjectType> sObjTypes = SObjectService.getObjectsRelatedTo(Schema.Account_Plan__c.SObjectType);
        Map<String, Boolean> result = new Map<String, Boolean>();
        result.put('Account', saveObjectsSet.contains('Account'));

        for (Schema.SObjectType sObjType : sObjTypes) {
            Schema.DescribeSObjectResult describeResult = sObjType.getDescribe();
            String name = describeResult.getName();
            if (!RELATEDEXCLUSIONS.contains(name) && !exclusions.contains(name)) {
                result.put(name, saveObjectsSet.contains(name));
            }
        }

        return result;
    }

    @AuraEnabled
    public static void saveObjectsRelatedToAccount(Map<String, Boolean> input) {
        String inputString = UtilityForString.buildStringFromMap(input);
        CRUSH_Settings_Obj__c orgSettings = SettingService.getOrgSettingsAndCreateIfNeeded();
        orgSettings.Task_Objects_Related_To_Account__c = inputString;
        SettingService.upsertSettings(orgSettings);
    }

    @AuraEnabled
    public static void saveObjectsRelatedToAccountPlan(Map<String, Boolean> input) {
        String inputString = UtilityForString.buildStringFromMap(input);
        CRUSH_Settings_Obj__c orgSettings = SettingService.getOrgSettingsAndCreateIfNeeded();
        orgSettings.Task_Objects_Related_To_Account_Plan__c = inputString;
        SettingService.upsertSettings(orgSettings);
    }

    private static void scheduleKeyDateReminderEmailJob(Set<String> existingJobNames) {
        // runs at 9am every day
        if (existingJobNames.contains(KEY_DATES_REMINDER_JOB_NAME) == false) {
            System.schedule(KEY_DATES_REMINDER_JOB_NAME, '0 0 9 * * ?', new ScheduleEmailKeyDateReminderBatch());
        }
    }

    private without sharing class SystemContext {
        private void commitWork(fflib_ISObjectUnitOfWork uow) {
            uow.commitWork();
        }
    }

    @AuraEnabled
    public static Boolean updateAccountPlan(String recordId) {
        Boolean flag = false;
        try {
            CrushSettings cs = getOrgSettings();
            pqcrush__Account_Plan__c acp = new pqcrush__Account_Plan__c();
            acp.pqcrush__Default_Plan_Scoring__c = cs.useDefaultAPScoring;
            acp.Id = recordId;
            Database.SaveResult sr;
            if(Schema.sObjectType.pqcrush__Account_Plan__c.isUpdateable() && Schema.sObjectType.pqcrush__Account_Plan__c.fields.pqcrush__Default_Plan_Scoring__c.isUpdateable()) {
                 sr = Database.update(acp,true,Accesslevel.USER_MODE);
            }
            if (sr.isSuccess()) {
                flag = true;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return flag;
    }
}