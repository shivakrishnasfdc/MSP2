public with sharing class PlanScore {
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public List<Decimal> scores { get; set; }

    public PlanScore(String name) {
        this.name = name;
        this.scores = new List<Decimal>();
    }
}