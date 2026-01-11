public with sharing class MatrixWrapper {
    @AuraEnabled
    public Id id;

    @AuraEnabled
    public List<InfluenceWrapper> influenceList;

    @AuraEnabled
    public String influenceLabel;

    @AuraEnabled
    public List<SupportWrapper> supportList;

    @AuraEnabled
    public String supportLabel;

    public MatrixWrapper(pq_Influence_And_Support_Matrix__c matrix, List<InfluenceWrapper> influenceList, List<SupportWrapper> supportList) {
        this.id = matrix?.Id;
        this.influenceLabel = matrix?.Influence_Label__c;
        this.supportLabel = matrix?.Support_Label__c;
        this.influenceList = influenceList;
        this.supportList = supportList;
    }
}