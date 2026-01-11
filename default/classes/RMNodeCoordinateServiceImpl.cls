public with sharing class RMNodeCoordinateServiceImpl {
    /******************************
     *      PUBLIC METHODS
     ******************************/

    public void saveAllNodeCoordinates(Id objectId, List<GraphNodeData> gnd) {
        
            List<RM_Node_Coordinate__c> oldCoordinates = RMNodeCoordinateSelector.newInstance()
                .selectByObjectId(objectId);
            if (Schema.sObjectType.RM_Node_Coordinate__c.isDeletable()) {
            Database.Delete(oldCoordinates, false,Accesslevel.USER_MODE); // Using Database.Delete instead of RegisterDeleted to eliminate Race Condition by setting AllorNone to false
            }

        fflib_ISObjectUnitOfWork uow2 = Application.UnitOfWork.newInstance();
        for (GraphNodeData node : gnd) {
            String key = '';
            String tempId = '';
            if (!String.isBlank(node.key)) {
                key = node.key;
            } else if (!String.isBlank(node.tempId)) {
                tempId = node.tempId;
            }

            if (!String.isBlank(key)) {
                RM_Node_Coordinate__c rmNodeCoordinate = new RM_Node_Coordinate__c(Key__c = key, TempId__c = tempId);

                if (node.location != null) {
                    rmNodeCoordinate.X__c = Double.valueOf(node.location.x);
                    rmNodeCoordinate.Y__c = Double.valueOf(node.location.y);
                }

                if (objectId.getSobjectType() == Relationship_Map__c.getSObjectType()) {
                    rmNodeCoordinate.Relationship_Map__c = objectId;
                } else if (objectId.getSobjectType() == Account_Plan__c.getSObjectType()) {
                    rmNodeCoordinate.Account_Plan__c = objectId;
                }
                uow2.registerNew(rmNodeCoordinate);
            }
        }

        uow2.commitWork();
    }

    public Map<String, RM_Node_Coordinate__c> getNodeCoordinates(Id objectId) {
        List<RM_Node_Coordinate__c> coordinates = RMNodeCoordinateSelector.newInstance().selectByObjectId(objectId);
        Map<String, RM_Node_Coordinate__c> result = new Map<String, RM_Node_Coordinate__c>();
        for (RM_Node_Coordinate__c cordinate : coordinates) {
            if (!String.isBlank(cordinate.Key__c)) {
                result.put(cordinate.Key__c, cordinate);
            }
            if (!String.isBlank(cordinate.TempId__c)) {
                result.put(cordinate.TempId__c, cordinate);
            }
        }
        return result;
    }

    public void updateNodeCoordinates(Id objectId, List<GraphNodeData> gnd) {
        Id relMapId = null;
        Id accountPlanId = null;
        if (objectId.getSobjectType() == Relationship_Map__c.getSObjectType()) {
            relMapId = objectId;
        } else if (objectId.getSobjectType() == Account_Plan__c.getSObjectType()) {
            accountPlanId = objectId;
        }

        Set<String> keys = new Set<String>();
        Map<String, GraphNodeData> mapData = new Map<String, GraphNodeData>();
        for (GraphNodeData node : gnd) {
            if (!String.isBlank(node.key)) {
                keys.add(node.key);
                mapData.put(node.key, node);
            }
        }

        List<RM_Node_Coordinate__c> coordinates = RMNodeCoordinateSelector.newInstance()
            .selectByObjectIdAndKeys(objectId, keys);

        Map<String, RM_Node_Coordinate__c> mapKeyCoordinates = new Map<String, RM_Node_Coordinate__c>();
        for (RM_Node_Coordinate__c coordinate : coordinates) {
            if (!String.isBlank(coordinate.Key__c)) {
                mapKeyCoordinates.put(coordinate.Key__c, coordinate);
            }
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (GraphNodeData node : gnd) {
            RM_Node_Coordinate__c existingCoord = mapKeyCoordinates.get(node.key);
            if (existingCoord != null && node.location != null) {
                existingCoord.X__c = node.location.x;
                existingCoord.Y__c = node.location.y;
                uow.registerDirty(existingCoord);
            } else if (node.location != null) {
                uow.registerNew(
                    new RM_Node_Coordinate__c(
                        Key__c = node.key,
                        TempId__c = node.tempId,
                        X__c = Double.valueOf(node.location.x),
                        Y__c = Double.valueOf(node.location.y),
                        Relationship_Map__c = relMapId,
                        Account_Plan__c = accountPlanId
                    )
                );
            }
        }

        uow.commitWork();
    }

    public void udpateCoordinatesForLeads(Set<String> leadIds, Map<Id, Id> leadContactMap) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<RM_Node_Coordinate__c> coordinates = RMNodeCoordinateSelector.newInstance().selectByKeys(leadIds);
        for (RM_Node_Coordinate__c coordinate : coordinates) {
            Id contactId = leadContactMap.get(coordinate.Key__c);
            if (contactId != null) {
                coordinate.Key__c = contactId;
                uow.registerDirty(coordinate);
            }
        }

        uow.commitWork();
    }
}