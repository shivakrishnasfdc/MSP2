public with sharing class RelationshipLineWrapperService {
    private static RelationshipLineWrapperServiceImpl instance = null;

    public static Map<Id, String> getNodeNames(
        List<Contact_Relationship__c> contactRelList,
        List<Map_Member_Placeholder_Relationship__c> mapMemberList
    ) {
        return service().getNodeNames(contactRelList, mapMemberList);
    }

    public static Map<String, List<CommonRelationshipLineObject>> organizeMemberList(
        Id contactId,
        List<Map_Member_Placeholder_Relationship__c> mapMemberList,
        List<Contact_Relationship__c> contactRelList
    ) {
        return service().organizeMemberList(contactId, mapMemberList, contactRelList);
    }

    private static RelationshipLineWrapperServiceImpl service() {
        if (instance == null) {
            instance = (RelationshipLineWrapperServiceImpl) Application.Service.newInstance(
                RelationshipLineWrapperServiceImpl.class
            );
        }
        return instance;
    }
}