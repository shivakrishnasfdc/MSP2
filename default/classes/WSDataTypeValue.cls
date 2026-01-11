public with sharing class WSDataTypeValue {
    @AuraEnabled
    public Id id;

    @AuraEnabled
    public Id dataTypeId;

    @AuraEnabled
    public String dataTypeLabel;

    @AuraEnabled
    public String color;

    @AuraEnabled
    public String value;

    public WSDataTypeValue(Id id, Id dataTypeId, String dataTypeLabel, String value, String color) {
        this.id = id;
        this.dataTypeId = dataTypeId;
        this.dataTypeLabel = dataTypeLabel;
        this.value = value;
        this.color = color;
    }

    public Boolean equals(Object obj) {
        if (obj == null || !(obj instanceof WSDataTypeValue)) {
            return false;
        }

        WSDataTypeValue other = (WSDataTypeValue) obj;

        if (this.id != null) {
            return this.id == other.id;
        }

        return false;
    }

    public Integer hashCode() {
        return System.hashCode(this.id);
    }
}