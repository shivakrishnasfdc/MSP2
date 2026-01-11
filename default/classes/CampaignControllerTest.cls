@isTest
private class CampaignControllerTest {
    @isTest
    static void getCampaignMembersForContactIdTest() {
        TestMockData md = new TestMockData();
        CampaignMemberSelector selector = md.mockCampaignMemberSelector;

        CampaignController.getCampaignMembersForContactId(md.mockContactId);

        ((CampaignMemberSelector) md.mocks.verify(selector, 1)).selectByContactId(new Set<Id>{ md.mockContactId });
        System.assert(true, 'Assert by mock verify');
    }
}