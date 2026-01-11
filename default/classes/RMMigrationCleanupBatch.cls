@SuppressWarnings('PMD.EmptyStatementBlock')
public with sharing class RMMigrationCleanupBatch implements Database.Batchable<SObject> {
    List<String> matchingFields = PostInstallHelperService.getFieldsForKSMigration();
    Map<String, Schema.SObjectField> rmmFields = Relationship_Map_Member__c.getSObjectType()
        .getDescribe()
        .fields.getMap();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Query rmQuery = PostInstallHelperService.getQueryForKSMigration();
        if (rmQuery == null) {
            return null;
        }
        String queryString = rmQuery.toQueryString();
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext bc, List<Relationship_Map_Member__c> rmmsToUpdate) {
        Application.bypassTrigger = true;
        Map<Id, Relationship_Map_Member__c> rmmMap = new Map<Id, Relationship_Map_Member__c>();
        for (Relationship_Map_Member__c rmm : rmmsToUpdate) {
            rmmMap.put(rmm.Original_Key_Stakeholder__c, rmm);
        }

        List<Key_Stakeholder__c> keyStakeholders = new Query(Key_Stakeholder__c.getSObjectType(), null)
            .addCondition(Query.conditionIn('Id', rmmMap.keySet()))
            .selectFields(matchingFields)
            .toSObjectList();

        for (Key_Stakeholder__c ks : keyStakeholders) {
            Relationship_Map_Member__c rmm = rmmMap.get(ks.Id);
            for (String field : matchingFields) {
                Schema.SObjectField rmmField = rmmFields.get(field);
                if (rmmField == null) {
                    continue;
                }
                if (rmmField.getDescribe().getType() == Schema.DisplayType.Boolean) {
                    rmm.put(field, ks.get(field));
                } else if (ks.get(field) != null && rmm.get(field) == null) {
                    rmm.put(field, ks.get(field));
                }
            }
        }
        update rmmsToUpdate;
        Application.bypassTrigger = false;
    }

    public void finish(Database.BatchableContext bc) {
    }
}