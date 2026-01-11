public with sharing class LightningSelectOption implements Comparable {
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String value { get; set; }
    @AuraEnabled
    public Boolean disabled { get; set; }
    @AuraEnabled
    public Boolean escapeItem { get; set; }

    public LightningSelectOption(String value, String label) {
        this.value = value;
        this.label = label;
        this.disabled = false;
        this.escapeItem = false;
    }

    public LightningSelectOption(String value, String label, Boolean isDisabled) {
        this.value = value;
        this.label = label;
        this.disabled = isDisabled;
        this.escapeItem = false;
    }

    public Integer compareTo(Object obj) {
        LightningSelectOption option = (LightningSelectOption) (obj);

        if (this.label > option.label) {
            return 1;
        }

        if (this.label == option.label) {
            return 0;
        }

        return -1;
    }
}