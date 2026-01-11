public with sharing class RMNodeCoordinateService {
    public static void saveAllNodeCoordinates(Id objectId, List<GraphNodeData> gnd) {
        service().saveAllNodeCoordinates(objectId, gnd);
    }

    public static Map<String, RM_Node_Coordinate__c> getNodeCoordinates(Id objectId) {
        return service().getNodeCoordinates(objectId);
    }

    public static void updateNodeCoordinates(Id objectId, List<GraphNodeData> gnd) {
        service().updateNodeCoordinates(objectId, gnd);
    }

    public static void udpateCoordinatesForLeads(Set<String> leadIds, Map<Id, Id> leadContactMap) {
        service().udpateCoordinatesForLeads(leadIds, leadContactMap);
    }

    private static RMNodeCoordinateServiceImpl service() {
        return (RMNodeCoordinateServiceImpl) Application.Service.newInstance(RMNodeCoordinateServiceImpl.class);
    }
}