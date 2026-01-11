public with sharing class AccountContactRelationService {
    public static Boolean areAccountContactRelationEnabled() {
        return service().areAccountContactRelationEnabled();
    }

    public static Set<Id> getContactIdsForAccounts(Set<Id> accountIds) {
        return service().getContactIdsForAccounts(accountIds);
    }

    private static AccountContactRelationServiceImpl service() {
        return (AccountContactRelationServiceImpl) Application.Service.newInstance(
            AccountContactRelationServiceImpl.class
        );
    }
}