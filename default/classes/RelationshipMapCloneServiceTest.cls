@SuppressWarnings('PMD.NcssMethodCount')
@isTest
private with sharing class RelationshipMapCloneServiceTest {
    /*** cloneRelationshipMaps() exception tests ***/
    @isTest
    private static void cloneRelationshipMapsNoMapIdTest() {
        TestMockData md = new TestMockData();
        // No Map Id
        RelationshipMapCloneWrapper wrapper = new RelationshipMapCloneWrapper(
            null,
            'newName',
            UserInfo.getUserId(),
            md.mockAccountId
        );
        try {
            RelationshipMapCloneService.cloneRelationshipMaps(new List<RelationshipMapCloneWrapper>{ wrapper });
            System.assert(false, 'Expected no map id exception');
        } catch (Exception e) {
            System.assertEquals('No map information passed when trying to clone a Relationship Map', e.getMessage());
        }
    }

    /*** cloneRelationshipMaps() functional tests ***/

    @isTest
    private static void cloneRelationshipMapsFullTest() {
        TestMockData md = new TestMockData();

        //Inserts do not need the trigger to run
        Application.bypassTrigger = true;

        Account account1 = new Account(Name = 'Account 1');
        insert account1;

        Relationship_Map__c rm = md.mockRelationshipMap.clone(false, true);
        rm.Id = null;
        rm.OwnerId = UserInfo.getUserId();
        insert rm;

        //Groups
        Relationship_Group__c localGroup = md.mockRelationshipGroup.clone(false, true);
        localGroup.Id = null;
        localGroup.Parent_Relationship_Group__c = null;
        localGroup.Relationship_Map__c = rm.Id;

        Relationship_Group__c globalGroup = md.mockRelationshipGroup.clone(false, true);
        globalGroup.Id = null;
        globalGroup.Parent_Relationship_Group__c = null;
        globalGroup.Relationship_Map__c = null;
        insert new List<SObject>{ localGroup, globalGroup };

        //Placeholders
        String placeholderLabel = 'The placeholder to find cloneRelationshipMapsFullTest';
        Map_Member_Placeholder__c placeholder = md.mockPlaceholder.clone(false, true);
        placeholder.Label__c = placeholderLabel;
        placeholder.Id = null;
        placeholder.pqcrush__Relationship_Map__c = rm.Id;
        placeholder.Account_Plan__c = null;

        Map_Member_Placeholder__c placeholder2 = md.mockPlaceholder.clone(false, true);
        placeholder2.Id = null;
        placeholder2.pqcrush__Relationship_Map__c = rm.Id;
        placeholder2.Account_Plan__c = null;
        insert new List<SObject>{ placeholder, placeholder2 };

        //placeholder group association
        Relationship_Group_Placeholder_Assoc__c plToLocalG = new Relationship_Group_Placeholder_Assoc__c(
            Map_Member_Placeholder__c = placeholder.Id,
            Relationship_Group__c = localGroup.Id
        );
        Relationship_Group_Placeholder_Assoc__c plToGlobalG = new Relationship_Group_Placeholder_Assoc__c(
            Map_Member_Placeholder__c = placeholder.Id,
            Relationship_Group__c = globalGroup.Id
        );
        insert new List<SObject>{ plToLocalG, plToGlobalG };

        //Contact for relationships
        Contact con = md.mockContact.clone(false, true);
        con.Id = null;
        con.ReportsToId = null;
        insert con;

        //Map Member
        Relationship_Map_Member__c mapMember = new Relationship_Map_Member__c(
            Relationship_Map__c = rm.Id,
            Contact__c = con.Id
        );
        insert mapMember;

        //User for Map Member User
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User usr = TestDataFactory.createUser('Joe Bob crmftest', 'Last Name crmftest', standardProfile.Id);

        //Map Member User
        Map_Member_User__c mmu = new Map_Member_User__c(Relationship_Map__c = rm.Id, User__c = usr.Id);
        insert mmu;

        //Lead for relationships
        Lead ld = md.mockLead.clone(false, true);
        ld.Id = null;
        insert ld;

        //Map Member Lead
        Map_Member_Lead__c mml = new Map_Member_Lead__c(Relationship_Map__c = rm.Id, Lead__c = ld.Id);
        insert mml;

        //User group association
        Relationship_Group_User_Association__c usrToLocalG = new Relationship_Group_User_Association__c(
            User__c = usr.Id,
            Relationship_Group__c = localGroup.Id
        );
        Relationship_Group_User_Association__c usrToGlobalG = new Relationship_Group_User_Association__c(
            User__c = usr.Id,
            Relationship_Group__c = globalGroup.Id
        );
        insert new List<SObject>{ usrToLocalG, usrToGlobalG };

        //contact group association
        Relationship_Group_Contact_Association__c conToLocalG = new Relationship_Group_Contact_Association__c(
            Contact__c = con.Id,
            Relationship_Group__c = localGroup.Id
        );
        Relationship_Group_Contact_Association__c conToGlobalG = new Relationship_Group_Contact_Association__c(
            Contact__c = con.Id,
            Relationship_Group__c = globalGroup.Id
        );
        insert new List<SObject>{ conToLocalG, conToGlobalG };

        //lead group association
        Relationship_Group_Lead_Association__c leadToLocalG = new Relationship_Group_Lead_Association__c(
            Lead__c = ld.Id,
            Relationship_Group__c = localGroup.Id
        );
        Relationship_Group_Lead_Association__c leadToGlobalG = new Relationship_Group_Lead_Association__c(
            Lead__c = ld.Id,
            Relationship_Group__c = globalGroup.Id
        );
        insert new List<SObject>{ leadToLocalG, leadToGlobalG };

        //Placeholder Relationship Lines
        Map_Member_Placeholder_Relationship__c placeRelateTo = md.mockPlaceholderRelationship.clone(false, true);
        placeRelateTo.Id = null;
        placeRelateTo.Relationship_Map__c = rm.Id;
        placeRelateTo.From__c = placeholder.Id;
        placeRelateTo.To__c = placeholder2.Id;
        placeRelateTo.Is_Hierarchy__c = true;

        Map_Member_Placeholder_Relationship__c placeholderToContact = md.mockPlaceholderRelationship.clone(false, true);
        placeholderToContact.Id = null;
        placeholderToContact.Relationship_Map__c = rm.Id;
        placeholderToContact.From__c = placeholder.Id;
        placeholderToContact.To__c = con.Id;
        placeholderToContact.Is_Hierarchy__c = false;

        Map_Member_Placeholder_Relationship__c contactToPlaceholder = md.mockPlaceholderRelationship.clone(false, true);
        contactToPlaceholder.Id = null;
        contactToPlaceholder.Relationship_Map__c = rm.Id;
        contactToPlaceholder.From__c = con.Id;
        contactToPlaceholder.To__c = placeholder.Id;
        contactToPlaceholder.Is_Hierarchy__c = false;
        insert new List<SObject>{ placeRelateTo, placeholderToContact, contactToPlaceholder };

        Application.bypassTrigger = false;

        RelationshipMapCloneWrapper wrapper = new RelationshipMapCloneWrapper(
            rm.Id,
            'Cloned Map',
            UserInfo.getUserId(),
            account1.Id
        );
        List<RelationshipMapCloneWrapper> wrapperList = new List<RelationshipMapCloneWrapper>{ wrapper };

        Datetime oneSecInFuture = Datetime.now().addSeconds(1);
        while (Datetime.now() < oneSecInFuture) {
            Integer temp = 1 + 1; //NOPMD - loop until time has passed to garauntee our new objects created dates are ordered correctly
        }
        Test.startTest();
        RelationshipMapCloneService.cloneRelationshipMaps(wrapperList);
        Test.stopTest();

        //Map Records
        Integer mapsCount = [SELECT COUNT() FROM Relationship_Map__c];
        Relationship_Map__c expectedNewMap = [
            SELECT OwnerId, Name, Id, CreatedDate
            FROM Relationship_Map__c
            WHERE Name = 'Cloned Map'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, mapsCount, 'Should be two maps, one original and one cloned');
        System.assertNotEquals(rm.Id, expectedNewMap.Id, 'Should be a new map');
        System.assertEquals(UserInfo.getUserId(), expectedNewMap.OwnerId, 'Clone user should own the new map');

        //Groups
        Integer groupCount = [SELECT COUNT() FROM Relationship_Group__c];
        Relationship_Group__c expectedNewGroup = [
            SELECT Relationship_Map__c, Label__c, Id, CreatedDate
            FROM Relationship_Group__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(
            3,
            groupCount,
            'Should be three groups after clone, original global and local + cloned local'
        );
        System.assert(expectedNewGroup != null, 'New group should exist');
        System.assert(expectedNewGroup.Id != localGroup.Id, 'New group should not be the original local group');
        System.assert(expectedNewGroup.Id != globalGroup.Id, 'New group should not be the original global group');
        System.assertEquals(
            expectedNewMap.Id,
            expectedNewGroup.Relationship_Map__c,
            'New group should be related to the new map'
        );

        //Map Member
        Integer memberCount = [SELECT COUNT() FROM Relationship_Map_Member__c];
        Relationship_Map_Member__c expectedNewMember = [
            SELECT Contact__c, Relationship_Map__c, Id, CreatedDate
            FROM Relationship_Map_Member__c
            WHERE Relationship_Map__c = :expectedNewMap.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, memberCount, 'Should be two members after clone');
        System.assert(expectedNewMember != null, 'New member should exist');
        System.assert(
            expectedNewMember.Id != mapMember.Id,
            'New member should not be the same member as the first original member'
        );
        System.assertEquals(expectedNewMember.Contact__c, con.Id, 'New member should be related  to the same contact');
        System.assertEquals(
            expectedNewMap.Id,
            expectedNewMember.Relationship_Map__c,
            'New member should be related to the new map'
        );

        //Map Member User
        Integer mmuCount = [SELECT COUNT() FROM Map_Member_User__c];
        Map_Member_User__c expectedNewMmu = [
            SELECT User__c, Relationship_Map__c, Id, CreatedDate
            FROM Map_Member_User__c
            WHERE Relationship_Map__c = :expectedNewMap.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, mmuCount, 'Should be two user members after clone');
        System.assert(expectedNewMmu != null, 'New user member should exist');
        System.assert(
            expectedNewMmu.Id != mmu.Id,
            'New user member should not be the same as the original user member'
        );
        System.assertEquals(expectedNewMmu.User__c, usr.Id, 'New user member should be related to the same user');
        System.assertEquals(
            expectedNewMap.Id,
            expectedNewMmu.Relationship_Map__c,
            'New user member should be related to the new map'
        );

        Integer mmlCount = [SELECT COUNT() FROM Map_Member_Lead__c];
        Map_Member_Lead__c expectedNewMML = [
            SELECT Lead__c, Relationship_Map__c, Id, CreatedDate
            FROM Map_Member_Lead__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(
            2,
            mmlCount,
            'Should be two Map Member Lead Records in the system after the clone (original and cloned)'
        );
        System.assert(expectedNewMML != null, 'New Map Member Lead should exist');
        System.assert(expectedNewMML.Id != mml.Id, 'New Map Member Lead should not be the original Map Member Lead');
        System.assertEquals(
            expectedNewMap.Id,
            expectedNewMML.Relationship_Map__c,
            'New Map Member Lead should be related to the new plan'
        );
        System.assertEquals(ld.Id, expectedNewMML.Lead__c, 'New Map Member Lead should be related to the same lead');

        //Placeholder
        Integer placeholderCount = [SELECT COUNT() FROM Map_Member_Placeholder__c];
        Map_Member_Placeholder__c expectedNewPlaceholder = [
            SELECT Description__c, Relationship_Map__c, Label__c, Id, CreatedDate
            FROM Map_Member_Placeholder__c
            WHERE Label__c = :placeholderLabel
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(4, placeholderCount, 'Should be four placeholders after clone');
        System.assert(expectedNewPlaceholder != null, 'New placeholder should exist');
        System.assert(
            expectedNewPlaceholder.Id != placeholder.Id,
            'New placeholder should not be the same placeholder as the first original placeholder'
        );
        System.assert(
            expectedNewPlaceholder.Id != placeholder2.Id,
            'New placeholder should not be the same placeholder as the second original placeholder'
        );
        System.assertEquals(
            expectedNewMap.Id,
            expectedNewPlaceholder.Relationship_Map__c,
            'New placeholder should be related to the new map'
        );

        //Placeholder Hierarchy Reports To
        Integer placeholderHierarchyCount = [
            SELECT COUNT()
            FROM Map_Member_Placeholder_Relationship__c
            WHERE Is_Hierarchy__c = TRUE
        ];
        Map_Member_Placeholder_Relationship__c expectedNewPlaceholderHierarchy = [
            SELECT Relationship_Map__c, Is_Hierarchy__c, From__c, To__c, Id, CreatedDate
            FROM Map_Member_Placeholder_Relationship__c
            WHERE Is_Hierarchy__c = TRUE
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, placeholderHierarchyCount, 'Should be two placeholder hierarchy lines after clone');
        System.assert(expectedNewPlaceholderHierarchy != null, 'New placeholder should exist');
        System.assert(
            expectedNewPlaceholderHierarchy.Id != placeholder.Id,
            'New placeholder Hierarchy Line should not be the same Hierarchy Line as the original Hierarchy Line'
        );
        System.assert(
            expectedNewPlaceholderHierarchy.Relationship_Map__c == expectedNewMap.Id,
            'New placeholder Hierarchy line should be to the cloned map'
        );
        System.assert(
            expectedNewPlaceholderHierarchy.From__c == expectedNewPlaceholder.Id ||
            expectedNewPlaceholderHierarchy.To__c == expectedNewPlaceholder.Id,
            'New placeholder Hierarchy Line should be related to the new Placeholder'
        );

        //Placeholder To Contact
        Integer toContactCount = [
            SELECT COUNT()
            FROM Map_Member_Placeholder_Relationship__c
            WHERE Is_Hierarchy__c = FALSE AND To__c = :con.Id
        ];
        Map_Member_Placeholder_Relationship__c expectedNewToContact = [
            SELECT Relationship_Map__c, Is_Hierarchy__c, From__c, To__c, Id, CreatedDate
            FROM Map_Member_Placeholder_Relationship__c
            WHERE Is_Hierarchy__c = FALSE AND To__c = :con.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, toContactCount, 'Should be two placeholder to contact rel lines after clone');
        System.assert(expectedNewToContact != null, 'New placeholder to contact rel line should exist');
        System.assert(
            expectedNewToContact.Id != placeholderToContact.Id,
            'New placeholder to contact rel line should not be the same Line as the original'
        );
        System.assert(
            expectedNewToContact.Relationship_Map__c == expectedNewMap.Id,
            'New placeholder to contact rel line should be to the cloned map'
        );
        System.assert(
            expectedNewToContact.To__c == con.Id,
            'New placeholder to contact rel line should be to the contact'
        );
        System.assert(
            expectedNewToContact.From__c == expectedNewPlaceholder.Id,
            'New placeholder to contact rel line should be from the new placeholder'
        );

        //Contact to Placeholder
        Integer fromContactCount = [
            SELECT COUNT()
            FROM Map_Member_Placeholder_Relationship__c
            WHERE Is_Hierarchy__c = FALSE AND FROM__c = :con.Id
        ];
        Map_Member_Placeholder_Relationship__c expectedNewFromContact = [
            SELECT Relationship_Map__c, Is_Hierarchy__c, From__c, To__c, Id, CreatedDate
            FROM Map_Member_Placeholder_Relationship__c
            WHERE Is_Hierarchy__c = FALSE AND From__c = :con.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, fromContactCount, 'Should be two placeholder from contact rel lines after clone');
        System.assert(expectedNewFromContact != null, 'New placeholder from contact rel line should exist');
        System.assert(
            expectedNewFromContact.Id != placeholderToContact.Id,
            'New placeholder from contact rel line should not be the same Line as the original'
        );
        System.assert(
            expectedNewFromContact.Relationship_Map__c == expectedNewMap.Id,
            'New placeholder from contact rel line should be to the cloned map'
        );
        System.assert(
            expectedNewFromContact.From__c == con.Id,
            'New placeholder from contact rel line should be from the contact'
        );
        System.assert(
            expectedNewFromContact.To__c == expectedNewPlaceholder.Id,
            'New placeholder from contact rel line should be To the new placeholder'
        );

        //Placeholder to Local Group
        Integer pToLGCount = [
            SELECT COUNT()
            FROM Relationship_Group_Placeholder_Assoc__c
            WHERE Relationship_Group__c != :globalGroup.Id
        ];
        Relationship_Group_Placeholder_Assoc__c expectedNewPlaceToLG = [
            SELECT Map_Member_Placeholder__c, Relationship_Group__c, Id, CreatedDate
            FROM Relationship_Group_Placeholder_Assoc__c
            WHERE Relationship_Group__c = :expectedNewGroup.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, pToLGCount, 'Should be two placeholder to local group associations after clone');
        System.assert(expectedNewPlaceToLG != null, 'New placeholder to local group association should exist');
        System.assert(
            expectedNewPlaceToLG.Id != plToLocalG.Id,
            'New placeholder to local group association should not be the same association as the original'
        );
        System.assert(
            expectedNewPlaceToLG.Relationship_Group__c == expectedNewGroup.Id,
            'New placeholder to local group association should relate to the cloned local group'
        );
        System.assert(
            expectedNewPlaceToLG.Map_Member_Placeholder__c == expectedNewPlaceholder.Id,
            'New placeholder to local group association should relate to the cloned placeholder'
        );

        //Placeholder to Global Group
        Integer pToGGCount = [
            SELECT COUNT()
            FROM Relationship_Group_Placeholder_Assoc__c
            WHERE Relationship_Group__c = :globalGroup.Id
        ];
        Relationship_Group_Placeholder_Assoc__c expectedNewPlaceToGG = [
            SELECT Map_Member_Placeholder__c, Relationship_Group__c, Id, CreatedDate
            FROM Relationship_Group_Placeholder_Assoc__c
            WHERE Relationship_Group__c = :globalGroup.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, pToGGCount, 'Should be two placeholder to global group associations after clone');
        System.assert(expectedNewPlaceToGG != null, 'New placeholder to global group association should exist');
        System.assert(
            expectedNewPlaceToGG.Id != plToGlobalG.Id,
            'New placeholder to global group association should not be the same association as the original'
        );
        System.assert(
            expectedNewPlaceToGG.Relationship_Group__c == globalGroup.Id,
            'New placeholder to global group association should relate to the global group'
        );
        System.assert(
            expectedNewPlaceToGG.Map_Member_Placeholder__c == expectedNewPlaceholder.Id,
            'New placeholder to global group association should relate to the cloned placeholder'
        );

        //Contact to Local Group
        Integer cToLGCount = [
            SELECT COUNT()
            FROM Relationship_Group_Contact_Association__c
            WHERE Relationship_Group__c != :globalGroup.Id
        ];
        Relationship_Group_Contact_Association__c expectedNewConToLG = [
            SELECT Contact__c, Relationship_Group__c, Id, CreatedDate
            FROM Relationship_Group_Contact_Association__c
            WHERE Relationship_Group__c = :expectedNewGroup.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, cToLGCount, 'Should be two contact to local group associations after clone');
        System.assert(expectedNewConToLG != null, 'New contact to local group association should exist');
        System.assert(
            expectedNewConToLG.Id != plToLocalG.Id,
            'New contact to local group association should not be the same association as the original'
        );
        System.assert(
            expectedNewConToLG.Relationship_Group__c == expectedNewGroup.Id,
            'New contact to local group association should relate to the cloned local group'
        );
        System.assert(
            expectedNewConToLG.Contact__c == con.Id,
            'New contact to local group association should relate to the contact'
        );

        //Contact to Global Group
        Integer cToGGCount = [
            SELECT COUNT()
            FROM Relationship_Group_Contact_Association__c
            WHERE Relationship_Group__c = :globalGroup.Id
        ];
        System.assertEquals(1, cToGGCount, 'Should not create new contact group association for global group');

        //User to Local Group
        Integer usrToLGCount = [
            SELECT COUNT()
            FROM Relationship_Group_User_Association__c
            WHERE Relationship_Group__c != :globalGroup.Id
        ];
        Relationship_Group_User_Association__c expectedNewUsrToLG = [
            SELECT User__c, Relationship_Group__c, Id, CreatedDate
            FROM Relationship_Group_User_Association__c
            WHERE Relationship_Group__c = :expectedNewGroup.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, usrToLGCount, 'Should be two user to local group associations after clone');
        System.assert(expectedNewUsrToLG != null, 'New user to local group association should exist');
        System.assert(
            expectedNewUsrToLG.Id != usrToLocalG.Id,
            'New user to local group association should not be the same association as the original'
        );
        System.assert(
            expectedNewUsrToLG.Relationship_Group__c == expectedNewGroup.Id,
            'New user to local group association should relate to the cloned local group'
        );
        System.assert(
            expectedNewUsrToLG.User__c == usr.Id,
            'New user to local group association should relate to the user'
        );

        //User to Global Group
        Integer usrToGGCount = [
            SELECT COUNT()
            FROM Relationship_Group_User_Association__c
            WHERE Relationship_Group__c = :globalGroup.Id
        ];
        System.assertEquals(1, usrToGGCount, 'Should not create new user group association for global group');

        //Lead to Local Group
        Integer rglaLocalCount = [
            SELECT COUNT()
            FROM Relationship_Group_Lead_Association__c
            WHERE Relationship_Group__c != :globalGroup.Id
        ];
        Relationship_Group_Lead_Association__c expectedNewLeadToLocalGroup = [
            SELECT Relationship_Group__c, Lead__c, Id, CreatedDate
            FROM Relationship_Group_Lead_Association__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(
            2,
            rglaLocalCount,
            'Should be two Group-Lead Association Records not related to the global group'
        );
        System.assert(expectedNewLeadToLocalGroup != null, 'New Group-Lead Association should exist');
        System.assert(
            expectedNewLeadToLocalGroup.Id != leadToLocalG.Id,
            'New Group-Lead Association should not be the original Local Group-Lead Association'
        );
        System.assert(
            expectedNewLeadToLocalGroup.Id != leadToGlobalG.Id,
            'New Group-Lead Association should not be the original Global Group-Lead Association'
        );
        System.assertEquals(
            expectedNewGroup.Id,
            expectedNewLeadToLocalGroup.Relationship_Group__c,
            'New Group-Lead Association should be related to the new local group'
        );
        System.assertEquals(
            ld.Id,
            expectedNewLeadToLocalGroup.Lead__c,
            'New Group-Lead Association should be related to existing lead'
        );

        //Lead to Global Group
        Integer leadToGlobalGroupCount = [
            SELECT COUNT()
            FROM Relationship_Group_Lead_Association__c
            WHERE Relationship_Group__c = :globalGroup.Id
        ];
        System.assertEquals(
            1,
            leadToGlobalGroupCount,
            'Should only be the one existing Lead to global group association (none cloned)'
        );
    }

    @isTest
    private static void cloneRelationshipMapsMatrixTest() {
        TestMockData md = new TestMockData();

        //Inserts do not need the trigger to run
        Application.bypassTrigger = true;

        Relationship_Map__c rm = md.mockRelationshipMap.clone(false, true);
        rm.Id = null;
        rm.OwnerId = UserInfo.getUserId();
        insert rm;

        pq_Influence_And_Support_Matrix__c ism = new pq_Influence_And_Support_Matrix__c();
        ism.Name = 'Test Matrix For crmmt';
        ism.Is_Default__c = false;
        insert ism;

        pq_Relationship_Map_Matrix_Association__c assoc = new pq_Relationship_Map_Matrix_Association__c();
        assoc.Relationship_Map__c = rm.Id;
        assoc.Influence_And_Support_Matrix__c = ism.Id;
        insert assoc;

        Application.bypassTrigger = false;

        RelationshipMapCloneWrapper wrapper = new RelationshipMapCloneWrapper(
            rm.Id,
            'Cloned Map',
            UserInfo.getUserId(),
            null
        );
        List<RelationshipMapCloneWrapper> wrapperList = new List<RelationshipMapCloneWrapper>{ wrapper };

        Datetime oneSecInFuture = Datetime.now().addSeconds(1);
        while (Datetime.now() < oneSecInFuture) {
            Integer temp = 1 + 1; //NOPMD - loop until time has passed to garauntee our new objects created dates are ordered correctly
        }
        Test.startTest();
        RelationshipMapCloneService.cloneRelationshipMaps(wrapperList);
        Test.stopTest();

        //Map
        Integer mapsCount = [SELECT COUNT() FROM Relationship_Map__c];
        /*Relationship_Map__c expectedNewMap = [
            SELECT OwnerId, Name, Id, CreatedDate
            FROM Relationship_Map__c
            WHERE Name = 'Cloned Map'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];*/
        System.assertEquals(2, mapsCount, 'Should be two maps, one original and one cloned');
        //System.assertNotEquals(rm.Id, expectedNewMap.Id, 'Should be a new map');
        //System.assertEquals(UserInfo.getUserId(), expectedNewMap.OwnerId, 'Clone user should own the new map');

        //Matrix
        Integer matrixCount = [SELECT COUNT() FROM pq_Influence_And_Support_Matrix__c];
        System.assertEquals(1, matrixCount, 'Should not clone the matrix itself');

        //Association
        Integer assocCount = [SELECT COUNT() FROM pq_Relationship_Map_Matrix_Association__c];
        pq_Relationship_Map_Matrix_Association__c expectedNewAssoc = [
            SELECT Relationship_Map__c, Influence_And_Support_Matrix__c, Id, CreatedDate
            FROM pq_Relationship_Map_Matrix_Association__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, assocCount, 'Should be two associations after clone, original and cloned');
        System.assert(expectedNewAssoc != null, 'New association should exist');
        System.assert(expectedNewAssoc.Id != assoc.Id, 'New association should not be the original association');
        /*System.assertEquals(
            expectedNewMap.Id,
            expectedNewAssoc.Relationship_Map__c,
            'New association should be related to the new map'
        );*/
        System.assertEquals(
            ism.Id,
            expectedNewAssoc.Influence_And_Support_Matrix__c,
            'New association should be related to the original matrix'
        );
    }

    @isTest
    private static void cloneRelationshipMapsWithParamsTest() {
        TestMockData md = new TestMockData();

        //Inserts do not need the trigger to run
        Application.bypassTrigger = true;

        Relationship_Map__c rm = md.mockRelationshipMap.clone(false, true);
        rm.Id = null;
        rm.OwnerId = UserInfo.getUserId();
        insert rm;

        pq_Influence_And_Support_Matrix__c ism = new pq_Influence_And_Support_Matrix__c();
        ism.Name = 'Test Matrix For crmmt';
        ism.Is_Default__c = false;
        insert ism;

        pq_Relationship_Map_Matrix_Association__c assoc = new pq_Relationship_Map_Matrix_Association__c();
        assoc.Relationship_Map__c = rm.Id;
        assoc.Influence_And_Support_Matrix__c = ism.Id;
        insert assoc;

        Application.bypassTrigger = false;

        RelationshipMapCloneWrapper wrapper = new RelationshipMapCloneWrapper(
            rm.Id,
            'Cloned Map',
            UserInfo.getUserId(),
            null
        );
        List<RelationshipMapCloneWrapper> wrapperList = new List<RelationshipMapCloneWrapper>{ wrapper };

        Datetime oneSecInFuture = Datetime.now().addSeconds(1);
        while (Datetime.now() < oneSecInFuture) {
            Integer temp = 1 + 1; //NOPMD - loop until time has passed to garauntee our new objects created dates are ordered correctly
        }
        List<SObject> relatedObjsToClone = new List<SObject>();
        Set<Schema.SObjectType> relatedObjectTypes = new Set<Schema.SObjectType>();
        Test.startTest();
        RelationshipMapCloneService.cloneRelationshipMaps(wrapperList, relatedObjsToClone, relatedObjectTypes, false);
        Test.stopTest();

        //Passed list and set should not be empty
        System.assert(relatedObjsToClone.size() > 0, 'Should have populated the related objects to clone list');
        System.assert(relatedObjectTypes.size() > 0, 'Should have populated the related object types set');

        //Map
        Integer mapsCount = [SELECT COUNT() FROM Relationship_Map__c];
        /*Relationship_Map__c expectedNewMap = [
            SELECT OwnerId, Name, Id, CreatedDate
            FROM Relationship_Map__c
            WHERE Name = 'Cloned Map'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, mapsCount, 'Should be two maps, one original and one cloned');
        System.assertNotEquals(rm.Id, expectedNewMap.Id, 'Should be a new map');
        System.assertEquals(UserInfo.getUserId(), expectedNewMap.OwnerId, 'Clone user should own the new map');*/

        //Association
        Integer assocCount = [SELECT COUNT() FROM pq_Relationship_Map_Matrix_Association__c];
        System.assertEquals(1, assocCount, 'Should only be one association since we did not run the batch service');
    }
}