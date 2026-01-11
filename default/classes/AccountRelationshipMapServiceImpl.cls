public with sharing class AccountRelationshipMapServiceImpl {
    
    public List<Account_Map_Member__c> addAccountToRelationshipMap(Id relationshipMapId, Set<Id> accountIdSet) {
        System.debug('==addAccountToRelationshipMap implementataion==called');
        System.debug('==accountIdSet=='+accountIdSet);
        System.debug('==relationshipMapId=='+relationshipMapId);
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        List<Account_Map_Member__c> mapMembers = new List<Account_Map_Member__c>();

        for (Id accountId : accountIdSet) {
            Account_Map_Member__c member = new Account_Map_Member__c(
                Account_Relationship_Map__c = relationshipMapId,
                pqcrush__Account__c = accountId
            );
            System.debug('===member account=='+member);
            mapMembers.add(member);
            uow.registerNew(member);
        }
        System.debug('===mapMembers=='+mapMembers);

        uow.commitWork();

        return mapMembers;
    }
}