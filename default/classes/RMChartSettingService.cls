public with sharing class RMChartSettingService {
    public static RM_Chart_Setting__c getRelationshipMapSettingForObject(Id objectId) {
        return service().getRelationshipMapSettingForObject(objectId);
    }

    public static RM_Chart_Setting__c getRelationshipMapSettingForObjectCreateIfNeeded(Id objectId) {
        return service().getRelationshipMapSettingForObjectCreateIfNeeded(objectId);
    }

    public static Map<Id, RM_Chart_Setting__c> getRelationshipMapSettingForObjects(Set<Id> objectIds) {
        return service().getRelationshipMapSettingForObjects(objectIds, false);
    }

    private static RMChartSettingServiceImpl service() {
        return (RMChartSettingServiceImpl) Application.Service.newInstance(RMChartSettingServiceImpl.class);
    }
}