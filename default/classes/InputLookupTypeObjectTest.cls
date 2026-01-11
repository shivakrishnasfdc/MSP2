@IsTest
private with sharing class InputLookupTypeObjectTest {
    @IsTest
    private static void emptyInitTest() {
        InputLookupTypeObject result = new InputLookupTypeObject();
        System.assertEquals(null, result.objType);
        System.assertEquals(null, result.displayFieldName);
        System.assertEquals(null, result.objNameField);
        System.assertEquals(null, result.getSoslReturningStatement());
    }

    @IsTest
    private static void initWithTypeTest() {
        InputLookupTypeObject result = new InputLookupTypeObject('Account');
        System.assertEquals('Account', result.objType);
        System.assertEquals(null, result.displayFieldName);
        System.assertEquals('Name', result.objNameField);
    }

    @IsTest
    private static void getSoslReturningStatementNoDisplayFieldTest() {
        InputLookupTypeObject result = new InputLookupTypeObject('Account');
        System.assertEquals('Account(Id, Name ORDER BY Name)', result.getSoslReturningStatement());
    }

    @IsTest
    private static void getSoslReturningStatementDisplayFieldIsNameFieldTest() {
        InputLookupTypeObject result = new InputLookupTypeObject('Account');
        result.displayFieldName = 'Name';
        System.assertEquals('Account(Id, Name ORDER BY Name)', result.getSoslReturningStatement());
    }

    @IsTest
    private static void getSoslReturningStatementDisplayFieldIsNotNameFieldTest() {
        InputLookupTypeObject result = new InputLookupTypeObject('Account');
        result.displayFieldName = 'Site';
        System.assertEquals('Account(Id, Name, Site ORDER BY Site)', result.getSoslReturningStatement());
    }
}