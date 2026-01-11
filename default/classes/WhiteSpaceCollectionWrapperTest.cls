@isTest
private class WhiteSpaceCollectionWrapperTest {
    @isTest
    private static void initializerWithRowAndLabelTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceCollectionWrapper wrapper = new WhiteSpaceCollectionWrapper(md.mockWhiteSpaceRow);

        System.assertEquals(md.mockWhiteSpaceRow, wrapper.collection);
        System.assertEquals(md.mockWhiteSpaceRowId, wrapper.id);
        System.assertEquals(md.mockWhiteSpaceRow.Name, wrapper.name);
        System.assertEquals(null, wrapper.relatedObjectId);
        System.assertEquals(null, wrapper.parentObjectId);
    }

    @isTest
    private static void initializerWithColumnNoLabelTest() {
        TestMockData md = new TestMockData();
        md.mockWhiteSpaceColumn.Name = null;
        WhiteSpaceCollectionWrapper wrapper = new WhiteSpaceCollectionWrapper(md.mockWhiteSpaceColumn);

        System.assertEquals(md.mockWhiteSpaceColumn, wrapper.collection);
        System.assertEquals(md.mockWhiteSpaceColumnId, wrapper.id);
        System.assertEquals('[no label]', wrapper.name);
        System.assertEquals(null, wrapper.relatedObjectId);
        System.assertEquals(null, wrapper.parentObjectId);
    }

    @isTest
    private static void initializerWithObjectRelatedIdAndNameTest() {
        TestMockData md = new TestMockData();
        String relatedId = 'Test Related Id';
        String name = 'Test Name';
        WhiteSpaceCollectionWrapper wrapper = new WhiteSpaceCollectionWrapper(md.mockWhiteSpaceRow, relatedId, name);

        System.assertEquals(md.mockWhiteSpaceRow, wrapper.collection);
        System.assertEquals(md.mockWhiteSpaceRowId, wrapper.id);
        System.assertEquals(relatedId, wrapper.relatedObjectId);
        System.assertEquals(name, wrapper.name);
        System.assertEquals(null, wrapper.parentObjectId);
        System.assertEquals(null, wrapper.groupedRelatedRecordIds);
    }

    @isTest
    private static void initializerWithObjectNameAndGroupIdsTest() {
        TestMockData md = new TestMockData();
        String name = 'Test Name';
        List<String> groupedRelatedRecordIds = new List<String>{ 'Test Grouped Related Record Id' };
        WhiteSpaceCollectionWrapper wrapper = new WhiteSpaceCollectionWrapper(
            md.mockWhiteSpaceRow,
            name,
            name,
            groupedRelatedRecordIds
        );

        System.assertEquals(md.mockWhiteSpaceRow, wrapper.collection);
        System.assertEquals(md.mockWhiteSpaceRowId, wrapper.id);
        System.assertEquals(name, wrapper.name);
        System.assertEquals(name, wrapper.relatedObjectId);
        System.assertEquals(null, wrapper.parentObjectId);
        System.assertEquals(groupedRelatedRecordIds, wrapper.groupedRelatedRecordIds);
    }

    @isTest
    private static void initializerWithMappingAndObjectTest() {
        TestMockData md = new TestMockData();
        md.mockAccount.ParentId = fflib_IDGenerator.generate(Account.SObjectType);
        WhitespaceTemplateMappingWrapper mappingWrapper = new WhitespaceTemplateMappingWrapper(md.mockAccountMapping);
        WhiteSpaceCollectionWrapper wrapper = new WhiteSpaceCollectionWrapper(
            md.mockWhiteSpaceColumn,
            mappingWrapper,
            md.mockAccount
        );

        System.assertEquals(md.mockWhiteSpaceColumn, wrapper.collection);
        System.assertEquals(md.mockWhiteSpaceColumnId, wrapper.id);
        System.assertEquals(md.mockAccount.Name, wrapper.name);
        System.assertEquals(md.mockAccountId, wrapper.relatedObjectId);
        System.assertEquals(md.mockAccount.ParentId, wrapper.parentObjectId);
        System.assertEquals(null, wrapper.groupedRelatedRecordIds);
    }
}