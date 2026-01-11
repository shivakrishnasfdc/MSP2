@isTest
private class CommonRelationshipLineObjectTest {
    @isTest
    static void instanceTest() {
        Id croId = fflib_IDGenerator.generate(Relationship_Map__c.SObjectType);
        Id rmId = fflib_IDGenerator.generate(Relationship_Map__c.SObjectType);
        Id apId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        String containerName = 'test';
        Id nodeKey = fflib_IDGenerator.generate(Contact.SObjectType);
        String lineLabel = 'label';
        String lineColor = '#ff00ff';
        Boolean isGlobal = true;

        CommonRelationshipLineObject cro = new CommonRelationshipLineObject(
            croId,
            rmId,
            apId,
            containerName,
            nodeKey,
            lineLabel,
            lineColor,
            isGlobal
        );
        System.assertEquals(croId, cro.id);
        System.assertEquals(rmId, cro.relationshipMapId);
        System.assertEquals(apId, cro.accountPlanId);
        System.assertEquals(containerName, cro.containerName);
        System.assertEquals(nodeKey, cro.nodeKey);
        System.assertEquals(lineLabel, cro.lineLabel);
        System.assertEquals(lineColor, cro.lineColor);
        System.assertEquals(isGlobal, cro.isGlobalRelationship);
    }
}