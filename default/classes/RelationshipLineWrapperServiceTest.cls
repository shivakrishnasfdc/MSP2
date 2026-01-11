@isTest
private class RelationshipLineWrapperServiceTest {
    @isTest
    static void getNodeNamesTest() {
        TestMockData md = new TestMockData();
        UsersSelector mockUsersSelector = md.mockUsersSelector;
        LeadSelector mockLeadSelector = md.mockLeadSelector;
        MapMemberPlaceHolderSelector mockMapMemberPlaceHolderSelector = md.mockMapMemberPlaceHolderSelector;
        RelationshipGroupSelector mockRelationshipGroupSelector = md.mockRelationshipGroupSelector;
        ContactSelector mockContactSelector = md.mockContactSelector;

        Id crId1 = fflib_IDGenerator.generate(Contact_Relationship__c.SObjectType);
        Id toId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id fromId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id mmprId1 = fflib_IDGenerator.generate(Map_Member_Placeholder_Relationship__c.SObjectType);

        Id mmprToId = fflib_IDGenerator.generate(Contact.SObjectType);

        List<Contact_Relationship__c> contactRelList = new List<Contact_Relationship__c>{
            new Contact_Relationship__c(Id = crId1, To_Contact__c = toId, From_Contact__c = fromId)
        };
        List<Map_Member_Placeholder_Relationship__c> mapMemberList = new List<Map_Member_Placeholder_Relationship__c>{
            new Map_Member_Placeholder_Relationship__c(Id = mmprId1, From__c = mmprToId, To__c = mmprToId)
        };

        Set<Id> mmprIdSet = new Set<Id>{ mmprToId };

        User user1 = new User(
            Id = fflib_IDGenerator.generate(User.SObjectType),
            FirstName = 'John',
            LastName = 'Smith'
        );
        Lead lead1 = new Lead(
            Id = fflib_IDGenerator.generate(Lead.SObjectType),
            FirstName = 'Jane',
            LastName = 'Doe',
            Company = 'ACME'
        );
        Map_Member_Placeholder__c mmp = new Map_Member_Placeholder__c(
            Id = fflib_IDGenerator.generate(Map_Member_Placeholder__c.SObjectType),
            Label__c = 'label1'
        );
        Relationship_Group__c relGroup = new Relationship_Group__c(
            Id = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType),
            Label__c = 'group1'
        );
        Contact c1 = new Contact(
            Id = fflib_IDGenerator.generate(Contact.SObjectType),
            FirstName = 'first',
            LastName = 'last'
        );

        md.mocks.startStubbing();
        md.mocks.when(mockUsersSelector.selectById(mmprIdSet)).thenReturn(new List<User>{ user1 });
        md.mocks.when(mockLeadSelector.selectById(mmprIdSet)).thenReturn(new List<Lead>{ lead1 });
        md.mocks.when(mockMapMemberPlaceHolderSelector.selectById(mmprIdSet))
            .thenReturn(new List<Map_Member_Placeholder__c>{ mmp });
        md.mocks.when(mockRelationshipGroupSelector.selectById(mmprIdSet))
            .thenReturn(new List<Relationship_Group__c>{ relGroup });
        md.mocks.when(mockContactSelector.selectById(new Set<Id>{ fromId, toId })).thenReturn(new List<Contact>{ c1 });
        md.mocks.stopStubbing();

        Map<Id, String> result = RelationshipLineWrapperService.getNodeNames(contactRelList, mapMemberList);
        System.assertEquals(5, result.keySet().size());
        System.assertEquals('label1', result.get(mmp.Id));
        System.assertEquals('group1', result.get(relGroup.Id));
    }

    @isTest
    static void organizeMemberListTest() {
        Contact testContact1 = TestDataFactory.createContact('John', 'Smith');
        Contact testContact2 = TestDataFactory.createContact('Jane', 'Doe');

        Contact_Relationship_Type__c relType = TestDataFactory.createContactRelationshipType(
            '#aabbcc',
            'label',
            true,
            true
        );

        Relationship_Map__c relMap = TestDataFactory.createRelationshipMap('mapName');
        TestDataFactory.createRelTypeMapAssociation(relMap, relType);
        Contact_Relationship__c cr1 = TestDataFactory.createContactRelationship(
            testContact1,
            testContact2,
            'one',
            relType.Id,
            null,
            relMap.Id
        );
        Contact_Relationship__c cr2 = TestDataFactory.createContactRelationship(
            testContact1,
            testContact2,
            'two',
            relType.Id,
            null,
            relMap.Id
        );

        List<Contact_Relationship__c> contactRelList = new List<Contact_Relationship__c>{ cr1, cr2 };

        List<Map_Member_Placeholder_Relationship__c> mapMemberList = new List<Map_Member_Placeholder_Relationship__c>();

        Map<String, List<CommonRelationshipLineObject>> result = RelationshipLineWrapperService.organizeMemberList(
            testContact1.Id,
            mapMemberList,
            contactRelList
        );

        System.assertEquals(1, result.keySet().size());
        System.assert(result.containsKey(relMap.Id));
        System.assertEquals(2, result.get(relMap.Id).size());
    }

    @isTest
    static void organizeMemberListTest2() {
        Contact c1 = TestDataFactory.createContact('john', 'smith');
        Contact c2 = TestDataFactory.createContact('jane', 'williams');
        Contact c3 = TestDataFactory.createContact('joe', 'smith');
        Contact c4 = TestDataFactory.createContact('al', 'cp');

        Contact_Relationship_Type__c relType = TestDataFactory.createContactRelationshipType(
            '#aabbcc',
            'label',
            true,
            true
        );

        Relationship_Map__c relMap = TestDataFactory.createRelationshipMap('mapName');

        Account_Plan__c ap = TestDataFactory.createAccountPlan('plan name');

        Map_Member_Placeholder_Relationship__c mmpr1 = new Map_Member_Placeholder_Relationship__c(
            To__c = c1.Id,
            From__c = c2.Id,
            Is_Hierarchy__c = true,
            Contact_Relationship_Type__c = relType.Id,
            Relationship_Map__c = relMap.Id
        );

        Map_Member_Placeholder_Relationship__c mmpr2 = new Map_Member_Placeholder_Relationship__c(
            To__c = c3.Id,
            From__c = c1.Id,
            Is_Hierarchy__c = true,
            Contact_Relationship_Type__c = relType.Id,
            Account_Plan__c = ap.Id
        );

        Map_Member_Placeholder_Relationship__c mmpr3 = new Map_Member_Placeholder_Relationship__c(
            To__c = c2.Id,
            From__c = c1.Id,
            Is_Hierarchy__c = true,
            Contact_Relationship_Type__c = relType.Id,
            Account_Plan__c = ap.Id
        );

        List<Contact_Relationship__c> contactRelList = new List<Contact_Relationship__c>();

        List<Map_Member_Placeholder_Relationship__c> mapMemberList = new List<Map_Member_Placeholder_Relationship__c>{
            mmpr1,
            mmpr2,
            mmpr3
        };

        Map<String, List<CommonRelationshipLineObject>> result = RelationshipLineWrapperService.organizeMemberList(
            c4.Id,
            mapMemberList,
            contactRelList
        );

        System.assertEquals(2, result.keySet().size());
        System.assert(result.containsKey(relMap.Id));
        System.assert(result.containsKey(ap.Id));
        System.assertEquals(1, result.get(relMap.Id).size());
        System.assertEquals(2, result.get(ap.Id).size());
    }
}