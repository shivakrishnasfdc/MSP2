@isTest
private class WhiteSpaceTypeEnumHelperTest {
    @isTest
    private static void getTypeFromTest1() {
        White_Space__c ws = new White_Space__c(White_Space_Template__c = null);

        WhiteSpaceTypeEnum wsenum = WhiteSpaceTypeEnumHelper.getTypeFrom(ws, null);
        System.assertEquals(WhiteSpaceTypeEnum.FREE_FORM, wsenum);
    }

    @isTest
    private static void getTypeFromTest2() {
        White_Space_Template__c wst = new White_Space_Template__c(
            Id = fflib_IDGenerator.generate(White_Space_Template__c.SObjectType)
        );
        White_Space__c ws = new White_Space__c();
        ws.White_Space_Template__c = wst.Id;

        WhiteSpaceTypeEnum wsenum = WhiteSpaceTypeEnumHelper.getTypeFrom(ws, wst);
        System.assertEquals(WhiteSpaceTypeEnum.TEMPLATE, wsenum);
    }

    @isTest
    private static void getTypeFromTest3() {
        White_Space_Template__c wst = new White_Space_Template__c(
            Id = fflib_IDGenerator.generate(White_Space_Template__c.SObjectType)
        );
        wst.hasDependentPicklistColumns__c = true;
        White_Space__c ws = new White_Space__c();
        ws.White_Space_Template__c = wst.Id;

        WhiteSpaceTypeEnum wsenum = WhiteSpaceTypeEnumHelper.getTypeFrom(ws, wst);
        System.assertEquals(WhiteSpaceTypeEnum.DEPENDENT_PICKLIST, wsenum);
    }
}