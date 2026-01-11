public with sharing class ContactExtendedFieldService {
    public static void updateProfileImageData(Id contactId, String base64Data) {
        service().updateProfileImageData(contactId, base64Data);
    }

    public static void updateInfluenceSupport(Id contactId, Id influenceId, Id supportId) {
        service().updateInfluenceSupport(contactId, influenceId, supportId);
    }

    private static ContactExtendedFieldServiceImpl service() {
        return (ContactExtendedFieldServiceImpl) Application.Service.newInstance(ContactExtendedFieldServiceImpl.class);
    }
}