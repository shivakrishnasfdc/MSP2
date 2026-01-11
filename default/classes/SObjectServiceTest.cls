@isTest
private class SObjectServiceTest {
    @isTest
    static void getSObjectTypeTest() {
        Schema.SobjectType result1 = SObjectService.getSObjectType('Contact');
        Schema.SobjectType result2 = SObjectService.getSObjectType('Account');
        Schema.SobjectType result3 = SObjectService.getSObjectType('Opportunity');
        Schema.SobjectType result4 = SObjectService.getSObjectType('Lead');
        Schema.SobjectType result5 = SObjectService.getSObjectType('');
        Schema.SobjectType result6 = SObjectService.getSObjectType('pqcrush__Relationship_Map__c');

        // Then
        System.assertEquals(Contact.sObjectType, result1);
        System.assertEquals(Account.sObjectType, result2);
        System.assertEquals(Opportunity.sObjectType, result3);
        System.assertEquals(Lead.sObjectType, result4);
        System.assertEquals(null, result5);
        System.assertEquals(Relationship_Map__c.sObjectType, result6);
    }

    @isTest
    static void relationshipsFromDescribeMatchingObjectTypeTest() {
        Set<Schema.SObjectField> result1 = SObjectService.relationshipsFromDescribeMatchingObjectType(
            Contact.getSObjectType().getDescribe(),
            Account.getSObjectType()
        );
        Set<Schema.SObjectField> result2 = SObjectService.relationshipsFromDescribeMatchingObjectType(
            Account.getSObjectType().getDescribe(),
            User.getSObjectType()
        );

        // Then
        System.assert(
            result1.contains(Contact.AccountId),
            'Contacts should have an AccountId field relating to Accounts'
        );
        System.assert(
            result2.contains(Account.CreatedById),
            'Accounts should have a CreatedById  field relating to Users'
        );
        System.assert(
            result2.contains(Account.LastModifiedById),
            'Accounts should have a LastModifiedById  field relating to Users'
        );
        System.assert(result2.contains(Account.OwnerId), 'Accounts should have a OwnerId  field relating to Users');
        // Size checks include greater than otherwise they could fail in a customer org if they have customizations
        System.assert(result1.size() >= 1, 'Contacts only have one relationship to Accounts');
        System.assert(
            result2.size() >= 3,
            'Accounts have three relationships to Users (CreatedById, LastModifiedById, OwnerId)()'
        );
    }

    @isTest
    static void getObjectsRelatedToTest() {
        Set<Schema.SObjectType> result = SObjectService.getObjectsRelatedTo(Account.getSObjectType());

        // Then
        System.assert(
            result.contains(Contact.getSObjectType()),
            'Contacts should have an AccountId field relating to Accounts'
        );

        System.assert(
            result.contains(Opportunity.getSObjectType()),
            'Opportunities should have an AccountId field relating to Accounts'
        );
    }

    // Get ALL contacts related to an account
    @isTest
    static void getIdsForRelatedObjectsTest() {
        Account a = new Account(name = 'test');
        insert a;
        Account b = new Account(name = 'test2');
        insert b;
        Contact c1 = new Contact(LastName = 'contact1', AccountId = a.Id);
        insert c1;
        Contact c2 = new Contact(LastName = 'contact2', AccountId = a.Id);
        insert c2;
        Contact c3 = new Contact(LastName = 'contact3', AccountId = b.Id);
        insert c3;

        Set<Id> result = SObjectService.getIdsForRelatedObjects(
            a.Id,
            new List<Schema.sObjectType>{ Contact.getSObjectType() }
        );

        // Then
        System.assertEquals(2, result.size());
        System.assert(result.contains(c1.Id));
        System.assert(result.contains(c2.Id));
    }

    @isTest
    static void getIdsForRelatedObjectsNullTest() {
        Set<Id> result = SObjectService.getIdsForRelatedObjects(
            null,
            new List<Schema.sObjectType>{ Contact.getSObjectType() }
        );

        // Then
        System.assertEquals(0, result.size());
    }

    @isTest
    static void getIdsForRelatedObjectsSameTypeTest() {
        Account a = new Account(name = 'test');
        insert a;
        Contact c1 = new Contact(LastName = 'contact1', AccountId = a.Id);
        insert c1;

        Set<Id> result = SObjectService.getIdsForRelatedObjects(
            c1.Id,
            new List<Schema.sObjectType>{ Contact.getSObjectType() }
        );

        // Then
        System.assertEquals(0, result.size());
    }

    @isTest
    static void getDescribeFieldMapsForFieldsTest() {
        Map<String, FieldMetaData> result = SObjectService.getDescribeFieldMapsForFields(
            Key_Stakeholder__c.SObjectType,
            new List<String>{ 'CreatedDate', 'pqcrush__Account_Plan__c' }
        );

        FieldMetaData apField = result.get('pqcrush__Account_Plan__c');
        FieldMetaData createdDateField = result.get('CreatedDate');

        System.assertEquals(2, result.size());
        System.assert(result.containsKey('CreatedDate'));
        System.assert(result.containsKey('pqcrush__Account_Plan__c'));
        System.assertEquals('Account Plan', apField.label);
        System.assertEquals('Created Date', createdDateField.label);
        System.assertEquals('DATETIME', createdDateField.displayType);
    }

    @isTest
    static void getDescribeFieldMapsForFieldsNullTest() {
        Map<String, FieldMetaData> result = SObjectService.getDescribeFieldMapsForFields(
            Key_Stakeholder__c.SObjectType,
            null
        );

        System.assertEquals(0, result.size());
    }

    @isTest
    static void hasRecordTypeEnabledTest() {
        SObjectService.hasRecordTypeEnabled(Contact.SObjectType);

        System.assert(true, 'This should not throw any errors.');
    }

    @isTest
    static void getCustomFieldsTest() {
        SObjectService.getCustomFields(Key_Stakeholder__c.SObjectType, false);
        SObjectService.getCustomFields(Key_Stakeholder__c.SObjectType, true);

        System.assert(true, 'This should not throw any errors.');
    }
}