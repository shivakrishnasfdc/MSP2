public with sharing class InfluenceSupportMatrixService {
    public static Map<Id, pq_Influence_And_Support_Matrix__c> getMatrixesForRelationshipMap(Set<Id> mapIds) {
        return service().getMatrixesForRelationshipMap(mapIds);
    }

    public static Map<Id, pq_Influence_And_Support_Matrix__c> getMatrixesForAccountPlan(Set<Id> accountPlanIds) {
        return service().getMatrixesForAccountPlan(accountPlanIds);
    }

    public static List<pq_Influence__c> getInfluencesByMatrixes(Set<Id> matrixIdSet) {
        return service().getInfluencesByMatrixes(matrixIdSet);
    }

    public static List<pq_Support__c> getSupportByMatrixes(Set<Id> matrixIdSet) {
        return service().getSupportByMatrixes(matrixIdSet);
    }

    public static MatrixMember buildMatrixMemberForKS(
        Key_Stakeholder__c ks,
        Map<String, FieldMetaData> descFieldMap,
        RM_Chart_Setting__c setting,
        Map<Id, Id> reportsToMap,
        Map<Id, Contact> contactMap
    ) {
        return service().buildMatrixMemberForKS(ks, descFieldMap, setting, reportsToMap, contactMap);
    }

    public static MatrixMember buildMatrixMemberForMapMember(
        Relationship_Map_Member__c rmm,
        Map<String, FieldMetaData> descFieldMap,
        RM_Chart_Setting__c setting,
        Map<Id, Id> reportsToMap,
        Map<Id, Contact> contactMap
    ) {
        return service().buildMatrixMemberForMapMember(rmm, descFieldMap, setting, reportsToMap, contactMap);
    }

    private static InfluenceSupportMatrixServiceImpl service() {
        return (InfluenceSupportMatrixServiceImpl) Application.Service.newInstance(
            InfluenceSupportMatrixServiceImpl.class
        );
    }
}