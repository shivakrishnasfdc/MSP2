@SuppressWarnings('PMD.ApexDangerousMethods')
public abstract class AccountPlanChildDomain extends PQSObjectDomainExt {
    public AccountPlanChildDomain(List<SObject> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    public AccountPlanChildDomain(List<SObject> sObjectList, SObjectType sObjectType) {
        super(sObjectList, sObjectType);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    /******************************
     *   TRIGGER HANDLER METHODS
     ******************************/

    public virtual override void onBeforeInsert() {
        AccountPlanService.maybeOpenAccountPlans(getRecordsByAccountPlanIds());
    }

    public virtual override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        AccountPlanService.maybeOpenAccountPlans(getRecordsByAccountPlanIds());
    }

    public virtual override void onBeforeDelete() {
        AccountPlanService.maybeOpenAccountPlans(getRecordsByAccountPlanIds());
    }

    /******************************
     *      VIRTUAL METHODS
     ******************************/

    protected virtual String getAccountPlanFieldName() {
        return 'pqcrush__Account_Plan__c';
    }

    public virtual Map<Id, List<SObject>> getRecordsByAccountPlanIds() {
        Map<Id, List<SObject>> recordsByAccountPlanId = new Map<Id, List<SObject>>();

        for (SObject record : Records) {
            Id accountPlanId = (Id) record.get(getAccountPlanFieldName());

            if (!recordsByAccountPlanId.containsKey(accountPlanId)) {
                recordsByAccountPlanId.put(accountPlanId, new List<SObject>());
            }

            recordsByAccountPlanId.get(accountPlanId).add(record);
        }

        return recordsByAccountPlanId;
    }
}