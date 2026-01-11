public with sharing class KeyStakeholderServiceImpl {
    public List<Key_Stakeholder__c> addContactAsKeyStakeholder(Id accountPlanId, Set<Id> contactIdSet) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        List<Key_Stakeholder__c> keyStakeholders = new List<Key_Stakeholder__c>();

        for (Id contactId : contactIdSet) {
            Key_Stakeholder__c keyStakeholder = new Key_Stakeholder__c(
                Account_Plan__c = accountPlanId,
                Contact__c = contactId
            );
            keyStakeholders.add(keyStakeholder);
            uow.registerNew(keyStakeholder);
        }

        uow.commitWork();

        return keyStakeholders;
    }
}