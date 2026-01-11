public abstract class AccountPlanWSChildDomain extends AccountPlanChildDomain {
    public AccountPlanWSChildDomain(List<SObject> sObjectList) {
        super(sObjectList);
    }

    public AccountPlanWSChildDomain(List<SObject> sObjectList, SObjectType sObjectType) {
        super(sObjectList, sObjectType);
    }

    /******************************
     *      VIRTUAL METHODS
     ******************************/

    protected virtual String getWhiteSpaceFieldName() {
        return 'White_Space__c';
    }

    public override virtual Map<Id, List<SObject>> getRecordsByAccountPlanIds() {
        Set<Id> whiteSpaceIds = new Set<Id>();
        Map<Id, Id> objWhiteSpaceIds = new Map<Id, Id>();
        for (SObject record : (List<SObject>) Records) {
            whiteSpaceIds.add((Id) record.get(getWhiteSpaceFieldName()));
            objWhiteSpaceIds.put(record.Id, (Id) record.get(getWhiteSpaceFieldName()));
        }

        List<White_Space__c> whiteSpaces = WhiteSpaceSelector.newInstance().selectById(whiteSpaceIds);
        Map<Id, Id> whiteSpaceAccountPlanIds = new Map<Id, Id>();
        for (White_Space__c record : whiteSpaces) {
            whiteSpaceAccountPlanIds.put(record.Id, (Id) record.get(getAccountPlanFieldName()));
        }

        Map<Id, List<SObject>> recordsByAccountPlanId = new Map<Id, List<SObject>>();
        for (SObject record : (List<SObject>) Records) {
            Id whiteSpaceId = objWhiteSpaceIds.get(record.Id);
            Id accountPlanId = whiteSpaceAccountPlanIds.get(whiteSpaceId);

            if (!recordsByAccountPlanId.containsKey(accountPlanId)) {
                recordsByAccountPlanId.put(accountPlanId, new List<SObject>());
            }

            recordsByAccountPlanId.get(accountPlanId).add(record);
        }

        return recordsByAccountPlanId;
    }
}