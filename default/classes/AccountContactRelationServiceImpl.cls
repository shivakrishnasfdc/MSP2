public with sharing class AccountContactRelationServiceImpl {
    // Check to see if Account Contact Relation is turned on
    public Boolean areAccountContactRelationEnabled() {
        Schema.SObjectType accountContactRelationType = Application.getGlobalDescribe().get('AccountContactRelation');
        if (accountContactRelationType != null) {
            return true;
        }
        return false;
    }

    public Set<Id> getContactIdsForAccounts(Set<Id> accountIds) {
        Set<Id> result = new Set<Id>();
        for (
            SObject acr : Database.query(
                'SELECT Id, AccountId, IsActive, ContactId FROM AccountContactRelation WHERE IsActive=TRUE AND AccountId IN :accountIds'
            )
        ) {
            result.add((Id) acr.get('ContactId'));
        }
        return result;
    }
}