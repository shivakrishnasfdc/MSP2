public with sharing class RelationshipMapTriggerHandler extends PQSObjectDomainExt {
    public RelationshipMapTriggerHandler(List<pqcrush__Relationship_Map__c> records) {
        super(records);
    }

    public static RelationshipMapTriggerHandler newInstance(List<pqcrush__Relationship_Map__c> sObjectList) {
        return (RelationshipMapTriggerHandler) Application.Domain.newInstance(sObjectList);
    }

    /******************************
     *   TRIGGER HANDLER METHODS
     ******************************/
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        updateCount(existingRecords);
    }

    public override void onAfterDelete() {
        updateAccPlanCount((List<pqcrush__Relationship_Map__c>) Records);
    }

    public void updateAccPlanCount(List<pqcrush__Relationship_Map__c> relationShipMapLst) {
        Set<Id> accPlanIds = new Set<Id>();
        Map<Id, pqcrush__Account_Plan__c> accountPlanMapToUpdate = new Map<Id, pqcrush__Account_Plan__c>();
        if (relationShipMapLst.size() > 0) {
            for (pqcrush__Relationship_Map__c rel : relationShipMapLst) {
                // Putting the values into the Set if objects size greater than zero
                accPlanIds.add(rel.pqcrush__pq_AccountPlanId__c);
            }
        }
        if (
            pqcrush__Relationship_Map__c.SObjectType.getDescribe().isAccessible() &&
            Schema.SObjectType.pqcrush__Relationship_Map__c.fields.pqcrush__Map_Member_Count__c.isAccessible()
        ) {
            if (accPlanIds.size() > 0) {
                //Using Aggregate functions in SOQL, to Count(), SUM() and MAX(), for roll up and summarize data in a query.
                for (AggregateResult aggr : [
                    SELECT Count(Id) ids, pqcrush__pq_AccountPlanId__c, SUM(pqcrush__Map_Member_Count__c) cnt
                    FROM pqcrush__Relationship_Map__c
                    WHERE pqcrush__pq_AccountPlanId__c IN :accPlanIds
                    GROUP BY pqcrush__pq_AccountPlanId__c
                ]) {
                    pqcrush__Account_Plan__c accountPlans = new pqcrush__Account_Plan__c();
                    accountPlans.pqcrush__Relationship_Members_Count__c = (Decimal) aggr.get('cnt');
                    accountPlans.Id = (Id) aggr.get('pqcrush__pq_AccountPlanId__c');
                    accountPlanMapToUpdate.put(accountPlans.Id, accountPlans);
                }
            }

            try {
                update accountPlanMapToUpdate.values();
            } catch (Exception e) {
                System.debug('Error on updating of relationship map member count ' + e.getMessage()); //NOPMD
            }
        }
    }
    public void updateCount(map<id, SObject> existing) {
        updateAccPlanCount((List<pqcrush__Relationship_Map__c>) Records);
    }

    /******************************
     *       INNER CLASSES
     ******************************/

    /**
     * This is a workaround for the lack of reflection in Apex.
     */
    public with sharing class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new RelationshipMapTriggerHandler(sObjectList);
        }
    }
}