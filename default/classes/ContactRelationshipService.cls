public with sharing class ContactRelationshipService {
    public static List<GraphLinkData> getRelationships(Set<Id> contactIds, Id mapId, Boolean hasAccountPlanSetting) {
        return service().getRelationships(contactIds, mapId, hasAccountPlanSetting);
    }

    public static void deleteCustomLinks(List<GraphLinkData> linkData) {
        service().deleteCustomLinks(linkData);
    }

    public static void newCustomLinks(List<GraphLinkData> linkData, Id mapOrAccountPlanId) {
        service().newCustomLinks(linkData, mapOrAccountPlanId);
    }

    public static void updateCustomLinks(List<GraphLinkData> linkData) {
        service().updateCustomLinks(linkData);
    }

    private static ContactRelationshipServiceImpl service() {
        return (ContactRelationshipServiceImpl) Application.Service.newInstance(ContactRelationshipServiceImpl.class);
    }
}