public with sharing class SObjectController {
    @AuraEnabled
    public static List<RecordTypeInfoWrapper> getRecordTypeInfos(String sobjectApiName) {
        Schema.SobjectType sobjType = SObjectService.getSObjectType(sobjectApiName);
        List<RecordTypeInfo> rtiList = sobjType.getDescribe().getRecordTypeInfos();
        return RecordTypeInfoWrapper.buildWrappers(rtiList);
    }

    @AuraEnabled
    public static Map<String, Boolean> getFieldDetails(String sobjectApiName) {
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(sobjectApiName);
        Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();

        List<pqcrush__MandatoryFields__mdt> contactMdt = pqcrush__MandatoryFields__mdt.getAll().values();
        String fieldSetName = contactMdt[0].pqcrush__FieldSetName__c;
        // String objectName = contactMdt[0].pqcrush__Object__c;

        Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetMemberList = fieldSetObj.getFields();
        Map<String, Boolean> requiredFieldMap = new Map<String, Boolean>();

        for (Schema.FieldSetMember fieldsetMember : fieldSetMemberList) {
            requiredFieldMap.put(fieldsetMember.getFieldPath(), fieldsetMember.getRequired());
        }
        return requiredFieldMap;
    }
}