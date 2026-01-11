@SuppressWarnings('PMD.EmptyStatementBlock')
public with sharing class BatchInsert implements Database.Batchable<sObject> {
    public Integer batchSize = 50;
    public List<SObject> objsToInsert;
    public List<Schema.SObjectType> relatedObjectTypes;
    public Boolean bypassTriggers = false;
    public Boolean bypassDmlChecks = false;

    public Iterable<sObject> start(Database.BatchableContext bc) {
        return objsToInsert;
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        Application.bypassTrigger = bypassTriggers;
        fflib_ISObjectUnitOfWork relatedUoW = new fflib_Application.UnitOfWorkFactory(relatedObjectTypes)
            .newInstance(new ContinueDML(this.bypassDmlChecks));
        relatedUoW.registerNew(scope);
        relatedUoW.commitWork();
        Application.bypassTrigger = false;
    }

    public void finish(Database.BatchableContext bc) {
    }
}