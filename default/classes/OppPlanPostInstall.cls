@SuppressWarnings('PMD.EmptyStatementBlock')
public with sharing class OppPlanPostInstall {
    public static final String OPP_PLAN_CREATION_JOB_NAME = 'Scheduled Opportunity Plan Creation';
    private Version previousVersion;

    public OppPlanPostInstall(Version prevVersion) {
        this.previousVersion = prevVersion;
        if (prevVersion != null) {
            doUpgrade();
        } else {
            doFirstInstall();
        }
        doEveryTime();
    }

    private void doUpgrade() {
        if (isInstalledVersionBefore(new Version(14, 0))) {
            schedulePlanCreation();
        }
    }

    private void doFirstInstall() {
        schedulePlanCreation();
    }

    private void doEveryTime() {
    }

    private Boolean isInstalledVersionBefore(Version version) {
        return previousVersion.compareTo(version) < 0;
    }

    private void schedulePlanCreation() {
        if (Schema.sObjectType.CronTrigger.isAccessible() == false) {
            return;
        }
        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
            FROM CronTrigger
            WHERE CronJobDetail.Name = :OPP_PLAN_CREATION_JOB_NAME
        ];
        Set<String> jobNames = new Set<String>();

        for (CronTrigger job : jobs) {
            jobNames.add(job.CronJobDetail.Name);
        }
        // runs every hour
        if (jobNames.contains(OPP_PLAN_CREATION_JOB_NAME) == false) {
            System.schedule(OPP_PLAN_CREATION_JOB_NAME, '0 0 * * * ?', new OpportunityPlanCreationBatch());
        }
    }
}