public with sharing class RelationshipMapService {
    public static pqcrush__Relationship_Map__c createRelationshipMapWithFieldValues(Map<String, Object> fieldValues) {
        return service().createRelationshipMapWithFieldValues(fieldValues);
    }

    public static pqcrush__Relationship_Map__c createRelatedMap(
        List<Schema.SObjectField> objRelations,
        List<Schema.SObjectField> mapRelations,
        Schema.DescribeSObjectResult objDescribe,
        Id objRecordId
    ) {
        return service().createRelatedMap(objRelations, mapRelations, objDescribe, objRecordId);
    }

    public static List<Relationship_Map_Member__c> addContactToRelationshipMap(
        Id relationshipMapId,
        Set<Id> contactIdSet
    ) {
        return service().addContactToRelationshipMap(relationshipMapId, contactIdSet);
    }

    public static Double getMapMemberCountForAccountPlan(List<Account_Plan__c> accountPlans) {
        return service().getMapMemberCountForAccountPlan(accountPlans);
    }

    public static Date getMapMemberLastUpdatedDateForAccountPlan(List<Account_Plan__c> accountPlans) {
        return service().getMapMemberLastUpdatedDateForAccountPlan(accountPlans);
    }

    public static Boolean hasAccountPlanSetting(Id mapId) {
        return service().hasAccountPlanSetting(mapId);
    }

    public static Boolean hasAccountPlanSetting(Relationship_Map__c rmMap) {
        return service().hasAccountPlanSetting(rmMap);
    }

    public static Id getParentIdForRelationshipMapId(Id mapId) {
        return service().getParentIdForRelationshipMapId(mapId);
    }

    public static Id getParentIdForRelationshipMap(Relationship_Map__c rmMap) {
        return service().getParentIdForRelationshipMap(rmMap);
    }

    public static Set<Id> getMapsForObjectFromObject(Schema.SObjectType objType, Set<Id> recordIds) {
        return service().getMapsForObjectFromObject(objType, recordIds);
    }

    public static Set<Id> getMapsForObjectFromRM(Schema.SObjectType objType, Set<Id> recordIds) {
        return service().getMapsForObjectFromRM(objType, recordIds);
    }

    private static RelationshipMapServiceImpl service() {
        return (RelationshipMapServiceImpl) Application.Service.newInstance(RelationshipMapServiceImpl.class);
    }
}