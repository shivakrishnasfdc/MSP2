@isTest
private class OrgChartFieldSelectorTest {
    @testSetup
    static void setup() {
        // Create org chart fields
        List<Org_Chart_Field__c> testOrgChartFields = new List<Org_Chart_Field__c>();
        for (Integer i = 0; i < 3; i++) {
            testOrgChartFields.add(
                new Org_Chart_Field__c(
                    ObjectName__c = 'Test' + i,
                    FieldName__c = 'Test Ocf Field Label' + i,
                    FieldLabel__c = 'Test Ocf Field Name' + i,
                    Related_FieldName__c = 'Test Ocf Related Field Name' + i,
                    isRequired__c = false,
                    isVisible__c = true
                )
            );
        }
        insert testOrgChartFields;
    }

    @isTest
    static void selectByIdTest() {
        // Given
        Set<Id> givenOrgChartFieldIds = new Map<Id, Org_Chart_Field__c>([SELECT Id FROM Org_Chart_Field__c]).keySet();

        // When
        Test.startTest();

        List<Org_Chart_Field__c> orgChartFields = new OrgChartFieldSelector().selectById(givenOrgChartFieldIds);

        Test.stopTest();

        // Then
        Set<Id> orgChartFieldIds = new Map<Id, Org_Chart_Field__c>(orgChartFields).keyset();

        System.assertEquals(3, orgChartFields.size(), 'Expected 3 Org Chart Field records.');

        for (Id orgChartFieldId : givenOrgChartFieldIds) {
            System.assertEquals(true, orgChartFieldIds.contains(orgChartFieldId));
        }
    }

    @isTest
    static void selectByObjectNameAndMapTypeTest() {
        // Given
        String objectName = 'Test1';

        // When
        Test.startTest();

        List<Org_Chart_Field__c> orgChartFields = new OrgChartFieldSelector()
            .selectByObjectNameAndMapType(objectName, 'Key Stakeholder');

        Test.stopTest();

        // Then
        System.assertEquals(1, orgChartFields.size(), 'Expected 1 Org Chart Field record.');
        System.assertEquals(objectName, orgChartFields.get(0).ObjectName__c);
    }

    @isTest
    static void selectAllTest() {
        // When
        Test.startTest();

        List<Org_Chart_Field__c> orgChartFields = new OrgChartFieldSelector().selectAll();

        Test.stopTest();

        // Then
        System.assertEquals(3, orgChartFields.size(), 'Expected 3 Org Chart Field records.');
    }
}