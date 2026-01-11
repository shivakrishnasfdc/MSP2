public with sharing class MapMemberLeadWrapper implements IRelationshipMapLeadObject2 {
    Map_Member_Lead__c member;
    Lead relatedLead;

    public Id id() {
        return member.Id;
    }

    public Id leadId() {
        return member.pqcrush__Lead__c;
    }

    public String firstName() {
        return relatedLead != null ? relatedLead.FirstName : '';
    }

    public String lastName() {
        return relatedLead != null ? relatedLead.LastName : '';
    }

    public String objectName() {
        return Map_Member_Lead__c.sObjectType.getDescribe().getName();
    }

    public String title() {
        if (Schema.sObjectType.Lead.fields.Title.isAccessible()) {
            return relatedLead.Title;
        }
        return '';
    }

    public Object get(String key) {
        try {
            return member.get(key);
        } catch (Exception e) {
            return null;
        }
    }

    public MapMemberLeadWrapper(Map_Member_Lead__c mapMemberLead) {
        this(mapMemberLead, mapMemberLead.Lead__r);
    }

    public MapMemberLeadWrapper(Map_Member_Lead__c mapMemberLead, Lead related) {
        this.member = mapMemberLead;
        if (related != null) {
            this.relatedLead = related;
        } else if (mapMemberLead.Lead__c != null) {
            List<Lead> leads = LeadSelector.newInstance().selectById(new Set<Id>{ mapMemberLead.Lead__c });
            this.relatedLead = (leads != null && leads.size() > 0) ? leads[0] : null;
        }
    }

    public Boolean equals(Object obj) {
        if (obj == null || !(obj instanceof MapMemberLeadWrapper)) {
            return false;
        }

        MapMemberLeadWrapper other = (MapMemberLeadWrapper) obj;

        return this.id() == other.id();
    }

    public Integer hashCode() {
        return String.valueOf(member.id).hashCode();
    }
}