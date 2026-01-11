@isTest
private with sharing class WSRelatedObjectWrapperTest {
    @isTest
    static void emptyInitializerTest() {
        WSRelatedObjectWrapper result = new WSRelatedObjectWrapper();
        System.assertEquals(null, result.objDesc);
        System.assertEquals(null, result.labelFieldName);
        System.assertEquals(null, result.fieldList);
        System.assertEquals(null, result.relationshipField);
        System.assertEquals('#556677', result.color);
    }
    @isTest
    static void initializerWithoutConfigTest() {
        WSRelatedObjectWrapper result = new WSRelatedObjectWrapper(
            Account.sObjectType.getDescribe(),
            Schema.SObjectType.Account.fields.OwnerId
        );
        System.assertEquals(Schema.SObjectType.Account.fields.Name.getName(), result.labelFieldName);
        System.assertEquals(2, result.fieldList.size());
        System.assertEquals(Schema.SObjectType.Account.fields.Name.getName(), result.fieldList[0]);
        System.assertEquals(Schema.SObjectType.Account.fields.Id.getName(), result.fieldList[1]);
    }

    @isTest
    static void initializerNullConfigTest() {
        WSRelatedObjectWrapper result = new WSRelatedObjectWrapper(
            Account.sObjectType.getDescribe(),
            Schema.SObjectType.Account.fields.OwnerId,
            null
        );
        System.assertEquals(Schema.SObjectType.Account.fields.Name.getName(), result.labelFieldName);
        System.assertEquals(2, result.fieldList.size());
        System.assertEquals(Schema.SObjectType.Account.fields.Name.getName(), result.fieldList[0]);
        System.assertEquals(Schema.SObjectType.Account.fields.Id.getName(), result.fieldList[1]);
    }

    @isTest
    static void initializerBadConfigObjectTest() {
        Cell_Relationship_Configuration__c config = new Cell_Relationship_Configuration__c();
        config.Object_API_Name__c = 'Contact';
        config.Color__c = '#FFF';
        config.Display_Field__c = 'Name';
        WSRelatedObjectWrapper result = new WSRelatedObjectWrapper(
            Account.sObjectType.getDescribe(),
            Schema.SObjectType.Account.fields.OwnerId,
            config
        );
        System.assertEquals(Schema.SObjectType.Account.fields.Name.getName(), result.labelFieldName);
        System.assertEquals(2, result.fieldList.size());
        System.assertEquals(Schema.SObjectType.Account.fields.Name.getName(), result.fieldList[0]);
        System.assertEquals(Schema.SObjectType.Account.fields.Id.getName(), result.fieldList[1]);
    }

    @isTest
    static void initializerBadConfigDisplayFieldTest() {
        Cell_Relationship_Configuration__c config = new Cell_Relationship_Configuration__c();
        config.Object_API_Name__c = 'Account';
        config.Color__c = '#FFF';
        config.Display_Field__c = 'wsrow_FakeField';
        WSRelatedObjectWrapper result = new WSRelatedObjectWrapper(
            Account.sObjectType.getDescribe(),
            Schema.SObjectType.Account.fields.OwnerId,
            config
        );
        System.assertEquals(Schema.SObjectType.Account.fields.Name.getName(), result.labelFieldName);
        System.assertEquals(2, result.fieldList.size());
        System.assertEquals(Schema.SObjectType.Account.fields.Name.getName(), result.fieldList[0]);
        System.assertEquals(Schema.SObjectType.Account.fields.Id.getName(), result.fieldList[1]);
    }

    @isTest
    static void initializerEmptyConfigDisplayFieldTest() {
        Cell_Relationship_Configuration__c config = new Cell_Relationship_Configuration__c();
        config.Object_API_Name__c = 'Account';
        config.Color__c = '#FFF';
        config.Display_Field__c = '';
        WSRelatedObjectWrapper result = new WSRelatedObjectWrapper(
            Account.sObjectType.getDescribe(),
            Schema.SObjectType.Account.fields.OwnerId,
            config
        );
        System.assertEquals(Schema.SObjectType.Account.fields.Name.getName(), result.labelFieldName);
        System.assertEquals(2, result.fieldList.size());
        System.assertEquals(Schema.SObjectType.Account.fields.Name.getName(), result.fieldList[0]);
        System.assertEquals(Schema.SObjectType.Account.fields.Id.getName(), result.fieldList[1]);
    }

    @isTest
    static void initializerWithConfigHappyPathTest() {
        Cell_Relationship_Configuration__c config = new Cell_Relationship_Configuration__c();
        config.Object_API_Name__c = 'Account';
        config.Color__c = '#FFF';
        config.Display_Field__c = 'Type';
        WSRelatedObjectWrapper result = new WSRelatedObjectWrapper(
            Account.sObjectType.getDescribe(),
            Schema.SObjectType.Account.fields.OwnerId,
            config
        );
        System.assertEquals(Schema.SObjectType.Account.fields.Type.getName(), result.labelFieldName);
        System.assertEquals(2, result.fieldList.size());
        System.assertEquals(Schema.SObjectType.Account.fields.Type.getName(), result.fieldList[0]);
        System.assertEquals(Schema.SObjectType.Account.fields.Id.getName(), result.fieldList[1]);
        System.assertEquals(config.Color__c, result.color);
    }

    @isTest
    static void initializerWithConfigCompoundBadPathTest() {
        Cell_Relationship_Configuration__c config = new Cell_Relationship_Configuration__c();
        config.Object_API_Name__c = 'pqcrush__White_Space_Amount_Type_Association__c';
        config.Color__c = '#FFF';
        config.Display_Field__c = 'pqcrush__White_Space_Amount_Type__r.pqcrush__Not_Real__c';
        WSRelatedObjectWrapper result = new WSRelatedObjectWrapper(
            pqcrush__White_Space_Amount_Type_Association__c.sObjectType.getDescribe(),
            Schema.SObjectType.pqcrush__White_Space_Amount_Type_Association__c.fields.White_Space_Cell__c,
            config
        );
        System.assertEquals(
            Schema.SObjectType.White_Space_Amount_Type_Association__c.fields.Name.getName(),
            result.labelFieldName
        );
        System.assertEquals(2, result.fieldList.size());
        System.assertEquals(
            Schema.SObjectType.White_Space_Amount_Type_Association__c.fields.Name.getName(),
            result.fieldList[0]
        );
        System.assertEquals(
            Schema.SObjectType.White_Space_Amount_Type_Association__c.fields.Id.getName(),
            result.fieldList[1]
        );
        System.assertEquals(config.Color__c, result.color);
    }

    @isTest
    static void initializerWithConfigCompoundGoodPathTest() {
        Cell_Relationship_Configuration__c config = new Cell_Relationship_Configuration__c();
        config.Object_API_Name__c = 'pqcrush__White_Space_Amount_Type_Association__c';
        config.Color__c = '#FFF';
        config.Display_Field__c = 'pqcrush__White_Space_Amount_Type__r.pqcrush__Color_RGB__c';
        WSRelatedObjectWrapper result = new WSRelatedObjectWrapper(
            pqcrush__White_Space_Amount_Type_Association__c.sObjectType.getDescribe(),
            Schema.SObjectType.pqcrush__White_Space_Amount_Type_Association__c.fields.White_Space_Cell__c,
            config
        );
        System.assertEquals('pqcrush__White_Space_Amount_Type__r.pqcrush__Color_RGB__c', result.labelFieldName);
        System.assertEquals(2, result.fieldList.size());
        System.assertEquals('pqcrush__White_Space_Amount_Type__r.pqcrush__Color_RGB__c', result.fieldList[0]);
        System.assertEquals('pqcrush__White_Space_Amount_Type__r.Id', result.fieldList[1]);
        System.assertEquals(config.Color__c, result.color);
    }
}