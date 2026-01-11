public with sharing class NameDecimalPair {
    @AuraEnabled
    public String name;

    @AuraEnabled
    public Decimal value;

    public NameDecimalPair(String name, Decimal value) {
        this.name = name;
        this.value = value;
    }
}