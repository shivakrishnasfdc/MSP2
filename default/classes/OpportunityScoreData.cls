public with sharing class OpportunityScoreData {
    @AuraEnabled
    public List<NameDecimalPair> dataList { get; set; }
    @AuraEnabled
    public Decimal withOpportunityContact { get ; set; }
    @AuraEnabled
    public Decimal normalizedScore { get; set; }

    public OpportunityScoreData(
    ) {
        this.dataList = new List<NameDecimalPair>();
        this.withOpportunityContact = 0;
        this.normalizedScore = 0;
    }
}