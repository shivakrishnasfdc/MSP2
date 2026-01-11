public with sharing class KeyStakeholderService {
    public static List<Key_Stakeholder__c> addContactAsKeyStakeholder(Id accountPlanId, Set<Id> contactIdSet) {
        return service().addContactAsKeyStakeholder(accountPlanId, contactIdSet);
    }

    private static KeyStakeholderServiceImpl service() {
        return (KeyStakeholderServiceImpl) Application.Service.newInstance(KeyStakeholderServiceImpl.class);
    }
}