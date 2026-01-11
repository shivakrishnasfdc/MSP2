@isTest
private class ReportStructureWrapperTest {
    @isTest
    static void instanceTest() {
        Id id = fflib_IDGenerator.generate(Relationship_Map__c.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        List<String> peopleTheyReportTo = new List<String>{ 'joe', 'cindy' };
        List<String> peopleTheyManage = new List<String>{ 'john', 'jane' };
        String containerName = 'my map';
        Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        Id relationshipMapId = fflib_IDGenerator.generate(Relationship_Map__c.SObjectType);

        ReportStructureWrapper wrapper = new ReportStructureWrapper(
            id,
            contactId,
            peopleTheyReportTo,
            peopleTheyManage,
            containerName,
            accountPlanId,
            relationshipMapId
        );

        System.assertEquals(id, wrapper.id);
        System.assertEquals(contactId, wrapper.contactId);
        System.assertEquals(peopleTheyReportTo, wrapper.peopleTheyReportTo);
        System.assertEquals(peopleTheyManage, wrapper.peopleTheyManage);
        System.assertEquals(containerName, wrapper.containerName);
        System.assertEquals(accountPlanId, wrapper.accountPlanId);
        System.assertEquals(relationshipMapId, wrapper.relationshipMapId);
    }

    @isTest
    static void convertTest() {
        TestMockData md = new TestMockData();
        ReportStructureWrapperServiceImpl mockReportStructureWrapperService = md.mockReportStructureWrapperService;

        Id c1 = fflib_IDGenerator.generate(Contact.SObjectType);
        Id c2 = fflib_IDGenerator.generate(Contact.SObjectType);
        Id c3 = fflib_IDGenerator.generate(Contact.SObjectType);

        Id apId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        Id rmId = fflib_IDGenerator.generate(Relationship_Map__c.SObjectType);

        Contact contact1 = new Contact(Id = c1, LastName = 'Test1', FirstName = 'first1');
        Contact contact2 = new Contact(Id = c2, LastName = 'Test2', FirstName = 'first2');
        Contact contact3 = new Contact(Id = c3, LastName = 'Test3', FirstName = 'first3');

        Map_Member_Placeholder_Relationship__c mmpr1 = new Map_Member_Placeholder_Relationship__c(
            To__c = c1,
            From__c = c2,
            Is_Hierarchy__c = true,
            Contact_Relationship_Type__c = null,
            Relationship_Map__c = null,
            Account_Plan__c = apId
        );

        Map_Member_Placeholder_Relationship__c mmpr2 = new Map_Member_Placeholder_Relationship__c(
            To__c = c3,
            From__c = c1,
            Is_Hierarchy__c = true,
            Contact_Relationship_Type__c = null,
            Relationship_Map__c = rmId,
            Account_Plan__c = null
        );

        Map_Member_Placeholder_Relationship__c mmpr3 = new Map_Member_Placeholder_Relationship__c(
            To__c = c2,
            From__c = c3,
            Is_Hierarchy__c = true,
            Contact_Relationship_Type__c = null,
            Relationship_Map__c = rmId,
            Account_Plan__c = null
        );

        List<Map_Member_Placeholder_Relationship__c> mapMemberList = new List<Map_Member_Placeholder_Relationship__c>{
            mmpr1,
            mmpr2,
            mmpr3
        };

        List<Map_Member_Placeholder_Relationship__c> list1 = new List<Map_Member_Placeholder_Relationship__c>{ mmpr1 };
        List<Map_Member_Placeholder_Relationship__c> list2 = new List<Map_Member_Placeholder_Relationship__c>{
            mmpr2,
            mmpr3
        };

        Map<Id, List<Map_Member_Placeholder_Relationship__c>> mapByContainerId = new Map<Id, List<Map_Member_Placeholder_Relationship__c>>();
        mapByContainerId.put(apId, list1);
        mapByContainerId.put(rmId, list2);

        Map<Id, Contact> mapContacts = new Map<Id, Contact>();
        mapContacts.put(c1, contact1);
        mapContacts.put(c2, contact2);
        mapContacts.put(c3, contact3);

        md.mocks.startStubbing();
        md.mocks.when(mockReportStructureWrapperService.organizeMemberList(mapMemberList)).thenReturn(mapByContainerId);
        md.mocks.when(mockReportStructureWrapperService.getContactMap(mapMemberList)).thenReturn(mapContacts);
        md.mocks.stopStubbing();

        List<ReportStructureWrapper> result = ReportStructureWrapper.convert(md.mockContactId, mapMemberList);

        Set<Id> mapIds = new Set<Id>{ rmId, apId };

        System.assertEquals(2, result.size());
        System.assert(mapIds.contains(result[0].id));
        System.assert(mapIds.contains(result[1].id));
    }

    @isTest
    static void convert2Test() {
        Contact a = new Contact(LastName = 'Test1', FirstName = 'first1');
        insert a;
        Contact b = new Contact(LastName = 'Test1', FirstName = 'first1', ReportsToId = a.Id);
        insert b;
        Contact c = new Contact(LastName = 'Test1', FirstName = 'first1', ReportsToId = b.Id);
        insert c;
        Contact d = new Contact(LastName = 'Test1', FirstName = 'first1', ReportsToId = b.Id);
        insert d;

        List<Contact> peopleTheyManage = new List<Contact>{ b, c };

        ReportStructureWrapper result = ReportStructureWrapper.convert(b, peopleTheyManage);

        System.assertEquals(1, result.peopleTheyReportTo.size());
        System.assertEquals(2, result.peopleTheyManage.size());
    }

    @isTest
    static void convertNullTest() {
        List<ReportStructureWrapper> result = ReportStructureWrapper.convert(
            fflib_IDGenerator.generate(Contact.SObjectType),
            null
        );
        System.assertEquals(0, result.size());

        List<ReportStructureWrapper> result2 = ReportStructureWrapper.convert(
            fflib_IDGenerator.generate(Contact.SObjectType),
            null
        );
        System.assertEquals(0, result2.size());
    }
}