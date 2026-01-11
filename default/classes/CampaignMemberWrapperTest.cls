@isTest
private class CampaignMemberWrapperTest {
    @isTest
    static void instanceTest() {
        Id cmId = fflib_IDGenerator.generate(CampaignMember.SObjectType);
        Id cId = fflib_IDGenerator.generate(Campaign.SObjectType);
        String name = 'c name';
        String status = 'Send';
        Boolean isActive = true;

        CampaignMemberWrapper wrapper = new CampaignMemberWrapper(cmId, cId, name, isActive, status);

        System.assertEquals(cmId, wrapper.id);
        System.assertEquals(cId, wrapper.campaignId);
        System.assertEquals(name, wrapper.campaignName);
        System.assertEquals(status, wrapper.status);
        System.assertEquals(isActive, wrapper.campaignIsActive);
    }

    @isTest
    static void convertTest() {
        String campaignName = 'campaign Name';
        Contact c = TestDataFactory.createContact('john', 'smith');
        Campaign cam = new Campaign(Name = campaignName, IsActive = true);
        insert cam;
        CampaignMember cm = new CampaignMember(CampaignId = cam.Id, ContactId = c.Id, Status = 'Sent');
        insert cm;

        CampaignMember queryCm = [
            SELECT Id, Campaign.Id, Campaign.Name, Campaign.IsActive, Status
            FROM CampaignMember
            WHERE Id = :cm.Id
        ];

        List<CampaignMemberWrapper> result = CampaignMemberWrapper.convert(new List<CampaignMember>{ queryCm });
        System.assertEquals(1, result.size());
        System.assertEquals(queryCm.Id, result[0].id);
        System.assertEquals(cam.Id, result[0].campaignId);
        System.assertEquals(campaignName, result[0].campaignName);
        System.assertEquals('Sent', result[0].status);
        System.assertEquals(true, result[0].campaignIsActive);
    }

    @isTest
    static void convertNullTest() {
        List<CampaignMemberWrapper> result = CampaignMemberWrapper.convert(null);
        System.assertEquals(0, result.size());
    }
}