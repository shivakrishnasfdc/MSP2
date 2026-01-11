@isTest
private class PostInstallTest {
    public static final String USER1_FIRST_NAME = 'admin';
    public static final String USER1_LAST_NAME = 'adam';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';
    public static final String RM_ADMINISTRATOR = 'PROLIFIQ_RELATIONSHIP_MAP';
    public static final String STANDARD_USER = 'Standard User';

    @TestSetup
    static void testSetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];
        User adminAdam = TestDataFactory.createUser(USER1_FIRST_NAME, USER1_LAST_NAME, p.Id);
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];
        PermissionSet rmAdminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :RM_ADMINISTRATOR];
        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = adminAdam.Id, PermissionSetId = adminUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = adminAdam.Id, PermissionSetId = rmAdminUserPermissionSet.Id)
        };
    }

    @isTest
    static void defaultAmountTypeTestNull() {
        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        Test.testInstall(postinstall, null);
        List<White_Space_Amount_Type__c> spendWithUS = [
            SELECT id, name
            FROM White_Space_Amount_Type__c
            WHERE name = 'Current Spend'
        ];
        System.assertEquals(1, spendWithUS.size(), 'Current Spend Amount Type not found');

        List<White_Space_Amount_Type__c> spendWithCompetitor = [
            SELECT id, name
            FROM White_Space_Amount_Type__c
            WHERE name = 'Competitor'
        ];
        System.assertEquals(1, spendWithCompetitor.size(), 'Competitor Amount Type not found');

        List<White_Space_Amount_Type__c> upside = [
            SELECT id, name
            FROM White_Space_Amount_Type__c
            WHERE name = 'Upside'
        ];
        System.assertEquals(1, upside.size(), 'Upside Amount Type not found');
    }

    @isTest
    static void defaultAmountTypeTest1dot7() {
        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        Test.testInstall(postinstall, new Version(1, 7), true);
        List<White_Space_Amount_Type__c> spendWithUS = [
            SELECT id, name, Display_Type__c
            FROM White_Space_Amount_Type__c
            WHERE name = 'Current Spend'
        ];
        System.assertEquals(1, spendWithUS.size(), 'Current Spend Amount Type not found');
        System.assertEquals(
            'Currency',
            spendWithUS[0].Display_Type__c,
            'Current Spend Amount Type is not set to currency'
        );

        List<White_Space_Amount_Type__c> spendWithCompetitor = [
            SELECT id, name, Display_Type__c
            FROM White_Space_Amount_Type__c
            WHERE name = 'Competitor'
        ];
        System.assertEquals(1, spendWithCompetitor.size(), 'Competitor Amount Type not found');
        System.assertEquals(
            'Currency',
            spendWithCompetitor[0].Display_Type__c,
            'Competitor Amount Type is not set to currency'
        );

        List<White_Space_Amount_Type__c> upside = [
            SELECT id, name, Display_Type__c
            FROM White_Space_Amount_Type__c
            WHERE name = 'Upside'
        ];
        System.assertEquals(1, upside.size(), 'Upside Amount Type not found');
        System.assertEquals('Currency', upside[0].Display_Type__c, 'Upside Amount Type is not set to currency');
    }

    @isTest
    static void installTest1dot8() {
        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        Test.testInstall(postinstall, new Version(1, 8), true);
        List<White_Space_Amount_Type__c> spendWithUS = [
            SELECT id, name
            FROM White_Space_Amount_Type__c
            WHERE name = 'Current Spend'
        ];
        System.assertEquals(0, spendWithUS.size(), 'Current Spend Amount Type is not empty');

        List<White_Space_Amount_Type__c> spendWithCompetitor = [
            SELECT id, name
            FROM White_Space_Amount_Type__c
            WHERE name = 'Competitor'
        ];
        System.assertEquals(0, spendWithCompetitor.size(), 'Competitor Amount Type is not empty');

        List<White_Space_Amount_Type__c> upside = [
            SELECT id, name
            FROM White_Space_Amount_Type__c
            WHERE name = 'Upside'
        ];
        System.assertEquals(0, upside.size(), 'Upside Amount Type not found is not empty');
    }

    @isTest
    static void postInstallOrgSettingsMigrationFrom1dot8() {
        User adminAdam = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        System.runAs(adminAdam) {
            PostInstall postinstall = new PostInstall();
            postInstall.batchSize = 2000;
            Test.testInstall(postinstall, new Version(1, 8), false);
            List<CRUSH_Settings_Obj__c> settings = [SELECT Id FROM CRUSH_Settings_Obj__c WHERE Type__c = 'Org' LIMIT 1];
            System.assertEquals(1, settings.size());
        }
    }

    @isTest
    static void postInstallOrgSettingsMigrationFrom3dot8NoSettings() {
        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        Test.testInstall(postinstall, new Version(3, 8), false);
        List<CRUSH_Settings_Obj__c> settings = [SELECT Id FROM CRUSH_Settings_Obj__c WHERE Type__c = 'Org' LIMIT 1];
        System.assertEquals(1, settings.size());
    }

    @isTest
    static void postInstallOrgSettingsMigrationFrom3dot8WithSettings() {
        CRUSH_Settings_Obj__c expectedSetting = new CRUSH_Settings_Obj__c(Type__c = 'Org');
        insert expectedSetting;
        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        Test.testInstall(postinstall, new Version(3, 8), false);
        List<CRUSH_Settings_Obj__c> settings = [SELECT Id FROM CRUSH_Settings_Obj__c WHERE Type__c = 'Org' LIMIT 1];
        System.assertEquals(1, settings.size());
        System.assertEquals(expectedSetting.Id, settings[0].Id);
    }

    @isTest
    static void postInstallOrgSettingsNewInstallNoSettings() {
        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        Test.testInstall(postinstall, null, false);
        List<CRUSH_Settings_Obj__c> settings = [SELECT Id FROM CRUSH_Settings_Obj__c WHERE Type__c = 'Org' LIMIT 1];
        System.assertEquals(1, settings.size());
    }

    @isTest
    static void postInstallOrgSettingsNewInstallWithSettings() {
        CRUSH_Settings_Obj__c expectedSetting = new CRUSH_Settings_Obj__c(Type__c = 'Org');
        insert expectedSetting;
        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        Test.testInstall(postinstall, null, false);
        List<CRUSH_Settings_Obj__c> settings = [SELECT Id FROM CRUSH_Settings_Obj__c WHERE Type__c = 'Org' LIMIT 1];
        System.assertEquals(1, settings.size());
        System.assertEquals(expectedSetting.Id, settings[0].Id);
    }

    @isTest
    static void postInstalladdTeamMemberOwnersTest() {
        // Create Test Account
        Account a = new Account(Name = 'test account');
        insert a;

        // Create Test Account Plans (Trigger should create team member owners)
        Account_Plan__c ap1 = new Account_Plan__c(Account__c = a.Id, Name = 'Plan A');
        Account_Plan__c ap2 = new Account_Plan__c(Account__c = a.Id, Name = 'Plan B');
        Account_Plan__c ap3 = new Account_Plan__c(Account__c = a.Id, Name = 'Plan C');
        List<Account_Plan__c> aps = new List<Account_Plan__c>{ ap1, ap2, ap3 };
        insert aps;

        // Create Test Account Plans (turn off creation of team member owners)
        AccountPlans.bypassCreateOwnersTrigger = true;
        Account_Plan__c ap4 = new Account_Plan__c(Account__c = a.Id, Name = 'Plan D');
        Account_Plan__c ap5 = new Account_Plan__c(Account__c = a.Id, Name = 'Plan E');
        Account_Plan__c ap6 = new Account_Plan__c(Account__c = a.Id, Name = 'Plan F');
        Account_Plan__c ap7 = new Account_Plan__c(Account__c = a.Id, Name = 'Plan G');
        List<Account_Plan__c> aps2 = new List<Account_Plan__c>{ ap4, ap5, ap6, ap7 };
        insert aps2;

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        Test.testInstall(postinstall, null, false);

        // Assert 7 total owners were created
        Id userId = UserInfo.getUserId();
        List<Team_Member__c> settings = [SELECT Id FROM Team_Member__c WHERE User__c = :userId];
        System.assertEquals(7, settings.size());
    }

    @isTest
    static void postInstallActivateExistingAmountTypesTest() {
        White_Space_Amount_Type__c at = new White_Space_Amount_Type__c(
            Name = 'testAmountType',
            IsActive__c = false,
            Color_RGB__c = '#0000ff'
        );
        insert at;

        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(7, 0), false);
        }

        List<White_Space_Amount_Type__c> result = [SELECT id, name, IsActive__c FROM White_Space_Amount_Type__c];

        system.assertEquals(1, result.size());
        system.assertEquals(true, result[0].IsActive__c);
    }

    @isTest
    static void postInstallupdateContactRelationshipsTest() {
        Contact jody = new Contact(LastName = 'jody');
        insert jody;
        Contact neil = new Contact(ReportsToId = jody.Id, LastName = 'neil');
        insert neil;

        Contact_Relationship__c c1 = new Contact_Relationship__c(From_Contact__c = jody.Id, To_Contact__c = neil.Id);
        insert c1;

        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(8, 0), false);
        }

        List<Contact_Relationship_Type__c> relTypes = [SELECT id FROM Contact_Relationship_Type__c];
        List<Contact_Relationship__c> rels = [SELECT id, Contact_Relationship_Type__c FROM Contact_Relationship__c];

        system.assertEquals(1, relTypes.size());
        system.assertEquals(relTypes[0].Id, rels[0].Contact_Relationship_Type__c);
    }

    @isTest
    static void postInstallFixDuplicateChartSettingsCountTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];
        Account a = new Account(Name = 'test account');
        insert a;

        // Create Test Account Plans (Trigger should create team member owners)
        Account_Plan__c ap1 = new Account_Plan__c(Account__c = a.Id, Name = 'Plan A');
        Account_Plan__c ap2 = new Account_Plan__c(Account__c = a.Id, Name = 'Plan B');
        Account_Plan__c ap3 = new Account_Plan__c(Account__c = a.Id, Name = 'Plan C');
        List<Account_Plan__c> aps = new List<Account_Plan__c>{ ap1, ap2, ap3 };
        insert aps;

        Relationship_Map__c rm1 = new Relationship_Map__c(Name = 'test rm1');
        insert rm1;

        RM_Chart_Setting__c cs1 = new RM_Chart_Setting__c(Account_Plan__c = ap1.Id);
        RM_Chart_Setting__c cs2 = new RM_Chart_Setting__c(Account_Plan__c = ap2.Id);
        RM_Chart_Setting__c cs3 = new RM_Chart_Setting__c(Relationship_Map__c = rm1.Id);
        RM_Chart_Setting__c cs2dup = new RM_Chart_Setting__c(Account_Plan__c = ap2.Id);
        RM_Chart_Setting__c cs3dup = new RM_Chart_Setting__c(Relationship_Map__c = rm1.Id);
        insert new List<RM_Chart_Setting__c>{ cs1, cs2, cs3, cs2dup, cs3dup };

        Test.startTest();
        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(9999, 0), false);
        }
        Test.stopTest();

        List<RM_Chart_Setting__c> chartSettings = [SELECT Id FROM RM_Chart_Setting__c];
        System.assertEquals(3, chartSettings.size(), 'should remove all duplicate settings');
    }

    @isTest
    static void postInstallFixDuplicateChartSettingsValidityTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];
        Account a = new Account(Name = 'test account');
        insert a;

        // Create Test Account Plans (Trigger should create team member owners)
        Account_Plan__c ap1 = new Account_Plan__c(Account__c = a.Id, Name = 'Plan A');
        insert ap1;

        RM_Chart_Setting__c cs1 = new RM_Chart_Setting__c(Account_Plan__c = ap1.Id);
        insert cs1;

        // 2 second "pause" to have noticable time between creations
        Long startTime = DateTime.now().getTime();
        Long finalTime = DateTime.now().getTime();
        Long millisecondsToWait = 2000; // vary this depending on your "sleep" needs
        while (finalTime - startTime < millisecondsToWait) {
            finalTime = DateTime.now().getTime();
        }

        RM_Chart_Setting__c cs2 = new RM_Chart_Setting__c(Account_Plan__c = ap1.Id);
        insert cs2;

        Test.startTest();
        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(9999, 0), false);
        }
        Test.stopTest();

        List<RM_Chart_Setting__c> chartSettings = [SELECT Id FROM RM_Chart_Setting__c];
        System.assertEquals(1, chartSettings.size(), 'should only return one chart setting');
        System.assertEquals(cs2.Id, chartSettings[0].Id, 'chart setting returned should be most recently edited one');
    }

    @isTest
    static void postInstallupdateRMChartSettingsTest() {
        RM_Chart_Setting__c c1 = new RM_Chart_Setting__c();
        insert c1;

        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(8, 0), false);
        }

        List<RM_Chart_Setting__c> settings = [
            SELECT Id, Auto_Layout__c, Is_Group_Global_Scope__c, Is_Relationship_Line_Global_Scope__c
            FROM RM_Chart_Setting__c
        ];

        system.assertEquals(1, settings.size());
        system.assertEquals(true, settings[0].Auto_Layout__c);
        system.assertEquals(true, settings[0].Is_Group_Global_Scope__c);
        system.assertEquals(true, settings[0].Is_Relationship_Line_Global_Scope__c);
    }

    @isTest
    static void defaultRelTypeTestNull() {
        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        Test.testInstall(postinstall, null);

        List<Contact_Relationship_Type__c> relType = [
            SELECT id, name, color__c, label__c, Label_Editable__c, IsActive__c
            FROM Contact_Relationship_Type__c
        ];
        System.assertEquals(1, relType.size());
        System.assertEquals('#0080ff', relType[0].Color__c);
        System.assertEquals('relationship', relType[0].Label__c);
        System.assertEquals(true, relType[0].Label_Editable__c);
        System.assertEquals(true, relType[0].IsActive__c);
    }

    @isTest
    static void updateUserSettingsForFilterDataDefaultsTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        White_Space__c ws = TestDataFactory.createWhiteSpace('A Plan');
        WS_User_Setting__c setting1 = new WS_User_Setting__c(
            Show_Empty_Columns__c = false,
            Show_Empty_Rows__c = false,
            Show_Populated_Columns__c = false,
            Show_Populated_Rows__c = false,
            White_Space__c = ws.Id
        );
        WS_User_Setting__c setting2 = new WS_User_Setting__c(White_Space__c = ws.Id);

        insert new List<WS_User_Setting__c>{ setting1, setting2 };

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(13, 8), false);
        }

        List<WS_User_Setting__c> result = [
            SELECT Id, Show_Empty_Columns__c, Show_Empty_Rows__c, Show_Populated_Columns__c, Show_Populated_Rows__c
            FROM WS_User_Setting__c
            WHERE Id IN (:setting1.Id, :setting2.Id)
        ];

        System.assertEquals(2, result.size());

        Map<Id, WS_User_Setting__c> resultMap = new Map<Id, WS_User_Setting__c>(result);

        WS_User_Setting__c result1 = resultMap.get(setting1.Id);
        System.assertEquals(true, result1.Show_Empty_Columns__c);
        System.assertEquals(true, result1.Show_Empty_Rows__c);
        System.assertEquals(true, result1.Show_Populated_Columns__c);
        System.assertEquals(true, result1.Show_Populated_Rows__c);

        WS_User_Setting__c result2 = resultMap.get(setting2.Id);
        System.assertEquals(true, result2.Show_Empty_Columns__c);
        System.assertEquals(true, result2.Show_Empty_Rows__c);
        System.assertEquals(true, result2.Show_Populated_Columns__c);
        System.assertEquals(true, result2.Show_Populated_Rows__c);
    }

    @isTest
    static void updateContactRelationshipTypesTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        Contact_Relationship_Type__c type1 = new Contact_Relationship_Type__c(IsActive__c = true, Color__c = '#ff9922');
        insert type1;
        Contact_Relationship_Type__c type2 = new Contact_Relationship_Type__c(IsActive__c = true, Color__c = '#ffddcc');
        insert type2;
        Contact_Relationship_Type__c type3 = new Contact_Relationship_Type__c(
            IsActive__c = false,
            Color__c = '#ff8811'
        );
        insert type3;

        PostInstall postinstall = new PostInstall();
        postinstall.batchSize = 2000;
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(12, 0), false);
        }

        List<Contact_Relationship_Type__c> result = [
            SELECT pqcrush__Used_in_all_account_plans__c, pqcrush__Used_in_all_relationship_maps__c
            FROM Contact_Relationship_Type__c
            WHERE IsActive__c = TRUE
        ];

        System.assertEquals(2, result.size());
        for (Contact_Relationship_Type__c relType : result) {
            System.assertEquals(true, relType.pqcrush__Used_in_all_account_plans__c);
            System.assertEquals(true, relType.pqcrush__Used_in_all_relationship_maps__c);
        }
    }

    @isTest
    static void insertDefaultSvgTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(12, 0), false);
        }

        List<RM_Svg__c> svgs = [SELECT id, Name, Label__c, Fill__c, Geometry_String__c FROM RM_Svg__c];

        Set<String> names = new Set<String>();
        for (RM_Svg__c svg : svgs) {
            names.add(svg.Name);
        }

        System.assert(names.contains('Star'));
        System.assert(names.contains('Lightning'));
        System.assert(names.contains('Diamond'));
    }

    @isTest
    static void postInstallUpdateRMOrgSettingsTest() {
        RM_Org_Setting__c c1 = new RM_Org_Setting__c(Type__c = 'rm');
        insert c1;

        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(12, 0), false);
        }

        List<RM_Org_Setting__c> settings = [
            SELECT Id, Type__c, Lead_Tab__c, User_Tab__c, Create_New_Contact__c
            FROM RM_Org_Setting__c
        ];

        system.assertEquals(true, settings[0].Lead_Tab__c);
        system.assertEquals(true, settings[0].User_Tab__c);
        system.assertEquals(true, settings[0].Create_New_Contact__c);
    }

    @isTest
    static void createDefaultInfluenceSupportMatrixTest() {
        Schema.DescribeFieldResult influenceFieldResult = SObjectType.Key_Stakeholder__c.fields.Influence__c;
        Schema.DescribeFieldResult supportFieldResult = SObjectType.Key_Stakeholder__c.fields.Support__c;

        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(12, 0), false);
        }

        List<pq_Influence__c> influences = [SELECT Id, Name, Label__c FROM pq_Influence__c];

        List<pq_Support__c> supports = [SELECT Id, Name, Label__c, Color__c FROM pq_Support__c];

        List<pq_Influence_And_Support_Matrix__c> matrixes = [
            SELECT Id, Name, Is_Default__c
            FROM pq_Influence_And_Support_Matrix__c
        ];

        List<pq_Influence_Matrix_Association__c> infAssoc = [SELECT Id FROM pq_Influence_Matrix_Association__c];

        List<pq_Support_Matrix_Association__c> supAssoc = [SELECT Id FROM pq_Support_Matrix_Association__c];

        system.assertEquals(influenceFieldResult.getPicklistValues().size(), influences.size());
        system.assertEquals(supportFieldResult.getPicklistValues().size(), supports.size());
        system.assertEquals(1, matrixes.size());
        system.assertEquals(influenceFieldResult.getPicklistValues().size(), infAssoc.size());
        system.assertEquals(supportFieldResult.getPicklistValues().size(), supAssoc.size());
    }

    @IsTest
    static void updateMapMembersInfleunceSupportHappyPathTest() {
        Schema.DescribeFieldResult influenceFieldResult = SObjectType.Key_Stakeholder__c.fields.Influence__c;
        Schema.DescribeFieldResult supportFieldResult = SObjectType.Key_Stakeholder__c.fields.Support__c;
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        Key_Stakeholder__c ks1;
        Key_Stakeholder__c ks2;
        System.runAs(admin) {
            Account_Plan__c accountPlan = TestDataFactory.createAccountPlan('my plan');
            Contact c1 = new Contact(LastName = 'postInstallC1', FirstName = 'c1First', Title = 'Executive');
            Contact c2 = new Contact(LastName = 'postInstallC2', FirstName = 'c2First', Title = 'Engineer');
            insert new List<Contact>{ c1, c2 };
            ks1 = new Key_Stakeholder__c(
                Contact__c = c1.Id,
                Account_Plan__c = accountPlan.Id,
                Influence__c = influenceFieldResult.getPicklistValues().get(0).getValue(),
                Support__c = supportFieldResult.getPicklistValues().get(0).getValue()
            );
            ks2 = new Key_Stakeholder__c(
                Contact__c = c2.Id,
                Account_Plan__c = accountPlan.Id,
                Influence__c = influenceFieldResult.getPicklistValues().get(1).getValue(),
                Support__c = supportFieldResult.getPicklistValues().get(1).getValue()
            );
            insert new List<Key_Stakeholder__c>{ ks1, ks2 };
        }
        Set<Id> stakeholderIds = new Set<Id>{ ks1.Id, ks2.Id };
        Datetime insertTime = Datetime.now();

        Datetime oneSecInFuture = Datetime.now().addSeconds(1);
        while (Datetime.now() < oneSecInFuture) {
            Integer temp = 1 + 1; //NOPMD - loop until time has passed to garauntee our modified date is different
        }

        Test.startTest();
        System.runAs(admin) {
            PostInstall postinstall = new PostInstall();
            postInstall.batchSize = 2000;
            Test.testInstall(postinstall, new Version(12, 99), false);
        }
        Test.stopTest();

        List<Key_Stakeholder__c> updatedList = [
            SELECT Id, InfluenceId__c, SupportId__c
            FROM Key_Stakeholder__c
            WHERE lastModifiedDate > :insertTime
        ];
        System.assertEquals(2, updatedList.size(), 'Both records should have been updated');
        for (Key_Stakeholder__c ks : updatedList) {
            System.assertNotEquals(null, ks.InfluenceId__c, 'InfluenceId__c should not be null');
            System.assertNotEquals(null, ks.SupportId__c, 'SupportId__c should not be null');
            System.assert(stakeholderIds.contains(ks.Id), 'Id should be one of the original stakeholder ids');
        }
    }

    @IsTest
    static void updateMapMembersInfleunceSupportNullInfluenceAndSupportTest() {
        Schema.DescribeFieldResult influenceFieldResult = SObjectType.Key_Stakeholder__c.fields.Influence__c;
        Schema.DescribeFieldResult supportFieldResult = SObjectType.Key_Stakeholder__c.fields.Support__c;
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        Key_Stakeholder__c ks1;
        Key_Stakeholder__c ks2;
        System.runAs(admin) {
            Account_Plan__c accountPlan = TestDataFactory.createAccountPlan('my plan');
            Contact c1 = new Contact(LastName = 'postInstallC1', FirstName = 'c1First', Title = 'Executive');
            Contact c2 = new Contact(LastName = 'postInstallC2', FirstName = 'c2First', Title = 'Engineer');
            insert new List<Contact>{ c1, c2 };
            ks1 = new Key_Stakeholder__c(
                Contact__c = c1.Id,
                Account_Plan__c = accountPlan.Id,
                Influence__c = null,
                Support__c = null
            );
            ks2 = new Key_Stakeholder__c(
                Contact__c = c2.Id,
                Account_Plan__c = accountPlan.Id,
                Influence__c = influenceFieldResult.getPicklistValues().get(1).getValue(),
                Support__c = supportFieldResult.getPicklistValues().get(1).getValue()
            );
            insert new List<Key_Stakeholder__c>{ ks1, ks2 };
        }
        Datetime insertTime = Datetime.now();

        Datetime oneSecInFuture = Datetime.now().addSeconds(1);
        while (Datetime.now() < oneSecInFuture) {
            Integer temp = 1 + 1; //NOPMD - loop until time has passed to garauntee our modified date is different
        }

        Test.startTest();
        System.runAs(admin) {
            PostInstall postinstall = new PostInstall();
            postInstall.batchSize = 2000;
            Test.testInstall(postinstall, new Version(12, 99), false);
        }
        Test.stopTest();

        List<Key_Stakeholder__c> updatedList = [
            SELECT Id, InfluenceId__c, SupportId__c
            FROM Key_Stakeholder__c
            WHERE lastModifiedDate > :insertTime
        ];
        System.assertEquals(1, updatedList.size(), 'Both records should have been updated');
        System.assertEquals(ks2.Id, updatedList[0].Id, 'Only the record with values should have been updated');
    }

    @IsTest
    static void updateMapMembersInfleunceSupportNullSupportTest() {
        Schema.DescribeFieldResult influenceFieldResult = SObjectType.Key_Stakeholder__c.fields.Influence__c;
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        Key_Stakeholder__c ks1;
        System.runAs(admin) {
            Account_Plan__c accountPlan = TestDataFactory.createAccountPlan('my plan');
            Contact c1 = new Contact(LastName = 'postInstallC1', FirstName = 'c1First', Title = 'Executive');
            Contact c2 = new Contact(LastName = 'postInstallC2', FirstName = 'c2First', Title = 'Engineer');
            insert new List<Contact>{ c1, c2 };
            ks1 = new Key_Stakeholder__c(
                Contact__c = c1.Id,
                Account_Plan__c = accountPlan.Id,
                Influence__c = influenceFieldResult.getPicklistValues().get(1).getValue(),
                Support__c = null
            );
            insert ks1;
        }
        Datetime insertTime = Datetime.now();

        Datetime oneSecInFuture = Datetime.now().addSeconds(1);
        while (Datetime.now() < oneSecInFuture) {
            Integer temp = 1 + 1; //NOPMD - loop until time has passed to garauntee our modified date is different
        }

        Test.startTest();
        System.runAs(admin) {
            PostInstall postinstall = new PostInstall();
            postInstall.batchSize = 2000;
            Test.testInstall(postinstall, new Version(12, 99), false);
        }
        Test.stopTest();

        List<Key_Stakeholder__c> updatedList = [
            SELECT Id, InfluenceId__c, SupportId__c
            FROM Key_Stakeholder__c
            WHERE lastModifiedDate > :insertTime
        ];
        System.assertEquals(1, updatedList.size(), 'The record should be updated');
        System.assertEquals(null, updatedList[0].SupportId__c, 'SupportId should be null');
    }

    @IsTest
    static void updateMapMembersInfleunceSupportMapMemberTest() {
        Schema.DescribeFieldResult influenceFieldResult = SObjectType.Key_Stakeholder__c.fields.Influence__c;
        Schema.DescribeFieldResult supportFieldResult = SObjectType.Key_Stakeholder__c.fields.Support__c;
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        Relationship_Map_Member__c rmm1;
        Relationship_Map_Member__c rmm2;
        System.runAs(admin) {
            Relationship_Map__c rm = TestDataFactory.createRelationshipMap('mapName');
            Contact c1 = new Contact(LastName = 'postInstallC1', FirstName = 'c1First', Title = 'Executive');
            Contact c2 = new Contact(LastName = 'postInstallC2', FirstName = 'c2First', Title = 'Engineer');
            insert new List<Contact>{ c1, c2 };
            rmm1 = new Relationship_Map_Member__c(
                Contact__c = c1.Id,
                Relationship_Map__c = rm.Id,
                Influence__c = influenceFieldResult.getPicklistValues().get(0).getValue(),
                Support__c = supportFieldResult.getPicklistValues().get(0).getValue()
            );
            rmm2 = new Relationship_Map_Member__c(
                Contact__c = c2.Id,
                Relationship_Map__c = rm.Id,
                Influence__c = influenceFieldResult.getPicklistValues().get(1).getValue(),
                Support__c = supportFieldResult.getPicklistValues().get(1).getValue()
            );
            insert new List<Relationship_Map_Member__c>{ rmm1, rmm2 };
        }
        Set<Id> stakeholderIds = new Set<Id>{ rmm1.Id, rmm2.Id };
        Datetime insertTime = Datetime.now();

        Datetime oneSecInFuture = Datetime.now().addSeconds(1);
        while (Datetime.now() < oneSecInFuture) {
            Integer temp = 1 + 1; //NOPMD - loop until time has passed to garauntee our modified date is different
        }

        Test.startTest();
        System.runAs(admin) {
            PostInstall postinstall = new PostInstall();
            postInstall.batchSize = 2000;
            Test.testInstall(postinstall, new Version(12, 99), false);
        }
        Test.stopTest();

        List<Relationship_Map_Member__c> updatedList = [
            SELECT Id, InfluenceId__c, SupportId__c
            FROM Relationship_Map_Member__c
            WHERE lastModifiedDate > :insertTime
        ];
        System.assertEquals(2, updatedList.size(), 'Both records should have been updated');
        for (Relationship_Map_Member__c rmm : updatedList) {
            System.assertNotEquals(null, rmm.InfluenceId__c, 'InfluenceId__c should not be null');
            System.assertNotEquals(null, rmm.SupportId__c, 'SupportId__c should not be null');
            System.assert(stakeholderIds.contains(rmm.Id), 'Id should be one of the original map member ids');
        }
    }

    @isTest
    static void postInstallupdateRMChartSettings2Test() {
        RM_Chart_Setting__c c1 = new RM_Chart_Setting__c();
        insert c1;

        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(12, 0), false);
        }

        List<RM_Chart_Setting__c> settings = [
            SELECT Id, Is_Influence_Support_Global_Scope__c, Is_Reports_To_Global_Scope__c
            FROM RM_Chart_Setting__c
        ];

        system.assertEquals(1, settings.size());
        system.assertEquals(false, settings[0].Is_Influence_Support_Global_Scope__c);
        system.assertEquals(true, settings[0].Is_Reports_To_Global_Scope__c);
    }

    @isTest
    static void postInstallUpdateRMOrgSettings2Test() {
        RM_Org_Setting__c c1 = new RM_Org_Setting__c(Type__c = 'rm');
        insert c1;

        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(12, 5), false);
        }

        List<RM_Org_Setting__c> settings = [SELECT Id, Show_Auto_Manual_Toggle__c FROM RM_Org_Setting__c];

        system.assertEquals(true, settings[0].Show_Auto_Manual_Toggle__c);
    }

    @isTest
    static void updateRMOrgSettingsForButtonVisibilityTest() {
        RM_Org_Setting__c c1 = new RM_Org_Setting__c(Type__c = 'rm');
        c1.Show_Clone_Relationship_Map__c = false;
        c1.Show_Chart_Settings__c = false;
        c1.Enable_Contact_Context_Menu__c = false;
        c1.Enable_Map_Member_Context_Menu__c = false;
        c1.Enable_Omni_Viewer_Context_Menu__c = true;
        insert c1;

        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        PostInstall postinstall = new PostInstall();
        postinstall.batchSize = 2000;
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(12, 11), false);
        }

        List<RM_Org_Setting__c> settings = [
            SELECT
                Id,
                Show_Clone_Relationship_Map__c,
                Show_Chart_Settings__c,
                Enable_Contact_Context_Menu__c,
                Enable_Map_Member_Context_Menu__c,
                Enable_Omni_Viewer_Context_Menu__c
            FROM RM_Org_Setting__c
        ];

        system.assertEquals(true, settings[0].Show_Clone_Relationship_Map__c);
        system.assertEquals(true, settings[0].Show_Chart_Settings__c);
        system.assertEquals(true, settings[0].Enable_Contact_Context_Menu__c);
        system.assertEquals(true, settings[0].Enable_Map_Member_Context_Menu__c);
        system.assertEquals(false, settings[0].Enable_Omni_Viewer_Context_Menu__c);
    }

    @isTest
    static void updateRmGroupMenuForButtonVisibilityTest() {
        RM_Org_Setting__c c1 = new RM_Org_Setting__c(Type__c = 'rm');
        c1.Enable_Group_Selection_Context_Menu__c = true;
        insert c1;

        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        PostInstall postinstall = new PostInstall();
        postinstall.batchSize = 2000;
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(14, 0), true);
        }

        List<RM_Org_Setting__c> settings = [SELECT Id, Enable_Group_Selection_Context_Menu__c FROM RM_Org_Setting__c];

        system.assertEquals(true, settings[0].Enable_Group_Selection_Context_Menu__c);
    }

    @isTest
    static void updateCRUSHOrgSettingForCreateInWSTest() {
        CRUSH_Settings_Obj__c c1 = new CRUSH_Settings_Obj__c(Type__c = 'Org');
        insert c1;

        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(12, 8), false);
        }

        List<CRUSH_Settings_Obj__c> settings = [
            SELECT Id, Can_Create_Objects_In_Cross_Sell__c
            FROM CRUSH_Settings_Obj__c
        ];

        system.assertEquals(true, settings[0].Can_Create_Objects_In_Cross_Sell__c);
    }

    @isTest
    static void updatePlanOverviewsTest() {
        Account a = new Account(Name = 'aaa');
        insert a;
        Account_Plan__c plan1 = new Account_Plan__c(
            Account__c = a.Id,
            Name = 'test1',
            Plan_Overview_Title__c = 'titleA',
            Plan_Overview__c = 'descA'
        );
        Account_Plan__c plan2 = new Account_Plan__c(
            Account__c = a.Id,
            Name = 'test2',
            Plan_Overview_Title__c = null,
            Plan_Overview__c = 'desc2'
        );
        Account_Plan__c plan3 = new Account_Plan__c(
            Account__c = a.Id,
            Name = 'test3',
            Plan_Overview_Title__c = null,
            Plan_Overview__c = null
        );
        //turns out that our original overview title only allowed up to 80 characters
        Account_Plan__c plan4 = new Account_Plan__c(
            Account__c = a.Id,
            Name = 'test3',
            Plan_Overview_Title__c = 'title4 this is a long title that is longer than eighty characters to test the name trimming is done correctly, trimmed to 80'
                .substring(0, 80),
            Plan_Overview__c = 'desc4'
        );
        insert new List<Account_Plan__c>{ plan1, plan2, plan3, plan4 };

        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        Test.startTest();
        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(12, 5), false);
        }
        Test.stopTest();

        List<pq_CRUSH_Plan_Overview__c> planOverViews = [
            SELECT Id, Name, Description__c, Background_Color__c, Title__c, Account_Plan__c
            FROM pq_CRUSH_Plan_Overview__c
        ];

        system.assertEquals(4, planOverViews.size(), 'Should insert a overview for each plan');
        Boolean plan1Inserted = false;
        Boolean plan2Inserted = false;
        Boolean plan3Inserted = false;
        Boolean plan4Inserted = false;
        for (pq_CRUSH_Plan_Overview__c po : planOverViews) {
            if (po.Account_Plan__c == plan1.Id) {
                system.assertEquals(plan1.Plan_Overview__c, po.Description__c);
                system.assertEquals(plan1.Plan_Overview_Title__c, po.Title__c);
                system.assertEquals(plan1.Plan_Overview_Title__c, po.Name);
                system.assertEquals('#cccccc', po.Background_Color__c);
                plan1Inserted = true;
            } else if (po.Account_Plan__c == plan2.Id) {
                system.assertEquals(plan2.Plan_Overview__c, po.Description__c);
                system.assertEquals(plan2.Plan_Overview_Title__c, po.Title__c);
                system.assertNotEquals(
                    plan2.Plan_Overview_Title__c,
                    po.Name,
                    'If name is null then it will generate a name'
                );
                system.assertEquals('#cccccc', po.Background_Color__c);
                plan2Inserted = true;
            } else if (po.Account_Plan__c == plan3.Id) {
                system.assertEquals(plan3.Plan_Overview__c, po.Description__c);
                system.assertEquals(plan3.Plan_Overview_Title__c, po.Title__c);
                system.assertNotEquals(
                    plan3.Plan_Overview_Title__c,
                    po.Name,
                    'If name is null then it will generate a name'
                );
                system.assertEquals('#cccccc', po.Background_Color__c);
                plan3Inserted = true;
            } else if (po.Account_Plan__c == plan4.Id) {
                system.assertEquals(plan4.Plan_Overview__c, po.Description__c);
                system.assertEquals(plan4.Plan_Overview_Title__c, po.Title__c);
                system.assertEquals(plan4.Plan_Overview_Title__c, po.Name);
                system.assertEquals('#cccccc', po.Background_Color__c);
                plan4Inserted = true;
            }
        }
        System.assert(
            plan1Inserted && plan2Inserted && plan3Inserted && plan4Inserted,
            'All the plan overviews should have been inserted'
        );
    }

    @isTest
    static void updateCRUSHOrgSettingForUseDefaultScoreTest() {
        CRUSH_Settings_Obj__c c1 = new CRUSH_Settings_Obj__c(
            Type__c = 'Org',
            Use_Default_Account_Plan_Score__c = false
        );
        insert c1;

        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(12, 8), false);
        }

        List<CRUSH_Settings_Obj__c> settings = [
            SELECT Id, Use_Default_Account_Plan_Score__c
            FROM CRUSH_Settings_Obj__c
        ];

        system.assertEquals(true, settings[0].Use_Default_Account_Plan_Score__c);
    }

    @isTest
    static void updateCRUSHOrgSettingForUsePercentageScoreTest() {
        CRUSH_Settings_Obj__c c1 = new CRUSH_Settings_Obj__c(
            Type__c = 'Org',
            Use_Percentage_Account_Plan_Score__c = false
        );
        insert c1;

        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(12, 8), false);
        }

        List<CRUSH_Settings_Obj__c> settings = [
            SELECT Id, Use_Percentage_Account_Plan_Score__c
            FROM CRUSH_Settings_Obj__c
        ];

        system.assertEquals(true, settings[0].Use_Percentage_Account_Plan_Score__c);
    }

    @isTest
    static void updateWhiteSpaceHighlightsTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        WS_Highlight__c c1 = new WS_Highlight__c(
            Color__c = '#ccddee',
            Label__c = 'test label',
            Apply_To_All_Cross_Sell_Maps__c = false
        );
        insert c1;

        System.runAs(admin) {
            PostInstall postinstall = new PostInstall();
            postinstall.batchSize = 2000;
            Test.testInstall(postinstall, new Version(12, 0), false);
        }

        List<WS_Highlight__c> result = [
            SELECT Id, Apply_To_All_Cross_Sell_Maps__c
            FROM WS_Highlight__c
            WHERE Apply_To_All_Cross_Sell_Maps__c = TRUE
        ];

        system.assertEquals(1, result.size());
    }

    static void createDefaultRelationshipTypeTest() {
        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        Test.testInstall(postinstall, null);

        List<Contact_Relationship_Type__c> result = [
            SELECT
                id,
                Name,
                Color__c,
                Label__c,
                Label_Editable__c,
                IsActive__c,
                Used_in_all_account_plans__c,
                Used_in_all_relationship_maps__c
            FROM Contact_Relationship_Type__c
        ];
        System.assertEquals(1, result.size());
        System.assertEquals('Relationship', result[0].Name);
        System.assertEquals('#0080ff', result[0].Color__c);
        System.assertEquals('relationship', result[0].Label__c);
        System.assertEquals(true, result[0].Label_Editable__c);
        System.assertEquals(true, result[0].IsActive__c);
        System.assertEquals(true, result[0].Used_in_all_account_plans__c);
        System.assertEquals(true, result[0].Used_in_all_relationship_maps__c);
    }

    @isTest
    static void insertDefaultSvg2Test() {
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        Test.startTest();
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(12, 5), false);
        }
        Test.stopTest();

        List<RM_Svg__c> svgs = [SELECT id, Label__c, Fill__c, Geometry_String__c FROM RM_Svg__c];

        System.assert(svgs.size() >= 342);
    }

    // Test KS & Lead, user conversion
    @isTest
    static void convertKSToRMTest1() {
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        // Create Test Account
        Account a = new Account(Name = 'test account');
        insert a;

        Account_Plan__c ap1 = new Account_Plan__c(Account__c = a.Id, Name = 'Plan A');
        insert ap1;

        Contact c2 = new Contact(LastName = 'Test');
        insert c2;
        Contact c1 = new Contact(LastName = 'Test', ReportsToId = c2.Id);
        insert c1;

        Key_Stakeholder__c ks1 = new Key_Stakeholder__c(Contact__c = c1.Id, Account_Plan__c = ap1.Id);
        insert ks1;

        Key_Stakeholder__c ks2 = new Key_Stakeholder__c(Contact__c = c2.Id, Account_Plan__c = ap1.Id);
        insert ks2;

        // Leads
        Lead l1 = new Lead(LastName = 'SmithL', Company = 'ACME');
        insert l1;
        Key_Stakeholder_Lead__c ksLead1 = new Key_Stakeholder_Lead__c(Account_Plan__c = ap1.Id, Lead__c = l1.Id);
        insert ksLead1;

        //Map Member User
        Map_Member_User__c mmu = new Map_Member_User__c(Account_Plan__c = ap1.Id, User__c = admin.Id);
        insert mmu;

        //-----------------------------------------------------------------------------
        // RUN POST INSTALL TEST

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        Test.startTest();
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(13, 9), false);
        }
        Test.stopTest();
        //-----------------------------------------------------------------------------

        List<Relationship_Map__c> rm = [SELECT id, name FROM Relationship_Map__c];
        System.assertEquals(1, rm.size());
        System.assertEquals('Plan A', rm[0].Name);

        Id rmId = rm[0].Id;

        // Map Members
        List<Relationship_Map_Member__c> rmm = [
            SELECT id, Contact__c, Relationship_Map__c
            FROM Relationship_Map_Member__c
        ];

        System.assertEquals(2, rmm.size());
        System.assert(rmm[0].Contact__c == c1.Id || rmm[0].Contact__c == c2.Id);
        System.assert(rmm[1].Contact__c == c1.Id || rmm[1].Contact__c == c2.Id);
        System.assert(rmm[0].Relationship_Map__c == rmId);
        System.assert(rmm[1].Relationship_Map__c == rmId);

        // Leads
        List<Map_Member_Lead__c> rmmLead = [SELECT id, Lead__c, Relationship_Map__c FROM Map_Member_Lead__c];

        System.assertEquals(1, rmmLead.size());
        System.assertEquals(l1.Id, rmmLead[0].Lead__c);
        System.assert(rmmLead[0].Relationship_Map__c == rmId);

        //  Map Member User
        List<Map_Member_User__c> mmusers = [SELECT id, Relationship_Map__c FROM Map_Member_User__c];

        System.assertEquals(1, mmusers.size());
        System.assertEquals(rmId, mmusers[0].Relationship_Map__c);
    }

    // Test Influence & Support conversion
    @isTest
    static void convertKSToRMTest2() {
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        // Create Test Account
        Account a = new Account(Name = 'test account');
        insert a;

        Account_Plan__c ap1 = new Account_Plan__c(Account__c = a.Id, Name = 'Plan A');
        insert ap1;

        // Influence Support
        pq_Influence_And_Support_Matrix__c ism = new pq_Influence_And_Support_Matrix__c();
        ism.Name = 'Test Matrix For crmmt';
        ism.Is_Default__c = false;
        insert ism;

        pq_Account_Plan_Matrix_Association__c assoc = new pq_Account_Plan_Matrix_Association__c();
        assoc.Account_Plan__c = ap1.Id;
        assoc.Influence_And_Support_Matrix__c = ism.Id;
        insert assoc;

        //-----------------------------------------------------------------------------
        // RUN POST INSTALL TEST

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        Test.startTest();
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(13, 9), false);
        }
        Test.stopTest();
        //-----------------------------------------------------------------------------

        List<Relationship_Map__c> rm = [SELECT id, name FROM Relationship_Map__c];
        System.assertEquals(1, rm.size());
        System.assertEquals('Plan A', rm[0].Name);

        Id rmId = rm[0].Id;

        // Influence & Support
        List<pq_Relationship_Map_Matrix_Association__c> relmapmatrixassoc = [
            SELECT id, Influence_And_Support_Matrix__c, Relationship_Map__c
            FROM pq_Relationship_Map_Matrix_Association__c
        ];

        System.assertEquals(1, relmapmatrixassoc.size());
        System.assertEquals(ism.Id, relmapmatrixassoc[0].Influence_And_Support_Matrix__c);
        System.assertEquals(rmId, relmapmatrixassoc[0].Relationship_Map__c);
    }

    // Test SVG Conversion
    @isTest
    static void convertKSToRMTest3() {
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        // Create Test Account
        Account a = new Account(Name = 'test account');
        insert a;

        Account_Plan__c ap1 = new Account_Plan__c(Account__c = a.Id, Name = 'Plan A');
        insert ap1;

        // svg
        RM_Svg__c svg = new RM_Svg__c(
            Name = 'Star',
            Label__c = 'Star',
            Fill__c = '#da252b',
            Geometry_String__c = 'M27.4,3.1l4.6,15c0.2,0.6,0.8,0.9,1.4,0.9h15c1.5,0,2.1,2,0.9,2.9l-12.2,9c-0.5,0.4-0.7,1.1-0.5,1.7L42.4,48c0.4,1.4-1.1,2.6-2.3,1.7L27,39.9c-0.5-0.4-1.2-0.4-1.8,0L12,49.7c-1.2,0.9-2.8-0.3-2.3-1.7l5.6-15.4c0.2-0.6,0-1.3-0.5-1.7l-12.2-9C1.4,21,2.1,19,3.5,19h15c0.7,0,1.2-0.2,1.4-0.9L24.6,3C25,1.6,27,1.7,27.4,3.1z',
            View_Box__c = '0 0 52 52',
            Used_in_all_account_plans__c = true
        );
        insert svg;

        RM_Svg_Account_Plan_Association__c rmSvgAccountPlanAssociation = new RM_Svg_Account_Plan_Association__c(
            RM_Svg__c = svg.Id,
            Account_Plan__c = ap1.Id
        );
        insert rmSvgAccountPlanAssociation;

        // RM SVG Node Association
        RM_Svg_Node_Association__c rmsvgNodeAssoc = new RM_Svg_Node_Association__c(
            Key__c = 'abc',
            RM_Svg__c = svg.Id,
            account_Plan__c = ap1.Id
        );
        insert rmsvgNodeAssoc;

        //-----------------------------------------------------------------------------
        // RUN POST INSTALL TEST

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        Test.startTest();
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(13, 9), false);
        }
        Test.stopTest();
        //-----------------------------------------------------------------------------

        List<Relationship_Map__c> rm = [SELECT id, name FROM Relationship_Map__c];
        System.assertEquals(1, rm.size());
        System.assertEquals('Plan A', rm[0].Name);

        Id rmId = rm[0].Id;

        // SVG Map Association
        List<RM_Svg_Map_Association__c> rmsvgmapssoc = [
            SELECT id, RM_Svg__c, Relationship_Map__c
            FROM RM_Svg_Map_Association__c
        ];

        System.assertEquals(1, rmsvgmapssoc.size());
        System.assertEquals(svg.Id, rmsvgmapssoc[0].RM_Svg__c);
        System.assertEquals(rmId, rmsvgmapssoc[0].Relationship_Map__c);

        // RM SVG Node Association
        List<RM_Svg_Node_Association__c> rmsvgnodeassocs = [
            SELECT id, Relationship_Map__c
            FROM RM_Svg_Node_Association__c
        ];

        System.assertEquals(1, rmsvgnodeassocs.size());
        System.assertEquals(rmId, rmsvgnodeassocs[0].Relationship_Map__c);
    }

    // TEST Relationship types & relationships conversion
    @isTest
    static void convertKSToRMTest4() {
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        // Create Test Account
        Account a = new Account(Name = 'test account');
        insert a;

        Account_Plan__c ap1 = new Account_Plan__c(Account__c = a.Id, Name = 'Plan A');
        insert ap1;

        // Relationship Type
        Contact_Relationship_Type__c relType = new Contact_Relationship_Type__c(
            Name = 'Relationship',
            Color__c = '#0080ff',
            Label__c = 'relationship',
            Label_Editable__c = true,
            IsActive__c = true,
            Used_in_all_account_plans__c = true
        );
        insert relType;

        Relationship_Type_Account_Plan_Assoc__c rtapa = new Relationship_Type_Account_Plan_Assoc__c(
            Relationship_Type__c = relType.Id,
            Account_Plan__c = ap1.Id
        );
        insert rtapa;

        // Contact Relationships
        Contact jody = new Contact(LastName = 'jody');
        insert jody;
        Contact neil = new Contact(ReportsToId = jody.Id, LastName = 'neil');
        insert neil;
        Contact_Relationship__c cr1 = new Contact_Relationship__c(
            Account_Plan__c = ap1.Id,
            From_Contact__c = jody.Id,
            To_Contact__c = neil.Id
        );
        insert cr1;

        //-----------------------------------------------------------------------------
        // RUN POST INSTALL TEST

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        Test.startTest();
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(13, 9), false);
        }
        Test.stopTest();
        //-----------------------------------------------------------------------------

        List<Relationship_Map__c> rm = [SELECT id, name FROM Relationship_Map__c];
        System.assertEquals(1, rm.size());
        System.assertEquals('Plan A', rm[0].Name);

        Id rmId = rm[0].Id;

        //  Relationship Type Associations
        List<Relationship_Type_Map_Association__c> rttypemapassoc = [
            SELECT id, Relationship_Type__c, Relationship_Map__c
            FROM Relationship_Type_Map_Association__c
        ];

        System.assertEquals(1, rttypemapassoc.size());
        System.assertEquals(relType.Id, rttypemapassoc[0].Relationship_Type__c);
        System.assertEquals(rmId, rttypemapassoc[0].Relationship_Map__c);

        //  Contact Relationship
        List<Contact_Relationship__c> contactRels = [SELECT id, Relationship_Map__c FROM Contact_Relationship__c];

        System.assertEquals(1, contactRels.size());
        System.assertEquals(rmId, contactRels[0].Relationship_Map__c);
    }

    // Test Relationship Group, Anchors & Chart Settings
    @isTest
    static void convertKSToRMTest5() {
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        // Create Test Account
        Account a = new Account(Name = 'test account');
        insert a;

        Account_Plan__c ap1 = new Account_Plan__c(Account__c = a.Id, Name = 'Plan A');
        insert ap1;

        // Relationship Groups
        Relationship_Group__c newGroup = new Relationship_Group__c(
            Name = 'Group Name',
            Relationship_Map__c = null,
            Account_Plan__c = ap1.Id
        );
        insert newGroup;

        // Relationship Anchors
        RM_Anchor__c rmAnchor = new RM_Anchor__c(Relationship_Map__c = null, Account_Plan__c = ap1.Id);
        insert rmAnchor;

        // RM Chart Settings
        RM_Chart_Setting__c cs1 = new RM_Chart_Setting__c(Account_Plan__c = ap1.Id);
        insert cs1;

        //-----------------------------------------------------------------------------
        // RUN POST INSTALL TEST

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        Test.startTest();
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(13, 9), false);
        }
        Test.stopTest();
        //-----------------------------------------------------------------------------

        List<Relationship_Map__c> rm = [SELECT id, name FROM Relationship_Map__c];
        System.assertEquals(1, rm.size());
        System.assertEquals('Plan A', rm[0].Name);

        Id rmId = rm[0].Id;

        //  Relationship Groups
        List<Relationship_Group__c> rgroups = [SELECT id, Relationship_Map__c FROM Relationship_Group__c];

        System.assertEquals(1, rgroups.size());
        System.assertEquals(rmId, rgroups[0].Relationship_Map__c);

        //  Anchors
        List<RM_Anchor__c> anchors = [SELECT id, Relationship_Map__c FROM RM_Anchor__c];

        System.assertEquals(1, anchors.size());
        System.assertEquals(rmId, anchors[0].Relationship_Map__c);

        // RM Chart Settings
        List<RM_Chart_Setting__c> rmchartsettings = [SELECT id, Relationship_Map__c FROM RM_Chart_Setting__c];

        System.assertEquals(1, rmchartsettings.size());
        System.assertEquals(rmId, rmchartsettings[0].Relationship_Map__c);
    }

    // Test Place holders conversion
    @isTest
    static void convertKSToRMTest6() {
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        // Create Test Account
        Account a = new Account(Name = 'test account');
        insert a;

        Account_Plan__c ap1 = new Account_Plan__c(Account__c = a.Id, Name = 'Plan A');
        insert ap1;

        // Map Member Placeholders
        Map_Member_Placeholder__c mmp = new Map_Member_Placeholder__c(
            Name = 'label',
            Label__c = 'label',
            Description__c = 'desc',
            TempId__c = 'tempId',
            Account_Plan__c = ap1.Id,
            Relationship_Map__c = null
        );
        insert mmp;

        // Map Member Placeholder Relationships
        Map_Member_Placeholder_Relationship__c mmphr = new Map_Member_Placeholder_Relationship__c(
            Account_Plan__c = ap1.Id,
            Relationship_Map__c = null
        );
        insert mmphr;

        //-----------------------------------------------------------------------------
        // RUN POST INSTALL TEST

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        Test.startTest();
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(13, 9), false);
        }
        Test.stopTest();
        //-----------------------------------------------------------------------------

        List<Relationship_Map__c> rm = [SELECT id, name, Type_Setting__c FROM Relationship_Map__c];
        System.assertEquals(1, rm.size());
        System.assertEquals('Plan A', rm[0].Name);
        System.assertEquals('pqcrush__Account_Plan__c', rm[0].Type_Setting__c);

        Id rmId = rm[0].Id;

        //  Map Member Placeholder
        List<Map_Member_Placeholder__c> mmphs = [SELECT id, Relationship_Map__c FROM Map_Member_Placeholder__c];

        System.assertEquals(1, mmphs.size());
        System.assertEquals(rmId, mmphs[0].Relationship_Map__c);

        //  Map Member Placeholder Relationships
        List<Map_Member_Placeholder_Relationship__c> mmphrs = [
            SELECT id, Relationship_Map__c
            FROM Map_Member_Placeholder_Relationship__c
        ];

        System.assertEquals(1, mmphrs.size());
        System.assertEquals(rmId, mmphrs[0].Relationship_Map__c);
    }

    // Test Org_Chart_Field__c conversion
    @isTest
    static void convertKSToRMOrgChartFieldTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];

        // Org Chart Fields
        Org_Chart_Field__c apField = new Org_Chart_Field__c(
            pqcrush__FieldLabel__c = 'random field label',
            pqcrush__FieldName__c = 'testing_field_name__c',
            IsMain__c = true,
            Map_Type__c = 'Key Stakeholder',
            ObjectName__c = 'pqcrush__Key_Stakeholder__c'
        );
        Org_Chart_Field__c rmField = new Org_Chart_Field__c(
            pqcrush__FieldLabel__c = 'random field label RM',
            pqcrush__FieldName__c = 'testing_field_name_RM__c',
            IsMain__c = true,
            Map_Type__c = 'Relationship Map',
            ObjectName__c = 'pqcrush__Relationship_Map_Member__c'
        );
        insert new List<Org_Chart_Field__c>{ apField, rmField };

        //-----------------------------------------------------------------------------
        // RUN POST INSTALL TEST

        PostInstall postinstall = new PostInstall();
        postInstall.batchSize = 2000;
        Test.startTest();
        System.runAs(admin) {
            Test.testInstall(postinstall, new Version(13, 99), false);
        }
        Test.stopTest();
        //-----------------------------------------------------------------------------

        List<Org_Chart_Field__c> orgChartFields = [
            SELECT id, pqcrush__FieldLabel__c, pqcrush__FieldName__c, IsMain__c, Map_Type__c, ObjectName__c
            FROM Org_Chart_Field__c
        ];

        System.assertEquals(2, orgChartFields.size());
        for (Org_Chart_Field__c field : orgChartFields) {
            System.assertEquals('pqcrush__Relationship_Map_Member__c', field.ObjectName__c);
        }
    }

    // Test updateStakeholderAutoCreateSetting
    @isTest
    static void updateStakeholderAutoCreateSettingValidUpgradeTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];
        System.runAs(admin) {
            CRUSH_Settings_Obj__c orgSettings = new CRUSH_Settings_Obj__c();
            orgSettings.Type__c = 'Org';
            orgSettings.Auto_Create_Stakeholder_Maps__c = false;
            insert orgSettings;

            PostInstall postinstall = new PostInstall();
            Test.startTest();
            Test.testInstall(postinstall, new Version(15, 2), false);
            Test.stopTest();

            List<CRUSH_Settings_Obj__c> settings = [
                SELECT Id, Auto_Create_Stakeholder_Maps__c
                FROM CRUSH_Settings_Obj__c
            ];

            system.assertEquals(true, settings[0].Auto_Create_Stakeholder_Maps__c);
        }
    }

    @isTest
    static void updateStakeholderAutoCreateSettingLateUpgradeTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME LIMIT 1];
        System.runAs(admin) {
            CRUSH_Settings_Obj__c orgSettings = new CRUSH_Settings_Obj__c();
            orgSettings.Type__c = 'Org';
            orgSettings.Auto_Create_Stakeholder_Maps__c = false;
            insert orgSettings;

            PostInstall postinstall = new PostInstall();
            Test.startTest();
            Test.testInstall(postinstall, new Version(15, 5), false);
            Test.stopTest();

            List<CRUSH_Settings_Obj__c> settings = [
                SELECT Id, Auto_Create_Stakeholder_Maps__c
                FROM CRUSH_Settings_Obj__c
            ];

            system.assertEquals(false, settings[0].Auto_Create_Stakeholder_Maps__c);
        }
    }
}