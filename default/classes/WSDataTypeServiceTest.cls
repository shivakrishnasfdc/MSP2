@isTest
private class WSDataTypeServiceTest {
    @isTest
    static void getDataTypesTest() {
        // mocks
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork uow = md.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test
        WSDataTypeSelector mockWSDataTypeSelector = md.mockWSDataTypeSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockWSDataTypeSelector.selectByWhiteSpaceId(md.mockWhiteSpaceId))
            .thenReturn(new List<WS_Data_Type__c>());
        md.mocks.stopStubbing();

        WSDataTypeService.getDataTypes(md.mockWhiteSpaceId);

        // Then
        ((WSDataTypeSelector) md.mocks.verify(mockWSDataTypeSelector, 1)).selectByWhiteSpaceId(md.mockWhiteSpaceId);
        System.assert(true, 'Assertion from mock verify');
    }

    @isTest
    static void saveDataForCellNewTest() {
        // mocks
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork uow = md.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test
        WSDataTypeAssociationSelector mockWsDataTypeAssocationSelector = md.mockWSDataTypeAssociationSelector;

        String val = 'test abc';
        md.mocks.startStubbing();
        md.mocks.when(
                mockWsDataTypeAssocationSelector.selectByCellAndDataType(md.mockWhiteSpaceCellId, md.mockWSDataTypeId)
            )
            .thenReturn(new List<WS_Data_Type_Association__c>());
        md.mocks.stopStubbing();

        WSDataTypeService.saveDataForCell(md.mockWhiteSpaceCellId, md.mockWSDataTypeId, val);

        // Then
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(md.mockUow, 1))
            .registerNew(fflib_Match.sObjectOfType(WS_Data_Type_Association__c.SObjectType));
        System.assert(true, 'Assertion from mock verify');
    }

    @isTest
    static void saveDataForCellUpdateTest() {
        // mocks
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork uow = md.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test
        WSDataTypeAssociationSelector mockWsDataTypeAssocationSelector = md.mockWSDataTypeAssociationSelector;

        String val = 'test abc';
        md.mocks.startStubbing();
        md.mocks.when(
                mockWsDataTypeAssocationSelector.selectByCellAndDataType(md.mockWhiteSpaceCellId, md.mockWSDataTypeId)
            )
            .thenReturn(new List<WS_Data_Type_Association__c>{ md.mockWSDataTypeAssociation });
        md.mocks.stopStubbing();

        WSDataTypeService.saveDataForCell(md.mockWhiteSpaceCellId, md.mockWSDataTypeId, val);

        // Then
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(md.mockUow, 1))
            .registerDirty(fflib_Match.sObjectOfType(WS_Data_Type_Association__c.SObjectType));
        System.assert(true, 'Assertion from mock verify');
    }

    @isTest
    static void getDataTypeDataForCellTest() {
        // mocks
        TestMockData md = new TestMockData();
        fflib_ISObjectUnitOfWork uow = md.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test
        WSDataTypeAssociationSelector mockWsDataTypeAssocationSelector = md.mockWSDataTypeAssociationSelector;

        md.mocks.startStubbing();
        md.mocks.when(mockWsDataTypeAssocationSelector.selectByCellId(md.mockWhiteSpaceCellId))
            .thenReturn(new List<WS_Data_Type_Association__c>());
        md.mocks.stopStubbing();

        WSDataTypeService.getDataTypeDataForCell(md.mockWhiteSpaceCellId);

        // Then
        ((WSDataTypeAssociationSelector) md.mocks.verify(mockWsDataTypeAssocationSelector, 1))
            .selectByCellId(md.mockWhiteSpaceCellId);
        System.assert(true, 'Assertion from mock verify');
    }
}