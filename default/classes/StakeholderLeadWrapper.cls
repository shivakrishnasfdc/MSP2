public with sharing class StakeholderLeadWrapper implements IRelationshipMapLeadObject2 {
    Key_Stakeholder_Lead__c member;
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

    public String title() {
        if (Schema.sObjectType.Lead.fields.Title.isAccessible()) {
            return relatedLead.Title;
        }
        return '';
    }

    public String objectName() {
        return Key_Stakeholder_Lead__c.sObjectType.getDescribe().getName();
    }

    public Object get(String key) {
        try {
            return member.get(key);
        } catch (Exception e) {
            return null;
        }
    }

    public StakeholderLeadWrapper(Key_Stakeholder_Lead__c keyStakeholderLead) {
        this(keyStakeholderLead, keyStakeholderLead.Lead__r);
    }

    public StakeholderLeadWrapper(Key_Stakeholder_Lead__c keyStakeholderLead, Lead related) {
        this.member = keyStakeholderLead;
        if (related != null) {
            this.relatedLead = related;
        } else if (keyStakeholderLead.Lead__c != null) {
            List<Lead> leads = LeadSelector.newInstance().selectById(new Set<Id>{ keyStakeholderLead.Lead__c });
            this.relatedLead = (leads != null && leads.size() > 0) ? leads[0] : null;
        }
    }

    public Boolean equals(Object obj) {
        if (obj == null || !(obj instanceof StakeholderLeadWrapper)) {
            return false;
        }

        StakeholderLeadWrapper other = (StakeholderLeadWrapper) obj;

        return this.id() == other.id();
    }

    public Integer hashCode() {
        return String.valueOf(member.id).hashCode();
    }
}