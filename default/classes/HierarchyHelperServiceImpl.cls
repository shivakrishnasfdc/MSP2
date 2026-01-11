public with sharing class HierarchyHelperServiceImpl {
    public String getLabelForRelationship(Contact_Relationship__c rel) {
        if (rel == null) {
            return '';
        }

        Map<String, Object> fields = rel.getPopulatedFieldsAsMap();

        if (!fields.containsKey('Contact_Relationship_Type__r')) {
            return rel.Label__c;
        }

        if (rel.Contact_Relationship_Type__r == null) {
            return rel.Label__c;
        }
        if (rel.Contact_Relationship_Type__r.Label_Editable__c == null) {
            return rel.Label__c;
        }
        if (rel.Contact_Relationship_Type__r.Label_Editable__c) {
            return rel.Label__c;
        }
        return rel.Contact_Relationship_Type__r.Label__c;
    }

    public String getLabelForRelationship(Map_Member_Placeholder_Relationship__c rel) {
        if (rel == null) {
            return '';
        }

        Map<String, Object> fields = rel.getPopulatedFieldsAsMap();

        if (!fields.containsKey('Contact_Relationship_Type__r')) {
            return rel.Label__c;
        }

        if (rel.Contact_Relationship_Type__r == null) {
            return rel.Label__c;
        }
        if (rel.Contact_Relationship_Type__r.Label_Editable__c == null) {
            return rel.Label__c;
        }
        if (rel.Contact_Relationship_Type__r.Label_Editable__c) {
            return rel.Label__c;
        }
        return rel.Contact_Relationship_Type__r.Label__c;
    }
}