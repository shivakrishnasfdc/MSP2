public without sharing class OpportunityPlanSettingsController {
    public static final String OPPORTUNITY_EFFICIENCY_INDEX_JOB_NAME = 'Schedule Key Date Reminder Emails';

    @AuraEnabled
    public static Boolean isCreateOpportunityPlanEnabled() {
        List<pqcrush__pq_Opportunity_Manager_Setting__c> oppSetting = OpportunityManagerSettingSelector.newInstance().getOppSetting();
        if(oppSetting.size() == 0){
            pqcrush__pq_Opportunity_Manager_Setting__c oms = new pqcrush__pq_Opportunity_Manager_Setting__c();
            oms.pqcrush__Opportunity_Setting_Name__c = System.label.Opportunity_Manager_Setting;
            oppSetting.add(oms);
            Database.Insert(oppSetting,true,AccessLevel.USER_MODE);
        }
        return oppSetting[0].pqcrush__Create_Opportunity_Plan__c;
    }

    @AuraEnabled
    public static void updateCreateOpportunityPlanEnabled(Boolean createOppPlan) {
        List<pqcrush__pq_Opportunity_Manager_Setting__c> oppSetting = OpportunityManagerSettingSelector.newInstance().getOppSetting();
        if(oppSetting.size() > 0){
            pqcrush__pq_Opportunity_Manager_Setting__c oms = new pqcrush__pq_Opportunity_Manager_Setting__c();
            oppSetting[0].pqcrush__Create_Opportunity_Plan__c = createOppPlan;
            Database.Update(oppSetting,true,AccessLevel.USER_MODE);
        }
    }

    @AuraEnabled
    public static Boolean isOpportunityEfficiencyIndexJobStarted() {
        List<CronTrigger> jobs = queryJobs();
        return jobs.size() > 0;
    }

    @AuraEnabled
    public static void handleScheduleOpportunityPlanCreation(){
        Database.executeBatch(new OpportunityPlanCreationBatch(), 50);
    }

    @AuraEnabled
    public static void scheduleOpportunityEfficiencyIndexJobs() {
        List<CronTrigger> jobs = queryJobs();
        Set<String> jobNames = new Set<String>();

        for (CronTrigger job : jobs) {
            jobNames.add(job.CronJobDetail.Name);
        }

        // runs at 2am every day
        if (!jobNames.contains(OPPORTUNITY_EFFICIENCY_INDEX_JOB_NAME)) {
            System.schedule(OPPORTUNITY_EFFICIENCY_INDEX_JOB_NAME, '0 0 2 * * ?', new OpportunityEffectivenessIndexBatch());
        }
    }

    @AuraEnabled
    public static void runTest(Date d) {

        if (!Schema.sObjectType.Opportunity.isAccessible()) {
            throw new AuraHandledException('You do not have access to Opportunity');
        }

        Date toDate = d.addDays(1);

        List<Opportunity> opps = [
            SELECT Id, IsWon, IsClosed
            FROM Opportunity
            WHERE IsClosed = true AND LastModifiedDate >= :d AND LastModifiedDate < :toDate
            WITH SECURITY_ENFORCED
        ];

        OpportunityEIBatchService.processOpportunity(opps, d);

    }

    @AuraEnabled
    public static pq_Opportunity_Manager_Setting__c getSetting() {
        List<pqcrush__pq_Opportunity_Manager_Setting__c> oppSetting = OpportunityManagerSettingSelector.newInstance().getOppSetting();
        return oppSetting[0];
        
    }

    @AuraEnabled
    public static void updateDaysOfData(Integer days) {
        pq_Opportunity_Manager_Setting__c setting = OpportunityManagerSettingSelector.newInstance().selectOne();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        if (setting != null) {
            setting.Days_of_Data_Used_In_Analysis__c = days;
            uow.registerDirty(setting);
        } else {
            setting = new pq_Opportunity_Manager_Setting__c(
                Days_of_Data_Used_In_Analysis__c = days
            );
            uow.registerNew(setting);
        }
        uow.commitWork();
    }

    private static List<CronTrigger> queryJobs() {
        if (Schema.sObjectType.CronTrigger.isAccessible() == false) {
            throw new AuraHandledException('You do not have permission to schedule jobs');
        }

        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
            FROM CronTrigger
            WHERE CronJobDetail.Name = :OPPORTUNITY_EFFICIENCY_INDEX_JOB_NAME
        ];

        return jobs;
    }
}