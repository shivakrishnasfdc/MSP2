@isTest
private class WhiteSpaceDisplayFieldDataWrapperTest {
    @isTest
    private static void basicInitializerTest() {
        WhiteSpaceDisplayFieldDataWrapper wrapper = new WhiteSpaceDisplayFieldDataWrapper();

        System.assertEquals(null, wrapper.value);
        System.assertEquals(null, wrapper.displayName);
        System.assertEquals(null, wrapper.objectId);
        System.assertEquals(null, wrapper.secondaryObjectId);
    }

    @isTest
    private static void nameAndIdInitializerTest() {
        String displayName = 'naiit_displayName';
        Id objId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        WhiteSpaceDisplayFieldDataWrapper wrapper = new WhiteSpaceDisplayFieldDataWrapper(displayName, objId);

        System.assertEquals('', wrapper.value);
        System.assertEquals(displayName, wrapper.displayName);
        System.assertEquals(objId, wrapper.objectId);
        System.assertEquals(null, wrapper.secondaryObjectId);
    }

    @isTest
    private static void initializerFullTest() {
        Object value = 56;
        String displayName = 'naiit_displayName';
        Id objId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        Id secObjId = fflib_IDGenerator.generate(Account.SObjectType);
        WhiteSpaceDisplayFieldDataWrapper wrapper = new WhiteSpaceDisplayFieldDataWrapper(
            value,
            displayName,
            objId,
            secObjId
        );

        System.assertEquals(value, wrapper.value);
        System.assertEquals(displayName, wrapper.displayName);
        System.assertEquals(objId, wrapper.objectId);
        System.assertEquals(secObjId, wrapper.secondaryObjectId);
    }

    @isTest
    private static void toAssociationWithDisplayFieldIdTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceDisplayFieldDataWrapper wrapper = new WhiteSpaceDisplayFieldDataWrapper();
        wrapper.value = 1;
        wrapper.objectId = md.mockWhiteSpaceAmountTypeAssociationId;

        White_Space_Amount_Type_Association__c result = wrapper.toAssociationWithDisplayFieldId(
            md.mockWhiteSpaceAmountTypeId,
            md.mockWhiteSpaceCellId
        );

        System.assertEquals(md.mockWhiteSpaceAmountTypeAssociationId, result.Id);
        System.assertEquals(1, result.pqcrush__Amount__c);
        System.assertEquals(md.mockWhiteSpaceAmountTypeId, result.pqcrush__White_Space_Amount_Type__c);
        System.assertEquals(md.mockWhiteSpaceCellId, result.pqcrush__White_Space_Cell__c);
    }

    @isTest
    private static void toAssociationWithDisplayFieldIdNullObjectIdTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceDisplayFieldDataWrapper wrapper = new WhiteSpaceDisplayFieldDataWrapper();
        wrapper.value = 1;
        wrapper.objectId = null;

        White_Space_Amount_Type_Association__c result = wrapper.toAssociationWithDisplayFieldId(
            md.mockWhiteSpaceAmountTypeId,
            md.mockWhiteSpaceCellId
        );

        System.assertEquals(null, result.Id);
        System.assertEquals(1, result.pqcrush__Amount__c);
        System.assertEquals(md.mockWhiteSpaceAmountTypeId, result.pqcrush__White_Space_Amount_Type__c);
        System.assertEquals(md.mockWhiteSpaceCellId, result.pqcrush__White_Space_Cell__c);
    }

    @isTest
    private static void toAssociationWithNonAmountTypeTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceDisplayFieldDataWrapper wrapper = new WhiteSpaceDisplayFieldDataWrapper();
        wrapper.value = 1;
        wrapper.objectId = md.mockAccountPlanId;

        White_Space_Amount_Type_Association__c result = wrapper.toAssociationWithDisplayFieldId(
            md.mockWhiteSpaceAmountTypeId,
            md.mockWhiteSpaceCellId
        );

        System.assertEquals(null, result);
    }

    @isTest
    private static void toAssociationWithStringValueAmountTypeTest() {
        TestMockData md = new TestMockData();
        WhiteSpaceDisplayFieldDataWrapper wrapper = new WhiteSpaceDisplayFieldDataWrapper();
        wrapper.value = '1';
        wrapper.objectId = md.mockWhiteSpaceAmountTypeAssociationId;

        White_Space_Amount_Type_Association__c result = wrapper.toAssociationWithDisplayFieldId(
            md.mockWhiteSpaceAmountTypeId,
            md.mockWhiteSpaceCellId
        );

        System.assertEquals(md.mockWhiteSpaceAmountTypeAssociationId, result.Id);
        System.assertEquals(1, result.pqcrush__Amount__c);
        System.assertEquals(md.mockWhiteSpaceAmountTypeId, result.pqcrush__White_Space_Amount_Type__c);
        System.assertEquals(md.mockWhiteSpaceCellId, result.pqcrush__White_Space_Cell__c);
    }
}