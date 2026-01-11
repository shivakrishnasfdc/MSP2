public class FieldWrapper implements Comparable {
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public Boolean isOrgChartField { get; set; }
    @AuraEnabled
    public Boolean isRequired { get; set; }
    @AuraEnabled
    public Boolean isNameField { get; set; }
    @AuraEnabled
    public String relatedFieldName { get; set; }

    public FieldWrapper() {
        this(null, null, null, null, null, null);
    }

    public FieldWrapper(
        String label,
        String name,
        Boolean isOrgChartField,
        Boolean isRequired,
        Boolean isNameField,
        String relatedFieldName
    ) {
        this.label = label;
        this.name = name;
        this.isOrgChartField = isOrgChartField;
        this.isRequired = isRequired;
        this.isNameField = isNameField;
        this.relatedFieldName = relatedFieldName;
    }

    public Integer compareTo(Object obj) {
        FieldWrapper field = (FieldWrapper) (obj);

        if (this.label > field.label) {
            return 1;
        }

        if (this.label == field.label) {
            return 0;
        }

        return -1;
    }
}