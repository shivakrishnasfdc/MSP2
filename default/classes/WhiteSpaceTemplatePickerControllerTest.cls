@isTest
private class WhiteSpaceTemplatePickerControllerTest {
    public static final String USER1_FIRST_NAME = 'admin';
    public static final String USER1_LAST_NAME = 'adam';

    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';
    public static final String WHITE_SPACE_TEMPLATE_NAME = 'testTemplate';
    public static final String STANDARD_USER = 'Standard User';

    @testSetup
    static void testSetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];
        User adminAdam = TestDataFactory.createUser(USER1_FIRST_NAME, USER1_LAST_NAME, p.Id);
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];

        insert new PermissionSetAssignment(AssigneeId = adminAdam.Id, PermissionSetId = adminUserPermissionSet.Id);
    }

    @isTest
    static void getTemplateListTest() {
        // mocks
        TestMockData md = new TestMockData();
        WhiteSpaceTemplateSelector mockWSTSelector = md.mockWSTSelector;
        White_Space_Template__c mockTemplate = md.mockWhiteSpaceTemplate;
        mockTemplate.RowMapping__r = md.mockAccountMapping;
        mockTemplate.ColumnMapping__r = md.mockProductMapping;
        White_Space_Template__c mockLegacyWhiteSpaceTemplate = md.mockLegacyWhiteSpaceTemplate;

        // Given
        User adminUser = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME];

        md.mocks.startStubbing();
        md.mocks.when(mockWSTSelector.selectAllWithRowColumnMappings())
            .thenReturn(new List<White_Space_Template__c>{ mockTemplate, mockLegacyWhiteSpaceTemplate });
        md.mocks.stopStubbing();

        List<WhiteSpaceTemplatePickerController.TemplateInfo> result = new List<WhiteSpaceTemplatePickerController.TemplateInfo>();
        // When
        Test.startTest();
        System.runAs(adminUser) {
            result = WhiteSpaceTemplatePickerController.getTemplateList();
        }
        Test.stopTest();

        // Then
        System.assertEquals(2, result.size());
        System.assertEquals(mockTemplate.id, result[0].id);
        System.assertEquals(mockTemplate.name, result[0].name);
        System.assertEquals(UTIL_Describe.getObjectLabelPlural(md.mockAccountMapping.ObjectType__c), result[0].rowName);
        System.assertEquals(
            UTIL_Describe.getObjectLabelPlural(md.mockProductMapping.ObjectType__c),
            result[0].columnName
        );

        System.assertEquals(mockLegacyWhiteSpaceTemplate.id, result[1].id);
        System.assertEquals(mockLegacyWhiteSpaceTemplate.name, result[1].name);
        System.assertEquals(
            UTIL_Describe.getObjectLabelPlural(mockLegacyWhiteSpaceTemplate.Row_Object_Name__c),
            result[1].rowName
        );
        System.assertEquals(
            UTIL_Describe.getObjectLabelPlural(mockLegacyWhiteSpaceTemplate.Column_Object_Name__c),
            result[1].columnName
        );
    }

    @isTest
    static void getTemplateWrapperTest() {
        // mocks
        TestMockData md = new TestMockData();
        WhiteSpaceTemplateSelector mockWSTSelector = md.mockWSTSelector;
        MappingSelector mockMappingSelector = md.mockMappingSelector;

        // given
        User adminUser = [SELECT Id FROM User WHERE LastName = :USER1_LAST_NAME];

        Mapping__c mockProductMapping = md.mockProductMapping;
        Mapping__c mockAccountMapping = md.mockAccountMapping;

        Id mockTemplateId = md.mockWhiteSpaceTemplateId;
        White_Space_Template__c mockTemplate = new White_Space_Template__c(
            Id = mockTemplateId,
            Name = WHITE_SPACE_TEMPLATE_NAME,
            RowMapping__c = mockProductMapping.id,
            ColumnMapping__c = mockAccountMapping.id
        );

        md.mocks.startStubbing();
        md.mocks.when(mockWSTSelector.selectById(new Set<Id>{ mockTemplateId }))
            .thenReturn(new List<White_Space_Template__c>{ mockTemplate });
        md.mocks.when(
                mockMappingSelector.selectByIdWithConditionGroups(
                    new Set<ID>{ mockProductMapping.id, mockAccountMapping.id }
                )
            )
            .thenReturn(new List<Mapping__c>{ mockProductMapping, mockAccountMapping });
        md.mocks.stopStubbing();

        // When
        WhiteSpaceTemplateWrapper result;

        Test.startTest();
        System.runAs(adminUser) {
            result = WhiteSpaceTemplatePickerController.getTemplateWrapper(mockTemplateId);
        }
        Test.stopTest();

        System.assertEquals(mockTemplateId, result.id);
    }
}