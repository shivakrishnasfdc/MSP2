public with sharing class CampaignMemberWrapper {
    @AuraEnabled
    public Id id { get; set; }
    @AuraEnabled
    public Id campaignId { get; set; }
    @AuraEnabled
    public String campaignName { get; set; }
    @AuraEnabled
    public Boolean campaignIsActive { get; set; }
    @AuraEnabled
    public String status { get; set; }

    public CampaignMemberWrapper(Id id, Id campaignId, String campaignName, Boolean campaignIsActive, String status) {
        this.id = id;
        this.campaignId = campaignId;
        this.campaignName = campaignName;
        this.campaignIsActive = campaignIsActive;
        this.status = status;
    }

    public static List<CampaignMemberWrapper> convert(List<CampaignMember> campaignMemberList) {
        if (campaignMemberList == null || campaignMemberList.size() == 0) {
            return new List<CampaignMemberWrapper>();
        }

        // Get Picklist values for Status
        Schema.DescribeFieldResult statusFieldResult = SObjectType.CampaignMember.fields.Status;

        Map<String, String> pickListMap = new Map<String, String>();

        for (Schema.PicklistEntry entry : statusFieldResult.getPicklistValues()) {
            pickListMap.put(entry.getValue(), entry.getLabel());
        }

        List<CampaignMemberWrapper> result = new List<CampaignMemberWrapper>();
        for (CampaignMember cm : campaignMemberList) {
            result.add(
                new CampaignMemberWrapper(
                    cm.Id,
                    cm.Campaign.Id,
                    cm.Campaign.Name,
                    cm.Campaign.IsActive,
                    (pickListMap != null && pickListMap.get(cm.Status) != null) ? pickListMap.get(cm.Status) : ''
                )
            );
        }

        return result;
    }
}