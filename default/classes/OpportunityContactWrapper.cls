public with sharing class OpportunityContactWrapper {
    @AuraEnabled
    public Id id { get; set; }
    @AuraEnabled
    public Id opportunityId { get; set; }
    @AuraEnabled
    public String opportunityName { get; set; }
    @AuraEnabled
    public Decimal opportunityAmount { get; set; }
    @AuraEnabled
    public String contactRole { get; set; }
    @AuraEnabled
    public Boolean isClosed { get; set; }

    public OpportunityContactWrapper(
        Id id,
        Id opportunityId,
        String opportunityName,
        Decimal opportunityAmount,
        String contactRole,
        Boolean isClosed
    ) {
        this.id = id;
        this.opportunityId = opportunityId;
        this.opportunityName = opportunityName;
        this.opportunityAmount = opportunityAmount;
        this.contactRole = contactRole;
        this.isClosed = isClosed;
    }

    public static List<OpportunityContactWrapper> convert(List<OpportunityContactRole> opContactList) {
        if (opContactList == null || opContactList.size() == 0) {
            return new List<OpportunityContactWrapper>();
        }

        // Get Picklist values for Status
        Schema.DescribeFieldResult roleFieldResult = SObjectType.OpportunityContactRole.fields.Role;

        Map<String, String> pickListMap = new Map<String, String>();

        for (Schema.PicklistEntry entry : roleFieldResult.getPicklistValues()) {
            pickListMap.put(entry.getValue(), entry.getLabel());
        }

        List<OpportunityContactWrapper> result = new List<OpportunityContactWrapper>();
        for (OpportunityContactRole ocr : opContactList) {
            result.add(
                new OpportunityContactWrapper(
                    ocr.Id,
                    ocr.Opportunity.Id,
                    ocr.Opportunity.Name,
                    ocr.Opportunity.Amount,
                    (pickListMap != null && pickListMap.get(ocr.Role) != null) ? pickListMap.get(ocr.Role) : '',
                    ocr.Opportunity.isClosed
                )
            );
        }

        return result;
    }
}