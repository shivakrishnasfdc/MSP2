public with sharing class OpportunityEffectivenessData {

    public Date dateOfData { get; set; }
    public Map<String, Decimal> lostMap { get; set; }
    public Map<String, Decimal> wonMap { get; set; }
    public Decimal totalWon { get ; set; }
    public Decimal totalLost { get; set; }
    public Decimal wonWithContact { get; set; }
    public Decimal lostWithContact { get; set; }


    public OpportunityEffectivenessData(
    ) {
        this.dateOfData = Date.today();
        this.lostMap = new Map<String, Decimal>();
        this.wonMap =  new Map<String, Decimal>();
        this.totalLost = 0;
        this.totalWon = 0;
        this.wonWithContact = 0;
        this.lostWithContact = 0;
    }

    public static OpportunityEffectivenessData convert(pq_Opportunity_Effectiveness_Index__c input) {
        OpportunityEffectivenessData result = new OpportunityEffectivenessData();

        if (input == null) {
            return result;
        }

        if (!String.isBlank(input.Serialized_Lost_Data__c)) {
            Map<String, Object> mLost = (Map<String, Object>) JSON.deserializeUntyped(
                input.Serialized_Lost_Data__c
            );
            Map<String, Decimal> lostData = UtilityForMap.convertMap(mLost);
            result.lostMap = lostData;
        }

        if (!String.isBlank(input.Serialized_Won_Data__c)) {
            Map<String, Object> mWon = (Map<String, Object>) JSON.deserializeUntyped(
                input.Serialized_Won_Data__c
            );
            Map<String, Decimal> wonData = UtilityForMap.convertMap(mWon);
            result.wonMap = wonData;
        }

        if (input.Total_Lost__c != null) {
            result.totalLost = input.Total_Lost__c;
        }
        if (input.Total_Lost__c != null) {
            result.totalWon = input.Total_Won__c;
        }
        if (input.Total_Lost__c != null) {
            result.wonWithContact = input.Total_Won_With_Contact__c;
        }
        if (input.Total_Lost__c != null) {
            result.lostWithContact = input.Total_Lost_With_Contact__c;
        }

        return result;
    }

    public static OpportunityEffectivenessData convertForRollingData(pq_Opportunity_Effectiveness_Index__c input) {
        OpportunityEffectivenessData result = new OpportunityEffectivenessData();

        if (input == null) {
            return result;
        }

        if (!String.isBlank(input.Rolling_Serialized_Lost_Data__c)) {
            Map<String, Object> mLost = (Map<String, Object>) JSON.deserializeUntyped(
                input.Rolling_Serialized_Lost_Data__c
            );
            Map<String, Decimal> lostData = UtilityForMap.convertMap(mLost);
            result.lostMap = lostData;
        }

        if (!String.isBlank(input.Rolling_Serialized_Won_Data__c)) {
            Map<String, Object> mWon = (Map<String, Object>) JSON.deserializeUntyped(
                input.Rolling_Serialized_Won_Data__c
            );
            Map<String, Decimal> wonData = UtilityForMap.convertMap(mWon);
            result.wonMap = wonData;
        }

        if (input.Rolling_Total_Lost__c != null) {
            result.totalLost = input.Rolling_Total_Lost__c;
        }
        if (input.Rolling_Total_Won__c != null) {
            result.totalWon = input.Rolling_Total_Won__c;
        }
        if (input.Rolling_Total_Won_With_Contact__c != null) {
            result.wonWithContact = input.Rolling_Total_Won_With_Contact__c;
        }
        if (input.Rolling_Total_Lost_With_Contact__c != null) {
            result.lostWithContact = input.Rolling_Total_Lost_With_Contact__c;
        }

        return result;
    }
}