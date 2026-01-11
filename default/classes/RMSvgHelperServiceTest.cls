@isTest
private class RMSvgHelperServiceTest {
    @isTest
    static void injectBoundBadgesTest() {
        Id id1 = fflib_IDGenerator.generate(RM_Svg__c.SObjectType);
        Id id2 = fflib_IDGenerator.generate(RM_Svg__c.SObjectType);

        RM_Svg__c svg1 = new RM_Svg__c(Id = id1, Contact_Field_API_Name__c = 'foo');
        RM_Svg__c svg2 = new RM_Svg__c(Id = id2, Contact_Field_API_Name__c = 'something else');

        List<RM_Svg__c> svgs = new List<RM_Svg__c>{ svg1, svg2 };

        List<GraphNodeData> graphNodeDataList = new List<GraphNodeData>();

        String value = 'true';
        String apiName = 'foo';
        OrgAdditionalField f1 = new OrgAdditionalField(apiName, 'foo', value, false, '');
        OrgAdditionalField f2 = new OrgAdditionalField('title', 'title', 'Mr', false, '');

        Id cId = fflib_IDGenerator.generate(Contact.SObjectType);
        GraphNodeData graphData1 = new GraphNodeData(cId, 'groupKey', 'label', 'horizontal');
        graphData1.additionalFields = new List<OrgAdditionalField>{ f1, f2 };

        graphNodeDataList.add(graphData1);

        List<GraphNodeData> result = RMSvgHelperService.injectBoundBadges(svgs, graphNodeDataList);

        System.assertEquals(1, result.size());
        System.assertEquals(1, result[0].additionalFields.size());
        System.assertEquals('title', result[0].additionalFields[0].apiName);
        System.assertEquals(id1, result[0].badges[0].id);
    }
}