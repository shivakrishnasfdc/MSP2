@isTest
private class CampaignMemberSelectorTest {
    @isTest
    static void newInstanceTest() {
        CampaignMemberSelector selector = CampaignMemberSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByContactIdTest() {
        String campName = 'campaignA';
        Campaign c = new Campaign(Name = campName, IsActive = true);
        insert c;
        Contact con = TestDataFactory.createContact('john', 'smith');
        CampaignMember cm = new CampaignMember(CampaignId = c.Id, ContactId = con.Id, Status = 'Sent');
        insert cm;

        List<CampaignMember> result = CampaignMemberSelector.newInstance().selectByContactId(new Set<Id>{ con.Id });
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(campName, result[0].Campaign.Name);
        System.assertEquals('Sent', result[0].Status);
        System.assertEquals(con.FirstName, result[0].Contact.FirstName);
    }
}