public with sharing class ReportStructureWrapperService {
    public static Map<Id, List<Map_Member_Placeholder_Relationship__c>> organizeMemberList(
        List<Map_Member_Placeholder_Relationship__c> mapMemberList
    ) {
        return service().organizeMemberList(mapMemberList);
    }

    public static Map<Id, Contact> getContactMap(List<Map_Member_Placeholder_Relationship__c> mapMemberList) {
        return service().getContactMap(mapMemberList);
    }

    private static ReportStructureWrapperServiceImpl service() {
        return (ReportStructureWrapperServiceImpl) Application.Service.newInstance(
            ReportStructureWrapperServiceImpl.class
        );
    }
}