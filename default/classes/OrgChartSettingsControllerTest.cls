@SuppressWarnings('PMD.NcssMethodCount,PMD.CyclomaticComplexity')
@isTest
private class OrgChartSettingsControllerTest {
    public static final String STANDARD_USER_FIRST_NAME = 'Alex';
    public static final String STANDARD_USER_LAST_NAME = 'Allen';

    public static final String ADMIN_USER_FIRST_NAME = 'Crispy';
    public static final String ADMIN_USER_LAST_NAME = 'Creme';

    public static final String RM_STANDARD_USER_FIRST_NAME = 'RM_Alex';
    public static final String RM_STANDARD_USER_LAST_NAME = 'RM_Allen';

    public static final String RM_ADMIN_USER_FIRST_NAME = 'RM_Crispy';
    public static final String RM_ADMIN_USER_LAST_NAME = 'RM_Creme';

    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';
    public static final String RM_STANDARD_USER = 'PROLIFIQ_RELATIONSHIP_MAP_Standard_User';
    public static final String RM_ADMINISTRATOR = 'PROLIFIQ_RELATIONSHIP_MAP';

    public static final String CONTACT_OBJECT_NAME = 'Contact';
    public static final String KSH_OBJECT_NAME = 'Relationship_Map_Member__c';

    public static final List<String> TEST_FIELDS = new List<String>{ 'FirstName', 'LastName', 'Title' };

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User standardUser = TestDataFactory.createUser(
            STANDARD_USER_FIRST_NAME,
            STANDARD_USER_LAST_NAME,
            standardProfile.Id
        );
        PermissionSet standardUserPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = :CRUSH_STANDARD_USER
            LIMIT 1
        ];

        User adminUser = TestDataFactory.createUser(ADMIN_USER_FIRST_NAME, ADMIN_USER_LAST_NAME, standardProfile.Id);
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR LIMIT 1];

        User rmStanUser = TestDataFactory.createUser(
            RM_STANDARD_USER_FIRST_NAME,
            RM_STANDARD_USER_LAST_NAME,
            standardProfile.Id
        );
        PermissionSet rmStanUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :RM_STANDARD_USER LIMIT 1];

        User rmAdminUser = TestDataFactory.createUser(
            RM_ADMIN_USER_FIRST_NAME,
            RM_ADMIN_USER_LAST_NAME,
            standardProfile.Id
        );
        PermissionSet rmAdminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :RM_ADMINISTRATOR LIMIT 1];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = standardUser.Id, PermissionSetId = standardUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = adminUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = rmStanUser.Id, PermissionSetId = rmStanUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = rmAdminUser.Id, PermissionSetId = rmAdminUserPermissionSet.Id)
        };
    }

    @isTest
    static void getKSObjectFieldsStandardUserTest() {
        // Given
        User standardUser = [SELECT Id FROM User WHERE LastName = :STANDARD_USER_LAST_NAME];

        Schema.DescribeSObjectResult contactDescription = Schema.SObjectType.Contact;
        Schema.DescribeSObjectResult kshDescription;
        List<Schema.SObjectField> contactFields = new List<Schema.SObjectField>();
        List<Schema.SObjectField> kshFields = new List<Schema.SObjectField>();
        System.runAs(standardUser) {
            Map<String, Schema.SObjectField> fieldDescribeTokens = contactDescription.fields.getMap();
            List<Schema.SObjectField> allContactFields = fieldDescribeTokens.values();
            for (Integer i = allContactFields.size() - 1; i >= 0; i--) {
                Schema.SObjectField field = allContactFields.get(i);
                Schema.DescribeFieldResult dfr = field.getDescribe();
                if (dfr.isAccessible() == false) {
                    continue;
                }

                if (dfr.getType().name() == 'REFERENCE') {
                    if (dfr.isNamePointing()) {
                        continue;
                    }

                    String refObjectName = null;

                    for (Schema.SObjectType reference : dfr.getReferenceTo()) {
                        refObjectName = reference.getDescribe().getName();
                    }

                    // We are only showing the related Account (remove the comparing to account to show all)
                    if (refObjectName == null || !refObjectName.equalsIgnoreCase('account')) {
                        continue;
                    }
                    for (Schema.SObjectField accField : Schema.SObjectType.Account.fields.getMap().values()) {
                        Schema.DescribeFieldResult accDfr = accField.getDescribe();
                        if (accDfr.isAccessible() && (accDfr.getType().name() == 'ID' || accDfr.isNameField())) {
                            contactFields.add(accField);
                        }
                    }
                } else {
                    contactFields.add(field);
                }
            }

            kshDescription = Schema.describeSObjects(new List<String>{ KSH_OBJECT_NAME }).get(0);
            List<Schema.SObjectField> allKSHFields = kshDescription.fields.getMap().values();
            for (Integer i = allKSHFields.size() - 1; i >= 0; i--) {
                Schema.SObjectField field = allKSHFields.get(i);
                if (
                    field.getDescribe().isAccessible() == false ||
                    field.getDescribe().getType().name() == 'REFERENCE' ||
                    field.getDescribe().getName() == 'influence__c' ||
                    field.getDescribe().getName() == 'support__c' ||
                    field.getDescribe().getName() == 'pqcrush__influence__c' ||
                    field.getDescribe().getName() == 'pqcrush__support__c'
                ) {
                    continue;
                }
                kshFields.add(field);
            }
        }

        List<ObjectDescriptionWrapper> results;

        // When
        Test.startTest();

        System.runAs(standardUser) {
            results = OrgChartSettingsController.getKSObjectFields('accountrelation');
        }

        Test.stopTest();

        // Then
        ObjectDescriptionWrapper contactResult = results.get(0);
        ObjectDescriptionWrapper kshResult = results.get(1);
        system.assertEquals(2, results.size());
        system.assertEquals(contactDescription.getName(), contactResult.objectName);
        system.assertEquals(contactDescription.getLabel(), contactResult.objectLabel);
        system.assertEquals(contactFields.size(), contactResult.fields.size());
        system.assertEquals(kshDescription.getName(), kshResult.objectName);
        system.assertEquals(kshDescription.getLabel(), kshResult.objectLabel);
        system.assertEquals(kshFields.size(), kshResult.fields.size());
    }

    @isTest
    static void getKSObjectFieldsAdminUserTest() {
        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];

        Schema.DescribeSObjectResult contactDescription = Schema.SObjectType.Contact;
        Schema.DescribeSObjectResult kshDescription;
        List<Schema.SObjectField> contactFields = new List<Schema.SObjectField>();
        List<Schema.SObjectField> kshFields = new List<Schema.SObjectField>();
        System.runAs(adminUser) {
            Map<String, Schema.SObjectField> fieldDescribeTokens = contactDescription.fields.getMap();
            List<Schema.SObjectField> allContactFields = fieldDescribeTokens.values();
            for (Integer i = allContactFields.size() - 1; i >= 0; i--) {
                Schema.SObjectField field = allContactFields.get(i);
                Schema.DescribeFieldResult dfr = field.getDescribe();
                if (dfr.isAccessible() == false) {
                    continue;
                }

                if (dfr.getType().name() == 'REFERENCE') {
                    if (dfr.isNamePointing()) {
                        continue;
                    }

                    String refObjectName = null;

                    for (Schema.SObjectType reference : dfr.getReferenceTo()) {
                        refObjectName = reference.getDescribe().getName();
                    }

                    // We are only showing the related Account (remove the comparing to account to show all)
                    if (refObjectName == null || !refObjectName.equalsIgnoreCase('account')) {
                        continue;
                    }
                    for (Schema.SObjectField accField : Schema.SObjectType.Account.fields.getMap().values()) {
                        Schema.DescribeFieldResult accDfr = accField.getDescribe();
                        if (accDfr.isAccessible() && (accDfr.getType().name() == 'ID' || accDfr.isNameField())) {
                            contactFields.add(accField);
                        }
                    }
                } else {
                    contactFields.add(field);
                }
            }

            kshDescription = Schema.describeSObjects(new List<String>{ KSH_OBJECT_NAME }).get(0);
            List<Schema.SObjectField> allKSHFields = kshDescription.fields.getMap().values();
            for (Integer i = allKSHFields.size() - 1; i >= 0; i--) {
                Schema.SObjectField field = allKSHFields.get(i);
                if (
                    field.getDescribe().isAccessible() == false ||
                    field.getDescribe().getType().name() == 'REFERENCE' ||
                    field.getDescribe().getName() == 'influence__c' ||
                    field.getDescribe().getName() == 'support__c' ||
                    field.getDescribe().getName() == 'pqcrush__influence__c' ||
                    field.getDescribe().getName() == 'pqcrush__support__c'
                ) {
                    continue;
                }
                kshFields.add(field);
            }
        }

        List<ObjectDescriptionWrapper> results;

        // When
        System.runAs(adminUser) {
            results = OrgChartSettingsController.getKSObjectFields('accountrelation');
        }

        // Then
        ObjectDescriptionWrapper contactResult = results.get(0);
        ObjectDescriptionWrapper kshResult = results.get(1);
        system.assertEquals(2, results.size());
        system.assertEquals(contactDescription.getName(), contactResult.objectName);
        system.assertEquals(contactDescription.getLabel(), contactResult.objectLabel);
        system.assertEquals(contactFields.size(), contactResult.fields.size());
        system.assertEquals(kshDescription.getName(), kshResult.objectName);
        system.assertEquals(kshDescription.getLabel(), kshResult.objectLabel);
        system.assertEquals(kshFields.size(), kshResult.fields.size());
    }

    @isTest
    static void getOrgChartFieldsFirstTimeStandardUserTest() {
        // Given
        User standardUser = [SELECT Id FROM User WHERE LastName = :STANDARD_USER_LAST_NAME];

        List<Org_Chart_Field__c> orgChartFields;
        List<OrgChartFieldWrapper> results;

        // When
        Test.startTest();
        System.runAs(standardUser) {
            orgChartFields = new OrgChartFieldSelector().selectAll();
            system.assert(orgChartFields.isEmpty());

            results = OrgChartSettingsController.getOrgChartFields('Key Stakeholder');
        }
        Test.stopTest();

        // Then
        system.assert(!results.isEmpty());
    }

    @isTest
    static void getOrgChartFieldsFirstTimeAdminUserTest() {
        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];

        List<Org_Chart_Field__c> orgChartFields;
        List<OrgChartFieldWrapper> results;

        // When
        Test.startTest();
        System.runAs(adminUser) {
            orgChartFields = new OrgChartFieldSelector().selectAll();
            system.assert(orgChartFields.isEmpty());

            results = OrgChartSettingsController.getOrgChartFields('Key Stakeholder');
        }
        Test.stopTest();

        // Then
        system.assert(!results.isEmpty());
    }

    @isTest
    static void getOrgChartFieldsStandardUserTest() {
        // Given
        User standardUser = [SELECT Id FROM User WHERE LastName = :STANDARD_USER_LAST_NAME];
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];

        System.runAs(adminUser) {
            List<Org_Chart_Field__c> testOrgChartFields = new List<Org_Chart_Field__c>();
            for (String testField : TEST_FIELDS) {
                testOrgChartFields.add(
                    new Org_Chart_Field__c(
                        ObjectName__c = CONTACT_OBJECT_NAME,
                        FieldName__c = testField,
                        FieldLabel__c = testField,
                        isRequired__c = true,
                        isVisible__c = true
                    )
                );
            }
            insert testOrgChartFields;
        }

        List<OrgChartFieldWrapper> results;

        // When
        Test.startTest();
        System.runAs(standardUser) {
            results = OrgChartSettingsController.getOrgChartFields('Key Stakeholder');
        }
        Test.stopTest();

        // Then
        system.assertEquals(3, results.size());
    }

    @isTest
    static void getOrgChartFieldsAdminUserTest() {
        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];

        System.runAs(adminUser) {
            List<Org_Chart_Field__c> testOrgChartFields = new List<Org_Chart_Field__c>();
            for (String testField : TEST_FIELDS) {
                testOrgChartFields.add(
                    new Org_Chart_Field__c(
                        ObjectName__c = CONTACT_OBJECT_NAME,
                        FieldName__c = testField,
                        FieldLabel__c = testField,
                        isRequired__c = true,
                        isVisible__c = true
                    )
                );
            }
            insert testOrgChartFields;
        }

        List<OrgChartFieldWrapper> results;

        // When
        Test.startTest();
        System.runAs(adminUser) {
            results = OrgChartSettingsController.getOrgChartFields('Key Stakeholder');
        }
        Test.stopTest();

        // Then
        system.assertEquals(3, results.size());
    }

    @isTest
    static void createOrgChartDefaultsAdminUserTest() {
        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SettingServiceImpl mockService = (SettingServiceImpl) mocks.mock(SettingServiceImpl.class);

        Application.Service.setMock(SettingServiceImpl.class, mockService);

        CRUSH_Settings_Obj__c mockOrgSettings = new CRUSH_Settings_Obj__c(Type__c = 'Org');
        mockOrgSettings.Org_Chart_Default_Fields__c = 'Contact.Name.Required';
        mocks.startStubbing();
        mocks.when(mockService.getOrgSettingsAndCreateIfNeeded()).thenReturn(mockOrgSettings);
        mocks.stopStubbing();

        List<Org_Chart_Field__c> results;

        // When
        Test.startTest();
        System.runAs(adminUser) {
            results = OrgChartSettingsController.createOrgChartDefaults('Key Stakeholder');
        }
        Test.stopTest();

        // Then
        system.assertEquals('Contact', results.get(0).ObjectName__c);
        system.assertEquals('Name', results.get(0).FieldName__c);
        system.assertEquals(true, results.get(0).isRequired__c);
        system.assertEquals(true, results.get(0).isVisible__c);
        system.assertEquals('Key Stakeholder', results.get(0).Map_Type__c);
        system.assertEquals(Schema.SObjectType.Contact.fields.Name.getLabel(), results.get(0).FieldLabel__c);
    }

    @isTest
    static void createOrgChartDefaultsAdminUserTest2() {
        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SettingServiceImpl mockService = (SettingServiceImpl) mocks.mock(SettingServiceImpl.class);

        Application.Service.setMock(SettingServiceImpl.class, mockService);

        CRUSH_Settings_Obj__c mockOrgSettings = new CRUSH_Settings_Obj__c(Type__c = 'Org');
        mockOrgSettings.Org_Chart_Default_Fields__c = 'Contact.Name.Required,Contact.Title';
        mocks.startStubbing();
        mocks.when(mockService.getOrgSettingsAndCreateIfNeeded()).thenReturn(mockOrgSettings);
        mocks.stopStubbing();

        List<Org_Chart_Field__c> results;

        // When
        Test.startTest();
        System.runAs(adminUser) {
            results = OrgChartSettingsController.createOrgChartDefaults('Key Stakeholder');
        }
        Test.stopTest();

        // Then
        system.assertEquals(2, results.size());
    }

    @isTest
    static void createOrgChartDefaultsStandardUserTest() {
        // Given
        User standardUser = [SELECT Id FROM User WHERE LastName = :STANDARD_USER_LAST_NAME];

        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        OrgChartFieldSelector mockOrgChartFieldSelector = md.mockOrgChartFieldSelector;

        CRUSH_Settings_Obj__c mockOrgSettings = new CRUSH_Settings_Obj__c(Type__c = 'Org');
        mockOrgSettings.Org_Chart_Default_Fields__c = 'Contact.Name.Required,Contact.Title';

        Org_Chart_Field__c orgChartField1 = (Org_Chart_Field__c) Org_Chart_Field__c.getSObjectType()
            .newSObject(null, true);
        orgChartField1.ObjectName__c = 'Contact';
        orgChartField1.FieldName__c = 'Name';
        orgChartField1.FieldLabel__c = Schema.SObjectType.Contact.fields.Name.getLabel();
        orgChartField1.isRequired__c = true;
        orgChartField1.isVisible__c = true;
        orgChartField1.Map_Type__c = 'Key Stakeholder';
        orgChartField1.IsMain__c = true;

        Org_Chart_Field__c orgChartField2 = (Org_Chart_Field__c) Org_Chart_Field__c.getSObjectType()
            .newSObject(null, true);
        orgChartField2.ObjectName__c = 'Contact';
        orgChartField2.FieldName__c = 'Title';
        orgChartField2.FieldLabel__c = Schema.SObjectType.Contact.fields.Title.getLabel();
        orgChartField2.isRequired__c = false;
        orgChartField2.isVisible__c = true;
        orgChartField2.Map_Type__c = 'Key Stakeholder';
        orgChartField2.IsMain__c = true;

        List<Org_Chart_Field__c> mockOrgChartFieldList = new List<Org_Chart_Field__c>{ orgChartField1, orgChartField2 };

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(mockOrgSettings);
        md.mocks.when(mockOrgChartFieldSelector.selectByMapType('Key Stakeholder')).thenReturn(mockOrgChartFieldList);
        md.mocks.stopStubbing();

        List<Org_Chart_Field__c> results;

        // When
        Test.startTest();
        System.runAs(standardUser) {
            results = OrgChartSettingsController.createOrgChartDefaults('Key Stakeholder');
        }
        Test.stopTest();

        // Then
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew((List<Org_Chart_Field__c>) fflib_Match.anyList());
        system.assertEquals(2, results.size());
        system.assertEquals('Contact', results.get(0).ObjectName__c);
        system.assertEquals('Name', results.get(0).FieldName__c);
        system.assertEquals(true, results.get(0).isRequired__c);
        system.assertEquals(true, results.get(0).isVisible__c);
        system.assertEquals('Key Stakeholder', results.get(0).Map_Type__c);
        system.assertEquals(Schema.SObjectType.Contact.fields.Name.getLabel(), results.get(0).FieldLabel__c);
    }

    @isTest
    static void createOrgChartDefaultsRMStandardUserTest() {
        // Given
        User standardUser = [SELECT Id FROM User WHERE LastName = :RM_STANDARD_USER_LAST_NAME];

        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        OrgChartFieldSelector mockOrgChartFieldSelector = md.mockOrgChartFieldSelector;

        CRUSH_Settings_Obj__c mockOrgSettings = new CRUSH_Settings_Obj__c(Type__c = 'Org');
        mockOrgSettings.Relationship_Map_Default_Fields__c = 'Contact.Name.Required,Contact.Title';

        Org_Chart_Field__c orgChartField1 = (Org_Chart_Field__c) Org_Chart_Field__c.getSObjectType()
            .newSObject(null, true);
        orgChartField1.ObjectName__c = 'Contact';
        orgChartField1.FieldName__c = 'Name';
        orgChartField1.FieldLabel__c = Schema.SObjectType.Contact.fields.Name.getLabel();
        orgChartField1.isRequired__c = true;
        orgChartField1.isVisible__c = true;
        orgChartField1.Map_Type__c = 'Relationship Map';
        orgChartField1.IsMain__c = true;

        Org_Chart_Field__c orgChartField2 = (Org_Chart_Field__c) Org_Chart_Field__c.getSObjectType()
            .newSObject(null, true);
        orgChartField2.ObjectName__c = 'Contact';
        orgChartField2.FieldName__c = 'Title';
        orgChartField2.FieldLabel__c = Schema.SObjectType.Contact.fields.Title.getLabel();
        orgChartField2.isRequired__c = false;
        orgChartField2.isVisible__c = true;
        orgChartField2.Map_Type__c = 'Relationship Map';
        orgChartField2.IsMain__c = true;

        List<Org_Chart_Field__c> mockOrgChartFieldList = new List<Org_Chart_Field__c>{ orgChartField1, orgChartField2 };

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(mockOrgSettings);
        md.mocks.when(mockOrgChartFieldSelector.selectByMapType('Relationship Map')).thenReturn(mockOrgChartFieldList);
        md.mocks.stopStubbing();

        List<Org_Chart_Field__c> results;

        // When
        Test.startTest();
        System.runAs(standardUser) {
            results = OrgChartSettingsController.createOrgChartDefaults('Relationship Map');
        }
        Test.stopTest();

        // Then
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 0))
            .registerNew((List<Org_Chart_Field__c>) fflib_Match.anyList());
        system.assertEquals(2, results.size());
        system.assertEquals('Contact', results.get(0).ObjectName__c);
        system.assertEquals('Name', results.get(0).FieldName__c);
        system.assertEquals(true, results.get(0).isRequired__c);
        system.assertEquals(true, results.get(0).isVisible__c);
        system.assertEquals('Relationship Map', results.get(0).Map_Type__c);
        system.assertEquals(Schema.SObjectType.Contact.fields.Name.getLabel(), results.get(0).FieldLabel__c);
    }

    @isTest
    static void createOrgChartDefaultsRMAdminUserTest() {
        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :RM_ADMIN_USER_LAST_NAME];

        TestMockData md = new TestMockData();
        SettingServiceImpl mockSettingService = md.mockSettingService;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;
        OrgChartFieldSelector mockOrgChartFieldSelector = md.mockOrgChartFieldSelector;

        CRUSH_Settings_Obj__c mockOrgSettings = new CRUSH_Settings_Obj__c(Type__c = 'Org');
        mockOrgSettings.Relationship_Map_Default_Fields__c = 'Contact.Name.Required,Contact.Title';

        Org_Chart_Field__c orgChartField1 = (Org_Chart_Field__c) Org_Chart_Field__c.getSObjectType()
            .newSObject(null, true);
        orgChartField1.ObjectName__c = 'Contact';
        orgChartField1.FieldName__c = 'Name';
        orgChartField1.FieldLabel__c = Schema.SObjectType.Contact.fields.Name.getLabel();
        orgChartField1.isRequired__c = true;
        orgChartField1.isVisible__c = true;
        orgChartField1.Map_Type__c = 'Relationship Map';
        orgChartField1.IsMain__c = true;

        Org_Chart_Field__c orgChartField2 = (Org_Chart_Field__c) Org_Chart_Field__c.getSObjectType()
            .newSObject(null, true);
        orgChartField2.ObjectName__c = 'Contact';
        orgChartField2.FieldName__c = 'Title';
        orgChartField2.FieldLabel__c = Schema.SObjectType.Contact.fields.Title.getLabel();
        orgChartField2.isRequired__c = false;
        orgChartField2.isVisible__c = true;
        orgChartField2.Map_Type__c = 'Relationship Map';
        orgChartField2.IsMain__c = true;

        List<Org_Chart_Field__c> mockOrgChartFieldList = new List<Org_Chart_Field__c>{ orgChartField1, orgChartField2 };

        md.mocks.startStubbing();
        md.mocks.when(mockSettingService.getOrgSettingsAndCreateIfNeeded()).thenReturn(mockOrgSettings);
        md.mocks.when(mockOrgChartFieldSelector.selectByMapType('Relationship Map')).thenReturn(mockOrgChartFieldList);
        md.mocks.stopStubbing();

        List<Org_Chart_Field__c> results;

        // When
        Test.startTest();
        System.runAs(adminUser) {
            results = OrgChartSettingsController.createOrgChartDefaults('Relationship Map');
        }
        Test.stopTest();

        // Then
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew((List<Org_Chart_Field__c>) fflib_Match.anyList());
        system.assertEquals(2, results.size());
        system.assertEquals('Contact', results.get(0).ObjectName__c);
        system.assertEquals('Name', results.get(0).FieldName__c);
        system.assertEquals(true, results.get(0).isRequired__c);
        system.assertEquals(true, results.get(0).isVisible__c);
        system.assertEquals('Relationship Map', results.get(0).Map_Type__c);
        system.assertEquals(Schema.SObjectType.Contact.fields.Name.getLabel(), results.get(0).FieldLabel__c);
    }

    @isTest
    static void saveSettingsAdminUserTest() {
        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];

        String updateListJson = '[{"fieldLabel":"Email","fieldName":"Email","objectName":"Contact","isVisible":false, "mapType": "Key Stakeholder"}]';

        System.runAs(adminUser) {
            Org_Chart_Field__c testOrgChartField = new Org_Chart_Field__c(
                pqcrush__ObjectName__c = CONTACT_OBJECT_NAME,
                pqcrush__FieldName__c = 'testField',
                pqcrush__FieldLabel__c = 'test field',
                pqcrush__isRequired__c = true,
                pqcrush__isVisible__c = true
            );
            insert testOrgChartField;
        }
        List<Id> orgChartFieldIds = new List<Id>();

        Id testOrgChartFieldId = [SELECT Id FROM Org_Chart_Field__c LIMIT 1].Id;

        orgChartFieldIds.add(testOrgChartFieldId);
        List<OrgChartFieldWrapper> results;

        // When
        Test.startTest();
        System.runAs(adminUser) {
            results = OrgChartSettingsController.saveSettings(updateListJson, orgChartFieldIds);
        }
        Test.stopTest();

        // Then
        system.assertEquals(1, results.size());
        system.assertEquals('Contact', results.get(0).objectName);
        system.assertEquals('Email', results.get(0).fieldName);
        system.assertEquals(false, results.get(0).isRequired);
        system.assertEquals(false, results.get(0).isVisible);
        system.assertEquals('Email', results.get(0).fieldLabel);
    }
}