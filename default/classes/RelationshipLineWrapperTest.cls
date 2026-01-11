@isTest
private class RelationshipLineWrapperTest {
    @isTest
    static void instanceTest() {
        Id rlId = fflib_IDGenerator.generate(Contact.SObjectType);
        String nodeName = 'test';
        String lineLabel = 'label';
        String lineColor = '#ff00ff';

        RelationshipLineWrapper rlw = new RelationshipLineWrapper(rlId, lineLabel, lineColor, nodeName);
        System.assertEquals(rlId, rlw.id);
        System.assertEquals(nodeName, rlw.nodeName);
        System.assertEquals(lineLabel, rlw.lineLabel);
        System.assertEquals(lineColor, rlw.lineColor);
    }
}