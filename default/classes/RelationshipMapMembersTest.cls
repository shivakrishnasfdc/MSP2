@isTest
private with sharing class RelationshipMapMembersTest {
    private static final String RELATIONSHIP_MAP_NAME = 'RelationshipMapMembersTest test hierarchy group 1';
    private static final String FIRST_CONTACT_LAST_NAME = 'RelationshipMapMembersTest contact lastName 1';
    private static final String SECOND_CONTACT_LAST_NAME = 'RelationshipMapMembersTest contact lastName 2';

    public static final String ADMIN_USER_FIRST_NAME = 'rmm test admin user first';
    public static final String ADMIN_USER_LAST_NAME = 'rmm test admin user last';

    public static final String PRM_ADMIN_PERM = 'PROLIFIQ_RELATIONSHIP_MAP';

    public static final String STANDARD_USER = 'Standard User';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];
        User adminUser = TestDataFactory.createUser(ADMIN_USER_FIRST_NAME, ADMIN_USER_LAST_NAME, standardProfile.Id);
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :PRM_ADMIN_PERM LIMIT 1];
        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = adminUserPermissionSet.Id)
        };

        System.runAs(adminUser) {
            Relationship_Map__c relationshipMap = TestDataFactory.createRelationshipMap(RELATIONSHIP_MAP_NAME);

            Contact contact1 = new Contact(LastName = FIRST_CONTACT_LAST_NAME);
            insert contact1;

            Contact contact2 = new Contact(LastName = SECOND_CONTACT_LAST_NAME);
            insert contact2;

            TestDataFactory.createRelationshipMapMember(relationshipMap.Id, contact1.Id);
            TestDataFactory.createRelationshipMapMember(relationshipMap.Id, contact2.Id);
        }
    }

    @isTest
    static void constructorTest() {
        System.assertNotEquals(null, new RelationshipMapMembers(new List<Relationship_Map_Member__c>()));
        System.assertEquals(
            false,
            new RelationshipMapMembers(new List<Relationship_Map_Member__c>())
                .Configuration.EnforcingTriggerCRUDSecurity,
            'Should not be enforcing Trigger CRUD Security due to complications with automation in customer orgs'
        );
    }

    /************************************
     *** getUniqueKey() ***
     ***********************************/

    @isTest
    static void getUniqueKeyTest() {
        // Given Happy Path
        String chmString =
            '{"Relationship_Map__c": "' +
            fflib_IDGenerator.generate(pqcrush__Relationship_Map__c.SObjectType) +
            '", "Contact__c": "' +
            fflib_IDGenerator.generate(Contact.SObjectType) +
            '"}'; //These fields not writeable
        Relationship_Map_Member__c member = (Relationship_Map_Member__c) JSON.deserialize(
            chmString,
            Relationship_Map_Member__c.class
        );

        // When
        String uniqueKey = RelationshipMapMembers.getUniqueKey(member);

        // Then
        String expectedValue = String.valueOf(member.Relationship_Map__c) + String.valueOf(member.Contact__c);
        System.assertEquals(expectedValue, uniqueKey);

        // Given null Contact
        chmString =
            '{"Relationship_Map__c": "' +
            fflib_IDGenerator.generate(pqcrush__Relationship_Map__c.SObjectType) +
            '", "Contact__c": null }'; //These fields not writeable
        member = (Relationship_Map_Member__c) JSON.deserialize(chmString, Relationship_Map_Member__c.class);

        // When
        uniqueKey = RelationshipMapMembers.getUniqueKey(member);

        // Then
        expectedValue = String.valueOf(member.Relationship_Map__c) + String.valueOf(member.Contact__c);
        System.assertEquals(expectedValue, uniqueKey);

        // Given null Group
        chmString =
            '{"Relationship_Map__c": null, "Contact__c": "' +
            fflib_IDGenerator.generate(Contact.SObjectType) +
            '"}'; //These fields not writeable
        member = (Relationship_Map_Member__c) JSON.deserialize(chmString, Relationship_Map_Member__c.class);

        // When
        uniqueKey = RelationshipMapMembers.getUniqueKey(member);

        // Then
        expectedValue = String.valueOf(member.Relationship_Map__c) + String.valueOf(member.Contact__c);
        System.assertEquals(expectedValue, uniqueKey);

        // Given null Contact and Group
        chmString = '{"Relationship_Map__c": null, "Contact__c": null }';
        member = (Relationship_Map_Member__c) JSON.deserialize(chmString, Relationship_Map_Member__c.class);

        // When
        uniqueKey = RelationshipMapMembers.getUniqueKey(member);

        // Then
        expectedValue = String.valueOf(member.Relationship_Map__c) + String.valueOf(member.Contact__c);
        System.assertEquals(expectedValue, uniqueKey);
    }

    /***************************
     *** onValidate() Update ***
     **************************/

    @isTest
    static void onValidateUpdateInvalidTest() {
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];
        Database.saveResult saveResult;
        System.runAs(adminUser) {
            // Given
            Relationship_Map__c relationshipMap = [
                SELECT Id
                FROM Relationship_Map__c
                WHERE Name = :RELATIONSHIP_MAP_NAME
            ];
            Contact testContact1 = [SELECT Id FROM Contact WHERE LastName = :FIRST_CONTACT_LAST_NAME];
            Contact testContact2 = [SELECT Id FROM Contact WHERE LastName = :SECOND_CONTACT_LAST_NAME];
            Relationship_Map_Member__c duplicateMember = [
                SELECT Id, Relationship_Map__c, Contact__c
                FROM Relationship_Map_Member__c
                WHERE Relationship_Map__c = :relationshipMap.Id AND Contact__c = :testContact1.Id
            ];
            duplicateMember.Contact__c = testContact2.Id;

            // When
            Test.startTest();

            RelationshipMapMembers membersClass = RelationshipMapMembers.newInstance(
                new List<Relationship_Map_Member__c>{ duplicateMember }
            );
            membersClass.onValidate();
            saveResult = Database.update(membersClass.getRecords(), false)[0];

            Test.stopTest();
        }

        // Then
        List<Database.Error> errors = saveResult.getErrors();

        System.assertEquals(false, saveResult.isSuccess());
        System.assertEquals(1, errors.size());
        System.assertEquals(System.Label.error_duplicate_hierarchy_member, errors[0].getMessage());
    }

    @isTest
    static void onValidateUpdateValidTest() {
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];
        Database.saveResult saveResult;
        System.runAs(adminUser) {
            // Given
            Relationship_Map__c relationshipMap = [
                SELECT Id
                FROM Relationship_Map__c
                WHERE Name = :RELATIONSHIP_MAP_NAME
            ];
            Contact existingContact = [SELECT Id FROM Contact WHERE LastName = :FIRST_CONTACT_LAST_NAME];
            Contact testContact = new Contact(LastName = 'onValidateInsertInvalidTest new contact');
            insert testContact;

            Relationship_Map_Member__c nonDuplicateMember = [
                SELECT Id, Relationship_Map__c, Contact__c
                FROM Relationship_Map_Member__c
                WHERE Relationship_Map__c = :relationshipMap.Id AND Contact__c = :existingContact.Id
            ];
            nonDuplicateMember.Contact__c = testContact.Id;

            // When
            Test.startTest();

            RelationshipMapMembers membersClass = RelationshipMapMembers.newInstance(
                new List<Relationship_Map_Member__c>{ nonDuplicateMember }
            );
            membersClass.onValidate();
            saveResult = Database.update(membersClass.getRecords(), false)[0];

            Test.stopTest();
        }

        // Then
        List<Database.Error> errors = saveResult.getErrors();

        System.assertEquals(true, saveResult.isSuccess());
        System.assertEquals(0, errors.size());
    }

    /***************************
     *** onValidate() Insert ***
     **************************/

    @isTest
    static void onValidateInsertInvalidTest() {
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];
        Database.saveResult saveResult;
        System.runAs(adminUser) {
            // Given
            Relationship_Map__c relationshipMap = [
                SELECT Id
                FROM Relationship_Map__c
                WHERE Name = :RELATIONSHIP_MAP_NAME
            ];
            Contact testContact = [SELECT Id FROM Contact WHERE LastName = :FIRST_CONTACT_LAST_NAME];

            Relationship_Map_Member__c duplicateMember = new Relationship_Map_Member__c(
                Relationship_Map__c = relationshipMap.Id,
                Contact__c = testContact.Id,
                Influence__c = 'High',
                Support__c = 'Floater'
            );

            // When
            Test.startTest();

            RelationshipMapMembers membersClass = RelationshipMapMembers.newInstance(
                new List<Relationship_Map_Member__c>{ duplicateMember }
            );
            membersClass.onValidate();
            saveResult = Database.insert(membersClass.getRecords(), false)[0];

            Test.stopTest();
        }

        // Then
        List<Database.Error> errors = saveResult.getErrors();

        System.assertEquals(false, saveResult.isSuccess());
        System.assertEquals(1, errors.size());
        System.assertEquals(System.Label.error_duplicate_hierarchy_member, errors[0].getMessage());
    }

    @isTest
    static void onValidateInsertValidTest() {
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];
        Database.saveResult saveResult;
        System.runAs(adminUser) {
            // Given
            Relationship_Map__c relationshipMap = [
                SELECT Id
                FROM Relationship_Map__c
                WHERE Name = :RELATIONSHIP_MAP_NAME
            ];
            Contact testContact = new Contact(LastName = 'onValidateInsertInvalidTest new contact');
            insert testContact;

            Relationship_Map_Member__c nonDuplicateMember = new Relationship_Map_Member__c(
                Relationship_Map__c = relationshipMap.Id,
                Contact__c = testContact.Id,
                Influence__c = 'High',
                Support__c = 'Floater'
            );

            // When
            Test.startTest();

            RelationshipMapMembers membersClass = RelationshipMapMembers.newInstance(
                new List<Relationship_Map_Member__c>{ nonDuplicateMember }
            );
            membersClass.onValidate();
            saveResult = Database.insert(membersClass.getRecords(), false)[0];

            Test.stopTest();
        }

        // Then
        List<Database.Error> errors = saveResult.getErrors();

        System.assertEquals(true, saveResult.isSuccess());
        System.assertEquals(0, errors.size());
    }

    /********************
     *** sendEmails() ***
     *******************/

    @isTest
    static void sendEmailAllNotificationsDisabledTest() {
        TestMockData md = new TestMockData();
        SendEmailNotificationsImpl mockEmailService = md.mockSendEmailNotificationsService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        RelationshipMapSelector mockRelationshipMapSelector = md.mockRelationshipMapSelector;

        md.mockSettings.Enable_Notifications__c = false;
        md.mockSettings.Key_Stakeholder_Updated__c = true;

        md.mockRelationshipMap.pq_AccountPlanId__c = md.mockAccountPlanId;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(mockRelationshipMapSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.stopStubbing();

        List<Relationship_Map_Member__c> memberList = new List<Relationship_Map_Member__c>{
            md.mockRelationshipMapMember
        };

        RelationshipMapMembers.newInstance(memberList).onAfterInsert();
        ((SendEmailNotificationsImpl) md.mocks.verify(mockEmailService, 0))
            .sendEmails((List<SendEmailNotifications.SendEmailRequest>) fflib_match.anyList());
        System.assert(true, 'Test verified via mock verification');
    }

    @isTest
    static void sendEmailStakeholderNotificationsDisabledTest() {
        TestMockData md = new TestMockData();
        SendEmailNotificationsImpl mockEmailService = md.mockSendEmailNotificationsService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        RelationshipMapSelector mockRelationshipMapSelector = md.mockRelationshipMapSelector;

        md.mockSettings.Enable_Notifications__c = true;
        md.mockSettings.Key_Stakeholder_Updated__c = false;

        md.mockRelationshipMap.pq_AccountPlanId__c = md.mockAccountPlanId;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(mockRelationshipMapSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.stopStubbing();

        List<Relationship_Map_Member__c> memberList = new List<Relationship_Map_Member__c>{
            md.mockRelationshipMapMember
        };

        RelationshipMapMembers.newInstance(memberList).onAfterInsert();
        ((SendEmailNotificationsImpl) md.mocks.verify(mockEmailService, 0))
            .sendEmails((List<SendEmailNotifications.SendEmailRequest>) fflib_match.anyList());
        System.assert(true, 'Test verified via mock verification');
    }

    @isTest
    static void sendEmailNoMapPlanTest() {
        TestMockData md = new TestMockData();
        SendEmailNotificationsImpl mockEmailService = md.mockSendEmailNotificationsService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        RelationshipMapSelector mockRelationshipMapSelector = md.mockRelationshipMapSelector;

        md.mockSettings.Enable_Notifications__c = true;
        md.mockSettings.Key_Stakeholder_Updated__c = true;

        md.mockRelationshipMap.pq_AccountPlanId__c = null;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(mockRelationshipMapSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.stopStubbing();

        List<Relationship_Map_Member__c> memberList = new List<Relationship_Map_Member__c>{
            md.mockRelationshipMapMember
        };

        RelationshipMapMembers.newInstance(memberList).onAfterInsert();
        ((SendEmailNotificationsImpl) md.mocks.verify(mockEmailService, 0))
            .sendEmails((List<SendEmailNotifications.SendEmailRequest>) fflib_match.anyList());
        System.assert(true, 'Test verified via mock verification');
    }

    @isTest
    static void onAfterInsertSendEmailTest() {
        TestMockData md = new TestMockData();
        SendEmailNotificationsImpl mockEmailService = md.mockSendEmailNotificationsService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        RelationshipMapSelector mockRelationshipMapSelector = md.mockRelationshipMapSelector;

        md.mockSettings.Enable_Notifications__c = true;
        md.mockSettings.Key_Stakeholder_Updated__c = true;

        md.mockRelationshipMap.pq_AccountPlanId__c = md.mockAccountPlanId;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(mockRelationshipMapSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.stopStubbing();

        List<Relationship_Map_Member__c> memberList = new List<Relationship_Map_Member__c>{
            md.mockRelationshipMapMember
        };

        RelationshipMapMembers.newInstance(memberList).onAfterInsert();
        ((SendEmailNotificationsImpl) md.mocks.verify(mockEmailService, 1))
            .sendEmails((List<SendEmailNotifications.SendEmailRequest>) fflib_match.anyList());
        System.assert(true, 'Test verified via mock verification');
    }

    @isTest
    static void onAfterUpdateSendEmailTest() {
        TestMockData md = new TestMockData();
        SendEmailNotificationsImpl mockEmailService = md.mockSendEmailNotificationsService;
        SettingServiceImpl mockSettingService = md.mockSettingService;
        RelationshipMapSelector mockRelationshipMapSelector = md.mockRelationshipMapSelector;

        md.mockSettings.Enable_Notifications__c = true;
        md.mockSettings.Key_Stakeholder_Updated__c = true;

        md.mockRelationshipMap.pq_AccountPlanId__c = md.mockAccountPlanId;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.when(mockRelationshipMapSelector.selectByIds(new Set<Id>{ md.mockRelationshipMapId }))
            .thenReturn(new List<Relationship_Map__c>{ md.mockRelationshipMap });
        md.mocks.stopStubbing();

        List<Relationship_Map_Member__c> memberList = new List<Relationship_Map_Member__c>{
            md.mockRelationshipMapMember
        };
        Map<Id, Relationship_Map_Member__c> memberMap = new Map<Id, Relationship_Map_Member__c>{
            md.mockRelationshipMapMemberId => md.mockRelationshipMapMember
        };

        RelationshipMapMembers.newInstance(memberList).onAfterUpdate(memberMap);
        ((SendEmailNotificationsImpl) md.mocks.verify(mockEmailService, 1))
            .sendEmails((List<SendEmailNotifications.SendEmailRequest>) fflib_match.anyList());
        System.assert(true, 'Test verified via mock verification');
    }
}