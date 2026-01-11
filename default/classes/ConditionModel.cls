public with sharing class ConditionModel {
    @AuraEnabled
    public string operator { get; set; }
    @AuraEnabled
    public List<MappingConditionWrapper> singleConditions { get; set; }
}