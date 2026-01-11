/**
* @File Name : AccountWrapper.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : November 17, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | November 17, 2024 |   | Initial Version
**/

public with sharing class AccountWrapper  implements AccountMapObject{
    @AuraEnabled
    public Account member;

    @AuraEnabled
    public Account relatedAccount;

    public Id id() {
        return member.Id;
    }

    public Id accountId() {
        return member.Id;
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
        return Account.sObjectType.getDescribe().getName();
    }

    public String influence() {
        return '';
    }

    public String support() {
        return '';
    }

    public String supportColor() {
        return '';
    }

    public Object get(String key) {
        try {
            return member.get(key);
        } catch (Exception e) {
            return null;
        }
    }

    public AccountWrapper(Account hierarchyMember) {

		if (hierarchyMember != null) {
            List<Account> accounts = AccountSelector.newInstance()
                .selectById(new Set<Id>{ hierarchyMember.Id });
				this.relatedAccount = accounts.size() > 0 ? accounts[0] : null;
				this.member = accounts.size() > 0 ? accounts[0] : null;
        }
          
        //this(hierarchyMember, hierarchyMember.Account__r);
    }

    /*public AccountWrapper(Account_Map_Member__c hierarchyMember, Account related) {
        this.member = hierarchyMember;
        if (related != null) {
            this.relatedAccount = related;
        } else if (hierarchyMember.Account__c != null) {
            List<Account> accounts = AccountSelector.newInstance()
                .selectById(new Set<Id>{ hierarchyMember.Account__c });
            this.relatedAccount = accounts.size() > 0 ? accounts[0] : null;
        }
    }*/

    public Boolean equals(Object obj) {
        if (obj == null || !(obj instanceof AccountWrapper)) {
            return false;
        }

        AccountWrapper other = (AccountWrapper) obj;

        return this.id() == other.id();
    }

    public Integer hashCode() {
        return String.valueOf(member.id).hashCode();
    }
}