@isTest
private class SendEmailNotificationsTest {
    private static final String USER1_LASTNAME = '1';
    private static final String USER2_LASTNAME = '2';
    private static final String USER3_LASTNAME = '3';
    private static final String ACCOUNT_PLAN1_NAME = 'Account Plan 1';
    private static final String ACCOUNT_PLAN2_NAME = 'Account Plan 2';
    private static final String EMAIL_TEMPLATE = 'mytemplate';

    @testSetup
    static void testSetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User user1 = TestDataFactory.createUser('User', USER1_LASTNAME, p.Id);
        User user2 = TestDataFactory.createUser('User', USER2_LASTNAME, p.Id);

        PermissionSet creatorUserPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'CRUSH_Account_Plan_Creator'
        ];
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'CRUSH_Administrator'];

        List<PermissionSetAssignment> permissionSets = new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = user1.Id, PermissionSetId = creatorUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = user2.Id, PermissionSetId = creatorUserPermissionSet.Id)
        };

        PermissionSetAssignment adminAssignment = TestDataFactory.createPermissionSetAssignment(
            UserInfo.getUserId(),
            adminUserPermissionSet.Id
        );
        if (adminAssignment != null) {
            permissionSets.add(adminAssignment);
        }

        insert permissionSets;

        EmailTemplate email = TestDataFactory.createEmailTemplate(EMAIL_TEMPLATE);
        insert email;

        System.runAs(user1) {
            Account a = new Account(Name = 'Account 1');
            insert a;

            Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan(ACCOUNT_PLAN1_NAME, a);
            TestDataFactory.createTeamMember(user2, accountPlan1, 'Edit');
        }
    }

    @isTest
    static void sendEmailTest() {
        // Given
        SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();

        List<Account_Plan__c> accountPlanRecords = [SELECT Id, OwnerId, Status__c FROM Account_Plan__c];

        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        request.accountPlanId = accountPlanRecords[0].Id;
        request.eventType = EMAIL_TEMPLATE;

        System.runAs(systemUser) {
            // When
            try {
                SendEmailNotifications.sendEmails(new List<SendEmailNotifications.SendEmailRequest>{ request });
            } catch (Exception e) {
                System.assert(false);
            }
        }
    }

    @isTest
    static void sendEmailTest2() {
        // Given
        SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();

        List<Account_Plan__c> accountPlanRecords = [SELECT Id, OwnerId, Status__c FROM Account_Plan__c];

        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        request.accountPlanId = accountPlanRecords[0].Id;
        request.eventType = EMAIL_TEMPLATE;

        System.runAs(systemUser) {
            // When
            try {
                SendEmailNotifications.sendEmails(new List<SendEmailNotifications.SendEmailRequest>{ request });
            } catch (Exception e) {
                System.assert(false);
            }
        }
    }

    @isTest
    static void sendEmailTest3() {
        // Given
        SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();

        List<Account_Plan__c> accountPlanRecords = [SELECT Id, OwnerId, Status__c FROM Account_Plan__c];

        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        request.accountPlanId = accountPlanRecords[0].Id;
        request.eventType = EMAIL_TEMPLATE;

        System.runAs(systemUser) {
            // When
            try {
                SendEmailNotifications.sendEmails(new List<SendEmailNotifications.SendEmailRequest>{ request });
            } catch (Exception e) {
                System.assert(false);
            }
        }
    }

    @isTest
    static void sendEmailTest4() {
        // Given
        SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();

        List<Account_Plan__c> accountPlanRecords = [SELECT Id, OwnerId, Status__c FROM Account_Plan__c];

        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        request.accountPlanId = accountPlanRecords[0].Id;
        request.eventType = EMAIL_TEMPLATE;

        System.runAs(systemUser) {
            // When
            try {
                SendEmailNotifications.sendEmails(new List<SendEmailNotifications.SendEmailRequest>{ request });
            } catch (Exception e) {
                System.assert(false);
            }
        }
    }

    @isTest
    static void sendEmailTest5() {
        // Given
        SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();

        List<Account_Plan__c> accountPlanRecords = [SELECT Id, OwnerId, Status__c FROM Account_Plan__c];

        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        request.accountPlanId = accountPlanRecords[0].Id;
        request.eventType = EMAIL_TEMPLATE;

        System.runAs(systemUser) {
            // When
            try {
                SendEmailNotifications.sendEmails(new List<SendEmailNotifications.SendEmailRequest>{ request });
            } catch (Exception e) {
                System.assert(false);
            }
        }
    }

    @isTest
    static void sendEmailTest6() {
        // Given
        SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();

        List<Account_Plan__c> accountPlanRecords = [SELECT Id, OwnerId, Status__c FROM Account_Plan__c];

        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        request.accountPlanId = accountPlanRecords[0].Id;
        request.eventType = EMAIL_TEMPLATE;

        System.runAs(systemUser) {
            // When
            try {
                SendEmailNotifications.sendEmails(new List<SendEmailNotifications.SendEmailRequest>{ request });
            } catch (Exception e) {
                System.assert(false);
            }
        }
    }

    @isTest
    static void sendEmailTest7() {
        // Given
        SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();

        List<Account_Plan__c> accountPlanRecords = [SELECT Id, OwnerId, Status__c FROM Account_Plan__c];

        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        request.accountPlanId = accountPlanRecords[0].Id;
        request.eventType = EMAIL_TEMPLATE;

        System.runAs(systemUser) {
            // When
            try {
                SendEmailNotifications.sendEmails(new List<SendEmailNotifications.SendEmailRequest>{ request });
            } catch (Exception e) {
                System.assert(false);
            }
        }
    }

    @isTest
    static void sendEmailTest8() {
        // Given
        SendEmailNotifications.SendEmailRequest request = new SendEmailNotifications.SendEmailRequest();

        List<Account_Plan__c> accountPlanRecords = [SELECT Id, OwnerId, Status__c FROM Account_Plan__c];

        User systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        request.accountPlanId = accountPlanRecords[0].Id;
        request.eventType = EMAIL_TEMPLATE;

        System.runAs(systemUser) {
            // When
            try {
                SendEmailNotifications.sendEmails(new List<SendEmailNotifications.SendEmailRequest>{ request });
            } catch (Exception e) {
                System.assert(false);
            }
        }
    }
}