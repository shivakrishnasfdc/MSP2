public with sharing class CampaignController {
    @AuraEnabled
    public static List<CampaignMemberWrapper> getCampaignMembersForContactId(Id contactId) {
        List<CampaignMember> cmList = CampaignMemberSelector.newInstance().selectByContactId(new Set<Id>{ contactId });
        return CampaignMemberWrapper.convert(cmList);
    }
}