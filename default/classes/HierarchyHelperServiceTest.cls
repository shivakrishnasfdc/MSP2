@IsTest
private class HierarchyHelperServiceTest {
    @IsTest
    static void getLabelForRelationshipNullTest() {
        Contact_Relationship__c c = null;
        Map_Member_Placeholder_Relationship__c m = null;
        String result1 = HierarchyHelperService.getLabelForRelationship(c);
        String result2 = HierarchyHelperService.getLabelForRelationship(m);
        System.assertEquals('', result1);
        System.assertEquals('', result2);
    }
}