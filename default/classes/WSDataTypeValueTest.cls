@isTest
private class WSDataTypeValueTest {
    @isTest
    static void newInstanceTest() {
        Id id1 = fflib_IDGenerator.generate(Account.SObjectType);
        Id dataTypeId = fflib_IDGenerator.generate(Account.SObjectType);
        String dataTypeLabel = 'testing';
        String val = 'test';
        String color = '#ffffff';

        WSDataTypeValue dt = new WSDataTypeValue(id1, dataTypeId, dataTypeLabel, val, color);
        System.assertNotEquals(null, dt);
        System.assertEquals(id1, dt.id);
        System.assertEquals(dataTypeId, dt.dataTypeId);
        System.assertEquals(dataTypeLabel, dt.dataTypeLabel);
        System.assertEquals(val, dt.value);
        System.assertEquals(color, dt.color);
    }
}