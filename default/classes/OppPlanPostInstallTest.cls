@IsTest
private class OppPlanPostInstallTest {
    @IsTest
    static void postInstallFreshInstallTest() {
        new OppPlanPostInstall(null);
        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
            FROM CronTrigger
            WHERE CronJobDetail.Name = :OppPlanPostInstall.OPP_PLAN_CREATION_JOB_NAME
        ];
        Set<String> jobNames = new Set<String>();
        for (CronTrigger job : jobs) {
            jobNames.add(job.CronJobDetail.Name);
        }
        System.assert(jobNames.contains(OppPlanPostInstall.OPP_PLAN_CREATION_JOB_NAME));
    }

    @IsTest
    static void postInstall13xUpgradeTest() {
        new OppPlanPostInstall(new Version(13, 99));
        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
            FROM CronTrigger
            WHERE CronJobDetail.Name = :OppPlanPostInstall.OPP_PLAN_CREATION_JOB_NAME
        ];
        Set<String> jobNames = new Set<String>();
        for (CronTrigger job : jobs) {
            jobNames.add(job.CronJobDetail.Name);
        }
        System.assert(jobNames.contains(OppPlanPostInstall.OPP_PLAN_CREATION_JOB_NAME));
    }

    @IsTest
    static void postInstallPost13xUpgradeTest() {
        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
            FROM CronTrigger
            WHERE CronJobDetail.Name = :OppPlanPostInstall.OPP_PLAN_CREATION_JOB_NAME
        ];
        Set<String> before = new Set<String>();
        for (CronTrigger job : jobs) {
            before.add(job.CronJobDetail.Name);
        }

        new OppPlanPostInstall(new Version(14, 99));

        jobs = [
            SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
            FROM CronTrigger
            WHERE CronJobDetail.Name = :OppPlanPostInstall.OPP_PLAN_CREATION_JOB_NAME
        ];
        Set<String> after = new Set<String>();
        for (CronTrigger job : jobs) {
            after.add(job.CronJobDetail.Name);
        }
        System.assertEquals(before, after);
    }
}