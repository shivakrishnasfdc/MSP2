@IsTest
private class RelationshipMapMemberWrapperTest {
    /************************************
     *** Initializer() ***
     ***********************************/

    @isTest
    public static void initializerTest() {
        TestMockData md = new TestMockData();

        RelationshipMapMemberWrapper wrapper = new RelationshipMapMemberWrapper(md.mockRelationshipMapMember);

        System.assertNotEquals(null, wrapper, 'wrapper should exist');
        System.assertEquals(md.mockRelationshipMapMember.Id, wrapper.id(), 'Id should match wrapped object');
        System.assertEquals(
            md.mockRelationshipMapMember.pqcrush__Contact__c,
            wrapper.contactId(),
            'contactId should match wrapped object'
        );
        System.assertEquals(
            md.mockRelationshipMapMember.pqcrush__Contact__r.FirstName,
            wrapper.contactFirstName(),
            'contactFirstName should match wrapped object'
        );
        System.assertEquals(
            md.mockRelationshipMapMember.pqcrush__Contact__r.LastName,
            wrapper.contactLastName(),
            'contactLastName should match wrapped object'
        );
        System.assertEquals(
            md.mockRelationshipMapMember.pqcrush__Contact__r.ReportsToId,
            wrapper.parentId(),
            'parentId should match wrapped object'
        );
        System.assertEquals(
            Relationship_Map_Member__c.sObjectType.getDescribe().getName(),
            wrapper.objectName(),
            'objectName should match wrapped object'
        );
        System.assertEquals(
            md.mockRelationshipMapMember.pqcrush__Influence__c,
            wrapper.influence(),
            'influence should match wrapped object'
        );
        System.assertEquals(
            md.mockRelationshipMapMember.pqcrush__Support__c,
            wrapper.support(),
            'support should match wrapped object'
        );
        System.assertEquals(
            md.mockRelationshipMapMember.pqcrush__Support__c,
            wrapper.get(Relationship_Map_Member__c.pqcrush__Support__c.getDescribe().getName()),
            'get support should match wrapped object'
        );
    }

    /************************************
     *** equals() ***
     ***********************************/

    @isTest
    public static void equalsTest() {
        TestMockData md = new TestMockData();

        RelationshipMapMemberWrapper wrapper1 = new RelationshipMapMemberWrapper(md.mockRelationshipMapMember);
        RelationshipMapMemberWrapper wrapper2 = new RelationshipMapMemberWrapper(md.mockRelationshipMapMember);
        RelationshipMapMemberWrapper wrapper3 = new RelationshipMapMemberWrapper(md.mockRelationshipMapMember);
        System.assertEquals(wrapper1, wrapper2);
        System.assert(wrapper1.equals(wrapper1));
        System.assert(wrapper1.equals(wrapper2));
        System.assert(wrapper2.equals(wrapper1));
        System.assert(wrapper2.equals(wrapper3));
        System.assert(wrapper1.equals(wrapper3));
    }

    /************************************
     *** hashCode() ***
     ***********************************/

    @isTest
    public static void hashCodeTest() {
        TestMockData md = new TestMockData();

        RelationshipMapMemberWrapper wrapper = new RelationshipMapMemberWrapper(md.mockRelationshipMapMember);
        System.assertEquals(String.valueOf(md.mockRelationshipMapMember.id).hashCode(), wrapper.hashCode());
    }
}