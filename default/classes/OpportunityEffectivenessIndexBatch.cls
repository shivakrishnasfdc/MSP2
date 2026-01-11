@SuppressWarnings('PMD.EmptyStatementBlock')
public with sharing class OpportunityEffectivenessIndexBatch implements Database.Batchable<SObject>, Schedulable {
    
    private List<SObject> objectsToUpdate = new List<SObject>();
    private List<SObject> objectsToInsert = new List<SObject>();
    private Date fromDate = null;
    private Date toDate = null;

    /******************************
     *     Schedulable Methods
     ******************************/

    public void execute(SchedulableContext context) {
        Database.executeBatch(this);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {

        Date fDate = getFromDate();
        Date tDate = getToDate();

        return Database.getQueryLocator(
            [
                SELECT Id, IsWon, IsClosed
                FROM Opportunity
                WHERE IsClosed = true AND LastModifiedDate >= :fDate AND LastModifiedDate < :tDate
            ]
        );
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> opps) {
        Application.bypassTrigger = true;

        Date d = getFromDate();

        OpportunityEIBatchService.processOpportunity(opps, d);

        Application.bypassTrigger = false;
    }

    public void finish(Database.BatchableContext bc) {
    }

    private Date getFromDate() {
                
        if (fromDate == null || toDate == null) {
            toDate = Date.today();
            fromDate = toDate.addDays(-1);
        }

        return fromDate;
    }

    private Date getToDate() {
                
        if (fromDate == null || toDate == null) {
            toDate = Date.today();
            fromDate = toDate.addDays(-1);
        }

        return toDate;
    }

}