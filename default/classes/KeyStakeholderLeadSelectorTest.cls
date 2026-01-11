@isTest
private class KeyStakeholderLeadSelectorTest {
    public static final String ADMIN_USER1_FIRST_NAME = 'AmyAdmin1';
    public static final String ADMIN_USER1_LAST_NAME = 'Arlie';

    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';
    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User adminUser1 = TestDataFactory.createUser(ADMIN_USER1_FIRST_NAME, ADMIN_USER1_LAST_NAME, standardProfile.Id);

        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];

        // Assigning two users with the admin perm set and one user with the standard perm set
        List<PermissionSetAssignment> permissionSets = new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = adminUser1.Id, PermissionSetId = adminUserPermissionSet.Id)
        };

        Id systemUserId = UserInfo.getUserId();
        PermissionSetAssignment systemCrushAdminPermissions = TestDataFactory.createPermissionSetAssignment(
            systemUserId,
            adminUserPermissionSet.Id
        );

        if (systemCrushAdminPermissions != null) {
            permissionSets.add(systemCrushAdminPermissions);
        }
        insert permissionSets;

        // Disabling triggers as this class should not be testing them
        Application.bypassTrigger = true;
    }

    @isTest
    static void newInstanceTest() {
        KeyStakeholderLeadSelector selector = KeyStakeholderLeadSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];

        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;

        Account_Plan__c ap = TestDataFactory.createAccountPlan('My Plan', testAccount);
        Lead l1 = TestDataFactory.createLead('john', 'smith', 'ACME');
        Lead l2 = TestDataFactory.createLead('john2', 'smith2', 'ACME');

        Key_Stakeholder_Lead__c ksl1 = TestDataFactory.createKeyStakeholderLead(ap, l1);
        TestDataFactory.createKeyStakeholderLead(ap, l2);

        System.runAs(adminUser1) {
            List<Key_Stakeholder_Lead__c> result = KeyStakeholderLeadSelector.newInstance()
                .selectById(new Set<Id>{ ksl1.Id });

            System.assertEquals(1, result.size());
            System.assertEquals(ksl1.Id, result[0].Id);
        }
    }

    @isTest
    static void selectByLeadIdTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];

        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;

        Account_Plan__c ap = TestDataFactory.createAccountPlan('My Plan', testAccount);
        Lead l1 = TestDataFactory.createLead('john', 'smith', 'ACME');
        Lead l2 = TestDataFactory.createLead('john2', 'smith2', 'ACME');

        Key_Stakeholder_Lead__c ksl1 = TestDataFactory.createKeyStakeholderLead(ap, l1);
        TestDataFactory.createKeyStakeholderLead(ap, l2);

        System.runAs(adminUser1) {
            List<Key_Stakeholder_Lead__c> result = KeyStakeholderLeadSelector.newInstance()
                .selectByLeadId(new Set<Id>{ l1.Id });

            System.assertEquals(1, result.size());
            System.assertEquals(ksl1.Id, result[0].Id);
        }
    }

    @isTest
    static void selectByAccountPlansTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];

        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;

        Account_Plan__c ap = TestDataFactory.createAccountPlan('My Plan', testAccount);
        Lead l1 = TestDataFactory.createLead('john', 'smith', 'ACME');
        Lead l2 = TestDataFactory.createLead('john2', 'smith2', 'ACME');

        Account_Plan__c ap2 = TestDataFactory.createAccountPlan('My Plan 2', testAccount);
        Lead l3 = TestDataFactory.createLead('john3', 'smith3', 'ACME');

        TestDataFactory.createKeyStakeholderLead(ap, l1);
        TestDataFactory.createKeyStakeholderLead(ap, l2);
        TestDataFactory.createKeyStakeholderLead(ap2, l3);

        System.runAs(adminUser1) {
            List<Key_Stakeholder_Lead__c> result = KeyStakeholderLeadSelector.newInstance()
                .selectByAccountPlans(new Set<Id>{ ap.Id });

            System.assertEquals(2, result.size());
        }
    }

    @isTest
    static void selectConvertedLeadsByRelationshipMapsTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];

        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;

        Account_Plan__c ap = TestDataFactory.createAccountPlan('My Plan', testAccount);
        Lead l1 = TestDataFactory.createLead('john', 'smith', 'ACME');
        Lead l2 = TestDataFactory.createLead('john2', 'smith2', 'ACME');

        Account_Plan__c ap2 = TestDataFactory.createAccountPlan('My Plan 2', testAccount);
        Lead l3 = TestDataFactory.createLead('john2', 'smith2', 'ACME');

        Key_Stakeholder_Lead__c ksl1 = TestDataFactory.createKeyStakeholderLead(ap, l1);
        TestDataFactory.createKeyStakeholderLead(ap, l2);
        TestDataFactory.createKeyStakeholderLead(ap2, l3);

        // Convert Lead
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(l1.id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Closed - Converted');

        Database.LeadConvertResult l1Converted = Database.convertLead(lc);
        System.assert(l1Converted.isSuccess());

        System.runAs(adminUser1) {
            List<Key_Stakeholder_Lead__c> result = KeyStakeholderLeadSelector.newInstance()
                .selectConvertedLeadsByAccountPlans(new Set<Id>{ ap.Id });

            System.assertEquals(1, result.size());
            System.assertEquals(ksl1.Id, result[0].Id);
        }
    }
}