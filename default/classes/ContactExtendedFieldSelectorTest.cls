@isTest
private class ContactExtendedFieldSelectorTest {
    @testSetup
    static void testSetup() {
        pq_Influence__c i1 = new pq_Influence__c(Name = 'Low', Label__c = 'lowlabel');
        insert i1;
        pq_Support__c s1 = new pq_Support__c(Name = 'Champion', Label__c = 'champlabel', Color__c = '#ff0011');
        insert s1;

        Account acct = new Account(Name = 'testaccount');
        insert acct;

        Contact testContact1 = new Contact(
            LastName = 'Hudson',
            MobilePhone = '123-456-6789',
            Email = 'a@acme.com',
            AccountId = acct.Id
        );
        insert testContact1;

        Contact testContact2 = new Contact(
            LastName = 'Terry',
            MobilePhone = '123-456-6789',
            Email = 'a@acme.com',
            ReportsToId = testContact1.Id
        );
        insert testContact2;

        Contact testContact3 = new Contact(
            LastName = 'Cruz',
            MobilePhone = '123-456-6789',
            Email = 'a@acme.com',
            ReportsToId = testContact1.Id
        );
        insert testContact3;

        Contact_Extended_Field__c cef1 = new Contact_Extended_Field__c(
            Contact__c = testContact1.Id,
            Profile_Picture_Data__c = 'abc',
            Influence__c = i1.Id,
            Support__c = s1.Id
        );
        insert cef1;

        Contact_Extended_Field__c cef2 = new Contact_Extended_Field__c(
            Contact__c = testContact2.Id,
            Profile_Picture_Data__c = 'xyz',
            Influence__c = i1.Id,
            Support__c = s1.Id
        );
        insert cef2;
    }

    @isTest
    static void selectByContactIdAllRecordsTest() {
        // Given
        Contact c1 = [SELECT Id FROM Contact WHERE LastName = 'Hudson' LIMIT 1];
        Contact c2 = [SELECT Id FROM Contact WHERE LastName = 'Terry' LIMIT 1];

        // When
        Test.startTest();
        List<Contact_Extended_Field__c> contactExtendedFields = new ContactExtendedFieldSelector()
            .selectByContactId(new Set<Id>{ c1.Id, c2.Id });
        Test.stopTest();

        // Then
        System.assertEquals(2, contactExtendedFields.size(), 'Should return all that were asked for');
    }

    @isTest
    static void selectByContactIdMixedRecordsTest() {
        // Given
        Contact c1 = [SELECT Id FROM Contact WHERE LastName = 'Hudson' LIMIT 1];
        Contact c2 = [SELECT Id FROM Contact WHERE LastName = 'Cruz' LIMIT 1];

        // When
        Test.startTest();
        List<Contact_Extended_Field__c> contactExtendedFields = new ContactExtendedFieldSelector()
            .selectByContactId(new Set<Id>{ c1.Id, c2.Id });
        Test.stopTest();

        // Then
        System.assertEquals(
            1,
            contactExtendedFields.size(),
            'Expected only one contact extended fields record since one doesn\'t have one'
        );
    }

    @isTest
    static void selectByContactIdSingleRecordTest() {
        // Given
        Contact c1 = [SELECT Id FROM Contact WHERE LastName = 'Hudson' LIMIT 1];

        // When
        Test.startTest();
        List<Contact_Extended_Field__c> contactExtendedFields = new ContactExtendedFieldSelector()
            .selectByContactId(new Set<Id>{ c1.Id });
        Test.stopTest();

        // Then
        System.assertEquals(1, contactExtendedFields.size(), 'Should only return the one asked for');
        System.assertEquals('Low', contactExtendedFields[0].Influence__r.Name);
        System.assertEquals('lowlabel', contactExtendedFields[0].Influence__r.Label__c);
        System.assertEquals('Champion', contactExtendedFields[0].Support__r.Name);
        System.assertEquals('champlabel', contactExtendedFields[0].Support__r.Label__c);
        System.assertEquals('#ff0011', contactExtendedFields[0].Support__r.Color__c);
    }
}