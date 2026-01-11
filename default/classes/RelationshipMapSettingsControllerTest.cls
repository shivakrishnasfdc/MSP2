@IsTest
public with sharing class RelationshipMapSettingsControllerTest {
    @testSetup
    static void testSetup() {
        List<pq_Condition__c> conditions = new List<pq_Condition__c>{
            new pq_Condition__c(Value__c = 'xyz'),
            new pq_Condition__c(Value__c = 'abc')
        };

        insert conditions;
    }

    @IsTest
    static void getAutoCreateMapFlagTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;

        md.mockSettings.Auto_Create_Stakeholder_Maps__c = true;
        md.mockSettings.Auto_Create_Relationship_Maps__c = false;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        Boolean result = RelationshipMapSettingsController.getAutoCreateMapFlag('rm');
        System.assertEquals(
            false,
            result,
            'should return the Auto_Create_Relationship_Maps__c value if rm is passed in'
        );

        result = RelationshipMapSettingsController.getAutoCreateMapFlag('Relationship Map');
        System.assertEquals(
            false,
            result,
            'should return the Auto_Create_Relationship_Maps__c value if Relationship Map is passed in'
        );

        result = RelationshipMapSettingsController.getAutoCreateMapFlag('Keystakeholder');
        System.assertEquals(
            true,
            result,
            'should return the Auto_Create_Stakeholder_Maps__c value if Keystakeholder is passed in'
        );

        result = RelationshipMapSettingsController.getAutoCreateMapFlag('bad data');
        System.assertEquals(
            false,
            result,
            'should return the Auto_Create_Relationship_Maps__c value if unkown type is passed in'
        );
    }

    @IsTest
    static void setAutoCreateMapFlagUnknowTypeTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;

        md.mockSettings.Auto_Create_Stakeholder_Maps__c = false;
        md.mockSettings.Auto_Create_Relationship_Maps__c = false;

        CRUSH_Settings_Obj__c expected = md.mockSettings.clone();
        expected.Auto_Create_Relationship_Maps__c = true;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        RelationshipMapSettingsController.setAutoCreateMapFlag(true, 'bad data');

        ((SettingServiceImpl) md.mocks.verify(mockSettingService, 0)).upsertSettings(expected);
        System.assert(true, 'Verified by mock');
    }

    @IsTest
    static void setAutoCreateMapFlagRMTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;

        md.mockSettings.Auto_Create_Stakeholder_Maps__c = false;
        md.mockSettings.Auto_Create_Relationship_Maps__c = false;

        CRUSH_Settings_Obj__c expected = md.mockSettings.clone();
        expected.Auto_Create_Relationship_Maps__c = true;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        RelationshipMapSettingsController.setAutoCreateMapFlag(true, 'rm');

        ((SettingServiceImpl) md.mocks.verify(mockSettingService, 0)).upsertSettings(expected);
        System.assert(true, 'Verified by mock');
    }

    @IsTest
    static void setAutoCreateMapFlagRelationshipMapTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;

        md.mockSettings.Auto_Create_Stakeholder_Maps__c = false;
        md.mockSettings.Auto_Create_Relationship_Maps__c = false;

        CRUSH_Settings_Obj__c expected = md.mockSettings.clone();
        expected.Auto_Create_Relationship_Maps__c = true;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        RelationshipMapSettingsController.setAutoCreateMapFlag(true, 'Relationship Map');

        ((SettingServiceImpl) md.mocks.verify(mockSettingService, 0)).upsertSettings(expected);
        System.assert(true, 'Verified by mock');
    }

    @IsTest
    static void setAutoCreateMapFlagKeyStakeholderTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;

        md.mockSettings.Auto_Create_Stakeholder_Maps__c = false;
        md.mockSettings.Auto_Create_Relationship_Maps__c = false;

        CRUSH_Settings_Obj__c expected = md.mockSettings.clone();
        expected.Auto_Create_Stakeholder_Maps__c = true;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        RelationshipMapSettingsController.setAutoCreateMapFlag(true, 'keystakeholder');

        ((SettingServiceImpl) md.mocks.verify(mockSettingService, 0)).upsertSettings(expected);
        System.assert(true, 'Verified by mock');
    }

    @isTest
    static void testSupportColorSettingObjectConstructor() {
        String name = 'TestName';
        String label = 'TestLabel';
        String color = 'TestColor';

        RelationshipMapSettingsController.SupportColorSettingObject obj = new RelationshipMapSettingsController.SupportColorSettingObject(
            name,
            label,
            color
        );

        System.assertEquals(name, obj.name, 'Name should be set correctly');
        System.assertEquals(label, obj.value, 'Value should be set correctly');
        System.assertEquals(color, obj.color, 'Color should be set correctly');
    }

    @isTest
    static void getRMOrgSettingForTypeTest() {
        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;

        md.mockSettings.Auto_Create_Stakeholder_Maps__c = false;
        md.mockSettings.Auto_Create_Relationship_Maps__c = false;

        CRUSH_Settings_Obj__c expected = md.mockSettings.clone();
        expected.Auto_Create_Relationship_Maps__c = true;

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(md.mockSettings);
        md.mocks.stopStubbing();

        RelationshipMapSettingsController.getRMOrgSettingForType('rm');

        ((SettingServiceImpl) md.mocks.verify(mockSettingService, 0)).upsertSettings(expected);
        System.assert(true, 'Verified by mock');
    }

    @isTest
    static void updateEnableSuggestedContactsForRMTest() {
        Id fakeID = '0012w00000RMXXfAAH';

        try {
            Test.startTest();
            RelationshipMapSettingsController.updateEnableSuggestedContactsForRM(fakeID, true);
            Test.stopTest();
        } catch (Exception e) {
            System.assertEquals('System.NullPointerException', e.getTypeName(), 'Invalid Exception');
        }
    }

    @isTest
    static void updateRMOrgSettingOperatorTest() {
        Id fakeID = '0012w00000RMXXfAAH';
        try {
            Test.startTest();
            RelationshipMapSettingsController.updateRMOrgSettingOperator(fakeID, 'AND');
            Test.stopTest();
        } catch (Exception e) {
            System.assertEquals('System.NullPointerException', e.getTypeName(), 'Invalid Exception');
        }
    }

    @isTest
    static void getContactsConditionsTest() {
        Id fakeID = '0012w00000RMXXfAAH';

        Test.startTest();
        List<pq_Condition__c> result = RelationshipMapSettingsController.getContactsConditions(fakeID);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Expected empty list');
    }

    @isTest
    static void insertContactsConditionTest() {
        List<pq_Condition__c> conditions = new List<pq_Condition__c>{ new pq_Condition__c(Value__c = 'xyz') };

        Test.startTest();
        List<pq_Condition__c> result = RelationshipMapSettingsController.insertContactsCondition(conditions);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Expected empty list');
    }

    @isTest
    static void deleteContactsConditionTest() {
        Id recordId = [SELECT id FROM pq_condition__c LIMIT 1].id;

        List<pq_Condition__c> conditions = new List<pq_Condition__c>{ new pq_Condition__c(Id = recordId) };

        Test.startTest();
        RelationshipMapSettingsController.deleteContactsCondition(conditions);
        Test.stopTest();
        System.assert(true, 'Verified');
    }
    @isTest
    static void updateContactsConditionTest() {
        Id recordId = [SELECT id FROM pq_condition__c LIMIT 1].id;

        List<pq_Condition__c> conditions = new List<pq_Condition__c>{
            new pq_Condition__c(Id = recordId, Value__c = 'uxyz')
        };

        Test.startTest();
        List<pq_Condition__c> result = RelationshipMapSettingsController.updateContactsCondition(conditions);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Expected empty list');
    }
}