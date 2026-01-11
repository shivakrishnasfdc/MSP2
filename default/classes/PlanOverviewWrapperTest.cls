@isTest
private class PlanOverviewWrapperTest {
    @isTest
    static void newInstanceTest() {
        Id overviewId = fflib_IDGenerator.generate(pq_CRUSH_Plan_Overview__c.SObjectType);
        String backgroundColor = '#223344';
        String title = 'title A';
        String description = 'desc A';

        pq_CRUSH_Plan_Overview__c planOverview = new pq_CRUSH_Plan_Overview__c(
            Id = overviewId,
            Background_Color__c = backgroundColor,
            Title__c = title,
            Description__c = description
        );

        PlanOverviewWrapper result = new PlanOverviewWrapper(planOverview, true, false);
        System.assertNotEquals(null, result);
        System.assertEquals(overviewId, result.id);
        System.assertEquals(title, result.title);
        System.assertEquals(description, result.description);
        System.assertEquals(backgroundColor, result.backgroundColor);
        System.assertEquals(true, result.updateable);
        System.assertEquals(false, result.deleteable);
    }

    @isTest
    static void newInstanceDefaultColorTest() {
        Id overviewId = fflib_IDGenerator.generate(pq_CRUSH_Plan_Overview__c.SObjectType);
        String backgroundColor = null;
        String title = 'title A';
        String description = 'desc A';

        pq_CRUSH_Plan_Overview__c planOverview = new pq_CRUSH_Plan_Overview__c(
            Id = overviewId,
            Background_Color__c = backgroundColor,
            Title__c = title,
            Description__c = description
        );

        PlanOverviewWrapper result = new PlanOverviewWrapper(planOverview, true, false);
        System.assertNotEquals(null, result);
        System.assertEquals('#cccccc', result.backgroundColor);
    }
}