public with sharing class DataCleanupController {
    @AuraEnabled
    public static Integer getCountOfMembersNeedingInfluenceSupportCleanup() {
        Integer count = 0;
        count += PostInstallHelperService.getMapMembersToUpdate().size();
        count += PostInstallHelperService.getStakeholdersToUpdate().size();
        return count;
    }

    @AuraEnabled
    public static void cleanupMembersNeedingInfluenceSupport() {
        List<SObject> foundRecords = new List<SObject>();
        foundRecords.addAll(PostInstallHelperService.getMapMembersToUpdate());
        foundRecords.addAll(PostInstallHelperService.getStakeholdersToUpdate());
        if (foundRecords.size() == 0) {
            return;
        }
        List<pq_Influence__c> infList = InfluenceSelector.newInstance().selectAll();
        List<pq_Support__c> suppList = SupportSelector.newInstance().selectAll();
        Set<SObject> recordsToUpdate = PostInstallHelperService.updateMapMembersInfleunceSupport(
            foundRecords,
            infList,
            suppList
        );
        PostInstallHelperService.executeBatchUpdateForRecords(
            new List<SObject>(recordsToUpdate),
            new List<Schema.SObjectType>{
                Key_Stakeholder__c.getSObjectType(),
                Relationship_Map_Member__c.getSObjectType()
            }
        );
    }

    @AuraEnabled
    public static Integer getRecordCountForKSMapConversion() {
        return PostInstallHelperService.getRecordCountForKSMapConversion();
    }

    @AuraEnabled
    public static void startKSMapConversionBatch() {
        KSConversionBatch batch = new KSConversionBatch();
        Database.executeBatch(batch, 5);
    }

    @AuraEnabled
    public static Boolean isKSMapConversionRunning() {
        Query q = new Query(AsyncApexJob.getSObjectType(), null);
        q.addCondition(
            Query.doAnd(
                Query.conditionEq('ApexClass.Name', 'KSConversionBatch'),
                Query.conditionIn('Status', new List<String>{ 'Processing', 'Queued' })
            )
        );
        q.count('Id', 'totalCount');
        AggregateResult result = q.aggregate()[0];
        return (Integer) result.get('totalCount') > 0;
    }

    @AuraEnabled
    public static List<String> getFieldsForKSMigration() {
        return PostInstallHelperService.getFieldsForKSMigration();
    }

    @AuraEnabled
    public static Integer getRecordCountForKSMigration() {
        return PostInstallHelperService.getRecordCountForKSMigration();
    }

    @AuraEnabled
    public static void startKSMigrationCleanupBatch() {
        RMMigrationCleanupBatch batch = new RMMigrationCleanupBatch();
        Database.executeBatch(batch, 500);
    }

    @AuraEnabled
    public static void migrateKSDataToRM() {
        List<SObject> mapMembers = PostInstallHelperService.getMapMembersToUpdateCustomFields();
        Set<SObject> recordsToUpdate = new Set<SObject>(mapMembers);
        PostInstallHelperService.executeBatchUpdateForRecords(
            new List<SObject>(recordsToUpdate),
            new List<Schema.SObjectType>{ Relationship_Map_Member__c.getSObjectType() }
        );
    }

    @AuraEnabled
    public static Boolean isKSMigrationRunning() {
        Query q = new Query(AsyncApexJob.getSObjectType(), null);
        q.addCondition(
            Query.doAnd(
                Query.conditionEq('ApexClass.Name', 'RMMigrationCleanupBatch'),
                Query.conditionIn('Status', new List<String>{ 'Processing', 'Queued' })
            )
        );
        q.count('Id', 'totalCount');
        AggregateResult result = q.aggregate()[0];
        return (Integer) result.get('totalCount') > 0;
    }
    
    @AuraEnabled
    public static void startRelationshipMemberUpdateCountBatch() {
    
        RelationshipMemberCountUpdateBatch batchJob = new RelationshipMemberCountUpdateBatch();
        Database.executeBatch(batchJob, Integer.valueOf(System.label.RelationshipMemberCountUpdateBatch_Size));
        
    }
}