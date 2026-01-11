@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class SObjectMetadata implements Comparable {
    @AuraEnabled
    public String apiName { get; set; }
    @AuraEnabled
    public List<ChildRelationshipMetadata> childRelationships { get; private set; }
    @AuraEnabled
    public Boolean hasRecordTypeInfos { get; private set; }
    @AuraEnabled
    public Boolean isAccessible { get; private set; }
    @AuraEnabled
    public Boolean isCreateable { get; private set; }
    @AuraEnabled
    public Boolean isCustom { get; private set; }
    @AuraEnabled
    public Boolean isCustomSetting { get; private set; }
    @AuraEnabled
    public Boolean isQueryable { get; private set; }
    @AuraEnabled
    public Boolean isSearchable { get; private set; }
    @AuraEnabled
    public Boolean isUpdateable { get; private set; }
    @AuraEnabled
    public String keyPrefix { get; private set; }
    @AuraEnabled
    @TestVisible
    public String label { get; private set; }
    @AuraEnabled
    public String labelPlural { get; private set; }
    @AuraEnabled
    public String localApiName { get; private set; }

    public SobjectMetadata(String sobjectApiName) {
        this(UTIL_Describe.getSObjectType(sobjectApiName));
    }

    public SobjectMetadata(Schema.SobjectType objectType) {
        this(objectType.getDescribe());
    }

    public SObjectMetadata(DescribeSobjectResult sobjectDescribe) {
        this.apiName = sobjectDescribe.getName();
        this.childRelationships = this.getChildRelationships(sobjectDescribe.getChildRelationships());
        this.hasRecordTypeInfos = sobjectDescribe.getRecordTypeInfos().size() > 0;
        this.isAccessible = sobjectDescribe.isAccessible();
        this.isCreateable = sobjectDescribe.isCreateable();
        this.isCustom = sobjectDescribe.isCustom();
        this.isCustomSetting = sobjectDescribe.isCustomSetting();
        this.isQueryable = sobjectDescribe.isQueryable();
        this.isSearchable = sobjectDescribe.isSearchable();
        this.isUpdateable = sobjectDescribe.isUpdateable();
        this.keyPrefix = sobjectDescribe.getKeyPrefix();
        this.label = sobjectDescribe.getLabel();
        this.labelPlural = sobjectDescribe.getLabelPlural();
        this.localApiName = sobjectDescribe.getLocalName();
    }

    public Integer compareTo(Object obj) {
        SObjectMetadata sObjectMetadata = (SObjectMetadata) (obj);
        if (this.label > sObjectMetadata.label) {
            return 1;
        }
        if (this.label == sObjectMetadata.label) {
            return 0;
        }
        return -1;
    }

    public Boolean equals(Object obj) {
        if (obj == null || !(obj instanceof SObjectMetadata)) {
            return false;
        }
        SObjectMetadata sObjectMetadata = (SObjectMetadata) (obj);
        return this.apiName == sObjectMetadata.apiName;
    }

    public Integer hashCode() {
        return System.hashCode(this.apiName);
    }

    private List<ChildRelationshipMetadata> getChildRelationships(List<Schema.ChildRelationship> relationships) {
        List<ChildRelationshipMetadata> childRelationships = new List<ChildRelationshipMetadata>();
        for (Schema.ChildRelationship relationship : relationships) {
            childRelationships.add(new ChildRelationshipMetadata(relationship));
        }
        return childRelationships;
    }

    public class ChildRelationshipMetadata implements Comparable {
        @AuraEnabled
        public String childObjectApiName { get; private set; }
        @AuraEnabled
        public String fieldName { get; private set; }
        @AuraEnabled
        public String relationshipName { get; private set; }

        public ChildRelationshipMetadata(Schema.ChildRelationship childRelationship) {
            this.childObjectApiName = String.valueOf(childRelationship.getChildSobject());
            Schema.SObjectField childField = childRelationship.getField();
            this.fieldName = childField.getDescribe().getName();
            this.relationshipName = childRelationship.getRelationshipName();
        }

        public Integer compareTo(Object compareTo) {
            ChildRelationshipMetadata compareToChildRelationship = (ChildRelationshipMetadata) compareTo;
            String key = this.childObjectApiName + this.fieldName;
            String compareToKey = compareToChildRelationship.childObjectApiName + compareToChildRelationship.fieldName;

            if (key == compareToKey) {
                return 0;
            } else if (key > compareToKey) {
                return 1;
            } else {
                return -1;
            }
        }
    }
}