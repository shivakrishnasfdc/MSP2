@SuppressWarnings('PMD.NcssMethodCount')
@isTest
private class ContactRelationshipServiceTest {
    /*----------------------------------------------------------------------------------------------
    getRelationshipsTest
    -----------------------------------------------------------------------------------------------*/
    @isTest
    static void getRelationshipsLocalTest() {
        // Mocks
        TestMockData md = new TestMockData();
        ContactRelationshipSelector mockSelector = md.mockContactRelationshipSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;

        // Given
        Contact jody = new Contact(LastName = 'jody');
        insert jody;
        Contact neil = new Contact(ReportsToId = jody.Id, LastName = 'neil');
        insert neil;
        Contact terry = new Contact(ReportsToId = neil.Id, LastName = 'terry');
        insert terry;
        Contact ant = new Contact(ReportsToId = terry.Id, LastName = 'ant');
        Contact cj = new Contact(ReportsToId = terry.Id, LastName = 'cj');
        Contact dame = new Contact(ReportsToId = terry.Id, LastName = 'dame');
        Contact nas = new Contact(ReportsToId = terry.Id, LastName = 'nas');
        insert ant;
        insert cj;
        insert dame;
        insert nas;

        Contact_Relationship__c c1 = new Contact_Relationship__c(From_Contact__c = jody.Id, To_Contact__c = neil.Id);
        Contact_Relationship__c c2 = new Contact_Relationship__c(From_Contact__c = neil.Id, To_Contact__c = terry.Id);
        Contact_Relationship__c c3 = new Contact_Relationship__c(From_Contact__c = terry.Id, To_Contact__c = dame.Id);
        Contact_Relationship__c c4 = new Contact_Relationship__c(From_Contact__c = terry.Id, To_Contact__c = cj.Id);
        Contact_Relationship__c c5 = new Contact_Relationship__c(From_Contact__c = terry.Id, To_Contact__c = ant.Id);
        Contact_Relationship__c c6 = new Contact_Relationship__c(From_Contact__c = terry.Id, To_Contact__c = nas.Id);

        List<Contact_Relationship__c> contactRelationships = new List<Contact_Relationship__c>{
            c1,
            c2,
            c3,
            c4,
            c5,
            c6
        };
        Set<Id> contactIds = new Set<Id>{ jody.Id, neil.Id, terry.Id, ant.Id, dame.Id, cj.Id, nas.Id };

        RM_Chart_Setting__c setting = new RM_Chart_Setting__c(
            Id = fflib_IDGenerator.generate(RM_Chart_Setting__c.SObjectType),
            Is_Relationship_Line_Global_Scope__c = false
        );

        md.mocks.startStubbing();
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(setting);
        md.mocks.when(mockSelector.selectLocalRelationshipsById(contactIds, md.mockRelationshipMapId, false))
            .thenReturn(contactRelationships);
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        List<GraphLinkData> linkData = ContactRelationshipService.getRelationships(
            contactIds,
            md.mockRelationshipMapId,
            false
        );
        Test.stopTest();

        // Then
        System.assertEquals(6, linkData.size());
    }

    @isTest
    static void getRelationshipsGlobalTest() {
        // Mocks
        TestMockData md = new TestMockData();
        ContactRelationshipSelector mockSelector = md.mockContactRelationshipSelector;
        RMChartSettingServiceImpl mockRMChartSettingService = md.mockRMChartSettingService;

        // Given
        Contact jody = new Contact(LastName = 'jody');
        insert jody;
        Contact neil = new Contact(ReportsToId = jody.Id, LastName = 'neil');
        insert neil;
        Contact terry = new Contact(ReportsToId = neil.Id, LastName = 'terry');
        insert terry;
        Contact ant = new Contact(ReportsToId = terry.Id, LastName = 'ant');
        Contact cj = new Contact(ReportsToId = terry.Id, LastName = 'cj');
        Contact dame = new Contact(ReportsToId = terry.Id, LastName = 'dame');
        Contact nas = new Contact(ReportsToId = terry.Id, LastName = 'nas');
        insert ant;
        insert cj;
        insert dame;
        insert nas;

        Contact_Relationship__c c1 = new Contact_Relationship__c(From_Contact__c = jody.Id, To_Contact__c = neil.Id);
        Contact_Relationship__c c2 = new Contact_Relationship__c(From_Contact__c = neil.Id, To_Contact__c = terry.Id);
        Contact_Relationship__c c3 = new Contact_Relationship__c(From_Contact__c = terry.Id, To_Contact__c = dame.Id);
        Contact_Relationship__c c4 = new Contact_Relationship__c(From_Contact__c = terry.Id, To_Contact__c = cj.Id);
        Contact_Relationship__c c5 = new Contact_Relationship__c(From_Contact__c = terry.Id, To_Contact__c = ant.Id);
        Contact_Relationship__c c6 = new Contact_Relationship__c(From_Contact__c = terry.Id, To_Contact__c = nas.Id);

        List<Contact_Relationship__c> contactRelationships = new List<Contact_Relationship__c>{
            c1,
            c2,
            c3,
            c4,
            c5,
            c6
        };
        Set<Id> contactIds = new Set<Id>{ jody.Id, neil.Id, terry.Id, ant.Id, dame.Id, cj.Id, nas.Id };

        RM_Chart_Setting__c setting = new RM_Chart_Setting__c(
            Id = fflib_IDGenerator.generate(RM_Chart_Setting__c.SObjectType),
            Is_Relationship_Line_Global_Scope__c = true
        );

        md.mocks.startStubbing();
        md.mocks.when(mockRMChartSettingService.getRelationshipMapSettingForObject(md.mockRelationshipMapId))
            .thenReturn(setting);
        md.mocks.when(mockSelector.selectGlobalRelationshipsById(contactIds, md.mockRelationshipMapId, false))
            .thenReturn(contactRelationships);
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        List<GraphLinkData> linkData = ContactRelationshipService.getRelationships(
            contactIds,
            md.mockRelationshipMapId,
            false
        );
        Test.stopTest();

        // Then
        System.assertEquals(6, linkData.size());
    }

    /*----------------------------------------------------------------------------------------------
    deleteCustomLinks
    -----------------------------------------------------------------------------------------------*/
    @isTest
    static void deleteCustomLinksTest() {
        // Mocks
        TestMockData md = new TestMockData();
        ContactRelationshipSelector mockSelector = md.mockContactRelationshipSelector;
        MapMemberPlaceholderRelationshipSelector mockMapMemberPlaceholderRelationshipSelector = md.mockMapMemberPlaceholderRelationshipSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        // Given
        List<GraphLinkData> linkDataArray = new List<GraphLinkData>();
        linkDataArray.add(
            new GraphLinkData(
                fflib_IDGenerator.generate(Contact_Relationship__c.SObjectType),
                '',
                '',
                false,
                '',
                '',
                ''
            )
        );
        linkDataArray.add(new GraphLinkData('', 'abc', '', false, '', '', ''));

        Contact_Relationship__c c1 = new Contact_Relationship__c(
            Id = fflib_IDGenerator.generate(Contact_Relationship__c.SObjectType),
            TempId__c = 'a'
        );
        Map_Member_Placeholder_Relationship__c c2 = new Map_Member_Placeholder_Relationship__c(
            Id = fflib_IDGenerator.generate(Map_Member_Placeholder_Relationship__c.SObjectType),
            TempId__c = 'b'
        );

        Set<String> ids = new Set<String>{ linkDataArray[0].id, linkDataArray[1].tempId };

        md.mocks.startStubbing();
        md.mocks.when(mockSelector.selectByIdOrTempKey(ids)).thenReturn(new List<Contact_Relationship__c>{ c1 });
        md.mocks.when(mockMapMemberPlaceholderRelationshipSelector.selectByIdOrTempKey(ids))
            .thenReturn(new List<Map_Member_Placeholder_Relationship__c>{ c2 });
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        ContactRelationshipService.deleteCustomLinks(linkDataArray);
        Test.stopTest();

        //Then
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 2))
            .registerDeleted((List<Contact_Relationship__c>) fflib_Match.anyList());
        System.assert(true, 'Assert verified by mocks');
    }

    /*----------------------------------------------------------------------------------------------
    newCustomLinks
    -----------------------------------------------------------------------------------------------*/
    @isTest
    static void newCustomLinksTest() {
        // Mocks
        TestMockData md = new TestMockData();
        ContactRelationshipSelector mockSelector = md.mockContactRelationshipSelector; //NOPMD - Needs to be called in order for it to be mocked in the test
        MapMemberPlaceholderRelationshipSelector mockMapMemberPlaceholderRelationshipSelector = md.mockMapMemberPlaceholderRelationshipSelector; //NOPMD - Needs to be called in order for it to be mocked in the test
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        // Given
        List<GraphLinkData> linkDataArray = new List<GraphLinkData>();
        String fromKey = fflib_IDGenerator.generate(Contact.SObjectType);
        String toKey = fflib_IDGenerator.generate(Contact.SObjectType);

        String fromKey2 = fflib_IDGenerator.generate(Map_Member_Placeholder__c.SObjectType);
        String toKey2 = fflib_IDGenerator.generate(Map_Member_Placeholder__c.SObjectType);

        Contact_Relationship_Type__c relType = TestDataFactory.createContactRelationshipType(
            '#ff0022',
            'label',
            true,
            true
        );

        linkDataArray.add(new GraphLinkData('', 'tempIdabc', fromKey, false, toKey, relType.Id, 'label'));

        linkDataArray.add(new GraphLinkData('', 'tempIdabc', fromKey2, false, toKey2, relType.Id, 'label'));

        // When
        Test.startTest();
        ContactRelationshipService.newCustomLinks(linkDataArray, md.mockRelationshipMapId);
        Test.stopTest();

        //Then
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew(
                new Contact_Relationship__c(
                    From_Contact__c = fromKey,
                    To_Contact__c = toKey,
                    TempId__c = 'tempIdabc',
                    Contact_Relationship_Type__c = relType.Id,
                    Label__c = 'label',
                    Relationship_Map__c = md.mockRelationshipMapId
                )
            );
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 1))
            .registerNew(
                new Map_Member_Placeholder_Relationship__c(
                    From__c = fromKey2,
                    To__c = toKey2,
                    TempId__c = 'tempIdabc',
                    Type__c = relType.Id,
                    Label__c = 'label',
                    Contact_Relationship_Type__c = relType.Id,
                    Relationship_Map__c = md.mockRelationshipMapId,
                    Is_Hierarchy__c = false
                )
            );
        System.assert(true, 'Assert by mock verify');
    }

    /*----------------------------------------------------------------------------------------------
    updateCustomLinks
    -----------------------------------------------------------------------------------------------*/
    @isTest
    static void updateCustomLinksTest() {
        // Mocks
        TestMockData md = new TestMockData();
        ContactRelationshipSelector mockSelector = md.mockContactRelationshipSelector;
        MapMemberPlaceholderRelationshipSelector mockMapMemberPlaceholderRelationshipSelector = md.mockMapMemberPlaceholderRelationshipSelector;
        fflib_ISObjectUnitOfWork mockUow = md.mockUow;

        // Given
        List<GraphLinkData> linkDataArray = new List<GraphLinkData>();
        Id from1 = fflib_IDGenerator.generate(Contact.SObjectType);
        Id to1 = fflib_IDGenerator.generate(Contact.SObjectType);
        Id from2 = fflib_IDGenerator.generate(Map_Member_Placeholder__c.SObjectType);
        Id to2 = fflib_IDGenerator.generate(Map_Member_Placeholder__c.SObjectType);
        linkDataArray.add(
            new GraphLinkData(
                fflib_IDGenerator.generate(Contact_Relationship__c.SObjectType),
                'tempId',
                from1,
                false,
                to1,
                'Custom',
                'Label'
            )
        );
        linkDataArray.add(new GraphLinkData('', 'tempId2', from2, false, to2, 'Custom', 'Label'));

        Contact_Relationship__c c1 = new Contact_Relationship__c(
            Id = fflib_IDGenerator.generate(Contact_Relationship__c.SObjectType),
            TempId__c = 'a'
        );
        Map_Member_Placeholder_Relationship__c c2 = new Map_Member_Placeholder_Relationship__c(
            Id = fflib_IDGenerator.generate(Map_Member_Placeholder_Relationship__c.SObjectType),
            TempId__c = 'b'
        );

        Set<String> ids = new Set<String>{ linkDataArray[0].id, linkDataArray[1].tempId };

        md.mocks.startStubbing();
        md.mocks.when(mockSelector.selectByIdOrTempKey(ids)).thenReturn(new List<Contact_Relationship__c>{ c1 });
        md.mocks.when(mockMapMemberPlaceholderRelationshipSelector.selectByIdOrTempKey(ids))
            .thenReturn(new List<Map_Member_Placeholder_Relationship__c>{ c2 });
        md.mocks.stopStubbing();

        // When
        Test.startTest();
        ContactRelationshipService.updateCustomLinks(linkDataArray);
        Test.stopTest();

        //Then
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 2))
            .registerDirty((List<Contact_Relationship__c>) fflib_Match.anyList());
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 2))
            .registerNew((List<Contact_Relationship__c>) fflib_Match.anyList());
        ((fflib_ISObjectUnitOfWork) md.mocks.verify(mockUow, 2))
            .registerDeleted((List<Contact_Relationship__c>) fflib_Match.anyList());
        System.assert(true, 'Assert by mock verify');
    }
}