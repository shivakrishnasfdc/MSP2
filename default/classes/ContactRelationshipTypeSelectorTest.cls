@isTest
private class ContactRelationshipTypeSelectorTest {
    public static final String ADMIN_USER1_FIRST_NAME = 'SamStandard';
    public static final String ADMIN_USER1_LAST_NAME = 'Sunlock';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

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
            TestDataFactory.createContactRelationshipType('#ff0000', 'red', true, true);
            TestDataFactory.createContactRelationshipType('#00ff00', 'green', true, true);
            TestDataFactory.createContactRelationshipType('#0000ff', 'blue', true, false);
        }
    }

    @isTest
    static void newInstanceTest() {
        ContactRelationshipTypeSelector selector = ContactRelationshipTypeSelector.newInstance();

        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectAllTest() {
        User adminUser1 = [SELECT Id FROM User WHERE LastName = :ADMIN_USER1_LAST_NAME];
        List<Contact_Relationship_Type__c> types = [
            SELECT Id, IsActive__c
            FROM Contact_Relationship_Type__c
            WHERE IsActive__c = TRUE
        ];

        List<Contact_Relationship_Type__c> contactRelationshipTypes;

        Test.startTest();
        System.runAs(adminUser1) {
            contactRelationshipTypes = new ContactRelationshipTypeSelector().selectAll();
        }
        Test.stopTest();

        System.assertEquals(types.size(), contactRelationshipTypes.size());
    }

    @isTest
    static void selectByRelationshipMapsTest() {
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');

        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('mymap');
        Relationship_Map__c rm2 = TestDataFactory.createRelationshipMap('mymap2');

        rm.pq_AccountPlanId__c = ap.Id;

        Contact_Relationship_Type__c relType1 = TestDataFactory.createContactRelationshipType(
            '#ffffff',
            'label1',
            true,
            true
        );
        Contact_Relationship_Type__c relType2 = TestDataFactory.createContactRelationshipType(
            '#ffffff',
            'label2',
            true,
            true
        );
        Contact_Relationship_Type__c relType3 = TestDataFactory.createContactRelationshipType(
            '#ffffff',
            'label2',
            true,
            true
        );

        TestDataFactory.createRelTypeMapAssociation(rm, relType1);
        TestDataFactory.createRelTypeAccountPlanAssociation(ap, relType3);
        TestDataFactory.createRelTypeMapAssociation(rm2, relType2);

        Test.startTest();
        List<Contact_Relationship_Type__c> result = new ContactRelationshipTypeSelector()
            .selectByRelationshipMaps(new Set<Id>{ rm.Id }, true, ap.Id);
        Test.stopTest();

        System.assertEquals(2, result.size());
        System.assert(relType1.Id == result[0].Id || relType3.Id == result[0].Id);
        System.assert(relType1.Id == result[1].Id || relType3.Id == result[1].Id);
    }

    @isTest
    static void selectByAccountPlansTest() {
        Application.bypassTrigger = true;
        Account newAccount = TestDataFactory.createAccount('testAccount');
        Account_Plan__c plan = TestDataFactory.createAccountPlan('myplan', newAccount);
        Account_Plan__c plan2 = TestDataFactory.createAccountPlan('myplan2', newAccount);

        Contact_Relationship_Type__c relType1 = TestDataFactory.createContactRelationshipType(
            '#ffffff',
            'label1',
            true,
            true
        );
        Contact_Relationship_Type__c relType2 = TestDataFactory.createContactRelationshipType(
            '#ffffff',
            'label2',
            true,
            true
        );
        Contact_Relationship_Type__c relType3 = TestDataFactory.createContactRelationshipType(
            '#ffffff',
            'label2',
            true,
            true
        );

        TestDataFactory.createRelTypeAccountPlanAssociation(plan, relType1);
        TestDataFactory.createRelTypeAccountPlanAssociation(plan, relType3);
        TestDataFactory.createRelTypeAccountPlanAssociation(plan2, relType2);

        Test.startTest();
        List<Contact_Relationship_Type__c> result = new ContactRelationshipTypeSelector()
            .selectByAccountPlans(new Set<Id>{ plan.Id });
        Test.stopTest();

        System.assertEquals(2, result.size());
        System.assert(relType1.Id == result[0].Id || relType3.Id == result[0].Id);
        System.assert(relType1.Id == result[1].Id || relType3.Id == result[1].Id);
    }

    @isTest
    static void getRelationshipTypesFromJunctionTestForRM() {
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');
        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('mymap');
        Relationship_Map__c rm2 = TestDataFactory.createRelationshipMap('mymap2');
        rm.pq_AccountPlanId__c = ap.Id;
        update rm;

        Contact_Relationship_Type__c relType1 = TestDataFactory.createContactRelationshipType(
            '#ffffff',
            'label1',
            true,
            true
        );
        Contact_Relationship_Type__c relType2 = TestDataFactory.createContactRelationshipType(
            '#ffffff',
            'label2',
            true,
            true
        );
        Contact_Relationship_Type__c relType3 = TestDataFactory.createContactRelationshipType(
            '#ffffff',
            'label2',
            true,
            true
        );

        TestDataFactory.createRelTypeMapAssociation(rm, relType1);
        TestDataFactory.createRelTypeAccountPlanAssociation(ap, relType3);
        TestDataFactory.createRelTypeMapAssociation(rm2, relType2);

        Test.startTest();
        Set<Id> result = ContactRelationshipTypeSelector.newInstance().getRelationshipTypesFromJunction(rm.Id);
        Test.stopTest();

        System.assertEquals(2, result.size());
        System.assert(result.contains(relType1.Id));
        System.assert(result.contains(relType3.Id));
    }

    @isTest
    static void getRelationshipTypesFromJunctionTestForAccountPlan() {
        Application.bypassTrigger = true;
        Account newAccount = TestDataFactory.createAccount('testAccount');
        Account_Plan__c plan = TestDataFactory.createAccountPlan('myplan', newAccount);
        Account_Plan__c plan2 = TestDataFactory.createAccountPlan('myplan2', newAccount);

        Contact_Relationship_Type__c relType1 = TestDataFactory.createContactRelationshipType(
            '#ffffff',
            'label1',
            true,
            true
        );
        Contact_Relationship_Type__c relType2 = TestDataFactory.createContactRelationshipType(
            '#ffffff',
            'label2',
            true,
            true
        );
        Contact_Relationship_Type__c relType3 = TestDataFactory.createContactRelationshipType(
            '#ffffff',
            'label2',
            true,
            true
        );

        TestDataFactory.createRelTypeAccountPlanAssociation(plan, relType1);
        TestDataFactory.createRelTypeAccountPlanAssociation(plan, relType3);
        TestDataFactory.createRelTypeAccountPlanAssociation(plan2, relType2);

        Test.startTest();
        Set<Id> result = ContactRelationshipTypeSelector.newInstance().getRelationshipTypesFromJunction(plan.Id);
        Test.stopTest();

        System.assertEquals(2, result.size());
        System.assert(result.contains(relType1.Id));
        System.assert(result.contains(relType3.Id));
    }
}