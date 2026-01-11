public with sharing class HierarchyHelperService {
    private static HierarchyHelperServiceImpl instance = null;

    public static String getLabelForRelationship(Contact_Relationship__c rel) {
        return service().getLabelForRelationship(rel);
    }

    public static String getLabelForRelationship(Map_Member_Placeholder_Relationship__c rel) {
        return service().getLabelForRelationship(rel);
    }

    private static HierarchyHelperServiceImpl service() {
        if (instance == null) {
            instance = (HierarchyHelperServiceImpl) Application.Service.newInstance(HierarchyHelperServiceImpl.class);
        }
        return instance;
    }
}