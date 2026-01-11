public with sharing class MapMemberUserWrapper implements IRelationshipMapUserObject {
    Map_Member_User__c member;
    User relatedUser;

    public Id id() {
        return member.Id;
    }

    public Id userId() {
        return member.pqcrush__User__c;
    }

    public String userFirstName() {
        return relatedUser != null ? relatedUser.FirstName : '';
    }

    public String userLastName() {
        return relatedUser != null ? relatedUser.LastName : '';
    }

    public Id managerId() {
        return relatedUser != null ? relatedUser.ManagerId : '';
    }

    public String objectName() {
        return Map_Member_User__c.sObjectType.getDescribe().getName();
    }

    public Object get(String key) {
        try {
            return member.get(key);
        } catch (Exception e) {
            return null;
        }
    }

    public MapMemberUserWrapper(Map_Member_User__c hierarchyMember) {
        this(hierarchyMember, hierarchyMember.User__r);
    }

    public MapMemberUserWrapper(Map_Member_User__c hierarchyMember, User related) {
        this.member = hierarchyMember;
        if (related != null) {
            this.relatedUser = related;
        } else if (hierarchyMember.User__c != null) {
            List<User> users = UsersSelector.newInstance()
                .selectById(new Set<Id>{ hierarchyMember.User__c });
            this.relatedUser = users.size() > 0 ? users[0] : null;
        }
    }

    public Boolean equals(Object obj) {
        if (obj == null || !(obj instanceof MapMemberUserWrapper)) {
            return false;
        }

        MapMemberUserWrapper other = (MapMemberUserWrapper) obj;

        return this.id() == other.id();
    }

    public Integer hashCode() {
        return String.valueOf(member.id).hashCode();
    }
}