public with sharing class AccountMemberWrapper  implements AccountMapObject{
    @AuraEnabled
    public Account_Map_Member__c member;

    @AuraEnabled
    public Account relatedAccount;

    public Id id() {
        return member.Id;
    }

    public Id accountId() {
        return member.pqcrush__Account__c;
    }

    public String accountFirstName() {
        return relatedAccount != null ? relatedAccount.Name : '';
    }

    public String accountLastName() {
        return relatedAccount != null ? relatedAccount.Name : '';
    }

    public Id parentId() {
        return relatedAccount != null ? relatedAccount.Id : '';
    }

    public String objectName() {
        return Account_Map_Member__c.sObjectType.getDescribe().getName();
    }

    public String influence() {
        return member.pqcrush__Local_Influence__r.Name;
    }

    public String support() {
        return member.pqcrush__Local_Support__r.Name;
    }

    public String supportColor() {
        return member.pqcrush__Local_Support__r.Color__c;
    }

    public Object get(String key) {
        try {
            return member.get(key);
        } catch (Exception e) {
            return null;
        }
    }

    public AccountMemberWrapper(Account_Map_Member__c hierarchyMember) {
        this(hierarchyMember, hierarchyMember.Account__r);
    }

    public AccountMemberWrapper(Account_Map_Member__c hierarchyMember, Account related) {
        this.member = hierarchyMember;
        if (related != null) {
            this.relatedAccount = related;
        } else if (hierarchyMember.Account__c != null) {
            List<Account> accounts = AccountSelector.newInstance()
                .selectById(new Set<Id>{ hierarchyMember.Account__c });
            this.relatedAccount = accounts.size() > 0 ? accounts[0] : null;
        }
    }

    public Boolean equals(Object obj) {
        if (obj == null || !(obj instanceof AccountMemberWrapper)) {
            return false;
        }

        AccountMemberWrapper other = (AccountMemberWrapper) obj;

        return this.id() == other.id();
    }

    public Integer hashCode() {
        return String.valueOf(member.id).hashCode();
    }
}