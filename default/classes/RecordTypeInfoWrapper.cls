public with sharing class RecordTypeInfoWrapper {
    @AuraEnabled
    public Id recordTypeId;

    @AuraEnabled
    public String name;

    @AuraEnabled
    public String developerName;

    @AuraEnabled
    public Boolean isActive;

    @AuraEnabled
    public Boolean isAvailable;

    @AuraEnabled
    public Boolean isDefaultRecordTypeMapping;

    @AuraEnabled
    public Boolean isMaster;

    public RecordTypeInfoWrapper(RecordTypeInfo rti) {
        this.recordTypeId = rti.getRecordTypeId();
        this.name = rti.getName();
        this.isActive = rti.isActive();
        this.isAvailable = rti.isAvailable();
        this.isDefaultRecordTypeMapping = rti.isDefaultRecordTypeMapping();
        this.isMaster = rti.isMaster();
    }

    public static List<RecordTypeInfoWrapper> buildWrappers(List<RecordTypeInfo> rtiList) {
        List<RecordTypeInfoWrapper> wrappers = new List<RecordTypeInfoWrapper>();
        for (RecordTypeInfo rti : rtiList) {
            wrappers.add(new RecordTypeInfoWrapper(rti));
        }
        return wrappers;
    }
}