@IsTest
private class DataCleanupControllerTest {
    @IsTest
    static void getCountOfMembersNeedingInfluenceSupportCleanupTest() {
        TestMockData md = new TestMockData();
        PostInstallHelperServiceImpl pih = md.mockPostInstallHelperService;

        List<pqcrush__Key_Stakeholder__c> stakeholders = new List<pqcrush__Key_Stakeholder__c>{ md.mockKeyStakeholder };
        List<Relationship_Map_Member__c> members = new List<Relationship_Map_Member__c>{ md.mockRelationshipMapMember };

        md.mocks.startStubbing();
        md.mocks.when(pih.getMapMembersToUpdate()).thenReturn(members);
        md.mocks.when(pih.getStakeholdersToUpdate()).thenReturn(stakeholders);
        md.mocks.stopStubbing();

        Integer result = DataCleanupController.getCountOfMembersNeedingInfluenceSupportCleanup();
        System.assertEquals(
            stakeholders.size() + members.size(),
            result,
            'Should return sum of members and stakeholders (2)'
        );
    }

    @IsTest
    static void getCountOfMembersNeedingInfluenceSupportCleanupEmptyTest() {
        TestMockData md = new TestMockData();
        PostInstallHelperServiceImpl pih = md.mockPostInstallHelperService;

        List<pqcrush__Key_Stakeholder__c> stakeholders = new List<pqcrush__Key_Stakeholder__c>();
        List<Relationship_Map_Member__c> members = new List<Relationship_Map_Member__c>();

        md.mocks.startStubbing();
        md.mocks.when(pih.getMapMembersToUpdate()).thenReturn(members);
        md.mocks.when(pih.getStakeholdersToUpdate()).thenReturn(stakeholders);
        md.mocks.stopStubbing();

        Integer result = DataCleanupController.getCountOfMembersNeedingInfluenceSupportCleanup();
        System.assertEquals(
            stakeholders.size() + members.size(),
            result,
            'Should return sum of members and stakeholders (0)'
        );
    }

    @IsTest
    static void cleanupMembersNeedingInfluenceSupportNoRecordsTest() {
        TestMockData md = new TestMockData();
        PostInstallHelperServiceImpl pih = md.mockPostInstallHelperService;

        List<pqcrush__Key_Stakeholder__c> stakeholders = new List<pqcrush__Key_Stakeholder__c>();
        List<Relationship_Map_Member__c> members = new List<Relationship_Map_Member__c>();

        md.mocks.startStubbing();
        md.mocks.when(pih.getMapMembersToUpdate()).thenReturn(members);
        md.mocks.when(pih.getStakeholdersToUpdate()).thenReturn(stakeholders);
        md.mocks.stopStubbing();

        DataCleanupController.cleanupMembersNeedingInfluenceSupport();

        ((PostInstallHelperServiceImpl) md.mocks.verify(pih, 0))
            .updateMapMembersInfleunceSupport(
                (List<SObject>) fflib_Match.anyList(),
                (List<pq_Influence__c>) fflib_Match.anyList(),
                (List<pq_Support__c>) fflib_Match.anyList()
            );
        ((PostInstallHelperServiceImpl) md.mocks.verify(pih, 0))
            .executeBatchUpdateForRecords(
                (List<SObject>) fflib_Match.anyObject(),
                (List<Schema.SObjectType>) fflib_Match.anyList()
            );
        System.assert(true, 'Assert verified by mocks');
    }

    @IsTest
    static void cleanupMembersNeedingInfluenceSupportHappyPathTest() {
        TestMockData md = new TestMockData();
        PostInstallHelperServiceImpl pih = md.mockPostInstallHelperService;
        InfluenceSelector infSel = md.mockInfluenceSelector;
        SupportSelector supSel = md.mockSupportSelector;

        List<pqcrush__Key_Stakeholder__c> stakeholders = new List<pqcrush__Key_Stakeholder__c>{ md.mockKeyStakeholder };
        List<Relationship_Map_Member__c> members = new List<Relationship_Map_Member__c>();
        List<pq_Influence__c> influences = new List<pq_Influence__c>{ md.mockInfluence };
        List<pq_Support__c> supports = new List<pq_Support__c>{ md.mockSupport };
        Set<SObject> updatedRecords = new Set<SObject>{ md.mockKeyStakeholder };

        md.mocks.startStubbing();
        md.mocks.when(pih.getMapMembersToUpdate()).thenReturn(members);
        md.mocks.when(pih.getStakeholdersToUpdate()).thenReturn(stakeholders);
        md.mocks.when(infSel.selectAll()).thenReturn(influences);
        md.mocks.when(supSel.selectAll()).thenReturn(supports);
        md.mocks.when(pih.updateMapMembersInfleunceSupport(stakeholders, influences, supports))
            .thenReturn(updatedRecords);
        md.mocks.stopStubbing();

        DataCleanupController.cleanupMembersNeedingInfluenceSupport();

        ((PostInstallHelperServiceImpl) md.mocks.verify(pih, 1))
            .updateMapMembersInfleunceSupport(stakeholders, influences, supports);
        ((PostInstallHelperServiceImpl) md.mocks.verify(pih, 1))
            .executeBatchUpdateForRecords(
                new List<SObject>(updatedRecords),
                new List<Schema.SObjectType>{
                    Key_Stakeholder__c.getSObjectType(),
                    Relationship_Map_Member__c.getSObjectType()
                }
            );
        System.assert(true, 'Assert verified by mocks');
    }

    @IsTest
    static void getRecordCountForKSMapConversionTest() {
        TestDataFactory.createAccountPlan('grcfksct_Test_Plan');
        Integer result = DataCleanupController.getRecordCountForKSMapConversion();
        System.assertEquals(1, result, 'Should return 1');
    }
}