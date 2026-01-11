@isTest
private class LeadSelectorTest {
    @isTest
    static void selectByIdTest() {
        // Given

        Lead l1 = TestDataFactory.createLead('fname', 'lname', 'acme');
        Lead l2 = TestDataFactory.createLead('fname2', 'lname2', 'acme2');
        TestDataFactory.createLead('fname3', 'lname3', 'acme3');

        // When
        Test.startTest();

        List<Lead> leads = new LeadSelector().selectById(new Set<Id>{ l1.Id, l2.Id });

        Test.stopTest();

        // Then

        System.assertEquals(2, leads.size(), 'Expected 2 Contact records.');
        System.assert(l1.Id == leads[0].Id || l2.Id == leads[0].Id);
        System.assert(l1.Id == leads[1].Id || l2.Id == leads[1].Id);
    }

    @isTest
    static void selectNonConvertedWithAdditionalFieldsTest() {
        // Given

        Lead l1 = TestDataFactory.createLead('fname', 'lname', 'acme');
        Lead l2 = TestDataFactory.createLead('fname2', 'lname2', 'acme2');
        Lead l3 = TestDataFactory.createLead('fname3', 'lname3', 'acme3');

        // When
        Test.startTest();

        List<Lead> leads = new LeadSelector()
            .selectNonConvertedWithAdditionalFields(new Set<Id>{ l3.Id }, new Set<String>(), 300);

        Test.stopTest();

        // Then

        System.assertEquals(2, leads.size(), 'Expected 2 Contact records.');
        System.assert(l1.Id == leads[0].Id || l2.Id == leads[0].Id);
        System.assert(l1.Id == leads[1].Id || l2.Id == leads[1].Id);
    }

    @isTest
    static void selectNonConvertedWithAdditionalFieldsMaxTest() {
        // Given

        TestDataFactory.createLead('fname', 'lname', 'acme');
        TestDataFactory.createLead('fname2', 'lname2', 'acme2');
        TestDataFactory.createLead('fname3', 'lname3', 'acme3');

        // When
        Test.startTest();

        List<Lead> leads = new LeadSelector()
            .selectNonConvertedWithAdditionalFields(new Set<Id>(), new Set<String>(), 1);

        Test.stopTest();

        // Then

        System.assertEquals(1, leads.size(), 'Expected one Contact record.');
    }

    @isTest
    static void searchBlankTest() {
        // Given

        TestDataFactory.createLead('fname', 'lname', 'acme');
        TestDataFactory.createLead('fname2', 'lname2', 'acme2');
        TestDataFactory.createLead('fname3', 'lname3', 'acme3');

        // When
        Test.startTest();

        List<Lead> leads = new LeadSelector().search('', new Set<Id>(), new Set<String>(), 200);

        Test.stopTest();

        // Then

        System.assertEquals(0, leads.size(), 'Expected no Lead records.');
    }

    @isTest
    static void searchMaxZeroTest() {
        // Given

        TestDataFactory.createLead('fname', 'lname', 'acme');
        TestDataFactory.createLead('fname2', 'lname2', 'acme2');
        TestDataFactory.createLead('fname3', 'lname3', 'acme3');

        // When
        Test.startTest();

        List<Lead> leads = new LeadSelector().search('fname3', new Set<Id>(), new Set<String>(), 0);

        Test.stopTest();

        // Then

        System.assertEquals(0, leads.size(), 'Expected 0 Lead records.');
    }

    @isTest
    static void searchTest() {
        // Given
        Lead l1 = TestDataFactory.createLead('loo', 'lname', 'acme');
        TestDataFactory.createLead('lemon', 'lname2', 'divisio');
        TestDataFactory.createLead('orange', 'lname3', 'helipad');

        String query = 'emon';
        Set<Id> excludedIds = new Set<Id>();
        Set<String> additionalFields = new Set<String>();
        Integer maxResult = 100;

        Test.setFixedSearchResults(new List<String>{ l1.Id });

        // When
        Test.startTest();
        List<Lead> leads = LeadSelector.newInstance().search(query, excludedIds, additionalFields, maxResult);
        Test.stopTest();

        // Then
        System.assertEquals(1, leads.size(), 'Expected 1 Lead record.');
    }
}