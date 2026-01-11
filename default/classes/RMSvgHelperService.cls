public with sharing class RMSvgHelperService {
    @AuraEnabled
    public static List<GraphNodeData> injectBoundBadges(List<RM_Svg__c> svgs, List<GraphNodeData> graphNodeDataList) {
        return service().injectBoundBadges(svgs, graphNodeDataList);
    }

    private static RMSvgHelperServiceImpl service() {
        return (RMSvgHelperServiceImpl) Application.Service.newInstance(RMSvgHelperServiceImpl.class);
    }
}