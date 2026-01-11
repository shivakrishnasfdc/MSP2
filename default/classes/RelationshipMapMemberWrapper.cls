public with sharing class RelationshipMapMemberWrapper implements IRelationshipMapObject {
    @AuraEnabled
    public Relationship_Map_Member__c member;

    @AuraEnabled
    public Contact relatedContact;

    public Id id() {
        return member.Id;
    }

    public Id contactId() {
        return member.pqcrush__Contact__c;
    }

    public String contactFirstName() {
        return relatedContact != null ? relatedContact.FirstName : '';
    }

    public String contactLastName() {
        return relatedContact != null ? relatedContact.LastName : '';
    }

    public Id parentId() {
        return relatedContact != null ? relatedContact.ReportsToId : '';
    }

    public String objectName() {
        return Relationship_Map_Member__c.sObjectType.getDescribe().getName();
    }

    public String influence() {
        return member.pqcrush__InfluenceId__r.Name;
    }

    public String support() {
        return member.pqcrush__SupportId__r.Name;
    }

    public String supportColor() {
        return member.pqcrush__SupportId__r.Color__c;
    }

    public Object get(String key) {
        try {
            return member.get(key);
        } catch (Exception e) {
            return null;
        }
    }

    public RelationshipMapMemberWrapper(Relationship_Map_Member__c hierarchyMember) {
        this(hierarchyMember, hierarchyMember.Contact__r);
    }

    public RelationshipMapMemberWrapper(Relationship_Map_Member__c hierarchyMember, Contact related) {
        this.member = hierarchyMember;
        if (related != null) {
            this.relatedContact = related;
        } else if (hierarchyMember.Contact__c != null) {
            List<Contact> contacts = ContactSelector.newInstance()
                .selectById(new Set<Id>{ hierarchyMember.Contact__c });
            this.relatedContact = contacts.size() > 0 ? contacts[0] : null;
        }
    }

    public Boolean equals(Object obj) {
        if (obj == null || !(obj instanceof RelationshipMapMemberWrapper)) {
            return false;
        }

        RelationshipMapMemberWrapper other = (RelationshipMapMemberWrapper) obj;

        return this.id() == other.id();
    }

    public Integer hashCode() {
        return String.valueOf(member.id).hashCode();
    }
}