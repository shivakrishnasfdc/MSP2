@isTest
private with sharing class WSCellRelationshipConfigSelectorTest {
    private static final String ADMIN_USER_LAST_NAME = 'wscrcs_Admin_Last';
    private static final String STANDARD_USER_LAST_NAME = 'wscrcs_Standard_Last';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User admin = TestDataFactory.createUser('user', ADMIN_USER_LAST_NAME, standardProfile.Id);
        User standard = TestDataFactory.createUser('user', STANDARD_USER_LAST_NAME, standardProfile.Id);

        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'CRUSH_Administrator'];
        PermissionSet standardUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'CRUSH_Standard_User'];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = admin.Id, PermissionSetId = adminUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = standard.Id, PermissionSetId = standardUserPermissionSet.Id)
        };

        System.runAs(admin) {
            Cell_Relationship_Configuration__c config1 = new Cell_Relationship_Configuration__c();
            config1.Object_API_Name__c = 'Contact';
            config1.Color__c = '#FFF';
            config1.Display_Field__c = 'Name';

            Cell_Relationship_Configuration__c config2 = new Cell_Relationship_Configuration__c();
            config2.Object_API_Name__c = 'Account';
            config2.Color__c = '#000';
            config2.Display_Field__c = 'Type';

            insert new List<Cell_Relationship_Configuration__c>{ config1, config2 };
        }
    }

    @isTest
    static void newInstanceTest() {
        WSCellRelationshipConfigSelector selector = WSCellRelationshipConfigSelector.newInstance();
        System.assertNotEquals(null, selector, 'Selector should be returned');
        System.assertEquals(
            Cell_Relationship_Configuration__c.sObjectType,
            selector.getSObjectType(),
            'Selector should be for expected object type'
        );
        System.assertEquals(
            4,
            selector.getSObjectFieldList().size(),
            'Selector should have expected number of fields in fieldList'
        );
        System.assert(
            selector.getSObjectFieldList().contains(Cell_Relationship_Configuration__c.Id),
            'Selector\'s fieldList should contain Id field'
        );
        System.assert(
            selector.getSObjectFieldList().contains(Cell_Relationship_Configuration__c.Object_API_Name__c),
            'Selector\'s fieldList should contain Object_API_Name__c field'
        );
        System.assert(
            selector.getSObjectFieldList().contains(Cell_Relationship_Configuration__c.Color__c),
            'Selector\'s fieldList should contain Color__c field'
        );
        System.assert(
            selector.getSObjectFieldList().contains(Cell_Relationship_Configuration__c.Display_Field__c),
            'Selector\'s fieldList should contain Display_Field__c field'
        );
    }

    @isTest
    static void selectAllTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        User standard = [SELECT Id FROM User WHERE LastName = :STANDARD_USER_LAST_NAME];
        List<Cell_Relationship_Configuration__c> result;

        System.runAs(admin) {
            result = WSCellRelationshipConfigSelector.newInstance().selectAll();
        }
        System.assertEquals(2, result.size(), 'Admin user should return two configs');

        System.runAs(standard) {
            result = WSCellRelationshipConfigSelector.newInstance().selectAll();
        }
        System.assertEquals(2, result.size(), 'Standard user should return two configs');
    }

    @isTest
    static void selectByObjectNameTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        List<Cell_Relationship_Configuration__c> result;

        System.runAs(admin) {
            result = WSCellRelationshipConfigSelector.newInstance().selectByObjectName(new Set<String>{ 'Account' });
        }
        System.assertEquals(1, result.size(), 'should return one config (Account)');

        System.runAs(admin) {
            result = WSCellRelationshipConfigSelector.newInstance()
                .selectByObjectName(new Set<String>{ 'Account', 'Contact' });
        }
        System.assertEquals(2, result.size(), 'should rreturn two configs (Account and Contact)');

        System.runAs(admin) {
            result = WSCellRelationshipConfigSelector.newInstance()
                .selectByObjectName(new Set<String>{ 'Account', 'Contact', 'Lead' });
        }
        System.assertEquals(2, result.size(), 'should rreturn two configs (Lead won\'t match)');
    }
}