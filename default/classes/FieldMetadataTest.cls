@isTest
private class FieldMetadataTest {
    @isTest
    static void newInstanceTest() {
        FieldMetadata result = new FieldMetadata('Contact', 'FirstName');
        System.assertNotEquals(null, result);
    }

    @isTest
    static void newInstanceTest2() {
        Schema.DescribeFieldResult fieldResult = Account.Name.getDescribe();
        Schema.SObjectField sobjectField = fieldResult.getSObjectField();
        Schema.SobjectType sobjectType = Schema.Account.getSObjectType();

        Schema.DescribeFieldResult fieldDescribe = sobjectField.getDescribe();

        FieldMetadata result = new FieldMetadata(sobjectType, sobjectField);
        System.assertNotEquals(null, result);
        System.assertEquals(String.valueOf(sobjectField), result.apiName);
        System.assertEquals(fieldDescribe.getType().name(), result.displayType);
        System.assertEquals(fieldDescribe.isAccessible(), result.isAccessible);
        System.assertEquals(fieldDescribe.isCalculated(), result.isCalculated);
        System.assertEquals(fieldDescribe.isCreateable(), result.isCreateable);
        System.assertEquals(fieldDescribe.isCustom(), result.isCustom);
        System.assertEquals(fieldDescribe.isFilterable(), result.isFilterable);
        System.assertEquals(fieldDescribe.isGroupable(), result.isGroupable);
        System.assertEquals(fieldDescribe.isNameField(), result.isNameField);
        System.assertEquals(fieldDescribe.isNillable() == false && fieldDescribe.isCreateable(), result.isRequired);
        System.assertEquals(fieldDescribe.isSortable(), result.isSortable);
        System.assertEquals(fieldDescribe.isUpdateable(), result.isUpdateable);
        System.assertEquals(fieldDescribe.getLabel(), result.label);
        System.assertEquals(fieldDescribe.getRelationshipName(), result.relationshipApiName);
        System.assertEquals(fieldDescribe.getRelationshipOrder(), result.relationshipOrder);
        System.assertEquals(String.valueOf(sobjectType), result.sobjectApiName);
    }

    @isTest
    static void compareTest() {
        FieldMetadata result = new FieldMetadata('Contact', 'FirstName');
        FieldMetadata result2 = new FieldMetadata('Contact', 'FirstName');
        FieldMetadata result3 = new FieldMetadata('Contact', 'LastName');

        if (result.compareTo(result2) == 0) {
            System.assert(true);
        }

        if (result.compareTo(result3) > 0) {
            System.assert(true);
        }
    }
}