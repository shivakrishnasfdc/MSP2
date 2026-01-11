@isTest
public with sharing class KeyDatesTest {
    public static final String OWNER_LAST_NAME = 'owneruser';
    public static final String TEAM_MEMBER_LAST_NAME = 'teammemberuser';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User owner = TestDataFactory.createUser('user', OWNER_LAST_NAME, standardProfile.Id);
        User teamMember = TestDataFactory.createUser('user', TEAM_MEMBER_LAST_NAME, standardProfile.Id);

        PermissionSet creatorUserPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'CRUSH_Account_Plan_Creator'
        ];
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'CRUSH_Administrator'];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = teamMember.Id, PermissionSetId = creatorUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = owner.Id, PermissionSetId = adminUserPermissionSet.Id)
        };

        System.runAs(owner) {
            Account testAccount = new Account(Name = 'Account 1');
            insert testAccount;

            AccountPlans.bypassEmailTrigger = true;
            KeyDates.bypassEmailTrigger = true;

            Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan('account plan 1', testAccount, 'Open');
            TestDataFactory.createAccountPlanShare(teamMember, accountPlan1, 'Read', 'Manual');

            Key_Date__c keyDate = new Key_Date__c(Account_Plan__c = accountPlan1.Id, Date__c = Date.today());
            insert keyDate;

            accountPlan1.Status__c = 'Closed';
            update accountPlan1;
        }
    }

    @isTest
    static void teamMemberInsertKeyDate() {
        // Given
        User teamMember = [SELECT Id FROM User WHERE LastName = :TEAM_MEMBER_LAST_NAME];
        Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c];
        AccountPlans.bypassEmailTrigger = true;
        KeyDates.bypassEmailTrigger = true;

        // When
        Test.startTest();

        Key_Date__c keyDate = new Key_Date__c(Account_Plan__c = accountPlan.Id, Date__c = Date.today());
        Database.SaveResult saveResult;

        System.runAs(teamMember) {
            saveResult = Database.insert(new List<Key_Date__c>{ keyDate }, false)[0];
        }

        Test.stopTest();

        // Then
        List<Database.Error> errors = saveResult.getErrors();
        Account_Plan__c updatedAccountPlan = [SELECT Id, Status__c FROM Account_Plan__c];

        System.assertEquals('Closed', updatedAccountPlan.Status__c);
        System.assertEquals(false, saveResult.isSuccess());
        System.assertEquals(1, errors.size());
        System.assertEquals(System.Label.error_closed_account_plan_related_items, errors[0].getMessage());
    }

    @isTest
    static void ownerInsertKeyDate() {
        // Given
        User owner = [SELECT Id FROM User WHERE LastName = :OWNER_LAST_NAME];
        Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c];
        AccountPlans.bypassEmailTrigger = true;
        KeyDates.bypassEmailTrigger = true;

        // When
        Test.startTest();

        Key_Date__c keyDate = new Key_Date__c(Account_Plan__c = accountPlan.Id, Date__c = Date.today());
        Database.SaveResult saveResult;

        System.runAs(owner) {
            saveResult = Database.insert(new List<Key_Date__c>{ keyDate }, false)[0];
        }

        Test.stopTest();

        // Then
        List<Database.Error> errors = saveResult.getErrors();
        Account_Plan__c updatedAccountPlan = [SELECT Id, Status__c FROM Account_Plan__c];

        System.assertEquals('Open', updatedAccountPlan.Status__c);
        System.assertEquals(true, saveResult.isSuccess());
        System.assertEquals(0, errors.size());
    }

    @isTest
    static void ownerUpdateKeyDate() {
        // Given
        User owner = [SELECT Id FROM User WHERE LastName = :OWNER_LAST_NAME];
        Key_Date__c keyDate = [SELECT Id, Date__c FROM Key_Date__c];
        AccountPlans.bypassEmailTrigger = true;
        KeyDates.bypassEmailTrigger = true;

        // When
        Test.startTest();

        Database.SaveResult saveResult;
        keyDate.Date__c = Date.today().addDays(1);

        System.runAs(owner) {
            saveResult = Database.update(new List<Key_Date__c>{ keyDate }, false)[0];
        }

        Test.stopTest();

        // Then
        List<Database.Error> errors = saveResult.getErrors();
        Account_Plan__c updatedAccountPlan = [SELECT Id, Status__c FROM Account_Plan__c];

        System.assertEquals('Open', updatedAccountPlan.Status__c);
        System.assertEquals(true, saveResult.isSuccess());
        System.assertEquals(0, errors.size());
    }

    @isTest
    static void ownerDeleteKeyDate() {
        // Given
        User owner = [SELECT Id FROM User WHERE LastName = :OWNER_LAST_NAME];
        Key_Date__c keyDate = [SELECT Id, Date__c FROM Key_Date__c];
        AccountPlans.bypassEmailTrigger = true;
        KeyDates.bypassEmailTrigger = true;

        // When
        Test.startTest();

        Database.DeleteResult deleteResult;

        System.runAs(owner) {
            deleteResult = Database.delete(new List<Key_Date__c>{ keyDate }, false)[0];
        }

        Test.stopTest();

        // Then
        List<Database.Error> errors = deleteResult.getErrors();
        Account_Plan__c updatedAccountPlan = [SELECT Id, Status__c FROM Account_Plan__c];

        System.assertEquals('Open', updatedAccountPlan.Status__c);
        System.assertEquals(true, deleteResult.isSuccess());
        System.assertEquals(0, errors.size());
    }

    //@isTest
    //static void onAfterInsertSendEmailTest() {
    //    // Mocks
    //    fflib_ApexMocks mocks = new fflib_ApexMocks();
    //    SendEmailNotificationsImpl mockService = (SendEmailNotificationsImpl) mocks.mock(SendEmailNotificationsImpl.class);
    //    Application.Service.setMock(SendEmailNotificationsImpl.class, mockService);

    //    Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);

    //    List<Key_Date__c> updatedRecords = new List<Key_Date__c> {
    //        new Key_Date__c(
    //            Account_Plan__c = accountPlanId
    //        )
    //    };

    //    Boolean updateAll = true;
    //    Boolean updateOwner = true;

    //    CRUSH_Settings_Obj__c orgSettings = new CRUSH_Settings_Obj__c(
    //        Type__c = 'Org',
    //        Enable_Notifications__c = true
    //    );
    //    upsert orgSettings;

    //    List<SendEmailNotifications.SendEmailRequest> emailRequests = new List<SendEmailNotifications.SendEmailRequest>();
    //    SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();
    //    request.accountPlanId = accountPlanId;
    //    request.teamMemberUserId = UserInfo.getUserId();
    //    request.eventType = 'Key_Dates_Is_Updated';
    //    emailRequests.add(request);

    //    User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    //    System.runAs(systemUser) {
    //        KeyDates.newInstance(updatedRecords).onAfterInsert();
    //        ((SendEmailNotificationsImpl) mocks.verify(mockService, 1)).sendEmails(emailRequests);
    //    }
    //}
}