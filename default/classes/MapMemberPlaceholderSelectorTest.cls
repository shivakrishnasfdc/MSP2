@isTest
private class MapMemberPlaceholderSelectorTest {
    public static final String ADMIN_USER1_FIRST_NAME = 'SamStandard';
    public static final String ADMIN_USER1_LAST_NAME = 'Sunlock';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    public static final String LABEL1 = 'Boo1';
    public static final String LABEL2 = 'Boo2';
    public static final String LABEL3 = 'Boo3';
    public static final String TEMPID1 = 'Ghost1';
    public static final String TEMPID2 = 'Ghost2';
    public static final String TEMPID3 = 'Ghost3';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User adminUser1 = TestDataFactory.createUser(ADMIN_USER1_FIRST_NAME, ADMIN_USER1_LAST_NAME, standardProfile.Id);

        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];

        // Assigning two users with the admin perm set and one user with the standard perm set
        List<PermissionSetAssignment> permissionSets = new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = adminUser1.Id, PermissionSetId = adminUserPermissionSet.Id)
        };
        insert permissionSets;

        System.runAs(adminUser1) {
            AccountPlans.bypassEmailTrigger = true;

            Account testAccount = new Account(Name = 'Account 1');
            insert testAccount;

            Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan('Account Plan 1', testAccount);
            Relationship_Map__c rm = TestDataFactory.createRelationshipMap('Relationship Map Name');

            TestDataFactory.createMapMemberPlaceholder(LABEL1, LABEL1, TEMPID1, accountPlan1.Id, null);
            TestDataFactory.createMapMemberPlaceholder(LABEL2, LABEL2, TEMPID2, accountPlan1.Id, null);
            TestDataFactory.createMapMemberPlaceholder(LABEL3, LABEL3, TEMPID3, null, rm.Id);
        }
    }

    @isTest
    static void newInstanceTest() {
        MapMemberPlaceholderSelector selector = MapMemberPlaceholderSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        List<Map_Member_Placeholder__c> placeholders = [SELECT Id FROM Map_Member_Placeholder__c];
        Set<Id> mapMemberPlaceholderIds = (new Map<Id, Map_Member_Placeholder__c>(placeholders)).keySet();

        List<Map_Member_Placeholder__c> mapMemberPlaceholdersForadminUser1;

        Test.startTest();
        System.runAs(adminUser1) {
            mapMemberPlaceholdersForadminUser1 = new MapMemberPlaceholderSelector().selectById(mapMemberPlaceholderIds);
        }
        Test.stopTest();

        System.assertEquals(placeholders.size(), mapMemberPlaceholdersForadminUser1.size());
        for (Map_Member_Placeholder__c ph : mapMemberPlaceholdersForadminUser1) {
            System.assert(mapMemberPlaceholderIds.contains(ph.Id));
        }
    }

    @isTest
    static void selectByIdOrTempKeyTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        List<Map_Member_Placeholder__c> placeholders = [SELECT Id, TempId__c FROM Map_Member_Placeholder__c];
        Set<String> mapMemberPlaceholderTempKeys = new Set<String>();

        for (Map_Member_Placeholder__c mmp : placeholders) {
            mapMemberPlaceholderTempKeys.add(mmp.TempId__c);
        }

        List<Map_Member_Placeholder__c> mapMemberPlaceholdersForadminUser1;

        Test.startTest();
        System.runAs(adminUser1) {
            mapMemberPlaceholdersForadminUser1 = new MapMemberPlaceholderSelector()
                .selectByIdOrTempKey(mapMemberPlaceholderTempKeys);
        }
        Test.stopTest();

        System.assertEquals(placeholders.size(), mapMemberPlaceholdersForadminUser1.size());
        for (Map_Member_Placeholder__c ph : mapMemberPlaceholdersForadminUser1) {
            System.assert(mapMemberPlaceholderTempKeys.contains(ph.TempId__c));
        }
    }

    @isTest
    static void selectByAccountPlanTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];

        Account_Plan__c ap = [SELECT Id FROM Account_Plan__c LIMIT 1];
        List<Map_Member_Placeholder__c> placeholders = [
            SELECT Id
            FROM Map_Member_Placeholder__c
            WHERE Account_Plan__c = :ap.Id
        ];
        Set<Id> mapMemberPlaceholderIds = new Set<Id>();

        for (Map_Member_Placeholder__c mmp : placeholders) {
            mapMemberPlaceholderIds.add(mmp.Id);
        }

        List<Map_Member_Placeholder__c> mapMemberPlaceholdersForadminUser1;

        Test.startTest();
        System.runAs(adminUser1) {
            mapMemberPlaceholdersForadminUser1 = new MapMemberPlaceholderSelector()
                .selectByObjectId(new Set<Id>{ ap.Id });
        }
        Test.stopTest();

        System.assertEquals(placeholders.size(), mapMemberPlaceholdersForadminUser1.size());
        for (Map_Member_Placeholder__c ph : mapMemberPlaceholdersForadminUser1) {
            System.assert(mapMemberPlaceholderIds.contains(ph.Id));
        }
    }

    @isTest
    static void selectByRelationshipMapTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];

        Relationship_Map__c rm = [SELECT Id FROM Relationship_Map__c LIMIT 1];
        List<Map_Member_Placeholder__c> placeholders = [
            SELECT Id
            FROM Map_Member_Placeholder__c
            WHERE Relationship_Map__c = :rm.Id
        ];
        Set<Id> mapMemberPlaceholderIds = new Set<Id>();

        for (Map_Member_Placeholder__c mmp : placeholders) {
            mapMemberPlaceholderIds.add(mmp.Id);
        }

        List<Map_Member_Placeholder__c> mapMemberPlaceholdersForadminUser1;

        Test.startTest();
        System.runAs(adminUser1) {
            mapMemberPlaceholdersForadminUser1 = new MapMemberPlaceholderSelector()
                .selectByObjectId(new Set<Id>{ rm.Id });
        }
        Test.stopTest();

        System.assertEquals(placeholders.size(), mapMemberPlaceholdersForadminUser1.size());
        for (Map_Member_Placeholder__c ph : mapMemberPlaceholdersForadminUser1) {
            System.assert(mapMemberPlaceholderIds.contains(ph.Id));
        }
    }
}