public with sharing class ObjectUpdatibility {
    @auraEnabled
    public String name;

    @auraEnabled
    public Map<String, Boolean> fields;

    public ObjectUpdatibility(String name, Map<String, Boolean> fields) {
        this.name = name;
        this.fields = fields;
    }
}