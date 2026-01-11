@IsTest
private class PostInstallHelperServiceTest {
    public static final String USER1_FIRST_NAME = 'admin';
    public static final String USER1_LAST_NAME = 'adam';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';
    public static final String STANDARD_USER = 'Standard User';

    @TestSetup
    static void testSetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];
        User adminAdam = TestDataFactory.createUser(USER1_FIRST_NAME, USER1_LAST_NAME, p.Id);
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];
        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = adminAdam.Id, PermissionSetId = adminUserPermissionSet.Id)
        };
    }

    @IsTest
    static void getMapMembersToUpdateTest() {
        Schema.DescribeFieldResult influenceFieldResult = SObjectType.Key_Stakeholder__c.fields.Influence__c;
        Schema.DescribeFieldResult supportFieldResult = SObjectType.Key_Stakeholder__c.fields.Support__c;
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        Relationship_Map_Member__c rmm1;
        Relationship_Map_Member__c rmm2;
        Relationship_Map_Member__c rmm3;
        Relationship_Map_Member__c rmm4;
        Relationship_Map_Member__c rmm5;
        System.runAs(admin) {
            pq_Influence__c inf = new pq_Influence__c(Name = 'Low', Label__c = 'lowlabel');
            pq_Support__c sup = new pq_Support__c(Name = 'Champion', Label__c = 'champlabel', Color__c = '#ff0011');
            Contact c1 = new Contact(LastName = 'postInstallC1', FirstName = 'c1First');
            Contact c2 = new Contact(LastName = 'postInstallC2', FirstName = 'c2First');
            Contact c3 = new Contact(LastName = 'postInstallC3', FirstName = 'c3First');
            Contact c4 = new Contact(LastName = 'postInstallC4', FirstName = 'c4First');
            Contact c5 = new Contact(LastName = 'postInstallC5', FirstName = 'c5First');
            insert new List<SObject>{ inf, sup, c1, c2, c3, c4, c5 };
            Relationship_Map__c rm = TestDataFactory.createRelationshipMap('mapName');
            rmm1 = new Relationship_Map_Member__c( //Already set - won't fetch
                Contact__c = c1.Id,
                Relationship_Map__c = rm.Id,
                Influence__c = influenceFieldResult.getPicklistValues().get(0).getValue(),
                Support__c = supportFieldResult.getPicklistValues().get(0).getValue(),
                InfluenceId__c = inf.Id,
                SupportId__c = sup.Id
            );
            rmm2 = new Relationship_Map_Member__c( //nothing to set - won't fetch
                Contact__c = c2.Id,
                Relationship_Map__c = rm.Id,
                Influence__c = null,
                Support__c = null,
                InfluenceId__c = null,
                SupportId__c = null
            );
            rmm3 = new Relationship_Map_Member__c( //nothing to set - won't fetch
                Contact__c = c3.Id,
                Relationship_Map__c = rm.Id,
                Influence__c = influenceFieldResult.getPicklistValues().get(0).getValue(),
                Support__c = null,
                InfluenceId__c = inf.Id,
                SupportId__c = null
            );
            rmm4 = new Relationship_Map_Member__c( //one to set - will fetch
                Contact__c = c4.Id,
                Relationship_Map__c = rm.Id,
                Influence__c = influenceFieldResult.getPicklistValues().get(0).getValue(),
                Support__c = supportFieldResult.getPicklistValues().get(0).getValue(),
                InfluenceId__c = null,
                SupportId__c = sup.Id
            );
            rmm5 = new Relationship_Map_Member__c( //all to set - will fetch
                Contact__c = c5.Id,
                Relationship_Map__c = rm.Id,
                Influence__c = influenceFieldResult.getPicklistValues().get(0).getValue(),
                Support__c = supportFieldResult.getPicklistValues().get(0).getValue(),
                InfluenceId__c = null,
                SupportId__c = null
            );
            insert new List<Relationship_Map_Member__c>{ rmm1, rmm2, rmm3, rmm4, rmm5 };
        }
        Set<Id> expectedIds = new Set<Id>{ rmm4.Id, rmm5.Id };

        List<Relationship_Map_Member__c> result = PostInstallHelperService.getMapMembersToUpdate();

        System.assertEquals(2, result.size(), 'Expected 2 members that need update');
        for (Relationship_Map_Member__c rmm : result) {
            System.assert(expectedIds.contains(rmm.Id), 'Expected member ' + rmm.Id + ' to be updated');
        }
    }

    @IsTest
    static void getStakeholdersToUpdateTest() {
        Schema.DescribeFieldResult influenceFieldResult = SObjectType.Key_Stakeholder__c.fields.Influence__c;
        Schema.DescribeFieldResult supportFieldResult = SObjectType.Key_Stakeholder__c.fields.Support__c;
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        Key_Stakeholder__c ks1;
        Key_Stakeholder__c ks2;
        Key_Stakeholder__c ks3;
        Key_Stakeholder__c ks4;
        Key_Stakeholder__c ks5;
        System.runAs(admin) {
            pq_Influence__c inf = new pq_Influence__c(Name = 'Low', Label__c = 'lowlabel');
            pq_Support__c sup = new pq_Support__c(Name = 'Champion', Label__c = 'champlabel', Color__c = '#ff0011');
            Contact c1 = new Contact(LastName = 'postInstallC1', FirstName = 'c1First');
            Contact c2 = new Contact(LastName = 'postInstallC2', FirstName = 'c2First');
            Contact c3 = new Contact(LastName = 'postInstallC3', FirstName = 'c3First');
            Contact c4 = new Contact(LastName = 'postInstallC4', FirstName = 'c4First');
            Contact c5 = new Contact(LastName = 'postInstallC5', FirstName = 'c5First');
            insert new List<SObject>{ inf, sup, c1, c2, c3, c4, c5 };
            Account_Plan__c accountPlan = TestDataFactory.createAccountPlan('my plan');
            ks1 = new Key_Stakeholder__c( //Already set - won't fetch
                Contact__c = c1.Id,
                Account_Plan__c = accountPlan.Id,
                Influence__c = influenceFieldResult.getPicklistValues().get(0).getValue(),
                Support__c = supportFieldResult.getPicklistValues().get(0).getValue(),
                InfluenceId__c = inf.Id,
                SupportId__c = sup.Id
            );
            ks2 = new Key_Stakeholder__c( //nothing to set - won't fetch
                Contact__c = c2.Id,
                Account_Plan__c = accountPlan.Id,
                Influence__c = null,
                Support__c = null,
                InfluenceId__c = null,
                SupportId__c = null
            );
            ks3 = new Key_Stakeholder__c( //nothing to set - won't fetch
                Contact__c = c3.Id,
                Account_Plan__c = accountPlan.Id,
                Influence__c = influenceFieldResult.getPicklistValues().get(0).getValue(),
                Support__c = null,
                InfluenceId__c = inf.Id,
                SupportId__c = null
            );
            ks4 = new Key_Stakeholder__c( //one to set - will fetch
                Contact__c = c4.Id,
                Account_Plan__c = accountPlan.Id,
                Influence__c = influenceFieldResult.getPicklistValues().get(0).getValue(),
                Support__c = supportFieldResult.getPicklistValues().get(0).getValue(),
                InfluenceId__c = null,
                SupportId__c = sup.Id
            );
            ks5 = new Key_Stakeholder__c( //all to set - will fetch
                Contact__c = c5.Id,
                Account_Plan__c = accountPlan.Id,
                Influence__c = influenceFieldResult.getPicklistValues().get(0).getValue(),
                Support__c = supportFieldResult.getPicklistValues().get(0).getValue(),
                InfluenceId__c = null,
                SupportId__c = null
            );
            insert new List<Key_Stakeholder__c>{ ks1, ks2, ks3, ks4, ks5 };
        }
        Set<Id> expectedIds = new Set<Id>{ ks4.Id, ks5.Id };

        List<Key_Stakeholder__c> result = PostInstallHelperService.getStakeholdersToUpdate();

        System.assertEquals(2, result.size(), 'Expected 2 stakeholders that need update');
        for (Key_Stakeholder__c ks : result) {
            System.assert(expectedIds.contains(ks.Id), 'Expected stakeholder ' + ks.Id + ' to be updated');
        }
    }

    @IsTest
    static void updateMapMembersInfleunceSupportNullMembersTest() {
        TestMockData md = new TestMockData();
        List<pq_Influence__c> infList = new List<pq_Influence__c>{ md.mockInfluence };
        List<pq_Support__c> supList = new List<pq_Support__c>{ md.mockSupport };

        Set<SObject> result = PostInstallHelperService.updateMapMembersInfleunceSupport(null, infList, supList);

        System.assertEquals(0, result.size(), 'Expected 0 members to be updated if null members passed');
    }

    @IsTest
    static void updateMapMembersInfleunceSupportEmptyMembersTest() {
        TestMockData md = new TestMockData();
        List<pq_Influence__c> infList = new List<pq_Influence__c>{ md.mockInfluence };
        List<pq_Support__c> supList = new List<pq_Support__c>{ md.mockSupport };

        Set<SObject> result = PostInstallHelperService.updateMapMembersInfleunceSupport(
            new List<SObject>(),
            infList,
            supList
        );

        System.assertEquals(0, result.size(), 'Expected 0 members to be updated if empty members passed');
    }

    @IsTest
    static void updateMapMembersInfleunceSupportNoMatchTest() {
        TestMockData md = new TestMockData();
        md.mockRelationshipMapMember.pqcrush__Influence__c = md.mockInfluence.Name + 'wrong';
        md.mockRelationshipMapMember.pqcrush__Support__c = md.mockSupport.Name + 'wrong';
        md.mockRelationshipMapMember.pqcrush__InfluenceId__c = null;
        md.mockRelationshipMapMember.pqcrush__SupportId__c = null;
        List<SObject> membersList = new List<SObject>{ md.mockRelationshipMapMember };
        List<pq_Influence__c> infList = new List<pq_Influence__c>{ md.mockInfluence };
        List<pq_Support__c> supList = new List<pq_Support__c>{ md.mockSupport };

        Set<SObject> result = PostInstallHelperService.updateMapMembersInfleunceSupport(membersList, infList, supList);

        System.assertEquals(0, result.size(), 'The member should not be updated if no match is found');
    }

    @IsTest
    static void updateMapMembersInfleunceSupportHappyPathTest() {
        TestMockData md = new TestMockData();
        md.mockRelationshipMapMember.pqcrush__Influence__c = md.mockInfluence.Name;
        md.mockRelationshipMapMember.pqcrush__Support__c = md.mockSupport.Name;
        md.mockRelationshipMapMember.pqcrush__InfluenceId__c = null;
        md.mockRelationshipMapMember.pqcrush__SupportId__c = null;
        List<SObject> membersList = new List<SObject>{ md.mockRelationshipMapMember };
        List<pq_Influence__c> infList = new List<pq_Influence__c>{ md.mockInfluence };
        List<pq_Support__c> supList = new List<pq_Support__c>{ md.mockSupport };

        Set<SObject> result = PostInstallHelperService.updateMapMembersInfleunceSupport(membersList, infList, supList);

        System.assertEquals(1, result.size(), 'The member should be returned with the updated values');

        Relationship_Map_Member__c updatedMember = null;
        for (SObject setElement : result) {
            updatedMember = (Relationship_Map_Member__c) setElement;
            break;
        }
        System.assertEquals(
            md.mockInfluence.Id,
            updatedMember.pqcrush__InfluenceId__c,
            'The influence should be updated'
        );
        System.assertEquals(md.mockSupport.Id, updatedMember.pqcrush__SupportId__c, 'The support should be updated');
    }

    @isTest
    static void executeBatchUpdateForRecordsTest() {
        Contact c1 = new Contact(LastName = 'postInstallC1', FirstName = 'c1First');
        insert c1;
        String expectedLastName = 'postInstallC1Updated';

        c1.lastName = expectedLastName;
        List<SObject> records = new List<SObject>{ c1 };
        List<Schema.SObjectType> objTypes = new List<Schema.SObjectType>{ Contact.getSObjectType() };

        Test.startTest();
        PostInstallHelperService.executeBatchUpdateForRecords(records, objTypes);
        Test.stopTest();

        Contact result = [SELECT Id, LastName FROM Contact WHERE Id = :c1.Id];
        System.assertEquals(expectedLastName, result.LastName, 'The last name should be updated');
    }

    @isTest
    static void executeBatchInsertForRecordsTest() {
        Contact c1 = new Contact(LastName = 'postInstallC1', FirstName = 'c1First');

        List<SObject> records = new List<SObject>{ c1 };
        List<Schema.SObjectType> objTypes = new List<Schema.SObjectType>{ Contact.getSObjectType() };

        Test.startTest();
        PostInstallHelperService.executeBatchInsertForRecords(records, objTypes);
        Test.stopTest();

        Contact result = [SELECT Id, LastName FROM Contact];
        System.assertNotEquals(null, result);
    }

    // Test no fields
    @IsTest
    static void getMapMembersToUpdateCustomFieldsTest1() {
        TestMockData md = new TestMockData();
        SObjectServiceImpl mockSObjectService = md.mockSObjectService;

        md.mocks.startStubbing();
        md.mocks.when(mockSObjectService.getCustomFields(Relationship_Map_Member__c.getSObjectType(), true))
            .thenReturn(new List<String>());
        md.mocks.when(mockSObjectService.getCustomFields(Key_Stakeholder__c.getSObjectType(), false))
            .thenReturn(new List<String>());
        md.mocks.stopStubbing();

        List<Relationship_Map_Member__c> result = PostInstallHelperService.getMapMembersToUpdateCustomFields();

        System.assertEquals(0, result.size(), 'Expected 0 returned if no updateable custom fields');
    }

    // Test valid fields
    @IsTest
    static void getMapMembersToUpdateCustomFieldsTest2() {
        User adminUser = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        System.runAs(adminUser) {
            Account testAccount = new Account(Name = 'Account 1');
            insert testAccount;

            Contact testContact1 = new Contact(LastName = 'FIRST_CONTACT_LAST_NAME');
            insert testContact1;

            pq_Influence__c i1 = new pq_Influence__c(Name = 'Low', Label__c = 'lowlabel');
            insert i1;
            pq_Support__c s1 = new pq_Support__c(Name = 'Champion', Label__c = 'champlabel', Color__c = '#ff0011');
            insert s1;

            Account_Plan__c accountPlan = TestDataFactory.createAccountPlan('ACCOUNT_PLAN_NAME', testAccount);
            Key_Stakeholder__c ks1 = TestDataFactory.createKeyStakeholder(accountPlan, testContact1, i1.Id, s1.Id);

            Relationship_Map__c rm = TestDataFactory.createRelationshipMap('my map');
            Relationship_Map_Member__c rmm = new Relationship_Map_Member__c(
                Contact__c = testContact1.Id,
                Relationship_Map__c = rm.Id,
                Original_Key_Stakeholder__c = ks1.Id
            );
            insert rmm;

            TestMockData md = new TestMockData();
            SObjectServiceImpl mockSObjectService = md.mockSObjectService;

            md.mocks.startStubbing();
            md.mocks.when(mockSObjectService.getCustomFields(Relationship_Map_Member__c.getSObjectType(), true))
                .thenReturn(new List<String>{ 'pqcrush__SupportId__c', 'pqcrush__Original_Key_Stakeholder__c' });
            md.mocks.when(mockSObjectService.getCustomFields(Key_Stakeholder__c.getSObjectType(), false))
                .thenReturn(new List<String>{ 'pqcrush__SupportId__c' });
            md.mocks.stopStubbing();

            List<Relationship_Map_Member__c> result = PostInstallHelperService.getMapMembersToUpdateCustomFields();
            System.assertEquals(1, result.size(), 'Expected 0 returned if no updateable custom fields');
            result[0].SupportId__c = s1.Id;
        }
    }

    @IsTest
    static void getRecordCountForKSMapConversionTest() {
        TestDataFactory.createAccountPlan('grcfksct_Test_Plan');
        Integer result = PostInstallHelperService.getRecordCountForKSMapConversion();
        System.assertEquals(1, result, 'Should return 1');
    }

    @IsTest
    static void getQueryForKSMapConversionTest() {
        Query result = PostInstallHelperService.getQueryForKSMapConversion();
        System.assertEquals(
            'SELECT id, name FROM pqcrush__Account_Plan__c WHERE (Id NOT IN (SELECT pqcrush__pq_accountplanid__c FROM pqcrush__Relationship_Map__c))',
            result.toQueryString(),
            'Should return expected query'
        );
    }
}