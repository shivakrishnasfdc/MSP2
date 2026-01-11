@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class OrgChartFieldWrapper {
    @AuraEnabled
    public Id id { get; set; }

    @AuraEnabled
    public String name { get; set; }

    @AuraEnabled
    public String objectName { get; set; }

    @AuraEnabled
    public String fieldName { get; set; }

    @AuraEnabled
    public String fieldLabel { get; set; }

    @AuraEnabled
    public Boolean isRequired { get; set; }

    @AuraEnabled
    public Boolean isVisible { get; set; }

    @AuraEnabled
    public String order { get; set; }

    @AuraEnabled
    public String mapType { get; set; }

    @AuraEnabled
    public Boolean isMain { get; set; }

    @AuraEnabled
    public Boolean isEditable { get; set; }

    @AuraEnabled
    public String relatedFieldName { get; set; }

    public OrgChartFieldWrapper(Org_Chart_Field__c ocf) {
        this.id = ocf.Id;
        this.name = ocf.Name;
        this.objectName = ocf.ObjectName__c;
        this.fieldName = ocf.FieldName__c;
        this.fieldLabel = ocf.FieldLabel__c;
        this.isRequired = ocf.isRequired__c;
        this.isVisible = ocf.isVisible__c;
        this.order = ocf.Order__c;
        this.mapType = ocf.Map_Type__c;
        this.isMain = ocf.IsMain__c;
        this.isEditable = true;
        this.relatedFieldName = ocf.Related_FieldName__c;

        if (this.objectName == 'Contact') {
            if (this.fieldName == 'Title' || this.fieldName == 'Name') {
                this.isEditable = false;
                this.isMain = true;
            }
        } else {
            if (this.fieldName == 'pqcrush__Influence__c' || this.fieldName == 'pqcrush__Support__c') {
                this.isEditable = false;
                this.isMain = true;
            }
        }
    }

    public Org_Chart_Field__c toSObject() {
        Org_Chart_Field__c result = new Org_Chart_Field__c(
            Id = this.id,
            Name = this.name,
            ObjectName__c = this.objectName,
            FieldName__c = this.fieldName,
            FieldLabel__c = this.fieldLabel,
            Map_Type__c = this.mapType,
            Related_FieldName__c = this.relatedFieldName
        );

        if (this.isRequired != null) {
            result.isRequired__c = this.isRequired;
        }

        if (this.isVisible != null) {
            result.isVisible__c = this.isVisible;
        }

        if (this.isMain != null) {
            result.IsMain__c = this.isMain;
        }

        return result;
    }

    public static List<Org_Chart_Field__c> toSObjectList(List<OrgChartFieldWrapper> inputList) {
        List<Org_Chart_Field__c> result = new List<Org_Chart_Field__c>();
        if (inputList == null || inputList.size() <= 0) {
            return result;
        }

        for (OrgChartFieldWrapper wrapper : inputList) {
            result.add(wrapper.toSObject());
        }

        return result;
    }
}