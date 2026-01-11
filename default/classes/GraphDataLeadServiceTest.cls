@isTest
private class GraphDataLeadServiceTest {
    @isTest
    static void createGraphDataNodesTest() {
        testMockData md = new testMockData();
        RelationshipGroupServiceImpl mockRelationshipGroupService = md.mockRelationshipGroupService;

        List<Lead> leads = new List<Lead>{ md.mockLead };
        Map<Id, IRelationshipMapLeadObject2> mapRelationshipMapMemberObject = new Map<Id, IRelationshipMapLeadObject2>();
        List<Relationship_Group_Lead_Association__c> rels = new List<Relationship_Group_Lead_Association__c>();
        Map<Id, Relationship_Group_Lead_Association__c> groupLeadAssocByLeadId = new Map<Id, Relationship_Group_Lead_Association__c>();
        Map<Id, Relationship_Group__c> allGroups = new Map<Id, Relationship_Group__c>();

        md.mocks.startStubbing();
        md.mocks.when(mockRelationshipGroupService.getGroupLeadAssocMap(rels, md.mockRelationshipMapId))
            .thenReturn(groupLeadAssocByLeadId);
        md.mocks.when(
                mockRelationshipGroupService.getAllGroups(
                    (Map<Id, Relationship_Group__c>) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject()
                )
            )
            .thenReturn(allGroups);
        md.mocks.when(
                mockRelationshipGroupService.createNodeDataForGroups(
                    (List<Relationship_Group__c>) fflib_Match.anyList()
                )
            )
            .thenReturn(new List<GraphNodeData>());
        md.mocks.stopStubbing();

        List<GraphNodeData> result = GraphDataLeadService.createGraphDataNodes(
            leads,
            mapRelationshipMapMemberObject,
            rels,
            md.mockRelationshipMapId
        );

        System.assertEquals(1, result.size(), 'Shoudl have 1 item');

        System.assertEquals(md.mockLeadId, result[0].key);
    }
}