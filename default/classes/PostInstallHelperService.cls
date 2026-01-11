public with sharing class PostInstallHelperService {
    // Key Stakeholder and Map Member influence and support field migration

    public static List<Relationship_Map_Member__c> getMapMembersToUpdate() {
        return service().getMapMembersToUpdate();
    }

    public static List<Key_Stakeholder__c> getStakeholdersToUpdate() {
        return service().getStakeholdersToUpdate();
    }

    public static Set<SObject> updateMapMembersInfleunceSupport(
        List<SObject> members,
        List<pq_Influence__c> infList,
        List<pq_Support__c> suppList
    ) {
        return service().updateMapMembersInfleunceSupport(members, infList, suppList);
    }

    // Migrate to Relationship Map object

    public static Integer getRecordCountForKSMapConversion() {
        return service().getRecordCountForKSMapConversion();
    }

    public static Query getQueryForKSMapConversion() {
        return service().getQueryForKSMapConversion();
    }

    // Migrate Key Stakeholders to Map Members

    public static List<Relationship_Map_Member__c> getMapMembersToUpdateCustomFields() {
        return service().getMapMembersToUpdateCustomFields();
    }

    public static List<String> getFieldsForKSMigration() {
        return service().getFieldsForKSMigration();
    }

    public static Integer getRecordCountForKSMigration() {
        return service().getRecordCountForKSMigration();
    }

    public static Query getQueryForKSMigration() {
        return service().getQueryForKSMigration();
    }

    public static List<Relationship_Map_Member__c> getRecordsForKSMigration() {
        return service().getRecordsForKSMigration();
    }

    // Generic Batching for Update and Insert

    public static void executeBatchUpdateForRecords(List<SObject> records, List<Schema.SObjectType> objTypes) {
        service().executeBatchUpdateForRecords(records, objTypes);
    }

    public static void executeBatchUpdateForRecords(
        List<SObject> records,
        List<Schema.SObjectType> objTypes,
        Integer batchSize,
        Boolean bypassTriggers
    ) {
        service().executeBatchUpdateForRecords(records, objTypes, batchSize, bypassTriggers);
    }

    public static void executeBatchInsertForRecords(List<SObject> records, List<Schema.SObjectType> objTypes) {
        service().executeBatchInsertForRecords(records, objTypes);
    }

    public static void executeBatchInsertForRecords(
        List<SObject> records,
        List<Schema.SObjectType> objTypes,
        Integer batchSize,
        Boolean bypassTriggers
    ) {
        service().executeBatchInsertForRecords(records, objTypes, batchSize, bypassTriggers);
    }

    private static PostInstallHelperServiceImpl service() {
        return (PostInstallHelperServiceImpl) Application.PostInstallService.newInstance(
            PostInstallHelperServiceImpl.class
        );
    }
}