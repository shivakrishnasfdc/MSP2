public with sharing class ContactExtendedFieldServiceImpl {
    public void updateProfileImageData(Id contactId, String base64Data) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        List<Contact_Extended_Field__c> extendedFields = ContactExtendedFieldSelector.newInstance()
            .selectByContactId(new Set<Id>{ contactId });
        if (extendedFields.size() == 1) {
            Contact_Extended_Field__c cef = extendedFields[0];
            cef.Profile_Picture_Data__c = base64Data;
            uow.registerDirty(cef);
        } else if (extendedFields.size() == 0) {
            uow.registerNew(
                new Contact_Extended_Field__c(Contact__c = contactId, Profile_Picture_Data__c = base64Data)
            );
        }

        uow.commitWork();
    }

    public void updateInfluenceSupport(Id contactId, Id influenceId, Id supportId) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        List<Contact_Extended_Field__c> extendedFields = ContactExtendedFieldSelector.newInstance()
            .selectByContactId(new Set<Id>{ contactId });
        if (extendedFields.size() == 1) {
            Contact_Extended_Field__c cef = extendedFields[0];
            cef.Influence__c = influenceId;
            cef.Support__c = supportId;
            uow.registerDirty(cef);
        } else if (extendedFields.size() == 0) {
            uow.registerNew(
                new Contact_Extended_Field__c(
                    Contact__c = contactId,
                    Influence__c = influenceId,
                    Support__c = supportId
                )
            );
        }
        System.debug('===extendedFields=='+extendedFields);
        uow.commitWork();
    }
}