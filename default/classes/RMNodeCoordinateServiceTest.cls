@isTest
private class RMNodeCoordinateServiceTest {
    @isTest
    static void getNodeCoordinatesTest() {
        testMockData md = new testMockData();
        RMNodeCoordinateSelector mockRMNodeCoordinateSelector = md.mockRMNodeCoordinateSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow; //NOPMD - Needs to be called in order for it to be mocked in the test

        md.mocks.startStubbing();
        md.mocks.when(mockRMNodeCoordinateSelector.selectByObjectId(md.mockRelationshipMapId))
            .thenReturn(new List<RM_Node_Coordinate__c>{ md.mockRMNodeCoordinateForRM });
        md.mocks.stopStubbing();

        Map<String, RM_Node_Coordinate__c> coordinates = RMNodeCoordinateService.getNodeCoordinates(
            md.mockRelationshipMapId
        );

        System.assert(coordinates.keySet().contains(md.mockRMNodeCoordinateForRM.Key__c));
    }

    @isTest
    static void saveAllNodeCoordinatesTest() {
        testMockData md = new testMockData();
        RMNodeCoordinateSelector mockRMNodeCoordinateSelector = md.mockRMNodeCoordinateSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        List<RM_Node_Coordinate__c> oldCoordinates = new List<RM_Node_Coordinate__c>{ md.mockRMNodeCoordinateForRM };

        List<GraphNodeData> gnd = new List<GraphNodeData>();
        GraphNodeData graphData = new GraphNodeData('label', 'desc');
        graphData.key = 'key1';
        graphData.tempId = 'tempId';
        graphData.location = new Point((Double) 111.11, (Double) 222.22);
        gnd.add(graphData);

        md.mocks.startStubbing();
        md.mocks.when(mockRMNodeCoordinateSelector.selectByObjectId(md.mockRelationshipMapId))
            .thenReturn(oldCoordinates);
        md.mocks.stopStubbing();

        RMNodeCoordinateService.saveAllNodeCoordinates(md.mockRelationshipMapId, gnd);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew(
                new RM_Node_Coordinate__c(
                    Key__c = graphData.key,
                    TempId__c = '',
                    X__c = Double.valueOf(graphData.location.x),
                    Y__c = Double.valueOf(graphData.location.y),
                    Relationship_Map__c = md.mockRelationshipMapId
                )
            );
        System.assert(true, 'assert by mock verify');
    }

    @isTest
    static void updateNodeCoordinatesTest() {
        testMockData md = new testMockData();
        RMNodeCoordinateSelector mockRMNodeCoordinateSelector = md.mockRMNodeCoordinateSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        List<RM_Node_Coordinate__c> oldCoordinates = new List<RM_Node_Coordinate__c>{ md.mockRMNodeCoordinateForRM };

        List<GraphNodeData> gnd = new List<GraphNodeData>();
        GraphNodeData graphData = new GraphNodeData('label', 'desc');
        graphData.key = md.mockRMNodeCoordinateForRM.Key__c;
        graphData.location = new Point((Double) 888.11, (Double) 999.22);
        gnd.add(graphData);

        md.mocks.startStubbing();
        md.mocks.when(
                mockRMNodeCoordinateSelector.selectByObjectIdAndKeys(
                    md.mockRelationshipMapId,
                    new Set<String>{ graphData.key }
                )
            )
            .thenReturn(oldCoordinates);
        md.mocks.stopStubbing();

        RM_Node_Coordinate__c oldCoordinate = md.mockRMNodeCoordinateForRM;
        oldCoordinate.X__c = graphData.location.x;
        oldCoordinate.Y__c = graphData.location.y;

        RMNodeCoordinateService.updateNodeCoordinates(md.mockRelationshipMapId, gnd);

        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1)).registerDirty(oldCoordinate);
        System.assert(true, 'assert by mock verify');
    }
}