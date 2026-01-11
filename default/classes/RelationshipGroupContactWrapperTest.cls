@isTest
private class RelationshipGroupContactWrapperTest {
    @isTest
    static void instanceTest() {
        Id rgcaId = fflib_IDGenerator.generate(Relationship_Group_Contact_Association__c.SObjectType);
        Id rgId = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType);
        Id rmId = fflib_IDGenerator.generate(Relationship_Map__c.SObjectType);
        Id apId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        String groupLabel = 'group label';
        String containerName = 'My Map';
        Boolean isGlobalGroup = true;

        RelationshipGroupContactWrapper wrapper = new RelationshipGroupContactWrapper(
            rgcaId,
            contactId,
            rgId,
            groupLabel,
            rmId,
            apId,
            containerName,
            isGlobalGroup
        );

        System.assertEquals(rgcaId, wrapper.id);
        System.assertEquals(contactId, wrapper.contactId);
        System.assertEquals(rgId, wrapper.groupId);
        System.assertEquals(groupLabel, wrapper.groupLabel);
        System.assertEquals(rmId, wrapper.relationshipMapId);
        System.assertEquals(apId, wrapper.accountPlanId);
        System.assertEquals(containerName, wrapper.containerName);
        System.assertEquals(isGlobalGroup, wrapper.isGlobalGroup);
    }

    @isTest
    static void convertTest() {
        String groupLabel = 'group Name';
        String mapName = 'my map';
        Contact c = TestDataFactory.createContact('john', 'smith');
        Relationship_Map__c rm = TestDataFactory.createRelationshipMap(mapName);
        Relationship_Group__c g = TestDataFactory.createRelationshipGroupForMap(groupLabel, rm.Id);

        Relationship_Group_Contact_Association__c rgca = new Relationship_Group_Contact_Association__c(
            Relationship_Group__c = g.Id,
            Contact__c = c.Id
        );
        insert rgca;

        Relationship_Group_Contact_Association__c queryRgca = [
            SELECT
                Id,
                Relationship_Group__c,
                Contact__c,
                Relationship_Group__r.Label__c,
                Relationship_Group__r.Relationship_Map__r.Name,
                Relationship_Group__r.Account_Plan__c,
                Relationship_Group__r.Account_Plan__r.Name
            FROM Relationship_Group_Contact_Association__c
            WHERE Id = :rgca.Id
        ];

        List<RelationshipGroupContactWrapper> result = RelationshipGroupContactWrapper.convert(
            new List<Relationship_Group_Contact_Association__c>{ queryRgca }
        );
        System.assertEquals(1, result.size());
        System.assertEquals(c.Id, result[0].contactId);
        System.assertEquals(g.Id, result[0].groupId);
        System.assertEquals(rm.Id, result[0].relationshipMapId);
        System.assertEquals(groupLabel, result[0].groupLabel);
        System.assertEquals(mapName, result[0].containerName);
    }

    @isTest
    static void convertTest2() {
        String groupLabel = 'group Name';
        String planName = 'my map';
        Contact c = TestDataFactory.createContact('john', 'smith');
        Account_Plan__c ap = TestDataFactory.createAccountPlan(planName);
        Relationship_Group__c g = TestDataFactory.createRelationshipGroupForAccountPlan(groupLabel, ap.Id);

        Relationship_Group_Contact_Association__c rgca = new Relationship_Group_Contact_Association__c(
            Relationship_Group__c = g.Id,
            Contact__c = c.Id
        );
        insert rgca;

        Relationship_Group_Contact_Association__c queryRgca = [
            SELECT
                Id,
                Relationship_Group__c,
                Contact__c,
                Relationship_Group__r.Label__c,
                Relationship_Group__r.Relationship_Map__r.Name,
                Relationship_Group__r.Account_Plan__c,
                Relationship_Group__r.Account_Plan__r.Name
            FROM Relationship_Group_Contact_Association__c
            WHERE Id = :rgca.Id
        ];

        List<RelationshipGroupContactWrapper> result = RelationshipGroupContactWrapper.convert(
            new List<Relationship_Group_Contact_Association__c>{ queryRgca }
        );
        System.assertEquals(1, result.size());
        System.assertEquals(c.Id, result[0].contactId);
        System.assertEquals(g.Id, result[0].groupId);
        System.assertEquals(ap.Id, result[0].accountPlanId);
        System.assertEquals(groupLabel, result[0].groupLabel);
        System.assertEquals(planName, result[0].containerName);
    }

    @isTest
    static void convertNullTest() {
        List<RelationshipGroupContactWrapper> result = RelationshipGroupContactWrapper.convert(null);
        System.assertEquals(0, result.size());
    }
}