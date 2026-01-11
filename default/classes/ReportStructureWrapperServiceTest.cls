@isTest
private class ReportStructureWrapperServiceTest {
    @isTest
    public static void organizeMemberListTest() {
        Map_Member_Placeholder_Relationship__c mmpr1 = new Map_Member_Placeholder_Relationship__c(
            To__c = fflib_IDGenerator.generate(Contact.SObjectType),
            From__c = fflib_IDGenerator.generate(Contact.SObjectType),
            Is_Hierarchy__c = true,
            Contact_Relationship_Type__c = null,
            Relationship_Map__c = null,
            Account_Plan__c = fflib_IDGenerator.generate(Account_Plan__c.SObjectType)
        );

        Map_Member_Placeholder_Relationship__c mmpr2 = new Map_Member_Placeholder_Relationship__c(
            To__c = fflib_IDGenerator.generate(Contact.SObjectType),
            From__c = fflib_IDGenerator.generate(Contact.SObjectType),
            Is_Hierarchy__c = true,
            Contact_Relationship_Type__c = null,
            Relationship_Map__c = fflib_IDGenerator.generate(Relationship_Map__c.SObjectType),
            Account_Plan__c = null
        );

        List<Map_Member_Placeholder_Relationship__c> mapMemberList = new List<Map_Member_Placeholder_Relationship__c>{
            mmpr1,
            mmpr2
        };

        Map<Id, List<Map_Member_Placeholder_Relationship__c>> result = ReportStructureWrapperService.organizeMemberList(
            mapMemberList
        );

        System.assertEquals(2, result.size());
        System.assert(result.keySet().contains(mmpr1.Account_Plan__c));
        System.assert(result.keySet().contains(mmpr2.Relationship_Map__c));
    }

    @isTest
    public static void getContactMapTest() {
        TestMockData md = new TestMockData();
        ContactSelector selector = md.mockContactSelector;

        Id c1 = fflib_IDGenerator.generate(Contact.SObjectType);
        Id c2 = fflib_IDGenerator.generate(Contact.SObjectType);
        Id c3 = fflib_IDGenerator.generate(Contact.SObjectType);

        Map_Member_Placeholder_Relationship__c mmpr1 = new Map_Member_Placeholder_Relationship__c(
            To__c = c1,
            From__c = c2,
            Is_Hierarchy__c = true,
            Contact_Relationship_Type__c = null,
            Relationship_Map__c = null,
            Account_Plan__c = fflib_IDGenerator.generate(Account_Plan__c.SObjectType)
        );

        Map_Member_Placeholder_Relationship__c mmpr2 = new Map_Member_Placeholder_Relationship__c(
            To__c = c3,
            From__c = c1,
            Is_Hierarchy__c = true,
            Contact_Relationship_Type__c = null,
            Relationship_Map__c = fflib_IDGenerator.generate(Relationship_Map__c.SObjectType),
            Account_Plan__c = null
        );

        Set<Id> contactIds = new Set<Id>{ c1, c2, c3 };

        md.mocks.startStubbing();
        md.mocks.when(selector.selectById(contactIds)).thenReturn(new List<Contact>{ md.mockContact });
        md.mocks.stopStubbing();

        List<Map_Member_Placeholder_Relationship__c> mapMemberList = new List<Map_Member_Placeholder_Relationship__c>{
            mmpr1,
            mmpr2
        };

        Map<Id, Contact> result = ReportStructureWrapperService.getContactMap(mapMemberList);

        System.assert(result.containsKey(md.mockContact.Id));
    }
}