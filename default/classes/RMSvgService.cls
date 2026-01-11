public with sharing class RMSvgService {
    @AuraEnabled
    public static GraphData injectBadges(Id mapId, GraphData gd, RM_Chart_Setting__C setting) {
        return service().injectBadges(mapId, gd, setting);
    }

    @AuraEnabled
    public static void associateBadge(Id mapOrAccountPlanId, String badgeId, List<String> nodeIds) {
        service().associateBadge(mapOrAccountPlanId, badgeId, nodeIds);
    }

    @AuraEnabled
    public static void removeBadge(Id mapOrAccountPlanId, List<String> nodeIds) {
        service().removeBadge(mapOrAccountPlanId, nodeIds);
    }

    private static RMSvgServiceImpl service() {
        return (RMSvgServiceImpl) Application.Service.newInstance(RMSvgServiceImpl.class);
    }
}