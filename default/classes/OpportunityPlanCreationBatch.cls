@SuppressWarnings('PMD.AvoidGlobalModifier,PMD.EmptyStatementBlock')
global with sharing class OpportunityPlanCreationBatch implements Database.Batchable<sObject>, Schedulable {
    public Integer batchSize = 200;
    public Integer maxRecords = 10000;

    /******************************
     *     Schedulable Methods
     ******************************/

    global void execute(SchedulableContext context) {
        Database.executeBatch(this, batchSize);
    }

    /******************************
     *     Batchable Methods
     ******************************/

    global Database.QueryLocator start(Database.BatchableContext context) {
        if (!FeatureFlagController.hasOpportunityPlanAccess()) {
            return Database.getQueryLocator([SELECT Id FROM Opportunity WITH SECURITY_ENFORCED LIMIT 0]); //must return a valid query locator but don't want results to try to process
        }
        //Query oppQuery = OpportunityPlanService.getQueryForOpportunitiesWithoutPlans();
        //return oppQuery.getQueryLocator();
        return Database.getQueryLocator([SELECT Id,Name FROM Opportunity WHERE ID NOT IN (SELECT pqcrush__Opportunity__c from pqcrush__PQ_Opportunity_Plan__c) WITH SECURITY_ENFORCED]);
    }

    global void execute(Database.BatchableContext context, List<Opportunity> opps) {
        if (!FeatureFlagController.hasOpportunityPlanAccess()) {
            return;
        }
        OpportunityPlanService.createOpportunityPlans(opps);
    }

    global void finish(Database.BatchableContext context) {
    }
}