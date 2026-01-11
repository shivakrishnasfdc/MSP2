public with sharing class AccountService {
    @AuraEnabled
    public static Id getRelatedAccountIdForRecordId(Id recordId) {
        return service().getRelatedAccountIdForRecordId(recordId);
    }

    @AuraEnabled
    public static Map<Id, Account> getAccountAndDescendents(Id parentAccountId) {
        return service().getAccountAndDescendents(parentAccountId);
    }

    public static Map<Id, Set<Id>> getTaskWhatIdsByAccountId(Set<Id> accountIds) {
        return service().getTaskWhatIdsByAccountId(accountIds);
    }

    public static Set<Id> getIdsForRelatedObjectsToAccount(Id accountId) {
        return service().getIdsForRelatedObjectsToAccount(accountId);
    }

    public static Set<Id> getContactIdsForAccount(Set<Id> accountIds) {
        return service().getContactIdsForAccount(accountIds);
    }

    private static AccountServiceImpl service() {
        return (AccountServiceImpl) Application.Service.newInstance(AccountServiceImpl.class);
    }
}